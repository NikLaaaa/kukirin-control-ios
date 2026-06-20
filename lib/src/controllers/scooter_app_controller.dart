import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ble_runtime_models.dart';
import '../models/control_action.dart';
import '../models/gatt_map.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_device.dart';
import '../models/scooter_snapshot.dart';
import '../models/toggle_setting.dart';
import '../services/ble_scooter_repository.dart';
import '../services/kukirin_protocol_service.dart';

class ScooterAppController extends ChangeNotifier {
  static const int searchTabIndex = 0;
  static const int dashboardTabIndex = 1;
  static const int protocolTabIndex = 2;

  ScooterAppController({
    required this._bleRepository,
    required KuKirinProtocolService protocolService,
  }) : _protocolService = protocolService,
       availableProfiles = protocolService.profiles,
       rideSettings = Map<ToggleSettingId, ToggleSetting>.fromEntries(
         protocolService.defaultRideSettings().map(
           (setting) => MapEntry(setting.id, setting),
         ),
       ),
       activeProfile = protocolService.profiles.first;

  final BleScooterRepository _bleRepository;
  final KuKirinProtocolService _protocolService;

  final List<ProtocolProfile> availableProfiles;
  final Map<ToggleSettingId, ToggleSetting> rideSettings;

  ProtocolProfile activeProfile;
  AppBleStatus bleStatus = AppBleStatus.unknown;
  List<ScooterDevice> devices = const <ScooterDevice>[];
  ScooterDevice? connectedDevice;
  AppConnectionState? connectionState;
  ScooterSnapshot snapshot = ScooterSnapshot.placeholder();
  List<GattServiceInfo> discoveredServices = const <GattServiceInfo>[];
  bool isScanning = false;
  bool isDemoMode = false;
  bool isApplyingChange = false;
  int selectedTab = searchTabIndex;
  String statusMessage = 'Initialize Bluetooth to start scanning.';
  String draftPreview = 'No command drafted yet.';
  String lastActionLabel = 'None';
  String activeOperationLabel = 'Idle';
  String? lastError;

  StreamSubscription<AppBleStatus>? _bleStatusSubscription;
  StreamSubscription<ScooterDevice>? _scanSubscription;
  StreamSubscription<AppConnectionUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _telemetrySubscription;
  Timer? _demoTimer;
  int _demoTick = 0;

  bool get hasConnectedTransport =>
      isDemoMode || connectionState == AppConnectionState.connected;

  bool get canViewDashboard => hasConnectedTransport;

  bool get isPreviewOnlyPlatform => _bleRepository.isPreviewOnlyPlatform;

  bool get canSendLiveCommands =>
      !isDemoMode &&
      connectionState == AppConnectionState.connected &&
      activeProfile.isBindable;

  void initialize() {
    _bleStatusSubscription ??= _bleRepository.watchBleStatus().listen(
      (status) {
        bleStatus = status;
        if (status == AppBleStatus.ready &&
            statusMessage.startsWith('Initialize')) {
          statusMessage = 'Bluetooth ready. Scan for a KuKirin scooter.';
        }
        notifyListeners();
      },
      onError: (Object error) {
        lastError = error.toString();
        statusMessage = 'Bluetooth initialization failed.';
        notifyListeners();
      },
    );
  }

  void setSelectedTab(int index) {
    if (selectedTab == index) {
      return;
    }

    selectedTab = index;
    notifyListeners();
  }

  void selectProfile(String profileId) {
    final nextProfile = availableProfiles.firstWhere(
      (profile) => profile.id == profileId,
      orElse: () => activeProfile,
    );

    activeProfile = nextProfile;
    statusMessage =
        '${activeProfile.name} selected. ${activeProfile.verified ? 'Verified commands enabled.' : 'Waiting for verified UUID mapping.'}';
    notifyListeners();
  }

  Future<void> startScan() async {
    await _stopDemoMode();
    await _scanSubscription?.cancel();

    devices = const <ScooterDevice>[];
    isScanning = true;
    lastError = null;
    statusMessage = 'Scanning for BLE devices nearby...';
    notifyListeners();

    _scanSubscription = _bleRepository.scanDevices().listen(
      (candidate) {
        final nextDevices = <ScooterDevice>[...devices];
        final existingIndex = nextDevices.indexWhere(
          (item) => item.id == candidate.id,
        );

        if (existingIndex >= 0) {
          nextDevices[existingIndex] = candidate;
        } else {
          nextDevices.add(candidate);
        }

        nextDevices.sort((left, right) {
          if (left.looksLikeKukirin != right.looksLikeKukirin) {
            return left.looksLikeKukirin ? -1 : 1;
          }
          return right.rssi.compareTo(left.rssi);
        });

        devices = nextDevices;
        statusMessage = nextDevices.any((item) => item.looksLikeKukirin)
            ? 'Possible KuKirin devices found. Pick one to connect.'
            : 'Scanning. If your scooter stays hidden, keep the dashboard awake.';
        notifyListeners();
      },
      onError: (Object error) {
        isScanning = false;
        lastError = error.toString();
        statusMessage = 'Scan failed. Check Bluetooth permissions on iPhone.';
        notifyListeners();
      },
    );
  }

  Future<void> stopScan() async {
    isScanning = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    statusMessage = devices.isEmpty
        ? 'Scan stopped. No devices collected yet.'
        : 'Scan stopped. ${devices.length} device(s) cached.';
    notifyListeners();
  }

  Future<void> connectToDevice(ScooterDevice device) async {
    await _stopDemoMode();
    await stopScan();
    await _disconnectLiveTransport(clearDevice: false);

    connectedDevice = device;
    connectionState = AppConnectionState.connecting;
    discoveredServices = const <GattServiceInfo>[];
    snapshot = ScooterSnapshot.placeholder().copyWith(
      statusLine:
          'Connecting to ${device.displayName}. Waiting for BLE handshake.',
      updatedAt: DateTime.now(),
    );
    statusMessage = 'Opening BLE transport to ${device.displayName}...';
    notifyListeners();

    _connectionSubscription = _bleRepository
        .connect(deviceId: device.id, profile: activeProfile)
        .listen(
          (update) async {
            connectionState = update.connectionState;

            switch (update.connectionState) {
              case AppConnectionState.connecting:
                statusMessage = 'Negotiating connection...';
                break;
              case AppConnectionState.connected:
                statusMessage =
                    'Connected. Reading services and characteristics...';
                setSelectedTab(dashboardTabIndex);
                snapshot = snapshot.copyWith(
                  isLiveData: true,
                  protocolBound: activeProfile.isBindable,
                  updatedAt: DateTime.now(),
                  statusLine: activeProfile.isBindable
                      ? 'Profile is verified. Live telemetry binding can start.'
                      : 'BLE transport is open, but KuKirin telemetry mapping still needs verified UUIDs.',
                );
                notifyListeners();
                await _hydrateGattMap(device.id);
                await _tryBindTelemetry(device.id);
                break;
              case AppConnectionState.disconnecting:
                statusMessage = 'Disconnecting from scooter...';
                break;
              case AppConnectionState.disconnected:
                statusMessage = 'Scooter disconnected.';
                snapshot = snapshot.copyWith(
                  isLiveData: false,
                  protocolBound: false,
                  updatedAt: DateTime.now(),
                  statusLine: 'Transport closed. Reconnect to continue.',
                );
                await _telemetrySubscription?.cancel();
                break;
            }

            notifyListeners();
          },
          onError: (Object error) async {
            lastError = error.toString();
            connectionState = AppConnectionState.disconnected;
            statusMessage = 'Connection failed.';
            snapshot = snapshot.copyWith(
              isLiveData: false,
              protocolBound: false,
              updatedAt: DateTime.now(),
              statusLine:
                  'Could not connect. Keep the scooter awake and retry.',
            );
            await _telemetrySubscription?.cancel();
            notifyListeners();
          },
        );
  }

  Future<void> startDemoMode() async {
    await _disconnectLiveTransport();
    await stopScan();

    isDemoMode = true;
    connectedDevice = ScooterDevice.demo();
    connectionState = AppConnectionState.connected;
    selectedTab = dashboardTabIndex;
    discoveredServices = const <GattServiceInfo>[];
    snapshot = ScooterSnapshot.demo();
    statusMessage =
        'Demo mode active. UI actions now change a simulated scooter.';
    notifyListeners();

    _demoTick = 0;
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _demoTick += 1;
      snapshot = _protocolService.advanceDemoSnapshot(
        snapshot,
        tick: _demoTick,
      );
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    if (isDemoMode) {
      await _stopDemoMode();
      snapshot = ScooterSnapshot.placeholder().copyWith(
        statusLine: 'Demo mode stopped.',
        updatedAt: DateTime.now(),
      );
      statusMessage = 'Demo mode stopped.';
      setSelectedTab(searchTabIndex);
      notifyListeners();
      return;
    }

    await _disconnectLiveTransport();
    snapshot = ScooterSnapshot.placeholder().copyWith(
      statusLine: 'Disconnected from scooter.',
      updatedAt: DateTime.now(),
    );
    statusMessage = 'Disconnected.';
    setSelectedTab(searchTabIndex);
    notifyListeners();
  }

  Future<void> sendAction(ControlActionKind action) async {
    if (!hasConnectedTransport) {
      statusMessage = 'Connect a scooter or start demo mode first.';
      notifyListeners();
      return;
    }

    await _runGuardedOperation(action.label, () async {
      lastActionLabel = action.label;

      if (isDemoMode) {
        snapshot = _protocolService.applyDemoAction(snapshot, action);
        draftPreview = _protocolService.draftCommand(action);
        statusMessage = 'Demo action "${action.label}" applied.';
        _syncSettingsFromSnapshot();
        return;
      }

      draftPreview = _protocolService.draftCommand(action);

      if (!canSendLiveCommands || connectedDevice == null) {
        statusMessage =
            'Command drafted but not transmitted. Add verified KuKirin UUIDs for ${activeProfile.name}.';
        return;
      }

      try {
        await _bleRepository.writeCommand(
          deviceId: connectedDevice!.id,
          profile: activeProfile,
          payload: _protocolService.encodeCommand(action),
        );
        statusMessage = 'Live command "${action.label}" sent.';
      } catch (error) {
        lastError = error.toString();
        statusMessage = 'Live command failed.';
      }
    });
  }

  Future<void> toggleRideSetting(ToggleSettingId id, bool value) async {
    final current = rideSettings[id];
    if (current == null) {
      return;
    }

    await _runGuardedOperation(current.title, () async {
      rideSettings[id] = current.copyWith(value: value);

      if (isDemoMode) {
        snapshot = _protocolService.applyDemoSetting(snapshot, id, value);
        draftPreview = _protocolService.draftSetting(id, value);
        statusMessage = '${current.title} updated in demo mode.';
        return;
      }

      draftPreview = _protocolService.draftSetting(id, value);
      snapshot = _applySettingToSnapshot(snapshot, id, value);

      if (!canSendLiveCommands || connectedDevice == null) {
        statusMessage =
            '${current.title} updated in UI, but live write is blocked until protocol mapping is verified.';
        return;
      }

      try {
        await _bleRepository.writeCommand(
          deviceId: connectedDevice!.id,
          profile: activeProfile,
          payload: _protocolService.encodeSetting(id, value),
        );
        statusMessage = '${current.title} sent to the scooter.';
      } catch (error) {
        lastError = error.toString();
        rideSettings[id] = current;
        snapshot = _applySettingToSnapshot(snapshot, id, current.value);
        statusMessage = '${current.title} failed and was reverted.';
      }
    });
  }

  String bleStatusLabel() => switch (bleStatus) {
    AppBleStatus.unknown => 'Unknown',
    AppBleStatus.unsupported => 'Unsupported',
    AppBleStatus.unauthorized => 'Unauthorized',
    AppBleStatus.poweredOff => 'Powered off',
    AppBleStatus.ready => 'Ready',
  };

  String connectionLabel() {
    if (isDemoMode) {
      return 'Demo session';
    }

    return switch (connectionState) {
      AppConnectionState.connecting => 'Connecting',
      AppConnectionState.connected => 'Connected',
      AppConnectionState.disconnecting => 'Disconnecting',
      AppConnectionState.disconnected => 'Disconnected',
      null => 'Idle',
    };
  }

  @override
  void dispose() {
    unawaited(_scanSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    unawaited(_telemetrySubscription?.cancel());
    unawaited(_bleStatusSubscription?.cancel());
    _demoTimer?.cancel();
    unawaited(_bleRepository.dispose());
    super.dispose();
  }

  Future<void> _hydrateGattMap(String deviceId) async {
    try {
      discoveredServices = await _bleRepository.discoverGattMap(deviceId);
    } catch (error) {
      lastError = error.toString();
      statusMessage = 'Connected, but service discovery failed.';
    }

    notifyListeners();
  }

  Future<void> _tryBindTelemetry(String deviceId) async {
    await _telemetrySubscription?.cancel();

    if (!activeProfile.isBindable) {
      return;
    }

    _telemetrySubscription = _bleRepository
        .subscribeToTelemetry(deviceId: deviceId, profile: activeProfile)
        .listen(
          (packet) {
            snapshot = _protocolService.decodeTelemetry(
              packet,
              previous: snapshot,
            );
            notifyListeners();
          },
          onError: (Object error) {
            lastError = error.toString();
            statusMessage = 'Telemetry subscription failed.';
            notifyListeners();
          },
        );
  }

  Future<void> _disconnectLiveTransport({bool clearDevice = true}) async {
    await _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (clearDevice) {
      connectedDevice = null;
    }

    if (!isDemoMode) {
      connectionState = AppConnectionState.disconnected;
    }
  }

  Future<void> _stopDemoMode() async {
    if (!isDemoMode) {
      return;
    }

    _demoTimer?.cancel();
    _demoTimer = null;
    isDemoMode = false;
    connectedDevice = null;
    connectionState = null;
  }

  ScooterSnapshot _applySettingToSnapshot(
    ScooterSnapshot current,
    ToggleSettingId id,
    bool value,
  ) {
    return switch (id) {
      ToggleSettingId.cruiseControl => current.copyWith(
        cruiseEnabled: value,
        updatedAt: DateTime.now(),
      ),
      ToggleSettingId.zeroStart => current.copyWith(
        zeroStartEnabled: value,
        updatedAt: DateTime.now(),
      ),
      ToggleSettingId.singleMotorMode => current.copyWith(
        singleMotorMode: value,
        updatedAt: DateTime.now(),
      ),
    };
  }

  void _syncSettingsFromSnapshot() {
    rideSettings[ToggleSettingId.cruiseControl] =
        rideSettings[ToggleSettingId.cruiseControl]!.copyWith(
          value: snapshot.cruiseEnabled,
        );
    rideSettings[ToggleSettingId.zeroStart] =
        rideSettings[ToggleSettingId.zeroStart]!.copyWith(
          value: snapshot.zeroStartEnabled,
        );
    rideSettings[ToggleSettingId.singleMotorMode] =
        rideSettings[ToggleSettingId.singleMotorMode]!.copyWith(
          value: snapshot.singleMotorMode,
        );
  }

  Future<void> _runGuardedOperation(
    String label,
    Future<void> Function() action,
  ) async {
    if (isApplyingChange) {
      statusMessage =
          'Wait until "$activeOperationLabel" finishes before sending another change.';
      notifyListeners();
      return;
    }

    isApplyingChange = true;
    activeOperationLabel = label;
    notifyListeners();

    try {
      await action();
    } finally {
      isApplyingChange = false;
      activeOperationLabel = 'Idle';
      notifyListeners();
    }
  }
}
