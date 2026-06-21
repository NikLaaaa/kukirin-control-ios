import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../models/ble_runtime_models.dart';
import '../models/gatt_map.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_device.dart';

class BleScooterRepository {
  BleScooterRepository()
    : _ble = Platform.isWindows ? null : FlutterReactiveBle();

  final FlutterReactiveBle? _ble;

  bool get isPreviewOnlyPlatform => Platform.isWindows;

  FlutterReactiveBle get _liveBle {
    final ble = _ble;
    if (ble == null) {
      throw StateError('Live BLE is not available on this preview platform.');
    }
    return ble;
  }

  Stream<AppBleStatus> watchBleStatus() {
    if (isPreviewOnlyPlatform) {
      return Stream<AppBleStatus>.value(AppBleStatus.ready);
    }
    return _liveBle.statusStream.map(_mapBleStatus);
  }

  Stream<ScooterDevice> scanDevices() {
    if (isPreviewOnlyPlatform) {
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
    return _liveBle
        .scanForDevices(
          withServices: const <Uuid>[],
          scanMode: ScanMode.lowLatency,
          requireLocationServicesEnabled: false,
        )
        .map(_mapDevice);
  }

  Stream<AppConnectionUpdate> connect({
    required String deviceId,
    ProtocolProfile? profile,
  }) {
    if (isPreviewOnlyPlatform) {
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

    final discoveryMap = _buildDiscoveryMap(profile);
    return _liveBle
        .connectToDevice(
          id: deviceId,
          servicesWithCharacteristicsToDiscover: discoveryMap.isEmpty
              ? null
              : discoveryMap,
          connectionTimeout: const Duration(seconds: 10),
        )
        .map(_mapConnectionUpdate);
  }

  Future<List<GattServiceInfo>> discoverGattMap(String deviceId) async {
    if (isPreviewOnlyPlatform) {
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

    await _liveBle.discoverAllServices(deviceId);
    final services = await _liveBle.getDiscoveredServices(deviceId);

    return services
        .map(
          (service) => GattServiceInfo(
            uuid: service.id.toString(),
            characteristics: service.characteristics
                .map(
                  (characteristic) => GattCharacteristicInfo(
                    uuid: characteristic.id.toString(),
                    capabilities: _describeCharacteristic(characteristic),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Stream<List<int>> subscribeToTelemetry({
    required String deviceId,
    required ProtocolProfile profile,
  }) {
    if (isPreviewOnlyPlatform) {
      return const Stream<List<int>>.empty();
    }

    final notifyCharacteristic = _qualifiedCharacteristic(
      deviceId: deviceId,
      serviceUuid: profile.serviceUuid,
      characteristicUuid: profile.notifyCharacteristicUuid,
    );

    return _liveBle.subscribeToCharacteristic(notifyCharacteristic);
  }

  Future<void> writeCommand({
    required String deviceId,
    required ProtocolProfile profile,
    required List<int> payload,
    bool withResponse = true,
  }) async {
    if (isPreviewOnlyPlatform) {
      return;
    }

    final writeCharacteristic = _qualifiedCharacteristic(
      deviceId: deviceId,
      serviceUuid: profile.serviceUuid,
      characteristicUuid: profile.writeCharacteristicUuid,
    );

    await _liveBle.writeCharacteristicWithoutResponse(
      writeCharacteristic,
      value: payload,
    );
  }

  Future<void> dispose() async {
    if (isPreviewOnlyPlatform) {
      return;
    }
    await _liveBle.deinitialize();
  }

  Map<Uuid, List<Uuid>> _buildDiscoveryMap(ProtocolProfile? profile) {
    if (profile == null || !profile.isBindable) {
      return const <Uuid, List<Uuid>>{};
    }

    return <Uuid, List<Uuid>>{
      Uuid.parse(profile.serviceUuid!): <Uuid>[
        Uuid.parse(profile.writeCharacteristicUuid!),
        Uuid.parse(profile.notifyCharacteristicUuid!),
      ],
    };
  }

  QualifiedCharacteristic _qualifiedCharacteristic({
    required String deviceId,
    required String? serviceUuid,
    required String? characteristicUuid,
  }) {
    if (serviceUuid == null || characteristicUuid == null) {
      throw StateError('Protocol profile is missing characteristic UUIDs.');
    }

    return QualifiedCharacteristic(
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(characteristicUuid),
      deviceId: deviceId,
    );
  }

  String _describeCharacteristic(Characteristic characteristic) {
    final capabilities = <String>[];

    if (characteristic.isReadable) {
      capabilities.add('read');
    }
    if (characteristic.isWritableWithResponse) {
      capabilities.add('write');
    }
    if (characteristic.isWritableWithoutResponse) {
      capabilities.add('writeNoResp');
    }
    if (characteristic.isNotifiable) {
      capabilities.add('notify');
    }
    if (characteristic.isIndicatable) {
      capabilities.add('indicate');
    }

    return capabilities.join(' | ');
  }

  AppBleStatus _mapBleStatus(BleStatus status) {
    return switch (status) {
      BleStatus.unknown => AppBleStatus.unknown,
      BleStatus.unsupported => AppBleStatus.unsupported,
      BleStatus.unauthorized => AppBleStatus.unauthorized,
      BleStatus.poweredOff => AppBleStatus.poweredOff,
      BleStatus.locationServicesDisabled => AppBleStatus.poweredOff,
      BleStatus.ready => AppBleStatus.ready,
    };
  }

  AppConnectionUpdate _mapConnectionUpdate(ConnectionStateUpdate update) {
    return AppConnectionUpdate(
      deviceId: update.deviceId,
      connectionState: switch (update.connectionState) {
        DeviceConnectionState.connecting => AppConnectionState.connecting,
        DeviceConnectionState.connected => AppConnectionState.connected,
        DeviceConnectionState.disconnecting => AppConnectionState.disconnecting,
        DeviceConnectionState.disconnected => AppConnectionState.disconnected,
      },
      failure: update.failure?.toString(),
    );
  }

  ScooterDevice _mapDevice(DiscoveredDevice device) {
    return ScooterDevice(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
      connectable: device.connectable == Connectable.available,
      advertisedServices: device.serviceUuids
          .map((uuid) => uuid.toString())
          .toList(),
    );
  }
}
