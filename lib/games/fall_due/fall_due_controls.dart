part of 'fall_due_game.dart';

class _DueControls extends StatelessWidget {
  const _DueControls({required this.game, required this.availableSize});

  static const _controlSurface = Color(0xDB302636);

  final _FallDueGame game;
  final Size availableSize;

  @override
  Widget build(BuildContext context) {
    final portrait = availableSize.height > availableSize.width;
    final borrowSize =
        (portrait ? availableSize.width * .23 : availableSize.height * .26)
            .clamp(78.0, 140.0);
    final moveSize = (borrowSize * .65).clamp(60.0, 90.0);
    final actionSize = (borrowSize * .54).clamp(52.0, 70.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HoldGameButton(
              label: 'LEFT',
              icon: Icons.chevron_left_rounded,
              color: _dueCream,
              backgroundColor: _controlSurface,
              size: moveSize,
              labelSize: 11,
              onChanged: (value) => game.left = value,
            ),
            const SizedBox(width: 6),
            HoldGameButton(
              label: 'RIGHT',
              icon: Icons.chevron_right_rounded,
              color: _dueCream,
              backgroundColor: _controlSurface,
              size: moveSize,
              labelSize: 11,
              onChanged: (value) => game.right = value,
            ),
          ],
        ),
        SizedBox(
          width: borrowSize + actionSize + 10,
          height: borrowSize + actionSize + 11,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _DueBorrowArc(borrowSize)),
                ),
              ),
              Positioned(
                right: actionSize + 8,
                top: 4,
                child: _DueAction(
                  label: 'GIVE',
                  icon: Icons.north_east_rounded,
                  color: _dueMint,
                  size: actionSize,
                  onTap: game.transferDebt,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: _DueAction(
                  label: 'TAKE',
                  icon: Icons.south_west_rounded,
                  color: _dueBlue,
                  size: actionSize,
                  onTap: game.stealDebt,
                ),
              ),
              Positioned(
                left: 0,
                bottom: (borrowSize - actionSize) * .36,
                child: HoldGameButton(
                  label: 'SLAM',
                  icon: Icons.keyboard_double_arrow_down_rounded,
                  color: _dueCoral,
                  backgroundColor: _controlSurface,
                  size: actionSize,
                  labelSize: 10,
                  onChanged: game.setSlam,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: HoldGameButton(
                  label: 'BORROW',
                  icon: Icons.arrow_upward_rounded,
                  color: _dueGold,
                  backgroundColor: const Color(0xEB47303A),
                  size: borrowSize,
                  labelSize: (borrowSize * .133).clamp(11.0, 16.0),
                  onChanged: game.setBorrow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DueAction extends StatelessWidget {
  const _DueAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final circle = CircleBorder(
      side: BorderSide(color: color.withValues(alpha: .82), width: 1.4),
    );
    return Material(
      color: Color.lerp(const Color(0xEE322737), color, .13),
      shape: circle,
      child: InkWell(
        customBorder: circle,
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: size * .41),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: 'sans-serif',
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueBorrowArc extends CustomPainter {
  const _DueBorrowArc(this.borrowSize);

  final double borrowSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width - borrowSize / 2,
      size.height - borrowSize / 2,
    );
    final arc = Rect.fromCircle(center: center, radius: borrowSize / 2 + 5);
    canvas.drawArc(
      arc,
      -2.86,
      2.30,
      false,
      Paint()
        ..color = const Color(0xBB302636)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      arc,
      -2.70,
      2.02,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xC8FF827A), Color(0xC8FFD56F), Color(0xC8A4DDFF)],
        ).createShader(arc)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _DueBorrowArc oldDelegate) =>
      oldDelegate.borrowSize != borrowSize;
}
