import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every arcade title uses the same finite campaign length.
const gameCampaignLevelCount = 21;

typedef LevelCompleteCallback = void Function(LevelRunResult result);

/// Result returned by a campaign game page to its level-select host.
/// Keeping this separate from a level result makes persistence happen before
/// navigation, and avoids every game inventing a slightly different next-level
/// flow.
enum CampaignNavigation { nextLevel }

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
    required this.chapterTitle,
    required this.storyBeat,
    required this.objective,
    required this.gameplayFocus,
    required this.lengthMultiplier,
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

  /// Narrative and mechanical framing for a single, authored-feeling
  /// campaign mission. These are deliberately part of the level blueprint so
  /// every screen and simulation describes the same challenge.
  final String chapterTitle;
  final String storyBeat;
  final String objective;
  final String gameplayFocus;
  final double lengthMultiplier;
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
    final story = _storyFor(gameId, levelNumber);
    // Campaign missions should feel like missions, not 30-second score
    // sprints. Their score target and par window now budget time for a setup,
    // a complication, and an extraction/settlement beat.
    final targetScore = (780 + levelNumber * 365 + random.nextInt(260));
    final baseParSeconds = (76 - curve * 14 + random.nextInt(10)).toDouble();
    final parSeconds = gameId == 'future_debt'
        ? baseParSeconds + 58
        : baseParSeconds;
    final mutator = story.mutator;
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
      briefing: story.briefing,
      chapterTitle: story.title,
      storyBeat: story.storyBeat,
      objective: story.objective,
      gameplayFocus: story.gameplayFocus,
      lengthMultiplier: story.lengthMultiplier,
    );
  }

  static int _stableSeed(String gameId, int levelNumber) {
    var hash = 0x45D9F3B;
    for (final unit in gameId.codeUnits) {
      hash = ((hash * 31) ^ unit) & 0x7fffffff;
    }
    return (hash ^ (levelNumber * 0x9E3779B9)) & 0x7fffffff;
  }

  static _CampaignStory _storyFor(String gameId, int levelNumber) {
    final act = (levelNumber - 1) ~/ 7;
    final beat = (levelNumber - 1) % 7;
    final template = _stories[gameId] ?? _stories['not_yet']!;
    final mission = template.missions[beat];
    final actStory = template.acts[act];
    return _CampaignStory(
      title: 'ACT ${act + 1} · ${mission.title}',
      mutator: mission.mutator,
      briefing: '${actStory.location} — ${mission.briefing}',
      storyBeat: actStory.storyBeat,
      objective: mission.objective,
      gameplayFocus: mission.gameplayFocus,
      lengthMultiplier: 1.18 + act * .16 + beat * .025,
    );
  }

  static const _stories = <String, _CampaignStoryTemplate>{
    'not_yet': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'THE FIRST BREACH',
          'A debt fracture opens over the quiet district.',
        ),
        _CampaignAct(
          'COLLECTOR TERRITORY',
          'The fracture learns your release timing.',
        ),
        _CampaignAct(
          'THE LAST ACCOUNT',
          'Reality offers one final chance to settle the ledger.',
        ),
      ],
      missions: [
        _CampaignMission(
          'STATIC WAKE',
          'TIGHT WINDOWS',
          'Clear the first breach before it spreads.',
          'Short defer stacks and clean releases.',
        ),
        _CampaignMission(
          'DRUM LINE',
          'SHIFTING ROUTES',
          'Hold the center while drifting drums close lanes.',
          'Positioning before settlement.',
        ),
        _CampaignMission(
          'LATE PAYMENT',
          'LEAN RECOVERY',
          'Survive a thin-repair sector.',
          'Choosing which consequence to defer.',
        ),
        _CampaignMission(
          'RED RUSH',
          'COMPOUND PRESSURE',
          'Break a charger swarm without a margin call.',
          'Release timing under pursuit.',
        ),
        _CampaignMission(
          'SENTINEL RING',
          'DOUBLE-BACK LANES',
          'Punch through the outer sentry circuit.',
          'Using the arena edge as a recovery route.',
        ),
        _CampaignMission(
          'INTEREST STORM',
          'HIGH-VALUE RISK',
          'Turn a dangerous debt stack into a payout.',
          'Building a controlled high-debt chain.',
        ),
        _CampaignMission(
          'BREACH ANCHOR',
          'UNSTABLE SIGNAL',
          'Destroy the anchor feeding the next act.',
          'Combining movement, fire, and settlement.',
        ),
      ],
    ),
    'edge_load': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'THE SERVICE WING',
          'A patron wants proof the mansion can be robbed.',
        ),
        _CampaignAct(
          'THE PRIVATE FLOOR',
          'The family has hired guards who remember every route.',
        ),
        _CampaignAct(
          'THE CROWN VAULT',
          'One last diamond can buy the crew out of the city.',
        ),
      ],
      missions: [
        _CampaignMission(
          'SIDE DOOR',
          'QUIET ENTRY',
          'Lift the diamond and enough portable loot to escape.',
          'Learning the mansion loop.',
        ),
        _CampaignMission(
          'GALLERY SWITCH',
          'SHIFTING ROUTES',
          'Cross two patrol lanes without filling the cargo border.',
          'Route choice versus valuable loot.',
        ),
        _CampaignMission(
          'BELL TOWER',
          'NOISE WINDOW',
          'Use a coin to create one clean vault opening.',
          'Deliberate noise timing.',
        ),
        _CampaignMission(
          'MASKED DINNER',
          'LEAN RECOVERY',
          'Recover a disguise after a risky pickup.',
          'Resetting suspicion instead of outrunning it.',
        ),
        _CampaignMission(
          'MIRROR HALL',
          'DOUBLE-BACK LANES',
          'Double back through the mansion after the vault trips.',
          'Reading guard search patterns.',
        ),
        _CampaignMission(
          'BLACK LABEL',
          'HIGH-VALUE RISK',
          'Carry an optional premium haul to the exit.',
          'Choosing score against visibility.',
        ),
        _CampaignMission(
          'ROOFTOP EXIT',
          'COMPOUND PRESSURE',
          'Leave through the final extraction corridor.',
          'Sprint management under compression.',
        ),
      ],
    ),
    'false_habit': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'THE OBSERVATION BLOCK',
          'The Warden is still collecting a model of your habits.',
        ),
        _CampaignAct(
          'PREDICTION MARKET',
          'Your false routes are being sold back to the security grid.',
        ),
        _CampaignAct(
          "THE WARDEN'S CORE",
          'Break the machine that teaches every guard your move.',
        ),
      ],
      missions: [
        _CampaignMission(
          'FIRST TELL',
          'READABLE PATTERN',
          'Teach one believable route, then cut away from it.',
          'Building and breaking a prediction.',
        ),
        _CampaignMission(
          'COLD ECHO',
          'SHIFTING ROUTES',
          'Use an Echo to claim the far-side loot.',
          'Planning a replayed path.',
        ),
        _CampaignMission(
          'LOCKDOWN LOOP',
          'TIGHT WINDOWS',
          'Reach the exit during its short unlocked pulse.',
          'Timing a cash-out.',
        ),
        _CampaignMission(
          'FALSE TRAIL',
          'DOUBLE-BACK LANES',
          'Lead the Warden into a loop before the vault.',
          'Feints and reverse routes.',
        ),
        _CampaignMission(
          'BLACK DIAMOND',
          'HIGH-VALUE RISK',
          'Secure the black diamond before escaping.',
          'Taking the exposed premium objective.',
        ),
        _CampaignMission(
          'HARD COMMIT',
          'COMPOUND PRESSURE',
          'Outrun the Warden after its longest prediction.',
          'Breaking direction after commitment.',
        ),
        _CampaignMission(
          'MODEL BREAK',
          'UNSTABLE SIGNAL',
          'Bank the final haul and destroy the prediction model.',
          'Combining Echoes, loot, and extraction.',
        ),
      ],
    ),
    'numberfall': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'THE COUNTING ROOM',
          'The city display begins to count itself upward.',
        ),
        _CampaignAct(
          'CARRY THE ONE',
          'Every rewrite now steals a platform from another route.',
        ),
        _CampaignAct(
          'ZERO HOUR',
          'Stabilize the last number before the display erases the skyline.',
        ),
      ],
      missions: [
        _CampaignMission(
          'ONE MORE',
          'READABLE REWRITE',
          'Collect enough fragments to open the display exit.',
          'Reading a single safe rewrite.',
        ),
        _CampaignMission(
          'CARRY LANE',
          'SHIFTING ROUTES',
          'Use catch dashes after the lower segments vanish.',
          'Recovering from a missed platform.',
        ),
        _CampaignMission(
          'RED DIGIT',
          'TIGHT WINDOWS',
          'Cross a hostile segment before the next redraw.',
          'Stomping enemies into rewrites.',
        ),
        _CampaignMission(
          'BORROWED SEVEN',
          'DOUBLE-BACK LANES',
          'Choose between the high fragment and the safe digit.',
          'Optional route risk.',
        ),
        _CampaignMission(
          'FRACTURE COUNT',
          'COMPOUND PRESSURE',
          'Keep the display stable through repeated changes.',
          'Maintaining momentum across rewrites.',
        ),
        _CampaignMission(
          'MISSING ZERO',
          'LEAN RECOVERY',
          'Find the recovery dashes below the broken number.',
          'Using safety platforms intentionally.',
        ),
        _CampaignMission(
          'FINAL SUM',
          'UNSTABLE SIGNAL',
          'Finish the equation and reach its hidden exit.',
          'Combining platform reading and enemy pressure.',
        ),
      ],
    ),
    'fall_due': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'THE ENTRY LEDGER',
          'A debt clerk opens the first gravity contract.',
        ),
        _CampaignAct(
          'THE TRANSFER WORKS',
          'The routes only move when weight changes hands.',
        ),
        _CampaignAct(
          'SETTLEMENT TOWER',
          'Climb to the audit room before the account closes.',
        ),
      ],
      missions: [
        _CampaignMission(
          'FIRST FALL',
          'SAFE DEBT',
          'Collect the route seals and reach the ledger door.',
          'Borrowing air time then landing safely.',
        ),
        _CampaignMission(
          'COUNTERWEIGHT',
          'SHIFTING ROUTES',
          'Move the first crate into a useful route position.',
          'Giving gravity to build a bridge.',
        ),
        _CampaignMission(
          'RISING CLAIM',
          'VERTICAL ROUTE',
          'Take gravity from a crate to reach a raised lock.',
          'Using light crates as moving lifts.',
        ),
        _CampaignMission(
          'PAYBACK WALK',
          'TIGHT WINDOWS',
          'Cross the spike lane with a heavy landing due.',
          'Controlling payback and checkpoints.',
        ),
        _CampaignMission(
          'TRANSFER BRIDGE',
          'DOUBLE-BACK LANES',
          'Trade weight between crates to open the long route.',
          'Sequencing Give and Take.',
        ),
        _CampaignMission(
          'AUDIT GUNS',
          'COMPOUND PRESSURE',
          'Clear the emitter corridor without losing the seals.',
          'Routing under projectile pressure.',
        ),
        _CampaignMission(
          'CLOSING ENTRY',
          'UNSTABLE SIGNAL',
          'Settle the final annex and escape the floor.',
          'Combining all gravity verbs.',
        ),
      ],
    ),
    'future_debt': _CampaignStoryTemplate(
      acts: [
        _CampaignAct(
          'OPEN CREDIT',
          'The first ledger rooms still offer cheap shortcuts.',
        ),
        _CampaignAct(
          'MATURITY DISTRICT',
          'Every borrowed power now prints an enemy into the maze.',
        ),
        _CampaignAct(
          'DEFAULT COURT',
          'Earn the final score and leave before the Collector owns you.',
        ),
      ],
      missions: [
        _CampaignMission(
          'FIRST BILL',
          'LOW INTEREST',
          'Reach the score gate and locate the exit.',
          'Borrowing one power with a readable bill.',
        ),
        _CampaignMission(
          'GHOST CORRIDOR',
          'SHIFTING ROUTES',
          'Phase through a blocked room, then survive the echo.',
          'Ghost Wage movement routes.',
        ),
        _CampaignMission(
          'COMPOUND ROOM',
          'HIGH-VALUE RISK',
          'Use overcharge to clear an elite pocket.',
          'Trading firepower for later pressure.',
        ),
        _CampaignMission(
          'REVERSE CLAIM',
          'DOUBLE-BACK LANES',
          'Reflect audit fire through the return corridor.',
          'Turning hostile shots into damage.',
        ),
        _CampaignMission(
          'LATE FEE HUNT',
          'TIGHT WINDOWS',
          'Hit the score goal before the expiry clock closes.',
          'Fast target selection.',
        ),
        _CampaignMission(
          'COLLECTOR BAIT',
          'COMPOUND PRESSURE',
          'Carry debt long enough to control the Collector.',
          'Managing a dangerous ledger state.',
        ),
        _CampaignMission(
          'FINAL MATURITY',
          'UNSTABLE SIGNAL',
          'Open the last gate and transfer the ledger onward.',
          'Combining all borrowed powers.',
        ),
      ],
    ),
  };
}

@immutable
class _CampaignStoryTemplate {
  const _CampaignStoryTemplate({required this.acts, required this.missions});
  final List<_CampaignAct> acts;
  final List<_CampaignMission> missions;
}

@immutable
class _CampaignAct {
  const _CampaignAct(this.location, this.storyBeat);
  final String location;
  final String storyBeat;
}

@immutable
class _CampaignMission {
  const _CampaignMission(
    this.title,
    this.mutator,
    this.objective,
    this.gameplayFocus,
  );
  final String title;
  final String mutator;
  final String objective;
  final String gameplayFocus;

  String get briefing => objective;
}

@immutable
class _CampaignStory {
  const _CampaignStory({
    required this.title,
    required this.mutator,
    required this.briefing,
    required this.storyBeat,
    required this.objective,
    required this.gameplayFocus,
    required this.lengthMultiplier,
  });
  final String title;
  final String mutator;
  final String briefing;
  final String storyBeat;
  final String objective;
  final String gameplayFocus;
  final double lengthMultiplier;
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
