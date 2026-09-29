import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_feedback.dart';

@immutable
class ArcadeAchievement {
  const ArcadeAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.secret = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool secret;
}

abstract final class ArcadeAchievements {
  static const _storageKey = 'false_arcade.achievements.unlocked_v2';

  static final List<ArcadeAchievement> all = [
    const ArcadeAchievement(
      id: 'first_contract',
      title: 'FIRST CONTRACT',
      description: 'Clear any campaign mission with 3 stars.',
      icon: Icons.star_rounded,
      color: Color(0xFFFFD36A),
    ),
    const ArcadeAchievement(
      id: 'debt_baron',
      title: 'DEBT BARON',
      description: 'Settle a stack of 4 or more deferred consequences in NOT YET.',
      icon: Icons.hourglass_top_rounded,
      color: Color(0xFFFF557D),
    ),
    const ArcadeAchievement(
      id: 'chain_reaction',
      title: 'VOLATILE REACTION',
      description: 'Detonate a volatile drum and trigger an explosive chain in NOT YET.',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF8A48),
    ),
    const ArcadeAchievement(
      id: 'phantom_heist',
      title: 'PHANTOM HEIST',
      description: 'Extract with the diamond in EDGELOAD with minimal alerts.',
      icon: Icons.diamond_rounded,
      color: Color(0xFF72D6FF),
    ),
    const ArcadeAchievement(
      id: 'max_capacity',
      title: 'MAX CAPACITY',
      description: 'Fill cargo space with valuable loot and survive extraction in EDGELOAD.',
      icon: Icons.all_inbox_rounded,
      color: Color(0xFFF7C948),
    ),
    const ArcadeAchievement(
      id: 'model_shatterer',
      title: 'FALSE REFLECTION',
      description: 'Fracture the Warden prediction model in FALSE HABIT.',
      icon: Icons.broken_image_rounded,
      color: Color(0xFFFF7B88),
    ),
    const ArcadeAchievement(
      id: 'echo_decoy',
      title: 'GHOST IN THE MACHINE',
      description: 'Deploy an Echo to redirect security and escape in FALSE HABIT.',
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFC29CFF),
    ),
    const ArcadeAchievement(
      id: 'digit_stomp',
      title: 'DIGIT STOMP',
      description: 'Stomp an enemy unit in NUMBERFALL.',
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFF55F2D7),
    ),
    const ArcadeAchievement(
      id: 'calculated_risk',
      title: 'CALCULATED RISK',
      description: 'Grab 3 risky arithmetic pickups without falling in NUMBERFALL.',
      icon: Icons.calculate_rounded,
      color: Color(0xFF2BAFEF),
    ),
    const ArcadeAchievement(
      id: 'gravity_hammer',
      title: 'SEISMIC SLAM',
      description: 'Pay back gravity debt through an impactful heavy landing in FALL DUE.',
      icon: Icons.south_rounded,
      color: Color(0xFF8DE1FF),
    ),
    const ArcadeAchievement(
      id: 'zero_sum',
      title: 'LEDGER BALANCE',
      description: 'Complete a ledger mission under par time in FALL DUE.',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFFFD86E),
    ),
    const ArcadeAchievement(
      id: 'default_survivor',
      title: 'COLLECTOR DEFEAT',
      description: 'Survive and conquer a bankruptcy encounter in FUTURE DEBT.',
      icon: Icons.gavel_rounded,
      color: Color(0xFFFF4F7F),
    ),
    const ArcadeAchievement(
      id: 'credit_limit',
      title: 'HIGH ROLLER',
      description: 'Perform under a heavy debt load with a high risk multiplier in FUTURE DEBT.',
      icon: Icons.credit_score_rounded,
      color: Color(0xFF4BE4FF),
    ),
    const ArcadeAchievement(
      id: 'combo_king',
      title: 'COMBO KING',
      description: 'Build a combo multiplier of 3.0x or higher in any arcade game.',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFD36A),
    ),
    const ArcadeAchievement(
      id: 'fever_overdrive',
      title: 'OVERDRIVE FEVER',
      description: 'Trigger Arcade Fever mode through rapid action mastery.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF48F2C1),
    ),
    const ArcadeAchievement(
      id: 'arcade_champion',
      title: 'SECTOR CHAMPION',
      description: 'Earn 15 stars across the campaign levels.',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFE66D),
    ),
    const ArcadeAchievement(
      id: 'hall_of_fame',
      title: 'ARCADE LEGEND',
      description: 'Submit a top-tier score to the Hall of Fame leaderboard.',
      icon: Icons.military_tech_rounded,
      color: Color(0xFF75DFFF),
    ),
    const ArcadeAchievement(
      id: 'arcade_centurion',
      title: 'CENTURION',
      description: 'Score 5,000 or more in a single game run.',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFE94D79),
    ),
  ];

  static final ValueNotifier<Set<String>> unlockedNotifier = ValueNotifier({});
  static final ValueNotifier<ArcadeAchievement?> latestUnlockNotifier =
      ValueNotifier(null);

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      unlockedNotifier.value = list.toSet();
      _loaded = true;
    } catch (_) {
      _loaded = true;
    }
  }

  static bool isUnlocked(String id) {
    if (!_loaded) load();
    return unlockedNotifier.value.contains(id);
  }

  static int get unlockedCount => unlockedNotifier.value.length;
  static int get totalCount => all.length;
  static double get completionRatio =>
      totalCount == 0 ? 0 : unlockedCount / totalCount;

  static Future<void> unlock(String id) async {
    if (!_loaded) await load();
    if (unlockedNotifier.value.contains(id)) return;

    final achievement = all.firstWhere(
      (a) => a.id == id,
      orElse: () => ArcadeAchievement(
        id: id,
        title: id.toUpperCase(),
        description: 'Secret achievement unlocked',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF48F2C1),
      ),
    );

    final updated = Set<String>.from(unlockedNotifier.value)..add(id);
    unlockedNotifier.value = updated;
    latestUnlockNotifier.value = achievement;

    GameFeedback.achievement();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, updated.toList());
    } catch (_) {}

    // Auto-dismiss toast banner after 3.5s
    Timer(const Duration(milliseconds: 3500), () {
      if (latestUnlockNotifier.value == achievement) {
        latestUnlockNotifier.value = null;
      }
    });
  }
}
