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
      if (!dash.isAvailable) continue;
      final alpha = dash.isFading ? .08 + dash.opacity * .2 : .16;
      canvas.drawRRect(
        RRect.fromRectAndRadius(dash.rect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF64F6DB).withValues(alpha: alpha),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(dash.rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFA5FFF4).withValues(alpha: alpha * 2.5),
      );
    }
    _drawDigits(canvas);
    if (game.exitOpen) _drawExit(canvas);
    for (final pickup in game.pickupsOnField) {
      final p = pickup.position;
      final color = pickup.risky
          ? const Color(0xFFFF9F68)
          : const Color(0xFFFFE66D);
      canvas.drawCircle(p, 24, Paint()..color = color.withValues(alpha: .14));
      canvas.drawCircle(p, 15, Paint()..color = color);
      _text(
        canvas,
        '+${pickup.delta}',
        p + const Offset(0, 5),
        12,
        const Color(0xFF172216),
        center: true,
        bold: true,
      );
    }
    if (game.enemy.alive) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(game.enemy.rect, const Radius.circular(6)),
        Paint()..color = const Color(0xFFFF6C7C),
      );
      canvas.drawRect(
        Rect.fromLTWH(game.enemy.x + 5, game.enemy.y + 7, 4, 4),
        Paint()..color = const Color(0xFF2B0B10),
      );
      canvas.drawRect(
        Rect.fromLTWH(game.enemy.x + 16, game.enemy.y + 7, 4, 4),
        Paint()..color = const Color(0xFF2B0B10),
      );
    }
    final player = game.player;
    canvas.drawRRect(
      RRect.fromRectAndRadius(player.rect, const Radius.circular(6)),
      Paint()..color = const Color(0xFFF3FDFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(player.x + 5, player.y + 13, 4, 4),
      Paint()..color = const Color(0xFF09202A),
    );
    canvas.drawRect(
      Rect.fromLTWH(player.x + 13, player.y + 13, 4, 4),
      Paint()..color = const Color(0xFF09202A),
    );
    canvas.drawRect(
      Rect.fromLTWH(player.x + 5, player.y, 12, 7),
      Paint()..color = const Color(0xFF64F6DB),
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
                ..strokeWidth = 1
                ..color = const Color(0xFFC9FFFC).withValues(alpha: .7),
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
