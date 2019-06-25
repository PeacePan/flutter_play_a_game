import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_play_a_game/main.dart';

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
