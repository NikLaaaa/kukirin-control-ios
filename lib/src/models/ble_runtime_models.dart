enum AppBleStatus { unknown, unsupported, unauthorized, poweredOff, ready }

enum AppConnectionState { connecting, connected, disconnecting, disconnected }

class AppConnectionUpdate {
  const AppConnectionUpdate({
    required this.deviceId,
    required this.connectionState,
    this.failure,
  });

  final String deviceId;
  final AppConnectionState connectionState;
  final String? failure;
}
