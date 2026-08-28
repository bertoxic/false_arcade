part of 'future_debt_game.dart';

class _FuturePainter extends CustomPainter {
  _FuturePainter(this.game);
  final _FutureDebtGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_FutureDebtGame.width, _FutureDebtGame.height),
    );
    canvas.drawColor(const Color(0xFF04060B), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _FutureDebtGame.width, _FutureDebtGame.height),
      Paint()
        ..shader =
            const RadialGradient(
              center: Alignment(0, -.78),
              radius: 1.3,
              colors: [Color(0xFF18233E), Color(0xFF07101A), Color(0xFF04060B)],
            ).createShader(
              const Rect.fromLTWH(
                0,
                0,
                _FutureDebtGame.width,
                _FutureDebtGame.height,
              ),
            ),
    );
    final shake = Offset(
      (game._random.nextDouble() - .5) * game.screenShake,
      (game._random.nextDouble() - .5) * game.screenShake,
    );
    canvas.save();
    canvas.translate(-game.camera.dx + shake.dx, -game.camera.dy + shake.dy);
    _world(canvas);
    canvas.restore();
    _minimap(canvas);
    _worldHud(canvas);
    canvas.restore();
  }

  void _world(Canvas canvas) {
    final visible = Rect.fromLTWH(
      game.camera.dx - 72,
      game.camera.dy - 72,
      _FutureDebtGame.width + 144,
      _FutureDebtGame.height + 144,
    );
    canvas.drawRect(visible, Paint()..color = const Color(0xFF050912));
    _floorTiles(canvas, visible);
    for (final zone in game.zones) {
      if (!zone.bounds.overlaps(visible)) continue;
      canvas.drawRect(
        zone.bounds,
        Paint()..color = const Color(0xFF0A1020).withValues(alpha: .38),
      );
      final stripes = Paint()
        ..color = const Color(0xFF1D2A44)
        ..strokeWidth = 1;
      for (var x = zone.bounds.left + 24; x < zone.bounds.right; x += 64) {
        canvas.drawLine(
          Offset(x, zone.bounds.top + 20),
          Offset(x, zone.bounds.bottom - 20),
          stripes,
        );
      }
      final scanX =
          zone.bounds.left +
          (game.time * 86 + zone.bounds.top * .17) % zone.bounds.width;
      canvas.drawRect(
        Rect.fromLTWH(scanX, zone.bounds.top + 12, 3, zone.bounds.height - 24),
        Paint()..color = const Color(0xFF58E8FF).withValues(alpha: .16),
      );
      _text(
        canvas,
        zone.mark,
        zone.bounds.center,
        62,
        const Color(0xFF1B2944).withValues(alpha: .25),
        center: true,
        bold: true,
      );
      _text(
        canvas,
        zone.name,
        zone.bounds.center + const Offset(0, 30),
        12,
        const Color(0xFF1B2944).withValues(alpha: .78),
        center: true,
        bold: true,
      );
    }
    for (final wall in game.walls) {
      if (wall.health > 0 && wall.bounds.overlaps(visible)) _wall(canvas, wall);
    }
    for (final portal in game.portals) {
      if (visible.inflate(48).contains(portal.position))
        _portal(canvas, portal);
    }
    if (game.levelExit != null &&
        visible.inflate(60).contains(game.levelExit!.position)) {
      _levelExit(canvas, game.levelExit!);
    }
    for (final pickup in game.pickups) {
      if (visible.inflate(30).contains(pickup.position))
        _pickup(canvas, pickup);
    }
    for (final particle in game.particles) {
      if (!visible.contains(particle.position)) continue;
      final alpha = (1 - particle.age / particle.life).clamp(0.0, 1.0);
      final color = _particleColor(particle.type).withValues(alpha: alpha);
      if (particle.velocity.distance > .1 &&
          (particle.type == _FutureParticleType.trail ||
              particle.type == _FutureParticleType.dash ||
              particle.type == _FutureParticleType.portal ||
              particle.type == _FutureParticleType.spark)) {
        final direction = normalizedOr(particle.velocity);
        canvas.drawLine(
          particle.position - direction * particle.size * 4,
          particle.position + direction * particle.size,
          Paint()
            ..color = color.withValues(alpha: alpha * .7)
            ..strokeWidth = particle.size * .85
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(
        particle.position,
        particle.size,
        Paint()..color = color,
      );
    }
    for (final shot in game.shots) _shot(canvas, shot, const Color(0xFFB4F6FF));
    for (final shot in game.enemyShots) {
      _shot(
        canvas,
        shot,
        shot.type == _FutureShotType.collector
            ? const Color(0xFFC995FF)
            : shot.type == _FutureShotType.echo
            ? const Color(0xFF58E8FF)
            : const Color(0xFFFF708D),
      );
    }
    for (final enemy in game.enemies) {
      if (visible.inflate(48).contains(enemy.position)) _enemy(canvas, enemy);
    }
    for (final echo in game.echoes) {
      if (visible.inflate(80).contains(echo.position)) _echo(canvas, echo);
    }
    if (game.collector != null) _collector(canvas, game.collector!);
    _playerLight(canvas, visible);
    _player(canvas);
  }

  void _floorTiles(Canvas canvas, Rect visible) {
    const tileSize = 48.0;
    final startX = (visible.left / tileSize).floor() * tileSize;
    final startY = (visible.top / tileSize).floor() * tileSize;
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF526583).withValues(alpha: .2);
    for (var x = startX; x < visible.right + tileSize; x += tileSize) {
      for (var y = startY; y < visible.bottom + tileSize; y += tileSize) {
        final column = (x / tileSize).floor();
        final row = (y / tileSize).floor();
        final variation = (column * 13 + row * 7) & 3;
        final tile = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, y + 1, tileSize - 2, tileSize - 2),
          const Radius.circular(3),
        );
        canvas.drawRRect(
          tile.shift(const Offset(1.5, 2)),
          Paint()..color = const Color(0xFF02050C).withValues(alpha: .25),
        );
        canvas.drawRRect(
          tile,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF18243A).withValues(alpha: .94),
                [
                  const Color(0xFF0E1727),
                  const Color(0xFF101B2D),
                  const Color(0xFF132038),
                  const Color(0xFF0C1524),
                ][variation],
              ],
            ).createShader(tile.outerRect),
        );
        canvas.drawRRect(tile, seam);
        canvas.drawLine(
          Offset(x + 7, y + 7),
          Offset(x + tileSize - 8, y + 7),
          Paint()
            ..color = const Color(0xFFB8D6FF).withValues(alpha: .055)
            ..strokeWidth = 1,
        );
      }
    }
  }

  void _playerLight(Canvas canvas, Rect visible) {
    final player = game.player;
    final aimAngle = math.atan2(game.aimDirection.dy, game.aimDirection.dx);
    final pulse = 1 + math.sin(game.time * 4) * .035;
    final direction = Offset(math.cos(aimAngle), math.sin(aimAngle));
    final source = player + direction * 9;

    void drawWallClippedBeam({
      required double halfAngle,
      required double reach,
      required int samples,
      required Color fill,
      required Color rim,
    }) {
      final beam = Path()..moveTo(source.dx, source.dy);
      final curvedEnd = Path();
      for (var index = 0; index <= samples; index++) {
        final progress = index / samples;
        final angle = aimAngle - halfAngle + halfAngle * 2 * progress;
        final distance = game._flashlightRayDistance(
          source,
          angle,
          reach * pulse,
        );
        final end =
            source + Offset(math.cos(angle), math.sin(angle)) * distance;
        beam.lineTo(end.dx, end.dy);
        if (index == 0) {
          curvedEnd.moveTo(end.dx, end.dy);
        } else {
          curvedEnd.lineTo(end.dx, end.dy);
        }
      }
      beam.close();
      canvas.drawPath(
        beam,
        Paint()
          ..color = fill
          ..blendMode = BlendMode.screen,
      );
      canvas.drawPath(
        curvedEnd,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = rim,
      );
    }

    drawWallClippedBeam(
      halfAngle: .56,
      reach: 430,
      samples: 48,
      fill: const Color(0xFF3DC9F6).withValues(alpha: .105),
      rim: const Color(0xFFB4F6FF).withValues(alpha: .3),
    );
    drawWallClippedBeam(
      halfAngle: .29,
      reach: 285,
      samples: 32,
      fill: const Color(0xFF89F4FF).withValues(alpha: .09),
      rim: const Color(0xFFDEFCFF).withValues(alpha: .24),
    );
    final glow = Rect.fromCircle(center: player, radius: 145 * pulse);
    canvas.drawCircle(
      player,
      145 * pulse,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF74E8FF).withValues(alpha: .26),
            const Color(0xFF2E7CBB).withValues(alpha: .08),
            Colors.transparent,
          ],
          stops: const [0, .58, 1],
        ).createShader(glow),
    );
    final fog = Rect.fromCircle(center: player, radius: 480 * pulse);
    canvas.drawRect(
      visible,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0x12000000),
            const Color(0xA6000000),
          ],
          stops: const [0, .48, 1],
        ).createShader(fog),
    );
  }

  void _wall(Canvas canvas, _FutureWall wall) {
    final health = wall.health / wall.maxHealth;
    final fill = !wall.destructible
        ? const Color(0xFF121C2F)
        : wall.secret
        ? const Color(0xFF3D3025)
        : health > .65
        ? const Color(0xFF233A57)
        : health > .32
        ? const Color(0xFF3D3150)
        : const Color(0xFF542B3B);
    final stroke = wall.secret
        ? const Color(0xFFB4924B)
        : wall.destructible
        ? const Color(0xFF83A8D0)
        : const Color(0xFF536784);
    final shape = RRect.fromRectAndRadius(
      wall.bounds,
      const Radius.circular(3),
    );
    canvas.drawRRect(
      shape.shift(const Offset(2, 3)),
      Paint()..color = const Color(0xAA02050C),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stroke.withValues(alpha: .28),
            fill,
            const Color(0xFF070C16).withValues(alpha: .85),
          ],
          stops: const [0, .48, 1],
        ).createShader(wall.bounds),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wall.bounds.deflate(1), const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = wall.secret ? 3 : 2
        ..color = stroke,
    );
    final inset = wall.bounds.deflate(5);
    final seams = Paint()
      ..color = stroke.withValues(alpha: .22)
      ..strokeWidth = 1;
    if (inset.width >= inset.height) {
      for (var x = inset.left + 18; x < inset.right; x += 18) {
        canvas.drawLine(Offset(x, inset.top), Offset(x, inset.bottom), seams);
      }
    } else {
      for (var y = inset.top + 18; y < inset.bottom; y += 18) {
        canvas.drawLine(Offset(inset.left, y), Offset(inset.right, y), seams);
      }
    }
    if (wall.destructible) {
      final bar = Rect.fromLTWH(
        wall.bounds.left + 4,
        wall.bounds.top + 4,
        wall.bounds.width - 8,
        2,
      );
      canvas.drawRect(bar, Paint()..color = const Color(0xFF08111F));
      canvas.drawRect(
        Rect.fromLTWH(bar.left, bar.top, bar.width * health, bar.height),
        Paint()
          ..color = wall.secret
              ? const Color(0xFFFFD36A)
              : const Color(0xFF73D7FF),
      );
    }
    if (wall.destructible && health < .86) {
      final center = wall.bounds.center;
      final crack = Paint()
        ..color =
            (wall.secret ? const Color(0xFFFFD36A) : const Color(0xFFB7C5DE))
                .withValues(alpha: .45)
        ..strokeWidth = 1.4;
      canvas.drawLine(center + const Offset(-14, -10), center, crack);
      canvas.drawLine(center, center + const Offset(-10, 12), crack);
      canvas.drawLine(center, center + const Offset(16, -9), crack);
    }
  }

  void _pickup(Canvas canvas, _FuturePickup pickup) {
    final color = switch (pickup.kind) {
      _FuturePickupKind.time => const Color(0xFF58E8FF),
      _FuturePickupKind.writeoff => const Color(0xFFFFD36A),
      _FuturePickupKind.ghost => const Color(0xFF70F5FF),
      _FuturePickupKind.compound => const Color(0xFFFF70B3),
      _FuturePickupKind.reverse => const Color(0xFFC995FF),
    };
    final mark = switch (pickup.kind) {
      _FuturePickupKind.time => '+',
      _FuturePickupKind.writeoff => r'$',
      _FuturePickupKind.ghost => 'G',
      _FuturePickupKind.compound => 'F',
      _FuturePickupKind.reverse => 'R',
    };
    canvas.save();
    canvas.translate(pickup.position.dx, pickup.position.dy);
    canvas.rotate(pickup.spin);
    final diamond = Path()
      ..moveTo(0, -11)
      ..lineTo(8, 0)
      ..lineTo(0, 11)
      ..lineTo(-8, 0)
      ..close();
    canvas.drawPath(diamond, Paint()..color = color.withValues(alpha: .16));
    canvas.drawPath(
      diamond,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color,
    );
    _text(canvas, mark, Offset.zero, 8, color, center: true, bold: true);
    canvas.restore();
  }

  void _portal(Canvas canvas, _FuturePortal portal) {
    const cyan = Color(0xFF62E9FF);
    const violet = Color(0xFFC995FF);
    final pulse = math.sin(portal.phase * 2.4) * 2;
    final oval = Rect.fromCenter(
      center: Offset.zero,
      width: portal.radius * 1.22,
      height: portal.radius * 1.72 + pulse,
    );
    canvas.save();
    canvas.translate(portal.position.dx, portal.position.dy);
    canvas.drawCircle(
      Offset.zero,
      portal.radius + 12 + pulse,
      Paint()..color = violet.withValues(alpha: .09),
    );
    canvas.drawOval(
      oval,
      Paint()
        ..shader = RadialGradient(
          colors: [cyan.withValues(alpha: .62), violet.withValues(alpha: .16)],
        ).createShader(oval),
    );
    canvas.save();
    canvas.rotate(portal.phase);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = cyan.withValues(alpha: .92);
    canvas.drawArc(oval.inflate(4), -.25, math.pi * .74, false, ring);
    ring.color = violet.withValues(alpha: .9);
    canvas.drawArc(oval.inflate(4), math.pi * .9, math.pi * .74, false, ring);
    canvas.restore();
    canvas.drawOval(
      oval.inflate(4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFE2F8FF).withValues(alpha: .8),
    );
    _text(
      canvas,
      'RIFT',
      const Offset(0, 4),
      7,
      const Color(0xFFF2FBFF),
      center: true,
      bold: true,
    );
    canvas.restore();
  }

  void _levelExit(Canvas canvas, _FutureLevelExit exit) {
    const cyan = Color(0xFF76F1FF);
    const gold = Color(0xFFFFD36A);
    final pulse = 1 + math.sin(exit.phase * 3.4) * .09;
    canvas.save();
    canvas.translate(exit.position.dx, exit.position.dy);
    canvas.drawCircle(
      Offset.zero,
      exit.radius * 1.65 * pulse,
      Paint()..color = gold.withValues(alpha: .12),
    );
    canvas.drawCircle(
      Offset.zero,
      exit.radius * 1.2 * pulse,
      Paint()..color = cyan.withValues(alpha: .14),
    );
    canvas.save();
    canvas.rotate(exit.phase);
    final outer = Rect.fromCircle(
      center: Offset.zero,
      radius: exit.radius * pulse,
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = gold;
    canvas.drawArc(outer, -.18, math.pi * .7, false, ring);
    ring.color = cyan;
    canvas.drawArc(outer, math.pi * .9, math.pi * .7, false, ring);
    canvas.restore();
    canvas.drawCircle(
      Offset.zero,
      exit.radius * .66,
      Paint()
        ..shader =
            RadialGradient(
              colors: [cyan.withValues(alpha: .6), gold.withValues(alpha: .12)],
            ).createShader(
              Rect.fromCircle(center: Offset.zero, radius: exit.radius * .66),
            ),
    );
    final arrow = Path()
      ..moveTo(-10, -10)
      ..lineTo(4, -10)
      ..lineTo(4, -16)
      ..lineTo(16, 0)
      ..lineTo(4, 16)
      ..lineTo(4, 10)
      ..lineTo(-10, 10)
      ..close();
    canvas.drawPath(arrow, Paint()..color = const Color(0xFFF7FEFF));
    _text(
      canvas,
      'NEXT',
      const Offset(0, 48),
      9,
      gold,
      center: true,
      bold: true,
    );
    canvas.restore();
  }

  void _shot(Canvas canvas, _FutureShot shot, Color color) {
    final direction = normalizedOr(shot.velocity);
    final normal = Offset(-direction.dy, direction.dx);
    final pulse = 1 + math.sin(game.time * 24 + shot.position.dx * .04) * .12;
    final trailLength = shot.charged ? 38.0 : 27.0;
    final flareRadius = shot.radius * (shot.charged ? 3.2 : 2.25) * pulse;
    // Layered trails keep the original shot colors, but give each bullet the
    // bright flare and velocity streak of an arcade projectile.
    canvas.drawLine(
      shot.position - direction * trailLength,
      shot.position + direction * shot.radius,
      Paint()
        ..color = color.withValues(alpha: .1)
        ..strokeWidth = shot.radius * 2.8
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
    canvas.drawLine(
      shot.position - direction * trailLength * .82,
      shot.position + direction * shot.radius * 1.5,
      Paint()
        ..color = color.withValues(alpha: .62)
        ..strokeWidth = shot.radius * .95
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
    canvas.drawCircle(
      shot.position,
      flareRadius * 1.55,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                color.withValues(alpha: .44),
                color.withValues(alpha: .1),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: shot.position,
                radius: flareRadius * 1.55,
              ),
            )
        ..blendMode = BlendMode.screen,
    );
    if (shot.charged) {
      canvas.drawCircle(
        shot.position,
        shot.radius * 3.2,
        Paint()..color = const Color(0xFFFF5AA7).withValues(alpha: .16),
      );
      canvas.drawLine(
        shot.position - direction * 28,
        shot.position + direction * 4,
        Paint()
          ..color = const Color(0xFFFF80C0).withValues(alpha: .72)
          ..strokeWidth = shot.radius * 1.25,
      );
    }
    canvas.drawLine(
      shot.position - direction * flareRadius * 1.8,
      shot.position + direction * flareRadius * 2.1,
      Paint()
        ..color = color.withValues(alpha: .82)
        ..strokeWidth = shot.radius * .65
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
    canvas.drawLine(
      shot.position - normal * flareRadius * .72,
      shot.position + normal * flareRadius * .72,
      Paint()
        ..color = color.withValues(alpha: .6)
        ..strokeWidth = shot.radius * .45
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
    canvas.drawCircle(
      shot.position,
      shot.radius * 1.2,
      Paint()
        ..color = color
        ..blendMode = BlendMode.screen,
    );
  }

  void _player(Canvas canvas) {
    final debt = game.debtAmount;
    final mutation = (debt / 24).clamp(0.0, 1.0);
    final moving = game.moveDirection.distance > .1;
    final travelDirection = moving ? game.moveDirection : game.aimDirection;
    final travelAngle = math.atan2(travelDirection.dy, travelDirection.dx);
    final aimAngle = math.atan2(game.aimDirection.dy, game.aimDirection.dx);
    final aimOffset = aimAngle - travelAngle;
    final walk = moving ? math.sin(game.time * 14) * 3.4 : 0.0;
    final bob = moving
        ? math.sin(game.time * 28) * 1.2
        : math.sin(game.time * 3) * .45;
    if (game.moveBoost > 0) {
      for (var index = 1; index <= 3; index++) {
        canvas.save();
        canvas.translate(
          game.player.dx - math.cos(travelAngle) * index * 15,
          game.player.dy - math.sin(travelAngle) * index * 15,
        );
        canvas.rotate(travelAngle);
        _debtor(
          canvas,
          mutation,
          walk - index * 1.5,
          ghost: true,
          moving: true,
          aimOffset: aimOffset,
        );
        canvas.restore();
      }
    }
    canvas.save();
    canvas.translate(game.player.dx, game.player.dy + bob);
    canvas.rotate(travelAngle);
    if (game.moveBoost > 0) {
      canvas.drawCircle(
        Offset.zero,
        29 + math.sin(game.time * 14) * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF58E8FF).withValues(alpha: .62),
      );
    }
    if (game.shootBoost > 0) {
      canvas.save();
      canvas.rotate(aimOffset);
      final pulse = 7 + math.sin(game.time * 22) * 2;
      canvas.drawCircle(
        const Offset(28, 0),
        pulse + 6,
        Paint()..color = const Color(0xFFFF4F9A).withValues(alpha: .18),
      );
      canvas.drawCircle(
        const Offset(28, 0),
        pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFF80C0).withValues(alpha: .85),
      );
      for (var index = 0; index < 3; index++) {
        final orbit = game.time * 9 + index * math.pi * 2 / 3;
        canvas.drawCircle(
          Offset(28 + math.cos(orbit) * 10, math.sin(orbit) * 10),
          2.2,
          Paint()..color = const Color(0xFFFFD1E7),
        );
      }
      canvas.restore();
    }
    _debtor(
      canvas,
      mutation,
      walk,
      moving: moving,
      aimOffset: aimOffset,
      firing: game.shotCooldown > .02,
      alpha: game.invulnerable > 0 ? .58 : 1,
    );
    canvas.restore();
    final slips = math.min(7, (debt / 4).floor());
    for (var index = 0; index < slips; index++) {
      final rotation =
          game.time * (.7 + mutation * .5) +
          index * math.pi * 2 / math.max(1, slips);
      final radius = 31 + index % 2 * 8;
      canvas.save();
      canvas.translate(
        game.player.dx + math.cos(rotation) * radius,
        game.player.dy + math.sin(rotation) * radius,
      );
      canvas.rotate(rotation + .7);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 10, height: 6),
        Paint()
          ..color =
              (index.isEven ? const Color(0xFFFF5F82) : const Color(0xFF8E79FF))
                  .withValues(alpha: .55),
      );
      canvas.restore();
    }
  }

  void _debtor(
    Canvas canvas,
    double mutation,
    double walk, {
    bool ghost = false,
    bool moving = false,
    double aimOffset = 0,
    bool firing = false,
    double alpha = 1,
  }) {
    final cyan = ghost ? const Color(0xFF58E8FF) : const Color(0xFF9FEEFF);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = cyan.withValues(alpha: alpha);
    final fill = (ghost ? const Color(0xFF3FCCE1) : const Color(0xFF17243A))
        .withValues(alpha: ghost ? .14 * alpha : alpha);
    final stride = moving ? walk : 0.0;
    final limb = Paint()
      ..color = cyan.withValues(alpha: alpha)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      const Offset(-2, 2),
      18,
      Paint()..color = const Color(0xFF02050C).withValues(alpha: .25 * alpha),
    );
    // The player faces toward local +X. Keeping the head, pack, and feet on
    // that axis makes the figure read from directly overhead.
    canvas.drawLine(const Offset(-8, -6), Offset(-16 - stride * .35, -7), limb);
    canvas.drawLine(const Offset(-8, 6), Offset(-16 + stride * .35, 7), limb);
    final backpack = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-20, -9, 10, 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(backpack, Paint()..color = fill);
    canvas.drawRRect(backpack, outline);
    final coat = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-13, -12, 27, 24),
      const Radius.circular(10),
    );
    canvas.drawRRect(coat, Paint()..color = fill);
    canvas.drawRRect(coat, outline);
    canvas.drawLine(
      const Offset(-9, -7),
      const Offset(7, 0),
      Paint()
        ..color = cyan.withValues(alpha: .55 * alpha)
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      const Offset(-9, 7),
      const Offset(7, 0),
      Paint()
        ..color = cyan.withValues(alpha: .55 * alpha)
        ..strokeWidth = 1.4,
    );
    // The upper body pivots separately from travel, so strafing keeps the
    // visor and weapon trained on the fire-stick / assisted-aim direction.
    canvas.save();
    canvas.rotate(aimOffset);
    final helmet = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, -10, 17, 20),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      helmet,
      Paint()..color = const Color(0xFF080D17).withValues(alpha: alpha),
    );
    canvas.drawRRect(helmet, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, -6, 5, 12),
        const Radius.circular(2),
      ),
      Paint()
        ..color =
            (mutation > .55 ? const Color(0xFFFF587D) : const Color(0xFF58E8FF))
                .withValues(alpha: alpha),
    );
    canvas.drawLine(const Offset(-3, -8), const Offset(19, -4), limb);
    canvas.drawLine(const Offset(-3, 8), const Offset(19, 4), limb);
    final gun = RRect.fromRectAndRadius(
      const Rect.fromLTWH(17, -6, 14, 12),
      const Radius.circular(3),
    );
    final gunFill = mutation > .8
        ? const Color(0xFF7A263D)
        : const Color(0xFF253B58);
    canvas.drawRRect(gun, Paint()..color = gunFill.withValues(alpha: alpha));
    canvas.drawRRect(gun, outline);
    canvas.drawRect(
      const Rect.fromLTWH(28, -2.5, 5, 5),
      Paint()..color = const Color(0xFFDFFCFF).withValues(alpha: alpha),
    );
    canvas.drawCircle(
      const Offset(33, 0),
      firing ? 5.5 : 3,
      Paint()
        ..color = (firing ? const Color(0xFFFFD36A) : const Color(0xFF58E8FF))
            .withValues(alpha: firing ? .7 * alpha : .9 * alpha),
    );
    canvas.drawLine(
      const Offset(20, -2),
      const Offset(27, -2),
      Paint()
        ..color = const Color(0xFF58E8FF).withValues(alpha: .7 * alpha)
        ..strokeWidth = 1.2,
    );
    canvas.restore();
    final glass = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color =
          (mutation > .45 ? const Color(0xFFFFD36A) : const Color(0xFF58E8FF))
              .withValues(alpha: alpha);
    canvas.drawCircle(const Offset(0, 0), 5, glass);
    canvas.drawLine(const Offset(-3, -3), const Offset(3, 3), glass);
    canvas.drawLine(const Offset(-3, 3), const Offset(3, -3), glass);
  }

  void _enemy(Canvas canvas, _FutureEnemy enemy) {
    canvas.save();
    canvas.translate(enemy.position.dx, enemy.position.dy);
    canvas.rotate(
      math.atan2(
        game.player.dy - enemy.position.dy,
        game.player.dx - enemy.position.dx,
      ),
    );
    final pulse = (math.sin(game.time * 7 + enemy.position.dx * .018) + 1) / 2;
    switch (enemy.type) {
      case _FutureEnemyType.hound:
        canvas.drawCircle(
          const Offset(-14, 0),
          8 + pulse * 5,
          Paint()..color = const Color(0xFFFF587D).withValues(alpha: .14),
        );
        final shape = Path()
          ..moveTo(18, 0)
          ..lineTo(2, -12)
          ..lineTo(-15, -8)
          ..lineTo(-8, 0)
          ..lineTo(-15, 8)
          ..lineTo(2, 12)
          ..close();
        canvas.drawPath(shape, Paint()..color = const Color(0xFFDF4465));
        canvas.drawPath(
          shape,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFFF8AA1),
        );
        canvas.drawRect(
          const Rect.fromLTWH(6, -2, 5, 4),
          Paint()..color = const Color(0xFFFFF0F3),
        );
      case _FutureEnemyType.auditor:
        canvas.save();
        canvas.rotate(game.time * 1.7 + enemy.position.dy * .01);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 34, height: 22),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFBA83FF),
        );
        canvas.drawLine(
          const Offset(-21, 0),
          const Offset(21, 0),
          Paint()
            ..color = const Color(0xFFD9B6FF).withValues(alpha: .72)
            ..strokeWidth = 1.4,
        );
        canvas.restore();
        canvas.drawCircle(
          Offset.zero,
          5,
          Paint()..color = const Color(0xFFBA83FF),
        );
      case _FutureEnemyType.interest:
        final gear = Path();
        for (var index = 0; index < 12; index++) {
          final angle = index * math.pi / 6;
          final point =
              Offset(math.cos(angle), math.sin(angle)) *
              (index.isEven ? 17 : 8);
          if (index == 0) {
            gear.moveTo(point.dx, point.dy);
          } else {
            gear.lineTo(point.dx, point.dy);
          }
        }
        gear.close();
        canvas.save();
        canvas.rotate(-game.time * 2.2 - enemy.position.dx * .01);
        canvas.drawPath(
          gear,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFFFD36A),
        );
        canvas.restore();
        _text(
          canvas,
          '%',
          const Offset(0, 4),
          12,
          const Color(0xFFFFD36A),
          center: true,
          bold: true,
        );
      case _FutureEnemyType.bailiff:
        canvas.drawCircle(
          Offset.zero,
          24 + pulse * 5,
          Paint()..color = const Color(0xFFFF587D).withValues(alpha: .12),
        );
        canvas.drawRect(
          const Rect.fromLTWH(-18, -15, 36, 30),
          Paint()..color = const Color(0xFF772F45),
        );
        canvas.drawRect(
          const Rect.fromLTWH(-18, -15, 36, 30),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFFF6A8C),
        );
        canvas.drawRect(
          const Rect.fromLTWH(3, -6, 26, 12),
          Paint()..color = const Color(0xFF18111A),
        );
    }
    canvas.restore();
    if (enemy.health < enemy.maxHealth) {
      final bar = Rect.fromCenter(
        center: enemy.position + Offset(0, -enemy.radius - 10),
        width: 36,
        height: 4,
      );
      canvas.drawRect(bar, Paint()..color = const Color(0xFF0B101A));
      canvas.drawRect(
        Rect.fromLTWH(
          bar.left,
          bar.top,
          bar.width * (enemy.health / enemy.maxHealth),
          bar.height,
        ),
        Paint()
          ..color = enemy.type == _FutureEnemyType.interest
              ? const Color(0xFFFFD36A)
              : const Color(0xFFFF5F82),
      );
    }
  }

  void _echo(Canvas canvas, _FutureEcho echo) {
    canvas.save();
    canvas.translate(echo.position.dx, echo.position.dy);
    switch (echo.type) {
      case _FutureEchoType.runner:
        canvas.rotate(
          math.atan2(
            game.player.dy - echo.position.dy,
            game.player.dx - echo.position.dx,
          ),
        );
        final runner = Path()
          ..moveTo(17, 0)
          ..lineTo(-8, -10)
          ..lineTo(-3, 0)
          ..lineTo(-8, 10)
          ..close();
        canvas.drawPath(
          runner,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFF58E8FF).withValues(alpha: .72),
        );
      case _FutureEchoType.auditor:
        canvas.drawCircle(
          Offset.zero,
          15,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFFF587D).withValues(alpha: .72),
        );
        canvas.drawLine(
          const Offset(-20, 0),
          const Offset(20, 0),
          Paint()
            ..color = const Color(0xFFFF587D).withValues(alpha: .72)
            ..strokeWidth = 3,
        );
      case _FutureEchoType.anchor:
        canvas.drawCircle(
          Offset.zero,
          echo.radius + math.sin(game.time * 5) * 5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFBA83FF).withValues(alpha: .7),
        );
        canvas.drawCircle(
          Offset.zero,
          echo.radius,
          Paint()..color = const Color(0xFFBA83FF).withValues(alpha: .12),
        );
        canvas.drawRect(
          const Rect.fromLTWH(-6, -16, 12, 32),
          Paint()..color = const Color(0xFFBA83FF).withValues(alpha: .72),
        );
        canvas.drawRect(
          const Rect.fromLTWH(-16, -6, 32, 12),
          Paint()..color = const Color(0xFFBA83FF).withValues(alpha: .72),
        );
      case _FutureEchoType.claim:
        canvas.rotate(game.time * 1.8);
        canvas.drawRect(
          const Rect.fromLTWH(-12, -12, 24, 24),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = const Color(0xFFFFD36A),
        );
        final gold = Paint()
          ..color = const Color(0xFFFFD36A)
          ..strokeWidth = 4;
        canvas.drawLine(const Offset(-18, 0), const Offset(18, 0), gold);
        canvas.drawLine(const Offset(0, -18), const Offset(0, 18), gold);
    }
    canvas.restore();
  }

  void _collector(Canvas canvas, _FutureCollector collector) {
    canvas.save();
    canvas.translate(collector.position.dx, collector.position.dy);
    canvas.rotate(game.time * .55);
    final gear = Path();
    for (var index = 0; index < 12; index++) {
      final angle = index * math.pi / 6;
      final point =
          Offset(math.cos(angle), math.sin(angle)) * (index.isEven ? 31 : 20);
      if (index == 0) {
        gear.moveTo(point.dx, point.dy);
      } else {
        gear.lineTo(point.dx, point.dy);
      }
    }
    gear.close();
    canvas.drawPath(
      gear,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFC995FF),
    );
    canvas.rotate(-game.time * 1.1);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
      Paint()..color = const Color(0xFFC995FF),
    );
    canvas.restore();
    final bar = Rect.fromCenter(
      center: collector.position + const Offset(0, -42),
      width: 64,
      height: 5,
    );
    canvas.drawRect(bar, Paint()..color = const Color(0xFF16101F));
    canvas.drawRect(
      Rect.fromLTWH(
        bar.left,
        bar.top,
        bar.width * (collector.health / collector.maxHealth).clamp(0.0, 1.0),
        bar.height,
      ),
      Paint()..color = const Color(0xFFC995FF),
    );
  }

  void _minimap(Canvas canvas) {
    const mapWidth = 94.0;
    const mapHeight = 58.0;
    // Keep the map beside the shortened ledger and above the message strip.
    // The inset leaves the pause control unobstructed.
    const origin = Offset(_FutureDebtGame.width - mapWidth - 54, 6);
    final map = Rect.fromLTWH(origin.dx, origin.dy, mapWidth, mapHeight);
    canvas.drawRect(
      map,
      Paint()..color = const Color(0xFF07101A).withValues(alpha: .9),
    );
    canvas.drawRect(
      map.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF435270),
    );
    const sx = mapWidth / _FutureDebtGame.worldWidth;
    const sy = mapHeight / _FutureDebtGame.worldHeight;
    for (final zone in game.zones) {
      canvas.drawRect(
        Rect.fromLTWH(
          origin.dx + zone.bounds.left * sx,
          origin.dy + zone.bounds.top * sy,
          zone.bounds.width * sx,
          zone.bounds.height * sy,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF273753),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        origin.dx + game.camera.dx * sx,
        origin.dy + game.camera.dy * sy,
        _FutureDebtGame.width * sx,
        _FutureDebtGame.height * sy,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = const Color(0xFFB4F6FF).withValues(alpha: .8),
    );
    for (final portal in game.portals) {
      canvas.drawCircle(
        Offset(
          origin.dx + portal.position.dx * sx,
          origin.dy + portal.position.dy * sy,
        ),
        1.7,
        Paint()..color = const Color(0xFFC995FF),
      );
    }
    if (game.levelExit != null) {
      canvas.drawCircle(
        Offset(
          origin.dx + game.levelExit!.position.dx * sx,
          origin.dy + game.levelExit!.position.dy * sy,
        ),
        2.5,
        Paint()..color = const Color(0xFFFFD36A),
      );
    }
    canvas.drawCircle(
      Offset(origin.dx + game.player.dx * sx, origin.dy + game.player.dy * sy),
      3,
      Paint()..color = const Color(0xFF58E8FF),
    );
    for (final enemy in game.enemies.take(30)) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            origin.dx + enemy.position.dx * sx,
            origin.dy + enemy.position.dy * sy,
          ),
          width: 2,
          height: 2,
        ),
        Paint()..color = const Color(0xFFFF587D),
      );
    }
  }

  void _worldHud(Canvas canvas) {
    final seized = <String>[
      if (game.isLocked(_DebtKind.move)) 'MOVE',
      if (game.isLocked(_DebtKind.shoot)) 'FIRE',
      if (game.isLocked(_DebtKind.dash)) 'DASH',
    ];
    if (seized.isNotEmpty) {
      _text(
        canvas,
        'SEIZED: ' + seized.join(' / '),
        const Offset(_FutureDebtGame.width / 2, 30),
        17,
        const Color(0xFFFF6C86),
        center: true,
        bold: true,
      );
    }
    if (game.levelExitOpen && !game.levelExitReached) {
      _text(
        canvas,
        'NEXT LEVEL GATE OPEN — ENTER THE GOLD PORTAL',
        const Offset(_FutureDebtGame.width / 2, 50),
        13,
        const Color(0xFFFFD36A),
        center: true,
        bold: true,
      );
    }
    final zone = game.currentZone;
    _text(
      canvas,
      (zone?.name ?? 'BETWEEN ACCOUNTS') +
          '  •  ' +
          game.enemies.length.toString() +
          ' CLAIMANTS',
      const Offset(16, _FutureDebtGame.height - 16),
      12,
      const Color(0xFF93A0BB),
      bold: true,
    );
  }

  Color _particleColor(_FutureParticleType type) => switch (type) {
    _FutureParticleType.borrow => const Color(0xFF58E8FF),
    _FutureParticleType.debt => const Color(0xFFFF4F78),
    _FutureParticleType.dash => const Color(0xFFBA83FF),
    _FutureParticleType.trail => const Color(0xFF6EF0FF),
    _FutureParticleType.portal => const Color(0xFFC995FF),
    _FutureParticleType.hit => const Color(0xFFFF6279),
    _FutureParticleType.kill => const Color(0xFF6EF0B7),
    _FutureParticleType.spark => const Color(0xFFEEF4FF),
    _FutureParticleType.compound => const Color(0xFFFF70B3),
    _FutureParticleType.repay => const Color(0xFFC995FF),
    _FutureParticleType.wall => const Color(0xFF8FA5CC),
    _FutureParticleType.gold => const Color(0xFFFFD36A),
  };

  void _text(
    Canvas canvas,
    String text,
    Offset point,
    double size,
    Color color, {
    bool center = false,
    bool bold = false,
  }) => paintGameText(
    canvas,
    text,
    point,
    size,
    color,
    align: center ? TextAlign.center : TextAlign.left,
    bold: bold,
  );

  @override
  bool shouldRepaint(covariant _FuturePainter oldDelegate) => true;
}
