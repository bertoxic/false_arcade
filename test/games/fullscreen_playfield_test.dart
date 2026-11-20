import 'package:fluga/games/false_habit/echo_heist_game.dart';
import 'package:fluga/games/fall_due/fall_due_game.dart';
import 'package:fluga/games/future_debt/future_debt_game.dart';
import 'package:fluga/games/not_yet/not_yet_game.dart';
import 'package:fluga/ui/game_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final screen in const [Size(568, 320), Size(390, 844), Size(960, 540)]) {
    testWidgets('Fall Due fits the Borrow controls at $screen', (tester) async {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: FallDuePage()));
      await tester.ensureVisible(find.text('ENTER THE LEDGER'));
      await tester.tap(find.text('ENTER THE LEDGER'));
      await tester.pump();

      Rect area(String label, Type control) => tester.getRect(
        find.ancestor(of: find.text(label), matching: find.byType(control)),
      );
      final borrow = area('BORROW', HoldGameButton);
      final slam = area('SLAM', HoldGameButton);
      final give = area('GIVE', InkWell);
      final take = area('TAKE', InkWell);
      final movement = [
        area('LEFT', HoldGameButton),
        area('RIGHT', HoldGameButton),
      ];
      expect(borrow.width, greaterThanOrEqualTo(78));
      expect(give.bottom, lessThan(borrow.top));
      expect(take.bottom, lessThan(borrow.top));
      expect(slam.right, lessThan(borrow.left));
      final controls = [...movement, borrow, slam, give, take];
      for (var i = 0; i < controls.length; i++) {
        expect(controls[i].shortestSide, greaterThanOrEqualTo(52));
        for (var j = i + 1; j < controls.length; j++) {
          expect(controls[i].overlaps(controls[j]), isFalse);
        }
      }
      expect(find.text('CYCLE'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

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

  test('Future Debt maps the arena to the whole screen at a uniform scale', () {
    expect(
      FutureDebtRules.arenaView(const Size(960, 540)),
      const Size(960, 540),
    );
    expect(
      FutureDebtRules.arenaView(const Size(800, 360)),
      const Size(1200, 540),
    );
    expect(
      FutureDebtRules.arenaView(const Size(800, 600)),
      const Size(720, 540),
    );
    const portrait = Size(390, 844);
    final world = FutureDebtRules.arenaView(portrait);
    expect(world.aspectRatio, closeTo(portrait.aspectRatio, 1e-9));
  });

  for (final screen in const [Size(568, 320), Size(390, 844), Size(960, 540)]) {
    testWidgets('Future Debt fits the combat controls at $screen', (
      tester,
    ) async {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: FutureDebtPage()));
      await tester.tap(find.text('ENTER THE LEDGER'));
      await tester.pump();

      final movement = tester.getRect(find.byType(TouchStick));
      final aim = tester.getRect(find.byType(AimGameButton));
      final dash = tester.getRect(find.widgetWithText(TapGameButton, 'DASH'));
      final ghost = tester.getRect(find.byTooltip('Ghost Wage'));
      final reverse = tester.getRect(find.byTooltip('Reverse Payment'));
      expect(
        tester.getSize(find.byKey(const ValueKey('future-debt-playfield'))),
        screen,
      );
      expect(movement.width, greaterThanOrEqualTo(98));
      expect(aim.width, closeTo(movement.width, 1e-6));
      expect(dash.height, inInclusiveRange(48, 64));
      expect(ghost.height, greaterThanOrEqualTo(48));
      expect(reverse.height, greaterThanOrEqualTo(48));
      expect(ghost.bottom, lessThan(aim.top));
      expect(reverse.bottom, lessThan(aim.top));
      for (final label in ['3s', '6s', '10s', '15s', 'MATURITY']) {
        expect(find.text(label), findsNothing);
      }
      final controls = [movement, aim, dash, ghost, reverse];
      for (var i = 0; i < controls.length; i++) {
        for (var j = i + 1; j < controls.length; j++) {
          expect(controls[i].overlaps(controls[j]), isFalse);
        }
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
