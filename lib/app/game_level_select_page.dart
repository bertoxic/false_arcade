import 'package:flutter/material.dart';

import '../core/level_campaign.dart';
import '../games/future_debt/future_debt_game.dart';
import 'arcade_catalog.dart';
import 'game_tutorial_page.dart';

class GameLevelSelectPage extends StatefulWidget {
  const GameLevelSelectPage({super.key, required this.game});

  final ArcadeGameDefinition game;

  @override
  State<GameLevelSelectPage> createState() => _GameLevelSelectPageState();
}

class _GameLevelSelectPageState extends State<GameLevelSelectPage> {
  final _store = LevelCampaignStore();
  late Future<LevelCampaignProgress> _progressFuture;
  LevelCampaignProgress? _progress;
  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    _progressFuture = _store.load();
  }

  void _setProgress(LevelCampaignProgress progress) {
    _progress = progress;
    final unlocked = progress.unlockedLevelFor(widget.game.id);
    _selectedLevel = _selectedLevel.clamp(1, unlocked);
  }

  void _recordCompletion(LevelRunResult result) {
    final progress = _progress;
    if (progress == null) return;
    setState(() => progress.record(result));
    _store.save(progress);
  }

  Future<void> _launch(LevelCampaignProgress progress) async {
    final blueprint = GameLevelGenerator.generate(
      widget.game.id,
      _selectedLevel,
    );
    final hasCompletedTutorial = await _store.hasCompletedTutorial(
      widget.game.id,
    );
    if (!mounted) return;
    if (!hasCompletedTutorial) {
      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => GameTutorialPage(game: widget.game, level: blueprint),
        ),
      );
      if (completed != true || !mounted) return;
      await _store.markTutorialCompleted(widget.game.id);
      if (!mounted) return;
    }
    final navigation = await Navigator.of(context).push<CampaignNavigation>(
      MaterialPageRoute<CampaignNavigation>(
        builder: (_) =>
            widget.game.levelPageBuilder(blueprint, _recordCompletion, () {
              Navigator.of(context).pop(CampaignNavigation.nextLevel);
            }),
      ),
    );
    if (!mounted ||
        navigation != CampaignNavigation.nextLevel ||
        _selectedLevel >= gameCampaignLevelCount) {
      return;
    }
    setState(() => _selectedLevel++);
    // The progress object is updated synchronously by _recordCompletion, so
    // the next mission is unlocked even while its disk save completes.
    await _launch(progress);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LevelCampaignProgress>(
    future: _progressFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final progress = _progress ?? snapshot.data!;
      if (_progress == null) _setProgress(progress);
      final accent = widget.game.colors.first;
      final selected = GameLevelGenerator.generate(
        widget.game.id,
        _selectedLevel,
      );
      final stars = progress.starsFor(widget.game.id, _selectedLevel);
      return Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1),
              radius: 1.25,
              colors: [
                accent.withValues(alpha: .22),
                const Color(0xFF07101A),
                const Color(0xFF02050A),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 7
                    : constraints.maxWidth >= 620
                    ? 5
                    : 3;
                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            tooltip: 'Back to games',
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.game.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: .95,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'GENERATED CAMPAIGN · $gameCampaignLevelCount LEVELS · ${progress.totalStars} STARS SAVED',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          itemCount: gameCampaignLevelCount,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 9,
                                childAspectRatio: 1.12,
                              ),
                          itemBuilder: (context, index) {
                            final number = index + 1;
                            final unlocked = progress.isUnlocked(
                              widget.game.id,
                              number,
                            );
                            return _LevelNode(
                              number: number,
                              stars: progress.starsFor(widget.game.id, number),
                              selected: number == _selectedLevel,
                              unlocked: unlocked,
                              accent: accent,
                              onTap: unlocked
                                  ? () =>
                                        setState(() => _selectedLevel = number)
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ChallengeCard(
                        level: selected,
                        existingStars: stars,
                        accent: accent,
                        onPlay: () => _launch(progress),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.number,
    required this.stars,
    required this.selected,
    required this.unlocked,
    required this.accent,
    required this.onTap,
  });

  final int number;
  final int stars;
  final bool selected;
  final bool unlocked;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: unlocked
              ? selected
                    ? accent.withValues(alpha: .21)
                    : const Color(0xFF0A1521)
              : const Color(0xFF080C14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unlocked
                ? accent.withValues(alpha: selected ? .95 : .38)
                : const Color(0xFF2B3547),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: unlocked
                  ? Text(
                      number.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Color(0xFF536075)),
            ),
            if (unlocked)
              Positioned(
                left: 5,
                right: 5,
                bottom: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 12,
                      color: index < stars
                          ? const Color(0xFFFFD36A)
                          : const Color(0xFF536075),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.level,
    required this.existingStars,
    required this.accent,
    required this.onPlay,
  });

  final GeneratedGameLevel level;
  final int existingStars;
  final Color accent;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final targetScore = level.gameId == 'future_debt'
        ? FutureDebtRules.campaignTargetScore(level.targetScore)
        : level.targetScore;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xE80A111B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEVEL ${level.number.toString().padLeft(2, '0')} · ${level.chapterTitle}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${level.storyBeat}\nObjective: ${level.objective}\nFocus: ${level.gameplayFocus}\nTarget $targetScore · Par ${level.parSeconds.round()}s · ${existingStars}/3 stars',
                  style: const TextStyle(
                    color: Color(0xFFC0CDDF),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          FilledButton.icon(
            onPressed: onPlay,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: const Color(0xFF031018),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'PLAY',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
