import 'package:flutter_test/flutter_test.dart';
import 'package:kukirin_control_ios/src/models/control_action.dart';
import 'package:kukirin_control_ios/src/models/scooter_snapshot.dart';
import 'package:kukirin_control_ios/src/models/toggle_setting.dart';
import 'package:kukirin_control_ios/src/services/kukirin_protocol_service.dart';

void main() {
  group('KuKirinProtocolService', () {
    final service = KuKirinProtocolService();

    test('creates draft frames for actions', () {
      expect(
        service.draftCommand(ControlActionKind.lock),
        contains('CMD_LOCK'),
      );
    });

    test('applies demo settings to snapshot', () {
      final updated = service.applyDemoSetting(
        ScooterSnapshot.demo(),
        ToggleSettingId.cruiseControl,
        true,
      );

      expect(updated.cruiseEnabled, isTrue);
      expect(updated.lastPacketHex, contains('SET_CRUISE'));
    });

    test('advances demo telemetry over time', () {
      final updated = service.advanceDemoSnapshot(
        ScooterSnapshot.demo(),
        tick: 3,
      );

      expect(updated.speedKmh, isNonZero);
      expect(updated.updatedAt, isA<DateTime>());
    });
  });
}
