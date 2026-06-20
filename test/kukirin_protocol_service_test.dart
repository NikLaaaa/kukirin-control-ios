import 'package:flutter_test/flutter_test.dart';
import 'package:kukirin_control_ios/src/models/control_action.dart';
import 'package:kukirin_control_ios/src/models/scooter_snapshot.dart';
import 'package:kukirin_control_ios/src/models/toggle_setting.dart';
import 'package:kukirin_control_ios/src/services/kukirin_protocol_service.dart';

void main() {
  group('KuKirinProtocolService', () {
    final service = KuKirinProtocolService();

    test('creates live draft frames for mapped actions', () {
      expect(service.draftCommand(ControlActionKind.lock), 'F041');
      expect(service.draftCommand(ControlActionKind.driveMode), 'F04C0302');
    });

    test('encodes mapped live commands and settings', () {
      expect(service.encodeCommand(ControlActionKind.unlock), [0xF0, 0x42]);
      expect(
        service.encodeSetting(ToggleSettingId.zeroStart, true),
        [0xF0, 0x4C, 0x02, 0x01],
      );
    });

    test('rejects unsupported live actions and settings', () {
      expect(
        () => service.encodeCommand(ControlActionKind.horn),
        throwsUnsupportedError,
      );
      expect(
        () => service.encodeSetting(ToggleSettingId.singleMotorMode, true),
        throwsUnsupportedError,
      );
    });

    test('applies demo settings to snapshot', () {
      final updated = service.applyDemoSetting(
        ScooterSnapshot.demo(),
        ToggleSettingId.cruiseControl,
        true,
      );

      expect(updated.cruiseEnabled, isTrue);
      expect(updated.lastPacketHex, 'F04C1301');
    });

    test('advances demo telemetry over time', () {
      final updated = service.advanceDemoSnapshot(
        ScooterSnapshot.demo(),
        tick: 3,
      );

      expect(updated.speedKmh, isNonZero);
      expect(updated.updatedAt, isA<DateTime>());
    });

    test('decodes known telemetry layout conservatively', () {
      final updated = service.decodeTelemetry(
        const <int>[
          0x7B,
          0x00,
          0x0F,
          0x02,
          0x4A,
          0x07,
          0x00,
          0x02,
          0x20,
          0x03,
          0x39,
          0x30,
          0x00,
          0x00,
        ],
        previous: ScooterSnapshot.placeholder(),
      );

      expect(updated.speedKmh, 12.3);
      expect(updated.voltage, 52.7);
      expect(updated.batteryPercent, 74);
      expect(updated.locked, isTrue);
      expect(updated.cruiseEnabled, isTrue);
      expect(updated.zeroStartEnabled, isTrue);
      expect(updated.rideMode, RideMode.drive);
      expect(updated.motorRpm, 800);
      expect(updated.odometerKm, 1234.5);
    });
  });
}
