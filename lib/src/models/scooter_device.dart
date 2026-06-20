class ScooterDevice {
  const ScooterDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.connectable,
    required this.advertisedServices,
  });

  final String id;
  final String name;
  final int rssi;
  final bool connectable;
  final List<String> advertisedServices;

  factory ScooterDevice.demo() {
    return const ScooterDevice(
      id: 'demo-kukirin',
      name: 'KuKirin Demo Ride',
      rssi: -42,
      connectable: true,
      advertisedServices: <String>[],
    );
  }

  bool get looksLikeKukirin {
    final lowered = name.toLowerCase();
    return lowered.contains('kukirin') ||
        lowered.contains('kugoo') ||
        lowered.contains('kirin');
  }

  String get displayName => name.isEmpty ? 'Unnamed BLE device' : name;
}
