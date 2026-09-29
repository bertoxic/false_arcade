import 'package:fluga/games/fall_due/fall_due_game.dart';
import 'package:fluga/ui/game_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fall Due gravity tuning', () {
    test('borrow exhaustion is continuous and changes lift into payback', () {
      expect(FallDueTuning.borrowNetAcceleration(0), lessThan(0));
      expect(
        FallDueTuning.borrowNetAcceleration(FallDueTuning.maxDebt),
        greaterThan(0),
      );

      var previous = FallDueTuning.borrowNetAcceleration(60);
      for (var debt = 60.1; debt <= 100; debt += .1) {
        final next = FallDueTuning.borrowNetAcceleration(debt);
        expect(next, greaterThanOrEqualTo(previous - 1e-9));
        expect((next - previous).abs(), lessThan(8));
        previous = next;
      }
    });

    test('payback multiplier is bounded to the ledger capacity', () {
      expect(FallDueTuning.paybackGravityMultiplier(-20), 1);
      expect(FallDueTuning.paybackGravityMultiplier(100), closeTo(2.4, 1e-9));
      expect(FallDueTuning.paybackGravityMultiplier(500), closeTo(2.4, 1e-9));
    });
  });

  group('Fall Due run rules', () {
    test('exit requires both seals and gravity locks', () {
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 0, lockedGates: 0),
        isTrue,
      );
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 1, lockedGates: 0),
        isFalse,
      );
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 0, lockedGates: 1),
        isFalse,
      );
    });

    test('death converts carried debt and adds a capped ledger fee', () {
      expect(FallDueRules.paybackAfterDeath(carriedDebt: 40, payback: 10), 66);
      expect(
        FallDueRules.paybackAfterDeath(carriedDebt: 100, payback: 90),
        FallDueTuning.maxDebt,
      );
    });

    test('clean exit bonus counts carried and payable debt', () {
      expect(FallDueRules.cleanExitBonus(carriedDebt: 0, payback: 0), 1000);
      expect(FallDueRules.cleanExitBonus(carriedDebt: 60, payback: 20), 200);
      expect(FallDueRules.cleanExitBonus(carriedDebt: 80, payback: 80), 0);
    });
  });

  group('Fall Due procedural level generation', () {
    test('contract stages generate sprawling long routes over 5,000 pixels', () {
      final lengthRun1 = FallDueRules.generatedStageLength(6);
      final lengthRun2 = FallDueRules.generatedStageLength(7);
      expect(lengthRun1, greaterThan(5000));
      expect(lengthRun2, greaterThan(5000));
    });

    test('different contract runs produce unique layouts, titles, and sections', () {
      final titleRun1 = FallDueRules.generatedStageTitle(6);
      final titleRun2 = FallDueRules.generatedStageTitle(7);
      expect(titleRun1, isNotEmpty);
      expect(titleRun2, isNotEmpty);
      expect(titleRun1, isNot(equals(titleRun2)));

      final sections1 = FallDueRules.generatedStageSectionCount(6);
      final sections2 = FallDueRules.generatedStageSectionCount(7);
      expect(sections1, greaterThanOrEqualTo(3));
      expect(sections2, greaterThanOrEqualTo(3));
    });
  });

  group('Fall Due character powers tuning', () {
    test('kinetic slam and parry powers provide high-impact response', () {
      expect(FallDueTuning.slamSpeed, greaterThanOrEqualTo(800));
      expect(FallDueTuning.shockwaveRadius, lessThanOrEqualTo(100));
      expect(FallDueTuning.shockwaveRadius, greaterThanOrEqualTo(75));
      expect(FallDueTuning.dashImpulse, lessThanOrEqualTo(380));
      expect(FallDueTuning.dashImpulse, greaterThanOrEqualTo(300));
      expect(FallDueTuning.dashDebtCost, greaterThanOrEqualTo(20));
      expect(FallDueTuning.parryRange, greaterThanOrEqualTo(160));
      expect(FallDueTuning.parryBonusScore, greaterThanOrEqualTo(400));
    });

    test('slam descent velocity scales with borrow power and requires borrow', () {
      expect(FallDueRules.canInitiateSlam(0), isFalse);
      expect(FallDueRules.canInitiateSlam(5), isFalse);
      expect(FallDueRules.canInitiateSlam(8), isTrue);
      expect(FallDueRules.canInitiateSlam(50), isTrue);

      expect(FallDueRules.slamDescentSpeed(0), 640.0);
      expect(FallDueRules.slamDescentSpeed(50), 860.0);
      expect(FallDueRules.slamDescentSpeed(100), 1080.0);
      expect(
        FallDueRules.slamDescentSpeed(100),
        greaterThan(FallDueRules.slamDescentSpeed(20)),
      );
    });

    test('only highest borrow tier causes gravitational shockwaves', () {
      expect(FallDueRules.slamCausesShockwave(0), isFalse);
      expect(FallDueRules.slamCausesShockwave(34.9), isFalse);
      expect(FallDueRules.slamCausesShockwave(69.9), isFalse);
      expect(FallDueRules.slamCausesShockwave(70.0), isTrue);
      expect(FallDueRules.slamCausesShockwave(100.0), isTrue);
    });

    test('slam concussion pushes nearby enemies even if direct hit missed', () {
      expect(FallDueRules.slamConcussionRadius(0), 70.0);
      expect(FallDueRules.slamConcussionRadius(100), 90.0);
      expect(FallDueRules.slamConcussionPush(0), 70.0);
      expect(FallDueRules.slamConcussionPush(100), 100.0);
      expect(
        FallDueRules.slamConcussionPush(100),
        greaterThan(FallDueRules.slamConcussionPush(0)),
      );
    });
  });

  group('Fall Due unique enemies with powers', () {
    test('procedural generator spawns drones, heavy enforcers, and leechers', () {
      final kinds = FallDueRules.generatedStageTargetKinds(6);
      expect(kinds.contains('crate'), isTrue);
      expect(kinds.contains('enemy'), isTrue);
      expect(kinds.contains('drone'), isTrue);
      expect(kinds.contains('heavy'), isTrue);
      expect(kinds.contains('leecher'), isTrue);
    });

    test('drone GIVE shoves downward and TAKE blasts across screen', () {
      expect(FallDueRules.droneGiveDownwardSpeed(), 750.0);
      expect(FallDueRules.droneTakeBlastSpeed(), 920.0);
      expect(FallDueRules.droneTakeBlastSpeed(), greaterThan(500.0));
      expect(FallDueRules.droneTakeBlastSpeed(), lessThan(1000.0));
      expect(FallDueRules.enemyTakeBlastSpeed(), 920.0);
      expect(FallDueRules.enemyTakeBlastSpeed(), greaterThan(500.0));
      expect(FallDueRules.enemyTakeBlastSpeed(), lessThan(1000.0));
    });
  });

  testWidgets('Fall Due starts, accepts borrow, slam, and pauses cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FallDuePage()));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump();

    expect(find.byType(GameStageProgressMenu), findsNothing);
    expect(find.text('JUMP'), findsNothing);
    expect(find.text('BORROW'), findsOneWidget);
    expect(find.text('SLAM'), findsOneWidget);
    expect(find.text('GIVE'), findsOneWidget);
    expect(find.text('TAKE'), findsOneWidget);
    expect(find.text('CYCLE'), findsOneWidget);
    expect(find.text('HEARTS'), findsOneWidget);
    expect(find.text('SEALS'), findsOneWidget);
    expect(find.text('PAYBACK'), findsNothing);

    // Test tapping SLAM
    await tester.tap(find.text('SLAM'));
    await tester.pump(const Duration(milliseconds: 50));

    final borrow = await tester.startGesture(tester.getCenter(find.text('BORROW')));
    await tester.pump(const Duration(milliseconds: 80));
    await borrow.up();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
