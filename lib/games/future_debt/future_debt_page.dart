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
    with SingleTickerProviderStateMixin {
  late final GameLoopController _loop;
  late final _FutureDebtGame _game;
  Offset _input = Offset.zero;
  Offset _aimInput = Offset.zero;
  bool _firing = false;
  bool _paused = false;
  bool _campaignComplete = false;
  // A Next Level action pops this route and immediately launches another
  // Future Debt route. Do not restore portrait/orientation in the gap: the
  // platform can apply that asynchronous restore after the next route has
  // requested landscape, leaving the new level rotated incorrectly.
  bool _continuingCampaign = false;

  @override
  void initState() {
    super.initState();
    GamePresentation.enterLandscape();
    _game = _FutureDebtGame(campaign: widget.level);
    _loop = GameLoopController(
      vsync: this,
      onStep: (dt) => _game.update(dt, _input, _aimInput, _firing),
      onFrame: () {
        _reportCompletion();
        if (mounted) setState(() {});
      },
      onLifecyclePause: _clearInput,
    )..start();
  }

  void _clearInput() {
    _input = Offset.zero;
    _aimInput = Offset.zero;
    _firing = false;
    _game.cancelTransientInput();
  }

  void _start() {
    _clearInput();
    _campaignComplete = false;
    _game.start();
    setState(() {});
  }

  void _pause(bool value) {
    _clearInput();
    _loop.setPaused(value);
    setState(() => _paused = value);
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
    _clearInput();
    _loop.dispose();
    if (!_continuingCampaign) GamePresentation.restore();
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
                          left: compact ? 7 : 10,
                          right: compact ? 7 : 10,
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
                          _FutureOverlay(onStart: _start),
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
    );
  }
}

class _FutureTopHud extends StatelessWidget {
  const _FutureTopHud({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // At narrower landscape widths, reserving room for the timeline matters
      // more than repeating the title already shown by the game overlay.
      final showBrand = !compact && constraints.maxWidth >= 740;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: compact ? 42 : 48),
          if (showBrand) ...[
            const SizedBox(width: 210, child: _BrandCard()),
            const SizedBox(width: 8),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FutureStat(
                label: 'LIFETIME',
                value: game.lifetime.clamp(0, 999).toStringAsFixed(1) + 's',
                color: game.lifetime < 10
                    ? const Color(0xFFFF6279)
                    : const Color(0xFFEEF4FF),
                compact: compact,
              ),
              const SizedBox(width: 5),
              _FutureStat(
                label: 'DEBT / FORM',
                value: game.debtAmount.toStringAsFixed(1) + 's',
                detail: game.formName,
                color: const Color(0xFFEEF4FF),
                compact: compact,
              ),
              const SizedBox(width: 5),
              _FutureStat(
                label: 'SCORE',
                value: game.score.floor().toString(),
                color: const Color(0xFFEEF4FF),
                compact: compact,
              ),
            ],
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: FractionallySizedBox(
                widthFactor: .6,
                child: _FutureTimeline(game: game, compact: compact),
              ),
            ),
          ),
          const SizedBox(width: 106),
          SizedBox(width: compact ? 39 : 44),
        ],
      );
    },
  );
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: _panelDecoration(const Color(0xFF2A3858)),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUTURE DEBT',
          style: TextStyle(
            fontSize: 18,
            height: .9,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'YOU ARE CREATING A PREDATOR THAT ARRIVES LATER.',
          style: TextStyle(
            color: Color(0xFF8996B4),
            fontSize: 6,
            letterSpacing: .55,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
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
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF8996B4),
          fontSize: compact ? 6 : 7,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: compact ? 14 : 17,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
      ),
      if (detail != null)
        Text(
          detail!,
          style: const TextStyle(
            color: Color(0xFF8996B4),
            fontSize: 6,
            height: .8,
            fontWeight: FontWeight.w800,
          ),
        ),
    ],
  );
}

class _FutureTimeline extends StatelessWidget {
  const _FutureTimeline({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(compact ? 6 : 9, 5, compact ? 6 : 9, 6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'THE LEDGER — NEXT 15 SECONDS',
              style: TextStyle(
                color: const Color(0xFFEAF2FF),
                fontSize: compact ? 6 : 8,
                fontWeight: FontWeight.w900,
                letterSpacing: compact ? .6 : 1,
              ),
            ),
            const Spacer(),
            Text(
              'NOW → MATURITY',
              style: TextStyle(
                color: const Color(0xFF8996B4),
                fontSize: compact ? 5 : 6,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(8, (index) {
            final start = index * 2;
            final end = math.min(start + 2, 15);
            final bills = game.bills
                .where(
                  (bill) =>
                      bill.due < game.time + end &&
                      bill.due + bill.duration > game.time + start,
                )
                .toList();
            final kinds = bills.map((bill) => bill.kind).toSet();
            final kind = kinds.isEmpty ? null : kinds.first;
            final color = kinds.length >= 3
                ? const Color(0xFFFF3E63)
                : kind == _DebtKind.move
                ? const Color(0xFF58E8FF)
                : kind == _DebtKind.shoot
                ? const Color(0xFFFF6B86)
                : kind == _DebtKind.dash
                ? const Color(0xFF9A78FF)
                : kind == _DebtKind.life
                ? const Color(0xFFFFD166)
                : const Color(0xFF27334D);
            final mark = kinds.length >= 3
                ? '☠'
                : kind == _DebtKind.move
                ? 'R'
                : kind == _DebtKind.shoot
                ? 'A'
                : kind == _DebtKind.dash
                ? '⊗'
                : kind == _DebtKind.life
                ? r'$'
                : '✓';
            return Expanded(
              child: Container(
                height: compact ? 21 : 28,
                margin: EdgeInsets.only(right: index == 7 ? 0 : 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kinds.isEmpty
                      ? const Color(0xFF141B2B)
                      : color.withValues(alpha: .28),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        mark,
                        style: TextStyle(
                          color: kinds.isEmpty
                              ? const Color(0xFF9AA7C1)
                              : Colors.white,
                          fontSize: compact ? 7 : 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 1,
                      child: Text(
                        end.toString(),
                        style: TextStyle(
                          color: const Color(0xFF66728F),
                          fontSize: compact ? 4 : 5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );
}

class _MessageStrip extends StatelessWidget {
  const _MessageStrip({required this.game, required this.compact});
  final _FutureDebtGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    child: Text(
      game.message,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: game.hasAnyLock
            ? const Color(0xFFFF8097)
            : const Color(0xFFFFD36A),
        fontSize: compact ? 6 : 8,
        fontWeight: FontWeight.w800,
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
                  detail: '+12 seconds now',
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
          value.toStringAsFixed(0) + 's',
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
  const _FutureOverlay({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xE8040713),
      child: Center(
        child: Container(
          width: 590,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF354667)),
            boxShadow: const [
              BoxShadow(color: Color(0xAA000000), blurRadius: 40),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: const [
                  _Tag('SCROLLING DEBT-MAZE'),
                  _Tag('DESTRUCTIBLE ROOMS'),
                  _Tag('FUTURE ECHOES'),
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
                    TextSpan(text: 'FUTURE '),
                    TextSpan(
                      text: 'DEBT',
                      style: TextStyle(color: Color(0xFFFF4F78)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'You play THE DEBTOR — a masked time-runner with an hourglass heart. Borrow an ability now and a matching Future Echo is stamped into the room. When the debt matures, the ability is taken away and that Echo becomes a real hazard.',
                style: TextStyle(
                  color: Color(0xFFBDC8DF),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Rule('Move', 'left stick'),
                  _Rule('Fire', 'hold FIRE'),
                  _Rule('Dash', 'tap DASH'),
                  _Rule('Borrow', 'credit rail'),
                  _Rule('Walls', 'crack, breach, reveal shards'),
                  _Rule('Camera', 'follows the Debtor through the maze'),
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
                        child: Opacity(opacity: 0, child: Text('START RUN')),
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

class _FutureCampaignClearOverlay extends StatelessWidget {
  const _FutureCampaignClearOverlay({
    required this.level,
    required this.score,
    required this.onReplay,
    required this.onExit,
  });

  final GeneratedGameLevel level;
  final int score;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xDE040713),
      child: Center(
        child: Container(
          width: 390,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF58E8FF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LEVEL ${level.number.toString().padLeft(2, '0')} CLEARED',
                style: const TextStyle(
                  color: Color(0xFF58E8FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'THE LEDGER YIELDED',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${level.mutator} · $score score\nStars are saved to this campaign level.',
                style: const TextStyle(
                  color: Color(0xFFC3D0E7),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onReplay,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF58E8FF),
                    foregroundColor: const Color(0xFF07111A),
                  ),
                  child: const Text(
                    'RUN LEVEL AGAIN',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              TextButton(
                onPressed: onExit,
                child: const Text('RETURN TO LEVELS'),
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
          text: keyText + ': ',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        TextSpan(text: value),
      ],
    ),
  );
}

BoxDecoration _panelDecoration(Color border) => BoxDecoration(
  color: const Color(0xED0D1320),
  border: Border.all(color: border),
  borderRadius: BorderRadius.circular(10),
);
