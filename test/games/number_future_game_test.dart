import 'package:fluga/games/future_debt/future_debt_game.dart';
import 'package:fluga/main.dart';
import 'package:fluga/games/numberfall/numberfall_game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'false_arcade.game_tutorials.v1': [
        'not_yet',
        'edge_load',
        'false_habit',
        'numberfall',
        'fall_due',
        'future_debt',
      ],
    }),
  );

  group('Numberfall display rules', () {
    test('uses one canonical final-three-digit representation', () {
      expect(numberfallDisplayDigits(14), [0, 1, 4]);
      expect(numberfallDisplayString(1007), '007');
      expect(numberfallDisplayString(-42), '042');
    });
  });

  group('Future Debt rules', () {
    test('campaign runs use an extended survival window and score target', () {
      expect(FutureDebtRules.startingLifetimeForLevel(1), 90);
      expect(FutureDebtRules.startingLifetimeForLevel(21), 105);
      expect(FutureDebtRules.campaignTargetScore(650), 1950);
    });

    test('interest increases only beyond the four-second base term', () {
      expect(FutureDebtRules.interestForDelay(3), 1);
      expect(FutureDebtRules.interestForDelay(4), 1);
      expect(FutureDebtRules.interestForDelay(8), closeTo(1.44, 1e-9));
    });

    test('spawn policy honors both quota and active-enemy cap', () {
      expect(
        FutureDebtRules.canSpawnEnemy(
          kills: 4,
          alive: 2,
          goal: 8,
          maximumAlive: 3,
        ),
        isTrue,
      );
      expect(
        FutureDebtRules.canSpawnEnemy(
          kills: 7,
          alive: 1,
          goal: 8,
          maximumAlive: 3,
        ),
        isFalse,
      );
      expect(
        FutureDebtRules.canSpawnEnemy(
          kills: 2,
          alive: 3,
          goal: 8,
          maximumAlive: 3,
        ),
        isFalse,
      );
    });

    test('dash direction is independent from auto-fire aim', () {
      expect(
        FutureDebtRules.dashVector(
          moveDirection: const Offset(0, 1),
          storedDirection: const Offset(-1, 0),
          fireDirection: const Offset(1, 0),
        ),
        const Offset(0, 1),
      );
      expect(
        FutureDebtRules.dashVector(
          moveDirection: Offset.zero,
          storedDirection: const Offset(-1, 0),
          fireDirection: const Offset(1, 0),
        ),
        const Offset(-1, 0),
      );
    });
  });

  testWidgets('Future Debt exposes a live bankruptcy encounter', (
    tester,
  ) async {
    await tester.pumpWidget(const NotYetApp());
    await tester.ensureVisible(find.text('FUTURE DEBT'));
    await tester.tap(find.text('FUTURE DEBT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('START RUN'));
    await tester.pump(const Duration(milliseconds: 100));

    final rush = await tester.startGesture(tester.getCenter(find.text('RUSH')));
    for (var frame = 0; frame < 14; frame++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    await rush.up();
    await tester.pump();

    expect(find.text('DEFAULT'), findsOneWidget);
    await tester.tap(find.text('DEFAULT'));
    await tester.pump();

    expect(find.textContaining('BANKRUPTCY:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
