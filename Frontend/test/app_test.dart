import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoMonitorApp());

    // Check that the login title or button exists
    expect(find.text('Login'), findsOneWidget);
  });
}