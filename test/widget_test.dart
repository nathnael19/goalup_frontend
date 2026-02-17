// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:goalup/main.dart';
import 'package:goalup/services/notification_service.dart';

void main() {
  testWidgets('GoalUp app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GoalUpApp(notificationService: NotificationService()),
    );

    // Verify that the app title is displayed
    expect(find.text('GoalUp'), findsOneWidget);

    // Verify that the bottom navigation has all tabs
    expect(find.text('Live Scores'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Standings'), findsOneWidget);
    expect(find.text('Teams'), findsOneWidget);
  });
}
