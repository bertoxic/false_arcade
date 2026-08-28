part of 'echo_heist_game.dart';

class _HeistPainter extends CustomPainter {
  _HeistPainter(this.heist);

  final _EchoHeist heist;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_EchoHeist.width, _EchoHeist.height),
    );
    canvas.drawColor(const Color(0xFF05070D), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    final bounds = const Rect.fromLTWH(
      0,
      0,
      _EchoHeist.width,
      _EchoHeist.height,
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF26344D), Color(0xFF0B111D), Color(0xFF05070D)],
        ).createShader(bounds),
    );
    final grid = Paint()
      ..color = const Color(0xFF89A8D0).withValues(alpha: .08)
      ..strokeWidth = 1;
    for (var x = 45.0; x < _EchoHeist.width; x += 42) {
      canvas.drawLine(Offset(x, 45), Offset(x, _EchoHeist.height - 45), grid);
    }
    for (var y = 50.0; y < _EchoHeist.height; y += 42) {
      canvas.drawLine(Offset(45, y), Offset(_EchoHeist.width - 45, y), grid);
    }
    final arena = Rect.fromLTWH(
      45,
      48,
      _EchoHeist.width - 90,
      _EchoHeist.height - 96,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(arena, const Radius.circular(19)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = heist._lockdown > 0
            ? const Color(0xFFFF607C).withValues(alpha: .7)
            : const Color(0xFF526A94),
    );
    _drawExit(canvas, heist);
    _drawDiamond(
      canvas,
      heist.blackDiamond,
      heist.blackDiamondTaken,
      heist.confidence,
    );
    for (final loot in heist.loot) {
      if (loot.taken) continue;
      final color = loot.diamond
          ? const Color(0xFF8FE8FF)
          : const Color(0xFFFFD66B);
      if (loot.diamond) {
        final path = Path()
          ..moveTo(loot.position.dx, loot.position.dy - 11)
          ..lineTo(loot.position.dx + 10, loot.position.dy)
          ..lineTo(loot.position.dx, loot.position.dy + 11)
          ..lineTo(loot.position.dx - 10, loot.position.dy)
          ..close();
        canvas.drawPath(path, Paint()..color = color);
      } else {
        canvas.drawCircle(loot.position, 8, Paint()..color = color);
        _text(
          canvas,
          r'$',
          loot.position + const Offset(0, 4),
          10,
          const Color(0xFF63501A),
          center: true,
          bold: true,
        );
      }
    }
    final predictionActive = heist.isTelegraphing || heist.isCommitted;
    final tether = Paint()
      ..color =
          (predictionActive ? const Color(0xFFFFD66B) : const Color(0xFFFF7895))
              .withValues(alpha: predictionActive ? .78 : .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = predictionActive ? 2.4 : 1.2;
    canvas.drawLine(heist.warden, heist.wardenTarget, tether);
    if (predictionActive) {
      canvas.drawCircle(
        heist.wardenTarget,
        heist.isCommitted ? 17 : 12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = heist.isCommitted
              ? const Color(0xFFFF728A)
              : const Color(0xFFFFD66B),
      );
      _text(
        canvas,
        '${heist.isCommitted ? 'COMMIT' : 'READ'} ${heist.predictedMove}',
        heist.wardenTarget + const Offset(0, 22),
        8,
        heist.isCommitted ? const Color(0xFFFF91A8) : const Color(0xFFFFD66B),
        center: true,
        bold: true,
      );
    }
    for (final echo in heist.echoes) {
      canvas.drawCircle(
        echo.position,
        16,
        Paint()..color = const Color(0xFFC3A2FF).withValues(alpha: .18),
      );
      canvas.drawCircle(
        echo.position,
        10,
        Paint()..color = const Color(0xFFC3A2FF).withValues(alpha: .72),
      );
      if (echo.carried != null) {
        canvas.drawCircle(
          echo.position + const Offset(0, -17),
          4,
          Paint()..color = const Color(0xFFFFD66B),
        );
      }
    }
    final wardenColor = heist._wardenStun > 0
        ? const Color(0xFF9BE9FF)
        : const Color(0xFFFF6F87);
    canvas.drawCircle(
      heist.warden,
      26,
      Paint()..color = wardenColor.withValues(alpha: .16),
    );
    canvas.drawCircle(heist.warden, 18, Paint()..color = wardenColor);
    canvas.drawCircle(
      heist.warden,
      7,
      Paint()..color = const Color(0xFF180913),
    );
    canvas.drawCircle(
      heist.warden + const Offset(3, -2),
      2.5,
      Paint()..color = Colors.white,
    );
    if (heist.wardenFollowingEcho) {
      _text(
        canvas,
        'ECHO LOCK',
        heist.warden + const Offset(0, -31),
        8,
        const Color(0xFFC3A2FF),
        center: true,
        bold: true,
      );
    }
    if (heist._wardenStun > 0) {
      _text(
        canvas,
        'STUNNED',
        heist.warden + const Offset(0, -31),
        8,
        const Color(0xFF9BE9FF),
        center: true,
        bold: true,
      );
    }
    final playerColor = const Color(0xFFEAF4FF);
    canvas.drawCircle(
      heist.player,
      23,
      Paint()..color = const Color(0xFF8FE8FF).withValues(alpha: .18),
    );
    canvas.drawCircle(heist.player, 13, Paint()..color = playerColor);
    canvas.drawCircle(
      heist.player + const Offset(-4, -2),
      2,
      Paint()..color = const Color(0xFF0B101C),
    );
    canvas.drawCircle(
      heist.player + const Offset(4, -2),
      2,
      Paint()..color = const Color(0xFF0B101C),
    );
    _text(
      canvas,
      heist.hasBreakWindow
          ? 'BREAK WINDOW — STEAL NOW'
          : 'WARDEN CONFIDENCE ${(heist.confidence * 100).round()}%',
      const Offset(480, 70),
      11,
      heist.hasBreakWindow ? const Color(0xFF83F2C0) : const Color(0xFFC9D7F1),
      center: true,
      bold: true,
    );
    canvas.restore();
  }

  void _drawExit(Canvas canvas, _EchoHeist heist) {
    final point = heist.exit;
    final color = heist.isExitLocked
        ? const Color(0xFFFF728A)
        : heist.isExitReady
        ? const Color(0xFF83F2C0)
        : const Color(0xFFFFD66B);
    final label = heist.isExitLocked
        ? 'LOCKED'
        : heist.isExitReady
        ? 'EXIT'
        : '${(heist.stageTarget - heist.runLoot).ceil()} MORE';
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        heist.exitBounds,
        const Radius.circular(5),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color,
    );
    _text(
      canvas,
      label,
      point + const Offset(0, -40),
      9,
      color,
      center: true,
      bold: true,
    );
  }

  void _drawDiamond(
    Canvas canvas,
    Offset point,
    bool taken,
    double confidence,
  ) {
    if (taken) return;
    final unlocked = confidence >= .85;
    final color = unlocked ? const Color(0xFFFFD66B) : const Color(0xFF6A7385);
    canvas.drawCircle(
      point,
      29,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: .6),
    );
    final path = Path()
      ..moveTo(point.dx, point.dy - 16)
      ..lineTo(point.dx + 13, point.dy)
      ..lineTo(point.dx, point.dy + 17)
      ..lineTo(point.dx - 13, point.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    _text(
      canvas,
      unlocked ? 'BLACK DIAMOND' : 'NEED 85%',
      point + const Offset(0, 38),
      8,
      color,
      center: true,
      bold: true,
    );
  }

  void _text(
    Canvas canvas,
    String text,
    Offset point,
    double size,
    Color color, {
    bool center = false,
    bool bold = false,
  }) {
    paintGameText(
      canvas,
      text,
      point,
      size,
      color,
      align: center ? TextAlign.center : TextAlign.left,
      bold: bold,
    );
  }

  @override
  bool shouldRepaint(covariant _HeistPainter oldDelegate) => true;
}
