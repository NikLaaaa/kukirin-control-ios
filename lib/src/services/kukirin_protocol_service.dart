import '../models/control_action.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_snapshot.dart';
import '../models/toggle_setting.dart';

class KuKirinProtocolService {
  List<ProtocolProfile> get profiles => const <ProtocolProfile>[
    ProtocolProfile(
      id: 'universal-placeholder',
      name: 'Universal KuKirin Placeholder',
      family: 'All models',
      note:
          'Safe default for UI development. Replace with verified UUIDs and packet map before sending commands.',
    ),
    ProtocolProfile(
      id: 'touch-dashboard-2025',
      name: 'Touch Dashboard Family',
      family: 'G2 / G3 / G4 / newer touch displays',
      note:
          'Prepared for modern touch dashboards once a real GATT capture from the official app is available.',
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
    ];
  }

  String draftCommand(ControlActionKind action) {
    return 'AA 55 ${action.draftToken} <payload> <checksum>';
  }

  String draftSetting(ToggleSettingId settingId, bool value) {
    final settingName = switch (settingId) {
      ToggleSettingId.cruiseControl => 'SET_CRUISE',
      ToggleSettingId.zeroStart => 'SET_ZERO_START',
      ToggleSettingId.singleMotorMode => 'SET_SINGLE_MOTOR',
    };

    final payload = value ? '01' : '00';
    return 'AA 55 $settingName $payload <checksum>';
  }

  List<int> encodeCommand(ControlActionKind action) {
    throw UnsupportedError(
      'Real KuKirin command encoding is intentionally blocked until a verified protocol capture is added.',
    );
  }

  List<int> encodeSetting(ToggleSettingId settingId, bool value) {
    throw UnsupportedError(
      'Real KuKirin setting encoding is intentionally blocked until a verified protocol capture is added.',
    );
  }

  ScooterSnapshot decodeTelemetry(
    List<int> packet, {
    required ScooterSnapshot previous,
  }) {
    return previous.copyWith(
      protocolBound: true,
      isLiveData: true,
      updatedAt: DateTime.now(),
      lastPacketHex: toHex(packet),
      statusLine:
          'Live BLE packets detected. Map fields in KuKirinProtocolService.decodeTelemetry().',
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
        statusLine: 'Demo mode switched to Drive.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.sportMode => snapshot.copyWith(
        rideMode: RideMode.sport,
        updatedAt: DateTime.now(),
        statusLine: 'Demo mode switched to Sport.',
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
        statusLine: 'Demo mode switched to single motor.',
        lastPacketHex: draftCommand(action),
      ),
      ControlActionKind.dualMotor => snapshot.copyWith(
        singleMotorMode: false,
        updatedAt: DateTime.now(),
        statusLine: 'Demo mode switched to dual motor.',
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
        statusLine: 'Motor mode updated in demo mode.',
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
}
