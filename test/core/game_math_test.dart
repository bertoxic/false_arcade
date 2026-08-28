import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/core/game_math.dart';

void main() {
  test('normalization is safe for zero vectors', () {
    expect(normalizedOr(Offset.zero), const Offset(1, 0));
    expect(normalizedOr(const Offset(3, 4)), const Offset(.6, .8));
  });

  test('rotation preserves magnitude', () {
    final result = rotated(const Offset(3, 0), math.pi / 2);
    expect(result.dx, closeTo(0, 1e-9));
    expect(result.dy, closeTo(3, 1e-9));
  });

  test('exponential damping is frame-rate independent', () {
    var atSixty = 100.0;
    for (var i = 0; i < 60; i++) {
      atSixty = damp(atSixty, .1, 1 / 60);
    }
    var atOneTwenty = 100.0;
    for (var i = 0; i < 120; i++) {
      atOneTwenty = damp(atOneTwenty, .1, 1 / 120);
    }

    expect(atSixty, closeTo(10, 1e-9));
    expect(atOneTwenty, closeTo(atSixty, 1e-9));
  });

  test('circle overlap includes touching boundaries', () {
    expect(circlesOverlap(Offset.zero, 5, const Offset(10, 0), 5), isTrue);
    expect(circlesOverlap(Offset.zero, 5, const Offset(10.1, 0), 5), isFalse);
  });
}
