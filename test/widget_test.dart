// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_minesweeper/main.dart';

void main() {
  testWidgets('踩地雷 - 開始新遊戲', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    expect(find.text('000'), findsOneWidget);
    expect(find.byIcon(Icons.mood), findsOneWidget);
  
    await tester.tap(find.byIcon(Icons.mood));
    await tester.pump();

    // expect(find.text('000'), findsNothing);
  });
}
