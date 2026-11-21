part of 'fall_due_game.dart';

extension _DueEncounterArt on _FallPainter {
  void _drawEncounterShadow(
    Canvas canvas,
    Offset at,
    double width, {
    bool overSpikes = false,
  }) {
    final rect = Rect.fromCenter(center: at, width: width, height: 16);
    canvas.drawOval(
      rect,
      _dueShade(
        rect,
        [const Color(0x880F1020), const Color(0x00101020)],
        center: Alignment.center,
        radius: .5,
      ),
    );
  }

  void _drawGravityCreature(
    Canvas canvas,
    Offset at,
    double radius,
    Color color, {
    bool fierce = false,
  }) {
    final dark = Color.lerp(color, _dueInk, .67)!;
    final bright = Color.lerp(color, Colors.white, .65)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final side in [-1, 1]) {
      final wing = Path()
        ..moveTo(at.dx + side * radius * .55, at.dy - radius * .35)
        ..quadraticBezierTo(
          at.dx + side * radius * 1.55,
          at.dy - radius * 1.05,
          at.dx + side * radius * 1.35,
          at.dy - radius * .08,
        )
        ..quadraticBezierTo(
          at.dx + side * radius * .95,
          at.dy + radius * .15,
          at.dx + side * radius * .55,
          at.dy + radius * .05,
        )
        ..close();
      canvas.drawPath(
        wing,
        _dueGradient(wing.getBounds(), [bright, color, dark]),
      );
      canvas.drawPath(wing, outline);
      final foot = Rect.fromCenter(
        center: at.translate(side * radius * .48, radius * .78),
        width: radius * .37,
        height: radius * .55,
      );
      canvas.drawOval(foot, _dueGradient(foot, [color, dark]));
      canvas.drawOval(foot, outline);
    }
    final body = Rect.fromCenter(
      center: at,
      width: radius * 2,
      height: radius * 1.85,
    );
    canvas.drawOval(
      body.shift(Offset(radius * .08, radius * .12)),
      Paint()..color = dark.withValues(alpha: .45),
    );
    canvas.drawOval(
      body,
      _dueShade(body, [
        bright,
        color,
        dark,
      ], center: const Alignment(-.38, -.55)),
    );
    canvas.drawOval(body, outline);
    for (final side in [-1, 1]) {
      final eye = Rect.fromCenter(
        center: at.translate(side * radius * .4, -radius * .06),
        width: radius * .38,
        height: radius * .46,
      );
      canvas.drawOval(eye, Paint()..color = const Color(0xFFFFF4CA));
      canvas.drawOval(eye, outline..strokeWidth = 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: eye.center.translate(side * radius * .025, radius * .03),
          width: radius * .14,
          height: radius * .23,
        ),
        Paint()..color = _dueInk,
      );
      if (fierce) {
        canvas.drawLine(
          eye.topLeft.translate(0, -2),
          eye.topRight.translate(0, 3),
          Paint()
            ..color = dark
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    final mouth = Path()
      ..moveTo(at.dx - radius * .14, at.dy + radius * .35)
      ..quadraticBezierTo(
        at.dx,
        at.dy + radius * (fierce ? .5 : .57),
        at.dx + radius * .14,
        at.dy + radius * .35,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: at.translate(-radius * .34, -radius * .55),
        width: radius * .48,
        height: radius * .19,
      ),
      Paint()..color = Colors.white.withValues(alpha: .42),
    );
  }

  void _drawRouteRig(Canvas canvas, _DueGravityWell well) {
    final rig = well.rig!;
    final at = well.center;
    final live = well.invertedTimer > 0;
    final light = live ? (well.drawing ? _dueGold : _dueBlue) : landscape.rim;
    _drawEncounterShadow(canvas, at.translate(0, 24), 149, overSpikes: true);
    final zone = Rect.fromLTRB(at.dx - 112, at.dy, at.dx + 112, at.dy + 184);
    final cone = _duePolygon([
      at.translate(-27, 4),
      at.translate(27, 4),
      zone.bottomRight,
      zone.bottomLeft,
    ]);
    canvas.drawPath(
      cone,
      _dueGradient(zone, [
        light.withValues(alpha: live ? .21 : .04),
        light.withValues(alpha: 0),
      ]),
    );
    canvas.save();
    canvas.clipPath(cone);
    final direction = well.drawing ? -1 : 1;
    for (final x in [-74.0, -38.0, 0.0, 38.0, 74.0]) {
      for (var row = 0; row < 4; row++) {
        final tick = (row * 44 + game.time * (live ? 75 : 18)) % 176;
        final d = direction > 0 ? 173 - tick : tick;
        final p = at.translate(x * (.31 + d / 200), d);
        final k = rig == _WellRig.ferry ? 8.0 : 3.5;
        canvas.drawLine(
          p,
          p.translate(k, -7.0 * direction),
          Paint()
            ..color = light.withValues(alpha: live ? .53 : .23)
            ..strokeWidth = 1.8,
        );
      }
    }
    canvas.restore();
    _drawGravityCreature(canvas, at, 36, const Color(0xFFDA6A91));
    _drawDueGem(canvas, at.translate(0, 24), 5, light);
    _badge(
      canvas,
      live
          ? (well.drawing ? 'CARGO DRAW' : 'CURRENT ACTIVE')
          : rig.title.toUpperCase(),
      at.translate(0, -53),
      light,
    );
    if (game._targetInRange(well) && !live) {
      _badge(canvas, 'GIVE · CURRENT', at.translate(0, 49), _dueBlue);
    }
  }

  void _drawNativeBoss(Canvas canvas, _DueBoss boss, Rect world) {
    if (!world.overlaps(boss.bounds)) return;
    final at = boss.center;
    _drawEncounterShadow(canvas, Offset(at.dx, 428), 205);
    final hot = boss.striking;
    final hazard = hot ? _dueCoral : _dueGold;
    if (boss.telegraph || hot) {
      for (final zone in boss.threatAreas(warningOnly: !hot)) {
        if (zone.isEmpty || !world.overlaps(zone)) continue;
        canvas.drawRect(
          zone,
          _dueGradient(zone, [
            hazard.withValues(alpha: .06),
            hazard.withValues(alpha: hot ? .61 : .24),
          ]),
        );
        canvas.drawRect(
          zone,
          Paint()
            ..color = hazard.withValues(alpha: .87)
            ..style = PaintingStyle.stroke
            ..strokeWidth = hot ? 3.4 : 1.4,
        );
        canvas.save();
        canvas.clipRect(zone);
        for (var x = zone.left - 12; x < zone.right; x += 19) {
          canvas.drawLine(
            Offset(x, zone.bottom),
            Offset(x + 12, zone.bottom - 9),
            Paint()
              ..color = hazard.withValues(alpha: .62)
              ..strokeWidth = 2.0,
          );
        }
        canvas.restore();
      }
    }
    final color = switch (boss.spec.first) {
      _BossAttack.rake => const Color(0xFFCE7199),
      _BossAttack.hammer => const Color(0xFFCB896A),
      _BossAttack.pulse => const Color(0xFFAC79B9),
      _BossAttack.flood => const Color(0xFF65A9B0),
      _BossAttack.rail => const Color(0xFF8A93C7),
      _BossAttack.shutters => const Color(0xFFC46288),
    };

    canvas.save();
    if (boss.stun > 0) {
      final wobble = math.sin(game.time * 22.0) * 0.12;
      canvas.translate(at.dx, at.dy);
      canvas.rotate(wobble);
      canvas.translate(-at.dx, -at.dy);
    }

    switch (boss.spec.name) {
      case 'Yard Bailiff':
        _drawYardBailiff(canvas, at, color, boss);
      case 'Span Keeper':
        _drawSpanKeeper(canvas, at, color, boss);
      case 'Collection Marshal':
        _drawCollectionMarshal(canvas, at, color, boss);
      case 'Sump Custodian':
        _drawSumpCustodian(canvas, at, color, boss);
      case 'Field Cartographer':
        _drawFieldCartographer(canvas, at, color, boss);
      case 'The Auditor':
      default:
        _drawTheAuditor(canvas, at, color, boss);
    }
    canvas.restore();

    // Render stun visual state with orbiting dizzy stars and countdown badge
    if (boss.stun > 0) {
      const starCount = 4;
      for (var s = 0; s < starCount; s++) {
        final angle = game.time * 6.5 + s * (2 * math.pi / starCount);
        final sx = at.dx + math.cos(angle) * 52.0;
        final sy = at.dy - 74.0 + math.sin(angle) * 15.0;
        _drawDueGem(canvas, Offset(sx, sy), 5.5, _dueGold);
        canvas.drawCircle(Offset(sx, sy), 2.0, Paint()..color = Colors.white);
      }
      _badge(
        canvas,
        'STUNNED ${boss.stun.toStringAsFixed(1)}s',
        at.translate(0, -98),
        _dueGold,
      );
    }

    final target = boss.exposed > 0 ? boss.core : boss.armor;
    final core = boss.exposed > 0;
    final light = boss.defeated || boss.recovering && !core
        ? _dueMint
        : core
        ? _dueCoral
        : _dueGold;
    if (!boss.defeated) {
      _dueGlow(
        canvas,
        target.center,
        core ? 27 : 18,
        light.withValues(alpha: .58),
      );
      _drawDueGem(canvas, target.center, core ? 8.5 : 6, light);
      if (boss.engaged) {
        final verb = core ? boss.finishing : boss.opening;
        _badge(
          canvas,
          '${core || boss.recovering ? verb.name.toUpperCase() : 'WAIT'} · ${target.label.toUpperCase()}',
          target.center.translate(0, 39),
          light,
        );
      }
    }
    if (boss.engaged || boss.defeated) {
      final title = Offset(at.dx, 118);
      _badge(
        canvas,
        boss.defeated
            ? '${boss.spec.name.toUpperCase()} DEFEATED'
            : '${boss.spec.name.toUpperCase()} · ${boss.health} / ${boss.spec.health} LIVES',
        title,
        light,
      );
      for (var i = 0; i < boss.spec.health; i++) {
        final p = Offset(at.dx + (i - (boss.spec.health - 1) / 2) * 22, 143);
        _drawDueGem(
          canvas,
          p,
          7,
          i < boss.health ? _dueCoral : const Color(0xFF4D3C4F),
        );
        if (i < boss.health) {
          canvas.drawCircle(
            p,
            2.5,
            Paint()..color = Colors.white.withValues(alpha: 0.8),
          );
        }
      }
    }
  }

  void _drawYardBailiff(Canvas canvas, Offset at, Color color, _DueBoss boss) {
    final dark = Color.lerp(color, _dueInk, .75)!;
    final bright = Color.lerp(color, Colors.white, .65)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final time = game.time;

    for (final side in [-1, 1]) {
      final armAngle = math.sin(time * 3.5 + side) * 0.18 + side * 0.35;
      canvas.save();
      canvas.translate(at.dx + side * 58, at.dy - 10);
      canvas.rotate(armAngle);
      final limb = Path()
        ..moveTo(0, -12)
        ..lineTo(side * 42, -26)
        ..lineTo(side * 48, -14)
        ..lineTo(side * 6, 4)
        ..close();
      canvas.drawPath(limb, _dueGradient(limb.getBounds(), [color, dark]));
      canvas.drawPath(limb, outline);
      for (var t = -1; t <= 1; t++) {
        final claw = Path()
          ..moveTo(side * 45, -20 + t * 9)
          ..lineTo(side * (72 + t.abs() * 6), -34 + t * 14)
          ..lineTo(side * 48, -12 + t * 9)
          ..close();
        canvas.drawPath(claw, Paint()..color = const Color(0xFFE2E8F0));
        canvas.drawPath(claw, outline..strokeWidth = 1.8);
      }
      canvas.restore();
    }

    final body = Rect.fromCenter(center: at, width: 120, height: 105);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(24)),
      _dueShade(body, [bright, color, dark]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(24)),
      outline,
    );

    for (var i = -2; i <= 2; i++) {
      final spike = Path()
        ..moveTo(at.dx + i * 20 - 7, at.dy - 44)
        ..lineTo(at.dx + i * 20, at.dy - 66)
        ..lineTo(at.dx + i * 20 + 7, at.dy - 44)
        ..close();
      canvas.drawPath(spike, Paint()..color = dark);
      canvas.drawPath(spike, outline..strokeWidth = 1.5);
    }

    final cowl = Rect.fromCenter(
      center: at.translate(0, -28),
      width: 70,
      height: 44,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cowl, const Radius.circular(12)),
      Paint()..color = dark,
    );
    final visor = Rect.fromCenter(
      center: at.translate(0, -28),
      width: 44,
      height: 7,
    );
    canvas.drawRect(visor, Paint()..color = const Color(0xFFFF2244));
    _dueGlow(
      canvas,
      at.translate(0, -28),
      16,
      const Color(0xFFFF2244).withValues(alpha: 0.8),
    );
  }

  void _drawSpanKeeper(Canvas canvas, Offset at, Color color, _DueBoss boss) {
    final dark = Color.lerp(color, _dueInk, .8)!;
    final bright = Color.lerp(color, const Color(0xFFFFD1A0), .6)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final time = game.time;

    final hammerPiston = math.sin(time * 5.0) * 12;
    canvas.save();
    canvas.translate(at.dx + 65, at.dy - 15);
    final cylinder = Rect.fromLTWH(0, -10, 36, 20);
    canvas.drawRect(cylinder, Paint()..color = dark);
    canvas.drawLine(
      const Offset(36, 0),
      Offset(54 + hammerPiston, 0),
      Paint()
        ..color = const Color(0xFFB0B9C6)
        ..strokeWidth = 7,
    );
    final hammerHead = Rect.fromCenter(
      center: Offset(68 + hammerPiston, 0),
      width: 28,
      height: 60,
    );
    canvas.drawRect(
      hammerHead,
      _dueGradient(hammerHead, [bright, color, dark]),
    );
    canvas.drawRect(hammerHead, outline);
    canvas.restore();

    canvas.save();
    canvas.translate(at.dx - 65, at.dy - 20);
    final boom = Path()
      ..moveTo(0, 0)
      ..lineTo(-46, -34)
      ..lineTo(-38, -42)
      ..lineTo(8, -6)
      ..close();
    canvas.drawPath(boom, Paint()..color = dark);
    canvas.drawPath(boom, outline);
    final block = Rect.fromLTWH(-58, -25, 26, 32);
    canvas.drawRect(block, _dueGradient(block, [color, dark]));
    canvas.drawRect(block, outline);
    canvas.restore();

    final chassis = Rect.fromCenter(center: at, width: 110, height: 110);
    canvas.drawRect(chassis, _dueShade(chassis, [bright, color, dark]));
    canvas.drawRect(chassis, outline);
    for (var x = chassis.left + 8; x <= chassis.right - 8; x += 18) {
      canvas.drawCircle(
        Offset(x, chassis.top + 8),
        2.5,
        Paint()..color = const Color(0xFF221612),
      );
      canvas.drawCircle(
        Offset(x, chassis.bottom - 8),
        2.5,
        Paint()..color = const Color(0xFF221612),
      );
    }

    final firebox = Rect.fromCenter(
      center: at.translate(0, 10),
      width: 50,
      height: 42,
    );
    canvas.drawRect(firebox, Paint()..color = const Color(0xFF1F0E07));
    _dueGlow(
      canvas,
      firebox.center,
      28,
      const Color(0xFFFF6A00).withValues(alpha: 0.8),
    );
    canvas.drawRect(
      firebox.deflate(5),
      Paint()..color = const Color(0xFFFFB300),
    );
    final barPaint = Paint()
      ..color = dark
      ..strokeWidth = 3.5;
    canvas.drawLine(
      firebox.topLeft + const Offset(5, 5),
      firebox.bottomRight - const Offset(5, 5),
      barPaint,
    );
    canvas.drawLine(
      firebox.topRight + const Offset(-5, 5),
      firebox.bottomLeft - const Offset(-5, 5),
      barPaint,
    );

    final crown = Rect.fromCenter(
      center: at.translate(0, -62),
      width: 75,
      height: 18,
    );
    canvas.drawRect(crown, Paint()..color = dark);
    for (final sx in [-20.0, 20.0]) {
      final stack = Rect.fromLTWH(at.dx + sx - 5, at.dy - 82, 10, 22);
      canvas.drawRect(stack, Paint()..color = dark);
    }
  }

  void _drawCollectionMarshal(
    Canvas canvas,
    Offset at,
    Color color,
    _DueBoss boss,
  ) {
    final dark = Color.lerp(color, _dueInk, .8)!;
    final bright = Color.lerp(color, Colors.white, .7)!;
    final time = game.time;

    for (var ring = 0; ring < 2; ring++) {
      final spin = time * (ring == 0 ? 3.0 : -2.4);
      final ringW = 160.0 + ring * 22;
      final ringH = 34.0 + ring * 12;
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(ring == 0 ? 0.28 : -0.28);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: ringW, height: ringH),
        Paint()
          ..color = bright.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      final nx = math.cos(spin) * (ringW / 2);
      final ny = math.sin(spin) * (ringH / 2);
      _drawDueGem(canvas, Offset(nx, ny), 5.5, const Color(0xFF00E5FF));
      _dueGlow(
        canvas,
        Offset(nx, ny),
        12,
        const Color(0xFF00E5FF).withValues(alpha: 0.8),
      );
      canvas.restore();
    }

    for (final side in [-1, 1]) {
      final pauldron = Rect.fromCenter(
        center: at.translate(side * 76, -14),
        width: 28,
        height: 75,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pauldron, const Radius.circular(14)),
        _dueGradient(pauldron, [bright, color, dark]),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pauldron, const Radius.circular(14)),
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    final orb = Rect.fromCenter(center: at, width: 92, height: 92);
    canvas.drawOval(
      orb,
      _dueShade(
        orb,
        [bright, color, dark],
        center: const Alignment(-0.25, -0.35),
      ),
    );
    canvas.drawOval(
      orb,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (var i = -1; i <= 1; i++) {
      final spireH = i == 0 ? 36.0 : 26.0;
      final spire = Path()
        ..moveTo(at.dx + i * 18 - 4, at.dy - 44)
        ..lineTo(at.dx + i * 22, at.dy - 44 - spireH)
        ..lineTo(at.dx + i * 18 + 4, at.dy - 44)
        ..close();
      canvas.drawPath(spire, Paint()..color = dark);
      canvas.drawCircle(
        Offset(at.dx + i * 22, at.dy - 44 - spireH),
        3.0,
        Paint()..color = const Color(0xFF6DE8FF),
      );
    }

    for (final side in [-1, 1]) {
      final eyePath = Path()
        ..moveTo(at.dx + side * 15, at.dy - 12)
        ..lineTo(at.dx + side * 30, at.dy - 18)
        ..lineTo(at.dx + side * 24, at.dy - 5)
        ..close();
      canvas.drawPath(eyePath, Paint()..color = const Color(0xFFFF2277));
      _dueGlow(
        canvas,
        at.translate(side * 22, -12),
        12,
        const Color(0xFFFF2277).withValues(alpha: 0.7),
      );
    }
  }

  void _drawSumpCustodian(
    Canvas canvas,
    Offset at,
    Color color,
    _DueBoss boss,
  ) {
    final dark = Color.lerp(color, _dueInk, .8)!;
    final bright = Color.lerp(color, const Color(0xFFB4F2E1), .65)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final time = game.time;

    for (final side in [-1, 1]) {
      final turbineCenter = at.translate(side * 68, 22);
      canvas.drawCircle(turbineCenter, 24, Paint()..color = dark);
      final tAngle = time * 8.0 * side;
      for (var b = 0; b < 4; b++) {
        final a = tAngle + b * (math.pi / 2);
        canvas.drawLine(
          turbineCenter,
          turbineCenter + Offset(math.cos(a) * 20, math.sin(a) * 20),
          Paint()
            ..color = const Color(0xFFE0ECEF)
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(
        turbineCenter,
        6,
        Paint()..color = const Color(0xFFCD9B58),
      );
    }

    final hull = Rect.fromCenter(
      center: at.translate(0, 10),
      width: 124,
      height: 96,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hull, const Radius.circular(36)),
      _dueShade(hull, [bright, color, dark]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hull, const Radius.circular(36)),
      outline,
    );

    final pipePaint = Paint()
      ..color = const Color(0xFFB87333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawArc(
      Rect.fromCenter(center: at.translate(0, 15), width: 132, height: 75),
      0,
      math.pi,
      false,
      pipePaint,
    );

    final dome = Rect.fromCenter(
      center: at.translate(0, -32),
      width: 76,
      height: 62,
    );
    canvas.drawOval(dome, Paint()..color = const Color(0xFF3B565B));
    canvas.drawOval(dome, outline);
    final portCenter = at.translate(0, -32);
    canvas.drawCircle(portCenter, 22, Paint()..color = const Color(0xFF1D282A));
    _dueGlow(
      canvas,
      portCenter,
      26,
      const Color(0xFF00FFC4).withValues(alpha: 0.7),
    );
    canvas.drawCircle(portCenter, 18, Paint()..color = const Color(0xFF65F7D0));
    canvas.drawCircle(portCenter, 18, outline..strokeWidth = 2.5);
    canvas.drawLine(
      portCenter.translate(-18, 0),
      portCenter.translate(18, 0),
      Paint()
        ..color = dark
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      portCenter.translate(0, -18),
      portCenter.translate(0, 18),
      Paint()
        ..color = dark
        ..strokeWidth = 2.5,
    );
  }

  void _drawFieldCartographer(
    Canvas canvas,
    Offset at,
    Color color,
    _DueBoss boss,
  ) {
    final dark = Color.lerp(color, _dueInk, .75)!;
    final bright = Color.lerp(color, const Color(0xFFFFF0B8), .7)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final time = game.time;

    const dialRadius = 66.0;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(time * 0.45);
    canvas.drawCircle(
      Offset.zero,
      dialRadius,
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    for (var i = 0; i < 16; i++) {
      final a = i * (2 * math.pi / 16);
      canvas.drawLine(
        Offset(math.cos(a) * (dialRadius - 6), math.sin(a) * (dialRadius - 6)),
        Offset(math.cos(a) * dialRadius, math.sin(a) * dialRadius),
        Paint()
          ..color = const Color(0xFF7A5813)
          ..strokeWidth = 1.8,
      );
    }
    canvas.restore();

    for (final side in [-1, 1]) {
      final wingSpread = math.sin(time * 2.2) * 0.15 + 0.45;
      canvas.save();
      canvas.translate(at.dx + side * 42, at.dy - 10);
      canvas.rotate(side * wingSpread);
      canvas.drawLine(
        Offset.zero,
        Offset(side * 52, 28),
        Paint()
          ..color = const Color(0xFFE5C058)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset.zero,
        Offset(side * 48, -26),
        Paint()
          ..color = const Color(0xFFE5C058)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset.zero, 5, Paint()..color = dark);
      canvas.restore();
    }

    final body = Rect.fromCenter(center: at, width: 88, height: 88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(22)),
      _dueShade(body, [bright, color, dark]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(22)),
      outline,
    );

    final lensCenter = at.translate(0, -6);
    canvas.drawCircle(lensCenter, 26, Paint()..color = const Color(0xFFC49A45));
    canvas.drawCircle(lensCenter, 26, outline..strokeWidth = 2.5);
    _dueGlow(
      canvas,
      lensCenter,
      32,
      const Color(0xFF6AE3FF).withValues(alpha: 0.8),
    );
    canvas.drawCircle(lensCenter, 20, Paint()..color = const Color(0xFF33CFFF));
    canvas.drawCircle(
      lensCenter,
      14,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawLine(
      lensCenter.translate(-14, 0),
      lensCenter.translate(14, 0),
      Paint()
        ..color = const Color(0xFF0C5668)
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      lensCenter.translate(0, -14),
      lensCenter.translate(0, 14),
      Paint()
        ..color = const Color(0xFF0C5668)
        ..strokeWidth = 1.2,
    );
  }

  void _drawTheAuditor(Canvas canvas, Offset at, Color color, _DueBoss boss) {
    final dark = Color.lerp(color, _dueInk, .85)!;
    final bright = Color.lerp(color, const Color(0xFFFFEFA8), .75)!;
    final time = game.time;

    final haloCenter = at.translate(0, -42);
    const haloR = 46.0;
    canvas.drawCircle(
      haloCenter,
      haloR,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );
    _dueGlow(
      canvas,
      haloCenter,
      56,
      const Color(0xFFFFD700).withValues(alpha: 0.6),
    );
    for (var r = 0; r < 8; r++) {
      final a = r * (2 * math.pi / 8) + time * 0.35;
      final rayStart =
          haloCenter +
          Offset(math.cos(a) * (haloR + 2), math.sin(a) * (haloR + 2));
      final rayEnd =
          haloCenter +
          Offset(math.cos(a) * (haloR + 18), math.sin(a) * (haloR + 18));
      canvas.drawLine(
        rayStart,
        rayEnd,
        Paint()
          ..color = const Color(0xFFFFE082)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final side in [-1, 1]) {
      final wingPath = Path()
        ..moveTo(at.dx + side * 22, at.dy - 32)
        ..cubicTo(
          at.dx + side * 75,
          at.dy - 64,
          at.dx + side * 88,
          at.dy + 12,
          at.dx + side * 35,
          at.dy + 45,
        )
        ..quadraticBezierTo(
          at.dx + side * 50,
          at.dy,
          at.dx + side * 22,
          at.dy - 32,
        );
      canvas.drawPath(
        wingPath,
        _dueGradient(wingPath.getBounds(), [
          const Color(0xFFFFE082),
          const Color(0xFFD4AF37),
          dark,
        ]),
      );
      canvas.drawPath(
        wingPath,
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    final body = Rect.fromCenter(
      center: at.translate(0, 10),
      width: 94,
      height: 104,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(28)),
      _dueShade(body, [bright, color, dark]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(28)),
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    for (var e = -1; e <= 1; e++) {
      final eyeCenter = at.translate(0, -22.0 + e * 18.0);
      final eyePath = Path()
        ..moveTo(eyeCenter.dx - 16, eyeCenter.dy)
        ..quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy - 9,
          eyeCenter.dx + 16,
          eyeCenter.dy,
        )
        ..quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy + 9,
          eyeCenter.dx - 16,
          eyeCenter.dy,
        );
      canvas.drawPath(eyePath, Paint()..color = const Color(0xFFFFF3CD));
      canvas.drawPath(
        eyePath,
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.drawCircle(
        eyeCenter,
        4.0,
        Paint()..color = const Color(0xFFFF1744),
      );
      _dueGlow(
        canvas,
        eyeCenter,
        10,
        const Color(0xFFFF1744).withValues(alpha: 0.8),
      );
    }
  }

  void _drawEnemyTell(Canvas canvas, _DueTarget target) {
    final lane = target.preparedAttack;
    if (lane == null || target.attackTell <= 0) return;
    final label = switch (target.kind) {
      _TargetKind.enemy => 'LUNGE',
      _TargetKind.drone => 'PULSE',
      _TargetKind.heavy => 'QUAKE',
      _TargetKind.leecher => 'SIPHON',
      _TargetKind.swordsman => 'SLASH',
      _TargetKind.archer => 'AIMING',
      _ => '',
    };
    final edge = target.kind == _TargetKind.drone
        ? _dueBlue
        : target.kind == _TargetKind.leecher
        ? const Color(0xFFD7A8FF)
        : target.kind == _TargetKind.swordsman
        ? const Color(0xFFFF5252)
        : target.kind == _TargetKind.archer
        ? const Color(0xFFFFB74D)
        : _dueGold;
    _badge(canvas, label, target.rect.topCenter.translate(0, -16), edge);
  }
}
