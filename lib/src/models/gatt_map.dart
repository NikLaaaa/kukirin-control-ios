class GattCharacteristicInfo {
  const GattCharacteristicInfo({
    required this.uuid,
    required this.capabilities,
  });

  final String uuid;
  final String capabilities;
}

class GattServiceInfo {
  const GattServiceInfo({required this.uuid, required this.characteristics});

  final String uuid;
  final List<GattCharacteristicInfo> characteristics;
}
