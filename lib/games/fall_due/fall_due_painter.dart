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
    final preparedWorld = !preview || game.platforms.isNotEmpty;
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
    final workshops = game.workshops.where((workshop) => world.overlaps(workshop.view)).toList();
    for (final workshop in workshops) {
      _drawWorkshopBackground(canvas, workshop, world);
    }

    for (final platform in preparedWorld ? game.platforms : stage.platforms) {
      if (!world.overlaps(platform)) continue;
      if (game.crumblingLedges.any((c) => c.rect == platform)) continue;
      if (game.weakPanels.any((w) => w.rect == platform)) continue;
      _drawPlatform(canvas, platform);
      _drawScenery(canvas, platform);
    }
    final spikes = preparedWorld ? game.spikes : stage.spikes;
    final trapRects = preparedWorld
        ? game.spikeTraps.map((t) => t.rect)
        : stage.allSpikeTraps.map((t) => t.rect);
    for (var index = 0; index < spikes.length; index++) {
      final s = spikes[index];
      if (!world.overlaps(s)) continue;
      if (trapRects.any((r) => r.overlaps(s))) continue;
      _drawSpikes(canvas, s, game.disabledSpikes.contains(index));
    }
    if (game._openingRelay case final opening?) {
      _drawOpeningRelay(canvas, opening, world);
    }

    if (preview) {
      for (final well in game.gravityWells) {
        if (world.contains(well.center)) _drawGravityWell(canvas, well);
      }
      for (final workshop in workshops) {
        _drawWorkshopMachines(canvas, workshop, world);
      }
      for (final seal in preparedWorld ? game.seals.map((seal) => seal.position) : stage.seals) {
        if (world.contains(seal)) _drawSeal(canvas, seal);
      }
      _drawHero(
        canvas,
        preparedWorld ? game.player.rect.bottomCenter : Offset(stage.platforms.first.left + 160, stage.platforms.first.top),
        1,
        true,
        0,
      );
      canvas.restore();
      return;
    }

    for (final workshop in workshops) {
      _drawWorkshopMachines(canvas, workshop, world);
    }
    if (game.activeBoss case final boss?) {
      _drawNativeBoss(canvas, boss, world);
    }

    for (final panel in game.weakPanels) {
      if (world.overlaps(panel.rect)) _drawWeakPanel(canvas, panel);
    }
    for (final ledge in game.crumblingLedges) {
      if (world.overlaps(ledge.rect)) _drawCrumblingLedge(canvas, ledge);
    }
    for (final trap in game.spikeTraps) {
      if (world.overlaps(trap.rect)) _drawSpikeTrap(canvas, trap);
    }
    for (final well in game.gravityWells) {
      if (world.contains(well.center) || world.overlaps(well.rect)) {
        _drawGravityWell(canvas, well);
      }
    }
    for (final laser in game.laserGates) {
      if (world.overlaps(laser.rect)) _drawLaserGate(canvas, laser);
    }
    for (final vent in game.vents) {
      if (world.overlaps(vent.rect)) _drawKineticVent(canvas, vent);
    }
    for (final conduit in game.conduits) {
      _drawConduit(canvas, conduit);
    }
    for (final plate in game.weightPlates) {
      if (world.overlaps(plate.rect)) _drawWeightPlate(canvas, plate);
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
    _drawEnemyTell(canvas, target);
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
      _TargetKind.swordsman => const Color(0xFFE5A823),
      _TargetKind.archer => const Color(0xFF4EA5A0),
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
        final charging = target.attackTell > 0;
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
      case _TargetKind.swordsman:
        final facing = target.attackDirection;
        _drawCreature(canvas, r.deflate(2), color);
        final helm = Rect.fromLTRB(
          r.left,
          r.top - 2,
          r.right,
          r.top + r.height * .55,
        );
        canvas.drawArc(
          helm,
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFFFFD280)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
        canvas.drawLine(
          Offset(r.center.dx - 5, r.top + 8),
          Offset(r.center.dx + 5, r.top + 8),
          Paint()
            ..color = const Color(0xFFFF4053)
            ..strokeWidth = 2.0,
        );
        final attacking = target.attackTell > 0;
        final swordAngle = attacking
            ? (facing > 0 ? -0.9 : 0.9)
            : (facing > 0 ? 0.35 : -0.35);
        canvas.save();
        canvas.translate(r.center.dx + facing * 8, r.center.dy);
        canvas.rotate(swordAngle);
        canvas.drawLine(
          const Offset(0, 4),
          const Offset(0, -4),
          Paint()
            ..color = const Color(0xFF8A6538)
            ..strokeWidth = 3,
        );
        canvas.drawLine(
          const Offset(-3, 0),
          const Offset(3, 0),
          Paint()
            ..color = const Color(0xFFFFD56B)
            ..strokeWidth = 3,
        );
        final bladePath = Path()
          ..moveTo(-2, 0)
          ..lineTo(-1.5, 24)
          ..lineTo(0, 29)
          ..lineTo(1.5, 24)
          ..lineTo(2, 0)
          ..close();
        canvas.drawPath(
          bladePath,
          Paint()
            ..color = attacking
                ? const Color(0xFFFFE082)
                : const Color(0xFFE0E6ED),
        );
        canvas.drawPath(
          bladePath,
          Paint()
            ..color = _dueInk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        if (attacking) {
          _dueGlow(
            canvas,
            const Offset(0, 16),
            14,
            const Color(0xFFFFAB40).withValues(alpha: 0.7),
          );
        }
        canvas.restore();
      case _TargetKind.archer:
        final facing = target.attackDirection;
        _drawCreature(canvas, r.deflate(2), color);
        final hood = Path()
          ..moveTo(r.left - 2, r.top + 10)
          ..quadraticBezierTo(r.center.dx, r.top - 6, r.right + 2, r.top + 10)
          ..quadraticBezierTo(r.right, r.top + 2, r.center.dx, r.top + 4)
          ..quadraticBezierTo(r.left, r.top + 2, r.left - 2, r.top + 10);
        canvas.drawPath(hood, Paint()..color = const Color(0xFF2C5E55));
        canvas.drawPath(
          hood,
          Paint()
            ..color = _dueInk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        final bowCenter = r.center + Offset(facing * 12, 0);
        final bowArc = Path()
          ..moveTo(bowCenter.dx + facing * 2, bowCenter.dy - 16)
          ..quadraticBezierTo(
            bowCenter.dx + facing * 12,
            bowCenter.dy,
            bowCenter.dx + facing * 2,
            bowCenter.dy + 16,
          );
        canvas.drawPath(
          bowArc,
          Paint()
            ..color = const Color(0xFF8D5B4C)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(bowCenter.dx + facing * 2, bowCenter.dy - 16),
          Offset(
            bowCenter.dx - facing * (target.attackTell > 0 ? 4 : 0),
            bowCenter.dy,
          ),
          Paint()
            ..color = const Color(0xFFF0E6D2)
            ..strokeWidth = 1.2,
        );
        canvas.drawLine(
          Offset(
            bowCenter.dx - facing * (target.attackTell > 0 ? 4 : 0),
            bowCenter.dy,
          ),
          Offset(bowCenter.dx + facing * 2, bowCenter.dy + 16),
          Paint()
            ..color = const Color(0xFFF0E6D2)
            ..strokeWidth = 1.2,
        );
        if (target.attackTell > 0) {
          canvas.drawLine(
            bowCenter,
            target.attackAim,
            Paint()
              ..color = const Color(0xFFFF5252).withValues(alpha: 0.45)
              ..strokeWidth = 1.2
              ..strokeCap = StrokeCap.round,
          );
          _drawDueGem(
            canvas,
            bowCenter + Offset(facing * 6, 0),
            4,
            const Color(0xFFFF5252),
          );
        }
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
    final color = emitter.reprogrammed
        ? _dueMint
        : emitter.debt > 1
        ? _dueGold
        : _dueCoral;
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
    if (emitter.reprogrammed) {
      _badge(canvas, 'HIJACKED', p.translate(0, -24), _dueMint);
    } else if (emitter.debt > 1) {
      _badge(canvas, '${emitter.debt.round()}%', p.translate(0, -24), color);
    }
  }

  void _drawBullet(Canvas canvas, _DueBullet bullet) {
    final color = bullet.reflected
        ? _dueBlue
        : bullet.debt > 1
        ? _dueGold
        : (bullet.arrow ? const Color(0xFFE89A3C) : _dueCoral);
    final center = bullet.rect.center;
    if (bullet.arrow) {
      final angle = math.atan2(bullet.vy, bullet.vx);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final shaftPaint = Paint()
        ..color = const Color(0xFFD6C298)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-14, 0), const Offset(10, 0), shaftPaint);
      final headPath = Path()
        ..moveTo(14, 0)
        ..lineTo(6, -4.5)
        ..lineTo(8, 0)
        ..lineTo(6, 4.5)
        ..close();
      canvas.drawPath(headPath, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawPath(
        headPath,
        Paint()
          ..color = _dueInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      final fletchPaint = Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-12, 0), const Offset(-16, -4), fletchPaint);
      canvas.drawLine(const Offset(-12, 0), const Offset(-16, 4), fletchPaint);
      canvas.drawLine(const Offset(-8, 0), const Offset(-12, -4), fletchPaint);
      canvas.drawLine(const Offset(-8, 0), const Offset(-12, 4), fletchPaint);
      canvas.drawLine(
        const Offset(-22, 0),
        const Offset(-14, 0),
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..strokeWidth = 2.0,
      );
      canvas.restore();
      return;
    }
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

    if (game.isPhaseShiftActive) {
      final t = game.time * 6.0;
      final shiftGlow = Color.lerp(
        const Color(0xFF6CF0FF),
        const Color(0xFFFF7DF9),
        (math.sin(t) + 1) / 2,
      )!;
      _dueGlow(canvas, player.center, 44, shiftGlow.withValues(alpha: 0.65));
      for (final off in [const Offset(-4, 0), const Offset(4, 0)]) {
        canvas.drawOval(
          player.rect.shift(off).inflate(2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = shiftGlow.withValues(alpha: 0.40),
        );
      }
    }

    if (game.isWallSliding) {
      final wallX = game._wallSlideDirection < 0 ? player.left : player.right;
      final sparksY = player.top + player.h * 0.7;
      canvas.drawLine(
        Offset(wallX, player.top),
        Offset(wallX, player.bottom),
        Paint()
          ..color = _dueGold.withValues(alpha: 0.7)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      _dueGlow(
        canvas,
        Offset(wallX, sparksY),
        18,
        _dueGold.withValues(alpha: 0.6),
      );
    }

    if (game.isTetherActive && game._tetherTarget != null) {
      final target = game._tetherTarget!;
      final p1 = player.center;
      final p2 = target.center;
      final beamPaint = Paint()
        ..color = const Color(0xFF8CFFB1).withValues(alpha: 0.75)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p1, p2, beamPaint);
      final mid = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2 - 8 * math.sin(game.time * 8),
      );
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF42E8FF).withValues(alpha: 0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
      _dueGlow(canvas, p1, 20, const Color(0xFF8CFFB1).withValues(alpha: 0.6));
      _dueGlow(canvas, p2, 24, const Color(0xFF8CFFB1).withValues(alpha: 0.8));
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

  void _drawCrumblingLedge(Canvas canvas, _DueCrumblingLedge ledge) {
    if (ledge.collapsed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(ledge.rect, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = _dueCream.withValues(alpha: 0.15),
      );
      return;
    }
    final alpha = ledge.collapsing
        ? 0.4 + 0.6 * (ledge.collapseTimer / ledge.maxCollapseTime)
        : 1.0;
    final rrect = RRect.fromRectAndRadius(ledge.rect, const Radius.circular(4));
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFF7A6858).withValues(alpha: alpha),
    );
    if (ledge.collapsing) {
      final crackPaint = Paint()
        ..color = _dueCoral.withValues(alpha: 0.85)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      final x = ledge.rect.left + ledge.rect.width * 0.35;
      final x2 = ledge.rect.left + ledge.rect.width * 0.7;
      canvas.drawLine(
        Offset(x, ledge.rect.top),
        Offset(x + 5, ledge.rect.bottom),
        crackPaint,
      );
      canvas.drawLine(
        Offset(x2, ledge.rect.top),
        Offset(x2 - 4, ledge.rect.bottom),
        crackPaint,
      );
    }
    canvas.drawLine(
      ledge.rect.topLeft,
      ledge.rect.topRight,
      Paint()
        ..color = const Color(0xFFD4A373).withValues(alpha: alpha)
        ..strokeWidth = 2.0,
    );
  }

  void _drawSpikeTrap(Canvas canvas, _DueSpikeTrap trap) {
    final rect = trap.rect;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.bottom - 8, rect.width, 8),
      Paint()..color = const Color(0xFF3E394A),
    );
    if (trap.crushedToBridge) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left,
            rect.top + rect.height * 0.65,
            rect.width,
            rect.height * 0.35,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF8E9BB0),
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + rect.height * 0.65),
        Offset(rect.right, rect.top + rect.height * 0.65),
        Paint()
          ..color = _dueMint
          ..strokeWidth = 2.0,
      );
      return;
    }
    if (trap.disarmed) return;
    final active = trap.isActive(game.time);
    final telegraphing = trap.isTelegraphing(game.time);
    if (telegraphing) {
      _dueGlow(
        canvas,
        Offset(rect.center.dx, rect.top + 6),
        rect.width * 0.4,
        const Color(0xFFFFB300).withValues(alpha: 0.55),
      );
    }
    if (active) {
      final toothCount = (rect.width / 16).clamp(2, 24).toInt();
      final toothW = rect.width / toothCount;
      final spikePath = Path();
      for (var i = 0; i < toothCount; i++) {
        final x0 = rect.left + i * toothW;
        final xMid = x0 + toothW / 2;
        final x1 = x0 + toothW;
        spikePath.moveTo(x0, rect.bottom - 6);
        spikePath.lineTo(xMid, rect.top);
        spikePath.lineTo(x1, rect.bottom - 6);
      }
      spikePath.close();
      canvas.drawPath(
        spikePath,
        Paint()..color = const Color(0xFFFF4865),
      );
      _dueGlow(
        canvas,
        rect.center,
        rect.height,
        const Color(0xFFFF4865).withValues(alpha: 0.45),
      );
    } else {
      final toothCount = (rect.width / 16).clamp(2, 24).toInt();
      final toothW = rect.width / toothCount;
      for (var i = 0; i < toothCount; i++) {
        final xMid = rect.left + i * toothW + toothW / 2;
        canvas.drawCircle(
          Offset(xMid, rect.bottom - 10),
          2.0,
          Paint()..color = const Color(0xFF8E8899),
        );
      }
    }
  }

  void _drawGravityWell(Canvas canvas, _DueGravityWell well) {
    if (well.rig != null) {
      _drawRouteRig(canvas, well);
      return;
    }
    final center = well.center;
    final inverted = well.inverted;
    final color = inverted ? const Color(0xFF5CE1E6) : const Color(0xFFB37DFF);
    final t = game.time;
    for (var r = 1; r <= 3; r++) {
      final ringR = (r * 18.0 + (t * 22.0 * (inverted ? -1 : 1))) % 56.0;
      canvas.drawCircle(
        center,
        ringR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = color.withValues(alpha: (1.0 - ringR / 56.0) * 0.8),
      );
    }
    canvas.drawCircle(
      center,
      12.0,
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      center,
      6.0,
      Paint()..color = Colors.white,
    );
    _dueGlow(canvas, center, 42, color.withValues(alpha: 0.6));
    _badge(canvas, well.label, center.translate(0, -32), color);
  }

  void _drawLaserGate(Canvas canvas, _DueLaserGate laser) {
    final rect = laser.rect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left - 4, rect.top - 8, rect.width + 8, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A4458),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left - 4, rect.bottom, rect.width + 8, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A4458),
    );
    final active = laser.isActive(game.time, false);
    if (!active) {
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        Paint()
          ..color = const Color(0xFF4A4458).withValues(alpha: 0.3)
          ..strokeWidth = 1.0,
      );
      return;
    }

    final occludingCrate = game.targets.where((t) =>
        t.alive &&
        t.kind == _TargetKind.crate &&
        t.rect.right > rect.left + 2 &&
        t.rect.left < rect.right - 2 &&
        (t.rect.overlaps(rect) ||
            (t.rect.bottom >= rect.top - 8 && t.rect.top <= rect.top + 20)),
    ).firstOrNull;

    final blockedOnTop = occludingCrate != null &&
        (occludingCrate.rect.bottom <= rect.top + 10 ||
            occludingCrate.rect.top <= rect.top + 6);

    if (blockedOnTop) {
      canvas.drawCircle(
        Offset(rect.center.dx, rect.top),
        5.0,
        Paint()..color = const Color(0xFFFF2A55).withValues(alpha: 0.8),
      );
      _badge(canvas, 'BLOCKED', Offset(rect.center.dx, rect.top - 16), const Color(0xFF62E9FF));
      return;
    }

    final beamBottom = occludingCrate != null
        ? math.max(rect.top, occludingCrate.rect.top)
        : rect.bottom;

    final nearWell = game.gravityWells.where((w) =>
        (w.center.dx - rect.center.dx).abs() < w.radius &&
        w.center.dy >= rect.top - 30 &&
        w.center.dy <= rect.bottom + 30,
    ).firstOrNull;

    final pulse = 0.8 + 0.2 * math.sin(game.time * 16.0);
    final beamColor = nearWell != null ? const Color(0xFFE249FF) : const Color(0xFFFF2A55);
    final beamPaint = Paint()
      ..color = beamColor.withValues(alpha: pulse)
      ..strokeWidth = rect.width.clamp(3.0, 12.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = (rect.width * 0.4).clamp(1.5, 4.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (nearWell != null) {
      final bendX = (nearWell.center.dx - rect.center.dx) * 0.45;
      final path = Path()
        ..moveTo(rect.center.dx, rect.top)
        ..quadraticBezierTo(
          rect.center.dx + bendX,
          (rect.top + beamBottom) / 2,
          rect.center.dx,
          beamBottom,
        );
      canvas.drawPath(path, beamPaint);
      canvas.drawPath(path, corePaint);
      _dueGlow(
        canvas,
        Offset(rect.center.dx + bendX * 0.5, (rect.top + beamBottom) / 2),
        rect.height * 0.5,
        beamColor.withValues(alpha: 0.5),
      );
    } else {
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, beamBottom),
        beamPaint,
      );
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, beamBottom),
        corePaint,
      );
      _dueGlow(
        canvas,
        Offset(rect.center.dx, (rect.top + beamBottom) / 2),
        (beamBottom - rect.top) * 0.6,
        const Color(0xFFFF2A55).withValues(alpha: 0.5),
      );
    }

    if (occludingCrate != null) {
      _drawDueGem(canvas, Offset(rect.center.dx, beamBottom), 5.5, const Color(0xFFFFD86E));
      _dueGlow(canvas, Offset(rect.center.dx, beamBottom), 14, const Color(0xFFFF2A55));
    }
  }

  void _drawKineticVent(Canvas canvas, _DueKineticVent vent) {
    final rect = vent.rect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF2C2836),
    );
    final active = vent.isActive(game.time);
    if (!active) return;
    final color =
        vent.isUpdraft ? const Color(0xFF62E9FF) : const Color(0xFFFF9548);
    final t = game.time * 3.5;
    final streakCount = (rect.width / 12).clamp(2, 6).toInt();
    final streakW = rect.width / streakCount;
    for (var i = 0; i < streakCount; i++) {
      final x = rect.left + i * streakW + streakW / 2;
      final phase = (t + i * 0.3) % 1.0;
      final yStart = vent.isUpdraft
          ? rect.top - phase * 60
          : rect.bottom + phase * 60;
      final yEnd = vent.isUpdraft ? yStart - 18 : yStart + 18;
      canvas.drawLine(
        Offset(x, yStart),
        Offset(x, yEnd),
        Paint()
          ..color = color.withValues(alpha: (1.0 - phase) * 0.8)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
    _dueGlow(canvas, rect.center, 24, color.withValues(alpha: 0.45));
  }

  void _drawConduit(Canvas canvas, _DueConduit conduit) {
    final p1 = conduit.emitterPos;
    final p2 = conduit.receptorPos;
    final connected = conduit.connected;
    final color = connected ? _dueMint : const Color(0xFFB08968);
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = color.withValues(alpha: connected ? 0.9 : 0.4)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(p1, 6.0, Paint()..color = color);
    canvas.drawCircle(p2, 6.0, Paint()..color = color);
    if (connected) {
      _dueGlow(canvas, p1, 16, _dueMint.withValues(alpha: 0.6));
      _dueGlow(canvas, p2, 16, _dueMint.withValues(alpha: 0.6));
    }
  }

  void _drawWeightPlate(Canvas canvas, _DueWeightPlate plate) {
    final rect = plate.rect;
    final satisfied = plate.satisfied;
    final color = satisfied ? _dueMint : const Color(0xFFE29578);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF282330),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color,
    );
    if (satisfied) {
      _dueGlow(canvas, rect.center, 18, _dueMint.withValues(alpha: 0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _FallPainter oldDelegate) => true;
}
