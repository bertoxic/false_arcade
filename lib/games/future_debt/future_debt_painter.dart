part of 'future_debt_game.dart';

/// Shares the arena's palette, cover and character drawing with the selector.
class FutureDebtCover extends StatelessWidget {
  const FutureDebtCover({super.key, this.muted = false});

  static final _scene = _FutureDebtGame(
    campaign: GameLevelGenerator.generate('future_debt', 1),
  );

  final bool muted;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _FuturePainter(_scene, null, null, cover: true)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(muted ? 0x6C28202B : 0x1728202B),
                Colors.transparent,
                const Color(0xD1251E29),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _FuturePainter extends CustomPainter {
  _FuturePainter(
    this.game,
    this.floorArt,
    this.treeArt, {
    this.cover = false,
    this.safeInsets = EdgeInsets.zero,
  }) : palette =
           _ArenaPalette.values[game._plan.act % _ArenaPalette.values.length];

  final _FutureDebtGame game;
  final ui.Image? floorArt;
  final ui.Image? treeArt;
  final bool cover;
  final EdgeInsets safeInsets;
  final _ArenaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const coverView = Size(_FutureDebtGame.width, _FutureDebtGame.height);
    final logical = cover ? coverView : FutureDebtRules.arenaView(size);
    final fullView = Offset.zero & logical;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (cover) {
      final scale = math.max(
        size.width / logical.width,
        size.height / logical.height,
      );
      canvas.translate(
        (size.width - logical.width * scale) / 2,
        (size.height - logical.height * scale) / 2,
      );
      canvas.scale(scale);
    } else {
      canvas.scale(size.width / logical.width);
    }
    final shake = Offset(
      math.sin(game.time * 72) * game.screenShake * .5,
      math.cos(game.time * 89) * game.screenShake * .5,
    );
    final origin = game.cameraCenter - fullView.center - shake;
    final camera = Offset(
      origin.dx.clamp(
        0.0,
        math.max(0.0, _FutureDebtGame.worldWidth - logical.width),
      ),
      origin.dy.clamp(
        0.0,
        math.max(0.0, _FutureDebtGame.worldHeight - logical.height),
      ),
    );
    final shown = fullView.shift(camera);
    canvas.save();
    canvas.translate(-camera.dx, -camera.dy);
    _world(canvas, shown.inflate(75));
    canvas.restore();
    canvas.drawRect(
      fullView,
      Paint()
        ..shader = const RadialGradient(
          radius: .93,
          colors: [Colors.transparent, Color(0x00302630), Color(0x58291D2D)],
          stops: [0, .53, 1],
        ).createShader(fullView),
    );
    canvas.restore();
    if (!cover && game.isPlaying) _minimap(canvas, size, shown);
  }

  void _world(Canvas canvas, Rect visible) {
    _floor(canvas, visible);
    final stretch = visible.inflate(125);
    final layers = <_ArenaLayer>[];

    for (final grove in game.arenaGroves) {
      if (!stretch.contains(grove.foot)) continue;
      _treeShadow(canvas, grove);
      layers.add(_ArenaLayer(grove.foot.dy, () => _tree(canvas, grove)));
    }
    for (final wall in game.walls) {
      if (wall.health <= 0 || !visible.overlaps(wall.bounds)) continue;
      _longShadow(canvas, wall.bounds, const Offset(-26, 33), blur: 4);
      if (wall.crate) {
        layers.add(
          _ArenaLayer(
            wall.bounds.bottom,
            () => _crate(canvas, wall.bounds, wall.health / wall.maxHealth),
          ),
        );
      }
    }
    for (final block in game.arenaBlocks) {
      if (block.wall.health <= 0 || !visible.overlaps(block.bounds)) continue;
      layers.add(
        _ArenaLayer(block.bounds.bottom, () => _stoneBlock(canvas, block)),
      );
    }
    for (final portal in game.portals) {
      if (visible.contains(portal.position)) {
        _portal(
          canvas,
          portal.position,
          portal.radius,
          portal.phase,
          _futureLilac,
        );
      }
    }
    if (game.levelExit case final exit? when visible.contains(exit.position)) {
      _portal(canvas, exit.position, exit.radius, exit.phase, _futureGold);
    }
    for (final pickup in game.pickups) {
      if (!pickup.dead && visible.contains(pickup.position)) {
        layers.add(
          _ArenaLayer(pickup.position.dy, () => _pickup(canvas, pickup)),
        );
      }
    }

    for (final enemy in game.enemies) {
      if (enemy.dead || !visible.contains(enemy.position)) continue;
      _actorShadow(canvas, enemy.position, enemy.radius * 1.25);
      layers.add(_ArenaLayer(enemy.position.dy, () => _enemy(canvas, enemy)));
    }
    for (final echo in game.echoes) {
      if (echo.dead || !visible.contains(echo.position)) continue;
      layers.add(_ArenaLayer(echo.position.dy, () => _echo(canvas, echo)));
    }
    if (game.collector case final boss? when visible.contains(boss.position)) {
      _actorShadow(canvas, boss.position, 29);
      layers.add(_ArenaLayer(boss.position.dy, () => _collector(canvas, boss)));
    }

    if (cover) {
      const rover = Offset(1649, 1118);
      const gunner = Offset(1710, 925);
      _actorShadow(canvas, rover, 18);
      _actorShadow(canvas, gunner, 23);
      layers.addAll([
        _ArenaLayer(
          rover.dy,
          () => _hound(canvas, rover, normalizedOr(game.player - rover), 14, 1),
        ),
        _ArenaLayer(
          gunner.dy,
          () => _auditor(
            canvas,
            gunner,
            normalizedOr(game.player - gunner),
            17,
            0,
            .78,
          ),
        ),
      ]);
    }
    _actorShadow(canvas, game.player, 22);
    for (final pulse in game.pulses) {
      if (stretch.contains(pulse.position)) _pulse(canvas, pulse);
    }
    _drawGhostTrail(canvas, visible);
    _dashRibbon(canvas);
    final phasingThroughCover =
        game.moveBoost > 0 &&
        game._blocked(game.player, _FutureDebtGame.playerRadius);
    if (!phasingThroughCover) {
      layers.add(_ArenaLayer(game.player.dy, () => _player(canvas)));
    }

    layers.sort((a, b) => a.depth.compareTo(b.depth));
    for (final layer in layers) {
      layer.draw();
    }
    if (phasingThroughCover) _player(canvas);
    for (final shot in game.shots) {
      if (visible.contains(shot.position)) {
        _shot(
          canvas,
          shot.position,
          shot.velocity,
          shot.charged ? const Color(0xFFB7F8D5) : _futureGold,
          shot.charged ? 3.6 : 2.7,
        );
      }
    }
    for (final shot in game.enemyShots) {
      if (!visible.contains(shot.position)) continue;
      final color = switch (shot.type) {
        _FutureShotType.collector => const Color(0xFFFA8CBB),
        _ => _futureCoral,
      };
      _shot(canvas, shot.position, shot.velocity, color, shot.radius * .45);
    }
    if (cover) {
      for (final step in [0, 1, 2]) {
        _shot(
          canvas,
          Offset(1563 + step * 30, 995 - step * 16),
          const Offset(460, -240),
          _futureGold,
          3,
        );
      }
    }
    for (final particle in game.particles) {
      if (visible.contains(particle.position)) _particle(canvas, particle);
    }
  }

  void _actorShadow(Canvas canvas, Offset feet, double width) {
    canvas.save();
    canvas.translate(feet.dx - width * .45, feet.dy + width * .59);
    canvas.rotate(-.72);
    final cast = Rect.fromCenter(
      center: Offset.zero,
      width: width * 2.3,
      height: width * 1.13,
    );
    canvas.drawOval(
      cast,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xAA302130), Color(0x69302130), Color(0x03302130)],
          stops: [0, .60, 1],
        ).createShader(cast),
    );
    canvas.restore();
    final contact = Rect.fromCenter(
      center: feet,
      width: width * 1.45,
      height: width * .69,
    );
    canvas.drawOval(
      contact,
      Paint()
        ..color = const Color(0x76332631)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _pickup(Canvas canvas, _FuturePickup pickup) {
    final anchor = pickup.position;
    final size = pickup.kind == _FuturePickupKind.caseFile ? 12.0 : 9.5;
    final p = anchor.translate(0, -9 + math.sin(pickup.spin * 1.9) * 4);
    final color = switch (pickup.kind) {
      _FuturePickupKind.time => _futureGold,
      _FuturePickupKind.writeoff => _futureMint,
      _FuturePickupKind.compound => const Color(0xFFFF9C6D),
      _FuturePickupKind.cashOut => const Color(0xFFFFDE8D),
      _FuturePickupKind.caseFile => const Color(0xFFFFE9A2),
    };
    _arenaGlow(canvas, p, size * 3.6, color.withValues(alpha: .50));
    canvas.drawOval(
      Rect.fromCenter(center: anchor, width: size * 4.2, height: size * 2.40),
      Paint()
        ..color = color.withValues(alpha: .38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    if (pickup.kind == _FuturePickupKind.caseFile) {
      final paper = Rect.fromCenter(center: p, width: 18, height: 22);
      _arenaRound(
        canvas,
        paper,
        3,
        _arenaLinear(paper, [_futureCream, color, const Color(0xFFB97A4A)]),
      );
      for (var i = 0; i < 3; i++) {
        canvas.drawLine(
          p.translate(-5, i * 4.0 - 4),
          p.translate(4.0 - i, i * 4.0 - 4),
          Paint()
            ..color = const Color(0xFF9D6450)
            ..strokeWidth = 1.3,
        );
      }
      return;
    }
    if (pickup.kind == _FuturePickupKind.compound) {
      for (var i = -1; i <= 1; i++) {
        final center = p.translate(i * 7.0, i.abs() * 4.0);
        final capsule = Rect.fromCenter(center: center, width: 5.5, height: 14);
        _arenaRound(
          canvas,
          capsule,
          2.5,
          _arenaClay(capsule, [_futureCream, color, const Color(0xFFC75248)]),
        );
      }
      return;
    }
    _gem(canvas, p, size, color, .76 + math.sin(pickup.spin * 2).abs() * .24);
    if (pickup.kind == _FuturePickupKind.cashOut) {
      final mark = p.translate(2, 0);
      final paint = Paint()
        ..color = const Color(0xFF633D39)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(mark.translate(-4, 0), mark.translate(4, 0), paint);
      canvas.drawLine(mark.translate(0, -4), mark.translate(0, 4), paint);
    }
  }

  void _gem(
    Canvas canvas,
    Offset p,
    double size,
    Color color, [
    double width = 1,
  ]) {
    final top = p.translate(0, -size * 1.28);
    final right = p.translate(size * width, 0);
    final bottom = p.translate(0, size * 1.28);
    final left = p.translate(-size * width, 0);
    final edge = _arenaShape([top, right, bottom, left]);
    canvas.drawPath(edge, Paint()..color = color);
    canvas.drawPath(
      _arenaShape([top, left, p]),
      Paint()..color = Color.lerp(color, Colors.white, .72)!,
    );
    canvas.drawPath(
      _arenaShape([p, right, bottom]),
      Paint()..color = Color.lerp(color, const Color(0xFFA54D43), .41)!,
    );
    canvas.drawPath(
      edge,
      Paint()
        ..color = const Color(0xE5FFF4CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _portal(
    Canvas canvas,
    Offset p,
    double radius,
    double phase,
    Color color,
  ) {
    final stone = Rect.fromCenter(
      center: p.translate(0, 3),
      width: radius * 2.55,
      height: radius * 1.81,
    );
    canvas.drawOval(stone, _arenaLinear(stone, [palette.stone, _futureInk]));
    final disk = stone.shift(const Offset(0, -6)).deflate(4);
    canvas.drawOval(
      disk,
      _arenaLinear(disk, [const Color(0xFFF3C4A5), palette.stone, _futureInk]),
    );
    final pool = disk.deflate(5);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: .93),
            Color.lerp(color, _futureInk, .50)!,
            _futureInk,
          ],
        ).createShader(pool),
    );
    _arenaGlow(
      canvas,
      p.translate(0, -7),
      radius * 1.65,
      color.withValues(alpha: .36),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        pool.deflate(i * 2.5),
        phase + i * 2.1,
        2.25,
        false,
        Paint()
          ..color = color.withValues(alpha: .82 - i * .19)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
    _gem(canvas, p.translate(0, -16 + math.sin(phase) * 3), 5.4, color);
  }

  void _dashRibbon(Canvas canvas) {
    if (game.dashRemaining <= 0) return;
    final step = game.player - game.dashOrigin;
    if (step.distanceSquared < 2) return;
    final p = game.player.translate(0, -13);
    final tail = game.dashOrigin.translate(0, -13);
    final normal = normalizedOr(Offset(-step.dy, step.dx));
    final t = game.dashRemaining / _FutureDebtGame._dashDuration;
    final ribbon = _arenaShape([tail, p + normal * 13, p - normal * 13]);
    canvas.drawPath(
      ribbon,
      _arenaLinear(
        ribbon.getBounds(),
        [const Color(0x00FFE1AA), _futureGold.withValues(alpha: .36 + t * .22)],
        from: Alignment((tail.dx - p.dx).sign, (tail.dy - p.dy).sign),
        to: Alignment((p.dx - tail.dx).sign, (p.dy - tail.dy).sign),
      ),
    );
    for (var i = 1; i < 4; i++) {
      final echo = Offset.lerp(p, tail, i / 4)!;
      final ball = Rect.fromCenter(
        center: echo,
        width: 29 - i * 5.0,
        height: 28 - i * 4.0,
      );
      canvas.drawOval(
        ball,
        Paint()..color = _futureGold.withValues(alpha: .21 - i * .04),
      );
    }
  }

  void _drawGhostTrail(Canvas canvas, Rect visible) {
    const tint = Color(0xFF9DEDF4);
    for (final frame in game.ghostTrail) {
      if (!visible.contains(frame.position)) continue;
      final alpha = ((game.time - frame.time) / .28).clamp(0.0, 1.0);
      final remaining = (1 - alpha) * .48;
      final head = Rect.fromCenter(
        center: frame.position.translate(0, -23),
        width: 32 * (1 - .24 * alpha),
        height: 27 * (1 - .20 * alpha),
      );
      final body = Rect.fromCenter(
        center: frame.position.translate(0, -8),
        width: 21,
        height: 17,
      );
      canvas.drawOval(
        body,
        _arenaClay(body, [
          tint.withValues(alpha: remaining * .83),
          tint.withValues(alpha: 0),
        ]),
      );
      canvas.drawOval(
        head,
        _arenaClay(head, [
          _futureCream.withValues(alpha: remaining),
          tint.withValues(alpha: remaining * .62),
          tint.withValues(alpha: 0),
        ]),
      );
    }
  }

  void _pulse(Canvas canvas, _FuturePowerPulse pulse) {
    final t = (pulse.age / _FuturePowerPulse.life).clamp(0.0, 1.0);
    final radius = pulse.radius * (.25 + .75 * t * (2 - t));
    final strength = (1 - t) * (1 - t);
    final circle = Rect.fromCenter(
      center: pulse.position,
      width: radius * 2,
      height: radius * 1.17,
    );
    final direction = pulse.direction;
    final angle = direction == null
        ? 0.0
        : math.atan2(direction.dy, direction.dx) - .88;
    final length = direction == null ? math.pi * 2 : 1.76;
    _arenaGlow(
      canvas,
      pulse.position.translate(0, -4),
      radius * 1.2,
      pulse.color.withValues(alpha: strength * .28),
    );
    final trace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0 * strength + 1.3
      ..color = pulse.color.withValues(alpha: strength * .50);
    canvas.drawArc(circle, angle, length, false, trace);
    canvas.drawArc(
      circle.deflate(math.min(4.0, radius * .10)),
      angle,
      length,
      false,
      trace
        ..color = _futureCream.withValues(alpha: strength * .78)
        ..strokeWidth = 1.5,
    );
    for (var i = 0; i < 6; i++) {
      final heading = angle + length * (i + .5) / 6;
      final at =
          pulse.position +
          Offset(
            math.cos(heading) * radius,
            math.sin(heading) * radius * .61 - math.sin(t * math.pi) * 9,
          );
      canvas.drawCircle(
        at,
        1.4 + strength,
        Paint()..color = pulse.color.withValues(alpha: strength * .88),
      );
    }
  }

  void _player(Canvas canvas) {
    final p = game.player;
    final dash = game.dashRemaining > 0;
    final ghost = game.moveBoost > 0;
    final reversed = game.reversalBoost > 0;
    final accent = ghost
        ? const Color(0xFFA2EAF3)
        : reversed
        ? _futureLilac
        : _futureGold;
    final aim = cover ? const Offset(.88, -.48) : game.aimDirection;
    final feet = Rect.fromCenter(center: p, width: 45, height: 25);
    if (ghost || reversed || dash) {
      _arenaGlow(
        canvas,
        p.translate(0, -14),
        43,
        accent.withValues(alpha: .38),
      );
    }
    if (reversed) {
      final shield = Rect.fromCenter(
        center: p.translate(0, -18),
        width: 60,
        height: 50,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0
        ..color = _futureLilac.withValues(alpha: .75);
      for (var i = 0; i < 3; i++) {
        final angle = i * math.pi * 2 / 3 + game.time * 3.6;
        canvas.drawArc(shield, angle, .91, false, paint);
        final light =
            shield.center + Offset(math.cos(angle) * 30, math.sin(angle) * 25);
        canvas.drawCircle(light, 2.2, Paint()..color = _futureCream);
      }
    }
    canvas.drawOval(
      feet,
      Paint()
        ..color = accent.withValues(alpha: dash ? .9 : .63)
        ..strokeWidth = dash ? 2.6 : 1.5
        ..style = PaintingStyle.stroke,
    );
    _fighter(
      canvas,
      p,
      aim,
      radius: 18,
      color: ghost ? const Color(0xFFC8F5EF) : const Color(0xFFF2DDBD),
      stride: game.stride,
      moving: game.velocity.distanceSquared > 64,
      dash: dash,
      muzzle: cover ? .8 : _flashAmount(game.lastShotAt),
      hurt: _hitAmount(game.lastHitAt),
    );
  }

  void _enemy(Canvas canvas, _FutureEnemy enemy) {
    final foot = enemy.position;
    final aim = normalizedOr(game.player - foot);
    final size = enemy.radius + 1.5;
    final hurt = _hitAmount(enemy.lastHitAt);
    switch (enemy.type) {
      case _FutureEnemyType.hound:
        _hound(canvas, foot, aim, size, enemy.stride, hurt: hurt);
      case _FutureEnemyType.auditor:
        _auditor(
          canvas,
          foot,
          aim,
          size,
          enemy.stride,
          _flashAmount(enemy.lastShotAt),
          hurt: hurt,
        );
      case _FutureEnemyType.interest:
        final charging =
            enemy.pulseTimer < .56 &&
            (game.player - foot).distanceSquared < 180 * 180;
        _leech(canvas, foot, aim, size, charging: charging, hurt: hurt);
      case _FutureEnemyType.bailiff:
        _bailiff(canvas, foot, aim, size, enemy.stride, hurt: hurt);
    }
    if (enemy.health < enemy.maxHealth) {
      _health(
        canvas,
        foot.translate(
          0,
          -size * (enemy.type == _FutureEnemyType.auditor ? 2.84 : 2.22),
        ),
        enemy.radius * 1.65,
        enemy.health / enemy.maxHealth,
        _futureCoral,
      );
    }
  }

  void _echo(Canvas canvas, _FutureEcho echo) {
    final p = echo.position;
    const color = _futureLilac;
    final phase = game.time * 3;
    _arenaGlow(
      canvas,
      p.translate(0, -14),
      echo.radius * 2.5,
      color.withValues(alpha: .31),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: p,
        width: echo.radius * 2.7,
        height: echo.radius * 1.7,
      ),
      phase,
      4.85,
      false,
      Paint()
        ..color = color.withValues(alpha: .73)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    final aim = normalizedOr(game.player - p);
    final size = echo.radius * .92;
    switch (echo.type) {
      case _FutureEchoType.anchor:
        _gem(
          canvas,
          p.translate(0, -12 + math.sin(phase) * 3),
          echo.radius * .62,
          color,
        );
        return;
      case _FutureEchoType.runner:
        _hound(canvas, p, aim, size, phase * 1.7, echo: true);
    }
    if (echo.health < echo.maxHealth) {
      _health(
        canvas,
        p.translate(0, -echo.radius * 2.65),
        echo.radius * 1.8,
        echo.health / echo.maxHealth,
        color,
      );
    }
  }

  void _collector(Canvas canvas, _FutureCollector boss) {
    final p = boss.position;
    _arenaGlow(canvas, p, 66, const Color(0x56F857A6));
    _bailiff(
      canvas,
      p,
      normalizedOr(game.player - p),
      25,
      game.time * 12,
      collector: true,
      hurt: _hitAmount(boss.lastHitAt),
      muzzle: _flashAmount(boss.lastShotAt),
    );
    _health(
      canvas,
      p.translate(0, -68),
      71,
      boss.health / boss.maxHealth,
      _futureCoral,
    );
    paintGameText(
      canvas,
      'COLLECTOR',
      p.translate(0, -84),
      10,
      _futureCream,
      align: TextAlign.center,
      bold: true,
      fontFamily: 'sans-serif',
    );
  }

  double _flashAmount(double event) =>
      (1 - (game.time - event) / .105).clamp(0.0, 1.0);
  double _hitAmount(double event) =>
      (1 - (game.time - event) / .19).clamp(0.0, 1.0);

  void _fighter(
    Canvas canvas,
    Offset feet,
    Offset aim, {
    required double radius,
    required Color color,
    bool moving = false,
    bool dash = false,
    double stride = 0,
    double muzzle = 0,
    double hurt = 0,
  }) {
    final d = radius;
    final step = moving ? math.sin(stride) : 0.0;
    final rise = moving
        ? math.sin(stride * 2) * d * .092
        : math.sin(game.time * 3 + feet.dx * .023) * 1.0;
    final tilt = dash ? aim.dx * .23 : step * .057;
    final dark = Color.lerp(color, _futureInk, .72)!;
    final light = Color.lerp(color, _futureCream, .65)!;
    final bodyColor = Color.lerp(color, _futureCream, hurt * .51)!;

    canvas.save();
    canvas.translate(feet.dx, feet.dy);
    canvas.rotate(tilt);
    canvas.scale(dash ? 1.12 : 1.0 + step.abs() * .028, dash ? .87 : 1.0);
    for (final side in [-1, 1]) {
      final foot = Rect.fromCenter(
        center: Offset(side * d * .37, -d * .15 + step * side * d * .23),
        width: d * .52,
        height: d * .60,
      );
      _arenaRound(canvas, foot, d * .18, _arenaClay(foot, [color, dark]));
    }
    final body = Rect.fromCenter(
      center: Offset(0, -d * .54 - rise),
      width: d * 1.43,
      height: d * 1.18,
    );
    canvas.drawOval(body, _arenaClay(body, [light, bodyColor, dark]));
    for (final side in [-1, 1]) {
      final arm = Rect.fromCenter(
        center: Offset(
          side * d * .66 + aim.dx * d * .14,
          -d * .56 - rise + side * step * d * .10,
        ),
        width: d * .44,
        height: d * .68,
      );
      canvas.drawOval(arm, _arenaClay(arm, [light, bodyColor, dark]));
    }
    final collar = Rect.fromCenter(
      center: Offset(0, -d * .82 - rise),
      width: d * 1.26,
      height: d * .30,
    );
    _arenaRound(
      canvas,
      collar,
      d * .11,
      _arenaLinear(collar, const [Color(0xFFFFAE7C), Color(0xFF994654)]),
    );
    _blaster(canvas, aim, d, muzzle, true);

    final head = Rect.fromCenter(
      center: Offset(aim.dx * d * .10, -d * 1.34 - rise + aim.dy * 1.5),
      width: d * 1.92,
      height: d * 1.75,
    );
    canvas.drawOval(
      head,
      _arenaClay(head, [
        light,
        bodyColor,
        Color.lerp(bodyColor, _futureInk, .48)!,
        dark,
      ]),
    );
    final face = head.center.translate(
      aim.dx * d * .32,
      d * .11 + aim.dy * d * .19,
    );
    final blink = (game.time % 4.8) > 4.65;
    for (final side in [-1, 1]) {
      final eye = face.translate(side * d * .24, 0);
      canvas.save();
      canvas.translate(eye.dx, eye.dy);
      canvas.rotate(.06 * aim.dx);
      final eyeRect = Rect.fromCenter(
        center: Offset.zero,
        width: d * .17,
        height: d * (blink ? .09 : .41),
      );
      _arenaRound(canvas, eyeRect, d * .14, Paint()..color = _futureInk);
      canvas.restore();
    }
    canvas.restore();
  }

  void _blaster(
    Canvas canvas,
    Offset aim,
    double radius,
    double flash,
    bool hero,
  ) {
    final angle = math.atan2(aim.dy, aim.dx);
    final recoil = flash * flash * 5;
    canvas.save();
    canvas.translate(
      aim.dx * radius * .68,
      -radius * .70 + aim.dy * radius * .60,
    );
    canvas.rotate(angle);
    final stock = Rect.fromLTWH(-recoil - 1, -4, radius * .76, 8);
    _arenaRound(
      canvas,
      stock,
      2.3,
      _arenaLinear(stock, const [
        Color(0xFF9C8A84),
        Color(0xFF40313A),
        Color(0xFF211A23),
      ]),
    );
    final barrel = Rect.fromLTWH(stock.right - 2, -2.5, radius * .43, 5);
    _arenaRound(
      canvas,
      barrel,
      1.5,
      _arenaLinear(barrel, const [Color(0xFFE5B991), Color(0xFF5B4951)]),
    );
    if (flash > 0) {
      final p = barrel.centerRight;
      final color = hero ? _futureGold : _futureCoral;
      final size = 5 + flash * 10;
      _arenaGlow(canvas, p, size * 1.8, color.withValues(alpha: flash * .77));
      canvas.drawPath(
        _arenaShape([
          p.translate(-4, 0),
          p.translate(size * .44, -size * .32),
          p.translate(size * .61, -size * .62),
          p.translate(size * .83, -size * .23),
          p.translate(size * 1.42, 0),
          p.translate(size * .66, size * .22),
          p.translate(size * .53, size * .61),
          p.translate(size * .36, size * .24),
        ]),
        Paint()..color = _futureCream.withValues(alpha: flash),
      );
    }
    canvas.restore();
  }

  void _shot(
    Canvas canvas,
    Offset position,
    Offset velocity,
    Color color,
    double radius,
  ) {
    final direction = normalizedOr(velocity);
    final head = position.translate(0, -10);
    final tail = head - direction * (radius * 5.8 + 6);
    final paint = Paint()
      ..strokeWidth = radius * 2.35
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(tail, head, [
        color.withValues(alpha: 0),
        color,
      ]);
    _arenaGlow(canvas, head, radius * 5, color.withValues(alpha: .62));
    canvas.drawLine(tail, head, paint);
    canvas.drawLine(
      head - direction * (radius * 2.8),
      head,
      Paint()
        ..color = _futureCream
        ..strokeWidth = radius * 1.12
        ..strokeCap = StrokeCap.round,
    );
  }

  void _particle(Canvas canvas, _FutureParticle particle) {
    final fade = (1 - particle.age / particle.life).clamp(0.0, 1.0);
    final color = switch (particle.type) {
      _FutureParticleType.trail => const Color(0xFFDEC19A),
      _FutureParticleType.wall => const Color(0xFFF3B08A),
      _FutureParticleType.spark => _futureCream,
      _FutureParticleType.borrow || _FutureParticleType.kill => _futureMint,
      _FutureParticleType.debt || _FutureParticleType.hit => _futureCoral,
      _FutureParticleType.portal || _FutureParticleType.repay => _futureLilac,
      _ => _futureGold,
    };
    final p = particle.position.translate(0, -4.0 * fade);
    final size = particle.size * (.38 + fade * .62);
    if (particle.type == _FutureParticleType.spark) {
      final direction = normalizedOr(particle.velocity);
      canvas.drawLine(
        p - direction * (size * 3.4),
        p,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = size * .6
          ..color = color.withValues(alpha: fade),
      );
      return;
    }
    if (particle.type == _FutureParticleType.wall) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(particle.age * 12 + particle.size);
      _arenaRound(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: size * 1.4, height: size),
        1,
        Paint()..color = color.withValues(alpha: fade),
      );
      canvas.restore();
      return;
    }
    canvas.drawCircle(
      p,
      size,
      Paint()..color = color.withValues(alpha: fade * .72),
    );
  }

  void _health(
    Canvas canvas,
    Offset p,
    double width,
    double amount,
    Color color,
  ) {
    final track = Rect.fromCenter(center: p, width: width, height: 4.5);
    _arenaRound(canvas, track, 2.25, Paint()..color = const Color(0xCC251D26));
    final fill = Rect.fromLTWH(
      track.left,
      track.top,
      width * amount.clamp(0.0, 1.0),
      track.height,
    );
    if (!fill.isEmpty) _arenaRound(canvas, fill, 2.25, Paint()..color = color);
  }

  void _minimap(Canvas canvas, Size surface, Rect shown) {
    final width = surface.width < 510 ? 70.0 : 100.0;
    final height = width * .56;
    final sx = width / _FutureDebtGame.worldWidth;
    final sy = height / _FutureDebtGame.worldHeight;
    final map = Rect.fromLTWH(
      surface.width - safeInsets.right - width - 56,
      safeInsets.top + 8,
      width,
      height,
    );
    final frame = RRect.fromRectAndRadius(map, const Radius.circular(8));
    canvas.drawRRect(frame, Paint()..color = _futurePanel);
    canvas.drawRRect(
      frame,
      Paint()
        ..color = const Color(0x77FFCA90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    Offset point(Offset p) => map.topLeft + Offset(p.dx * sx, p.dy * sy);
    for (final zone in game.zones) {
      canvas.drawRect(
        Rect.fromPoints(
          point(zone.bounds.topLeft),
          point(zone.bounds.bottomRight),
        ),
        Paint()..color = const Color(0x595D765A),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        point(shown.topLeft).dx,
        point(shown.topLeft).dy,
        shown.width * sx,
        shown.height * sy,
      ),
      Paint()
        ..color = const Color(0xB5EFDDAE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .85,
    );
    for (final enemy in game.enemies) {
      if (!enemy.dead) {
        canvas.drawCircle(
          point(enemy.position),
          1.3,
          Paint()..color = _futureCoral,
        );
      }
    }
    for (final portal in game.portals) {
      canvas.drawCircle(
        point(portal.position),
        1.8,
        Paint()..color = _futureLilac,
      );
    }
    if (game.levelExit case final exit?) {
      canvas.drawCircle(
        point(exit.position),
        2.4,
        Paint()..color = _futureGold,
      );
    }
    canvas.drawCircle(point(game.player), 2.4, Paint()..color = _futureCream);
  }

  @override
  bool shouldRepaint(covariant _FuturePainter oldDelegate) =>
      !cover || oldDelegate.palette != palette;
}
