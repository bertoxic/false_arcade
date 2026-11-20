part of 'future_debt_game.dart';

class FutureDebtPage extends StatefulWidget {
  const FutureDebtPage({
    super.key,
    this.level,
    this.onLevelComplete,
    this.onNextLevel,
  });

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;
  final VoidCallback? onNextLevel;

  @override
  State<FutureDebtPage> createState() => _FutureDebtPageState();
}

class _FutureDebtPageState extends State<FutureDebtPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameLoopController _loop;
  late final FocusNode _gameFocus;
  late final _FutureDebtGame _game;
  ui.Image? _floorArt;
  ui.Image? _treeArt;
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  Offset _input = Offset.zero;
  Offset _aimInput = Offset.zero;
  bool _firing = false;
  bool _paused = false;
  bool _campaignComplete = false;
  _FutureDebtPace _pace = _FutureDebtPace.standard;
  _FutureDebtKeyboardLayout _keyboardLayout =
      _FutureDebtKeyboardLayout.wasdMove;
  // A Next Level action pops this route and immediately launches another
  // Future Debt route. Do not restore portrait/orientation in the gap: the
  // platform can apply that asynchronous restore after the next route has
  // requested landscape, leaving the new level rotated incorrectly.
  bool _continuingCampaign = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GamePresentation.enterLandscape();
    GameFeedback.playMusic(_FutureDebtGame.musicTheme);
    _game = _FutureDebtGame(campaign: widget.level);
    _gameFocus = FocusNode(debugLabel: 'Future Debt controls')
      ..addListener(_onFocusChanged);
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        if (ArcadeHitStop.tick(dt)) return;
        ArcadeFever.tick(dt);
        _game.update(dt, _input, _aimInput, _firing);
      },
      onFrame: () {
        _reportCompletion();
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
    _loadPace();
    _loadArtwork('sunset_ground.jpg', (image) => _floorArt = image);
    _loadArtwork('sunset_tree.png', (image) => _treeArt = image);
  }

  Future<void> _loadArtwork(String name, ValueChanged<ui.Image> assign) async {
    try {
      final data = await rootBundle.load('$_futureAssetPath/$name');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => assign(image));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'future_debt',
          context: ErrorDescription('loading $name artwork'),
        ),
      );
    }
  }

  Future<void> _loadPace() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPace = preferences.getString('future_debt.accessibility.pace');
    final pace = _FutureDebtPace.values.where(
      (value) => value.name == savedPace,
    );
    final savedLayout = preferences.getString(
      'future_debt.accessibility.keyboard_layout',
    );
    final layout = _FutureDebtKeyboardLayout.values.where(
      (value) => value.name == savedLayout,
    );
    if (!mounted) return;
    setState(() {
      if (pace.isNotEmpty) _pace = pace.first;
      if (layout.isNotEmpty) _keyboardLayout = layout.first;
      _game.setPace(_pace);
    });
  }

  Future<void> _selectPace(_FutureDebtPace pace) async {
    setState(() {
      _pace = pace;
      _game.setPace(pace);
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('future_debt.accessibility.pace', pace.name);
  }

  Future<void> _selectKeyboardLayout(_FutureDebtKeyboardLayout layout) async {
    setState(() {
      _keyboardLayout = layout;
      _clearInput();
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'future_debt.accessibility.keyboard_layout',
      layout.name,
    );
  }

  void _clearInput() {
    _pressedKeys.clear();
    _input = Offset.zero;
    _aimInput = Offset.zero;
    _firing = false;
    _game.cancelTransientInput();
  }

  void _start() {
    _clearInput();
    _campaignComplete = false;
    _game.start();
    _gameFocus.requestFocus();
    setState(() {});
  }

  void _pause(bool value) {
    _clearInput();
    _loop.setPaused(value);
    if (value) {
      GameFeedback.pauseMusic();
    } else {
      GameFeedback.resumeMusic();
    }
    setState(() => _paused = value);
    if (!value) _gameFocus.requestFocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (!_controlKeys.contains(key)) return KeyEventResult.ignored;
    final freshPress = event is KeyDownEvent && _pressedKeys.add(key);
    if (event is KeyUpEvent) _pressedKeys.remove(key);
    _input = _keyboardLayout == _FutureDebtKeyboardLayout.wasdMove
        ? _directionalInput(
            LogicalKeyboardKey.keyA,
            LogicalKeyboardKey.keyD,
            LogicalKeyboardKey.keyW,
            LogicalKeyboardKey.keyS,
          )
        : _directionalInput(
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
          );
    _aimInput = _keyboardLayout == _FutureDebtKeyboardLayout.wasdMove
        ? _directionalInput(
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
          )
        : _directionalInput(
            LogicalKeyboardKey.keyJ,
            LogicalKeyboardKey.keyL,
            LogicalKeyboardKey.keyI,
            LogicalKeyboardKey.keyK,
          );
    _firing = _isPressed(LogicalKeyboardKey.space);
    if (freshPress &&
        (key == LogicalKeyboardKey.shiftLeft ||
            key == LogicalKeyboardKey.shiftRight)) {
      _game.dash();
    } else if (freshPress && key == LogicalKeyboardKey.digit1) {
      _game.borrow(_DebtKind.move);
    } else if (freshPress && key == LogicalKeyboardKey.digit3) {
      _game.borrow(_DebtKind.dash);
    } else if (freshPress && key == LogicalKeyboardKey.keyB) {
      _game.bankrupt();
    } else if (freshPress && key == LogicalKeyboardKey.escape) {
      _pause(!_paused);
    }
    setState(() {});
    return KeyEventResult.handled;
  }

  bool _isPressed(LogicalKeyboardKey key) => _pressedKeys.contains(key);

  Offset _directionalInput(
    LogicalKeyboardKey left,
    LogicalKeyboardKey right,
    LogicalKeyboardKey up,
    LogicalKeyboardKey down,
  ) => Offset(
    (_isPressed(right) ? 1 : 0) - (_isPressed(left) ? 1 : 0),
    (_isPressed(down) ? 1 : 0) - (_isPressed(up) ? 1 : 0),
  );

  static final Set<LogicalKeyboardKey> _controlKeys = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.escape,
  };

  void _onFocusChanged() {
    if (!_gameFocus.hasFocus) _clearInput();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _clearInput();
    if (!_paused && _game.isPlaying) _pause(true);
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_campaignComplete || level == null || !_game.levelExitReached) {
      return;
    }
    _campaignComplete = true;
    _clearInput();
    _loop.setPaused(true);
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _game.score.floor(),
        elapsedSeconds: _game.time,
      ),
    );
  }

  void _continueCampaign() {
    final next = widget.onNextLevel;
    if (next != null) {
      _continuingCampaign = true;
      next();
    } else {
      Navigator.of(context).pop(CampaignNavigation.nextLevel);
    }
  }

  @override
  void dispose() {
    _floorArt?.dispose();
    _treeArt?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _clearInput();
    _loop.dispose();
    _gameFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    ArcadeFlash.reset();
    ArcadeFever.reset();
    GameFeedback.playMusic('arcade_theme');
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      backgroundColor: _futureInk,
      body: Focus(
        focusNode: _gameFocus,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                key: const ValueKey('future-debt-playfield'),
                painter: _FuturePainter(
                  game,
                  _floorArt,
                  _treeArt,
                  safeInsets: MediaQuery.paddingOf(context),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final compact =
                      bounds.maxHeight < 520 || bounds.maxWidth < 640;
                  final narrow = bounds.maxWidth < 510;
                  final left = narrow ? 9.0 : 60.0;
                  final right = narrow ? 9.0 : 163.0;
                  final portrait = bounds.maxHeight > bounds.maxWidth;
                  final stick =
                      (portrait
                              ? bounds.maxWidth * .305
                              : bounds.maxHeight * .34)
                          .clamp(98.0, 174.0);
                  return Stack(
                    children: [
                      if (game.isPlaying) ...[
                        Positioned(
                          top: narrow ? 55 : 9,
                          left: left,
                          right: right,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: _FutureTopHud(
                                  game: game,
                                  compact: compact,
                                  onBankruptcy: () => setState(game.bankrupt),
                                ),
                              ),
                              const SizedBox(height: 5),
                              IgnorePointer(
                                child: _MessageStrip(
                                  game: game,
                                  compact: compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 7,
                          right: 8,
                          child: GamePauseButton(onTap: () => _pause(true)),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: TouchStick(
                            size: stick,
                            onChanged: (value) =>
                                setState(() => _input = value),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _FutureCombatControls(
                            game: game,
                            fireSize: stick,
                            onDash: () => setState(game.dash),
                            onBorrow: (kind) =>
                                setState(() => game.borrow(kind)),
                            onFiringChanged: (held) =>
                                setState(() => _firing = held),
                            onAimChanged: (value) =>
                                setState(() => _aimInput = value),
                          ),
                        ),
                      ],
                      if (game.phase == _FuturePhase.intro)
                        _FutureOverlay(
                          game: game,
                          pace: _pace,
                          onPaceChanged: _selectPace,
                          keyboardLayout: _keyboardLayout,
                          onKeyboardLayoutChanged: _selectKeyboardLayout,
                          onStart: _start,
                        ),
                      if (game.phase == _FuturePhase.dead)
                        _FutureDeathOverlay(game: game, onRestart: _start),
                      Positioned(
                        top: 7,
                        left: 8,
                        child: GameExitButton(
                          onExit: () => Navigator.of(context).pop(),
                        ),
                      ),
                      if (_campaignComplete)
                        CampaignMissionClearOverlay(
                          level: widget.level!,
                          score: game.score.floor(),
                          elapsedSeconds: game.time,
                          accent: _futureGold,
                          onNextLevel: _continueCampaign,
                          onExit: () => Navigator.of(context).pop(),
                        ),
                      if (_paused)
                        GamePauseOverlay(
                          gameName: 'FUTURE DEBT',
                          onResume: () => _pause(false),
                          onRestart: () {
                            _start();
                            _pause(false);
                          },
                          onExit: () => Navigator.of(context).pop(),
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
}

class _FutureTopHud extends StatelessWidget {
  const _FutureTopHud({
    required this.game,
    required this.compact,
    required this.onBankruptcy,
  });
  final _FutureDebtGame game;
  final bool compact;
  final VoidCallback onBankruptcy;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 50 : 58,
    padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
    decoration: BoxDecoration(
      color: _futurePanel,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x65FFCD93)),
    ),
    child: Row(
      children: [
        Flexible(
          flex: 3,
          child: _FutureStat(
            label: 'LIFETIME',
            value: '${game.lifetime.clamp(0, 999).toStringAsFixed(1)}s',
            icon: Icons.favorite_rounded,
            meter: game.lifetime / _FutureDebtGame._maximumLifetime,
            color: _futureCoral,
            compact: compact,
          ),
        ),
        Container(
          width: 1,
          height: compact ? 26 : 34,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: const Color(0x72B79185),
        ),
        Flexible(
          flex: 3,
          child: _FutureStat(
            label: 'DEBT',
            value: '${game.debtAmount.toStringAsFixed(1)}s',
            detail: game.formName,
            icon: Icons.schedule_rounded,
            color: game.hasAnyLock ? _futureCoral : _futureGold,
            compact: compact,
          ),
        ),
        Container(
          width: 1,
          height: compact ? 26 : 34,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: const Color(0x72B79185),
        ),
        Expanded(
          flex: 6,
          child: _FutureObjectiveReadout(game: game, compact: compact),
        ),
        if (game.canBankrupt)
          IconButton(
            tooltip: 'Declare bankruptcy',
            onPressed: onBankruptcy,
            color: _futureCoral,
            icon: const Icon(Icons.gavel_rounded, size: 20),
          ),
      ],
    ),
  );
}

class _FutureObjectiveReadout extends StatelessWidget {
  const _FutureObjectiveReadout({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${_ArenaPalette.values[game._plan.act % _ArenaPalette.values.length].label} · ${game.caseTitle}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _futureCream,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w900,
          letterSpacing: compact ? .5 : .8,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '${game.score.floor()} / ${game.scoreTarget}  ·  ${game.objectiveProgress}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: game.objectiveComplete ? _futureMint : _futureGold,
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: (game.score / game.scoreTarget).clamp(0, 1).toDouble(),
          minHeight: compact ? 3 : 4,
          backgroundColor: const Color(0xFF64505A),
          valueColor: AlwaysStoppedAnimation(
            game.objectiveComplete ? _futureMint : _futureGold,
          ),
        ),
      ),
    ],
  );
}

class _FutureStat extends StatelessWidget {
  const _FutureStat({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
    required this.icon,
    this.meter,
    this.detail,
  });
  final String label;
  final String value;
  final String? detail;
  final Color color;
  final IconData icon;
  final double? meter;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFE1BFB0),
          fontSize: compact ? 7 : 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(icon, color: color, size: compact ? 11 : 15),
            const SizedBox(width: 4),
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: _futureCream,
                fontSize: compact ? 14 : 17,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      if (meter case final fill?) ...[
        const SizedBox(height: 4),
        SizedBox(
          width: compact ? 52 : 75,
          child: LinearProgressIndicator(
            minHeight: 3,
            value: fill.clamp(0.0, 1.0),
            color: color,
            backgroundColor: const Color(0xFF654750),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
      if (detail != null)
        Text(
          detail!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _futureGold,
            fontSize: 7,
            height: .8,
            fontWeight: FontWeight.w800,
          ),
        ),
    ],
  );
}

class _MessageStrip extends StatelessWidget {
  const _MessageStrip({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final seized = [
      if (game.isLocked(_DebtKind.move)) 'MOVE',
      if (game.totalDefaultActive) 'FIRE',
      if (game.isLocked(_DebtKind.dash)) 'DASH',
    ];
    final status = game.levelExitOpen
        ? 'EXTRACTION OPEN'
        : seized.isNotEmpty
        ? 'SEIZED ${seized.join(' · ')}'
        : game.currentZone?.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xD22F2630),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status == null ? game.message : '$status  ·  ${game.message}',
        maxLines: compact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: seized.isNotEmpty ? _futureCoral : _futureCream,
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FutureOverlay extends StatelessWidget {
  const _FutureOverlay({
    required this.game,
    required this.pace,
    required this.onPaceChanged,
    required this.keyboardLayout,
    required this.onKeyboardLayoutChanged,
    required this.onStart,
  });
  final _FutureDebtGame game;
  final _FutureDebtPace pace;
  final ValueChanged<_FutureDebtPace> onPaceChanged;
  final _FutureDebtKeyboardLayout keyboardLayout;
  final ValueChanged<_FutureDebtKeyboardLayout> onKeyboardLayoutChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0x66312832),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(560, MediaQuery.sizeOf(context).width - 40),
            maxHeight: math
                .max(0.0, MediaQuery.sizeOf(context).height - 40)
                .toDouble(),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF43C2D39),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x8CFFC685)),
              boxShadow: const [
                BoxShadow(color: Color(0xAA000000), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            _Tag(
                              'CASE ${game._plan.levelNumber.toString().padLeft(2, '0')}',
                            ),
                            _Tag(game._plan.mutator),
                          ],
                        ),
                        const SizedBox(height: 9),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: _futureCream,
                              fontFamily: 'Georgia',
                              fontFamilyFallback: ['Noto Serif', 'serif'],
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .6,
                            ),
                            children: [
                              const TextSpan(text: 'Future '),
                              const TextSpan(
                                text: 'Debt',
                                style: TextStyle(color: _futureGold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          game.caseTitle,
                          style: const TextStyle(
                            color: Color(0xFFE6C36D),
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'The Directorate owns a version of you that has not happened yet. ${game.caseInstruction}',
                          style: TextStyle(
                            color: Color(0xFFBDC8DF),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            _Rule('Move', 'stick / ${keyboardLayout.label}'),
                            _Rule(
                              'Aim',
                              'FIRE stick / ${keyboardLayout.description}',
                            ),
                            const _Rule('Fire', 'hold FIRE / Space'),
                            const _Rule('Dash', 'DASH / Shift'),
                            const _Rule('Ghost Wage', 'by FIRE / 1'),
                            const _Rule('Reverse Payment', 'by FIRE / 3'),
                            const _Rule('Bankruptcy', 'debt gavel / B'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Defeated enemies can drop Compound Fire or Cash Out. Clear your case objective, score target, and outstanding contracts to open extraction.',
                          style: TextStyle(
                            color: Color(0xFF9FACC5),
                            fontSize: 9,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          'RUN PACE — ${pace.label}',
                          style: const TextStyle(
                            color: Color(0xFFE6C36D),
                            fontSize: 8,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final option in _FutureDebtPace.values)
                              ChoiceChip(
                                label: Text(option.label),
                                selected: option == pace,
                                onSelected: (_) => onPaceChanged(option),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pace.description,
                          style: const TextStyle(
                            color: Color(0xFF9FACC5),
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'KEYBOARD LAYOUT',
                          style: const TextStyle(
                            color: Color(0xFFE6C36D),
                            fontSize: 8,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final option
                                in _FutureDebtKeyboardLayout.values)
                              ChoiceChip(
                                label: Text(option.label),
                                selected: option == keyboardLayout,
                                onSelected: (_) =>
                                    onKeyboardLayoutChanged(option),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: _futureGold,
                    foregroundColor: _futureInk,
                  ),
                  child: const Text(
                    'ENTER THE LEDGER',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FutureDeathOverlay extends StatelessWidget {
  const _FutureDeathOverlay({required this.game, required this.onRestart});
  final _FutureDebtGame game;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0x94312832),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 430,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF43C2D39),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF934657)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ledger Closed',
                  style: TextStyle(
                    color: _futureCream,
                    fontFamily: 'Georgia',
                    fontFamilyFallback: ['Noto Serif', 'serif'],
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  game.message,
                  style: const TextStyle(
                    color: _futureCream,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRestart,
                    style: FilledButton.styleFrom(
                      backgroundColor: _futureCoral,
                      foregroundColor: _futureInk,
                    ),
                    child: const Text(
                      'REOPEN THE LEDGER',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF4A5A79)),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Color(0xFFB9C7E2),
        fontSize: 7,
        fontWeight: FontWeight.w800,
        letterSpacing: .7,
      ),
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule(this.keyText, this.value);
  final String keyText;
  final String value;
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Color(0xFFCAD5EB), fontSize: 9),
      children: [
        TextSpan(
          text: '$keyText: ',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        TextSpan(text: value),
      ],
    ),
  );
}
