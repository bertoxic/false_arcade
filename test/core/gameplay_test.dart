import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/core/gameplay.dart';

void main() {
  test('cooldown has explicit trigger and expiry semantics', () {
    final cooldown = Cooldown();
    expect(cooldown.tryTrigger(1), isTrue);
    expect(cooldown.tryTrigger(1), isFalse);
    cooldown.tick(.4);
    expect(cooldown.remaining, closeTo(.6, 1e-9));
    cooldown.tick(1);
    expect(cooldown.isReady, isTrue);
  });

  test('difficulty interval tightens without crossing its floor', () {
    const curve = DifficultyCurve(rampStages: 5, endlessGrowth: .1);
    expect(curve.interval(0, start: 4, minimum: 1), 4);
    expect(curve.interval(50, start: 4, minimum: 1), 1);
  });

  test('combo meter grows, caps, and expires', () {
    final combo = ComboMeter(maximum: 2, window: 1, step: .5);
    combo.scoreEvent();
    combo.scoreEvent();
    combo.scoreEvent();
    expect(combo.multiplier, 2);
    combo.tick(1);
    expect(combo.multiplier, 1);
  });
}
