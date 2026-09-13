part of 'numberfall_game.dart';

class _NumberPainter extends CustomPainter {
  _NumberPainter(this.game);
  final _NumberfallGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_NumberfallGame.width, _NumberfallGame.height),
    );
    canvas.drawColor(const Color(0xFF03080C), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    final full = const Rect.fromLTWH(
      0,
      0,
      _NumberfallGame.width,
      _NumberfallGame.height,
    );
    canvas.drawRect(
      full,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.4),
          colors: [Color(0xFF164C58), Color(0xFF07131A), Color(0xFF03080C)],
        ).createShader(full),
    );
    final grid = Paint()
      ..color = const Color(0xFF85E5ED).withValues(alpha: .055)
      ..strokeWidth = 1;
    for (var x = 0.0; x < _NumberfallGame.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, _NumberfallGame.height), grid);
    }
    for (var y = 0.0; y < _NumberfallGame.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(_NumberfallGame.width, y), grid);
    }
    for (final platform in game.fadingPlatforms) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(platform, const Radius.circular(6)),
        Paint()..color = const Color(0xFFFFD166).withValues(alpha: .16),
      );
    }
    for (final dash in game.bounceDashes) {
      if (!dash.isAvailable || !dash.isVisible) continue;
      final isWarning = dash.isFading && dash.remaining <= 1.5;
      final isCritical = dash.isFading && dash.remaining <= 0.75;
      
      final baseColor = isCritical
          ? const Color(0xFFFF4565)
          : (isWarning ? const Color(0xFFFF9F43) : const Color(0xFF64F6DB));
      final coreColor = isCritical
          ? const Color(0xFFFF8595)
          : (isWarning ? const Color(0xFFFFD166) : const Color(0xFFA5FFF4));
      
      final alpha = dash.opacity;
      
      // Platform glow halo
      canvas.drawRRect(
        RRect.fromRectAndRadius(dash.rect.inflate(3), const Radius.circular(7)),
        Paint()..color = baseColor.withValues(alpha: alpha * 0.18),
      );
      
      // Main shock-absorber beam
      canvas.drawRRect(
        RRect.fromRectAndRadius(dash.rect, const Radius.circular(5)),
        Paint()..color = baseColor.withValues(alpha: alpha * 0.35),
      );
      
      // Outer high-energy border
      canvas.drawRRect(
        RRect.fromRectAndRadius(dash.rect, const Radius.circular(5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = coreColor.withValues(alpha: alpha * 0.85),
      );

      // Spring coil / chevron shock pattern along the wide platform
      final springPaint = Paint()
        ..color = coreColor.withValues(alpha: alpha * 0.45)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (var sx = dash.rect.left + 16.0; sx < dash.rect.right - 10.0; sx += 24.0) {
        canvas.drawLine(
          Offset(sx, dash.rect.bottom - 2),
          Offset(sx + 6, dash.rect.top + 2),
          springPaint,
        );
        canvas.drawLine(
          Offset(sx + 6, dash.rect.top + 2),
          Offset(sx + 12, dash.rect.bottom - 2),
          springPaint,
        );
      }

      // Neon top bounce-lip
      canvas.drawLine(
        Offset(dash.rect.left + 4, dash.rect.top + 1),
        Offset(dash.rect.right - 4, dash.rect.top + 1),
        Paint()
          ..color = coreColor.withValues(alpha: alpha * 0.95)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );

      // Countdown readout if currently active & expiring
      if (dash.isFading) {
        final remainingText = 'COLLAPSE IN ${dash.remaining.toStringAsFixed(1)}s';
        _text(
          canvas,
          remainingText,
          Offset(dash.rect.center.dx, dash.rect.bottom + 4),
          9,
          coreColor.withValues(alpha: alpha * 0.9),
          center: true,
          bold: true,
        );
      }
    }
    // Draw dynamic particles
    for (final p in game.particles) {
      final alpha = (1.0 - p.time / p.life).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        2.2,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }

    _drawDigits(canvas);
    if (game.exitOpen) _drawExit(canvas);
    for (final pickup in game.pickupsOnField) {
      final p = pickup.position;
      final color = pickup.risky
          ? const Color(0xFFFF9F68)
          : const Color(0xFFFFE66D);
      // 3D holographic rotating arithmetic prism
      final bob = math.sin(game.time * 4 + pickup.position.dx) * 3;
      final rot = game.time * 2.5;
      final center = p + Offset(0, bob);

      // Outer diamond cage
      final cagePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.85);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rot);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 22),
        cagePaint,
      );
      canvas.restore();

      // Glowing inner core
      canvas.drawCircle(
        center,
        14,
        Paint()..color = color.withValues(alpha: 0.28),
      );
      canvas.drawCircle(
        center,
        10,
        Paint()..color = color,
      );

      _text(
        canvas,
        pickup.label,
        center + const Offset(0, 4),
        9,
        const Color(0xFF101B12),
        center: true,
        bold: true,
      );
    }
    if (game.enemy.alive) {
      final pulse = (math.sin(game.time * 6) * 0.5 + 0.5);
      final eColor = Color.lerp(
        const Color(0xFFFF4860),
        const Color(0xFFFF7A8C),
        pulse,
      )!;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          game.enemy.rect.inflate(3),
          const Radius.circular(8),
        ),
        Paint()..color = eColor.withValues(alpha: .28),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(game.enemy.rect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF1E0A10),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          game.enemy.rect.deflate(2),
          const Radius.circular(4),
        ),
        Paint()..color = eColor,
      );
      // Glitch horns / brow
      final hornPath = Path()
        ..moveTo(game.enemy.x + 3, game.enemy.y)
        ..lineTo(game.enemy.x - 2, game.enemy.y - 5)
        ..lineTo(game.enemy.x + 8, game.enemy.y)
        ..moveTo(game.enemy.x + game.enemy.w - 3, game.enemy.y)
        ..lineTo(game.enemy.x + game.enemy.w + 2, game.enemy.y - 5)
        ..lineTo(game.enemy.x + game.enemy.w - 8, game.enemy.y);
      canvas.drawPath(
        hornPath,
        Paint()
          ..color = eColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Menacing visor slit
      canvas.drawRect(
        Rect.fromLTWH(game.enemy.x + 4, game.enemy.y + 7, game.enemy.w - 8, 4),
        Paint()..color = const Color(0xFF100204),
      );
      canvas.drawCircle(
        Offset(game.enemy.center.dx + math.sin(game.time * 8) * 3, game.enemy.y + 9),
        2,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }

    final player = game.player;
    final moving = player.vx.abs() > 10;
    final facingRight = player.vx >= 0;
    final stride = moving && player.grounded
        ? math.sin(game.time * 18) * 5
        : 0.0;

    // Glowing motion aura
    canvas.drawCircle(
      player.center,
      24,
      Paint()..color = const Color(0xFF64F6DB).withValues(alpha: .24),
    );

    // Articulated legs / boots
    final bootPaint = Paint()
      ..color = const Color(0xFF1B3B48)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final solePaint = Paint()
      ..color = const Color(0xFF64F6DB)
      ..strokeWidth = 2;

    if (player.grounded) {
      // Left leg
      canvas.drawLine(
        Offset(player.center.dx - 3, player.y + player.h - 8),
        Offset(player.center.dx - 3 - stride, player.y + player.h),
        bootPaint,
      );
      // Right leg
      canvas.drawLine(
        Offset(player.center.dx + 3, player.y + player.h - 8),
        Offset(player.center.dx + 3 + stride, player.y + player.h),
        bootPaint,
      );
      // Sole neon treads
      canvas.drawLine(
        Offset(player.center.dx - 5 - stride, player.y + player.h),
        Offset(player.center.dx - 1 - stride, player.y + player.h),
        solePaint,
      );
      canvas.drawLine(
        Offset(player.center.dx + 1 + stride, player.y + player.h),
        Offset(player.center.dx + 5 + stride, player.y + player.h),
        solePaint,
      );
    } else {
      // Jump tuck pose
      canvas.drawLine(
        Offset(player.center.dx - 3, player.y + player.h - 8),
        Offset(player.center.dx - 5, player.y + player.h - 3),
        bootPaint,
      );
      canvas.drawLine(
        Offset(player.center.dx + 3, player.y + player.h - 8),
        Offset(player.center.dx + 5, player.y + player.h - 3),
        bootPaint,
      );
    }

    // Torso / cyber chassis
    final torsoRect = Rect.fromLTWH(
      player.x,
      player.y,
      player.w,
      player.h - 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFFE8F7FA),
    );

    // Cyber chest armor plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 3, player.y + 11, player.w - 6, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF183848),
    );

    // Glowing cyan visor with directional bias
    final visorX = facingRight ? player.x + 5 : player.x + 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(visorX, player.y + 4, player.w - 7, 5),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4FF3D6),
    );
    // Visor specular gleam
    canvas.drawCircle(
      Offset(visorX + (facingRight ? player.w - 9 : 2), player.y + 6),
      1.2,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    _text(
      canvas,
      'THE NUMBER IS COLLISION GEOMETRY',
      const Offset(24, 505),
      10,
      const Color(0xFF9BC6D1),
      bold: true,
    );
    if (game._pulse > 0) {
      canvas.drawRect(
        full.deflate(5 + (1 - game._pulse) * 8),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(
            0xFF64F6DB,
          ).withValues(alpha: game._pulse * .55),
      );
    }
    canvas.restore();
  }

  void _drawDigits(Canvas canvas) {
    final digits = numberfallDisplayDigits(game.score);
    final preview = game._pendingRewrite == null
        ? null
        : numberfallDisplayDigits(game._pendingRewrite!.targetScore);
    for (var index = 0; index < 3; index++) {
      final x = game._startX + index * (game._digitWidth + game._gap);
      final pieces = game._segmentsForDigit(digits[index], x, game._top);
      final active = _NumberfallGame._segments[digits[index]]!.toSet();
      final previewActive = preview == null
          ? active
          : _NumberfallGame._segments[preview[index]]!.toSet();
      for (final entry in pieces.entries) {
        final lit = active.contains(entry.key);
        final willBeLit = previewActive.contains(entry.key);
        for (final rect in entry.value) {
          if (lit) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(8)),
              Paint()..color = const Color(0xFF60F8DC).withValues(alpha: .24),
            );
          }
          final paint = Paint()
            ..color = lit
                ? const Color(0xFF60F8DC)
                : const Color(0xFF2E7781).withValues(alpha: .11);
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(6)),
            paint,
          );
          if (lit) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(6)),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = const Color(0xFFE2FFFC).withValues(alpha: .85),
            );
          }
          if (preview != null && lit != willBeLit) {
            final previewColor = willBeLit
                ? const Color(0xFFFFE66D)
                : const Color(0xFFFF7B91);
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(6)),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = previewColor.withValues(
                  alpha: .35 + game.rewriteFraction * .55,
                ),
            );
          }
        }
      }
      _text(
        canvas,
        'DIGIT ${index + 1}',
        Offset(x + game._digitWidth / 2, game._top - 24),
        9,
        const Color(0xFF8AB5BF),
        center: true,
        bold: true,
      );
    }
    if (preview != null) {
      _text(
        canvas,
        'PREVIEW ${preview.join()} · COMMIT ${(game.rewriteFraction * 100).round()}%',
        const Offset(480, 414),
        12,
        const Color(0xFFFFEAA0),
        center: true,
        bold: true,
      );
    }
  }

  void _drawExit(Canvas canvas) {
    final platform = game.exitPlatform;
    final door = game.exitDoor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(platform, const Radius.circular(5)),
      Paint()..color = const Color(0xFF357B75),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(14)),
      Paint()..color = const Color(0xFF65F6DB).withValues(alpha: .22),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFB8FFF0),
    );
    _text(
      canvas,
      'EXIT',
      door.center + const Offset(0, 4),
      10,
      const Color(0xFFD9FFF8),
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
  bool shouldRepaint(covariant _NumberPainter oldDelegate) => true;
}
