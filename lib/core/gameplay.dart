import 'dart:math' as math;

/// Reusable countdown with explicit ready/active semantics.
class Cooldown {
  Cooldown([this.remaining = 0]);

  double remaining;

  bool get isReady => remaining <= 0;
  bool get isActive => remaining > 0;

  void tick(double dt) {
    if (remaining > 0) remaining = math.max(0, remaining - dt);
  }

  bool tryTrigger(double duration) {
    if (!isReady) return false;
    remaining = math.max(0, duration);
    return true;
  }

  void extendTo(double duration) {
    remaining = math.max(remaining, duration);
  }

  void clear() => remaining = 0;
}

/// A compact, configurable difficulty curve shared by independent games.
class DifficultyCurve {
  const DifficultyCurve({
    this.rampStages = 8,
    this.exponent = 1,
    this.endlessGrowth = .04,
  }) : assert(rampStages > 0),
       assert(exponent > 0),
       assert(endlessGrowth >= 0);

  final int rampStages;
  final double exponent;
  final double endlessGrowth;

  double progress(int stageIndex) {
    final base = (stageIndex / rampStages).clamp(0, 1);
    final eased = math.pow(base, exponent).toDouble();
    final overflow = math.max(0, stageIndex - rampStages);
    return eased + overflow * endlessGrowth;
  }

  double scale(int stageIndex, {double start = 1, double end = 2}) =>
      start + (end - start) * progress(stageIndex);

  double interval(
    int stageIndex, {
    required double start,
    required double minimum,
  }) => math.max(minimum, start / scale(stageIndex));
}

/// Score multiplier that rewards sustained mastery but decays predictably.
class ComboMeter {
  ComboMeter({this.maximum = 8, this.window = 2.5, this.step = .25});

  final double maximum;
  final double window;
  final double step;

  double multiplier = 1;
  double remaining = 0;

  bool get active => remaining > 0 && multiplier > 1;

  void reset() {
    multiplier = 1;
    remaining = 0;
  }

  void scoreEvent({double weight = 1}) {
    multiplier = math.min(maximum, multiplier + step * weight);
    remaining = window;
  }

  void tick(double dt) {
    remaining = math.max(0, remaining - dt);
    if (remaining == 0) multiplier = 1;
  }
}
