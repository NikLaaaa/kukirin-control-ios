enum RideMode { eco, drive, sport }

extension RideModeX on RideMode {
  String get label => switch (this) {
    RideMode.eco => 'Eco',
    RideMode.drive => 'Sport',
    RideMode.sport => 'Race',
  };
}

class ScooterSnapshot {
  const ScooterSnapshot({
    required this.rideMode,
    required this.voltage,
    required this.speedKmh,
    required this.batteryPercent,
    required this.controllerTempC,
    required this.odometerKm,
    required this.tripKm,
    required this.estimatedRangeKm,
    required this.currentDrawA,
    required this.motorRpm,
    required this.locked,
    required this.lightsEnabled,
    required this.cruiseEnabled,
    required this.zeroStartEnabled,
    required this.singleMotorMode,
    required this.protocolBound,
    required this.isLiveData,
    required this.updatedAt,
    required this.statusLine,
    this.lastPacketHex,
  });

  final RideMode rideMode;
  final double voltage;
  final double speedKmh;
  final int batteryPercent;
  final double controllerTempC;
  final double odometerKm;
  final double tripKm;
  final double estimatedRangeKm;
  final double currentDrawA;
  final int motorRpm;
  final bool locked;
  final bool lightsEnabled;
  final bool cruiseEnabled;
  final bool zeroStartEnabled;
  final bool singleMotorMode;
  final bool protocolBound;
  final bool isLiveData;
  final DateTime updatedAt;
  final String statusLine;
  final String? lastPacketHex;

  factory ScooterSnapshot.placeholder() {
    return ScooterSnapshot(
      rideMode: RideMode.drive,
      voltage: 0,
      speedKmh: 0,
      batteryPercent: 0,
      controllerTempC: 0,
      odometerKm: 0,
      tripKm: 0,
      estimatedRangeKm: 0,
      currentDrawA: 0,
      motorRpm: 0,
      locked: false,
      lightsEnabled: false,
      cruiseEnabled: false,
      zeroStartEnabled: false,
      singleMotorMode: true,
      protocolBound: false,
      isLiveData: false,
      updatedAt: DateTime.now(),
      statusLine: 'Waiting for a scooter connection.',
    );
  }

  factory ScooterSnapshot.demo() {
    return ScooterSnapshot(
      rideMode: RideMode.drive,
      voltage: 52.8,
      speedKmh: 18.4,
      batteryPercent: 74,
      controllerTempC: 38.2,
      odometerKm: 1284.6,
      tripKm: 12.8,
      estimatedRangeKm: 31.0,
      currentDrawA: 12.6,
      motorRpm: 860,
      locked: false,
      lightsEnabled: true,
      cruiseEnabled: false,
      zeroStartEnabled: true,
      singleMotorMode: true,
      protocolBound: true,
      isLiveData: true,
      updatedAt: DateTime.now(),
      statusLine: 'Demo mode simulates a healthy KuKirin session.',
      lastPacketHex: 'AA 55 10 04 2C 01',
    );
  }

  ScooterSnapshot copyWith({
    RideMode? rideMode,
    double? voltage,
    double? speedKmh,
    int? batteryPercent,
    double? controllerTempC,
    double? odometerKm,
    double? tripKm,
    double? estimatedRangeKm,
    double? currentDrawA,
    int? motorRpm,
    bool? locked,
    bool? lightsEnabled,
    bool? cruiseEnabled,
    bool? zeroStartEnabled,
    bool? singleMotorMode,
    bool? protocolBound,
    bool? isLiveData,
    DateTime? updatedAt,
    String? statusLine,
    String? lastPacketHex,
  }) {
    return ScooterSnapshot(
      rideMode: rideMode ?? this.rideMode,
      voltage: voltage ?? this.voltage,
      speedKmh: speedKmh ?? this.speedKmh,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      controllerTempC: controllerTempC ?? this.controllerTempC,
      odometerKm: odometerKm ?? this.odometerKm,
      tripKm: tripKm ?? this.tripKm,
      estimatedRangeKm: estimatedRangeKm ?? this.estimatedRangeKm,
      currentDrawA: currentDrawA ?? this.currentDrawA,
      motorRpm: motorRpm ?? this.motorRpm,
      locked: locked ?? this.locked,
      lightsEnabled: lightsEnabled ?? this.lightsEnabled,
      cruiseEnabled: cruiseEnabled ?? this.cruiseEnabled,
      zeroStartEnabled: zeroStartEnabled ?? this.zeroStartEnabled,
      singleMotorMode: singleMotorMode ?? this.singleMotorMode,
      protocolBound: protocolBound ?? this.protocolBound,
      isLiveData: isLiveData ?? this.isLiveData,
      updatedAt: updatedAt ?? this.updatedAt,
      statusLine: statusLine ?? this.statusLine,
      lastPacketHex: lastPacketHex ?? this.lastPacketHex,
    );
  }
}
