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
    canvas.drawColor(const Color(0xFF04050A), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    final screen = const Rect.fromLTWH(
      0,
      0,
      _EchoHeist.width,
      _EchoHeist.height,
    );
    canvas.drawRect(
      screen,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.8),
          radius: 1.45,
          colors: [Color(0xFF222942), Color(0xFF0A0D18), Color(0xFF030408)],
        ).createShader(screen),
    );
    canvas.save();
    canvas.clipRect(screen);
    canvas.translate(-heist.camera.dx, -heist.camera.dy);
    final visible = heist.visibleWorld.inflate(90);
    _drawArchive(canvas, visible);
    _drawShards(canvas, visible);
    _drawExit(canvas, visible);
    _drawEcho(canvas, visible);
    _drawWarden(canvas, visible);
    _drawPlayer(canvas);
    _drawSightFog(canvas, heist.visibleWorld);
    canvas.restore();
    _drawFrame(canvas, screen);
    canvas.restore();
  }

  void _drawArchive(Canvas canvas, Rect visible) {
    final world = heist.world;
    canvas.drawRect(world, Paint()..color = const Color(0xFF0A0E1B));
    final grid = Paint()
      ..color = const Color(0xFF7580B9).withValues(alpha: .045)
      ..strokeWidth = 1;
    for (var x = 0.0; x < world.right; x += 48) {
      if (x >= visible.left - 48 && x <= visible.right + 48) {
        canvas.drawLine(
          Offset(x, visible.top),
          Offset(x, visible.bottom),
          grid,
        );
      }
    }
    for (var y = 0.0; y < world.bottom; y += 48) {
      if (y >= visible.top - 48 && y <= visible.bottom + 48) {
        canvas.drawLine(
          Offset(visible.left, y),
          Offset(visible.right, y),
          grid,
        );
      }
    }
    for (final gate in heist.gates) {
      if (!gate.passage.overlaps(visible)) continue;
      _drawGate(canvas, gate);
    }
    for (final room in heist.rooms) {
      if (!room.bounds.overlaps(visible)) continue;
      _drawRoom(canvas, room);
    }
    for (final gate in heist.gates) {
      if (!gate.passage.overlaps(visible)) continue;
      _drawDoorFace(canvas, gate);
    }
  }

  void _drawRoom(Canvas canvas, _HabitRoom room) {
    final core = room.id == heist.wardenRoom.id;
    final entry = room.id == heist.entryRoom.id;
    final bounds = room.bounds;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bounds.shift(const Offset(5, 7)),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xB8000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(14)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: core
              ? const [Color(0xFF2A183D), Color(0xFF15152B), Color(0xFF100F20)]
              : entry
              ? const [Color(0xFF16322E), Color(0xFF111D28), Color(0xFF0C1320)]
              : const [Color(0xFF202640), Color(0xFF131A2B), Color(0xFF0C1220)],
        ).createShader(bounds),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(5), const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = (core ? const Color(0xFFFF79BE) : const Color(0xFF6576A6))
            .withValues(alpha: core ? .65 : .3),
    );
    final paper = Paint()
      ..color = const Color(0xFFAFC7F2).withValues(alpha: .05)
      ..strokeWidth = 1;
    for (var x = bounds.left + 26; x < bounds.right - 12; x += 34) {
      canvas.drawLine(
        Offset(x, bounds.top + 18),
        Offset(x + 14, bounds.bottom - 18),
        paper,
      );
    }
    final label = core
        ? 'WARDEN CORE'
        : entry
        ? 'BREACH'
        : 'ARCHIVE ${room.id.toString().padLeft(2, '0')}';
    paintGameText(
      canvas,
      label,
      bounds.topLeft + const Offset(16, 20),
      8,
      core ? const Color(0xFFFFA4D3) : const Color(0xFF8FA2CB),
      bold: true,
    );
  }

  void _drawGate(Canvas canvas, _HabitGate gate) {
    final open = heist.isGateOpen(gate);
    final rewired = heist.isGateRewired(gate);
    final sealed = heist.sealedGateIds.contains(gate.id);
    final color = rewired
        ? const Color(0xFFFF62B0)
        : open
        ? const Color(0xFF5971A5)
        : const Color(0xFF3A3B58);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        gate.passage.inflate(5),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF05070E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gate.passage, const Radius.circular(6)),
      Paint()..color = color.withValues(alpha: open ? .62 : .2),
    );
    if (rewired) {
      final pulse = .45 + math.sin(heist.time * 10 + gate.id) * .2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          gate.passage.inflate(3),
          const Radius.circular(8),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFF8FCB).withValues(alpha: pulse),
      );
      final direction = heist.warden - gate.passage.center;
      final normal = direction.distance < 1
          ? const Offset(1, 0)
          : direction / direction.distance;
      _arrow(canvas, gate.passage.center, normal, 13, const Color(0xFFFFB1D8));
    }
    if (sealed) {
      final p = Paint()
        ..color = const Color(0xFFFF5E84).withValues(alpha: .72)
        ..strokeWidth = 3;
      canvas.drawLine(gate.passage.topLeft, gate.passage.bottomRight, p);
      canvas.drawLine(gate.passage.bottomLeft, gate.passage.topRight, p);
    }
  }

  void _drawDoorFace(Canvas canvas, _HabitGate gate) {
    final horizontal = gate.passage.width > gate.passage.height;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = heist.isGateRewired(gate)
          ? const Color(0xFFFFB4D9)
          : const Color(0xFFB6C7E8).withValues(alpha: .22);
    if (horizontal) {
      canvas.drawLine(gate.passage.topLeft, gate.passage.topRight, edge);
      canvas.drawLine(gate.passage.bottomLeft, gate.passage.bottomRight, edge);
    } else {
      canvas.drawLine(gate.passage.topLeft, gate.passage.bottomLeft, edge);
      canvas.drawLine(gate.passage.topRight, gate.passage.bottomRight, edge);
    }
  }

  void _drawShards(Canvas canvas, Rect visible) {
    for (final shard in heist.shards) {
      if (shard.collected || !visible.contains(shard.position)) continue;
      final pulse =
          1 + math.sin(heist.time * 5 + shard.position.dx * .01) * .12;
      canvas.save();
      canvas.translate(shard.position.dx, shard.position.dy);
      canvas.rotate(heist.time * .9);
      canvas.drawCircle(
        Offset.zero,
        27 * pulse,
        Paint()..color = const Color(0xFFFFD96C).withValues(alpha: .1),
      );
      final diamond = Path()
        ..moveTo(0, -15)
        ..lineTo(11, 0)
        ..lineTo(0, 15)
        ..lineTo(-11, 0)
        ..close();
      canvas.drawPath(diamond, Paint()..color = const Color(0xFFFFD96C));
      canvas.drawPath(
        diamond,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFF2B2),
      );
      canvas.restore();
      paintGameText(
        canvas,
        'TRUTH',
        shard.position + const Offset(0, -27),
        7,
        const Color(0xFFFFE8A1),
        align: TextAlign.center,
        bold: true,
      );
    }
  }

  void _drawExit(Canvas canvas, Rect visible) {
    if (!visible.inflate(80).contains(heist.exit)) return;
    final color = heist.exitOpen
        ? const Color(0xFF78F5C1)
        : const Color(0xFF607092);
    final pulse = heist.exitOpen ? 1 + math.sin(heist.time * 6) * .1 : 1.0;
    canvas.drawCircle(
      heist.exit,
      30 * pulse,
      Paint()..color = color.withValues(alpha: .12),
    );
    canvas.drawCircle(
      heist.exit,
      20,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color,
    );
    _arrow(canvas, heist.exit, const Offset(-1, 0), 14, color);
    paintGameText(
      canvas,
      heist.exitOpen ? 'BREACH OPEN' : 'BREACH LOCKED',
      heist.exit + const Offset(0, 37),
      8,
      color,
      align: TextAlign.center,
      bold: true,
    );
  }

  void _drawEcho(Canvas canvas, Rect visible) {
    final echo = heist.echo;
    if (echo == null || !visible.inflate(60).contains(echo.position)) return;
    final glow = Paint()
      ..color = const Color(0xFF8BB5FF).withValues(alpha: .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(echo.position, 27 + math.sin(heist.time * 8) * 3, glow);
    canvas.drawCircle(
      echo.position,
      11,
      Paint()..color = const Color(0xFF8BB5FF).withValues(alpha: .55),
    );
    canvas.drawCircle(
      echo.position + const Offset(4, -2),
      3,
      Paint()..color = Colors.white,
    );
    paintGameText(
      canvas,
      'ECHO',
      echo.position + const Offset(0, -28),
      7,
      const Color(0xFFB7D3FF),
      align: TextAlign.center,
      bold: true,
    );
  }

  void _drawWarden(Canvas canvas, Rect visible) {
    if (!visible.inflate(120).contains(heist.warden)) return;
    final active = heist.wardenReading;
    final pulse = 1 + math.sin(heist.time * (active ? 9 : 3)) * .08;
    final outer = active ? const Color(0xFFFF609D) : const Color(0xFFA47CFF);
    canvas.drawCircle(
      heist.warden,
      68 * pulse,
      Paint()..color = outer.withValues(alpha: active ? .13 : .07),
    );
    for (var index = 0; index < 8; index++) {
      final angle = heist.time * .35 + index * math.pi * 2 / 8;
      final start =
          heist.warden + Offset(math.cos(angle), math.sin(angle)) * 34;
      final end = heist.warden + Offset(math.cos(angle), math.sin(angle)) * 54;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = outer.withValues(alpha: .7)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      heist.warden,
      31,
      Paint()..color = const Color(0xFF241A3B),
    );
    canvas.drawCircle(
      heist.warden,
      31,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = outer,
    );
    canvas.drawOval(
      Rect.fromCenter(center: heist.warden, width: 31, height: 15),
      Paint()..color = const Color(0xFF080711),
    );
    canvas.drawCircle(
      heist.warden,
      6 + math.sin(heist.time * 8) * 1.5,
      Paint()
        ..color = active ? const Color(0xFFFFB0CF) : const Color(0xFFD0BEFF),
    );
    paintGameText(
      canvas,
      active ? 'READING' : 'WARDEN',
      heist.warden + const Offset(0, -47),
      9,
      outer,
      align: TextAlign.center,
      bold: true,
    );
  }

  void _drawPlayer(Canvas canvas) {
    final movingGlow = 1 + math.sin(heist.time * 8) * .08;
    canvas.drawCircle(
      heist.player,
      26 * movingGlow,
      Paint()..color = const Color(0xFF68E7FF).withValues(alpha: .14),
    );
    canvas.drawCircle(
      heist.player + const Offset(0, 8),
      13,
      Paint()..color = const Color(0xFF07101C),
    );
    final body = Path()
      ..moveTo(heist.player.dx - 11, heist.player.dy + 9)
      ..quadraticBezierTo(
        heist.player.dx - 13,
        heist.player.dy - 7,
        heist.player.dx,
        heist.player.dy - 14,
      )
      ..quadraticBezierTo(
        heist.player.dx + 13,
        heist.player.dy - 7,
        heist.player.dx + 11,
        heist.player.dy + 9,
      )
      ..quadraticBezierTo(
        heist.player.dx,
        heist.player.dy + 15,
        heist.player.dx - 11,
        heist.player.dy + 9,
      )
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF65DDF7));
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE1FBFF),
    );
    canvas.drawCircle(
      heist.player + const Offset(4, -3),
      3,
      Paint()..color = const Color(0xFF07121D),
    );
  }

  void _drawSightFog(Canvas canvas, Rect visible) {
    final shader = RadialGradient(
      colors: [
        Colors.transparent,
        const Color(0x1A02030A),
        const Color(0xA604050A),
      ],
      stops: const [0, .55, 1],
    ).createShader(Rect.fromCircle(center: heist.player, radius: 355));
    canvas.drawRect(visible, Paint()..shader = shader);
  }

  void _drawFrame(Canvas canvas, Rect screen) {
    final heat = (heist.heat / 100).clamp(0.0, 1.0);
    canvas.drawRect(
      screen.deflate(5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = heist.wardenReading ? 3 : 1.5
        ..color = Color.lerp(
          const Color(0xFF536489),
          const Color(0xFFFF537F),
          heat,
        )!,
    );
    if (heist.isFolding) {
      canvas.drawRect(
        screen,
        Paint()..color = const Color(0xFFFF4F99).withValues(alpha: .035),
      );
    }
  }

  void _arrow(
    Canvas canvas,
    Offset center,
    Offset direction,
    double size,
    Color color,
  ) {
    final normal = Offset(-direction.dy, direction.dx);
    final tip = center + direction * size;
    final base = center - direction * size * .65;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + normal * size * .55).dx, (base + normal * size * .55).dy)
      ..lineTo((base - normal * size * .55).dx, (base - normal * size * .55).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HeistPainter oldDelegate) => true;
}
