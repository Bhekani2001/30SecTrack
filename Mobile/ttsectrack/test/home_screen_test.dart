import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ttsectrack/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays logo and drawer', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Mobitra Tracker'), findsOneWidget);
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}