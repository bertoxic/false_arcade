import 'package:fluga/games/future_debt/future_debt_game.dart';
import 'package:fluga/games/numberfall/numberfall_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    test('catch platform spans beneath digits, counts down 3s, blinks, and super-bounces', () {
      final game = NumberfallTestAccess.createGame();
      game.start();

      expect(game.bounceDashes.length, 1);
      final platform = game.bounceDashes.first;
      expect(platform.rect.width, greaterThan(600)); // spans across digits
      expect(platform.isArmed, isTrue);
      expect(platform.isVisible, isTrue);

      // Trigger landing on the catch platform
      platform.trigger();
      expect(platform.isArmed, isFalse);
      expect(platform.isFading, isTrue);
      expect(platform.remaining, 3.0);

      // Advance 1.0s (2.0s left, not blinking yet)
      platform.update(1.0);
      expect(platform.remaining, 2.0);
      expect(platform.isVisible, isTrue);

      // Advance another 0.8s (1.2s left, in blinking range <= 1.5s)
      platform.update(0.8);
      expect(platform.remaining, closeTo(1.2, 0.01));
      expect(platform.isAvailable, isTrue);

      // Advance until expiration
      platform.update(1.5);
      expect(platform.remaining, 0.0);
      expect(platform.isAvailable, isFalse);
      expect(platform.isVisible, isFalse);

      // Reset when back on numbers
      platform.reset();
      expect(platform.isArmed, isTrue);
      expect(platform.isAvailable, isTrue);
      expect(platform.isVisible, isTrue);
    });

    test('digits 1 and 7 have mid-level landing shelves and doorway clearances', () {
      final platforms1 = NumberfallTestAccess.platformsFor(111);
      final midPlatforms1 = platforms1.where((p) => (p.top - 246.5).abs() < 2).toList();
      final basePlatforms1 = platforms1.where((p) => (p.top - 361.0).abs() < 2).toList();
      expect(midPlatforms1.length, greaterThanOrEqualTo(3)); // mid-shelf on all 3 digits
      expect(basePlatforms1.length, greaterThanOrEqualTo(3)); // base pedestal on all 3 digits

      final platforms7 = NumberfallTestAccess.platformsFor(777);
      final midPlatforms7 = platforms7.where((p) => (p.top - 246.5).abs() < 2).toList();
      expect(midPlatforms7.length, greaterThanOrEqualTo(3)); // crossbar on all 3 digits
    });

    test('inter-digit spacing is widened for free vertical movement between numbers', () {
      expect(NumberfallTestAccess.digitGap, 64.0);
      expect(NumberfallTestAccess.digitGap, greaterThan(50.0));
    });

    test('actor can land on mid-shelf of digit 1 and crossbar of digit 7', () {
      final game = NumberfallTestAccess.createGame();
      game.start();

      // Find mid-platform on digit 1 or 7
      final platforms = List<Rect>.from(game.platforms as Iterable);
      final midPlatforms = platforms.where((p) => (p.top - 246.5).abs() < 2).toList();
      expect(midPlatforms, isNotEmpty);

      // Position player above a mid-platform and simulate falling
      final target = midPlatforms.first;
      game.player.x = target.center.dx - game.player.w / 2;
      game.player.y = target.top - game.player.h - 10;
      game.player.vy = 200.0;
      game.player.grounded = false;

      // Update simulation step
      game.update(0.06);

      // Player should have landed securely on the platform
      expect(game.player.grounded, isTrue);
      expect(game.player.vy, 0.0);
      expect((game.player.y + game.player.h - target.top).abs(), lessThan(1.0));
    });
  });

  testWidgets('Numberfall supports desktop controls and pause', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NumberfallPage()));
    await tester.tap(find.text('ENTER THE NUMBER'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);

    expect(find.text('RUN PAUSED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Future Debt rules', () {
    test('campaign runs use an extended survival window and score target', () {
      expect(FutureDebtRules.startingLifetimeForLevel(1), 90);
      expect(FutureDebtRules.startingLifetimeForLevel(21), 105);
      expect(FutureDebtRules.campaignTargetScore(650), 650);
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
    await tester.pumpWidget(const MaterialApp(home: FutureDebtPage()));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('1 — GHOST WAGE'));
    await tester.pump();

    await tester.tap(find.textContaining('BANKRUPT').first);
    await tester.pump();

    expect(find.textContaining('BANKRUPTCY FEE POSTED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
