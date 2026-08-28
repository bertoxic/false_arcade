part of 'edge_load_game.dart';

class _EdgeLoadPainter extends CustomPainter {
  _EdgeLoadPainter(this.game);
  final _MansionGame game;

  static const _night = Color(0xFF05070B);

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_MansionGame.width, _MansionGame.height),
    );
    canvas.drawColor(_night, BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    _drawScene(canvas);
    _drawHud(canvas);
    canvas.restore();
  }

  void _drawScene(Canvas canvas) {
    final v = game.viewRect;
    canvas.save();
    canvas.clipRect(v);
    canvas.translate(v.left - game.camera.dx, v.top - game.camera.dy);
    final visible = Rect.fromLTWH(
      game.camera.dx,
      game.camera.dy,
      v.width,
      v.height,
    );
    canvas.drawRect(
      visible.inflate(50),
      Paint()..color = const Color(0xFF070B12),
    );
    _drawGround(canvas, visible);
    _drawCorridors(canvas);
    _drawRooms(canvas);
    _drawExit(canvas);
    _drawPickups(canvas);
    _drawVision(canvas);
    _drawWalls(canvas);
    _drawCovers(canvas);
    _drawCoins(canvas);
    for (final guard in game.guards)
      _drawPerson(
        canvas,
        guard.position,
        guard.face,
        guard.walkTime,
        guard.moveAmount,
        guard: guard,
      );
    _drawPerson(
      canvas,
      game.player.position,
      game.player.face,
      game.player.walkTime,
      game.player.moveAmount,
    );
    _drawPrompt(canvas);
    _drawFog(canvas, visible);
    canvas.restore();
    canvas.drawRect(
      v,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = game.vaultTaken
            ? const Color(0xFF6ED8FF)
            : const Color(0xBFF3BD58),
    );
    for (var i = 0; i < game.cargoCount; i++) _drawCargoTag(canvas, v, i);
  }

  void _drawGround(Canvas canvas, Rect visible) {
    final checker = Paint()
      ..color = const Color(0xFF2A3A4C).withValues(alpha: .12);
    for (
      double x = (visible.left / 64).floor() * 64;
      x < visible.right + 64;
      x += 64
    ) {
      for (
        double y = (visible.top / 64).floor() * 64;
        y < visible.bottom + 64;
        y += 64
      ) {
        if (((x / 64 + y / 64).floor() & 2) == 0)
          canvas.drawRect(Rect.fromLTWH(x, y, 64, 64), checker);
      }
    }
  }

  void _drawRooms(Canvas canvas) {
    for (final room in game.rooms) {
      canvas.drawRect(room.rect, Paint()..color = const Color(0xFF101722));
      canvas.drawRect(
        room.rect.deflate(8),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF6B87AB).withValues(alpha: .18),
      );
      final rug = Rect.fromCenter(
        center: room.rect.center,
        width: room.rect.width * .56,
        height: room.rect.height * .56,
      );
      canvas.drawRect(
        rug,
        Paint()..color = const Color(0xFF465B77).withValues(alpha: .08),
      );
      canvas.drawRect(
        rug,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF7897BE).withValues(alpha: .08),
      );
    }
    final grid = Paint()
      ..color = const Color(0xFF7390B5).withValues(alpha: .05)
      ..strokeWidth = 1;
    for (double x = 0; x <= _MansionGame.mansionWidth; x += 32)
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, _MansionGame.mansionHeight),
        grid,
      );
    for (double y = 0; y <= _MansionGame.mansionHeight; y += 32)
      canvas.drawLine(Offset(0, y), Offset(_MansionGame.mansionWidth, y), grid);
    _drawWalls(canvas);
  }

  void _drawCorridors(Canvas canvas) {
    final floor = Paint()..color = const Color(0xFF162235);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF6384AD).withValues(alpha: .3);
    for (final corridor in game.corridors) {
      canvas.drawRect(corridor.rect, floor);
      canvas.drawRect(corridor.rect.deflate(3), edge);
      final center = corridor.rect.center;
      if (corridor.rect.width > corridor.rect.height) {
        canvas.drawLine(
          Offset(corridor.rect.left + 8, center.dy),
          Offset(corridor.rect.right - 8, center.dy),
          Paint()
            ..color = const Color(0xFF9FB8D7).withValues(alpha: .14)
            ..strokeWidth = 1,
        );
      } else {
        canvas.drawLine(
          Offset(center.dx, corridor.rect.top + 8),
          Offset(center.dx, corridor.rect.bottom - 8),
          Paint()
            ..color = const Color(0xFF9FB8D7).withValues(alpha: .14)
            ..strokeWidth = 1,
        );
      }
    }
  }

  void _drawWalls(Canvas canvas) {
    final wall = Paint()
      ..color = const Color(0xFF30405A)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.square;
    for (final segment in game.walls) {
      canvas.drawLine(segment.a, segment.b, wall);
    }
  }

  void _drawCovers(Canvas canvas) {
    for (final cover in game.covers) {
      final bounds = cover.bounds;
      final shadow = bounds.shift(const Offset(3, 5));
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadow, const Radius.circular(4)),
        Paint()..color = const Color(0xAA020407),
      );
      if (cover.shape == _CoverShape.partition) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(3)),
          Paint()..color = const Color(0xFF3B4D67),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds.deflate(3), const Radius.circular(1)),
          Paint()..color = const Color(0xFF637A96),
        );
        final horizontal = bounds.width > bounds.height;
        final line = Paint()
          ..color = const Color(0xFFB2C9E3).withValues(alpha: .28)
          ..strokeWidth = 1.2;
        if (horizontal) {
          canvas.drawLine(
            Offset(bounds.left + 8, bounds.center.dy),
            Offset(bounds.right - 8, bounds.center.dy),
            line,
          );
        } else {
          canvas.drawLine(
            Offset(bounds.center.dx, bounds.top + 8),
            Offset(bounds.center.dx, bounds.bottom - 8),
            line,
          );
        }
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(7)),
          Paint()..color = const Color(0xFF46566C),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds.deflate(4), const Radius.circular(4)),
          Paint()..color = const Color(0xFF71859B),
        );
        canvas.drawCircle(
          bounds.center - const Offset(4, 4),
          5,
          Paint()..color = const Color(0xFFB7CCE2).withValues(alpha: .24),
        );
      }
    }
  }

  void _drawExit(Canvas canvas) {
    final glow = game.vaultTaken
        ? const Color(0xFF72F1B8)
        : const Color(0xFF506074);
    final pulse = 1 + math.sin(game.time * 2) * .08;
    canvas.drawCircle(
      game.exit,
      29 * pulse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = glow,
    );
    canvas.drawCircle(
      game.exit,
      23,
      Paint()..color = glow.withValues(alpha: .12),
    );
  }

  void _drawPickups(Canvas canvas) {
    for (final l in game.loot) {
      if (l.taken) continue;
      canvas.save();
      canvas.translate(l.position.dx, l.position.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
        Paint()..color = const Color(0xFFF3BD58),
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFFE4A5),
      );
      canvas.restore();
    }
    if (!game.vaultTaken) {
      final scale = 1 + math.sin(game.time * 4) * .08;
      final diamond = Path()
        ..moveTo(game.vault.dx, game.vault.dy - 17 * scale)
        ..lineTo(game.vault.dx + 13 * scale, game.vault.dy)
        ..lineTo(game.vault.dx, game.vault.dy + 17 * scale)
        ..lineTo(game.vault.dx - 13 * scale, game.vault.dy)
        ..close();
      canvas.drawPath(diamond, Paint()..color = const Color(0xFF7FE3FF));
      canvas.drawPath(
        diamond,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFD8F8FF),
      );
      canvas.drawCircle(
        game.vault,
        35 + math.sin(game.time * 3) * 4,
        Paint()..color = const Color(0xFF7FE3FF).withValues(alpha: .08),
      );
    }
    for (final k in game.kits) {
      if (k.taken) continue;
      final pulse = 1 + math.sin(game.time * 5 + k.position.dx * .01) * .12;
      canvas.drawCircle(
        k.position,
        22 * pulse,
        Paint()..color = const Color(0xFF86FFBE).withValues(alpha: .12),
      );
      final r = Rect.fromCenter(center: k.position, width: 16, height: 16);
      canvas.drawRect(r, Paint()..color = const Color(0xFF86FFBE));
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFD8FFE9),
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: k.position + const Offset(0, -2),
          width: 10,
          height: 3,
        ),
        Paint()..color = const Color(0xFF123727),
      );
      canvas.drawRect(
        Rect.fromCenter(center: k.position, width: 4, height: 16),
        Paint()..color = const Color(0xFF123727),
      );
    }
  }

  void _drawVision(Canvas canvas) {
    for (final g in game.guards) {
      final vision = g.advanced ? 255.0 : 210.0;
      final half = g.advanced ? .8 : .95;
      final path = Path()..moveTo(g.position.dx, g.position.dy);
      // Each ray terminates at its first wall. The guard's view now wraps
      // around room geometry and only spills through a genuine doorway.
      const rays = 56;
      for (var index = 0; index <= rays; index++) {
        final angle = g.face - half + half * 2 * index / rays;
        final distance = game._rayWallDistance(g.position, angle, vision);
        final end =
            g.position + Offset(math.cos(angle), math.sin(angle)) * distance;
        path.lineTo(end.dx, end.dy);
      }
      path.close();
      final alert = g.state == _GuardState.alert;
      canvas.drawPath(
        path,
        Paint()
          ..color = (alert ? const Color(0xFFFF4F5E) : const Color(0xFFFFCD69))
              .withValues(alpha: alert ? .14 : .055),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = (alert ? const Color(0xFFFF5F69) : const Color(0xFFFFDC82))
              .withValues(alpha: .1),
      );
    }
  }

  void _drawCoins(Canvas canvas) {
    for (final c in game.coins) {
      canvas.drawCircle(
        c.position,
        5,
        Paint()..color = const Color(0xFFF4D67B),
      );
      if (c.popped) {
        final age = -c.timer;
        canvas.drawCircle(
          c.position,
          30 + age * 120,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(
              0xFFF4D67B,
            ).withValues(alpha: (1 - age).clamp(0, 1)),
        );
      }
    }
  }

  void _drawPerson(
    Canvas canvas,
    Offset at,
    double face,
    double walk,
    double move, {
    _Guard? guard,
  }) {
    final advanced = guard?.advanced ?? false,
        alert = guard?.state == _GuardState.alert;
    final color = guard == null
        ? (game.player.disguise > 0
              ? const Color(0xFFB9C0CB)
              : const Color(0xFF72D6FF))
        : advanced
        ? (alert ? const Color(0xFFFF5D70) : const Color(0xFFA995FF))
        : (alert
              ? const Color(0xFFFF4F5E)
              : guard.state == _GuardState.search
              ? const Color(0xFFFF9966)
              : const Color(0xFFB9C0CB));
    final bob = math.sin(walk).abs() * 1.7 * move,
        swing = math.sin(walk) * 6 * move;
    if (alert)
      canvas.drawCircle(
        at,
        18 + math.sin(game.time * 8 + at.dx) * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFF4F5E).withValues(alpha: .55),
      );
    canvas.save();
    canvas.translate(at.dx, at.dy - bob);
    canvas.rotate(face);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 11 + bob), width: 28, height: 12),
      Paint()..color = const Color(0xFF000000).withValues(alpha: .38),
    );
    final leg = Paint()
      ..color = const Color(0xFF151B24)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-4, -4), Offset(-10, -6 + swing), leg);
    canvas.drawLine(const Offset(-4, 4), Offset(-10, 6 - swing), leg);
    final arm = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, -6), Offset(5, -10 - swing * .35), arm);
    canvas.drawLine(const Offset(0, 6), Offset(5, 10 + swing * .35), arm);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 19, height: 15),
      Paint()..color = color,
    );
    canvas.drawCircle(
      const Offset(9, 0),
      5.1,
      Paint()..color = const Color(0xFFD9C7B0),
    );
    canvas.drawRect(
      const Rect.fromLTWH(9, -4, 4, 8),
      Paint()..color = const Color(0xFF0B0F15),
    );
    if (advanced) {
      canvas.drawRect(
        const Rect.fromLTWH(-5, -7, 8, 14),
        Paint()..color = const Color(0xFF2D244D),
      );
      canvas.drawLine(
        const Offset(4, 7),
        const Offset(17, 8),
        Paint()
          ..color = const Color(0xFFD9CDFF)
          ..strokeWidth = 2.4,
      );
    }
    if (guard == null && game.sprinting && move > .35) {
      final streak = Paint()
        ..color = const Color(0xFF72D6FF).withValues(alpha: .28)
        ..strokeWidth = 2;
      for (var i = 0; i < 3; i++)
        canvas.drawLine(
          Offset(-12 - i * 6, -5 + i * 5),
          Offset(-25 - i * 8, -5 + i * 5),
          streak,
        );
    }
    if (guard == null && game.player.disguise > 0)
      canvas.drawCircle(
        Offset.zero,
        15 + math.sin(game.time * 10) * 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF86FFBE).withValues(alpha: .8),
      );
    canvas.restore();
    if (guard != null && guard.state != _GuardState.patrol)
      paintGameText(
        canvas,
        guard.state == _GuardState.alert
            ? '!'
            : guard.state == _GuardState.search
            ? '?'
            : '…',
        at + Offset(0, -31 + math.sin(game.time * 5 + at.dx) * 2),
        18,
        alert ? const Color(0xFFFF6672) : const Color(0xFFFFD36B),
        align: TextAlign.center,
        bold: true,
      );
  }

  void _drawPrompt(Canvas canvas) {
    final p = game.player.position;
    String text = '';
    Offset at = p + const Offset(0, -35);
    for (final k in game.kits) {
      if (!k.taken && (k.position - p).distance < 54) {
        text = 'DISGUISE KIT';
        at = k.position + const Offset(0, -32);
      }
    }
    if (text.isEmpty && !game.vaultTaken && (game.vault - p).distance < 58) {
      text = 'STEAL DIAMOND';
      at = game.vault + const Offset(0, -36);
    }
    if (text.isEmpty)
      for (final l in game.loot) {
        if (!l.taken && (l.position - p).distance < 50) {
          text = 'LOOT \$${l.value}';
          at = l.position + const Offset(0, -30);
        }
      }
    if (text.isEmpty && (game.exit - p).distance < 62) {
      text = game.extractionReady
          ? 'EXTRACT'
          : game.vaultTaken
          ? 'NEED ${game.requiredLootCount - game.player.lootCount} MORE LOOT'
          : 'EXTRACTION LOCKED';
      at = game.exit + const Offset(0, -42);
    }
    if (text.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawRect(
        Rect.fromCenter(
          center: at + const Offset(0, 4),
          width: tp.width + 18,
          height: 22,
        ),
        Paint()..color = const Color(0xD603070C),
      );
      paintGameText(
        canvas,
        text,
        at,
        12,
        const Color(0xFFD9E8FF),
        align: TextAlign.center,
        bold: true,
      );
    }
  }

  void _drawFog(Canvas canvas, Rect visible) {
    final p = game.player.position;
    final shader = RadialGradient(
      colors: [
        Colors.transparent,
        const Color(0x1A000000),
        const Color(0x94000000),
      ],
      stops: const [0, .6, 1],
    ).createShader(Rect.fromCircle(center: p, radius: 330));
    canvas.drawRect(visible, Paint()..shader = shader);
  }

  void _drawCargoTag(Canvas canvas, Rect v, int index) {
    final t = (index + .5) / math.max(1, game.cargoCount), side = index % 4;
    final paint = Paint()
      ..color = index == 0 && game.vaultTaken
          ? const Color(0xFF72D6FF)
          : const Color(0xFFF3BD58);
    if (side == 0)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(v.left + 16 + (v.width - 32) * t, v.top),
          width: 8,
          height: 14,
        ),
        paint,
      );
    if (side == 1)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(v.right, v.top + 16 + (v.height - 32) * t),
          width: 14,
          height: 8,
        ),
        paint,
      );
    if (side == 2)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(v.right - 16 - (v.width - 32) * t, v.bottom),
          width: 8,
          height: 14,
        ),
        paint,
      );
    if (side == 3)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(v.left, v.bottom - 16 - (v.height - 32) * t),
          width: 14,
          height: 8,
        ),
        paint,
      );
  }

  void _drawHud(Canvas canvas) {
    // Sit in the far top-right without overlapping the pause button. Its
    // footprint is 20% smaller than the previous minimap.
    _drawMap(canvas, Rect.fromLTWH(_MansionGame.width - 94, 30, 84, 62));
  }

  void _drawMap(Canvas canvas, Rect r) {
    canvas.drawRect(r, Paint()..color = const Color(0xE005090F));
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF263246),
    );
    final s = math.min(
          (r.width - 4) / _MansionGame.mansionWidth,
          (r.height - 4) / _MansionGame.mansionHeight,
        ),
        o = Offset(r.left + 2, r.top + 2);
    for (final room in game.rooms)
      canvas.drawRect(
        Rect.fromLTWH(
          o.dx + room.rect.left * s,
          o.dy + room.rect.top * s,
          room.rect.width * s,
          room.rect.height * s,
        ),
        Paint()..color = const Color(0xFF2C394D),
      );
    for (final g in game.guards) {
      if (g.state != _GuardState.patrol || g.advanced) {
        canvas.drawCircle(
          o + g.position * s,
          g.advanced ? 2.8 : 2.2,
          Paint()
            ..color = g.advanced
                ? const Color(0xFFAA96FF)
                : const Color(0xFFE2B860),
        );
      }
    }
    canvas.drawCircle(
      o + game.player.position * s,
      3,
      Paint()..color = Colors.white,
    );
    if (!game.vaultTaken)
      canvas.drawRect(
        Rect.fromCenter(center: o + game.vault * s, width: 4, height: 4),
        Paint()..color = const Color(0xFF72D6FF),
      );
  }

  @override
  bool shouldRepaint(covariant _EdgeLoadPainter oldDelegate) => true;
}
