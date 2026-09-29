import 'package:fluga/games/false_habit/echo_heist_game.dart';
import 'package:fluga/games/future_debt/future_debt_game.dart';
import 'package:fluga/games/not_yet/not_yet_game.dart';
import 'package:fluga/ui/game_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Not Yet gives its playfield the full gameplay height', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RealityGamePage()));

    final playfield = find.byKey(const ValueKey('not-yet-playfield'));
    expect(playfield, findsOneWidget);
    expect(tester.getSize(playfield).height, greaterThan(560));
    expect(find.byType(GameStageProgressMenu), findsNothing);
  });

  testWidgets('False Habit keeps its full playfield without a stage menu', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EchoHeistPage()));

    final playfield = find.byKey(const ValueKey('false-habit-playfield'));
    expect(playfield, findsOneWidget);
    expect(tester.getSize(playfield).height, greaterThan(560));
    expect(find.byType(GameStageProgressMenu), findsNothing);
  });

  testWidgets('False Habit briefing remains usable on compact landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EchoHeistPage()));

    expect(find.text('ENTER THE ARCHIVE'), findsOneWidget);
    await tester.tap(find.text('ENTER THE ARCHIVE'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.textContaining('FALSE HABIT · ARCHIVE 24'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Future Debt fills the landscape game display', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FutureDebtPage()));

    final playfield = find.byKey(const ValueKey('future-debt-playfield'));
    expect(playfield, findsOneWidget);
    expect(tester.getSize(playfield).height, greaterThan(560));
    expect(find.byType(GameStageProgressMenu), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Future Debt briefing scrolls on compact landscape devices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: FutureDebtPage()));

    expect(find.text('ENTER THE LEDGER'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
