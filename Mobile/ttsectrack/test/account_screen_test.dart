import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ttsectrack/screens/account_screen.dart';

void main() {
  testWidgets('AccountScreen displays account info', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
  });
}