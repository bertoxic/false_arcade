part of 'not_yet_game.dart';

class RealityGamePage extends StatefulWidget {
  const RealityGamePage({
    super.key,
    this.level,
    this.onLevelComplete,
    this.onNextLevel,
  });

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;
  final VoidCallback? onNextLevel;

  @override
  State<RealityGamePage> createState() => _RealityGamePageState();
}

class _RealityGamePageState extends State<RealityGamePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameLoopController _loop;
  late final FocusNode _gameFocus;
  late final RealityGame _game;
  final _movement = DirectionalInput();
  bool _firing = false;
  bool _paused = false;
  bool _completionReported = false;
  bool _continuingCampaign = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GamePresentation.enterLandscape();
    _game = RealityGame(
      campaignLevel: widget.level?.number ?? 1,
      random: math.Random(widget.level?.seed),
      campaign: widget.level,
    );
    _gameFocus = FocusNode(debugLabel: 'Not Yet controls');
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        _game.step(dt, _movement.axis, _firing);
        _reportCompletion();
      },
      onFrame: () {
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearInput();
    _loop.dispose();
    _gameFocus.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  void _setPaused(bool value) {
    _clearInput();
    _paused = value;
    _loop.setPaused(value);
    if (!value) _gameFocus.requestFocus();
  }

  void _clearInput() {
    _movement.reset();
    _firing = false;
    _game.setHolding(false);
  }

  void _setMove(Offset value) => setState(() => _movement.setAnalog(value));

  void _setFire(bool value) => setState(() => _firing = value);

  void _setNotYet(bool value) {
    setState(() => _game.setHolding(value));
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_completionReported ||
        level == null ||
        (_game.phase != GamePhase.levelClear &&
            _game.phase != GamePhase.victory)) {
      return;
    }
    _completionReported = true;
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _game.score,
        elapsedSeconds: _game.elapsedSeconds,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _clearInput();
    if (!_paused &&
        (_game.phase == GamePhase.playing ||
            _game.phase == GamePhase.settling)) {
      _loop.setPaused(true);
      if (mounted) setState(() => _paused = true);
    }
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

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (_movement.handleKey(event)) {
      setState(() {});
      return KeyEventResult.handled;
    }
    final down = event is! KeyUpEvent;
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_firing != down) _setFire(down);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight ||
        event.logicalKey == LogicalKeyboardKey.keyE) {
      if (_game.holding != down) _setNotYet(down);
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _setPaused(!_paused));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Focus(
      focusNode: _gameFocus,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      onFocusChange: (focused) {
        if (!focused) {
          _movement.reset();
          _firing = false;
          _game.setHolding(false);
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.3),
              radius: 1.35,
              colors: [Color(0xFF1B2943), Color(0xFF070A11), Color(0xFF030408)],
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
                      child: _TopHud(game: game, compact: compact),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
                        child: Center(
                          child: SizedBox.expand(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF405177),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x99000000),
                                      blurRadius: 34,
                                      offset: Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        key: const ValueKey(
                                          'not-yet-playfield',
                                        ),
                                        painter: GamePainter(game),
                                      ),
                                    ),
                                    Positioned(
                                      top: 60,
                                      left: 12,
                                      right: 170,
                                      child: IgnorePointer(
                                        child: _RealityArenaHud(game: game),
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
                                    if (game.phase == GamePhase.playing ||
                                        game.phase == GamePhase.settling)
                                      Positioned(
                                        top: 12,
                                        right: 15,
                                        child: GamePauseButton(
                                          onTap: () =>
                                              setState(() => _setPaused(true)),
                                        ),
                                      ),
                                    Positioned(
                                      left: compact ? 12 : 18,
                                      bottom: compact ? 10 : 18,
                                      child: _Joystick(onChanged: _setMove),
                                    ),
                                    Positioned(
                                      right: compact ? 12 : 18,
                                      bottom: compact ? 10 : 18,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          _ActionButton(
                                            label: 'NOT\nYET',
                                            icon: Icons.hourglass_top_rounded,
                                            color: const Color(0xFFE94D79),
                                            active: game.holding,
                                            diameter: compact ? 74 : 84,
                                            onChanged: _setNotYet,
                                          ),
                                          SizedBox(width: compact ? 10 : 14),
                                          _ActionButton(
                                            label: 'FIRE',
                                            icon: Icons.gps_fixed_rounded,
                                            color: const Color(0xFF4ADCF2),
                                            diameter: compact ? 68 : 78,
                                            onChanged: _setFire,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 57,
                                      right: 15,
                                      child: _DebtChip(game: game),
                                    ),
                                    if (game.phase == GamePhase.settling)
                                      const Positioned.fill(
                                        child: _SettlementBanner(),
                                      ),
                                    if (game.phase == GamePhase.title)
                                      _StartOverlay(onTap: game.startRun)
                                    else if (game.phase == GamePhase.levelClear)
                                      if (widget.level != null)
                                        CampaignMissionClearOverlay(
                                          level: widget.level!,
                                          score: game.score,
                                          elapsedSeconds: game.time,
                                          accent: const Color(0xFFE94D79),
                                          onNextLevel: _continueCampaign,
                                          onExit: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      else
                                        _LevelClearOverlay(
                                          game: game,
                                          onTap: game.nextLevel,
                                        )
                                    else if (game.phase == GamePhase.gameOver)
                                      _GameOverOverlay(
                                        game: game,
                                        onTap: game.startRun,
                                      )
                                    else if (game.phase == GamePhase.victory)
                                      if (widget.level != null)
                                        CampaignMissionClearOverlay(
                                          level: widget.level!,
                                          score: game.score,
                                          elapsedSeconds: game.time,
                                          accent: const Color(0xFFE94D79),
                                          onNextLevel: _continueCampaign,
                                          onExit: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      else
                                        _VictoryOverlay(
                                          game: game,
                                          onTap: game.startRun,
                                        ),
                                    if (_paused)
                                      GamePauseOverlay(
                                        gameName: 'NOT YET',
                                        onResume: () =>
                                            setState(() => _setPaused(false)),
                                        onRestart: () => setState(() {
                                          _setPaused(false);
                                          game.startRun();
                                        }),
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
                      child: _BottomHud(game: game, compact: compact),
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

class _TopHud extends StatelessWidget {
  const _TopHud({required this.game, required this.compact});

  final RealityGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hpFraction = game.hitPoints / RealityGame.maxHitPoints;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 7 : 12, 16, 0),
      child: Row(
        children: [
          if (!compact) ...[
            const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 25),
            const SizedBox(width: 6),
            const Text(
              'NOT YET',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 16),
          ],
          _StatChip(
            icon: Icons.favorite_rounded,
            label:
                '${game.hitPoints.clamp(0, RealityGame.maxHitPoints)} / ${RealityGame.maxHitPoints}',
            valueColor: hpFraction > .4
                ? const Color(0xFF79F2BE)
                : const Color(0xFFFF6386),
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.stars_rounded,
            label: game.score.toString().padLeft(5, '0'),
            valueColor: const Color(0xFFFFD166),
          ),
          const Spacer(),
          Text(
            'SECTOR ${game.levelIndex + 1}  •  ${game.level.title.toUpperCase()}',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: const Color(0xFFC9D5F3),
              fontWeight: FontWeight.w800,
              fontSize: compact ? 10 : 12,
              letterSpacing: compact ? .5 : 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealityArenaHud extends StatelessWidget {
  const _RealityArenaHud({required this.game});

  final RealityGame game;

  @override
  Widget build(BuildContext context) {
    final hpFraction = game.hitPoints / RealityGame.maxHitPoints;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.favorite_rounded,
            label:
                '${game.hitPoints.clamp(0, RealityGame.maxHitPoints)} / ${RealityGame.maxHitPoints}',
            valueColor: hpFraction > .4
                ? const Color(0xFF79F2BE)
                : const Color(0xFFFF6386),
          ),
          const SizedBox(width: 6),
          _StatChip(
            icon: Icons.stars_rounded,
            label: game.score.toString().padLeft(5, '0'),
            valueColor: const Color(0xFFFFD166),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'PURGE ${game.defeated}/${game.level.goal}   ·   CHAIN ×${game.chain.toStringAsFixed(1)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFC9D5F3),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111829),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF2E3C5B)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: valueColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({required this.game, required this.compact});

  final RealityGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final progress = game.level.goal == 0
        ? 0.0
        : game.defeated / game.level.goal;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, compact ? 7 : 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PURGE ${game.defeated}/${game.level.goal}',
                      style: TextStyle(
                        color: const Color(0xFFBAC7E2),
                        fontSize: compact ? 9 : 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CHAIN ×${game.chain.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: const Color(0xFFB993FF),
                        fontSize: compact ? 9 : 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (game.powerupLabel.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        game.powerupLabel,
                        style: TextStyle(
                          color: const Color(0xFF8DDCFF),
                          fontSize: compact ? 8 : 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: compact ? 5 : 7,
                    value: progress.clamp(0.0, 1.0),
                    color: const Color(0xFF8D73FF),
                    backgroundColor: const Color(0xFF182033),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 11 : 17),
          Text(
            game.statusText,
            style: TextStyle(
              color: game.holding
                  ? const Color(0xFFFF80A0)
                  : const Color(0xFF91A1C0),
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtChip extends StatelessWidget {
  const _DebtChip({required this.game});

  final RealityGame game;

  @override
  Widget build(BuildContext context) {
    final debtPercent = (game.debt / RealityGame.maxDebt * 100).round();
    return Container(
      width: 142,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xDD0C1120),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: game.holding
              ? const Color(0xFFAD496A)
              : const Color(0xFF34425F),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_bottom_rounded,
                color: game.holding
                    ? const Color(0xFFFF698D)
                    : const Color(0xFF94A4C4),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                game.holding ? 'PAUSED' : 'DEBT',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: game.debt / RealityGame.maxDebt,
              backgroundColor: const Color(0xFF202940),
              color: game.debt > 80
                  ? const Color(0xFFFF5A7E)
                  : const Color(0xFF65DDF3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$debtPercent%  ·  ×${game.payoutMultiplier.toStringAsFixed(1)} payout',
            style: const TextStyle(
              color: Color(0xFFC7D3EF),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Joystick extends StatefulWidget {
  const _Joystick({required this.onChanged});

  final ValueChanged<Offset> onChanged;

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  int? _pointer;
  Offset _knob = Offset.zero;
  static const _size = 104.0;

  void _update(PointerEvent event) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(event.position);
    final raw = local - const Offset(_size / 2, _size / 2);
    final capped = raw.distance > 37 ? raw / raw.distance * 37 : raw;
    setState(() => _knob = capped);
    widget.onChanged(capped / 37);
  }

  void _release(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _knob = Offset.zero);
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (_pointer != null) return;
        _pointer = event.pointer;
        _update(event);
      },
      onPointerMove: (event) {
        if (event.pointer == _pointer) _update(event);
      },
      onPointerUp: _release,
      onPointerCancel: _release,
      child: SizedBox(
        height: _size,
        width: _size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x55121A2B),
            border: Border.all(color: const Color(0x776F86AA), width: 1.5),
          ),
          child: Center(
            child: Transform.translate(
              offset: _knob,
              child: Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF60799E), Color(0xFF1B2940)],
                  ),
                  border: Border.all(color: const Color(0xFF9FB2D0)),
                ),
                child: const Icon(
                  Icons.control_camera_rounded,
                  size: 21,
                  color: Color(0xFFE2EDFF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.diameter,
    required this.onChanged,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double diameter;
  final ValueChanged<bool> onChanged;
  final bool active;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  int? _pointer;
  bool _down = false;

  void _release(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _down = false);
    widget.onChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _down || widget.active;
    return Listener(
      onPointerDown: (event) {
        if (_pointer != null) return;
        _pointer = event.pointer;
        setState(() => _down = true);
        widget.onChanged(true);
      },
      onPointerUp: _release,
      onPointerCancel: _release,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: widget.diameter,
        width: widget.diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pressed
              ? widget.color.withValues(alpha: .73)
              : const Color(0xCC101829),
          border: Border.all(
            color: pressed ? widget.color : widget.color.withValues(alpha: .55),
            width: 2,
          ),
          boxShadow: pressed
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: .42),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: widget.diameter * .27),
            const SizedBox(height: 2),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: widget.label.contains('\n') ? 9 : 10,
                height: .95,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartOverlay extends StatelessWidget {
  const _StartOverlay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      eyebrow: 'A TOP-DOWN REALITY ROGUELITE',
      title: 'NOT YET',
      description:
          'Hold NOT YET to defer consequences, then release the stack newest-first. Higher debt pays more, but interest eventually forces a margin call.',
      facts: const [
        _OverlayFact(Icons.gamepad_rounded, 'Move', 'stick / WASD'),
        _OverlayFact(Icons.gps_fixed_rounded, 'Auto-aim', 'FIRE / Space'),
        _OverlayFact(Icons.hourglass_top_rounded, 'Defer', 'NOT YET / Shift'),
      ],
      buttonLabel: 'ENTER THE BREACH',
      onTap: onTap,
    );
  }
}

class _LevelClearOverlay extends StatelessWidget {
  const _LevelClearOverlay({required this.game, required this.onTap});

  final RealityGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      eyebrow: 'SECTOR CLEARED  •  +${game.lastClearBonus} SCORE',
      title: 'BREACH OPEN',
      description: game.levelIndex + 1 == RealityGame.levels.length
          ? 'The final sector is silent. Close the breach while reality is still listening.'
          : 'The next sector brings faster enemies and a deeper debt ceiling.',
      facts: [
        _OverlayFact(Icons.stars_rounded, 'Score', '${game.score}'),
        _OverlayFact(
          Icons.local_fire_department_rounded,
          'Chain',
          '×${game.chain.toStringAsFixed(1)}',
        ),
        _OverlayFact(
          Icons.shield_rounded,
          'Hull',
          '${game.hitPoints}/${RealityGame.maxHitPoints}',
        ),
      ],
      buttonLabel: game.levelIndex + 1 == RealityGame.levels.length
          ? 'CLOSE THE BREACH'
          : 'NEXT SECTOR',
      onTap: onTap,
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.game, required this.onTap});

  final RealityGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      eyebrow: 'REALITY HAS CAUGHT UP',
      title: 'SETTLED.',
      description:
          'Your final stack could not be paid. Queue healing late so it resolves before the damage beneath it.',
      facts: [
        _OverlayFact(Icons.stars_rounded, 'Score', '${game.score}'),
        _OverlayFact(Icons.map_rounded, 'Sector', '${game.levelIndex + 1}'),
        _OverlayFact(
          Icons.local_fire_department_rounded,
          'Best chain',
          '×${game.chain.toStringAsFixed(1)}',
        ),
      ],
      buttonLabel: 'REWRITE REALITY',
      onTap: onTap,
      dangerous: true,
    );
  }
}

class _VictoryOverlay extends StatelessWidget {
  const _VictoryOverlay({required this.game, required this.onTap});

  final RealityGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      eyebrow: 'THE DEBT IS PAID',
      title: 'REALITY BENT.',
      description:
          'You outlasted every sector. Higher chains make the next run more lucrative—if you can survive the settlement.',
      facts: [
        _OverlayFact(Icons.stars_rounded, 'Final score', '${game.score}'),
        _OverlayFact(
          Icons.local_fire_department_rounded,
          'Final chain',
          '×${game.chain.toStringAsFixed(1)}',
        ),
        _OverlayFact(Icons.workspace_premium_rounded, 'Rank', game.rank),
      ],
      buttonLabel: 'RUN IT AGAIN',
      onTap: onTap,
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.facts,
    required this.buttonLabel,
    required this.onTap,
    this.dangerous = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<_OverlayFact> facts;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool dangerous;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xC9080C15),
        child: Center(
          child: Container(
            width: 480,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.fromLTRB(24, 23, 24, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF182238), Color(0xFF0B101C)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dangerous
                    ? const Color(0xFF95475E)
                    : const Color(0xFF4A5E87),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 40,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFF8DA1C5),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: dangerous ? const Color(0xFFFF8FA7) : Colors.white,
                    fontSize: 39,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFC0CBE1),
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facts
                      .map(
                        (fact) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11192A),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: const Color(0xFF2F3E5C)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                fact.icon,
                                color: const Color(0xFF7FCAED),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${fact.title}: ',
                                style: const TextStyle(
                                  color: Color(0xFF90A1C1),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                fact.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: dangerous
                          ? const Color(0xFFC44568)
                          : const Color(0xFF8568F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onTap,
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
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
}

class _OverlayFact {
  const _OverlayFact(this.icon, this.title, this.value);

  final IconData icon;
  final String title;
  final String value;
}

class _SettlementBanner extends StatelessWidget {
  const _SettlementBanner();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: const Color(0x22FFFFFF),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xE8121828),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE4F0FF)),
          ),
          child: const Text(
            'SETTLING THE STACK',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ),
    );
  }
}
