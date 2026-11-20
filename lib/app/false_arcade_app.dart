import 'package:flutter/material.dart';

import 'arcade_catalog.dart';
import 'arcade_game_art.dart';
import 'arcade_hall_of_fame_page.dart';
import 'game_level_select_page.dart';
import '../core/arcade_achievements.dart';
import '../core/arcade_ads.dart';
import '../core/arcade_daily_shift.dart';
import '../core/arcade_leaderboard.dart';
import '../core/game_feedback.dart';
import '../core/level_campaign.dart';
import '../ui/arcade_screen_filter.dart';
import '../ui/game_controls.dart';
import '../ui/screen_shake.dart';


class FalseArcadeApp extends StatefulWidget {
  const FalseArcadeApp({super.key});

  @override
  State<FalseArcadeApp> createState() => _FalseArcadeAppState();
}

class _FalseArcadeAppState extends State<FalseArcadeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      GameFeedback.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      GameFeedback.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'False Arcade',
      builder: (context, child) =>
          ArcadeScreenFilter(child: child ?? const SizedBox.shrink()),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFF02060B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF48F2C1),
          secondary: Color(0xFF75DFFF),
          surface: Color(0xFF0A111B),
        ),
        splashColor: const Color(0xFF48F2C1).withValues(alpha: .12),
        highlightColor: Colors.transparent,
      ),
      home: const ArcadeHomePage(),
    );
  }
}

/// A game-cabinet selection screen, rather than a web-style list of links.
class ArcadeHomePage extends StatefulWidget {
  const ArcadeHomePage({super.key});

  @override
  State<ArcadeHomePage> createState() => _ArcadeHomePageState();
}

class _ArcadeHomePageState extends State<ArcadeHomePage> {
  late int _selectedIndex;

  ArcadeGameDefinition get _selected => arcadeCatalog[_selectedIndex];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final day = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(1970))
        .inDays;
    _selectedIndex = day % arcadeCatalog.length;
    ArcadeFlash.reset();
    GameFeedback.playMusic('arcade_theme');
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    GameFeedback.selection();
    setState(() => _selectedIndex = index);
  }

  Future<void> _launch(ArcadeGameDefinition game) async {
    GameFeedback.selection();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameLevelSelectPage(game: game)),
    );
    ArcadeFlash.reset();
    GameFeedback.playMusic('arcade_theme');
  }

  void _openHallOfFame([int tab = 0]) {
    GameFeedback.selection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArcadeHallOfFamePage(initialTab: tab),
      ),
    );
  }


  void _cycle(int direction) {
    GameFeedback.selection();
    final next = (_selectedIndex + direction) % arcadeCatalog.length;
    setState(() => _selectedIndex = next < 0 ? arcadeCatalog.length - 1 : next);
  }

  Future<void> _launchDailyContract(DailyShiftContract contract) async {
    GameFeedback.selection();
    final gameDef = arcadeCatalog.firstWhere(
      (g) => g.id == contract.gameId,
      orElse: () => arcadeCatalog.first,
    );
    final level = GeneratedGameLevel(
      gameId: contract.gameId,
      number: 1,
      seed: contract.seed,
      difficulty: 1.35,
      enemyPressure: 1.35,
      rewardRate: 1.15,
      targetScore: contract.targetScore,
      parSeconds: contract.parSeconds,
      mutator: contract.mutators.map((m) => m.name).join(' + '),
      briefing: 'DAILY CONTRACT: ${contract.mutators.first.description}',
      chapterTitle: 'DAILY SHIFT // ${contract.dateKey}',
      storyBeat:
          'Universal seeded daily shift. Complete to extend streak and earn shields.',
      objective: 'SURVIVE AND SETTLE',
      gameplayFocus:
          'Active Mutators: ${contract.mutators.map((m) => m.name).join(' · ')}',
      lengthMultiplier: 1.0,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => gameDef.levelPageBuilder(
          level,
          (result) {
            DailyShiftManager.recordCompletion(contract.dateKey);
            ArcadeLeaderboard.submitScore(
              gameId: contract.gameId,
              initials: 'PLY',
              score: result.score,
              level: 1,
            );
          },
          () => Navigator.of(context).pop(),
        ),
      ),
    );
    ArcadeFlash.reset();
    GameFeedback.playMusic('arcade_theme');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.92),
          radius: 1.2,
          colors: [Color(0xFF0C2430), Color(0xFF040912), Color(0xFF010308)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: ArcadeGridField()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                final horizontalPadding = constraints.maxWidth >= 700
                    ? 28.0
                    : 16.0;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ArcadeHeader(
                          active: _selectedIndex + 1,
                          total: arcadeCatalog.length,
                          onHallOfFame: () => _openHallOfFame(0),
                          onTrophies: () => _openHallOfFame(1),
                          onFeedbackSettings: () =>
                              showGameFeedbackSettings(context),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _DailyShiftBanner(
                          onPlay: () => _launchDailyContract(
                            DailyShiftManager.getContract(),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _FeaturedGamePanel(
                          game: _selected,
                          index: _selectedIndex,
                          total: arcadeCatalog.length,
                          compact: constraints.maxWidth < 540,
                          onPlay: () => _launch(_selected),
                          onPrevious: () => _cycle(-1),
                          onNext: () => _cycle(1),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        10,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'CHOOSE A SIGNAL',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF90A7B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(
                                  0xFF385260,
                                ).withValues(alpha: .65),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TAP TO PLAY',
                              style: TextStyle(
                                color: Color(0xFF48F2C1),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: crossAxisCount == 1 ? 154 : 166,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _GameCartridge(
                            game: arcadeCatalog[index],
                            index: index,
                            selected: index == _selectedIndex,
                            onHover: () => _select(index),
                            onPlay: () {
                              _select(index);
                              _launch(arcadeCatalog[index]);
                            },
                          ),
                          childCount: arcadeCatalog.length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: ArcadeNativeAdCard(),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        18,
                      ),
                      sliver: const SliverToBoxAdapter(child: _ArcadeFooter()),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ArcadeHeader extends StatelessWidget {
  const _ArcadeHeader({
    required this.active,
    required this.total,
    required this.onHallOfFame,
    required this.onTrophies,
    required this.onFeedbackSettings,
  });

  final int active;
  final int total;
  final VoidCallback onHallOfFame;
  final VoidCallback onTrophies;
  final VoidCallback onFeedbackSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final isUltraCompact = constraints.maxWidth < 360;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF48F2C1),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF48F2C1).withValues(alpha: .35),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.videogame_asset_rounded,
                      color: Color(0xFF031016),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FALSE ARCADE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFF0FAFF),
                            fontSize: isUltraCompact ? 13 : 15,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'PressStart2P',
                            letterSpacing: isUltraCompact ? 1.0 : 1.5,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF48F2C1),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isUltraCompact
                              ? 'SYSTEM SELECT'
                              : 'SYSTEM SELECT // SIX IMPOSSIBLE GAMES',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF89A3B5),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onHallOfFame,
                    tooltip: 'Hall of Fame (High Scores)',
                    icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD36A), size: 19),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onTrophies,
                    tooltip: 'Trophies & Achievements',
                    icon: const Icon(Icons.military_tech_rounded, color: Color(0xFF48F2C1), size: 19),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onFeedbackSettings,
                    tooltip: 'Feedback settings',
                    icon: const Icon(Icons.tune_rounded, color: Color(0xFF8FEAFF), size: 19),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'SIGNAL ${active.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Color(0xFF48F2C1),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: ArcadeAchievements.unlockedNotifier,
                    builder: (context, unlocked, _) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1E2C),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFFFD36A).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.military_tech_rounded,
                            color: Color(0xFFFFD36A),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${unlocked.length}/${ArcadeAchievements.totalCount}',
                            style: const TextStyle(
                              color: Color(0xFFFFD36A),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isUltraCompact) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF48F2C1),
                        boxShadow: [
                          BoxShadow(color: Color(0xFF48F2C1), blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'READY',
                      style: TextStyle(
                        color: Color(0xFF7591A8),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 31,
              height: 31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF48F2C1),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF48F2C1).withValues(alpha: .35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.videogame_asset_rounded,
                color: Color(0xFF031016),
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FALSE ARCADE',
                  style: TextStyle(
                    color: Color(0xFFF0FAFF),
                    fontSize: 16,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'PressStart2P',
                    letterSpacing: 1.8,
                    shadows: [
                      Shadow(
                        color: Color(0xFF48F2C1),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'SYSTEM SELECT // SIX IMPOSSIBLE GAMES',
                  style: TextStyle(
                    color: Color(0xFF89A3B5),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onHallOfFame,
              tooltip: 'Hall of Fame (High Scores)',
              icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD36A), size: 20),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onTrophies,
              tooltip: 'Trophies & Achievements',
              icon: const Icon(Icons.military_tech_rounded, color: Color(0xFF48F2C1), size: 20),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onFeedbackSettings,
              tooltip: 'Feedback settings',
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF8FEAFF), size: 20),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'SIGNAL ${active.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Color(0xFF48F2C1),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: ArcadeAchievements.unlockedNotifier,
                      builder: (context, unlocked, _) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E2C),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFFD36A).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.military_tech_rounded,
                              color: Color(0xFFFFD36A),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${unlocked.length}/${ArcadeAchievements.totalCount}',
                              style: const TextStyle(
                                color: Color(0xFFFFD36A),
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF48F2C1),
                        boxShadow: [
                          BoxShadow(color: Color(0xFF48F2C1), blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'PLAYER ONE READY',
                      style: TextStyle(
                        color: Color(0xFF7591A8),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .85,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DailyShiftBanner extends StatelessWidget {
  const _DailyShiftBanner({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final contract = DailyShiftManager.getContract();
    final gameDef = arcadeCatalog.firstWhere(
      (g) => g.id == contract.gameId,
      orElse: () => arcadeCatalog.first,
    );
    final accent = gameDef.colors.first;

    return ValueListenableBuilder<DailyStreakLedger>(
      valueListenable: DailyShiftManager.streakNotifier,
      builder: (context, ledger, _) {
        final isDone = ledger.isCompletedOn(contract.dateKey);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.18),
                const Color(0xFF091422),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final isCompact = constraints.maxWidth < 580;

              final streakWidget = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9E40).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFFF9E40),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF9E40),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${ledger.currentStreak} DAYS',
                      style: const TextStyle(
                        color: Color(0xFFFF9E40),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (ledger.shieldTokens > 0) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFF72D6FF),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${ledger.shieldTokens}',
                        style: const TextStyle(
                          color: Color(0xFF72D6FF),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
              );

              final playButton = ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone
                      ? const Color(0xFF23364A)
                      : accent,
                  foregroundColor: isDone
                      ? const Color(0xFF8BA8C2)
                      : const Color(0xFF030A10),
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 10 : 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onPlay,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded,
                      size: 16,
                      color: isDone ? const Color(0xFF48F2C1) : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDone ? 'REPLAY' : 'PLAY SHIFT',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              );

              final mutatorsWrap = Wrap(
                spacing: 6,
                runSpacing: 4,
                children: contract.mutators.map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162536),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      m.name,
                      style: const TextStyle(
                        color: Color(0xFFBDD2E4),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  );
                }).toList(),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 1.5),
                          ),
                          child: Icon(gameDef.icon, color: accent, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DAILY CONTRACT // ${contract.dateKey}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'PressStart2P',
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  streakWidget,
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                gameDef.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    mutatorsWrap,
                    const SizedBox(height: 10),
                    playButton,
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: Icon(gameDef.icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'DAILY CONTRACT // ${contract.dateKey}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'PressStart2P',
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            streakWidget,
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gameDef.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        mutatorsWrap,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  playButton,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _FeaturedGamePanel extends StatelessWidget {
  const _FeaturedGamePanel({
    required this.game,
    required this.index,
    required this.total,
    required this.compact,
    required this.onPlay,
    required this.onPrevious,
    required this.onNext,
  });

  final ArcadeGameDefinition game;
  final int index;
  final int total;
  final bool compact;
  final VoidCallback onPlay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: compact ? 1.12 : 2.12,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF06101A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: game.colors.first.withValues(alpha: .88),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: game.colors.first.withValues(alpha: .28),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          if (game.colors.length > 1)
            BoxShadow(
              color: game.colors[1].withValues(alpha: .15),
              blurRadius: 40,
              offset: const Offset(0, 14),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ArcadeGameArtwork(gameId: game.id, colors: game.colors),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF040912).withValues(alpha: .98),
                    const Color(0xFF040912).withValues(alpha: .70),
                    const Color(0xFF040912).withValues(alpha: .05),
                  ],
                  stops: const [0, .42, 1],
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 15,
              child: _SignalTag(
                text:
                    'SIGNAL ${(index + 1).toString().padLeft(2, '0')} // $total',
                color: game.colors.first,
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
              child: Row(
                children: [
                  _CycleButton(
                    icon: Icons.chevron_left_rounded,
                    label: 'Previous game',
                    onTap: onPrevious,
                  ),
                  const SizedBox(width: 5),
                  _CycleButton(
                    icon: Icons.chevron_right_rounded,
                    label: 'Next game',
                    onTap: onNext,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 15,
              right: compact ? 15 : null,
              bottom: 14,
              width: compact ? null : 390,
              child: _FeaturedCopy(
                game: game,
                onPlay: onPlay,
                compact: compact,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SignalTag extends StatelessWidget {
  const _SignalTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xDD05101A),
      border: Border.all(color: color.withValues(alpha: .68)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _CycleButton extends StatelessWidget {
  const _CycleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: const Color(0xCC06111C),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 38,
          width: 38,
          child: Icon(icon, color: const Color(0xFFCFEAFF), size: 26),
        ),
      ),
    ),
  );
}

class _FeaturedCopy extends StatelessWidget {
  const _FeaturedCopy({
    required this.game,
    required this.onPlay,
    required this.compact,
  });

  final ArcadeGameDefinition game;
  final VoidCallback onPlay;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        game.subtitle.toUpperCase(),
        style: TextStyle(
          color: game.colors.first,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.16,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        game.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFF4FBFF),
          fontSize: compact ? 17 : 22,
          height: 1.1,
          fontWeight: FontWeight.w900,
          fontFamily: 'PressStart2P',
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: game.colors.first.withValues(alpha: .65),
              blurRadius: 12,
            ),
          ],
        ),
      ),
      const SizedBox(height: 7),
      Text(
        game.detail,
        maxLines: compact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFA9BCCB),
          fontSize: 12,
          height: 1.25,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          FilledButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow_rounded, size: 17),
            label: const Text(
              'PLAY MISSION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 37),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              backgroundColor: game.colors.first,
              foregroundColor: const Color(0xFF021016),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '${game.missionLabel}\n${game.campaignStages.toString().padLeft(2, '0')} STAGES ONLINE',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9BB1BF),
                fontSize: 8,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _GameCartridge extends StatelessWidget {
  const _GameCartridge({
    required this.game,
    required this.index,
    required this.selected,
    required this.onHover,
    required this.onPlay,
  });

  final ArcadeGameDefinition game;
  final int index;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Play ${game.title}',
    child: MouseRegion(
      onEnter: (_) => onHover(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onFocusChange: (focused) {
            if (focused) onHover();
          },
          onTap: onPlay,
          borderRadius: BorderRadius.circular(9),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF07101A),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: game.colors.first.withValues(
                  alpha: selected ? 1.0 : .42,
                ),
                width: selected ? 2.0 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: game.colors.first.withValues(alpha: .32),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ArcadeGameArtwork(
                      gameId: game.id,
                      colors: game.colors,
                      muted: !selected,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF02070D).withValues(alpha: .10),
                          const Color(0xFF02070D).withValues(alpha: .92),
                        ],
                        stops: const [.2, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 10,
                    child: Text(
                      '${(index + 1).toString().padLeft(2, '0')} // ${game.campaignStages.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: game.colors.first,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 9,
                    top: 8,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xD9051019),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: game.colors.first.withValues(alpha: .65),
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: game.colors.first,
                        size: 17,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF4FBFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'PressStart2P',
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          game.missionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9CB3C1),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ArcadeFooter extends StatelessWidget {
  const _ArcadeFooter();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'V 1.1  //  TOUCH + KEYBOARD READY',
          style: TextStyle(
            color: Color(0xFF607889),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),
      ),
      const Icon(Icons.gamepad_rounded, color: Color(0xFF48F2C1), size: 14),
      const SizedBox(width: 5),
      const Text(
        'SELECT // PLAY',
        style: TextStyle(
          color: Color(0xFF91A9B8),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

class NotYetApp extends FalseArcadeApp {
  const NotYetApp({super.key});
}
