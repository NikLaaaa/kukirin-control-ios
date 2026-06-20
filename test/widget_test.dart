import 'package:flutter_test/flutter_test.dart';
import 'package:kukirin_control_ios/src/app.dart';

void main() {
  testWidgets('app renders main shell', (WidgetTester tester) async {
    await tester.pumpWidget(const KukirinControlApp());

    expect(find.text('Search Devices'), findsOneWidget);
  });
}
