import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('campaign has a progressively tuned final mastery sector', () {
    expect(RealityGame.levels, hasLength(6));
    expect(RealityGame.levels.last.drumDrift, greaterThan(0));
    expect(
      RealityGame.levels.last.spawnInterval,
      lessThan(RealityGame.levels.first.spawnInterval),
    );
    expect(
      RealityGame.levels.last.maxOnField,
      greaterThan(RealityGame.levels.first.maxOnField),
    );
  });

  test('holding forever triggers a bounded margin call', () {
    final game = RealityGame(
      tuning: const RealityGameTuning(holdInterestPerSecond: 1200),
      random: math.Random(7),
    )..startRun();

    game.setHolding(true);
    game.step(.1, Offset.zero, false);

    expect(game.holding, isFalse);
    expect(game.debt, 0);
    expect(game.holdPressure, 0);
  });

  test('recorded run time excludes time spent on the briefing', () {
    final game = RealityGame(random: math.Random(11));

    game.step(8, Offset.zero, false);
    expect(game.elapsedSeconds, 0);

    game.startRun();
    game.step(.5, Offset.zero, false);
    expect(game.elapsedSeconds, closeTo(.5, 1e-9));
  });
}
