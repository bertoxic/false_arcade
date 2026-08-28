import 'package:flutter_test/flutter_test.dart';
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
  });
}
