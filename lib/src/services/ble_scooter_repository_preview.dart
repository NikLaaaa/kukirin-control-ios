import '../models/ble_runtime_models.dart';
import '../models/gatt_map.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_device.dart';

class BleScooterRepository {
  bool get isPreviewOnlyPlatform => true;

  Stream<AppBleStatus> watchBleStatus() {
    return Stream<AppBleStatus>.value(AppBleStatus.ready);
  }

  Stream<ScooterDevice> scanDevices() {
    return Stream<ScooterDevice>.fromIterable(const [
      ScooterDevice(
        id: 'preview-kukirin-g2',
        name: 'KuKirin G2 Master',
        rssi: -41,
        connectable: true,
        advertisedServices: <String>['preview-service'],
      ),
      ScooterDevice(
        id: 'preview-kukirin-g4',
        name: 'KuKirin G4',
        rssi: -52,
        connectable: true,
        advertisedServices: <String>['preview-service'],
      ),
      ScooterDevice(
        id: 'preview-headlight',
        name: 'Generic BLE Peripheral',
        rssi: -67,
        connectable: true,
        advertisedServices: <String>[],
      ),
    ]);
  }

  Stream<AppConnectionUpdate> connect({
    required String deviceId,
    ProtocolProfile? profile,
  }) {
    return Stream<AppConnectionUpdate>.fromIterable([
      AppConnectionUpdate(
        deviceId: deviceId,
        connectionState: AppConnectionState.connecting,
      ),
      AppConnectionUpdate(
        deviceId: deviceId,
        connectionState: AppConnectionState.connected,
      ),
    ]);
  }

  Future<List<GattServiceInfo>> discoverGattMap(String deviceId) async {
    return const <GattServiceInfo>[
      GattServiceInfo(
        uuid: 'preview-service',
        characteristics: <GattCharacteristicInfo>[
          GattCharacteristicInfo(
            uuid: 'preview-write',
            capabilities: 'write | writeNoResp',
          ),
          GattCharacteristicInfo(
            uuid: 'preview-notify',
            capabilities: 'notify',
          ),
        ],
      ),
    ];
  }

  Stream<List<int>> subscribeToTelemetry({
    required String deviceId,
    required ProtocolProfile profile,
  }) {
    return const Stream<List<int>>.empty();
  }

  Future<void> writeCommand({
    required String deviceId,
    required ProtocolProfile profile,
    required List<int> payload,
    bool withResponse = true,
  }) async {}

  Future<void> dispose() async {}
}
