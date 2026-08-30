part of 'edge_load_game.dart';

class EdgeLoadPage extends StatefulWidget {
  const EdgeLoadPage({
    super.key,
    this.level,
    this.onLevelComplete,
    this.onNextLevel,
  });

  final GeneratedGameLevel? level;
  final LevelCompleteCallback? onLevelComplete;
  final VoidCallback? onNextLevel;

  @override
  State<EdgeLoadPage> createState() => _EdgeLoadPageState();
}

class _EdgeLoadPageState extends State<EdgeLoadPage>
    with SingleTickerProviderStateMixin {
  late final GameLoopController _loop;
  late final _MansionGame _game;
  Offset _input = Offset.zero;
  bool _sprinting = false;
  bool _paused = false;
  bool _completionReported = false;
  bool _continuingCampaign = false;
  int _stickEpoch = 0;

  @override
  void initState() {
    super.initState();
    GamePresentation.enterLandscape();
    _game = _MansionGame(
      layoutSeed: widget.level?.seed,
      campaignLevel: widget.level?.number ?? 1,
    );
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) => _game.update(dt, _input, _sprinting),
      onFrame: () {
        _reportCompletion();
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
  }

  void _clearInput() {
    _input = Offset.zero;
    _sprinting = false;
    _stickEpoch++;
  }

  void _pause(bool value) {
    _paused = value;
    _clearInput();
    _loop.setPaused(value);
  }

  void _start() {
    _clearInput();
    _completionReported = false;
    _game.start();
  }

  void _reportCompletion() {
    final level = widget.level;
    if (_completionReported ||
        level == null ||
        _game.phase != _MansionPhase.extracted) {
      return;
    }
    _completionReported = true;
    widget.onLevelComplete?.call(
      LevelRunResult(
        level: level,
        score: _game.player.loot,
        elapsedSeconds: _game.time,
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
  void dispose() {
    _loop.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFF05070B),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 470;
              final control = compact ? 54.0 : 62.0;
              return Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(painter: _EdgeLoadPainter(game)),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GameExitButton(
                      onExit: () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (game.phase == _MansionPhase.playing)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GamePauseButton(
                        onTap: () => setState(() => _pause(true)),
                      ),
                    ),
                  if (game.phase == _MansionPhase.playing) ...[
                    Positioned(
                      top: 10,
                      left: 56,
                      child: _MansionRunHud(
                        game: game,
                        width: compact ? 170 : 202,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: TouchStick(
                        key: ValueKey(_stickEpoch),
                        size: compact ? 94 : 116,
                        onChanged: (value) => _input = value,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HoldGameButton(
                                label: 'SPRINT',
                                icon: Icons.bolt_rounded,
                                color: const Color(0xFF72D6FF),
                                size: control,
                                onChanged: (value) => _sprinting = value,
                              ),
                              const SizedBox(width: 7),
                              TapGameButton(
                                label: 'COIN',
                                icon: Icons.toll_rounded,
                                color: const Color(0xFFF4D67B),
                                width: control,
                                onTap: () => setState(game.queueCoin),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TapGameButton(
                                label: 'MASK',
                                icon: Icons.masks_rounded,
                                color: const Color(0xFF86FFBE),
                                width: control,
                                onTap: () => setState(game.queueDisguise),
                              ),
                              const SizedBox(width: 7),
                              SizedBox(width: control),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (game.phase == _MansionPhase.intro)
                    _MansionOverlay(
                      title: 'EDGELOAD: ${game.layoutName}',
                      copy:
                          'Steal the diamond, evade the guards, and extract. Every piece of loot closes in the screen. Loot is collected automatically; use the stick to move, sprint, throw coins, and wear a disguise.',
                      button: 'INFILTRATE',
                      onTap: () => setState(_start),
                    ),
                  if (game.phase == _MansionPhase.caught)
                    _MansionOverlay(
                      title: 'CAUGHT',
                      copy: game.message,
                      button: 'RUN IT AGAIN',
                      danger: true,
                      onTap: () => setState(_start),
                    ),
                  if (game.phase == _MansionPhase.extracted)
                    if (widget.level != null)
                      CampaignMissionClearOverlay(
                        level: widget.level!,
                        score: game.player.loot,
                        elapsedSeconds: game.time,
                        accent: const Color(0xFFF7C948),
                        onNextLevel: _continueCampaign,
                        onExit: () => Navigator.of(context).pop(),
                      )
                    else
                      _MansionOverlay(
                        title: 'EXTRACTION COMPLETE',
                        copy:
                            'You extracted \$${game.player.loot}. The more you stole, the less you could see.',
                        button: 'NEW RUN',
                        onTap: () => setState(_start),
                      ),
                  if (_paused)
                    GamePauseOverlay(
                      gameName: 'EDGELOAD: MANSION RUN',
                      onResume: () => setState(() => _pause(false)),
                      onRestart: () => setState(() {
                        _pause(false);
                        _start();
                      }),
                      onExit: () => Navigator.of(context).pop(),
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

class _MansionRunHud extends StatelessWidget {
  const _MansionRunHud({required this.game, required this.width});

  final _MansionGame game;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xDD101829),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFF72D6FF).withValues(alpha: .72),
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MansionStat(
                label: 'MONEY',
                value: '\$${game.player.loot}',
                color: const Color(0xFFF4D67B),
              ),
              _MansionStat(
                label: 'COINS',
                value: '${game.player.coins}',
                color: const Color(0xFFF4D67B),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            height: 30,
            child: VerticalDivider(color: Color(0xFF4D6381), width: 1),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MansionMeter(
                label: 'SPRINT',
                value: game.player.stamina / 100,
                color: game.sprinting
                    ? const Color(0xFFB7F3FF)
                    : const Color(0xFF72D6FF),
              ),
              _MansionMeter(
                label: 'STEALTH',
                value: game.player.disguise / _MansionGame.disguiseDuration,
                color: const Color(0xFF86FFBE),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MansionStat extends StatelessWidget {
  const _MansionStat({
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
        style: TextStyle(
          color: color,
          fontSize: 7,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: .45,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFFEAF2FF),
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _MansionMeter extends StatelessWidget {
  const _MansionMeter({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 42,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 7,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: .45,
          ),
        ),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 5,
            backgroundColor: const Color(0xFF273141),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
    ],
  );
}

class _MansionOverlay extends StatelessWidget {
  const _MansionOverlay({
    required this.title,
    required this.copy,
    required this.button,
    required this.onTap,
    this.danger = false,
  });
  final String title, copy, button;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xD905070B),
    child: Center(
      child: Container(
        width: 370,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xF00A1018),
          border: Border.all(
            color: danger ? const Color(0xFFFF6672) : const Color(0xFF72D6FF),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: danger
                    ? const Color(0xFFFF6672)
                    : const Color(0xFF72F1B8),
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              copy,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC0CDDF),
                height: 1.35,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(button),
              style: FilledButton.styleFrom(
                backgroundColor: danger
                    ? const Color(0xFFC73D54)
                    : const Color(0xFF297B99),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
