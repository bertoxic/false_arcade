part of 'fall_due_game.dart';

class FallDuePage extends StatefulWidget {
  const FallDuePage({
    super.key,
    this.level,
    this.onLevelComplete,
    this.onNextLevel,
  });

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;
  final VoidCallback? onNextLevel;

  @override
  State<FallDuePage> createState() => _FallDuePageState();
}

class _FallDuePageState extends State<FallDuePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameLoopController _loop;
  late final FocusNode _gameFocus;
  late final _FallDueGame _game;
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  bool _paused = false;
  bool _completionReported = false;
  bool _continuingCampaign = false;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GamePresentation.enterLandscape();
    _game = _FallDueGame(
      campaignLevel: widget.level?.number ?? 1,
      campaign: widget.level,
    );
    _gameFocus = FocusNode(debugLabel: 'Fall Due controls');
    _gameFocus.addListener(_onFocusChanged);
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        if (_game.phase == _DuePhase.playing) _elapsedSeconds += dt;
        _game.update(dt);
        _reportCompletion();
      },
      onFrame: () {
        if (mounted) setState(() {});
      },
    )..start();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final recognized = _controlKeys.contains(key);
    if (!recognized) return KeyEventResult.ignored;

    final freshPress = event is KeyDownEvent && _pressedKeys.add(key);
    if (event is KeyUpEvent) _pressedKeys.remove(key);

    _game.left = _isAnyPressed({
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA,
    });
    _game.right = _isAnyPressed({
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyD,
    });
    _game.setBorrow(
      _isAnyPressed({
        LogicalKeyboardKey.keyW,
        LogicalKeyboardKey.shiftLeft,
        LogicalKeyboardKey.shiftRight,
      }),
    );
    _game.setJump(
      _isAnyPressed({LogicalKeyboardKey.space, LogicalKeyboardKey.arrowUp}),
    );

    if (freshPress && key == LogicalKeyboardKey.keyQ) {
      _game.transferDebt();
    } else if (freshPress && key == LogicalKeyboardKey.keyE) {
      _game.stealDebt();
    } else if (freshPress && key == LogicalKeyboardKey.keyF) {
      _game.cycleTarget();
    }
    setState(() {});
    return KeyEventResult.handled;
  }

  static final Set<LogicalKeyboardKey> _controlKeys = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyF,
  };

  bool _isAnyPressed(Set<LogicalKeyboardKey> keys) =>
      keys.any(_pressedKeys.contains);

  void _onFocusChanged() {
    if (!_gameFocus.hasFocus) _clearInput();
  }

  void _clearInput() {
    _pressedKeys.clear();
    _game.clearInput();
  }

  void _setPaused(bool value) {
    if (value) _clearInput();
    _loop.setPaused(value);
    setState(() => _paused = value);
    if (!value) _gameFocus.requestFocus();
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_completionReported ||
        level == null ||
        (_game.phase != _DuePhase.stageClear && _game.phase != _DuePhase.won)) {
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

  void _continueCampaign() {
    _continuingCampaign = true;
    final next = widget.onNextLevel;
    if (next != null) {
      next();
    } else {
      Navigator.of(context).pop(CampaignNavigation.nextLevel);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _clearInput();
    if (!_paused && _game.phase == _DuePhase.playing) {
      _loop.setPaused(true);
      if (mounted) setState(() => _paused = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameFocus.removeListener(_onFocusChanged);
    _loop.dispose();
    _gameFocus.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      body: Focus(
        focusNode: _gameFocus,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1),
              radius: 1.3,
              colors: [Color(0xFF202A43), Color(0xFF0B0E15), Color(0xFF030406)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 520;
                return Column(
                  children: [
                    Offstage(
                      offstage: true,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          compact ? 6 : 10,
                          18,
                          0,
                        ),
                        child: Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FALL DUE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    letterSpacing: 2.1,
                                  ),
                                ),
                                Text(
                                  'BORROW GRAVITY. PAY IT BACK.',
                                  style: TextStyle(
                                    color: Color(0xFF9BB5D2),
                                    fontSize: 9,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _DueStat(
                              label: game.inPayback ? 'PAYBACK' : 'LOAN',
                              value: game.gravityReadout,
                              color: game.inPayback
                                  ? const Color(0xFFFFD86E)
                                  : const Color(0xFF8DE1FF),
                            ),
                            const SizedBox(width: 8),
                            _DueStat(
                              label: 'HEARTS',
                              value: '♥ ${game.lives}',
                              color: const Color(0xFFFF7186),
                            ),
                            const SizedBox(width: 8),
                            _DueStat(
                              label: 'STAGE',
                              value: game.stageProgress,
                              color: const Color(0xFFFFD86E),
                            ),
                            const SizedBox(width: 8),
                            _DueStat(
                              label: 'SCORE',
                              value: '${game.score}',
                              color: const Color(0xFF8CFFB1),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                    color: const Color(0xFF3A4A67),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _FallPainter(game),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 62,
                                      right: 62,
                                      child: IgnorePointer(
                                        child: Center(
                                          child: GameStageProgressMenu(
                                            title: 'FALL DUE',
                                            stageLabel: 'STAGE',
                                            currentStage: game.stageNumber,
                                            stageCount:
                                                _FallDueGame.stages.length,
                                            accentColor: const Color(
                                              0xFFFFD86E,
                                            ),
                                            compact: compact,
                                            endless:
                                                game.levelIndex >=
                                                _FallDueGame.stages.length,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 60,
                                      left: 12,
                                      right: 12,
                                      child: IgnorePointer(
                                        child: _DueArenaHud(game: game),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: GameExitButton(
                                        onExit: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                    if (game.phase == _DuePhase.playing)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GamePauseButton(
                                          onTap: () => _setPaused(true),
                                        ),
                                      ),
                                    Positioned(
                                      left: 14,
                                      bottom: 14,
                                      child: Row(
                                        children: [
                                          HoldGameButton(
                                            label: 'LEFT',
                                            icon: Icons.chevron_left_rounded,
                                            color: const Color(0xFF8DE1FF),
                                            size: compact ? 64 : 76,
                                            onChanged: (value) => setState(
                                              () => game.left = value,
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          HoldGameButton(
                                            label: 'RIGHT',
                                            icon: Icons.chevron_right_rounded,
                                            color: const Color(0xFF8DE1FF),
                                            size: compact ? 64 : 76,
                                            onChanged: (value) => setState(
                                              () => game.right = value,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 14,
                                      bottom: 14,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              HoldGameButton(
                                                label: 'JUMP',
                                                icon: Icons
                                                    .keyboard_double_arrow_up_rounded,
                                                color: const Color(0xFF8DE1FF),
                                                size: compact ? 56 : 67,
                                                onChanged: (value) => setState(
                                                  () => game.setJump(value),
                                                ),
                                              ),
                                              const SizedBox(width: 7),
                                              HoldGameButton(
                                                label: 'BORROW',
                                                icon:
                                                    Icons.arrow_upward_rounded,
                                                color: const Color(0xFFFFD86E),
                                                size: compact ? 70 : 80,
                                                onChanged: (value) => setState(
                                                  () => game.setBorrow(value),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 7),
                                          Row(
                                            children: [
                                              TapGameButton(
                                                label: 'CYCLE',
                                                icon:
                                                    Icons.track_changes_rounded,
                                                color: const Color(0xFFB3A0FF),
                                                width: compact ? 56 : 67,
                                                onTap: () =>
                                                    setState(game.cycleTarget),
                                              ),
                                              const SizedBox(width: 7),
                                              TapGameButton(
                                                label: 'GIVE',
                                                icon: Icons.north_east_rounded,
                                                color: const Color(0xFF8CFFB1),
                                                width: compact ? 56 : 67,
                                                onTap: () =>
                                                    setState(game.transferDebt),
                                              ),
                                              const SizedBox(width: 7),
                                              TapGameButton(
                                                label: 'TAKE',
                                                icon: Icons.south_west_rounded,
                                                color: const Color(0xFFFFD86E),
                                                width: compact ? 56 : 67,
                                                onTap: () =>
                                                    setState(game.stealDebt),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (game.phase == _DuePhase.intro)
                                      _DueOverlay(
                                        title: 'FALL DUE',
                                        copy:
                                            'Jump the route, then HOLD BORROW to lift yourself through the air. GIVE makes yellow crates heavy enough to seal spike beds. TAKE makes any yellow crate rise through platforms, carry you upward, or hold a lever. Touch blue SAVE beacons to keep your progress.',
                                        button: 'ENTER THE LEDGER',
                                        onTap: () => setState(game.start),
                                        showLoop: true,
                                      ),
                                    if (game.phase == _DuePhase.dead)
                                      _DueOverlay(
                                        title: 'FELL DUE',
                                        copy: game.message,
                                        button: 'RESUME FROM SAVE',
                                        onTap: () =>
                                            setState(game.retryFromCheckpoint),
                                        danger: true,
                                      ),
                                    if (game.phase == _DuePhase.stageClear)
                                      if (widget.level != null)
                                        CampaignMissionClearOverlay(
                                          level: widget.level!,
                                          score: game.score,
                                          elapsedSeconds: _elapsedSeconds,
                                          accent: const Color(0xFF8DE1FF),
                                          onNextLevel: _continueCampaign,
                                          onExit: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      else
                                        _DueOverlay(
                                          title: 'STAGE CLEAR',
                                          copy: game.message,
                                          button: 'NEXT STAGE',
                                          onTap: () => setState(game.nextStage),
                                        ),
                                    if (game.phase == _DuePhase.won)
                                      if (widget.level != null)
                                        CampaignMissionClearOverlay(
                                          level: widget.level!,
                                          score: game.score,
                                          elapsedSeconds: _elapsedSeconds,
                                          accent: const Color(0xFF8DE1FF),
                                          onNextLevel: _continueCampaign,
                                          onExit: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      else
                                        _DueOverlay(
                                          title: 'DEBT SETTLED',
                                          copy:
                                              'The campaign account is clear. Continue into escalating contract runs, or replay the authored audit.',
                                          button: 'ENTER CONTRACT RUNS',
                                          onTap: () => setState(
                                            game.startEndlessContracts,
                                          ),
                                          secondaryButton: 'REPLAY CAMPAIGN',
                                          onSecondaryTap: () =>
                                              setState(game.start),
                                        ),
                                    if (_paused)
                                      GamePauseOverlay(
                                        gameName: 'FALL DUE',
                                        onResume: () => _setPaused(false),
                                        onRestart: () {
                                          _loop.setPaused(false);
                                          setState(() {
                                            _paused = false;
                                            game.start();
                                          });
                                          _gameFocus.requestFocus();
                                        },
                                        onExit: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: true,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          compact ? 6 : 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFFFD86E),
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${game.message}   •   Keyboard: A/D move · Space jump · W borrow · Q give · E take · F cycle',
                                style: const TextStyle(
                                  color: Color(0xFFBAC8DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DueStat extends StatelessWidget {
  const _DueStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xCC111826),
      border: Border.all(color: const Color(0xFF2E3C57)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 7,
            color: Color(0xFF8E9DBB),
            fontWeight: FontWeight.w900,
            letterSpacing: .65,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _DueArenaHud extends StatelessWidget {
  const _DueArenaHud({required this.game});

  final _FallDueGame game;

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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FALL DUE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Text(
                      game.objectiveReadout,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9BB5D2),
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
              _DueStat(
                label: game.inPayback ? 'PAYBACK' : 'LOAN',
                value: game.gravityReadout,
                color: game.inPayback
                    ? const Color(0xFFFFD86E)
                    : const Color(0xFF8DE1FF),
              ),
              const SizedBox(width: 4),
              _DueStat(
                label: 'HEARTS',
                value: '♥ ${game.lives}',
                color: const Color(0xFFFF7186),
              ),
              const SizedBox(width: 4),
              _DueStat(
                label: 'STAGE',
                value: game.stageProgress,
                color: const Color(0xFFFFD86E),
              ),
              const SizedBox(width: 4),
              _DueStat(
                label: 'SCORE',
                value: '${game.score}',
                color: const Color(0xFF8CFFB1),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            game.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBAC8DF),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DueOverlay extends StatelessWidget {
  const _DueOverlay({
    required this.title,
    required this.copy,
    required this.button,
    required this.onTap,
    this.danger = false,
    this.showLoop = false,
    this.secondaryButton,
    this.onSecondaryTap,
  });
  final String title;
  final String copy;
  final String button;
  final VoidCallback onTap;
  final bool danger;
  final bool showLoop;
  final String? secondaryButton;
  final VoidCallback? onSecondaryTap;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xCA070910),
      child: Center(
        child: Container(
          width: 430,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            color: const Color(0xFF151B2A),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: danger ? const Color(0xFF954B5B) : const Color(0xFF526D96),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                danger
                    ? 'THE LEDGER COLLECTED'
                    : 'A PLATFORMER ABOUT CONSEQUENCES',
                style: const TextStyle(
                  color: Color(0xFFFFD86E),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: danger ? const Color(0xFFFF8B9B) : Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                copy,
                style: const TextStyle(
                  color: Color(0xFFC7D2E5),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              if (showLoop) ...[
                const SizedBox(height: 15),
                const _GravityLoopGuide(),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: danger
                        ? const Color(0xFFC44A62)
                        : const Color(0xFF5979B6),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    button,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                ),
              ),
              if (secondaryButton != null && onSecondaryTap != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSecondaryTap,
                    child: Text(secondaryButton!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _GravityLoopGuide extends StatelessWidget {
  const _GravityLoopGuide();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1320),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF344865)),
    ),
    child: const Row(
      children: [
        _LoopStep(number: '1', label: 'BORROW', color: Color(0xFF8DE1FF)),
        Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF8E9DBB)),
        _LoopStep(number: '2', label: 'GIVE', color: Color(0xFFFFD86E)),
        Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF8E9DBB)),
        _LoopStep(number: '3', label: 'TAKE', color: Color(0xFF8CFFB1)),
      ],
    ),
  );
}

class _LoopStep extends StatelessWidget {
  const _LoopStep({
    required this.number,
    required this.label,
    required this.color,
  });

  final String number;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 17,
          height: 17,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF071018),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
      ],
    ),
  );
}
