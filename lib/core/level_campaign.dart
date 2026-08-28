import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every arcade title uses the same finite campaign length.
const gameCampaignLevelCount = 21;

typedef LevelCompleteCallback = void Function(LevelRunResult result);

@immutable
class GeneratedGameLevel {
  const GeneratedGameLevel({
    required this.gameId,
    required this.number,
    required this.seed,
    required this.difficulty,
    required this.enemyPressure,
    required this.rewardRate,
    required this.targetScore,
    required this.parSeconds,
    required this.mutator,
    required this.briefing,
  });

  final String gameId;
  final int number;
  final int seed;
  final double difficulty;
  final double enemyPressure;
  final double rewardRate;
  final int targetScore;
  final double parSeconds;
  final String mutator;
  final String briefing;
}

/// A deterministic campaign generator. The same game/level always produces
/// the same challenge, while each title receives its own sequence of seeds.
abstract final class GameLevelGenerator {
  static GeneratedGameLevel generate(String gameId, int levelNumber) {
    assert(levelNumber >= 1 && levelNumber <= gameCampaignLevelCount);
    final seed = _stableSeed(gameId, levelNumber);
    final random = math.Random(seed);
    final progress = (levelNumber - 1) / (gameCampaignLevelCount - 1);
    final curve = math.pow(progress, 1.34).toDouble();
    final variance = random.nextDouble() * .16 - .08;
    final difficulty = (1 + curve * 1.15 + variance).clamp(.9, 2.2).toDouble();
    final pressure = (1 + curve * .82 + random.nextDouble() * .12)
        .clamp(1, 1.95)
        .toDouble();
    final rewards = (1.18 - curve * .24 + random.nextDouble() * .08)
        .clamp(.82, 1.25)
        .toDouble();
    final targetScore = (650 + levelNumber * 310 + random.nextInt(220));
    final baseParSeconds = (50 - curve * 16 + random.nextInt(9)).toDouble();
    final parSeconds = gameId == 'future_debt'
        ? baseParSeconds + 42
        : baseParSeconds;
    final mutator = _mutators[(seed >>> 3) % _mutators.length];
    return GeneratedGameLevel(
      gameId: gameId,
      number: levelNumber,
      seed: seed,
      difficulty: difficulty,
      enemyPressure: pressure,
      rewardRate: rewards,
      targetScore: targetScore,
      parSeconds: parSeconds,
      mutator: mutator,
      briefing: 'Pattern ${seed.toRadixString(16).toUpperCase()} · $mutator',
    );
  }

  static int _stableSeed(String gameId, int levelNumber) {
    var hash = 0x45D9F3B;
    for (final unit in gameId.codeUnits) {
      hash = ((hash * 31) ^ unit) & 0x7fffffff;
    }
    return (hash ^ (levelNumber * 0x9E3779B9)) & 0x7fffffff;
  }

  static const _mutators = [
    'TIGHT WINDOWS',
    'SHIFTING ROUTES',
    'HIGH-VALUE RISK',
    'COMPOUND PRESSURE',
    'LEAN RECOVERY',
    'UNSTABLE SIGNAL',
    'DOUBLE-BACK LANES',
  ];
}

@immutable
class LevelRunResult {
  const LevelRunResult({
    required this.level,
    required this.score,
    required this.elapsedSeconds,
    this.completed = true,
  });

  final GeneratedGameLevel level;
  final int score;
  final double elapsedSeconds;
  final bool completed;

  int get stars {
    if (!completed) return 0;
    var result = 1;
    if (score >= level.targetScore) result++;
    if (elapsedSeconds <= level.parSeconds) result++;
    return result;
  }
}

@immutable
class GameLevelRecord {
  const GameLevelRecord({
    this.stars = 0,
    this.bestScore = 0,
    this.bestSeconds = double.infinity,
  });

  final int stars;
  final int bestScore;
  final double bestSeconds;

  GameLevelRecord merge(LevelRunResult result) => GameLevelRecord(
    stars: math.max(stars, result.stars),
    bestScore: math.max(bestScore, result.score),
    bestSeconds: math.min(bestSeconds, result.elapsedSeconds),
  );

  Map<String, Object> toJson() => {
    'stars': stars,
    'bestScore': bestScore,
    'bestSeconds': bestSeconds.isFinite ? bestSeconds : -1,
  };

  factory GameLevelRecord.fromJson(Map<String, dynamic> json) {
    final storedSeconds = (json['bestSeconds'] as num?)?.toDouble() ?? -1;
    return GameLevelRecord(
      stars: ((json['stars'] as num?) ?? 0).clamp(0, 3).toInt(),
      bestScore: ((json['bestScore'] as num?) ?? 0).toInt(),
      bestSeconds: storedSeconds > 0 ? storedSeconds : double.infinity,
    );
  }
}

class LevelCampaignProgress {
  LevelCampaignProgress._(this._records);

  factory LevelCampaignProgress.empty() => LevelCampaignProgress._({});

  factory LevelCampaignProgress.fromJson(Map<String, dynamic> json) {
    final records = <String, GameLevelRecord>{};
    for (final entry in json.entries) {
      if (entry.value is Map) {
        records[entry.key] = GameLevelRecord.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }
    return LevelCampaignProgress._(records);
  }

  final Map<String, GameLevelRecord> _records;

  String _key(String gameId, int level) => '$gameId:$level';

  GameLevelRecord recordFor(String gameId, int level) =>
      _records[_key(gameId, level)] ?? const GameLevelRecord();

  int starsFor(String gameId, int level) => recordFor(gameId, level).stars;

  int unlockedLevelFor(String gameId) {
    var unlocked = 1;
    while (unlocked < gameCampaignLevelCount &&
        starsFor(gameId, unlocked) > 0) {
      unlocked++;
    }
    return unlocked;
  }

  bool isUnlocked(String gameId, int level) =>
      level <= unlockedLevelFor(gameId);

  int get totalStars =>
      _records.values.fold(0, (sum, record) => sum + record.stars);

  void record(LevelRunResult result) {
    final key = _key(result.level.gameId, result.level.number);
    _records[key] = recordFor(
      result.level.gameId,
      result.level.number,
    ).merge(result);
  }

  Map<String, Object> toJson() => {
    for (final entry in _records.entries) entry.key: entry.value.toJson(),
  };
}

class LevelCampaignStore {
  static const _storageKey = 'false_arcade.level_campaign.v1';
  static const _tutorialStorageKey = 'false_arcade.game_tutorials.v1';

  Future<LevelCampaignProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return LevelCampaignProgress.empty();
    try {
      return LevelCampaignProgress.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on FormatException {
      return LevelCampaignProgress.empty();
    }
  }

  Future<void> save(LevelCampaignProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(progress.toJson()));
  }

  Future<bool> hasCompletedTutorial(String gameId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_tutorialStorageKey)?.contains(gameId) ??
        false;
  }

  Future<void> markTutorialCompleted(String gameId) async {
    final preferences = await SharedPreferences.getInstance();
    final tutorials = {
      ...?preferences.getStringList(_tutorialStorageKey),
      gameId,
    }.toList()..sort();
    await preferences.setStringList(_tutorialStorageKey, tutorials);
  }
}
