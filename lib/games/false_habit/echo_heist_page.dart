part of 'echo_heist_game.dart';

class EchoHeistPage extends StatefulWidget {
  const EchoHeistPage({
    super.key,
    this.level,
    this.onLevelComplete,
    this.onNextLevel,
  });

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;
  final VoidCallback? onNextLevel;

  @override
  State<EchoHeistPage> createState() => _EchoHeistPageState();
}

class _EchoHeistPageState extends State<EchoHeistPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameLoopController _loop;
  late final _EchoHeist _heist;
  late final FocusNode _gameFocus;
  final DirectionalInput _movement = DirectionalInput();
  final Set<LogicalKeyboardKey> _pressedActions = {};
  bool _paused = false;
  bool _completionReported = false;
  bool _continuingCampaign = false;
  double _elapsedSeconds = 0;
  int _inputEpoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GamePresentation.enterLandscape();
    _heist = _EchoHeist(
      campaignLevel: widget.level?.number ?? 1,
      campaign: widget.level,
    );
    _gameFocus = FocusNode(debugLabel: 'False Habit controls');
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        final wasPlaying = _heist.phase == _HabitPhase.playing;
        if (wasPlaying) _elapsedSeconds += dt;
        _heist.update(dt, _movement.axis);
        if (wasPlaying && _heist.phase != _HabitPhase.playing) _clearInput();
        _reportCompletion();
      },
      onFrame: () {
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
  }

  void _clearInput() {
    _movement.reset();
    _pressedActions.clear();
    _inputEpoch++;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (_movement.handleKey(event)) {
      setState(() {});
      return KeyEventResult.handled;
    }
    final key = event.logicalKey;
    if (!_actionKeys.contains(key)) return KeyEventResult.ignored;
    final freshPress = event is KeyDownEvent && _pressedActions.add(key);
    if (event is KeyUpEvent) _pressedActions.remove(key);
    if (freshPress &&
        (key == LogicalKeyboardKey.keyE || key == LogicalKeyboardKey.space)) {
      _heist.deployEcho();
    } else if (freshPress && key == LogicalKeyboardKey.escape) {
      _setPaused(!_paused);
    }
    setState(() {});
    return KeyEventResult.handled;
  }

  static final Set<LogicalKeyboardKey> _actionKeys = {
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.escape,
  };

  void _setPaused(bool value) {
    _paused = value;
    _clearInput();
    _loop.setPaused(value);
    if (!value) _gameFocus.requestFocus();
  }

  void _startRun() {
    _clearInput();
    _completionReported = false;
    _elapsedSeconds = 0;
    _heist.start();
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_completionReported ||
        level == null ||
        _heist.phase != _HabitPhase.escaped) {
      return;
    }
    _completionReported = true;
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _heist.score,
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

  void _exitGame() {
    _clearInput();
    _loop.setPaused(true);
    Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _clearInput();
    if (!_paused && _heist.phase == _HabitPhase.playing) {
      _loop.setPaused(true);
      if (mounted) setState(() => _paused = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameFocus.dispose();
    _loop.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heist = _heist;
    return Scaffold(
      body: Focus(
        focusNode: _gameFocus,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        onFocusChange: (focused) {
          if (!focused) _clearInput();
        },
        child: ColoredBox(
          color: const Color(0xFF030408),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 500;
                final actionSize = compact ? 62.0 : 74.0;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          key: const ValueKey('false-habit-playfield'),
                          painter: _HeistPainter(heist),
                        ),
                      ),
                    ),
                    if (heist.phase == _HabitPhase.playing)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GamePauseButton(
                          onTap: () => setState(() => _setPaused(true)),
                        ),
                      ),
                    Positioned(
                      top: compact ? 66 : 72,
                      left: 12,
                      child: IgnorePointer(
                        child: _HabitHud(heist: heist, compact: compact),
                      ),
                    ),
                    if (heist.phase == _HabitPhase.playing) ...[
                      Positioned(
                        left: compact ? 12 : 18,
                        bottom: compact ? 12 : 18,
                        child: TouchStick(
                          key: ValueKey(_inputEpoch),
                          size: compact ? 90 : 108,
                          onChanged: (value) =>
                              setState(() => _movement.setAnalog(value)),
                        ),
                      ),
                      Positioned(
                        right: compact ? 12 : 18,
                        bottom: compact ? 12 : 18,
                        child: TapGameButton(
                          label: heist.echoReady ? 'ECHO' : 'CHARGE',
                          icon: Icons.auto_awesome_rounded,
                          color: heist.echoReady
                              ? const Color(0xFF9AB8FF)
                              : const Color(0xFF69789A),
                          width: actionSize,
                          onTap: () => setState(heist.deployEcho),
                        ),
                      ),
                    ],
                    if (heist.phase == _HabitPhase.intro)
                      _HabitOverlay(
                        eyebrow: 'REWIRE HEIST',
                        title: 'FALSE HABIT',
                        copy:
                            'The archive is larger than your camera. Steal Truth Fragments, then return to the Breach. Every doorway you repeat teaches the Warden a direction. When it reads you, the nearest rooms fold into a predicted door and an unexpected door: take the unexpected door to fracture its model. Cast an Echo after a long route to make the next fold happen somewhere else.',
                        controls:
                            'WASD / ARROWS  MOVE    ·    E / SPACE  CAST ECHO    ·    ESC  PAUSE',
                        button: 'ENTER THE ARCHIVE',
                        onTap: _startRun,
                      ),
                    if (heist.phase == _HabitPhase.caught)
                      _HabitOverlay(
                        eyebrow: 'MODEL COMPLETE',
                        title: 'HABIT CAPTURED',
                        copy:
                            'The Warden used your familiar door choice to close the archive around you. Build a route, then take the wrong door when READ appears. Heat is pressure, not a timer: break the model to cool it.',
                        controls: 'ECHOES REDIRECT A FOLD AFTER A LONG ROUTE.',
                        button: 'REWRITE THE RUN',
                        danger: true,
                        onTap: _startRun,
                      ),
                    if (heist.phase == _HabitPhase.escaped)
                      if (widget.level != null)
                        CampaignMissionClearOverlay(
                          level: widget.level!,
                          score: heist.score,
                          elapsedSeconds: _elapsedSeconds,
                          accent: const Color(0xFFFF8AC6),
                          onNextLevel: _continueCampaign,
                          onExit: _exitGame,
                        )
                      else
                        _HabitOverlay(
                          eyebrow: 'THE ARCHIVE REMEMBERS',
                          title: 'BREACH COMPLETE',
                          copy:
                              'You stole ${heist.stolen} Truth Fragments, fractured ${heist.breakChain} read${heist.breakChain == 1 ? '' : 's'}, and escaped before the Warden could make your route permanent.',
                          controls: 'THE NEXT RUN REMIXES THE ARCHIVE PATHS.',
                          button: 'RUN ANOTHER HEIST',
                          onTap: _startRun,
                        ),
                    if (!_paused)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: GameExitButton(onExit: _exitGame),
                      ),
                    if (_paused)
                      GamePauseOverlay(
                        gameName: 'FALSE HABIT',
                        onResume: () => setState(() => _setPaused(false)),
                        onRestart: () => setState(() {
                          _setPaused(false);
                          _startRun();
                        }),
                        onExit: _exitGame,
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

class _HabitHud extends StatelessWidget {
  const _HabitHud({required this.heist, required this.compact});

  final _EchoHeist heist;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final heat = (heist.heat / 100).clamp(0.0, 1.0);
    return Container(
      width: compact ? 198 : 236,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xD9080B16),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: heist.wardenReading
              ? const Color(0xFFFF6EAB)
              : const Color(0xFF6576A6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FALSE HABIT · ARCHIVE ${heist.rooms.length}',
            style: TextStyle(
              color: const Color(0xFFC8D3FF),
              fontSize: compact ? 7 : 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .65,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            heist.objectiveReadout,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: heist.exitOpen
                  ? const Color(0xFF7FF3BE)
                  : const Color(0xFFFFE29A),
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _HabitMetric(
                  label: 'WARDEN',
                  value: heist.wardenStateReadout,
                  color: heist.wardenReading
                      ? const Color(0xFFFF87BD)
                      : const Color(0xFF9BB9FF),
                ),
              ),
              const SizedBox(width: 8),
              _HabitMetric(
                label: 'FRACTURE',
                value: '×${heist.breakChain}',
                color: const Color(0xFFFFD96C),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: compact ? 42 : 50,
                child: Text(
                  'HEAT ${heist.heat.round()}%',
                  style: TextStyle(
                    color: const Color(0xFFE4BDCF),
                    fontSize: compact ? 7 : 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: heat,
                    minHeight: compact ? 5 : 6,
                    backgroundColor: const Color(0xFF20243B),
                    valueColor: AlwaysStoppedAnimation(
                      Color.lerp(
                        const Color(0xFF70C9FF),
                        const Color(0xFFFF547F),
                        heat,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            heist.message,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFB6C2DF),
              fontSize: compact ? 7 : 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            heist.controlHint,
            style: TextStyle(
              color: heist.echoReady
                  ? const Color(0xFFAAC2FF)
                  : const Color(0xFF7481A5),
              fontSize: compact ? 7 : 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitMetric extends StatelessWidget {
  const _HabitMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Color(0xFF8190B5),
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: .45,
        ),
      ),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _HabitOverlay extends StatelessWidget {
  const _HabitOverlay({
    required this.eyebrow,
    required this.title,
    required this.copy,
    required this.controls,
    required this.button,
    required this.onTap,
    this.danger = false,
  });

  final String eyebrow;
  final String title;
  final String copy;
  final String controls;
  final String button;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xD904050A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 500;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: constraints.maxHeight - (compact ? 16 : 32),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 8 : 16),
                child: Container(
                  padding: EdgeInsets.all(compact ? 12 : 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101429),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: danger
                          ? const Color(0xFFFF668B)
                          : const Color(0xFF8DA7FF),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: TextStyle(
                          color: danger
                              ? const Color(0xFFFF8CA7)
                              : const Color(0xFFAFBEFF),
                          fontSize: compact ? 7 : 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.35,
                        ),
                      ),
                      SizedBox(height: compact ? 3 : 5),
                      Text(
                        title,
                        style: TextStyle(
                          color: danger
                              ? const Color(0xFFFFA5B9)
                              : Colors.white,
                          fontSize: compact ? 23 : 29,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: compact ? 7 : 12),
                      Text(
                        copy,
                        style: TextStyle(
                          color: Color(0xFFC0C9E4),
                          fontSize: compact ? 11 : 13,
                          height: compact ? 1.25 : 1.38,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(compact ? 7 : 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191F39),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          controls,
                          style: TextStyle(
                            color: Color(0xFFB6C7FF),
                            fontSize: compact ? 7 : 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .45,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onTap,
                          icon: Icon(
                            danger
                                ? Icons.restart_alt_rounded
                                : Icons.account_tree_rounded,
                          ),
                          label: Text(button),
                          style: FilledButton.styleFrom(
                            backgroundColor: danger
                                ? const Color(0xFFC94368)
                                : const Color(0xFF697FE8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: compact ? 9 : 13,
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
        },
      ),
    ),
  );
}
