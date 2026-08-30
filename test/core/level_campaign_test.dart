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
    expect(first.chapterTitle, again.chapterTitle);
    expect(first.objective, isNotEmpty);
    expect(first.gameplayFocus, isNotEmpty);
  });

  test('every game has a three-act campaign with mission-length levels', () {
    const gameIds = [
      'not_yet',
      'edge_load',
      'false_habit',
      'numberfall',
      'fall_due',
      'future_debt',
    ];

    for (final gameId in gameIds) {
      final opening = GameLevelGenerator.generate(gameId, 1);
      final middle = GameLevelGenerator.generate(gameId, 8);
      final finale = GameLevelGenerator.generate(gameId, 15);

      expect(opening.chapterTitle, startsWith('ACT 1'));
      expect(middle.chapterTitle, startsWith('ACT 2'));
      expect(finale.chapterTitle, startsWith('ACT 3'));
      expect(opening.parSeconds, greaterThanOrEqualTo(70));
      expect(finale.lengthMultiplier, greaterThan(opening.lengthMultiplier));
    }
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
