import '../models/control_action.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_snapshot.dart';
import '../models/toggle_setting.dart';

class KuKirinProtocolService {
  static const String _serviceUuid = '0000fff0-0000-1000-8000-00805f9b34fb';
  static const String _writeUuid = '0000fff1-0000-1000-8000-00805f9b34fb';
  static const String _notifyUuid = '0000fff2-0000-1000-8000-00805f9b34fb';

  List<ProtocolProfile> get profiles => const <ProtocolProfile>[
    ProtocolProfile(
      id: 'kukirin-fff0-v1',
      name: 'KuKirin FFF0 Live Profile',
      family: 'Models exposing FFF0 / FFF1 / FFF2',
      note:
          'Uses the live FFF0 BLE service with FFF1 writes and FFF2 telemetry notifications.',
      serviceUuid: _serviceUuid,
      writeCharacteristicUuid: _writeUuid,
      notifyCharacteristicUuid: _notifyUuid,
      verified: true,
    ),
    ProtocolProfile(
      id: 'touch-dashboard-2025',
      name: 'Touch Dashboard Family',
      family: 'G2 / G3 / G4 / newer touch displays',
      note:
          'Fallback profile for future variants if they do not expose the FFF0 BLE service.',
    ),
    ProtocolProfile(
      id: 'legacy-kugoo-lcd',
      name: 'Legacy Kugoo LCD Family',
      family: 'Older Kugoo / KuKirin LCD dashboards',
      note:
          'Use this profile if a legacy dashboard ends up exposing BLE, but packet mapping is still pending.',
    ),
  ];

  List<ToggleSetting> defaultRideSettings() {
    return const <ToggleSetting>[
      ToggleSetting(
        id: ToggleSettingId.cruiseControl,
        title: 'Cruise control',
        subtitle: 'Keep throttle steady on long rides.',
        value: false,
      ),
      ToggleSetting(
        id: ToggleSettingId.zeroStart,
        title: 'Zero start',
        subtitle: 'Allow standing launch without a kick start.',
        value: true,
      ),
      ToggleSetting(
        id: ToggleSettingId.singleMotorMode,
        title: 'Single motor mode',
        subtitle: 'Lower draw for longer range and smoother city riding.',
        value: true,
      ),
      ToggleSetting(
        id: ToggleSettingId.childMode,
        title: 'Child Mode',
        subtitle: 'Reduced power and speed.',
        value: false,
      ),
    ];
  }

  bool supportsLiveAction(ControlActionKind action) =>
      _actionPacketHex(action) != null;

  bool supportsLiveSetting(ToggleSettingId settingId) =>
      _settingPacketHex(settingId, true) != null;

  String draftCommand(ControlActionKind action) {
    return _actionPacketHex(action) ?? '${action.draftToken} (unsupported)';
  }

  String draftSetting(ToggleSettingId settingId, bool value) {
    return _settingPacketHex(settingId, value) ??
        '${settingId.name.toUpperCase()} (unsupported)';
  }

  List<int> encodeCommand(ControlActionKind action) {
    final packetHex = _actionPacketHex(action);
    if (packetHex == null) {
      throw UnsupportedError(
        'No live KuKirin packet is mapped for ${action.label} yet.',
      );
    }

    return _hexToBytes(packetHex);
  }

  List<int> encodeSetting(ToggleSettingId settingId, bool value) {
    final packetHex = _settingPacketHex(settingId, value);
    if (packetHex == null) {
      throw UnsupportedError(
        'No live KuKirin packet is mapped for ${settingId.name} yet.',
      );
    }

    return _hexToBytes(packetHex);
  }

  ScooterSnapshot decodeTelemetry(
    List<int> packet, {
    required ScooterSnapshot previous,
  }) {
    final parsed = _tryDecodeKnownTelemetry(packet, previous: previous);
    if (parsed != null) {
      return parsed.copyWith(
        protocolBound: true,
        isLiveData: true,
        updatedAt: DateTime.now(),
        lastPacketHex: toHex(packet),
        statusLine: 'Live telemetry packet decoded from FFF2 notifications.',
      );
    }

    return previous.copyWith(
      protocolBound: true,
      isLiveData: true,
      updatedAt: DateTime.now(),
      lastPacketHex: toHex(packet),
      statusLine:
          'Live FFF2 packets detected. Command writes are active, but this packet layout still needs field mapping for telemetry.',
    );
  }

  ScooterSnapshot applyDemoAction(
    ScooterSnapshot snapshot,
    ControlActionKind action,
  ) {
    return switch (action) {
      ControlActionKind.lock => snapshot.copyWith(
        locked: true,
        speedKmh: 0,
        currentDrawA: 0,
        updatedAt: DateTime.now(),
        statusLine: 'Scooter locked from the demo control panel.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.unlock => snapshot.copyWith(
        locked: false,
        updatedAt: DateTime.now(),
        statusLine: 'Scooter unlocked in demo mode.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.lights => snapshot.copyWith(
        lightsEnabled: !snapshot.lightsEnabled,
        updatedAt: DateTime.now(),
        statusLine: 'Lights toggled in demo mode.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.ecoMode => snapshot.copyWith(
        rideMode: RideMode.eco,
        updatedAt: DateTime.now(),
        statusLine: 'Demo mode switched to Eco.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.driveMode => snapshot.copyWith(
        rideMode: RideMode.drive,
        updatedAt: DateTime.now(),
        statusLine: 'Demo mode switched to Sport.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.sportMode => snapshot.copyWith(
        rideMode: RideMode.sport,
        updatedAt: DateTime.now(),
        statusLine: 'Demo mode switched to Race.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.horn => snapshot.copyWith(
        updatedAt: DateTime.now(),
        statusLine: 'Horn pulse sent in demo mode.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.singleMotor => snapshot.copyWith(
        singleMotorMode: true,
        updatedAt: DateTime.now(),
        statusLine: 'Single motor mode is not mapped for the live profile yet.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.dualMotor => snapshot.copyWith(
        singleMotorMode: false,
        updatedAt: DateTime.now(),
        statusLine: 'Dual motor mode is not mapped for the live profile yet.',
        lastPacketHex: draftCommand(action),
      ),
    };
  }

  ScooterSnapshot applyDemoSetting(
    ScooterSnapshot snapshot,
    ToggleSettingId settingId,
    bool value,
  ) {
    return switch (settingId) {
      ToggleSettingId.cruiseControl => snapshot.copyWith(
        cruiseEnabled: value,
        updatedAt: DateTime.now(),
        statusLine: 'Cruise control updated in demo mode.',
        lastPacketHex: draftSetting(settingId, value),
      ),
      ToggleSettingId.zeroStart => snapshot.copyWith(
        zeroStartEnabled: value,
        updatedAt: DateTime.now(),
        statusLine: 'Zero start updated in demo mode.',
        lastPacketHex: draftSetting(settingId, value),
      ),
      ToggleSettingId.singleMotorMode => snapshot.copyWith(
        singleMotorMode: value,
        updatedAt: DateTime.now(),
        statusLine: 'Motor mode setting is not mapped for the live profile yet.',
        lastPacketHex: draftSetting(settingId, value),
      ),
    };
  }

  ScooterSnapshot advanceDemoSnapshot(
    ScooterSnapshot snapshot, {
    required int tick,
  }) {
    if (snapshot.locked) {
      return snapshot.copyWith(
        speedKmh: 0,
        currentDrawA: 0,
        updatedAt: DateTime.now(),
      );
    }

    final nextMode = snapshot.rideMode;
    final baseSpeed = switch (nextMode) {
      RideMode.eco => 16.0,
      RideMode.drive => 24.0,
      RideMode.sport => 35.0,
    };

    final wave = (tick % 6) - 2;
    final nextSpeed = baseSpeed + wave.toDouble();
    final nextBattery = snapshot.batteryPercent > 8
        ? snapshot.batteryPercent - (tick % 9 == 0 ? 1 : 0)
        : snapshot.batteryPercent;

    return snapshot.copyWith(
      speedKmh: nextSpeed,
      currentDrawA: 10 + (nextSpeed / 2),
      motorRpm: (nextSpeed * 44).round(),
      voltage: 52.8 - ((100 - nextBattery) * 0.03),
      controllerTempC: 37 + (tick % 4).toDouble(),
      batteryPercent: nextBattery,
      tripKm: snapshot.tripKm + (nextSpeed / 3600),
      odometerKm: snapshot.odometerKm + (nextSpeed / 3600),
      estimatedRangeKm: nextBattery * 0.42,
      updatedAt: DateTime.now(),
      statusLine: 'Demo telemetry tick ${tick + 1} running.',
    );
  }

  String toHex(List<int> data) {
    return data
        .map((value) => value.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  String? _actionPacketHex(ControlActionKind action) {
    return switch (action) {
      ControlActionKind.lock => 'F041',
      ControlActionKind.unlock => 'F042',
      ControlActionKind.ecoMode => 'F04C0301',
      ControlActionKind.driveMode => 'F04C0302',
      ControlActionKind.sportMode => 'F04C0303',
      ControlActionKind.lights => null,
      ControlActionKind.horn => null,
      ControlActionKind.singleMotor => null,
      ControlActionKind.dualMotor => null,
    };
  }

  String? _settingPacketHex(ToggleSettingId settingId, bool value) {
    return switch (settingId) {
      ToggleSettingId.cruiseControl => value ? 'F04C1301' : 'F04C1300',
      ToggleSettingId.zeroStart => value ? 'F04C0201' : 'F04C0200',
      ToggleSettingId.singleMotorMode => null,
    };
  }

  List<int> _hexToBytes(String hex) {
    final sanitized = hex.replaceAll(' ', '');
    if (sanitized.length.isOdd) {
      throw FormatException('Packet hex length must be even: $hex');
    }

    return <int>[
      for (var index = 0; index < sanitized.length; index += 2)
        int.parse(sanitized.substring(index, index + 2), radix: 16),
    ];
  }

  ScooterSnapshot? _tryDecodeKnownTelemetry(
    List<int> packet, {
    required ScooterSnapshot previous,
  }) {
    if (packet.length < 10) {
      return null;
    }

    final modeValue = packet[7];
    if (modeValue < 1 || modeValue > 3) {
      return null;
    }

    final speedRaw = packet[0] | (packet[1] << 8);
    final voltageRaw = packet[2] | (packet[3] << 8);
    final batteryPercent = packet[4];
    final flags = packet[5];
    final rpmRaw = packet[8] | (packet[9] << 8);

    if (batteryPercent > 100 || speedRaw > 2000 || voltageRaw > 2000) {
      return null;
    }

    final nextMode = switch (modeValue) {
      1 => RideMode.eco,
      2 => RideMode.drive,
      3 => RideMode.sport,
      _ => previous.rideMode,
    };

    final speed = speedRaw / 10.0;
    final voltage = voltageRaw / 10.0;
    final odometer = packet.length >= 14
        ? ((packet[10]) |
                  (packet[11] << 8) |
                  (packet[12] << 16) |
                  (packet[13] << 24)) /
              10.0
        : previous.odometerKm;

    return previous.copyWith(
      rideMode: nextMode,
      speedKmh: speed,
      voltage: voltage,
      batteryPercent: batteryPercent,
      odometerKm: odometer,
      tripKm: previous.tripKm,
      estimatedRangeKm: batteryPercent * 0.42,
      currentDrawA: previous.currentDrawA,
      motorRpm: rpmRaw,
      cruiseEnabled: (flags & 0x01) != 0,
      zeroStartEnabled: (flags & 0x02) != 0,
      locked: (flags & 0x04) != 0,
    );
  }
}
