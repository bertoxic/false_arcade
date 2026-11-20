part of 'future_debt_game.dart';

class _FutureCombatControls extends StatelessWidget {
  const _FutureCombatControls({
    required this.game,
    required this.fireSize,
    required this.onDash,
    required this.onBorrow,
    required this.onFiringChanged,
    required this.onAimChanged,
  });

  final _FutureDebtGame game;
  final double fireSize;
  final VoidCallback onDash;
  final ValueChanged<_DebtKind> onBorrow;
  final ValueChanged<bool> onFiringChanged;
  final ValueChanged<Offset> onAimChanged;

  @override
  Widget build(BuildContext context) {
    final abilitySize = (fireSize * .49).clamp(49.0, 65.0);
    final dashSize = (fireSize * .42).clamp(48.0, 64.0);
    return SizedBox(
      width: fireSize + dashSize + 10,
      height: fireSize + abilitySize + 11,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _FutureFireArc(fireSize)),
            ),
          ),
          Positioned(
            right: fireSize * .82 - abilitySize / 2,
            top: 4,
            child: _FuturePowerButton(
              title: 'Ghost Wage',
              label: 'GHOST',
              icon: Icons.blur_on_rounded,
              tint: const Color(0xFF9AEAF1),
              size: abilitySize,
              ready: game.canBorrow(_DebtKind.move),
              active: game.borrowBoostRemaining(_DebtKind.move) > 0,
              onTap: () => onBorrow(_DebtKind.move),
            ),
          ),
          Positioned(
            right: math.max(0.0, fireSize * .19 - abilitySize / 2),
            top: 0,
            child: _FuturePowerButton(
              title: 'Reverse Payment',
              label: 'REVERSE',
              icon: Icons.swap_horiz_rounded,
              tint: _futureLilac,
              size: abilitySize,
              ready: game.canBorrow(_DebtKind.dash),
              active: game.borrowBoostRemaining(_DebtKind.dash) > 0,
              onTap: () => onBorrow(_DebtKind.dash),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: TapGameButton(
              label: 'DASH',
              icon: Icons.bolt_rounded,
              color: _futureCream,
              width: dashSize,
              height: dashSize,
              onTap: onDash,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AimGameButton(
              label: 'FIRE',
              icon: Icons.gps_fixed_rounded,
              color: _futureGold,
              size: fireSize,
              onFiringChanged: onFiringChanged,
              onAimChanged: onAimChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FuturePowerButton extends StatelessWidget {
  const _FuturePowerButton({
    required this.title,
    required this.label,
    required this.icon,
    required this.tint,
    required this.size,
    required this.ready,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String label;
  final IconData icon;
  final Color tint;
  final double size;
  final bool ready;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const circle = CircleBorder();
    final ink = ready || active ? tint : Color.lerp(tint, _futureInk, .48)!;
    return Tooltip(
      message: title,
      child: Semantics(
        label: title,
        button: true,
        enabled: ready,
        toggled: active,
        child: Material(
          color: Colors.transparent,
          shape: circle,
          child: InkWell(
            customBorder: circle,
            onTap: ready ? onTap : null,
            child: Ink(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ink.withValues(alpha: active ? 1 : .8),
                  width: active ? 2 : 1.3,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.lerp(_futureInk, tint, active ? .56 : .19)!,
                    const Color(0xF71D1B29),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ink.withValues(alpha: active ? .48 : .17),
                    blurRadius: active ? 17 : 7,
                  ),
                ],
              ),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: size * .42, color: ink),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: TextStyle(
                        color: ink,
                        fontSize: size >= 58 ? 9 : 7.5,
                        height: 1,
                        fontWeight: FontWeight.w900,
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
}

class _FutureFireArc extends CustomPainter {
  const _FutureFireArc(this.fireSize);

  final double fireSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width - fireSize / 2,
      size.height - fireSize / 2,
    );
    final rail = Rect.fromCircle(center: center, radius: fireSize / 2 + 5);
    canvas.drawArc(
      rail,
      -2.70,
      2.10,
      false,
      Paint()
        ..color = const Color(0xAD2B2531)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      rail,
      -2.48,
      1.57,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xB09AEAF1), Color(0xC0D8B6FF)],
        ).createShader(rail)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _FutureFireArc oldDelegate) =>
      oldDelegate.fireSize != fireSize;
}
