import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ttsectrack/screens/about_screen.dart';

void main() {
  testWidgets('AboutScreen displays about info', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.text('About'), findsOneWidget);
    expect(find.text('This is a demo app'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });
}