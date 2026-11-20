import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Systemic mutator that modifies the rules of an arcade run.
@immutable
class DailyMutator {
  const DailyMutator({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;

  static const hyperInflation = DailyMutator(
    id: 'hyper_inflation',
    name: 'HYPER-INFLATION',
    tagline: '2x Debt Multiplier · 50% Settle Window',
    description: 'Debts compound at double speed, but settle rewards are doubled.',
  );

  static const blackout = DailyMutator(
    id: 'blackout',
    name: 'BLACKOUT CONDUIT',
    tagline: 'Dense Fog · +100% Extraction Haul',
    description: 'Vision cones are shortened, but loot values are supercharged.',
  );

  static const overclock = DailyMutator(
    id: 'overclock',
    name: 'NEURAL OVERCLOCK',
    tagline: 'Warden Learns 2x Faster · Echoes Expire Quick',
    description: 'Prediction models adapt rapidly, requiring instant deceptions.',
  );

  static const glitchedSegments = DailyMutator(
    id: 'glitched_segments',
    name: 'GLITCHED SEGMENTS',
    tagline: 'Platforms Rewrite Every 4s',
    description: 'Display digits mutate on an aggressive countdown.',
  );

  static const lunarLedger = DailyMutator(
    id: 'lunar_ledger',
    name: 'LUNAR LEDGER',
    tagline: 'Low Gravity · Double Payback Requirement',
    description: 'Extreme airtime, but impact landing requires absolute precision.',
  );

  static const shortTermLoan = DailyMutator(
    id: 'short_term_loan',
    name: 'SHORT-TERM LOAN',
    tagline: 'Half Ability Cooldowns · Rapid Overdraft',
    description: 'Fire abilities at hyper-speed, but lockouts hit immediately.',
  );

  static const glassCannon = DailyMutator(
    id: 'glass_cannon',
    name: 'GLASS PROTOCOL',
    tagline: '1-Hit Failure · 3x Score Rate',
    description: 'Absolute zero margin for error with maximum leaderboard reward.',
  );

  static const all = [
    hyperInflation,
    blackout,
    overclock,
    glitchedSegments,
    lunarLedger,
    shortTermLoan,
    glassCannon,
  ];
}

/// A specific deterministic daily challenge contract.
@immutable
class DailyShiftContract {
  const DailyShiftContract({
    required this.dateKey,
    required this.gameId,
    required this.seed,
    required this.challengeCode,
    required this.mutators,
    required this.targetScore,
    required this.parSeconds,
  });

  final String dateKey; // YYYY-MM-DD
  final String gameId;
  final int seed;
  final String challengeCode;
  final List<DailyMutator> mutators;
  final int targetScore;
  final double parSeconds;
}

/// Non-punitive streak tracking state.
@immutable
class DailyStreakLedger {
  const DailyStreakLedger({
    required this.currentStreak,
    required this.bestStreak,
    required this.shieldTokens,
    required this.lastCompletedDateKey,
    required this.totalClears,
  });

  final int currentStreak;
  final int bestStreak;
  final int shieldTokens;
  final String? lastCompletedDateKey;
  final int totalClears;

  factory DailyStreakLedger.initial() => const DailyStreakLedger(
        currentStreak: 0,
        bestStreak: 0,
        shieldTokens: 1, // Start with 1 complimentary shield token
        lastCompletedDateKey: null,
        totalClears: 0,
      );

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'shieldTokens': shieldTokens,
        'lastCompletedDateKey': lastCompletedDateKey,
        'totalClears': totalClears,
      };

  factory DailyStreakLedger.fromJson(Map<String, dynamic> json) =>
      DailyStreakLedger(
        currentStreak: (json['currentStreak'] as num? ?? 0).toInt(),
        bestStreak: (json['bestStreak'] as num? ?? 0).toInt(),
        shieldTokens: (json['shieldTokens'] as num? ?? 1).toInt(),
        lastCompletedDateKey: json['lastCompletedDateKey'] as String?,
        totalClears: (json['totalClears'] as num? ?? 0).toInt(),
      );

  bool isCompletedOn(String dateKey) => lastCompletedDateKey == dateKey;
}

/// Manages universal daily shifts, seeded contracts, and streak ledger.
abstract final class DailyShiftManager {
  static const _storageKey = 'false_arcade.daily_shift.ledger_v1';
  static const List<String> _gameCatalog = [
    'not_yet',
    'edge_load',
    'false_habit',
    'numberfall',
    'fall_due',
    'future_debt',
  ];

  static final ValueNotifier<DailyStreakLedger> streakNotifier =
      ValueNotifier<DailyStreakLedger>(DailyStreakLedger.initial());

  static bool _loaded = false;

  /// Loads streak ledger from persistent storage.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        streakNotifier.value = DailyStreakLedger.fromJson(data);
      }
      _checkDayRollover();
      _loaded = true;
    } catch (_) {}
  }

  /// Calculates the UTC date key: e.g. "2026-10-02".
  static String getDateKey([DateTime? time]) {
    final utc = (time ?? DateTime.now()).toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Generates the deterministic contract for the given UTC date.
  static DailyShiftContract getContract([DateTime? time]) {
    final utc = (time ?? DateTime.now()).toUtc();
    final dateKey = getDateKey(utc);
    final dayInt = utc.year * 10000 + utc.month * 100 + utc.day;

    final random = math.Random(dayInt);
    final gameIndex = dayInt % _gameCatalog.length;
    final gameId = _gameCatalog[gameIndex];

    // Pick 2 distinct mutators
    final m1Index = random.nextInt(DailyMutator.all.length);
    var m2Index = (m1Index + 1 + random.nextInt(DailyMutator.all.length - 1)) %
        DailyMutator.all.length;
    final mutators = [
      DailyMutator.all[m1Index],
      DailyMutator.all[m2Index],
    ];

    // Human-friendly challenge code
    final seed = (dayInt * 1103515245 + 12345) & 0x7FFFFFFF;
    final codeSuffix = seed.toRadixString(36).toUpperCase().padLeft(4, '0');
    final challengeCode = 'HEX-$codeSuffix-${gameId.substring(0, math.min(3, gameId.length)).toUpperCase()}';

    final targetScore = 2400 + random.nextInt(1800);
    final parSeconds = 60.0 + random.nextInt(35);

    return DailyShiftContract(
      dateKey: dateKey,
      gameId: gameId,
      seed: seed,
      challengeCode: challengeCode,
      mutators: mutators,
      targetScore: targetScore,
      parSeconds: parSeconds,
    );
  }

  /// Records a successful daily completion.
  static Future<void> recordCompletion(String dateKey) async {
    final current = streakNotifier.value;
    if (current.lastCompletedDateKey == dateKey) return; // already recorded

    final nextStreak = current.currentStreak + 1;
    final nextBest = math.max(nextStreak, current.bestStreak);
    // Award a shield token every 5-day streak milestone!
    final bonusShield = (nextStreak % 5 == 0) ? 1 : 0;

    final next = DailyStreakLedger(
      currentStreak: nextStreak,
      bestStreak: nextBest,
      shieldTokens: current.shieldTokens + bonusShield,
      lastCompletedDateKey: dateKey,
      totalClears: current.totalClears + 1,
    );

    streakNotifier.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(next.toJson()));
    } catch (_) {}
  }

  static void _checkDayRollover() {
    final today = getDateKey();
    final ledger = streakNotifier.value;
    if (ledger.lastCompletedDateKey == null) return;
    if (ledger.lastCompletedDateKey == today) return;

    try {
      final lastDate = DateTime.parse(ledger.lastCompletedDateKey!);
      final todayDate = DateTime.parse(today);
      final daysDiff = todayDate.difference(lastDate).inDays;

      if (daysDiff > 1) {
        // Player missed at least one calendar day
        if (daysDiff == 2 && ledger.shieldTokens > 0) {
          // Exactly 1 missed day absorbed by shield token!
          final preserved = DailyStreakLedger(
            currentStreak: ledger.currentStreak,
            bestStreak: ledger.bestStreak,
            shieldTokens: ledger.shieldTokens - 1,
            lastCompletedDateKey: ledger.lastCompletedDateKey,
            totalClears: ledger.totalClears,
          );
          streakNotifier.value = preserved;
        } else {
          // Missed multiple days or no shields: reset streak
          final resetLedger = DailyStreakLedger(
            currentStreak: 0,
            bestStreak: ledger.bestStreak,
            shieldTokens: ledger.shieldTokens,
            lastCompletedDateKey: ledger.lastCompletedDateKey,
            totalClears: ledger.totalClears,
          );
          streakNotifier.value = resetLedger;
        }
      }
    } catch (_) {}
  }
}
