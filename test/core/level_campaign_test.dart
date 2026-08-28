import 'package:fluga/core/level_campaign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated campaign levels are stable and distinct', () {
    final first = GameLevelGenerator.generate('future_debt', 1);
    final again = GameLevelGenerator.generate('future_debt', 1);
    final next = GameLevelGenerator.generate('future_debt', 2);

    expect(first.seed, again.seed);
    expect(first.mutator, again.mutator);
    expect(next.seed, isNot(first.seed));
    expect(gameCampaignLevelCount, 21);
  });

  test(
    'one star unlocks the next campaign level and persists best results',
    () {
      final progress = LevelCampaignProgress.empty();
      final level = GameLevelGenerator.generate('numberfall', 1);
      progress.record(
        LevelRunResult(
          level: level,
          score: level.targetScore,
          elapsedSeconds: level.parSeconds,
        ),
      );

      expect(progress.starsFor('numberfall', 1), 3);
      expect(progress.isUnlocked('numberfall', 2), isTrue);
      expect(progress.recordFor('numberfall', 1).bestScore, level.targetScore);
    },
  );
}
