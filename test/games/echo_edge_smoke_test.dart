import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/games/edge_load/edge_load_game.dart';
import 'package:fluga/games/false_habit/echo_heist_game.dart';

Future<void> _advanceFrames(WidgetTester tester, int count) async {
  for (var frame = 0; frame < count; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  test('all diamonds unlock the exit without extra common loot', () {
    expect(
      EchoHeistRules.exitUnlocked(
        runLoot: 2400,
        stageTarget: 9000,
        allDiamondsTaken: true,
      ),
      isTrue,
    );
  });

  testWidgets('Echo Heist starts with its prediction controls active', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EchoHeistPage()));
    await tester.tap(find.text('START HEIST'));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('ECHO'), findsWidgets);
    expect(find.text('ESCAPE'), findsOneWidget);
    expect(find.text('WARDEN'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await _advanceFrames(tester, 180);
    expect(find.textContaining('WARDEN READ:'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Echo Heist exit returns to its launching route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const EchoHeistPage()),
              ),
              child: const Text('OPEN HEIST'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN HEIST'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('START HEIST'), findsOneWidget);

    await tester.tap(find.byTooltip('Exit game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('OPEN HEIST'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EdgeLoad exposes its mansion-run controls and HUD', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EdgeLoadPage()));
    await tester.tap(find.text('INFILTRATE'));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.bySemanticsLabel('Movement control'), findsOneWidget);
    expect(find.text('SPRINT'), findsWidgets);
    expect(find.text('COIN'), findsOneWidget);
    expect(find.text('MASK'), findsOneWidget);
    expect(find.text('MONEY'), findsOneWidget);
    expect(find.text('COINS'), findsOneWidget);
    expect(find.text('STEALTH'), findsOneWidget);
    expect(find.text('\$0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
