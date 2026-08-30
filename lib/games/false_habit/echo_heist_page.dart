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
    with SingleTickerProviderStateMixin {
  late final GameLoopController _loop;
  late final _EchoHeist _heist;
  Offset _input = Offset.zero;
  bool _paused = false;
  bool _completionReported = false;
  bool _continuingCampaign = false;
  double _elapsedSeconds = 0;
  int _inputEpoch = 0;

  @override
  void initState() {
    super.initState();
    GamePresentation.enterLandscape();
    _heist = _EchoHeist(
      campaignLevel: widget.level?.number ?? 1,
      campaign: widget.level,
    );
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) {
        final previousPhase = _heist.phase;
        if (previousPhase == _HeistPhase.playing) _elapsedSeconds += dt;
        _heist.update(dt, _input);
        if (previousPhase == _HeistPhase.playing &&
            _heist.phase != _HeistPhase.playing) {
          _clearInput();
        }
        _reportCompletion();
      },
      onFrame: () {
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
  }

  void _clearInput() {
    _input = Offset.zero;
    _inputEpoch++;
  }

  void _setPaused(bool value) {
    _paused = value;
    _clearInput();
    _loop.setPaused(value);
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
        (_heist.phase != _HeistPhase.stageClear &&
            _heist.phase != _HeistPhase.won)) {
      return;
    }
    _completionReported = true;
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _heist.runLoot.round(),
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
    final navigator = Navigator.of(context);
    _loop.setPaused(true);
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _loop.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heist = _heist;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.4,
            colors: [Color(0xFF2B304E), Color(0xFF080B12), Color(0xFF030408)],
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
                    child: _HeistHud(heist: heist, compact: compact),
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
                                  color: const Color(0xFF4A5478),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      key: const ValueKey(
                                        'false-habit-playfield',
                                      ),
                                      painter: _HeistPainter(heist),
                                    ),
                                  ),
                                  Positioned(
                                    top: compact ? 112 : 148,
                                    left: 12,
                                    child: IgnorePointer(
                                      child: _HeistArenaHud(heist: heist),
                                    ),
                                  ),
                                  if (heist.phase == _HeistPhase.playing)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GamePauseButton(
                                        onTap: () =>
                                            setState(() => _setPaused(true)),
                                      ),
                                    ),
                                  Positioned(
                                    left: 16,
                                    bottom: 15,
                                    child: TouchStick(
                                      key: ValueKey(_inputEpoch),
                                      onChanged: (value) =>
                                          setState(() => _input = value),
                                      size: compact ? 88 : 102,
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    bottom: 17,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TapGameButton(
                                          label: 'ECHO',
                                          icon: Icons.auto_awesome_rounded,
                                          color: const Color(0xFFC3A2FF),
                                          width: compact ? 62 : 72,
                                          onTap: () =>
                                              setState(heist.deployEcho),
                                        ),
                                        const SizedBox(width: 9),
                                        TapGameButton(
                                          label: 'ESCAPE',
                                          icon: Icons.exit_to_app_rounded,
                                          color: const Color(0xFF83F2C0),
                                          width: compact ? 70 : 80,
                                          onTap: () => setState(heist.cashOut),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (heist.phase == _HeistPhase.intro)
                                    _HeistOverlay(
                                      title: 'FALSE HABIT',
                                      eyebrow: 'ECHO HEIST',
                                      copy:
                                          'Move predictably to teach the Warden a habit. Then change direction, steal on a broken prediction, and send an Echo to lure it away.',
                                      button: 'START HEIST',
                                      onTap: _startRun,
                                    ),
                                  if (heist.phase == _HeistPhase.caught)
                                    _HeistOverlay(
                                      title: 'CAUGHT',
                                      eyebrow: 'THE WARDEN WAS RIGHT',
                                      copy:
                                          'You lost the unbanked haul. Build confidence in one direction, then cut across its prediction before collecting.',
                                      button: 'TRY ANOTHER HEIST',
                                      onTap: _startRun,
                                      danger: true,
                                    ),
                                  if (heist.phase == _HeistPhase.stageClear)
                                    if (widget.level != null)
                                      CampaignMissionClearOverlay(
                                        level: widget.level!,
                                        score: heist.runLoot.round(),
                                        elapsedSeconds: _elapsedSeconds,
                                        accent: const Color(0xFFC29CFF),
                                        onNextLevel: _continueCampaign,
                                        onExit: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    else
                                      _HeistOverlay(
                                        title: 'DISTRICT CLEARED',
                                        eyebrow:
                                            '+${heist.runLoot.round()} BANKED THIS DISTRICT',
                                        copy:
                                            'The next Warden learns faster and runs harder. Keep breaking the prediction at the moment you steal.',
                                        button: 'NEXT DISTRICT',
                                        onTap: heist.nextStage,
                                      ),
                                  if (heist.phase == _HeistPhase.won)
                                    if (widget.level != null)
                                      CampaignMissionClearOverlay(
                                        level: widget.level!,
                                        score: heist.runLoot.round(),
                                        elapsedSeconds: _elapsedSeconds,
                                        accent: const Color(0xFFC29CFF),
                                        onNextLevel: _continueCampaign,
                                        onExit: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    else
                                      _HeistOverlay(
                                        title: 'THE HABIT BROKE',
                                        eyebrow: 'ALL DISTRICTS CASHED OUT',
                                        copy:
                                            'No Warden can hold your pattern. You cleared the complete heist.',
                                        button: 'NEW HEIST',
                                        onTap: _startRun,
                                      ),
                                  if (_paused)
                                    GamePauseOverlay(
                                      gameName: 'FALSE HABIT',
                                      onResume: () =>
                                          setState(() => _setPaused(false)),
                                      onRestart: () => setState(() {
                                        _setPaused(false);
                                        _startRun();
                                      }),
                                      onExit: _exitGame,
                                    ),
                                  // Keep the app-level exit above modal game
                                  // states so it stays tappable on the launch
                                  // and result screens.
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: GameExitButton(onExit: _exitGame),
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
                      padding: EdgeInsets.fromLTRB(18, 0, 18, compact ? 6 : 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.psychology_alt_rounded,
                            color: Color(0xFFC5B1FF),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              heist.message,
                              style: const TextStyle(
                                color: Color(0xFFB8C5DF),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'BANK ${heist.banked.round()}',
                            style: const TextStyle(
                              color: Color(0xFFFFD66B),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
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
    );
  }
}

class _HeistHud extends StatelessWidget {
  const _HeistHud({required this.heist, required this.compact});

  final _EchoHeist heist;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final confidence = heist.confidence;
    return Padding(
      padding: EdgeInsets.fromLTRB(17, compact ? 6 : 10, 17, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FALSE HABIT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.1,
                  fontSize: 16,
                ),
              ),
              Text(
                'DISTRICT ${heist.stageNumber}/${heist.stageCount}  LOOT ${heist.runLoot.round()}/${heist.stageTarget}',
                style: const TextStyle(
                  color: Color(0xFFFFD66B),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          _HeistMetric(
            label: 'WARDEN READ',
            value: '${(confidence * 100).round()}%',
            color: confidence >= .85
                ? const Color(0xFFFF7F95)
                : const Color(0xFF8FE8FF),
          ),
          const SizedBox(width: 8),
          _HeistMetric(
            label: 'CHAIN',
            value: '×${heist.combo.toStringAsFixed(1)}',
            color: const Color(0xFFC3A2FF),
          ),
          const SizedBox(width: 8),
          _HeistMetric(
            label: 'ECHO',
            value: heist.echoReady ? 'READY' : 'CHARGING',
            color: heist.echoReady
                ? const Color(0xFF83F2C0)
                : const Color(0xFF9BAAC6),
          ),
        ],
      ),
    );
  }
}

class _HeistMetric extends StatelessWidget {
  const _HeistMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC101625),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF2D3A57)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8899BA),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeistArenaHud extends StatelessWidget {
  const _HeistArenaHud({required this.heist});

  final _EchoHeist heist;

  @override
  Widget build(BuildContext context) => Container(
    width: 138,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0xC90D1421),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: const Color(0xFF47536F)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeistSideMetric(
          label: 'WARDEN',
          value: '${(heist.confidence * 100).round()}%',
          color: heist.confidence >= .85
              ? const Color(0xFFFF7F95)
              : const Color(0xFF8FE8FF),
        ),
        const Divider(height: 9, color: Color(0xFF37425E)),
        _HeistSideMetric(
          label: 'CHAIN',
          value: '×${heist.combo.toStringAsFixed(1)}',
          color: const Color(0xFFC3A2FF),
        ),
        const Divider(height: 9, color: Color(0xFF37425E)),
        _HeistSideMetric(
          label: 'ECHO',
          value: heist.echoReady ? 'READY' : 'CHARGE',
          color: heist.echoReady
              ? const Color(0xFF83F2C0)
              : const Color(0xFF9BAAC6),
        ),
        const Divider(height: 9, color: Color(0xFF37425E)),
        Text(
          heist.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFB8C5DF),
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'BANK ${heist.banked.round()}',
            style: const TextStyle(
              color: Color(0xFFFFD66B),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HeistSideMetric extends StatelessWidget {
  const _HeistSideMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9AAAC8),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .55,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _HeistOverlay extends StatelessWidget {
  const _HeistOverlay({
    required this.title,
    required this.eyebrow,
    required this.copy,
    required this.button,
    required this.onTap,
    this.danger = false,
  });

  final String title;
  final String eyebrow;
  final String copy;
  final String button;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xC9070B13),
        child: Center(
          child: Container(
            width: 430,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              color: const Color(0xFF121A2B),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: danger
                    ? const Color(0xFF984B61)
                    : const Color(0xFF596D9C),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFC3A2FF),
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: danger ? const Color(0xFFFF91A8) : Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  copy,
                  style: const TextStyle(
                    color: Color(0xFFC5D0E6),
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: danger
                          ? const Color(0xFFC54967)
                          : const Color(0xFF856AF1),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      button,
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
