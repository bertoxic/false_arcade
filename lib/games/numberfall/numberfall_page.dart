part of 'numberfall_game.dart';

class NumberfallPage extends StatefulWidget {
  const NumberfallPage({super.key, this.level, this.onLevelComplete});

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;

  @override
  State<NumberfallPage> createState() => _NumberfallPageState();
}

class _NumberfallPageState extends State<NumberfallPage>
    with SingleTickerProviderStateMixin {
  late final GameLoopController _loop;
  late final _NumberfallGame _game;
  bool _paused = false;
  bool _completionReported = false;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    GamePresentation.enterLandscape();
    _game = _NumberfallGame(
      campaignLevel: widget.level?.number ?? 1,
      random: math.Random(widget.level?.seed),
      campaign: widget.level,
    );
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        if (_game.phase == _NumberPhase.playing) _elapsedSeconds += dt;
        _game.update(dt);
      },
      onFrame: () {
        _reportCompletion();
        if (mounted) setState(() {});
      },
      onLifecyclePause: _game.clearInput,
    )..start();
  }

  void _setPaused(bool value) {
    _game.clearInput();
    _loop.setPaused(value);
    setState(() => _paused = value);
  }

  void _startRun() {
    _game.clearInput();
    _completionReported = false;
    _elapsedSeconds = 0;
    _game.start();
    setState(() {});
  }

  void _nextStage() {
    _game.clearInput();
    _game.nextStage();
    setState(() {});
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_completionReported ||
        level == null ||
        (_game.phase != _NumberPhase.stageClear &&
            _game.phase != _NumberPhase.won)) {
      return;
    }
    _completionReported = true;
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _game.score,
        elapsedSeconds: _elapsedSeconds,
      ),
    );
  }

  @override
  void dispose() {
    _game.clearInput();
    _loop.dispose();
    GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.35,
            colors: [Color(0xFF153947), Color(0xFF061018), Color(0xFF020508)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 520;
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(
                        child: SizedBox.expand(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF376A78),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _NumberPainter(game),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 62,
                                    right: 62,
                                    child: IgnorePointer(
                                      child: Center(
                                        child: GameStageProgressMenu(
                                          title: 'NUMBERFALL',
                                          stageLabel: 'DISPLAY',
                                          currentStage: game.stageNumber,
                                          stageCount: game.stageCount,
                                          accentColor: const Color(0xFF64F6DB),
                                          compact: compact,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 60,
                                    left: 12,
                                    right: 12,
                                    child: IgnorePointer(
                                      child: _NumberArenaHud(game: game),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: GameExitButton(
                                      onExit: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                  if (game.phase == _NumberPhase.playing)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GamePauseButton(
                                        onTap: () => _setPaused(true),
                                      ),
                                    ),
                                  Positioned(
                                    left: 15,
                                    bottom: 15,
                                    child: Row(
                                      children: [
                                        HoldGameButton(
                                          label: 'LEFT',
                                          icon: Icons.chevron_left_rounded,
                                          color: const Color(0xFF67D9ED),
                                          size: compact ? 58 : 66,
                                          onChanged: (value) =>
                                              setState(() => game.left = value),
                                        ),
                                        const SizedBox(width: 7),
                                        HoldGameButton(
                                          label: 'RIGHT',
                                          icon: Icons.chevron_right_rounded,
                                          color: const Color(0xFF67D9ED),
                                          size: compact ? 58 : 66,
                                          onChanged: (value) => setState(
                                            () => game.right = value,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 18,
                                    bottom: 16,
                                    child: HoldGameButton(
                                      label: 'JUMP',
                                      icon: Icons.arrow_upward_rounded,
                                      color: const Color(0xFFFFE66D),
                                      size: compact ? 70 : 80,
                                      onChanged: (value) =>
                                          setState(() => game.setJump(value)),
                                    ),
                                  ),
                                  if (game.phase == _NumberPhase.intro)
                                    _NumberOverlay(
                                      title: 'NUMBERFALL',
                                      copy:
                                          'The glowing segments are solid platforms. Three faint catch dashes sit below the display: land on one to rebound back up before it fades. Read the preview, choose a reachable fragment, and move before the display commits its rewrite.',
                                      button: 'ENTER THE NUMBER',
                                      onTap: _startRun,
                                    ),
                                  if (game.phase == _NumberPhase.dead)
                                    _NumberOverlay(
                                      title: 'YOU FELL',
                                      copy: game.message,
                                      button: 'RESTART',
                                      onTap: _startRun,
                                      danger: true,
                                    ),
                                  if (game.phase == _NumberPhase.stageClear)
                                    _NumberOverlay(
                                      title: 'DISPLAY STABLE',
                                      copy:
                                          'This number held together. The next display rewrites faster and asks for more pickups.',
                                      button: 'NEXT DISPLAY',
                                      onTap: _nextStage,
                                    ),
                                  if (game.phase == _NumberPhase.won)
                                    _NumberOverlay(
                                      title: 'EQUATION SOLVED',
                                      copy:
                                          'You cleared every display, read its rewrites, and found a stable route through the equation.',
                                      button: 'PLAY AGAIN',
                                      onTap: _startRun,
                                    ),
                                  if (_paused)
                                    GamePauseOverlay(
                                      gameName: 'NUMBERFALL',
                                      onResume: () => _setPaused(false),
                                      onRestart: () {
                                        _loop.setPaused(false);
                                        _paused = false;
                                        _startRun();
                                      },
                                      onExit: () => Navigator.of(context).pop(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

class _NumberStat extends StatelessWidget {
  const _NumberStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xCC0B1A23),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF285462)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF86A6B2),
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}

class _NumberArenaHud extends StatelessWidget {
  const _NumberArenaHud({required this.game});

  final _NumberfallGame game;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMBERFALL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Text(
                      'YOUR SCORE IS THE LEVEL',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF80A8B6),
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
              _NumberStat(
                label: 'NUMBER',
                value: game.displayString,
                color: const Color(0xFF64F6DB),
              ),
              const SizedBox(width: 4),
              _NumberStat(
                label: 'COLLECT',
                value: '${game.pickups}/${game.pickupGoal}',
                color: const Color(0xFFFFE66D),
              ),
              const SizedBox(width: 4),
              _NumberStat(
                label: 'STAGE',
                value: '${game.stageNumber}/${game.stageCount}',
                color: const Color(0xFF9AE7FF),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            game.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB7CED7),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _NumberOverlay extends StatelessWidget {
  const _NumberOverlay({
    required this.title,
    required this.copy,
    required this.button,
    required this.onTap,
    this.danger = false,
  });
  final String title;
  final String copy;
  final String button;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xC9061118),
      child: Center(
        child: Container(
          width: 410,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1A23),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: danger ? const Color(0xFF9C4B5C) : const Color(0xFF417B87),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                danger ? 'THE ARITHMETIC WON' : 'LIVING COLLISION GEOMETRY',
                style: const TextStyle(
                  color: Color(0xFF79DDEC),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: danger ? const Color(0xFFFF91A2) : Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                copy,
                style: const TextStyle(
                  color: Color(0xFFC0D5DE),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: danger
                        ? const Color(0xFFC74C64)
                        : const Color(0xFF36B9D0),
                    foregroundColor: const Color(0xFF06141B),
                  ),
                  child: Text(
                    button,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
