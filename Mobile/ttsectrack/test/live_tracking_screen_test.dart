import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ttsectrack/screens/live_tracking_screen.dart';

void main() {
  testWidgets('LiveTrackingScreen displays status and history', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LiveTrackingScreen()));
    expect(find.text('Connection Status'), findsOneWidget);
    expect(find.text('Location History'), findsOneWidget);
  });
}