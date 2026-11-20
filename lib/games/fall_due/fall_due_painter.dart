part of 'fall_due_game.dart';

const _dueGold = Color(0xFFFFD56F);
const _dueCream = Color(0xFFFFF2D6);
const _dueBlue = Color(0xFFA4DDFF);
const _dueMint = Color(0xFFA8F2C7);
const _dueCoral = Color(0xFFFF827A);
const _dueInk = Color(0xFF251D2B);

class _FallPainter extends CustomPainter {
  _FallPainter(this.game, this.landscape);

  final _FallDueGame game;
  final _DueLandscape landscape;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final viewport = LogicalViewport.fit(size, _duePlayfieldSize);
    final preview = game.phase == _DuePhase.intro;
    final stage = preview
        ? game._stageFor(game._initialLevelIndex)
        : game.level;
    final world = Rect.fromLTWH(
      game.camera - 100,
      -100,
      _duePlayfieldSize.width + 200,
      _duePlayfieldSize.height + 200,
    );

    canvas.save();
    viewport.applyTo(canvas);
    canvas.clipRect(Offset.zero & _duePlayfieldSize);
    _drawAtmosphere(canvas);
    canvas.translate(-game.camera, 0);

    for (final platform in preview ? stage.platforms : game.platforms) {
      if (!world.overlaps(platform)) continue;
      _drawPlatform(canvas, platform);
      _drawScenery(canvas, platform);
    }
    final spikes = preview ? stage.spikes : game.spikes;
    for (var index = 0; index < spikes.length; index++) {
      if (!world.overlaps(spikes[index])) continue;
      _drawSpikes(canvas, spikes[index], game.disabledSpikes.contains(index));
    }

    if (preview) {
      for (final seal in stage.seals) {
        if (world.contains(seal)) _drawSeal(canvas, seal);
      }
      _drawHero(
        canvas,
        Offset(stage.platforms.first.left + 160, stage.platforms.first.top),
        1,
        true,
        0,
      );
      canvas.restore();
      return;
    }

    for (final panel in game.weakPanels) {
      if (world.overlaps(panel.rect)) _drawWeakPanel(canvas, panel);
    }
    for (final pad in game.safeDebtPads) {
      if (world.overlaps(pad.rect)) _drawSafePad(canvas, pad);
    }
    if (world.overlaps(game.exit)) _drawExit(canvas);
    for (final checkpoint in game.checkpoints) {
      if (world.contains(checkpoint.position)) {
        _drawCheckpoint(canvas, checkpoint);
      }
    }
    for (final gate in game.gates) {
      if (world.overlaps(gate.rect)) _drawGate(canvas, gate);
    }
    for (final lever in game.levers) {
      if (world.contains(lever.position)) _drawLever(canvas, lever);
    }
    for (final seal in game.seals) {
      if (!seal.collected && world.contains(seal.position)) {
        _drawSeal(canvas, seal.position);
      }
    }
    for (final emitter in game.emitters) {
      if (world.contains(emitter.position)) _drawEmitter(canvas, emitter);
    }
    for (final bullet in game.bullets) {
      if (bullet.alive && world.overlaps(bullet.rect)) {
        _drawBullet(canvas, bullet);
      }
    }

    final selected = game._manualTarget;
    final recipient = game._gravityRecipient;
    if (recipient != null && game._targetInRange(recipient)) {
      _drawTether(canvas, recipient.center, automatic: selected == null);
    }
    for (final target in game.targets) {
      if (target.alive && world.overlaps(target.rect)) {
        _drawTarget(canvas, target);
      }
    }
    if (selected != null && world.overlaps(selected.rect)) {
      _drawTargetFrame(canvas, selected);
    }
    for (final particle in game.particles) {
      if (!world.contains(particle.position)) continue;
      final alpha = (particle.life / .8).clamp(0.0, 1.0);
      canvas.drawCircle(
        particle.position,
        1.1 + 3.2 * alpha,
        Paint()
          ..color = particle.color.withValues(alpha: alpha * .94)
          ..blendMode = BlendMode.screen,
      );
    }
    for (final wave in game.shockwaves) {
      if (world.contains(wave.position)) _drawShockwave(canvas, wave);
    }
    for (final arc in game.transferArcs) {
      if (world.overlaps(
        Rect.fromPoints(arc.origin, arc.destination).inflate(22),
      )) {
        _drawTransfer(canvas, arc);
      }
    }

    final player = game.player;
    _drawPlayerEffects(canvas);
    _drawHero(
      canvas,
      player.rect.bottomCenter,
      player.vx < -12 || (player.vx.abs() <= 12 && game.left) ? -1 : 1,
      player.grounded,
      player.vx.abs(),
    );
    canvas.restore();
  }

  void _badge(Canvas canvas, String text, Offset at, Color color) {
    final label = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 9.5,
          fontFamily: 'sans-serif',
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(
      center: at,
      width: label.width + 13,
      height: 17,
    );
    _dueRounded(canvas, rect, 8, Paint()..color = const Color(0xDC241D2A));
    label.paint(canvas, at - Offset(label.width / 2, label.height / 2));
    label.dispose();
  }

  void _drawSeal(Canvas canvas, Offset position) {
    final bob = math.sin(game.time * 3.3 + position.dx * .015) * 3;
    final center = position.translate(0, bob);
    _drawDueGem(canvas, center, 10.8, _dueGold);
    final spark = center.translate(15, -9 + bob);
    canvas.drawCircle(
      spark,
      1.7,
      Paint()..color = _dueCream.withValues(alpha: .67 + bob * .09),
    );
  }

  void _drawSpikes(Canvas canvas, Rect rect, bool shielded) {
    if (shielded) {
      final slab = Rect.fromLTWH(rect.left, rect.top + 4, rect.width, 19);
      _dueRounded(
        canvas,
        slab,
        7,
        _dueGradient(slab, [_dueMint, landscape.moss, landscape.stone]),
      );
      _badge(canvas, 'SHIELDED', rect.topCenter.translate(0, 32), _dueMint);
      return;
    }
    final bed = Rect.fromLTRB(
      rect.left,
      rect.top + 22,
      rect.right,
      rect.bottom,
    );
    _dueRounded(
      canvas,
      bed,
      6,
      _dueGradient(bed, [const Color(0xFF673A49), _dueInk]),
    );
    final count = math.max(1, (rect.width / 19).round());
    final step = rect.width / count;
    for (var i = 0; i < count; i++) {
      final left = rect.left + i * step;
      final peak = Offset(
        left + step * (.42 + i % 3 * .09),
        rect.top + 1 + i % 3 * 3,
      );
      final baseL = Offset(left, bed.top + 11);
      final baseR = Offset(left + step, bed.top + 9);
      final ridge = Offset(left + step * .59, bed.top + 13);
      final spike = _duePolygon([baseL, peak, baseR, ridge]);
      canvas.drawPath(
        spike,
        _dueGradient(spike.getBounds(), [
          const Color(0xFFFFBA9F),
          const Color(0xFFBC6470),
          const Color(0xFF674255),
        ]),
      );
      canvas.drawPath(
        _duePolygon([peak, baseR, ridge]),
        Paint()..color = const Color(0x5D652C4C),
      );
    }
  }

  void _drawWeakPanel(Canvas canvas, _DueWeakPanel panel) {
    final r = panel.rect;
    final count = math.max(1, (r.width / 27).round());
    final step = r.width / count;
    for (var i = 0; i < count; i++) {
      if (panel.broken && i % 3 != 0) continue;
      final board = Rect.fromLTWH(
        r.left + i * step,
        r.top,
        step - 1,
        panel.broken ? r.height * .44 : r.height,
      );
      _dueRounded(
        canvas,
        board,
        3,
        _dueGradient(board, [const Color(0xFFE3A775), const Color(0xFF7C4944)]),
      );
      final crack = Path()
        ..moveTo(board.left + board.width * .31, board.top)
        ..lineTo(board.center.dx + 3, board.center.dy)
        ..lineTo(board.center.dx - 1, board.bottom);
      canvas.drawPath(
        crack,
        Paint()
          ..color = const Color(0xB75B333E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.9,
      );
    }
  }

  void _drawSafePad(Canvas canvas, _DueSafeDebtPad pad) {
    final ready = pad.cooldown <= 0;
    final color = ready ? _dueMint : const Color(0xFF638779);
    _dueRounded(
      canvas,
      pad.rect.inflate(1),
      4,
      _dueGradient(pad.rect, [color, landscape.moss]),
    );
    for (var i = 1; i <= 3; i++) {
      final center = Offset(
        pad.rect.left + pad.rect.width * i / 4,
        pad.rect.top - 5,
      );
      canvas.drawCircle(center, ready ? 2.5 : 1.5, Paint()..color = color);
    }
    _badge(
      canvas,
      ready ? 'SETTLE' : 'RECHARGING',
      pad.rect.topCenter.translate(0, -18),
      color,
    );
  }

  void _drawCheckpoint(Canvas canvas, _DueCheckpoint checkpoint) {
    final p = checkpoint.position;
    final color = checkpoint.active ? _dueMint : _dueBlue;
    final base = Rect.fromCenter(
      center: p.translate(0, 17),
      width: 23,
      height: 22,
    );
    _dueRounded(
      canvas,
      base,
      5,
      _dueGradient(base, [landscape.stoneLight, landscape.stone]),
    );
    _drawDueGem(canvas, p.translate(0, -5), 9, color);
    _badge(
      canvas,
      checkpoint.active ? 'SAVED' : 'SAVE',
      p.translate(0, -30),
      color,
    );
  }

  void _drawLever(Canvas canvas, _DueLever lever) {
    final p = lever.position;
    final color = lever.active ? _dueMint : _dueBlue;
    final mount = Rect.fromCenter(center: p, width: 27, height: 21);
    _dueRounded(
      canvas,
      mount,
      7,
      _dueGradient(mount, [landscape.stoneLight, _dueInk]),
    );
    final tip = p.translate(lever.active ? 8 : -8, -9);
    canvas.drawLine(
      p.translate(0, 5),
      tip,
      Paint()
        ..color = _dueCream
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );
    _drawDueGem(canvas, tip, 4, color);
    _badge(
      canvas,
      lever.active ? 'LIFT ON' : 'ACTIVATE',
      p.translate(0, 24),
      color,
    );
  }

  void _drawGate(Canvas canvas, _DueGate gate) {
    final r = gate.rect;
    final color = gate.open ? _dueMint : _dueCoral;
    final cap = Rect.fromLTWH(r.left - 4, r.top, r.width + 8, 16);
    _dueRounded(
      canvas,
      cap,
      6,
      _dueGradient(cap, [landscape.stoneLight, landscape.stone]),
    );
    final foot = cap.shift(Offset(0, r.height - cap.height));
    _dueRounded(
      canvas,
      foot,
      6,
      _dueGradient(foot, [landscape.stoneLight, landscape.stone]),
    );
    if (!gate.open) {
      _dueRounded(
        canvas,
        r.deflate(4),
        7,
        _dueGradient(
          r,
          [const Color(0xFF9A5964), const Color(0xFFA9545F), landscape.stone],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      );
      for (var y = r.top + 24; y < r.bottom - 12; y += 22) {
        canvas.drawLine(
          Offset(r.left + 5, y + 7),
          Offset(r.right - 5, y - 5),
          Paint()
            ..color = const Color(0x56FFC7A6)
            ..strokeWidth = 2.9,
        );
      }
    }
    _drawDueGem(canvas, r.topCenter.translate(0, 8), 4.5, color);
    _badge(
      canvas,
      gate.open ? 'OPEN' : 'LOCKED',
      r.topCenter.translate(0, -13),
      color,
    );
  }

  void _drawExit(Canvas canvas) {
    final r = game.exit;
    final color = game.allObjectivesComplete ? _dueMint : _dueGold;
    final arch = RRect.fromRectAndCorners(
      r,
      topLeft: const Radius.circular(27),
      topRight: const Radius.circular(27),
    );
    final passage = RRect.fromRectAndCorners(
      r.deflate(8),
      topLeft: const Radius.circular(19),
      topRight: const Radius.circular(19),
    );
    canvas.drawRRect(
      arch,
      _dueGradient(
        r,
        [landscape.stoneLight, landscape.stone],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
    canvas.drawRRect(
      passage,
      _dueGradient(r, [
        _dueInk,
        Color.lerp(_dueInk, color, game.allObjectivesComplete ? .70 : .23)!,
      ]),
    );
    _drawDueGem(canvas, r.center.translate(0, -4), 8, color);
    final label = game.allObjectivesComplete
        ? 'EXIT'
        : game.lockedGates > 0
        ? '${game.lockedGates} LOCKS'
        : '${game.collectedSeals}/${game.seals.length} SEALS';
    _badge(canvas, label, r.topCenter.translate(0, -13), color);
  }

  void _drawTarget(Canvas canvas, _DueTarget target) {
    final r = target.rect;
    final stateColor = target.anchored
        ? _dueMint
        : target.debt < -1
        ? _dueBlue
        : target.debt > 1
        ? _dueGold
        : _dueCoral;
    final color = switch (target.kind) {
      _TargetKind.crate => const Color(0xFFBE8557),
      _TargetKind.enemy => const Color(0xFFEC8D69),
      _TargetKind.heavy => const Color(0xFFB97385),
      _TargetKind.drone => const Color(0xFFBA9CCC),
      _TargetKind.leecher => const Color(0xFF82B9A1),
      null => landscape.stoneLight,
    };

    switch (target.kind) {
      case _TargetKind.crate:
        _dueRounded(
          canvas,
          r,
          6,
          _dueGradient(
            r,
            [const Color(0xFFFFD29B), color, const Color(0xFF704736)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        );
        _dueRounded(
          canvas,
          r.deflate(4),
          4,
          Paint()..color = const Color(0x394C3030),
        );
        final braces = Path()
          ..moveTo(r.left + 5, r.top + 5)
          ..lineTo(r.right - 5, r.bottom - 5)
          ..moveTo(r.right - 5, r.top + 5)
          ..lineTo(r.left + 5, r.bottom - 5);
        canvas.drawPath(
          braces,
          Paint()
            ..color = const Color(0xAAFFE0AB)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        _drawDueGem(
          canvas,
          r.center,
          5.5,
          target.debt.abs() > 1 || target.anchored ? stateColor : _dueGold,
        );
      case _TargetKind.drone:
        final charging =
            target.droneRecoveryTimer <= 0 && target.abilityCooldown < .6;
        if (charging) {
          _dueGlow(canvas, r.center, r.width, _dueCoral.withValues(alpha: .65));
        }
        final flutter = math.sin(game.time * 22 + target.x) * .16;
        for (final side in [-1, 1]) {
          canvas.save();
          canvas.translate(r.center.dx + side * r.width * .28, r.center.dy);
          canvas.rotate(side * (-.52 + flutter));
          final wing = Rect.fromCenter(
            center: Offset(side * r.width * .27, -3),
            width: r.width * .72,
            height: 10,
          );
          canvas.drawOval(
            wing,
            _dueShade(wing, [
              const Color(0xFFF7D8FB),
              color,
              const Color(0xFF6C567F),
            ]),
          );
          canvas.restore();
        }
        _drawCreature(canvas, r.deflate(3), color, singleEye: true);
        if (charging) {
          _badge(canvas, 'PULSE', r.topCenter.translate(0, -14), _dueCoral);
        }
      case _TargetKind.leecher:
        final wisp = Path()
          ..moveTo(r.left, r.center.dy)
          ..quadraticBezierTo(r.left, r.top, r.center.dx, r.top)
          ..quadraticBezierTo(r.right, r.top, r.right, r.center.dy)
          ..quadraticBezierTo(r.right, r.bottom, r.center.dx + 1, r.bottom - 7)
          ..quadraticBezierTo(r.left - 4, r.bottom + 12, r.left, r.center.dy);
        canvas.drawPath(
          wisp,
          _dueShade(r, [
            const Color(0xFFCEF0D3),
            color,
            const Color(0xFF395668),
          ]),
        );
        _drawDueGem(canvas, r.center.translate(0, -2), 4.4, _dueCream);
      case _TargetKind.enemy:
      case _TargetKind.heavy:
        final helmet = Rect.fromLTRB(
          r.left,
          r.top,
          r.right,
          r.top + r.height * .70,
        );
        _drawCreature(canvas, r.deflate(2), color);
        canvas.drawArc(
          helmet,
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xA4FFE8C3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = target.kind == _TargetKind.heavy ? 3.8 : 1.8,
        );
      case null:
        break;
    }

    if (target.kind.isEnemy) {
      for (var i = 0; i < target.maxHealth; i++) {
        final x = r.center.dx + (i - (target.maxHealth - 1) / 2) * 6.5;
        canvas.drawCircle(
          Offset(x, r.bottom + 4),
          2.0,
          Paint()..color = i < target.health ? _dueCoral : _dueInk,
        );
      }
    }
    if (target.anchored) {
      _badge(canvas, 'BRIDGE', r.topCenter.translate(0, -12), stateColor);
    } else if (target.debt < -1) {
      _badge(canvas, 'LIGHT', r.topCenter.translate(0, -12), stateColor);
    } else if (target.debt > 1) {
      _badge(
        canvas,
        '×${(1 + target.debt * .035).toStringAsFixed(1)}',
        r.topCenter.translate(0, -12),
        stateColor,
      );
    }
  }

  void _drawCreature(
    Canvas canvas,
    Rect rect,
    Color color, {
    bool singleEye = false,
  }) {
    _dueRounded(
      canvas,
      rect,
      12,
      _dueShade(rect, [
        Color.lerp(color, _dueCream, .53)!,
        color,
        Color.lerp(color, _dueInk, .65)!,
      ]),
    );
    final face = Rect.fromCenter(
      center: rect.center.translate(0, -1),
      width: rect.width * .63,
      height: 10,
    );
    _dueRounded(canvas, face, 5, Paint()..color = _dueInk);
    for (final dx in singleEye ? [0.0] : [-4.2, 4.2]) {
      canvas.drawCircle(
        face.center.translate(dx, 0),
        2.2,
        Paint()..color = _dueCream,
      );
    }
  }

  void _drawEmitter(Canvas canvas, _DueEmitter emitter) {
    final p = emitter.position;
    final color = emitter.debt > 1 ? _dueGold : _dueCoral;
    final r = emitter.rect;
    _dueRounded(
      canvas,
      r,
      8,
      _dueShade(r, [
        const Color(0xFFE4A787),
        landscape.stoneLight,
        landscape.stone,
      ]),
    );
    final muzzle = p.translate(emitter.speed.sign * 17, 0);
    canvas.drawLine(
      p,
      muzzle,
      Paint()
        ..color = _dueInk
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    _drawDueGem(canvas, muzzle, 5, color);
    if (emitter.debt > 1) {
      _badge(canvas, '${emitter.debt.round()}%', p.translate(0, -24), color);
    }
  }

  void _drawBullet(Canvas canvas, _DueBullet bullet) {
    final color = bullet.reflected
        ? _dueBlue
        : bullet.debt > 1
        ? _dueGold
        : _dueCoral;
    final center = bullet.rect.center;
    final tail = center - Offset(bullet.vx.sign * 19, bullet.vy.sign * 3);
    canvas.drawLine(
      tail,
      center,
      Paint()
        ..color = color.withValues(alpha: .47)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    _dueGlow(canvas, center, 17, color.withValues(alpha: .64));
    canvas.drawCircle(center, 6, Paint()..color = color);
    canvas.drawCircle(center.translate(1, -1), 2.6, Paint()..color = _dueCream);
  }

  void _drawTether(Canvas canvas, Offset target, {required bool automatic}) {
    final start = game.player.center;
    final bend = Offset(
      (start.dx + target.dx) / 2,
      math.min(start.dy, target.dy) - 24,
    );
    final color = game.debt >= 3 ? _dueGold : _dueBlue;
    for (var i = 1; i < 12; i++) {
      final t = (i + game.time * 6 % 1) / 12;
      final point =
          start * ((1 - t) * (1 - t)) +
          bend * (2 * t * (1 - t)) +
          target * (t * t);
      canvas.drawCircle(
        point,
        i % 3 == 0 ? 1.9 : 1.25,
        Paint()..color = color.withValues(alpha: .68),
      );
    }
    if (automatic) {
      canvas.drawCircle(
        target,
        22 + math.sin(game.time * 6) * 2,
        Paint()
          ..color = color.withValues(alpha: .72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _drawTargetFrame(Canvas canvas, _DueGravityTarget target) {
    final inRange = game._targetInRange(target);
    final box = target.rect.inflate(6);
    const length = 8.0;
    final corners = Path();
    for (final (point, dx, dy) in [
      (box.topLeft, length, length),
      (box.topRight, -length, length),
      (box.bottomLeft, length, -length),
      (box.bottomRight, -length, -length),
    ]) {
      corners
        ..moveTo(point.dx + dx, point.dy)
        ..lineTo(point.dx, point.dy)
        ..lineTo(point.dx, point.dy + dy);
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xBA241D2A)
      ..strokeWidth = 4.4;
    canvas.drawPath(corners, paint);
    canvas.drawPath(
      corners,
      paint
        ..color = inRange ? _dueGold : const Color(0xFFBAA8BA)
        ..strokeWidth = 2.2,
    );
  }

  void _drawShockwave(Canvas canvas, _FallDueShockwave wave) {
    final progress = (wave.time / _FallDueShockwave.life).clamp(0.0, 1.0);
    final radius = wave.maxRadius * progress * (2 - progress);
    final alpha = math.pow(1 - progress, 1.45).toDouble();
    if (radius <= .5) return;
    final ground = Rect.fromCenter(
      center: wave.position,
      width: radius * 2,
      height: radius * .51,
    );
    canvas.drawOval(
      ground,
      _dueShade(
        ground,
        [wave.color.withValues(alpha: alpha * .36), Colors.transparent],
        center: Alignment.center,
        radius: .67,
      ),
    );
    for (final scale in [1.0, .77]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: wave.position,
          width: radius * 2 * scale,
          height: radius * .64 * scale,
        ),
        Paint()
          ..color = wave.color.withValues(alpha: alpha * scale)
          ..strokeWidth = 4 * (1 - progress * .7)
          ..style = PaintingStyle.stroke
          ..blendMode = BlendMode.screen,
      );
    }
    if (wave.maxRadius < 30) return;
    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5;
      final spark =
          wave.position +
          Offset(
            math.cos(angle) * radius * (.92 + i % 2 * .12),
            math.sin(angle) * radius * .30 - math.sin(progress * math.pi) * 16,
          );
      canvas.drawCircle(
        spark,
        1.3 + alpha * 1.4,
        Paint()..color = _dueCream.withValues(alpha: alpha * .86),
      );
    }
  }

  void _drawTransfer(Canvas canvas, _DueTransferArc arc) {
    final age = (arc.time / _DueTransferArc.life).clamp(0.0, 1.0);
    final alpha = 1 - age;
    final delta = arc.destination - arc.origin;
    final control =
        arc.origin + delta * .5 - Offset(0, math.min(64, delta.distance * .29));
    final curve = Path()
      ..moveTo(arc.origin.dx, arc.origin.dy)
      ..quadraticBezierTo(
        control.dx,
        control.dy,
        arc.destination.dx,
        arc.destination.dy,
      );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = arc.color.withValues(alpha: alpha * .26)
      ..strokeWidth = 8 * alpha + 1;
    canvas.drawPath(curve, track);
    canvas.drawPath(
      curve,
      track
        ..color = arc.color.withValues(alpha: alpha * .92)
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 4; i++) {
      final t = (age * 1.8 - i * .12).clamp(0.0, 1.0);
      final point =
          arc.origin * (1 - t) * (1 - t) +
          control * 2 * t * (1 - t) +
          arc.destination * t * t;
      canvas.drawCircle(
        point,
        (4.6 - i * .8) * alpha + .6,
        Paint()..color = _dueCream.withValues(alpha: alpha),
      );
    }
    _dueGlow(
      canvas,
      arc.destination,
      26,
      arc.color.withValues(alpha: alpha * .44),
    );
  }

  void _drawPlayerEffects(Canvas canvas) {
    final player = game.player;
    if (game._airDashRemaining > 0 && player.vx.abs() > 20) {
      final life = game._airDashRemaining / FallDueTuning.airDashDuration;
      for (var i = 3; i >= 1; i--) {
        final center = player.center.translate(
          -player.vx.sign * i * 14,
          i * 2.4,
        );
        final echo = Rect.fromCenter(
          center: center,
          width: 30 - i * 3.0,
          height: 30 - i * 4.0,
        );
        canvas.drawOval(
          echo,
          _dueShade(echo, [
            _dueCream.withValues(alpha: life * .40 / i),
            _dueBlue.withValues(alpha: life * .31 / i),
            _dueBlue.withValues(alpha: 0),
          ]),
        );
      }
    }
    if (game._slamming) {
      final strength = game._slamBorrowPower / 100;
      final center = player.center;
      final height = 53 + strength * 51;
      final tail = Path()
        ..moveTo(center.dx - 17, center.dy + 7)
        ..quadraticBezierTo(
          center.dx - 12,
          center.dy - height * .55,
          center.dx - 2,
          center.dy - height,
        )
        ..quadraticBezierTo(
          center.dx + 10,
          center.dy - height * .57,
          center.dx + 18,
          center.dy + 7,
        )
        ..close();
      canvas.drawPath(
        tail,
        _dueGradient(tail.getBounds(), [
          Colors.transparent,
          _dueCoral.withValues(alpha: .29),
          _dueGold.withValues(alpha: .60),
        ]),
      );
      _dueGlow(
        canvas,
        player.center,
        38 + strength * 20,
        _dueCoral.withValues(alpha: .58),
      );
      for (final x in [-12.0, 10.0]) {
        canvas.drawLine(
          player.center.translate(x, -22 - strength * 41),
          player.center.translate(x, 2),
          Paint()
            ..color = _dueCoral.withValues(alpha: .79)
            ..strokeWidth = 2 + strength * 2
            ..strokeCap = StrokeCap.round,
        );
      }
    } else if (game._antiGravityActive || game.inPayback) {
      final color = game.inPayback ? _dueGold : _dueBlue;
      _dueGlow(canvas, player.center, 37, color.withValues(alpha: .48));
      for (var i = 0; i < 3; i++) {
        final t = (game.time * 1.8 + i / 3) % 1;
        canvas.drawOval(
          Rect.fromCenter(
            center: player.rect.bottomCenter.translate(0, 3 + 16 * t),
            width: 23 + 37 * t,
            height: 6 + 7 * t,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0 + 1.5 * (1 - t)
            ..color = color.withValues(alpha: (1 - t) * .78),
        );
      }
    }
  }

  void _drawHero(
    Canvas canvas,
    Offset feet,
    double facing,
    bool grounded,
    double speed,
  ) {
    if (grounded) {
      final shadow = Rect.fromCenter(
        center: feet.translate(-6, 2),
        width: 43,
        height: 9,
      );
      canvas.drawOval(
        shadow,
        _dueShade(
          shadow,
          [const Color(0xAF231B29), const Color(0x00231B29)],
          center: Alignment.center,
          radius: .55,
        ),
      );
    }
    final stride = grounded
        ? math.sin(game.time * 17) * (speed / 42).clamp(0.0, 6.0)
        : 3.0;
    final lift = grounded ? stride.abs() * .23 : .0;
    canvas.save();
    canvas.translate(feet.dx, feet.dy);
    final squash =
        (1 - (game.time - game._landedAt) / .19).clamp(0.0, 1.0) *
        game._landingForce;
    final stretch = game._slamming ? .14 : 0.0;
    canvas.scale(
      facing * (1 + squash * .22 - stretch * .38),
      1 - squash * .28 + stretch,
    );
    const ivory = [Color(0xFFFFF6DB), Color(0xFFE6CAAF), Color(0xFF9B8DA9)];
    for (final side in [-1, 1]) {
      final boot = Rect.fromCenter(
        center: Offset(
          side * 5.4 + side * stride,
          -4 - math.max(0.0, side * stride),
        ),
        width: 9.3,
        height: 9,
      );
      _dueRounded(canvas, boot, 3.8, _dueShade(boot, ivory));
      final arm = Rect.fromCenter(
        center: Offset(side * 10.9, -13 - lift + side * stride * .35),
        width: 7.2,
        height: 15.0,
      );
      canvas.drawOval(arm, _dueShade(arm, ivory));
    }
    final body = Rect.fromCenter(
      center: Offset(0, -13 - lift),
      width: 21,
      height: 21,
    );
    canvas.drawOval(body, _dueShade(body, ivory));
    final drag = (speed / 42).clamp(0.0, 7.0);
    final flutter = math.sin(game.time * 19) * (.6 + drag * .45);
    final scarfTail = Path()
      ..moveTo(-.5, -23 - lift)
      ..quadraticBezierTo(-14, -24 - lift, -21 - drag, -18 - lift + flutter)
      ..quadraticBezierTo(-10, -17 - lift, .5, -20 - lift);
    canvas.drawPath(scarfTail, Paint()..color = const Color(0xFFC75C50));
    final neck = Rect.fromCenter(
      center: Offset(.2, -22 - lift),
      width: 19,
      height: 6,
    );
    _dueRounded(
      canvas,
      neck,
      3,
      _dueGradient(neck, [const Color(0xFFFA9E77), const Color(0xFFAD4D53)]),
    );
    final head = Rect.fromCenter(
      center: Offset(1, -35 - lift),
      width: 37,
      height: 31,
    );
    canvas.drawOval(
      head,
      _dueShade(
        head,
        [
          const Color(0xFFFFF9DB),
          const Color(0xFFF4D9BA),
          const Color(0xFFC4AAC0),
          const Color(0xFF877792),
        ],
        center: const Alignment(.61, -.80),
        radius: 1.08,
      ),
    );
    final blink = game.time % 5.8 > 5.64;
    for (final x in [5.2, 13.2]) {
      final eye = Rect.fromCenter(
        center: Offset(x, -34 - lift),
        width: 2.9,
        height: blink ? 1.2 : 7.1,
      );
      _dueRounded(canvas, eye, 2, Paint()..color = const Color(0xFF332733));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FallPainter oldDelegate) => true;
}
