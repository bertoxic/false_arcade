import 'dart:math' as math;
import 'dart:ui';

const double gameEpsilon = 1e-8;

Offset normalizedOr(Offset vector, {Offset fallback = const Offset(1, 0)}) {
  final lengthSquared = vector.dx * vector.dx + vector.dy * vector.dy;
  if (lengthSquared <= gameEpsilon) return fallback;
  return vector / math.sqrt(lengthSquared);
}

Offset rotated(Offset vector, double radians) {
  final cosine = math.cos(radians);
  final sine = math.sin(radians);
  return Offset(
    vector.dx * cosine - vector.dy * sine,
    vector.dx * sine + vector.dy * cosine,
  );
}

Offset cappedMagnitude(Offset vector, double maximum) {
  assert(maximum >= 0);
  final lengthSquared = vector.dx * vector.dx + vector.dy * vector.dy;
  if (lengthSquared <= maximum * maximum) return vector;
  return normalizedOr(vector, fallback: Offset.zero) * maximum;
}

/// Applies exponential, frame-rate-independent damping.
///
/// [retainedPerSecond] is the fraction remaining after one second. For
/// example, `0.1` retains ten percent of the original velocity after a second.
double damp(double value, double retainedPerSecond, double dt) {
  assert(retainedPerSecond >= 0 && retainedPerSecond <= 1);
  if (retainedPerSecond == 0) return 0;
  return value * math.pow(retainedPerSecond, math.max(0, dt)).toDouble();
}

Offset dampOffset(Offset value, double retainedPerSecond, double dt) =>
    value * math.pow(retainedPerSecond, math.max(0, dt)).toDouble();

double moveToward(double current, double target, double maxDelta) {
  if ((target - current).abs() <= maxDelta) return target;
  return current + (target - current).sign * maxDelta;
}

bool circlesOverlap(Offset a, double aRadius, Offset b, double bRadius) {
  final delta = a - b;
  final radius = aRadius + bRadius;
  return delta.dx * delta.dx + delta.dy * delta.dy <= radius * radius;
}

double inverseLerp(double min, double max, double value) {
  if ((max - min).abs() <= gameEpsilon) return 0;
  return ((value - min) / (max - min)).clamp(0, 1);
}

double smoothStep(double min, double max, double value) {
  final t = inverseLerp(min, max, value);
  return t * t * (3 - 2 * t);
}
