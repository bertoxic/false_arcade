import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/core/arcade_hitstop.dart';
import 'package:fluga/core/game_loop.dart';

void main() {
  group('FixedStepClock', () {
    test('produces the same simulation time for different frame rates', () {
      double simulate(double frameSeconds, int frames) {
        final clock = FixedStepClock();
        var simulated = 0.0;
        for (var frame = 0; frame < frames; frame++) {
          clock.advance(frameSeconds, (dt) => simulated += dt);
        }
        return simulated;
      }

      expect(simulate(1 / 60, 60), closeTo(1, 1e-9));
      expect(simulate(1 / 120, 120), closeTo(1, 1e-9));
    });

    test('bounds catch-up work after a stalled frame', () {
      final clock = FixedStepClock(maxSubSteps: 4);
      var steps = 0;

      final executed = clock.advance(2, (_) => steps++);

      expect(executed, 4);
      expect(steps, 4);
      expect(clock.interpolationAlpha, lessThan(1));
    });

    test('ignores invalid and non-positive deltas', () {
      final clock = FixedStepClock();
      var steps = 0;

      clock.advance(double.nan, (_) => steps++);
      clock.advance(-1, (_) => steps++);

      expect(steps, 0);
    });

    test('ArcadeHitStop freeze pauses and cleanly resumes simulation without hanging', () {
      final clock = FixedStepClock();
      var steps = 0;

      // Normal step
      clock.advance(1 / 60, (_) => steps++);
      expect(steps, greaterThan(0));

      final initialSteps = steps;
      // Freeze for 0.04 seconds (approx 2.4 frames at 60fps)
      ArcadeHitstop.freeze(const Duration(milliseconds: 40));
      expect(ArcadeHitstop.isActive, isTrue);

      // Frame 1 during freeze: advance returns 0 and steps do not increment
      clock.advance(1 / 60, (_) => steps++);
      expect(steps, initialSteps);
      expect(ArcadeHitstop.isActive, isTrue);

      // Frame 2 during freeze: still frozen
      clock.advance(1 / 60, (_) => steps++);
      expect(steps, initialSteps);

      // Frame 3 finishes remaining freeze duration:
      clock.advance(1 / 60, (_) => steps++);
      expect(steps, initialSteps);
      expect(ArcadeHitstop.isActive, isFalse);

      // Frame 4 after freeze: simulation resumes and steps increment!
      clock.advance(1 / 60, (_) => steps++);
      expect(steps, greaterThan(initialSteps));
    });
  });
}
