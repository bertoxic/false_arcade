import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/games/edge_load/edge_load_game.dart';
import 'package:fluga/games/false_habit/echo_heist_game.dart';

void main() {
  test('archive extraction and habit fractures have explicit rules', () {
    expect(EchoHeistRules.exitsOpen(stolen: 3, required: 3), isTrue);
    expect(EchoHeistRules.exitsOpen(stolen: 2, required: 3), isFalse);
    expect(
      EchoHeistRules.breaksRead(
        predicted: 'EAST',
        actual: 'NORTH',
        wardenReading: true,
      ),
      isTrue,
    );
    expect(
      EchoHeistRules.breaksRead(
        predicted: 'EAST',
        actual: 'EAST',
        wardenReading: true,
      ),
      isFalse,
    );
    expect(
      EchoHeistRules.breakBonus(chain: 3, campaignLevel: 5),
      greaterThan(EchoHeistRules.breakBonus(chain: 1, campaignLevel: 1)),
    );
  });

  testWidgets('False Habit starts the rewired archive heist', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EchoHeistPage()));
    expect(find.text('ENTER THE ARCHIVE'), findsOneWidget);
    await tester.tap(find.text('ENTER THE ARCHIVE'));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('ECHO'), findsWidgets);
    expect(find.textContaining('FALSE HABIT · ARCHIVE 24'), findsOneWidget);
    expect(find.textContaining('STEAL 0/3 TRUTH FRAGMENTS'), findsOneWidget);
    expect(find.textContaining('LEARNING EAST'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
    expect(find.text('RUN PAUSED'), findsOneWidget);
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
    expect(find.text('ENTER THE ARCHIVE'), findsOneWidget);

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
    expect(find.textContaining('DIAMOND 0/1'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
    expect(find.text('RUN PAUSED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
