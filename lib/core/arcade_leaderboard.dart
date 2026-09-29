import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single high score entry in the retro arcade Hall of Fame.
@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.initials,
    required this.score,
    required this.gameId,
    required this.level,
    required this.timestamp,
  });

  final String initials;
  final int score;
  final String gameId;
  final int level;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'initials': initials,
    'score': score,
    'gameId': gameId,
    'level': level,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    initials: (json['initials'] as String? ?? 'AAA').toUpperCase(),
    score: (json['score'] as num? ?? 0).toInt(),
    gameId: json['gameId'] as String? ?? 'unknown',
    level: (json['level'] as num? ?? 1).toInt(),
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      (json['timestamp'] as num? ?? 0).toInt(),
    ),
  );
}

/// Global Arcade Leaderboard and Hall of Fame persistence.
abstract final class ArcadeLeaderboard {
  static const _storageKey = 'false_arcade.leaderboard.scores_v2';
  static final ValueNotifier<Map<String, List<LeaderboardEntry>>> scoresNotifier =
      ValueNotifier({});

  static bool _loaded = false;

  /// Default arcade benchmark records so every game has a competitive target.
  static final Map<String, List<LeaderboardEntry>> _defaultScores = {
    'not_yet': [
      LeaderboardEntry(initials: 'VEX', score: 4850, gameId: 'not_yet', level: 8, timestamp: DateTime(2026, 1, 15)),
      LeaderboardEntry(initials: 'NEO', score: 3420, gameId: 'not_yet', level: 5, timestamp: DateTime(2026, 2, 10)),
      LeaderboardEntry(initials: 'ACE', score: 2180, gameId: 'not_yet', level: 3, timestamp: DateTime(2026, 2, 22)),
      LeaderboardEntry(initials: 'SAM', score: 1450, gameId: 'not_yet', level: 2, timestamp: DateTime(2026, 3, 5)),
      LeaderboardEntry(initials: 'BOT', score: 850, gameId: 'not_yet', level: 1, timestamp: DateTime(2026, 3, 12)),
    ],
    'edge_load': [
      LeaderboardEntry(initials: 'SLY', score: 5200, gameId: 'edge_load', level: 7, timestamp: DateTime(2026, 1, 18)),
      LeaderboardEntry(initials: 'FOX', score: 3890, gameId: 'edge_load', level: 5, timestamp: DateTime(2026, 2, 12)),
      LeaderboardEntry(initials: 'GHO', score: 2650, gameId: 'edge_load', level: 4, timestamp: DateTime(2026, 2, 25)),
      LeaderboardEntry(initials: 'LOK', score: 1800, gameId: 'edge_load', level: 2, timestamp: DateTime(2026, 3, 1)),
      LeaderboardEntry(initials: 'ROB', score: 950, gameId: 'edge_load', level: 1, timestamp: DateTime(2026, 3, 10)),
    ],
    'false_habit': [
      LeaderboardEntry(initials: 'CIP', score: 5600, gameId: 'false_habit', level: 8, timestamp: DateTime(2026, 1, 20)),
      LeaderboardEntry(initials: 'ECH', score: 4120, gameId: 'false_habit', level: 6, timestamp: DateTime(2026, 2, 14)),
      LeaderboardEntry(initials: 'NUL', score: 2900, gameId: 'false_habit', level: 4, timestamp: DateTime(2026, 2, 28)),
      LeaderboardEntry(initials: 'HEX', score: 1950, gameId: 'false_habit', level: 3, timestamp: DateTime(2026, 3, 4)),
      LeaderboardEntry(initials: 'ARK', score: 1100, gameId: 'false_habit', level: 1, timestamp: DateTime(2026, 3, 15)),
    ],
    'numberfall': [
      LeaderboardEntry(initials: 'NUM', score: 6200, gameId: 'numberfall', level: 9, timestamp: DateTime(2026, 1, 22)),
      LeaderboardEntry(initials: 'BIT', score: 4450, gameId: 'numberfall', level: 6, timestamp: DateTime(2026, 2, 18)),
      LeaderboardEntry(initials: 'SUM', score: 3100, gameId: 'numberfall', level: 4, timestamp: DateTime(2026, 3, 2)),
      LeaderboardEntry(initials: 'MOD', score: 2150, gameId: 'numberfall', level: 3, timestamp: DateTime(2026, 3, 8)),
      LeaderboardEntry(initials: 'DIG', score: 1250, gameId: 'numberfall', level: 1, timestamp: DateTime(2026, 3, 18)),
    ],
    'fall_due': [
      LeaderboardEntry(initials: 'GRA', score: 5900, gameId: 'fall_due', level: 8, timestamp: DateTime(2026, 1, 25)),
      LeaderboardEntry(initials: 'MAS', score: 4300, gameId: 'fall_due', level: 6, timestamp: DateTime(2026, 2, 16)),
      LeaderboardEntry(initials: 'ORB', score: 3050, gameId: 'fall_due', level: 4, timestamp: DateTime(2026, 3, 3)),
      LeaderboardEntry(initials: 'NEW', score: 2050, gameId: 'fall_due', level: 3, timestamp: DateTime(2026, 3, 9)),
      LeaderboardEntry(initials: 'DOW', score: 1180, gameId: 'fall_due', level: 1, timestamp: DateTime(2026, 3, 20)),
    ],
    'future_debt': [
      LeaderboardEntry(initials: 'CHR', score: 6500, gameId: 'future_debt', level: 9, timestamp: DateTime(2026, 1, 30)),
      LeaderboardEntry(initials: 'LMT', score: 4780, gameId: 'future_debt', level: 6, timestamp: DateTime(2026, 2, 20)),
      LeaderboardEntry(initials: 'LOA', score: 3300, gameId: 'future_debt', level: 4, timestamp: DateTime(2026, 3, 5)),
      LeaderboardEntry(initials: 'BNK', score: 2280, gameId: 'future_debt', level: 3, timestamp: DateTime(2026, 3, 11)),
      LeaderboardEntry(initials: 'DUE', score: 1320, gameId: 'future_debt', level: 1, timestamp: DateTime(2026, 3, 22)),
    ],
  };

  static Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final map = <String, List<LeaderboardEntry>>{};
        for (final entry in decoded.entries) {
          final list = (entry.value as List)
              .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList();
          list.sort((a, b) => b.score.compareTo(a.score));
          map[entry.key] = list;
        }
        scoresNotifier.value = map;
        _loaded = true;
        return;
      }
    } catch (_) {}

    // Fallback to initial seed scores
    scoresNotifier.value = Map.from(_defaultScores);
    _loaded = true;
  }

  static List<LeaderboardEntry> getScoresFor(String gameId) {
    if (!_loaded) load();
    return scoresNotifier.value[gameId] ?? _defaultScores[gameId] ?? [];
  }

  static bool isTopScore(String gameId, int score) {
    if (score <= 0) return false;
    final scores = getScoresFor(gameId);
    if (scores.length < 5) return true;
    return score > scores.last.score;
  }

  static Future<void> submitScore({
    required String gameId,
    required String initials,
    required int score,
    required int level,
  }) async {
    final entry = LeaderboardEntry(
      initials: (initials.trim().isEmpty ? 'YOU' : initials.trim()).toUpperCase(),
      score: score,
      gameId: gameId,
      level: level,
      timestamp: DateTime.now(),
    );

    final currentMap = Map<String, List<LeaderboardEntry>>.from(scoresNotifier.value);
    final list = List<LeaderboardEntry>.from(currentMap[gameId] ?? _defaultScores[gameId] ?? []);
    list.add(entry);
    list.sort((a, b) => b.score.compareTo(a.score));
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    currentMap[gameId] = list;
    scoresNotifier.value = currentMap;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = currentMap.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(_storageKey, jsonEncode(jsonMap));
    } catch (_) {}
  }
}
