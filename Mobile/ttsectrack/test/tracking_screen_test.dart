import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ttsectrack/screens/tracking_screen.dart';

void main() {
  testWidgets('TrackingScreen displays status and location cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TrackingScreen()));
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Connection Status'), findsOneWidget);
    expect(find.text('Current Location'), findsOneWidget);
  });
}