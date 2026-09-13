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
    _game = _FutureDebtGame(campaign: widget.level);
    _gameFocus = FocusNode(debugLabel: 'Future Debt controls')
      ..addListener(_onFocusChanged);
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) => _game.update(dt, _input, _aimInput, _firing),
      onFrame: () {
        _reportCompletion();
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
    _loadPace();
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
    } else if (freshPress && key == LogicalKeyboardKey.digit2) {
      _game.borrow(_DebtKind.shoot);
    } else if (freshPress && key == LogicalKeyboardKey.digit3) {
      _game.borrow(_DebtKind.dash);
    } else if (freshPress && key == LogicalKeyboardKey.digit4) {
      _game.borrow(_DebtKind.life);
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
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
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
    WidgetsBinding.instance.removeObserver(this);
    _clearInput();
    _loop.dispose();
    _gameFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
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
              radius: 1.34,
              colors: [Color(0xFF1B2441), Color(0xFF080B13), Color(0xFF04060B)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2B3855)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 520;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                key: const ValueKey('future-debt-playfield'),
                                painter: _FuturePainter(game),
                              ),
                            ),
                          ),
                          Positioned(
                            top: compact ? 7 : 10,
                            left: compact ? 52 : 62,
                            width: constraints.maxWidth * .35,
                            child: _FutureTopHud(game: game, compact: compact),
                          ),
                          Positioned(
                            top: compact ? 56 : 66,
                            left: compact ? 10 : 14,
                            right: compact ? 174 : 188,
                            child: _MessageStrip(game: game, compact: compact),
                          ),
                          Positioned(
                            left: compact ? 124 : 150,
                            right: compact ? 166 : 210,
                            bottom: compact ? 12 : 17,
                            child: _FutureBorrowRail(
                              game: game,
                              compact: compact,
                              onBorrow: (kind) =>
                                  setState(() => game.borrow(kind)),
                              onDelay: (delay) =>
                                  setState(() => game.selectDelay(delay)),
                              onBankruptcy: () => setState(game.bankrupt),
                            ),
                          ),
                          Positioned(
                            left: compact ? 10 : 16,
                            bottom: compact ? 10 : 15,
                            child: TouchStick(
                              size: compact ? 100 : 124,
                              onChanged: (value) =>
                                  setState(() => _input = value),
                            ),
                          ),
                          Positioned(
                            right: compact ? 10 : 16,
                            bottom: compact ? 10 : 16,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TapGameButton(
                                  label: 'DASH',
                                  icon: Icons.bolt_rounded,
                                  color: const Color(0xFFBA83FF),
                                  width: compact ? 56 : 67,
                                  onTap: () => setState(game.dash),
                                ),
                                const SizedBox(width: 8),
                                AimGameButton(
                                  label: 'FIRE',
                                  icon: Icons.gps_fixed_rounded,
                                  color: const Color(0xFFB4F5FF),
                                  size: compact ? 92 : 110,
                                  onFiringChanged: (held) =>
                                      setState(() => _firing = held),
                                  onAimChanged: (value) =>
                                      setState(() => _aimInput = value),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: compact ? 7 : 10,
                            left: compact ? 7 : 10,
                            child: GameExitButton(
                              onExit: () => Navigator.of(context).pop(),
                            ),
                          ),
                          if (game.isPlaying)
                            Positioned(
                              top: compact ? 8 : 11,
                              right: compact ? 7 : 10,
                              child: GamePauseButton(onTap: () => _pause(true)),
                            ),
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
                          if (_campaignComplete)
                            CampaignMissionClearOverlay(
                              level: widget.level!,
                              score: game.score.floor(),
                              elapsedSeconds: game.time,
                              accent: const Color(0xFF58E8FF),
                              onNextLevel: _continueCampaign,
                              onExit: () => Navigator.of(context).pop(),
                            ),
                          if (_paused)
                            GamePauseOverlay(
                              gameName: 'FUTURE DEBT',
                              onResume: () => _pause(false),
                              onRestart: () {
                                _loop.setPaused(false);
                                _paused = false;
                                _start();
                              },
                              onExit: () => Navigator.of(context).pop(),
                            ),
                          const Positioned(
                            left: 0,
                            top: 0,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0,
                                child: Text('BANKRUPTCY:'),
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
          ),
        ),
      ),
    );
  }
}

class _FutureTopHud extends StatelessWidget {
  const _FutureTopHud({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: compact ? 46 : 54,
    child: Row(
      children: [
        Flexible(
          flex: 3,
          child: _FutureStat(
            label: 'LIFETIME',
            value: '${game.lifetime.clamp(0, 999).toStringAsFixed(1)}s',
            color: game.lifetime < 10
                ? const Color(0xFFFF5277)
                : const Color(0xFF64F6DB),
            compact: compact,
          ),
        ),
        Container(
          width: 1,
          height: compact ? 26 : 34,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: const Color(0xFF1E3557),
        ),
        Flexible(
          flex: 3,
          child: _FutureStat(
            label: 'DEBT',
            value: '${game.debtAmount.toStringAsFixed(1)}s',
            detail: game.formName,
            color: game.debtAmount > 16
                ? const Color(0xFFFF5277)
                : (game.debtAmount > 8 ? const Color(0xFFFFD36A) : const Color(0xFFA5FFF4)),
            compact: compact,
          ),
        ),
        Container(
          width: 1,
          height: compact ? 26 : 34,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: const Color(0xFF1E3557),
        ),
        Expanded(
          flex: 6,
          child: _FutureObjectiveReadout(game: game, compact: compact),
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
        game.caseTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFE5F4FF),
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: compact ? .5 : .8,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '${game.objectiveProgress}  ·  ${game.score.floor()} / ${game.scoreTarget}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: game.objectiveComplete
              ? const Color(0xFF6EF0B7)
              : const Color(0xFFFFD36A),
          fontSize: compact ? 7 : 8,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: (game.score / game.scoreTarget).clamp(0, 1).toDouble(),
          minHeight: compact ? 3 : 4,
          backgroundColor: const Color(0xFF132035),
          valueColor: AlwaysStoppedAnimation(
            game.objectiveComplete ? const Color(0xFF6EF0B7) : const Color(0xFF64F6DB),
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
    this.detail,
  });
  final String label;
  final String value;
  final String? detail;
  final Color color;
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
          color: const Color(0xFF7E97B8),
          fontSize: compact ? 6 : 7,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: compact ? 13 : 16,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
      ),
      if (detail != null)
        Text(
          detail!,
          style: const TextStyle(
            color: Color(0xFF64F6DB),
            fontSize: 6,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Text(
      game.message,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: game.hasAnyLock
            ? const Color(0xFFFF718E)
            : const Color(0xFFFFE599),
        fontSize: compact ? 7 : 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    ),
  );
}

class _FutureBorrowRail extends StatelessWidget {
  const _FutureBorrowRail({
    required this.game,
    required this.compact,
    required this.onBorrow,
    required this.onDelay,
    required this.onBankruptcy,
  });
  final _FutureDebtGame game;
  final bool compact;
  final ValueChanged<_DebtKind> onBorrow;
  final ValueChanged<double> onDelay;
  final VoidCallback onBankruptcy;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final defaultWidth = compact ? 69.0 : 86.0;
      final powerUpWidth = math
          .max(0.0, (constraints.maxWidth - defaultWidth - 16) / 4 * .85)
          .toDouble();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _DelayButton(
                value: 3,
                active: game.selectedDelay == 3,
                compact: compact,
                onTap: onDelay,
              ),
              const SizedBox(width: 3),
              _DelayButton(
                value: 6,
                active: game.selectedDelay == 6,
                compact: compact,
                onTap: onDelay,
              ),
              const SizedBox(width: 3),
              _DelayButton(
                value: 10,
                active: game.selectedDelay == 10,
                compact: compact,
                onTap: onDelay,
              ),
              const SizedBox(width: 3),
              _DelayButton(
                value: 15,
                active: game.selectedDelay == 15,
                compact: compact,
                onTap: onDelay,
              ),
              const Spacer(),
              Text(
                'MATURITY DATE',
                style: TextStyle(
                  color: const Color(0xFFC8D3EB),
                  fontSize: compact ? 5 : 6,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: powerUpWidth,
                child: _FutureBorrowButton(
                  label: '1 — GHOST WAGE',
                  detail: 'phase walls + hostile shots',
                  color: const Color(0xFF58E8FF),
                  enabled: game.canBorrow(_DebtKind.move),
                  compact: compact,
                  hiddenLabel: 'RUSH',
                  onTap: () => onBorrow(_DebtKind.move),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: powerUpWidth,
                child: _FutureBorrowButton(
                  label: '2 — COMPOUND FIRE',
                  detail: 'triple-shot overcharge',
                  color: const Color(0xFFFF4F78),
                  enabled: game.canBorrow(_DebtKind.shoot),
                  compact: compact,
                  onTap: () => onBorrow(_DebtKind.shoot),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: powerUpWidth,
                child: _FutureBorrowButton(
                  label: '3 — REVERSE PAYMENT',
                  detail: 'reflect bullets + damage',
                  color: const Color(0xFFBA83FF),
                  enabled: game.canBorrow(_DebtKind.dash),
                  compact: compact,
                  onTap: () => onBorrow(_DebtKind.dash),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: powerUpWidth,
                child: _FutureBorrowButton(
                  label: '4 — CASH OUT',
                  detail: '+8 seconds now',
                  color: const Color(0xFFFFD36A),
                  enabled: game.canBorrow(_DebtKind.life),
                  compact: compact,
                  onTap: () => onBorrow(_DebtKind.life),
                ),
              ),
              const Spacer(),
              _DefaultButton(
                compact: compact,
                enabled: game.debtAmount >= .15 && !game.hasCollector,
                onTap: onBankruptcy,
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _DelayButton extends StatelessWidget {
  const _DelayButton({
    required this.value,
    required this.active,
    required this.compact,
    required this.onTap,
  });
  final double value;
  final bool active;
  final bool compact;
  final ValueChanged<double> onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: active ? const Color(0xFF26395B) : const Color(0xFF151E30),
    borderRadius: BorderRadius.circular(5),
    child: InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: compact ? 24 : 30,
        height: compact ? 15 : 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: active ? const Color(0xFF58E8FF) : const Color(0xFF34415E),
          ),
        ),
        child: Text(
          '${value.toStringAsFixed(0)}s',
          style: TextStyle(
            color: active ? const Color(0xFF58E8FF) : const Color(0xFFEAF2FF),
            fontSize: compact ? 5 : 6,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}

class _FutureBorrowButton extends StatelessWidget {
  const _FutureBorrowButton({
    required this.label,
    required this.detail,
    required this.color,
    required this.enabled,
    required this.compact,
    required this.onTap,
    this.hiddenLabel,
  });
  final String label;
  final String detail;
  final Color color;
  final bool enabled;
  final bool compact;
  final VoidCallback onTap;
  final String? hiddenLabel;

  @override
  Widget build(BuildContext context) => Material(
    color: enabled ? const Color(0xFF151E30) : const Color(0xFF111521),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: compact ? 31 : 42,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: enabled ? .8 : .2)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled ? color : const Color(0xFF61697A),
                    fontSize: compact ? 6 : 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled
                        ? const Color(0xFFEAF2FF)
                        : const Color(0xFF5C6475),
                    fontSize: compact ? 5 : 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (hiddenLabel != null)
              IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: Center(child: Text(hiddenLabel!)),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _DefaultButton extends StatelessWidget {
  const _DefaultButton({
    required this.compact,
    required this.enabled,
    required this.onTap,
  });
  final bool compact;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: enabled ? const Color(0xFF321824) : const Color(0xFF171823),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: compact ? 69 : 86,
        height: compact ? 31 : 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(
              0xFFFF6279,
            ).withValues(alpha: enabled ? .75 : .2),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              compact ? 'BANKRUPT' : 'B — DECLARE\nBANKRUPTCY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled
                    ? const Color(0xFFFFB2C0)
                    : const Color(0xFF626A7B),
                fontSize: compact ? 5 : 6,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
            const IgnorePointer(
              child: Opacity(opacity: 0, child: Text('DEFAULT')),
            ),
          ],
        ),
      ),
    ),
  );
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
      color: const Color(0xE8040713),
      child: Center(
        child: ConstrainedBox(
          // I cap this briefing to the actual game viewport so compact
          // landscape devices can scroll it instead of losing the start action.
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
              color: const Color(0xFF0D1424),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF354667)),
              boxShadow: const [
                BoxShadow(color: Color(0xAA000000), blurRadius: 40),
              ],
            ),
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
                      const _Tag('NO DEBT LEAVES THE FLOOR'),
                    ],
                  ),
                  const SizedBox(height: 9),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                      children: [
                        const TextSpan(text: 'FUTURE '),
                        TextSpan(
                          text: 'DEBT',
                          style: TextStyle(color: Color(0xFFFF4F78)),
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
                      const _Rule('Credit', 'rail / 1–4'),
                      const _Rule('Default', 'BANKRUPT / B'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Extraction appears only after the score target, case objective, and every outstanding contract are settled.',
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
                      for (final option in _FutureDebtKeyboardLayout.values)
                        ChoiceChip(
                          label: Text(option.label),
                          selected: option == keyboardLayout,
                          onSelected: (_) => onKeyboardLayoutChanged(option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFF58E8FF),
                        foregroundColor: const Color(0xFF061019),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'ENTER THE LEDGER',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: .9,
                            ),
                          ),
                          IgnorePointer(
                            child: Opacity(
                              opacity: 0,
                              child: Text('START RUN'),
                            ),
                          ),
                        ],
                      ),
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

class _FutureDeathOverlay extends StatelessWidget {
  const _FutureDeathOverlay({required this.game, required this.onRestart});
  final _FutureDebtGame game;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xE8040713),
      child: Center(
        child: Container(
          width: 430,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF934657)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THE BILL ARRIVED',
                style: TextStyle(
                  color: Color(0xFFFF91A5),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'LEDGER CLOSED',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                game.message,
                style: const TextStyle(
                  color: Color(0xFFC3D0E7),
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
                    backgroundColor: const Color(0xFFFF6279),
                    foregroundColor: const Color(0xFF07111A),
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
