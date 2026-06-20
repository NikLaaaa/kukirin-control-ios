class ProtocolProfile {
  const ProtocolProfile({
    required this.id,
    required this.name,
    required this.family,
    required this.note,
    this.serviceUuid,
    this.writeCharacteristicUuid,
    this.notifyCharacteristicUuid,
    this.verified = false,
  });

  final String id;
  final String name;
  final String family;
  final String note;
  final String? serviceUuid;
  final String? writeCharacteristicUuid;
  final String? notifyCharacteristicUuid;
  final bool verified;

  bool get isBindable =>
      verified &&
      serviceUuid != null &&
      writeCharacteristicUuid != null &&
      notifyCharacteristicUuid != null;
}
