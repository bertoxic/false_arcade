part of 'fall_due_game.dart';

class _FallPainter extends CustomPainter {
  _FallPainter(this.game);
  final _FallDueGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_FallDueGame.viewWidth, _FallDueGame.viewHeight),
    );
    canvas.drawColor(const Color(0xFF090C13), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    final view = const Rect.fromLTWH(
      0,
      0,
      _FallDueGame.viewWidth,
      _FallDueGame.viewHeight,
    );
    canvas.drawRect(
      view,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF151D30), Color(0xFF090C13)],
        ).createShader(view),
    );
    _drawSkyline(canvas);
    canvas.save();
    canvas.translate(-game.camera, 0);
    final worldView = Rect.fromLTWH(
      game.camera - 80,
      -80,
      _FallDueGame.viewWidth + 160,
      _FallDueGame.viewHeight + 160,
    );
    for (final platform in game.platforms) {
      if (!worldView.overlaps(platform)) continue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(platform, const Radius.circular(4)),
        Paint()..color = const Color(0xFF273750),
      );
      canvas.drawRect(
        Rect.fromLTWH(platform.left, platform.top, platform.width, 4),
        Paint()..color = const Color(0xFF78A5D7),
      );
      canvas.drawRect(
        Rect.fromLTWH(platform.left, platform.bottom - 5, platform.width, 5),
        Paint()..color = const Color(0xFF152133),
      );
    }
    for (final section in game.routeSections) {
      if (section.start < worldView.left - 220 ||
          section.start > worldView.right + 20) {
        continue;
      }
      _drawSectionMarker(canvas, section);
    }
    for (final panel in game.weakPanels) {
      if (!worldView.overlaps(panel.rect)) continue;
      _drawWeakPanel(canvas, panel);
    }
    for (final pad in game.safeDebtPads) {
      if (!worldView.overlaps(pad.rect)) continue;
      _drawSafeDebtPad(canvas, pad);
    }
    for (var index = 0; index < game.spikes.length; index++) {
      if (!worldView.overlaps(game.spikes[index])) continue;
      if (game.disabledSpikes.contains(index)) {
        _drawSealedSpikes(canvas, game.spikes[index]);
      } else {
        _drawSpikes(canvas, game.spikes[index]);
      }
    }
    if (worldView.overlaps(game.exit)) _drawExit(canvas);
    for (final seal in game.seals) {
      if (!worldView.contains(seal.position)) continue;
      _drawSeal(canvas, seal);
    }
    for (final checkpoint in game.checkpoints) {
      if (!worldView.contains(checkpoint.position)) continue;
      _drawCheckpoint(canvas, checkpoint);
    }
    for (final gate in game.gates) {
      if (!worldView.overlaps(gate.rect)) continue;
      _drawGate(canvas, gate);
    }
    for (final lever in game.levers) {
      if (!worldView.contains(lever.position)) continue;
      _drawLever(canvas, lever);
    }
    for (final emitter in game.emitters) {
      if (!worldView.contains(emitter.position)) continue;
      _drawEmitter(canvas, emitter);
    }
    for (final target in game.targets) {
      if (!worldView.overlaps(target.rect)) continue;
      _drawTarget(canvas, target);
    }
    for (final bullet in game.bullets) {
      if (!worldView.overlaps(bullet.rect)) continue;
      final color = bullet.debt > 1
          ? const Color(0xFFFFD86E)
          : const Color(0xFFFF7189);
      canvas.drawCircle(bullet.rect.center, 7, Paint()..color = color);
    }
    for (final particle in game.particles) {
      if (!worldView.contains(particle.position)) continue;
      canvas.drawCircle(
        particle.position,
        2.4,
        Paint()
          ..color = particle.color.withValues(
            alpha: (particle.life / .8).clamp(0.0, 1.0),
          ),
      );
    }
    final nearestTarget = game._nearestTarget();
    final nearestEmitter = game._nearestEmitter();
    final emitterIsCloser = game._emitterIsCloser(
      nearestTarget,
      nearestEmitter,
    );
    final recipient = emitterIsCloser
        ? nearestEmitter?.position
        : nearestTarget?.center;
    if (recipient != null) {
      final tetherColor = game.debt >= 3
          ? const Color(0xFFFFD86E)
          : const Color(0xFF8DE1FF);
      canvas.drawLine(
        game.player.center,
        recipient,
        Paint()
          ..color = tetherColor.withValues(alpha: .22)
          ..strokeWidth = 6.0,
      );
      canvas.drawLine(
        game.player.center,
        recipient,
        Paint()
          ..color = tetherColor.withValues(alpha: .82)
          ..strokeWidth = 1.8,
      );
      canvas.drawCircle(
        recipient,
        26 + math.sin(game.time * 6) * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = tetherColor.withValues(alpha: .75),
      );
    }
    final player = game.player;
    final playerColor = game.inPayback
        ? const Color(0xFFFFD86E)
        : const Color(0xFF8DE1FF);

    // Gravity distortion rings
    if (game._antiGravityActive) {
      final pulseRadius = 26.0 + (game.time * 40) % 20.0;
      final pulseAlpha = (1.0 - (pulseRadius - 26) / 20.0).clamp(0.0, 1.0);
      canvas.drawCircle(
        player.center,
        pulseRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF8DE1FF).withValues(alpha: pulseAlpha * 0.6),
      );
    }

    canvas.drawCircle(
      player.center,
      game._antiGravityActive ? 32 : 22,
      Paint()
        ..color = playerColor.withValues(
          alpha: game._antiGravityActive ? .34 : .12,
        ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(player.center.dx, player.y + player.h + 3),
        width: 29,
        height: 6,
      ),
      Paint()..color = const Color(0x9905080E),
    );
    _drawPlayer(canvas, player, playerColor);
    canvas.restore();
    _drawDebtMeter(canvas);
    _drawObjective(canvas);
    canvas.restore();
  }

  void _drawSectionMarker(Canvas canvas, _DueSectionSpec section) {
    final rect = Rect.fromLTWH(section.start + 12, 74, 205, 44);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()..color = const Color(0xDD102238),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF78A5D7),
    );
    canvas.drawLine(
      Offset(rect.left + 18, rect.bottom),
      Offset(rect.left + 18, 406),
      Paint()
        ..color = const Color(0xFF78A5D7).withValues(alpha: .65)
        ..strokeWidth = 1.2,
    );
    paintGameText(
      canvas,
      'SECTION',
      rect.topLeft + const Offset(34, 7),
      8,
      const Color(0xFF8DE1FF),
      bold: true,
      letterSpacing: 1.4,
    );
    paintGameText(
      canvas,
      section.title,
      rect.topLeft + const Offset(34, 21),
      11,
      const Color(0xFFE5F3FF),
      bold: true,
      letterSpacing: .7,
    );
    canvas.drawCircle(
      rect.topLeft + const Offset(18, 20),
      6,
      Paint()..color = const Color(0xFFFFD86E),
    );
  }

  void _drawPlayer(Canvas canvas, _DueBody player, Color accent) {
    final facing = player.vx < -12 ? -1.0 : 1.0;
    final backpack = Rect.fromLTWH(
      facing > 0 ? player.x + 1 : player.x + player.w - 7,
      player.y + 15,
      7,
      17,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(backpack, const Radius.circular(2)),
      Paint()..color = const Color(0xFF253750),
    );
    final torso = Rect.fromLTWH(player.x + 4, player.y + 15, 19, 17);
    canvas.drawRRect(
      RRect.fromRectAndRadius(torso, const Radius.circular(5)),
      Paint()..color = accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 5, player.y + 2, 17, 16),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFFE5F3FF),
    );
    final visor = Rect.fromLTWH(
      facing > 0 ? player.x + 12 : player.x + 6,
      player.y + 7,
      8,
      6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor, const Radius.circular(3)),
      Paint()..color = const Color(0xFF102238),
    );
    canvas.drawCircle(
      Offset(visor.center.dx + facing * 1.5, visor.center.dy),
      1.3,
      Paint()..color = accent,
    );
    final bootPaint = Paint()..color = const Color(0xFF162338);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 5, player.y + 30, 7, 6),
        const Radius.circular(2),
      ),
      bootPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 16, player.y + 30, 7, 6),
        const Radius.circular(2),
      ),
      bootPaint,
    );
    canvas.drawLine(
      Offset(player.x + 13.5, player.y + 2),
      Offset(player.x + 13.5 + facing * 3, player.y - 3),
      Paint()
        ..color = const Color(0xFFCDEBFF)
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      Offset(player.x + 13.5 + facing * 3, player.y - 3),
      1.5,
      Paint()..color = accent,
    );
  }

  void _drawSkyline(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF111725);
    for (var index = 0; index < 38; index++) {
      final x = (index * 83.0 + 29) % _FallDueGame.viewWidth;
      final y = 42.0 + (index * 47 % 225);
      canvas.drawCircle(
        Offset(x, y),
        index % 5 == 0 ? 1.4 : .7,
        Paint()..color = const Color(0xFF8DB6E8).withValues(alpha: .38),
      );
    }
    for (var index = 0; index < 12; index++) {
      final x = ((index * 150 - game.camera * .16) % 1800) - 100;
      final height = 65.0 + index % 4 * 37;
      canvas.drawRect(Rect.fromLTWH(x, 420 - height, 96, height), paint);
    }
  }

  void _drawWeakPanel(Canvas canvas, _DueWeakPanel panel) {
    if (panel.broken) {
      canvas.drawLine(
        panel.rect.topLeft,
        panel.rect.bottomRight,
        Paint()
          ..color = const Color(0xFFFFD86E).withValues(alpha: .5)
          ..strokeWidth = 2,
      );
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel.rect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF5A3B24),
    );
    final seam = Paint()
      ..color = const Color(0xFFB67C3D)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      panel.rect.topLeft + const Offset(13, 4),
      panel.rect.center,
      seam,
    );
    canvas.drawLine(
      panel.rect.center,
      panel.rect.bottomRight - const Offset(12, 4),
      seam,
    );
  }

  void _drawSafeDebtPad(Canvas canvas, _DueSafeDebtPad pad) {
    final color = pad.cooldown > 0
        ? const Color(0xFF8CFFB1)
        : const Color(0xFF56BBA3);
    canvas.drawRect(pad.rect, Paint()..color = const Color(0xFF143A35));
    canvas.drawRect(
      pad.rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color,
    );
    for (var x = pad.rect.left + 8; x < pad.rect.right; x += 14) {
      canvas.drawLine(
        Offset(x, pad.rect.bottom - 1),
        Offset(x + 5, pad.rect.top + 1),
        Paint()
          ..color = color.withValues(alpha: .8)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawSpikes(Canvas canvas, Rect rect) {
    final path = Path();
    final amount = math.max(2, (rect.width / 15).floor());
    for (var index = 0; index < amount; index++) {
      final left = rect.left + rect.width / amount * index;
      final right = rect.left + rect.width / amount * (index + 1);
      path
        ..moveTo(left, rect.bottom)
        ..lineTo((left + right) / 2, rect.top)
        ..lineTo(right, rect.bottom);
    }
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF6975));
  }

  void _drawSealedSpikes(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF1A4B45));
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 4),
      Paint()..color = const Color(0xFF8CFFB1),
    );
    _text(
      canvas,
      'SEALED',
      rect.center + const Offset(0, 4),
      8,
      const Color(0xFFDFFFEA),
      center: true,
      bold: true,
    );
  }

  void _drawExit(Canvas canvas) {
    final rect = game.exit;
    final unlocked = game.allObjectivesComplete;
    final color = unlocked ? const Color(0xFF8CFFB1) : const Color(0xFF697891);
    final threshold = Rect.fromLTWH(
      rect.left - 18,
      rect.bottom - 5,
      rect.width + 36,
      15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(threshold, const Radius.circular(3)),
      Paint()..color = const Color(0xFF1A2A40),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        threshold.left + 3,
        threshold.top + 2,
        threshold.width - 6,
        3,
      ),
      Paint()..color = color.withValues(alpha: .92),
    );
    final seam = Paint()
      ..color = const Color(0xFF7E9ABF).withValues(alpha: .32)
      ..strokeWidth = 1;
    for (var x = threshold.left + 10; x < threshold.right - 4; x += 12) {
      canvas.drawLine(
        Offset(x, threshold.top + 7),
        Offset(x + 5, threshold.bottom - 2),
        seam,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6), const Radius.circular(8)),
      Paint()..color = color.withValues(alpha: unlocked ? .16 : .08),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = unlocked ? const Color(0xFF12372C) : const Color(0xFF212938),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color,
    );
    _text(
      canvas,
      unlocked
          ? 'GATE'
          : game.lockedGates > 0 && game.allSealsCollected
          ? '${game.lockedGates} LOCK'
          : '${game.collectedSeals}/${game.seals.length}',
      rect.center + const Offset(0, 5),
      11,
      color,
      center: true,
      bold: true,
    );
  }

  void _drawSeal(Canvas canvas, _DueSeal seal) {
    final color = seal.collected
        ? const Color(0xFF48687A)
        : const Color(0xFF8CFFB1);
    canvas.drawCircle(
      seal.position,
      seal.radius + 7,
      Paint()..color = color.withValues(alpha: seal.collected ? .08 : .22),
    );
    canvas.drawCircle(seal.position, seal.radius, Paint()..color = color);
    _text(
      canvas,
      seal.collected ? 'OK' : 'S',
      seal.position + const Offset(0, 4),
      9,
      const Color(0xFF071018),
      center: true,
      bold: true,
    );
  }

  void _drawEmitter(Canvas canvas, _DueEmitter emitter) {
    final rect = Rect.fromCenter(
      center: emitter.position,
      width: 28,
      height: 28,
    );
    final color = emitter.debt > 1
        ? const Color(0xFFFFD86E)
        : const Color(0xFFFF788E);
    canvas.drawCircle(
      emitter.position,
      22 + emitter.debt * .15,
      Paint()..color = color.withValues(alpha: emitter.debt > 1 ? .18 : .05),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = emitter.debt > 1
            ? const Color(0xFF57451B)
            : const Color(0xFF5B2633),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
    final aim = emitter.speed.sign;
    canvas.drawLine(
      emitter.position,
      emitter.position + Offset(aim * 17, 0),
      Paint()
        ..color = const Color(0xFFFFB0BB)
        ..strokeWidth = 2,
    );
    if (emitter.debt > 1) {
      _text(
        canvas,
        '${emitter.debt.round()}%',
        emitter.position + const Offset(0, -22),
        8,
        const Color(0xFFFFD86E),
        center: true,
        bold: true,
      );
    }
  }

  void _drawGate(Canvas canvas, _DueGate gate) {
    final rect = gate.rect;
    final isOpen = gate.open;
    final accentColor = isOpen ? const Color(0xFF6EF0B7) : const Color(0xFFFF4868);
    final coreGlow = isOpen ? const Color(0xFFB4FFD8) : const Color(0xFFFF94A8);
    final steelDark = const Color(0xFF131A26);
    final steelPlate = const Color(0xFF243348);

    // 1. Structural Steel Wall Anchors (Top & Bottom hydraulic mount blocks)
    final topAnchor = Rect.fromLTWH(rect.left - 4, rect.top - 6, rect.width + 8, 14);
    final bottomAnchor = Rect.fromLTWH(rect.left - 4, rect.bottom - 8, rect.width + 8, 14);

    void drawMount(Rect mount) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(mount, const Radius.circular(3)),
        Paint()..color = steelDark,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(mount, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF435875),
      );
      // Industrial bolts / rivets
      for (final bx in [mount.left + 4, mount.right - 4]) {
        canvas.drawCircle(Offset(bx, mount.center.dy), 1.8, Paint()..color = const Color(0xFF7A93B4));
      }
    }

    drawMount(topAnchor);
    drawMount(bottomAnchor);

    if (isOpen) {
      // --- UNLOCKED / OPEN STATE ---
      // Retracted side guide rails
      canvas.drawRect(
        Rect.fromLTWH(rect.left + 1, rect.top + 8, 4, rect.height - 16),
        Paint()..color = steelPlate,
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.right - 5, rect.top + 8, 4, rect.height - 16),
        Paint()..color = steelPlate,
      );
      // Glowing green laser safe-zone wireframes
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accentColor.withValues(alpha: 0.5),
      );
      // Soft green interior path field
      canvas.drawRect(
        rect.deflate(4),
        Paint()..color = accentColor.withValues(alpha: 0.08),
      );
      // Center illuminated status badge
      final badge = Rect.fromCenter(center: rect.center, width: 28, height: 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, const Radius.circular(4)),
        Paint()..color = steelDark,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = accentColor,
      );
      _text(
        canvas,
        'OPEN',
        rect.center,
        7,
        accentColor,
        center: true,
        bold: true,
      );
    } else {
      // --- LOCKED / ACTIVE LIFT BLOCKER BARRIER ---
      // Heavy solid backing plate
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = steelDark,
      );

      // Heavy vertical hydraulic shaft rails
      canvas.drawRect(
        Rect.fromLTWH(rect.left + 2, rect.top + 6, 3, rect.height - 12),
        Paint()..color = const Color(0xFF5D7699),
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.right - 5, rect.top + 6, 3, rect.height - 12),
        Paint()..color = const Color(0xFF5D7699),
      );

      // Solid heavy barrier louvers with hazard stripes
      const louverHeight = 16.0;
      final count = ((rect.height - 20) / louverHeight).floor();
      for (var i = 0; i < count; i++) {
        final ly = rect.top + 10 + i * louverHeight;
        final louverRect = Rect.fromLTWH(rect.left + 5, ly, rect.width - 10, louverHeight - 3);
        
        // Dark metal louver plate
        canvas.drawRRect(
          RRect.fromRectAndRadius(louverRect, const Radius.circular(2)),
          Paint()..color = steelPlate,
        );

        // Caution diagonal hazard stripes (alternating amber/dark)
        final hazardPaint = Paint()
          ..color = const Color(0xFFFFD36A).withValues(alpha: 0.85)
          ..strokeWidth = 2.0;
        for (var hx = louverRect.left - 4; hx < louverRect.right + 4; hx += 8) {
          canvas.drawLine(
            Offset(hx, louverRect.bottom),
            Offset(hx + 5, louverRect.top),
            hazardPaint,
          );
        }

        // Louver border
        canvas.drawRRect(
          RRect.fromRectAndRadius(louverRect, const Radius.circular(2)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFF101724),
        );
      }

      // Outer energized force barrier border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = accentColor,
      );

      // Center heavy security lock terminal badge
      final badge = Rect.fromCenter(center: rect.center, width: 34, height: 26);
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, const Radius.circular(5)),
        Paint()..color = const Color(0xFF0C131D),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, const Radius.circular(5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = accentColor,
      );

      // Pulsing lock indicator light
      canvas.drawCircle(
        badge.center + const Offset(0, -5),
        3.5,
        Paint()..color = coreGlow,
      );

      _text(
        canvas,
        'LOCKED',
        badge.center + const Offset(0, 4),
        6,
        accentColor,
        center: true,
        bold: true,
      );
    }
  }

  void _drawCheckpoint(Canvas canvas, _DueCheckpoint checkpoint) {
    final base = checkpoint.position + const Offset(14, 37);
    final color = checkpoint.active
        ? const Color(0xFF8CFFB1)
        : const Color(0xFF8DE1FF);
    canvas.drawCircle(
      base + const Offset(0, -19),
      20,
      Paint()..color = color.withValues(alpha: checkpoint.active ? .22 : .08),
    );
    canvas.drawLine(
      base,
      base + const Offset(0, -34),
      Paint()
        ..color = const Color(0xFFC5D6F0)
        ..strokeWidth = 2,
    );
    final flag = Path()
      ..moveTo(base.dx, base.dy - 34)
      ..lineTo(base.dx + 17, base.dy - 28)
      ..lineTo(base.dx, base.dy - 20)
      ..close();
    canvas.drawPath(flag, Paint()..color = color);
    _text(
      canvas,
      checkpoint.active ? 'SAVED' : 'SAVE',
      base + const Offset(0, 14),
      7,
      color,
      center: true,
      bold: true,
    );
  }

  void _drawLever(Canvas canvas, _DueLever lever) {
    final color = lever.active
        ? const Color(0xFF8CFFB1)
        : const Color(0xFF8DE1FF);
    canvas.drawCircle(
      lever.position,
      20,
      Paint()..color = color.withValues(alpha: lever.active ? .23 : .11),
    );
    canvas.drawLine(
      lever.position + const Offset(0, 14),
      lever.position + const Offset(0, -10),
      Paint()
        ..color = const Color(0xFFB9C8E2)
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      lever.position + const Offset(0, -11),
      7,
      Paint()..color = color,
    );
    _text(
      canvas,
      lever.active ? 'ON' : 'LIFT',
      lever.position + const Offset(0, 31),
      8,
      color,
      center: true,
      bold: true,
    );
  }

  void _drawTarget(Canvas canvas, _DueTarget target) {
    final color = target.anchored
        ? const Color(0xFF4F8C78)
        : target.debt < -1
        ? const Color(0xFF62BDE8)
        : target.kind == _TargetKind.enemy
        ? const Color(0xFF9C5EB6)
        : const Color(0xFFD29A43);
    if (target.kind == _TargetKind.enemy) {
      final alertColor = target.debt < -1
          ? const Color(0xFF8DE1FF)
          : target.debt > 1
          ? const Color(0xFFFFD86E)
          : const Color(0xFFFF7186);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(target.center.dx, target.rect.bottom + 3),
          width: 28,
          height: 5,
        ),
        Paint()..color = const Color(0x66000000),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(8)),
        Paint()..color = color,
      );
      final visor = Rect.fromLTWH(target.x + 5, target.y + 9, 22, 9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(visor, const Radius.circular(4)),
        Paint()..color = const Color(0xFF171223),
      );
      canvas.drawCircle(
        Offset(target.x + 11, target.y + 13.5),
        2,
        Paint()..color = const Color(0xFFFFA0B5),
      );
      canvas.drawCircle(
        Offset(target.x + 21, target.y + 13.5),
        2,
        Paint()..color = const Color(0xFFFFA0B5),
      );
      canvas.drawLine(
        Offset(target.center.dx, target.y + 4),
        Offset(target.center.dx + 4, target.y),
        Paint()
          ..color = const Color(0xFFE5D9FF)
          ..strokeWidth = 1.2,
      );
      final warning = target.center + const Offset(0, -16);
      canvas.drawCircle(
        warning,
        12,
        Paint()..color = alertColor.withValues(alpha: .22),
      );
      canvas.drawCircle(warning, 6, Paint()..color = alertColor);
      _text(
        canvas,
        '!',
        warning + const Offset(0, -5),
        9,
        const Color(0xFF111725),
        center: true,
        bold: true,
      );
      _text(
        canvas,
        'COLLECTOR',
        target.center + const Offset(0, -34),
        7,
        alertColor,
        center: true,
        bold: true,
      );
    } else {
      // Industrial reinforced heavy gravity crate
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF1F180F),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect.deflate(2), const Radius.circular(3)),
        Paint()..color = color,
      );

      // Industrial hazard warning stripes across middle
      canvas.save();
      final hazardBand = Rect.fromLTWH(
        target.x + 2,
        target.y + target.h * 0.32,
        target.w - 4,
        target.h * 0.36,
      );
      canvas.clipRect(hazardBand);
      canvas.drawRect(hazardBand, Paint()..color = const Color(0xFFFFD166));
      final stripePaint = Paint()
        ..color = const Color(0xFF221606)
        ..strokeWidth = 3.5;
      for (double x = -20; x <= target.w + 20; x += 8) {
        canvas.drawLine(
          Offset(target.x + x, hazardBand.top - 2),
          Offset(target.x + x + 8, hazardBand.bottom + 2),
          stripePaint,
        );
      }
      canvas.restore();

      // Steel perimeter frame & corner brackets
      final framePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF332011);
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect.deflate(2), const Radius.circular(3)),
        framePaint,
      );

      // Central gravity core socket
      final isHeavy = target.debt > 1;
      final isLight = target.debt < -1;
      final coreColor = isLight
          ? const Color(0xFF7BE5FF)
          : isHeavy
          ? const Color(0xFFFF5277)
          : const Color(0xFFFFE082);
      canvas.drawCircle(
        target.center,
        5.5,
        Paint()..color = const Color(0xFF1A130B),
      );
      canvas.drawCircle(
        target.center,
        3.5,
        Paint()..color = coreColor,
      );
    }
    if (target.anchored) {
      _text(
        canvas,
        'BRIDGE',
        Offset(target.x + target.w / 2, target.y - 14),
        8,
        const Color(0xFF8CFFB1),
        center: true,
        bold: true,
      );
    } else if (target.debt < -1) {
      _text(
        canvas,
        'LIGHT',
        Offset(target.x + target.w / 2, target.y - 14),
        9,
        const Color(0xFF8DE1FF),
        center: true,
        bold: true,
      );
    } else if (target.debt > 1) {
      _text(
        canvas,
        '×${(1 + target.debt * .035).toStringAsFixed(1)}',
        Offset(target.x + target.w / 2, target.y - 14),
        10,
        const Color(0xFFFFD86E),
        center: true,
        bold: true,
      );
    }
  }

  void _drawDebtMeter(Canvas canvas) {
    const meter = Rect.fromLTWH(20, 20, 248, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(meter, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1F293A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          meter.left,
          meter.top,
          meter.width * game.gravityMeter / 100,
          meter.height,
        ),
        const Radius.circular(8),
      ),
      Paint()
        ..color = game.inPayback
            ? const Color(0xFFFFD86E)
            : const Color(0xFF8DE1FF),
    );
    _text(
      canvas,
      game._antiGravityActive
          ? 'BORROWING: GIVE LOAN AWAY BEFORE YOU RELEASE'
          : game.inPayback
          ? 'HEAVY PAYBACK: LAND CLEAN TO SETTLE FASTER'
          : game._settleGrace > 0
          ? 'LOAN OPEN: GIVE OR TAKE BEFORE PAYBACK'
          : game.debt > 0
          ? 'CARRIED LOAN: HOLD BORROW TO SPEND IT'
          : 'LEDGER CLEAR',
      const Offset(20, 50),
      10,
      const Color(0xFFD5E4FF),
      bold: true,
    );
  }

  void _drawObjective(Canvas canvas) {
    final title = 'STAGE ${game.stageProgress}  ${game.level.title}';
    final collectorState = game.visibleCollectors == 0
        ? 'ROUTE CLEAR'
        : 'COLLECTORS ${game.visibleCollectors}';
    final routeState = game.gates.isEmpty
        ? 'SAVE ${game.activatedCheckpoints}/${game.checkpoints.length}  SEALS ${game.collectedSeals}/${game.seals.length}  $collectorState'
        : 'SAVE ${game.activatedCheckpoints}/${game.checkpoints.length}  SEALS ${game.collectedSeals}/${game.seals.length}  LOCKS ${game.activeLevers}/${game.levers.length}  ${game.lockedGates == 0 ? 'ROUTE OPEN' : '${game.lockedGates} LOCKED'}  $collectorState';
    _text(
      canvas,
      title,
      const Offset(940, 22),
      10,
      const Color(0xFFD5E4FF),
      center: false,
      bold: true,
      right: true,
    );
    _text(
      canvas,
      routeState,
      const Offset(940, 40),
      9,
      game.allObjectivesComplete
          ? const Color(0xFF8CFFB1)
          : const Color(0xFF9BB5D2),
      right: true,
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
    bool right = false,
  }) {
    paintGameText(
      canvas,
      text,
      point,
      size,
      color,
      align: center
          ? TextAlign.center
          : right
          ? TextAlign.right
          : TextAlign.left,
      bold: bold,
    );
  }

  @override
  bool shouldRepaint(covariant _FallPainter oldDelegate) => true;
}
