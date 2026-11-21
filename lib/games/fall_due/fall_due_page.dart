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
    )..preparePreview();
    GameFeedback.playMusic(_landscapeForStage(_game._initialLevelIndex).music);
    _gameFocus = FocusNode(debugLabel: 'Fall Due controls');
    _gameFocus.addListener(_onFocusChanged);
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        if (ArcadeHitStop.tick(dt)) return;
        ArcadeFever.tick(dt);
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
    _game.setSlam(
      _isAnyPressed({LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown}),
    );

    if (freshPress && key == LogicalKeyboardKey.keyQ) {
      _game.transferDebt();
    } else if (freshPress && key == LogicalKeyboardKey.keyE) {
      _game.stealDebt();
    } else if (freshPress && key == LogicalKeyboardKey.keyF) {
      _game.cycleTarget();
    } else if (freshPress && key == LogicalKeyboardKey.keyR) {
      _game.performRepulsorBurst();
    } else if (freshPress && key == LogicalKeyboardKey.keyP) {
      _game.performPhaseShift();
    } else if (freshPress && key == LogicalKeyboardKey.keyT) {
      _game.performTether();
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
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyT,
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

  void _selectPlayfieldTarget(Offset point, Size size) {
    final viewport = LogicalViewport.fit(size, _duePlayfieldSize);
    if (!viewport.screenWorldRect.contains(point)) return;
    final worldPoint = viewport.screenToWorld(point) + Offset(_game.camera, 0);
    final padding = (10 / viewport.scale).clamp(6.0, 24.0);
    setState(() => _game.selectTargetAt(worldPoint, padding));
  }

  void _setPaused(bool value) {
    if (value) _clearInput();
    _loop.setPaused(value);
    if (value) {
      GameFeedback.pauseMusic();
    } else {
      GameFeedback.resumeMusic();
    }
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
    ArcadeFlash.reset();
    ArcadeFever.reset();
    GameFeedback.playMusic('arcade_theme');
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final stageIndex = game.phase == _DuePhase.intro
        ? game._initialLevelIndex
        : game.levelIndex;
    final landscape = _landscapeForStage(stageIndex);
    final playing = game.phase == _DuePhase.playing;
    return Scaffold(
      backgroundColor: _dueInk,
      body: Focus(
        focusNode: _gameFocus,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _DueBackdrop(landscape, camera: game.camera),
            LayoutBuilder(
              builder: (context, bounds) => GestureDetector(
                key: const ValueKey('fall-due-playfield'),
                behavior: HitTestBehavior.opaque,
                onTapUp: playing && !_paused
                    ? (event) => _selectPlayfieldTarget(
                        event.localPosition,
                        bounds.biggest,
                      )
                    : null,
                child: RepaintBoundary(
                  child: CustomPaint(painter: _FallPainter(game, landscape)),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, bounds) => Stack(
                  children: [
                    if (playing) ...[
                      if (game.currentWorkshop != null)
                        Positioned(
                          top: 53,
                          right: 8,
                          child: _DueIconButton(
                            icon: Icons.restore_rounded,
                            tooltip: 'Reset encounter',
                            onTap: () => setState(game.resetWorkshop),
                          ),
                        ),
                      Positioned(
                        top: bounds.maxWidth < 370 ? 56 : 9,
                        left: bounds.maxWidth < 370 ? 9 : 61,
                        right: bounds.maxWidth < 370 ? 9 : 61,
                        child: IgnorePointer(
                          child: _DueArenaHud(
                            game: game,
                            landscape: landscape,
                            campaign: widget.level != null,
                            compact: bounds.maxWidth < 560,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 7,
                        right: 8,
                        child: _DueIconButton(
                          icon: Icons.pause_rounded,
                          tooltip: 'Pause game',
                          onTap: () => _setPaused(true),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: _DueControls(
                          game: game,
                          availableSize: bounds.biggest,
                        ),
                      ),
                    ],
                    if (game.phase == _DuePhase.intro)
                      _DueOverlay(
                        landscape: landscape,
                        title: 'Fall Due',
                        copy: stageIndex == 0
                            ? 'Borrow to glide across gaps and Slam to land hard. Step on or push crates onto weight plates to open route blast gates. Collect all seals to unlock the exit!'
                            : game.level.briefing,
                        button: 'ENTER THE LEDGER',
                        onTap: () => setState(game.start),
                      ),
                    if (game.phase == _DuePhase.dead)
                      _DueOverlay(
                        title: 'Fell Due',
                        copy: game.message,
                        button: 'RESUME FROM SAVE',
                        onTap: () => setState(game.retryFromCheckpoint),
                        danger: true,
                      ),
                    if (game.phase == _DuePhase.stageClear ||
                        game.phase == _DuePhase.won)
                      if (widget.level case final level?)
                        CampaignMissionClearOverlay(
                          level: level,
                          score: game.score,
                          elapsedSeconds: _elapsedSeconds,
                          accent: _dueGold,
                          onNextLevel: _continueCampaign,
                          onExit: () => Navigator.of(context).pop(),
                        )
                      else if (game.phase == _DuePhase.stageClear)
                        _DueOverlay(
                          title: 'Stage Clear',
                          copy: game.message,
                          button: 'NEXT STAGE',
                          onTap: () => setState(() {
                            game.nextStage();
                            GameFeedback.playMusic(_landscapeForStage(game.levelIndex).music);
                          }),
                        )
                      else
                        _DueOverlay(
                          title: 'Debt Settled',
                          copy:
                              'Continue into escalating contract runs or replay the campaign.',
                          button: 'ENTER CONTRACT RUNS',
                          onTap: () => setState(() {
                            game.startEndlessContracts();
                            GameFeedback.playMusic(_landscapeForStage(game.levelIndex).music);
                          }),
                          secondaryButton: 'REPLAY CAMPAIGN',
                          onSecondaryTap: () => setState(game.start),
                        ),
                    Positioned(
                      top: 7,
                      left: 8,
                      child: _DueIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Exit game',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    if (_paused)
                      GamePauseOverlay(
                        gameName: 'FALL DUE',
                        onResume: () => _setPaused(false),
                        onRestart: () {
                          setState(game.start);
                          _setPaused(false);
                        },
                        onExit: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueIconButton extends StatelessWidget {
  const _DueIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: () {
      GameFeedback.selection();
      onTap();
    },
    icon: Icon(icon, size: 20),
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: const Color(0xDC2F2536),
      foregroundColor: _dueCream,
      minimumSize: const Size.square(44),
      side: const BorderSide(color: Color(0x56FFE1AC)),
    ),
  );
}

class _DueArenaHud extends StatelessWidget {
  const _DueArenaHud({
    required this.game,
    required this.landscape,
    required this.campaign,
    required this.compact,
  });

  final _FallDueGame game;
  final _DueLandscape landscape;
  final bool campaign;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final meterColor = game.inPayback ? _dueGold : _dueBlue;
    final stage = campaign ? 'Stage ${game.stageNumber}' : game.stageProgress;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DueHudTile(
              label: 'HEARTS',
              child: Semantics(
                label: '${game.lives} of 5 hearts remaining',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < game.lives
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: index < game.lives
                          ? _dueCoral
                          : const Color(0xFF937C8C),
                      size: compact ? 11 : 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _DueHudTile(
              label: 'SEALS',
              child: Text(
                '${game.collectedSeals}/${game.seals.length}',
                style: const TextStyle(
                  color: _dueGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            if (!compact) ...[
              if (game.lockedGates > 0) ...[
                const SizedBox(width: 4),
                _DueHudTile(
                  label: 'LOCKS',
                  child: Text(
                    '${game.lockedGates}',
                    style: const TextStyle(
                      color: _dueCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              _DueHudTile(
                label: 'SCORE',
                child: Text(
                  '${game.score}',
                  style: const TextStyle(
                    color: _dueCream,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  child: Text(
                    '${landscape.title}  ·  $stage',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _dueCream,
                      fontFamily: 'Georgia',
                      fontFamilyFallback: ['Noto Serif', 'serif'],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: _dueInk,
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const Spacer(),
            _DueHudTile(
              label: game.inPayback ? 'HEAVY' : 'GRAVITY',
              child: SizedBox(
                width: compact ? 53 : 103,
                height: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (game.gravityMeter / 100).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: const Color(0xFF5A4A61),
                          color: meterColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.gravityReadout,
                      style: TextStyle(
                        color: meterColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xC52F2536),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              game.message,
              textAlign: TextAlign.center,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _dueCream,
                fontSize: 9,
                height: 1.20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DueHudTile extends StatelessWidget {
  const _DueHudTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xE42F2536),
      border: Border.all(color: const Color(0x54FFE1AC)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE6CDB7),
            fontWeight: FontWeight.w900,
            fontSize: 8,
            letterSpacing: .75,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        child,
      ],
    ),
  );
}

class _DueOverlay extends StatelessWidget {
  const _DueOverlay({
    required this.title,
    required this.copy,
    required this.button,
    required this.onTap,
    this.landscape,
    this.danger = false,
    this.secondaryButton,
    this.onSecondaryTap,
  });

  final String title;
  final String copy;
  final String button;
  final VoidCallback onTap;
  final _DueLandscape? landscape;
  final bool danger;
  final String? secondaryButton;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0x4921192C),
      child: Center(
        child: Container(
          width: 370,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF04A3545), Color(0xFA292330)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: danger ? _dueCoral : const Color(0x89F7CB91),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5423192A),
                blurRadius: 32,
                offset: Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 19, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (landscape case final scene?)
                  Text(
                    scene.title.toUpperCase(),
                    style: const TextStyle(
                      color: _dueGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontFamilyFallback: const ['Noto Serif', 'serif'],
                    fontSize: 41,
                    height: 1.13,
                    fontWeight: FontWeight.w700,
                    color: danger ? _dueCoral : _dueCream,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  copy,
                  style: const TextStyle(
                    color: Color(0xFFF0DEC8),
                    fontSize: 13,
                    height: 1.36,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: danger ? _dueCoral : _dueGold,
                    foregroundColor: _dueInk,
                  ),
                  child: Text(
                    button,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .65,
                    ),
                  ),
                ),
                if (secondaryButton != null && onSecondaryTap != null)
                  OutlinedButton(
                    onPressed: onSecondaryTap,
                    style: OutlinedButton.styleFrom(foregroundColor: _dueCream),
                    child: Text(secondaryButton!),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
