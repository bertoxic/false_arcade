import 'package:flutter/material.dart';

import '../core/arcade_achievements.dart';
import '../core/arcade_leaderboard.dart';
import '../core/game_feedback.dart';
import 'arcade_catalog.dart';

/// Modal view displaying the Hall of Fame Leaderboard and Trophies showcase.
class ArcadeHallOfFamePage extends StatefulWidget {
  const ArcadeHallOfFamePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ArcadeHallOfFamePage> createState() => _ArcadeHallOfFamePageState();
}

class _ArcadeHallOfFamePageState extends State<ArcadeHallOfFamePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  var _selectedGameId = 'not_yet';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          GameFeedback.selection();
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Back to cabinet',
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF8FEAFF)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARCADE RECORDS',
                              style: TextStyle(
                                color: Color(0xFF48F2C1),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'PressStart2P',
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'HALL OF FAME',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isCompact)
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: const Color(0xFF48F2C1),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: const Color(0xFF48F2C1),
                          unselectedLabelColor: const Color(0xFF7591A8),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                          tabs: const [
                            Tab(icon: Icon(Icons.leaderboard_rounded, size: 18), text: 'HALL OF FAME'),
                            Tab(icon: Icon(Icons.military_tech_rounded, size: 18), text: 'TROPHIES'),
                          ],
                        ),
                    ],
                  ),
                  if (isCompact) ...[
                    const SizedBox(height: 8),
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicatorColor: const Color(0xFF48F2C1),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: const Color(0xFF48F2C1),
                      unselectedLabelColor: const Color(0xFF7591A8),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                      tabs: const [
                        Tab(icon: Icon(Icons.leaderboard_rounded, size: 16), text: 'HALL OF FAME'),
                        Tab(icon: Icon(Icons.military_tech_rounded, size: 16), text: 'TROPHIES'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _LeaderboardTab(
                          selectedGameId: _selectedGameId,
                          onGameSelected: (id) => setState(() => _selectedGameId = id),
                        ),
                        const _TrophiesTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({
    required this.selectedGameId,
    required this.onGameSelected,
  });

  final String selectedGameId;
  final ValueChanged<String> onGameSelected;

  @override
  Widget build(BuildContext context) {
    final game = arcadeCatalog.firstWhere(
      (g) => g.id == selectedGameId,
      orElse: () => arcadeCatalog.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: arcadeCatalog.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final g = arcadeCatalog[i];
                    final isSel = g.id == selectedGameId;
                    return InkWell(
                      onTap: () {
                        GameFeedback.selection();
                        onGameSelected(g.id);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? g.colors.first.withValues(alpha: 0.18) : const Color(0xFF07111D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? g.colors.first : const Color(0xFF263C52),
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(g.icon, size: 14, color: isSel ? g.colors.first : const Color(0xFF7B95AA)),
                            const SizedBox(width: 6),
                            Text(
                              g.title,
                              style: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF8DA3B5),
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                fontFamily: 'PressStart2P',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildScoresTable(context, game, isCompact: true),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game selector sidebar
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: ListView.separated(
                itemCount: arcadeCatalog.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final g = arcadeCatalog[i];
                  final isSel = g.id == selectedGameId;
                  return InkWell(
                    onTap: () {
                      GameFeedback.selection();
                      onGameSelected(g.id);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? g.colors.first.withValues(alpha: 0.18) : const Color(0xFF07111D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSel ? g.colors.first : const Color(0xFF263C52),
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(g.icon, size: 16, color: isSel ? g.colors.first : const Color(0xFF7B95AA)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              g.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF8DA3B5),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                fontFamily: 'PressStart2P',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Scores table
            Expanded(
              child: _buildScoresTable(context, game, isCompact: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoresTable(BuildContext context, ArcadeGameDefinition game, {required bool isCompact}) {
    return ValueListenableBuilder<Map<String, List<LeaderboardEntry>>>(
      valueListenable: ArcadeLeaderboard.scoresNotifier,
      builder: (context, map, _) {
        final entries = ArcadeLeaderboard.getScoresFor(selectedGameId);
        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF07121F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: game.colors.first.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: game.colors.first.withValues(alpha: 0.12),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${game.title} // TOP SCORES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: game.colors.first,
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'PressStart2P',
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'RANK   INITIALS   STAGE   SCORE',
                      style: TextStyle(
                        color: Color(0xFF6B8499),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
              Divider(color: const Color(0xFF1E3245), height: isCompact ? 16 : 20),
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text(
                          'NO RECORDED SCORES YET.\nSET A RECORD!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6A859A), height: 1.5),
                        ),
                      )
                    : ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, rank) {
                          final entry = entries[rank];
                          final isTop3 = rank < 3;
                          final rankColor = rank == 0
                              ? const Color(0xFFFFD36A) // Gold
                              : rank == 1
                                  ? const Color(0xFFD6E2E8) // Silver
                                  : rank == 2
                                      ? const Color(0xFFFF9E68) // Bronze
                                      : const Color(0xFF6F899D);

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 10 : 14,
                              vertical: isCompact ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: isTop3
                                  ? rankColor.withValues(alpha: 0.08)
                                  : const Color(0xFF040A12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isTop3
                                    ? rankColor.withValues(alpha: 0.5)
                                    : const Color(0xFF18293B),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isCompact ? 28 : 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '#${rank + 1}',
                                    style: TextStyle(
                                      color: rankColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: isCompact ? 11 : 13,
                                      fontFamily: 'PressStart2P',
                                    ),
                                  ),
                                ),
                                SizedBox(width: isCompact ? 8 : 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1D2C),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    entry.initials,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: isCompact ? 10 : 12,
                                      letterSpacing: 2,
                                      fontFamily: 'PressStart2P',
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'LVL ${entry.level}',
                                  style: TextStyle(
                                    color: const Color(0xFF7A94A8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: isCompact ? 10 : 11,
                                  ),
                                ),
                                SizedBox(width: isCompact ? 12 : 24),
                                Text(
                                  entry.score.toString().padLeft(6, '0'),
                                  style: TextStyle(
                                    color: isTop3 ? rankColor : const Color(0xFFE2EEF8),
                                    fontWeight: FontWeight.w900,
                                    fontSize: isCompact ? 11 : 13,
                                    letterSpacing: 1.2,
                                    fontFamily: 'PressStart2P',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrophiesTab extends StatelessWidget {
  const _TrophiesTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ArcadeAchievements.unlockedNotifier,
      builder: (context, unlockedSet, _) {
        final total = ArcadeAchievements.totalCount;
        final unlocked = ArcadeAchievements.unlockedCount;
        final pct = (total == 0 ? 0 : (unlocked / total * 100)).toInt();

        return Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF07121F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF263C52)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD36A), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TROPHIES UNLOCKED: $unlocked / $total ($pct%)',
                              style: const TextStyle(
                                color: Color(0xFFE2EEF8),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              unlocked == total ? '★ 100% COMPLETE' : 'KEEP PLAYING',
                              style: const TextStyle(
                                color: Color(0xFF48F2C1),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : unlocked / total,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF0F1E2C),
                            color: const Color(0xFF48F2C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Trophies Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 340,
                  mainAxisExtent: 96,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: ArcadeAchievements.all.length,
                itemBuilder: (context, i) {
                  final ach = ArcadeAchievements.all[i];
                  final isUnl = unlockedSet.contains(ach.id);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnl ? const Color(0xFF081525) : const Color(0xFF040A12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUnl ? ach.color.withValues(alpha: 0.6) : const Color(0xFF182838),
                        width: isUnl ? 1.5 : 1.0,
                      ),
                      boxShadow: isUnl
                          ? [
                              BoxShadow(
                                color: ach.color.withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isUnl ? ach.color.withValues(alpha: 0.2) : const Color(0xFF0B141E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isUnl ? ach.color : const Color(0xFF283B4E),
                            ),
                          ),
                          child: Icon(
                            isUnl ? ach.icon : Icons.lock_outline_rounded,
                            color: isUnl ? ach.color : const Color(0xFF4F6980),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ach.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isUnl ? Colors.white : const Color(0xFF6F899D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  fontFamily: 'PressStart2P',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ach.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isUnl ? const Color(0xFFBACADB) : const Color(0xFF4C6477),
                                  fontSize: 10,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Retro Arcade Initials Entry Dialog for Top High Scores.
Future<void> showArcadeInitialsEntryDialog(
  BuildContext context, {
  required String gameId,
  required int score,
  required int level,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _InitialsDialog(gameId: gameId, score: score, level: level),
  );
}

class _InitialsDialog extends StatefulWidget {
  const _InitialsDialog({
    required this.gameId,
    required this.score,
    required this.level,
  });

  final String gameId;
  final int score;
  final int level;

  @override
  State<_InitialsDialog> createState() => _InitialsDialogState();
}

class _InitialsDialogState extends State<_InitialsDialog> {
  final _letters = ['A', 'A', 'A'];
  var _activeSlot = 0;
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#?';

  void _cycle(int slot, int dir) {
    GameFeedback.selection();
    setState(() {
      final currentIdx = _alphabet.indexOf(_letters[slot]);
      final nextIdx = (currentIdx + dir) % _alphabet.length;
      _letters[slot] = _alphabet[nextIdx < 0 ? _alphabet.length - 1 : nextIdx];
    });
  }

  Future<void> _submit() async {
    GameFeedback.victory();
    final initials = _letters.join();
    await ArcadeLeaderboard.submitScore(
      gameId: widget.gameId,
      initials: initials,
      score: widget.score,
      level: widget.level,
    );
    await ArcadeAchievements.unlock('hall_of_fame');
    if (widget.score >= 5000) {
      await ArcadeAchievements.unlock('arcade_centurion');
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF07121F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD36A), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FFD36A),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD36A), size: 36),
            const SizedBox(height: 8),
            const Text(
              'NEW HIGH SCORE!',
              style: TextStyle(
                color: Color(0xFFFFD36A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFamily: 'PressStart2P',
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'SCORE: ${widget.score}',
              style: const TextStyle(
                color: Color(0xFF48F2C1),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'PressStart2P',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ENTER YOUR INITIALS FOR THE HALL OF FAME',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF90A7B8), fontSize: 9, letterSpacing: 0.8),
            ),
            const SizedBox(height: 18),
            // 3-Slot Initials Wheels
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () => _cycle(i, 1),
                          icon: const Icon(Icons.arrow_drop_up_rounded, color: Color(0xFF48F2C1), size: 32),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _activeSlot = i),
                          child: Container(
                            width: 52,
                            height: 62,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF03080F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _activeSlot == i
                                    ? const Color(0xFF48F2C1)
                                    : const Color(0xFF263C52),
                                width: _activeSlot == i ? 2.5 : 1.2,
                              ),
                              boxShadow: _activeSlot == i
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x6648F2C1),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _letters[i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'PressStart2P',
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _cycle(i, -1),
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF48F2C1), size: 32),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD36A),
                  foregroundColor: const Color(0xFF03070E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'LOG TO HALL OF FAME',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
