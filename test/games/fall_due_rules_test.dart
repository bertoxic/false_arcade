import 'package:fluga/games/fall_due/fall_due_game.dart';
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

  testWidgets('Fall Due starts, accepts held jump, and pauses cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FallDuePage()));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump();

    expect(find.text('JUMP'), findsOneWidget);
    expect(find.text('BORROW'), findsOneWidget);

    final jump = await tester.startGesture(tester.getCenter(find.text('JUMP')));
    await tester.pump(const Duration(milliseconds: 80));
    await jump.up();
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
