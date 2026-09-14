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
    // I derive camera shake from time so painting never consumes gameplay RNG
    // and a replay keeps the same combat sequence on every frame rate.
    final shake = Offset(
      math.sin(game.time * 71.3) * game.screenShake * .5,
      math.cos(game.time * 89.7) * game.screenShake * .5,
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
      if (visible.inflate(48).contains(portal.position)) {
        _portal(canvas, portal);
      }
    }
    if (game.levelExit != null &&
        visible.inflate(60).contains(game.levelExit!.position)) {
      _levelExit(canvas, game.levelExit!);
    }
    for (final pickup in game.pickups) {
      if (visible.inflate(30).contains(pickup.position)) {
        _pickup(canvas, pickup);
      }
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
    for (final shot in game.shots) {
      if (visible.inflate(48).contains(shot.position)) {
        _shot(canvas, shot, const Color(0xFFB4F6FF));
      }
    }
    for (final shot in game.enemyShots) {
      if (visible.inflate(48).contains(shot.position)) {
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
    const tileSize = 96.0;
    final startX = (visible.left / tileSize).floor() * tileSize;
    final startY = (visible.top / tileSize).floor() * tileSize;
    // Keep the material detail deterministic as the camera moves, and avoid
    // the per-tile shaders that made the original floor unnecessarily costly.
    final panelPaints = [
      Paint()..color = const Color(0xFF0B1420),
      Paint()..color = const Color(0xFF0D1724),
      Paint()..color = const Color(0xFF101A28),
      Paint()..color = const Color(0xFF0A121D),
    ];
    final topBevel = Paint()
      ..color = const Color(0xFF6E90B2).withValues(alpha: .16);
    final leftBevel = Paint()
      ..color = const Color(0xFF47617E).withValues(alpha: .11);
    final lowerBevel = Paint()
      ..color = const Color(0xFF02050B).withValues(alpha: .72);
    final panelOutline = Paint()
      ..color = const Color(0xFF9DB5D0).withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final scuff = Paint()
      ..color = const Color(0xFF9CB2C9).withValues(alpha: .10)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final hatch = Paint()
      ..color = const Color(0xFF060C15).withValues(alpha: .86);
    final hatchRim = Paint()
      ..color = const Color(0xFF58708B).withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bolt = Paint()..color = const Color(0xFF93ACC5).withValues(alpha: .3);

    for (var x = startX; x < visible.right + tileSize; x += tileSize) {
      final column = (x / tileSize).floor();
      for (var y = startY; y < visible.bottom + tileSize; y += tileSize) {
        final row = (y / tileSize).floor();
        final noise = _floorNoise(column, row);
        final tile = Rect.fromLTWH(x, y, tileSize, tileSize);
        canvas.drawRect(tile, panelPaints[noise & 3]);

        // Raised leading edges and a deep trailing edge make each slab read
        // as a physical, slightly worn panel rather than a flat grid.
        canvas.drawRect(
          Rect.fromLTWH(tile.left, tile.top, tile.width, 2),
          topBevel,
        );
        canvas.drawRect(
          Rect.fromLTWH(tile.left, tile.top, 2, tile.height),
          leftBevel,
        );
        canvas.drawRect(
          Rect.fromLTWH(tile.left, tile.bottom - 3, tile.width, 3),
          lowerBevel,
        );
        canvas.drawRect(
          Rect.fromLTWH(tile.right - 3, tile.top, 3, tile.height),
          lowerBevel,
        );
        canvas.drawRect(tile.deflate(5), panelOutline);

        // Glowing cybernetic data bus conduits along selected panel seams
        if ((column + row) % 3 == 0) {
          final conduitPaint = Paint()
            ..color = const Color(0xFF48F2C1).withValues(alpha: 0.16)
            ..strokeWidth = 1.2;
          canvas.drawLine(Offset(tile.left, tile.center.dy), Offset(tile.right, tile.center.dy), conduitPaint);

          // Traveling data packet pulse
          final packetProgress = ((game.time * 70 + column * 33 + row * 21) % tileSize);
          canvas.drawCircle(
            Offset(tile.left + packetProgress, tile.center.dy),
            1.8,
            Paint()
              ..color = const Color(0xFF58E8FF).withValues(alpha: 0.7)
              ..blendMode = BlendMode.screen,
          );
        }

        if ((noise & 7) == 0) {
          final start = Offset(tile.left + 19, tile.top + 25 + (noise % 36));
          canvas.drawLine(start, start + const Offset(38, -5), scuff);
          canvas.drawLine(
            start + const Offset(8, 5),
            start + const Offset(28, 2),
            scuff,
          );
        }
        if (noise % 13 == 0) {
          final accessPanel = Rect.fromCenter(
            center: tile.center,
            width: 48,
            height: 25,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(accessPanel, const Radius.circular(2)),
            hatch,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              accessPanel.deflate(2),
              const Radius.circular(1),
            ),
            hatchRim,
          );
          for (final corner in [
            accessPanel.topLeft + const Offset(5, 5),
            Offset(accessPanel.right - 5, accessPanel.top + 5),
            Offset(accessPanel.left + 5, accessPanel.bottom - 5),
            accessPanel.bottomRight - const Offset(5, 5),
          ]) {
            canvas.drawCircle(corner, 1.2, bolt);
          }
        }
      }
    }
  }

  int _floorNoise(int column, int row) {
    var value = column * 73856093 ^ row * 19349663;
    value = (value ^ (value >> 13)) * 83492791;
    return (value ^ (value >> 16)) & 0x7fffffff;
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
      samples: 24,
      fill: const Color(0xFF3DC9F6).withValues(alpha: .14),
      rim: const Color(0xFFB4F6FF).withValues(alpha: .3),
    );

    // Floating atmospheric dust motes catching the tactical flashlight beam
    for (var i = 0; i < 12; i++) {
      final dist = 40.0 + (i * 31 + game.time * 26) % 390;
      final spread = math.sin(game.time * 1.6 + i * 1.3) * 0.44;
      final moteAngle = aimAngle + spread;
      final maxRay = game._flashlightRayDistance(source, moteAngle, dist);
      if (maxRay >= dist - 2) {
        final motePos = source + Offset(math.cos(moteAngle), math.sin(moteAngle)) * dist;
        final moteAlpha = ((1.0 - dist / 390) * 0.55).clamp(0.0, 1.0);
        canvas.drawCircle(
          motePos,
          1.3,
          Paint()
            ..color = const Color(0xFFB4F6FF).withValues(alpha: moteAlpha)
            ..blendMode = BlendMode.screen,
        );
      }
    }
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
      _FuturePickupKind.caseFile => const Color(0xFFF2E3B3),
    };
    canvas.save();
    canvas.translate(pickup.position.dx, pickup.position.dy);
    canvas.rotate(pickup.spin);
    if (pickup.kind == _FuturePickupKind.writeoff) {
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
      _text(canvas, r'$', Offset.zero, 8, color, center: true, bold: true);
      canvas.restore();
      return;
    }
    final pulse = 1 + math.sin(game.time * 5 + pickup.position.dx) * .12;
    canvas.drawCircle(
      Offset.zero,
      16 * pulse,
      Paint()..color = color.withValues(alpha: .1),
    );
    final body = switch (pickup.kind) {
      _FuturePickupKind.time =>
        Path()
          ..moveTo(0, -11)
          ..cubicTo(9, -6, 6, -2, 3, 0)
          ..cubicTo(7, 4, 8, 8, 0, 12)
          ..cubicTo(-8, 8, -7, 4, -3, 0)
          ..cubicTo(-6, -3, -9, -7, 0, -11)
          ..close(),
      _FuturePickupKind.writeoff =>
        Path()
          ..moveTo(-10, -3)
          ..cubicTo(-4, -12, 7, -11, 11, -3)
          ..cubicTo(8, 9, -4, 12, -11, 4)
          ..cubicTo(-13, 1, -12, -1, -10, -3)
          ..close(),
      _FuturePickupKind.ghost =>
        Path()
          ..moveTo(0, -12)
          ..cubicTo(10, -8, 10, 5, 3, 11)
          ..cubicTo(1, 13, -2, 13, -4, 10)
          ..cubicTo(-12, 2, -8, -8, 0, -12)
          ..close(),
      _FuturePickupKind.compound =>
        Path()..addOval(
          Rect.fromCenter(center: Offset.zero, width: 18, height: 20),
        ),
      _FuturePickupKind.reverse =>
        Path()
          ..moveTo(-12, 0)
          ..cubicTo(-5, -12, 6, -12, 13, 0)
          ..cubicTo(6, 12, -5, 12, -12, 0)
          ..close(),
      _FuturePickupKind.caseFile =>
        Path()
          ..moveTo(-9, -10)
          ..cubicTo(2, -12, 11, -6, 9, 5)
          ..cubicTo(5, 13, -8, 10, -10, 2)
          ..cubicTo(-12, -3, -11, -7, -9, -10)
          ..close(),
    };
    canvas.drawPath(body, Paint()..color = color.withValues(alpha: .22));
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
    if (pickup.kind == _FuturePickupKind.reverse ||
        pickup.kind == _FuturePickupKind.ghost) {
      canvas.drawCircle(
        Offset.zero,
        4.4,
        Paint()..color = const Color(0xFF08101C),
      );
      canvas.drawCircle(Offset.zero, 1.8, Paint()..color = color);
    } else if (pickup.kind == _FuturePickupKind.caseFile) {
      final fold = Paint()
        ..color = color.withValues(alpha: .72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(
        Path()
          ..moveTo(-5, -4)
          ..quadraticBezierTo(0, -1, 5, -3)
          ..moveTo(-4, 2)
          ..quadraticBezierTo(0, 5, 4, 3),
        fold,
      );
    } else {
      canvas.drawCircle(
        Offset.zero,
        3.1,
        Paint()..color = color.withValues(alpha: .85),
      );
    }
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
    final petal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 7; index++) {
      final angle = exit.phase * .55 + index * math.pi * 2 / 7;
      final start = Offset(
        math.cos(angle) * exit.radius * .44,
        math.sin(angle) * exit.radius * .44,
      );
      final end = Offset(
        math.cos(angle) * exit.radius * 1.16,
        math.sin(angle) * exit.radius * 1.16,
      );
      petal.color = (index.isEven ? gold : cyan).withValues(alpha: .9);
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(
            (start.dx + end.dx) * .5 + math.sin(angle) * 9,
            (start.dy + end.dy) * .5 - math.cos(angle) * 9,
            end.dx,
            end.dy,
          ),
        petal,
      );
    }
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
    canvas.drawCircle(
      Offset.zero,
      exit.radius * .26,
      Paint()..color = const Color(0xFF07111A),
    );
    canvas.drawCircle(
      Offset.zero,
      exit.radius * .12,
      Paint()..color = const Color(0xFFF7FEFF),
    );
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
    final isEnemy = shot.damage == 0; // Enemy and echo shots have damage == 0
    final trailLength = isEnemy ? 34.0 : (shot.charged ? 38.0 : 27.0);
    final flareRadius = shot.radius * (isEnemy ? 2.8 : (shot.charged ? 3.2 : 2.25)) * pulse;

    // Layered trails for retro arcade projectile feel
    canvas.drawLine(
      shot.position - direction * trailLength,
      shot.position + direction * shot.radius,
      Paint()
        ..color = color.withValues(alpha: isEnemy ? .25 : .1)
        ..strokeWidth = shot.radius * (isEnemy ? 3.2 : 2.8)
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );
    canvas.drawLine(
      shot.position - direction * trailLength * .82,
      shot.position + direction * shot.radius * 1.5,
      Paint()
        ..color = color.withValues(alpha: .75)
        ..strokeWidth = shot.radius * (isEnemy ? 1.6 : .95)
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen,
    );

    // Glowing energy halo
    canvas.drawCircle(
      shot.position,
      flareRadius * 1.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: .5),
            color.withValues(alpha: .15),
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

    if (isEnemy) {
      // Menacing enemy plasma orb with rotating spiked energy aura
      final spin = game.time * 12.0;
      final orbPaint = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < 4; i++) {
        final angle = spin + i * math.pi / 2;
        final spike = Offset(math.cos(angle) * (shot.radius + 3.5), math.sin(angle) * (shot.radius + 3.5));
        canvas.drawLine(shot.position, shot.position + spike, orbPaint);
      }
      // Fiery inner core
      canvas.drawCircle(
        shot.position,
        shot.radius * 1.3,
        Paint()..color = color,
      );
      canvas.drawCircle(
        shot.position,
        shot.radius * 0.65,
        Paint()..color = const Color(0xFFFFF7E6),
      );
    } else {
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
      final slipColor = index.isEven ? const Color(0xFFFF4F78) : const Color(0xFFC995FF);
      final slipRect = Rect.fromCenter(center: Offset.zero, width: 11, height: 7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(slipRect, const Radius.circular(2)),
        Paint()..color = const Color(0xFF140B1E),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(slipRect, const Radius.circular(2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = slipColor,
      );
      _text(canvas, r'$', const Offset(0, 0.5), 6, slipColor, center: true, bold: true);
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
    final cyan = ghost ? const Color(0xFF58E8FF) : const Color(0xFF6DE8FF);
    final accent = mutation > .55 ? const Color(0xFFFF5F82) : const Color(0xFF64F6DB);
    final armorDark = const Color(0xFF162338).withValues(alpha: alpha);
    final armorMid = const Color(0xFF263854).withValues(alpha: alpha);
    final armorLight = const Color(0xFF3E5A84).withValues(alpha: alpha);
    final fleshTone = const Color(0xFFD8AB82).withValues(alpha: alpha);
    final bootColor = const Color(0xFF101724).withValues(alpha: alpha);
    final stride = moving ? walk : 0.0;

    // Ground contact shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 3), width: 34, height: 28),
      Paint()..color = const Color(0xFF000000).withValues(alpha: .45 * alpha),
    );

    // --- LEGS & BOOTS (Bird's-eye walking kinematics) ---
    final leftLegOffset = Offset(-6 - stride * 1.8, -11);
    final rightLegOffset = Offset(-6 + stride * 1.8, 11);

    void drawBoot(Offset pos) {
      // Boot heel to toe along travel vector
      final bootRect = Rect.fromCenter(center: pos, width: 14, height: 7.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bootRect, const Radius.circular(3)),
        Paint()..color = bootColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bootRect, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = cyan.withValues(alpha: 0.5 * alpha),
      );
      // Boot tip tread
      canvas.drawLine(
        Offset(pos.dx + 4, pos.dy - 2),
        Offset(pos.dx + 4, pos.dy + 2),
        Paint()
          ..color = cyan.withValues(alpha: 0.8 * alpha)
          ..strokeWidth = 1.5,
      );
    }

    drawBoot(leftLegOffset);
    drawBoot(rightLegOffset);

    // --- TACTICAL BACKPACK / RIG POWERPACK ---
    final packRect = const Rect.fromLTWH(-17, -9, 9, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(packRect, const Radius.circular(3)),
      Paint()..color = armorDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(packRect, const Radius.circular(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = cyan.withValues(alpha: 0.7 * alpha),
    );
    // Power core battery cells on pack
    for (var py in [-5.0, 0.0, 5.0]) {
      canvas.drawCircle(
        Offset(-12.5, py),
        1.5,
        Paint()..color = accent.withValues(alpha: 0.9 * alpha),
      );
    }

    // --- TORSO & SHOULDERS (Ballistic plate carrier from top view) ---
    final torsoPath = Path()
      ..moveTo(-10, -11)
      ..lineTo(3, -11) // Right collar
      ..quadraticBezierTo(7, -8, 7, 0) // Front chest
      ..quadraticBezierTo(7, 8, 3, 11) // Left collar
      ..lineTo(-10, 11)
      ..close();

    canvas.drawPath(torsoPath, Paint()..color = armorMid);
    canvas.drawPath(
      torsoPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = cyan.withValues(alpha: alpha),
    );

    // Shoulder armor pads (Pauldrons)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -15, 11, 7), const Radius.circular(2.5)),
      Paint()..color = armorLight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, 8, 11, 7), const Radius.circular(2.5)),
      Paint()..color = armorLight,
    );

    // Ballistic plate center seam
    canvas.drawLine(
      const Offset(-8, 0),
      const Offset(5, 0),
      Paint()
        ..color = cyan.withValues(alpha: 0.6 * alpha)
        ..strokeWidth = 1.2,
    );

    // --- ROTATING UPPER BODY & WEAPON ASSEMBLY (Aims toward mouse/aim stick) ---
    canvas.save();
    canvas.rotate(aimOffset);

    // 1. Operator Helmet & Tactical Visor
    final headCenter = const Offset(0, 0);
    // Outer helmet
    canvas.drawCircle(
      headCenter,
      7.2,
      Paint()..color = const Color(0xFF0F1725).withValues(alpha: alpha),
    );
    canvas.drawCircle(
      headCenter,
      7.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = cyan.withValues(alpha: 0.85 * alpha),
    );
    // Ballistic ridge atop helmet
    canvas.drawLine(
      const Offset(-4, 0),
      const Offset(4, 0),
      Paint()
        ..color = armorLight
        ..strokeWidth = 2.2,
    );
    // Glowing visor bar on front of helmet
    final visorPath = Path()
      ..moveTo(4, -4.5)
      ..quadraticBezierTo(7.5, 0, 4, 4.5);
    canvas.drawPath(
      visorPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: alpha),
    );

    // 2. Arms gripping the weapon
    final armPaint = Paint()
      ..color = armorDark
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final sleeveHighlight = Paint()
      ..color = cyan.withValues(alpha: 0.7 * alpha)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Left arm reaching to forward handguard (Offset(19, -4))
    canvas.drawLine(const Offset(-2, -9), const Offset(10, -8), armPaint);
    canvas.drawLine(const Offset(10, -8), const Offset(19, -4), armPaint);
    canvas.drawLine(const Offset(-2, -9), const Offset(10, -8), sleeveHighlight);

    // Right arm holding pistol grip / trigger (Offset(13, 3))
    canvas.drawLine(const Offset(-2, 9), const Offset(8, 7), armPaint);
    canvas.drawLine(const Offset(8, 7), const Offset(13, 3), armPaint);
    canvas.drawLine(const Offset(-2, 9), const Offset(8, 7), sleeveHighlight);

    // Hands / Tactical gloves
    canvas.drawCircle(const Offset(19, -4), 2.2, Paint()..color = fleshTone);
    canvas.drawCircle(const Offset(13, 3), 2.2, Paint()..color = fleshTone);

    // 3. Tactical Railgun / Assault Rifle
    // Gun stock & receiver
    final gunBody = Path()
      ..moveTo(8, 1)
      ..lineTo(26, 0)
      ..lineTo(28, -2)
      ..lineTo(35, -2) // Barrel tip
      ..lineTo(35, 1)
      ..lineTo(25, 2)
      ..lineTo(14, 4) // Magazine
      ..lineTo(11, 4)
      ..lineTo(8, 2)
      ..close();

    final gunColor = mutation > 0.8 ? const Color(0xFF662035) : const Color(0xFF1B283A);
    canvas.drawPath(gunBody, Paint()..color = gunColor.withValues(alpha: alpha));
    canvas.drawPath(
      gunBody,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFA5F4FF).withValues(alpha: 0.85 * alpha),
    );

    // Barrel / heat vents
    canvas.drawLine(
      const Offset(22, -1),
      const Offset(34, -1),
      Paint()
        ..color = accent.withValues(alpha: 0.75 * alpha)
        ..strokeWidth = 1.0,
    );

    // Laser Sight Beam
    canvas.drawLine(
      const Offset(35, 0),
      const Offset(110, 0),
      Paint()
        ..color = accent.withValues(alpha: 0.35 * alpha)
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      const Offset(110, 0),
      1.8,
      Paint()..color = accent.withValues(alpha: 0.8 * alpha),
    );

    // 4. Muzzle Flash & Energetic Discharge when firing
    if (firing) {
      // Expanding hot muzzle star
      final flashPaint = Paint()
        ..color = const Color(0xFFFFF0A0).withValues(alpha: 0.95 * alpha);
      canvas.drawCircle(const Offset(37, 0), 4.5, flashPaint);
      canvas.drawCircle(
        const Offset(39, 0),
        7.0,
        Paint()..color = const Color(0xFFFF9540).withValues(alpha: 0.5 * alpha),
      );
      // Kinetic shock cones
      canvas.drawLine(
        const Offset(36, -3),
        const Offset(43, -6),
        Paint()
          ..color = const Color(0xFFFFD36A).withValues(alpha: 0.9 * alpha)
          ..strokeWidth = 1.8,
      );
      canvas.drawLine(
        const Offset(36, 3),
        const Offset(43, 6),
        Paint()
          ..color = const Color(0xFFFFD36A).withValues(alpha: 0.9 * alpha)
          ..strokeWidth = 1.8,
      );
    }

    canvas.restore();
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
    
    // Attack telegraph: If enemy is about to fire or pounce, draw a warning targeting laser
    final isTelegraphing = enemy.shotTimer < 0.45;
    if (isTelegraphing) {
      final warningAlpha = ((0.45 - enemy.shotTimer) / 0.45).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset.zero,
        const Offset(140, 0),
        Paint()
          ..color = const Color(0xFFFF3355).withValues(alpha: warningAlpha * 0.7)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        const Offset(140, 0),
        2.5 + math.sin(game.time * 25) * 1.5,
        Paint()..color = const Color(0xFFFF3355).withValues(alpha: warningAlpha * 0.9),
      );
      // Charging energy gathering rings around the attacker
      canvas.drawCircle(
        const Offset(15, 0),
        (enemy.shotTimer / 0.45) * 16.0 + 2.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFF8598).withValues(alpha: warningAlpha),
      );
    }

    switch (enemy.type) {
      case _FutureEnemyType.hound:
        _drawHound(canvas, pulse);
      case _FutureEnemyType.auditor:
        _drawAuditor(canvas, pulse);
      case _FutureEnemyType.interest:
        _drawInterestLeech(canvas, pulse);
      case _FutureEnemyType.bailiff:
        _drawBailiff(canvas, pulse);
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

  void _drawHound(Canvas canvas, double pulse) {
    const flesh = Color(0xFF8E334A);
    const rim = Color(0xFFFF8AA1);
    final gait = math.sin(game.time * 12.5);
    final spring = gait.abs();
    final jawOpen = math
        .pow(math.max(0.0, math.sin(game.time * 4.7)), 5)
        .toDouble();
    canvas.save();
    canvas.translate(0, -spring * 2.4);
    canvas.scale(1 + spring * .07, 1 - spring * .045);
    final limb = Paint()
      ..color = const Color(0xFFC34B68)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final y = -11 + index * 7.3;
      final side = index.isEven ? 1.0 : -1.0;
      final kick = math.sin(game.time * 12.5 + index * math.pi * .72) * 7;
      final leg = Path()
        ..moveTo(-4, y)
        ..cubicTo(-10, y + kick * .35, -17, y - kick, -25, y + kick * .4)
        ..quadraticBezierTo(-29, y + kick * .55, -32, y + side * 2.2);
      canvas.drawPath(leg, limb);
    }
    final tailWhip = math.sin(game.time * 8.5) * 7;
    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(
        Offset(
          -16 - index * 6.4,
          tailWhip * (index / 4) + math.sin(game.time * 7 + index) * 1.5,
        ),
        (7.2 - index * 1.25).toDouble(),
        Paint()..color = flesh.withValues(alpha: .52 + index * .1),
      );
    }
    final body = Path()
      ..moveTo(-18, 0)
      ..cubicTo(-14, -15, 8, -17, 18, -6)
      ..cubicTo(25, 0, 20, 9 + pulse * 2, 10, 12)
      ..cubicTo(-2, 16, -18, 10, -18, 0)
      ..close();
    canvas.drawPath(body, Paint()..color = flesh);
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = rim,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-7, -11, 15, 22),
      Paint()..color = const Color(0xFF632638),
    );
    final bristle = Paint()
      ..color = const Color(0xFFFFA0B4)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final x = -8 + index * 6.0;
      final shiver = math.sin(game.time * 17 + index) * 1.5;
      canvas.drawLine(Offset(x, -13), Offset(x - 2, -19 - shiver), bristle);
    }
    for (final y in [-5.0, 0.0, 5.0]) {
      _eye(canvas, Offset(14, y), const Color(0xFFFFF0D1), radius: 2.1);
    }
    final upperJaw = Path()
      ..moveTo(18, -5)
      ..quadraticBezierTo(29, -3 - jawOpen * 2, 19, -jawOpen * 1.2);
    final lowerJaw = Path()
      ..moveTo(19, jawOpen * 1.2)
      ..quadraticBezierTo(29, 3 + jawOpen * 2, 18, 5);
    canvas.drawPath(
      upperJaw,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFD2D9),
    );
    canvas.drawPath(
      lowerJaw,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFD2D9),
    );
    if (jawOpen > .12) {
      canvas.drawCircle(
        Offset(25, 0),
        1.4 + jawOpen,
        Paint()..color = const Color(0xFFFFF1C6),
      );
    }
    canvas.restore();
  }

  void _drawAuditor(Canvas canvas, double pulse) {
    const ectoplasm = Color(0xFF8F6AD0);
    final hover = math.sin(game.time * 2.35) * 4;
    final breathe = math.sin(game.time * 3.1) * 1.8;
    final blink = math
        .pow(math.max(0.0, math.sin(game.time * 1.15 - 1.05)), 18)
        .toDouble();
    canvas.save();
    canvas.translate(0, hover);
    final tentacle = Paint()
      ..color = const Color(0xFFD7C1FF).withValues(alpha: .68)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 5; index++) {
      final origin = Offset(-10 + index * 5.0, 6);
      final wave = math.sin(game.time * 5 + index * 1.7) * 8;
      final strand = Path()
        ..moveTo(origin.dx, origin.dy)
        ..cubicTo(
          -15 + index * 6,
          15 + wave,
          -20 + index * 8 + math.sin(game.time * 3.4 + index) * 4,
          20 - wave,
          -12 + index * 7 + math.sin(game.time * 4 + index) * 3,
          27 + math.cos(game.time * 3 + index) * 3,
        );
      canvas.drawPath(strand, tentacle);
    }
    final domeRect = Rect.fromCenter(
      center: const Offset(0, -3),
      width: 31 - breathe * .5,
      height: 25 + pulse * 2 + breathe,
    );
    canvas.drawOval(
      domeRect,
      Paint()..color = ectoplasm.withValues(alpha: .76),
    );
    canvas.drawArc(
      domeRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFFE2D5FF),
    );
    canvas.drawCircle(
      Offset.zero,
      8 + pulse * 1.5,
      Paint()..color = const Color(0xFF43245E),
    );
    canvas.save();
    canvas.translate(3, -1);
    canvas.scale(1, math.max(.08, 1 - blink));
    _eye(canvas, Offset.zero, const Color(0xFFFFE6B0), radius: 2.8);
    canvas.restore();
    final tagFlutter = math.sin(game.time * 9) * 3;
    final tag = Path()
      ..moveTo(-18, -5)
      ..quadraticBezierTo(-24, -10 + tagFlutter, -29, -12)
      ..lineTo(-34, -6 + tagFlutter * .4)
      ..quadraticBezierTo(-29, -1 - tagFlutter, -25, 1)
      ..close();
    canvas.drawPath(
      tag,
      Paint()..color = const Color(0xFFF1DEC0).withValues(alpha: .72),
    );
    canvas.drawLine(
      const Offset(-29, -7),
      Offset(-25, -5 + tagFlutter * .25),
      Paint()
        ..color = const Color(0xFF7E628D).withValues(alpha: .7)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _drawInterestLeech(Canvas canvas, double pulse) {
    const skin = Color(0xFF9B7043);
    const bile = Color(0xFFFFD36A);
    final writhe = math.sin(game.time * 4.2) * .09;
    canvas.save();
    canvas.rotate(writhe);
    for (var index = 0; index < 5; index++) {
      final contraction = (math.sin(game.time * 5.4 - index * 1.05) + 1) / 2;
      final x = -17 + index * 7.6 + math.sin(game.time * 5 - index) * 1.3;
      final y = math.sin(game.time * 4.3 - index * .8) * 2.1;
      final segmentWidth = 12.5 + contraction * 3.3;
      final segmentHeight = 15.5 + (1 - contraction) * 7;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: segmentWidth,
          height: segmentHeight,
        ),
        Paint()..color = skin.withValues(alpha: .62 + index * .07),
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, y),
          width: segmentWidth,
          height: segmentHeight,
        ),
        -.9,
        1.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = bile.withValues(alpha: .58),
      );
    }
    final feeler = Paint()
      ..color = bile.withValues(alpha: .75)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final y in [-6.0, 6.0]) {
      final curl = math.sin(game.time * 8 + y) * 6;
      canvas.drawPath(
        Path()
          ..moveTo(5, y)
          ..quadraticBezierTo(18, y + curl, 25, y * 1.6),
        feeler,
      );
    }
    final sucker = 2.2 + pulse * 3.2;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(17, 0),
        width: 13 + pulse * 3,
        height: 13 + pulse * 3,
      ),
      Paint()..color = const Color(0xFF381D20),
    );
    canvas.drawCircle(
      const Offset(18, 0),
      sucker,
      Paint()..color = bile.withValues(alpha: .9),
    );
    canvas.drawCircle(
      const Offset(18, 0),
      sucker * .45,
      Paint()..color = const Color(0xFF3A1E1B),
    );
    for (var index = 0; index < 3; index++) {
      final drift = (game.time * 18 + index * 11) % 28;
      canvas.drawCircle(
        Offset(10 - drift, -10 - index * 3 + math.sin(game.time * 4 + index)),
        1.3 + index * .35,
        Paint()..color = bile.withValues(alpha: .42 - index * .08),
      );
    }
    canvas.restore();
  }

  void _drawBailiff(Canvas canvas, double pulse) {
    const hide = Color(0xFF6D2E43);
    const rim = Color(0xFFFF7D98);
    final lumber = math.sin(game.time * 2.7);
    final stomp = math
        .pow(math.max(0.0, math.sin(game.time * 2.7)), 8)
        .toDouble();
    canvas.save();
    canvas.translate(0, stomp * 3);
    canvas.rotate(lumber * .055);
    final limb = Paint()
      ..color = const Color(0xFFB44864)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final y = -15 + index * 10.0;
      final bend = math.sin(game.time * 5 + index) * 6;
      canvas.drawPath(
        Path()
          ..moveTo(-8, y)
          ..cubicTo(-22, y + bend, -27, y - bend, -35, y + bend * .3)
          ..quadraticBezierTo(-39, y + bend * .2, -41, y),
        limb,
      );
    }
    canvas.drawCircle(
      const Offset(-10, 0),
      23 + pulse * 2,
      Paint()..color = const Color(0xFFFF587D).withValues(alpha: .16),
    );
    final body = Path()
      ..moveTo(-22, 0)
      ..cubicTo(-19, -25, 5, -29, 23, -14)
      ..cubicTo(34, -4, 30, 17, 14, 22)
      ..cubicTo(-4, 28, -25, 18, -22, 0)
      ..close();
    canvas.drawPath(body, Paint()..color = hide);
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = rim,
    );
    for (final side in [-1.0, 1.0]) {
      final sacPulse = math.sin(game.time * 3.4 + side * 1.7) * 1.8;
      canvas.drawCircle(
        Offset(-5, side * 16),
        10 + sacPulse,
        Paint()..color = const Color(0xFF8F4057),
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-5, side * 16), radius: 7 + sacPulse),
        -.8,
        1.6,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFFF9AAF).withValues(alpha: .48),
      );
    }
    final arm = Path()
      ..moveTo(7, -13)
      ..cubicTo(16, -24, 29, -30 - lumber * 4, 35, -20)
      ..quadraticBezierTo(39, -14, 34, -9);
    canvas.drawPath(
      arm,
      Paint()
        ..color = const Color(0xFFB44864)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    for (var index = 0; index < 3; index++) {
      final clawY = -13 + index * 4.0;
      canvas.drawPath(
        Path()
          ..moveTo(34, -10)
          ..quadraticBezierTo(43, clawY - 4, 46, clawY),
        Paint()
          ..color = const Color(0xFFF5B6C4)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
    final mask = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, -12, 23, 24),
      const Radius.elliptical(12, 14),
    );
    canvas.drawRRect(mask, Paint()..color = const Color(0xFF241621));
    canvas.drawRRect(
      mask,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFF1B1C2),
    );
    for (final y in [-6.0, 0.0, 6.0]) {
      _eye(canvas, Offset(20, y), const Color(0xFFFFE1A4), radius: 2.3);
    }
    if (stomp > .05) {
      canvas.drawArc(
        Rect.fromCenter(
          center: const Offset(-10, 28),
          width: 48 + stomp * 20,
          height: 10 + stomp * 5,
        ),
        0,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = rim.withValues(alpha: stomp * .5),
      );
    }
    canvas.restore();
  }

  void _eye(Canvas canvas, Offset position, Color color, {double radius = 2}) {
    canvas.drawCircle(
      position,
      radius * 1.9,
      Paint()..color = color.withValues(alpha: .18),
    );
    canvas.drawCircle(position, radius, Paint()..color = color);
    canvas.drawCircle(
      position + const Offset(.6, 0),
      radius * .35,
      Paint()..color = const Color(0xFF180D16),
    );
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
          ..moveTo(-16, 0)
          ..cubicTo(-8, -15, 12, -14, 18, -3)
          ..cubicTo(23, 5, 9, 13, -5, 10)
          ..cubicTo(-15, 8, -20, 4, -16, 0)
          ..close();
        canvas.drawPath(
          runner,
          Paint()..color = const Color(0xFF58E8FF).withValues(alpha: .2),
        );
        canvas.drawPath(
          runner,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = const Color(0xFF9CEFFF).withValues(alpha: .8),
        );
        for (final y in [-6.0, 0.0, 6.0]) {
          canvas.drawLine(
            const Offset(-5, 0) + Offset(0, y),
            Offset(-18, y + math.sin(game.time * 8 + y) * 3),
            Paint()
              ..color = const Color(0xFF58E8FF).withValues(alpha: .65)
              ..strokeWidth = 2,
          );
        }
        _eye(canvas, const Offset(13, 0), const Color(0xFFE4FCFF), radius: 2);
      case _FutureEchoType.auditor:
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, -3), width: 29, height: 22),
          Paint()..color = const Color(0xFFFF587D).withValues(alpha: .17),
        );
        for (var index = 0; index < 4; index++) {
          final x = -8 + index * 5.0;
          canvas.drawPath(
            Path()
              ..moveTo(x, 6)
              ..cubicTo(
                x - 10,
                17,
                x + 10,
                20,
                x + math.sin(game.time * 5 + index) * 6,
                27,
              ),
            Paint()
              ..color = const Color(0xFFFF90B4).withValues(alpha: .72)
              ..strokeWidth = 2.2
              ..strokeCap = StrokeCap.round,
          );
        }
        _eye(canvas, const Offset(2, -2), const Color(0xFFFFE2EC), radius: 3);
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
        final knot = Path()
          ..moveTo(-14, 0)
          ..cubicTo(-12, -15, 12, -18, 16, -2)
          ..cubicTo(18, 12, -6, 20, -14, 7)
          ..close();
        canvas.drawPath(
          knot,
          Paint()..color = const Color(0xFFBA83FF).withValues(alpha: .45),
        );
        for (var index = 0; index < 5; index++) {
          final angle = index * math.pi * 2 / 5 + game.time * .7;
          final start = Offset(math.cos(angle) * 9, math.sin(angle) * 9);
          final end = Offset(math.cos(angle) * 25, math.sin(angle) * 25);
          canvas.drawLine(
            start,
            end,
            Paint()
              ..color = const Color(0xFFDABEFF).withValues(alpha: .55)
              ..strokeWidth = 2,
          );
        }
      case _FutureEchoType.claim:
        canvas.rotate(math.sin(game.time * 3) * .18);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 25, height: 18),
          Paint()..color = const Color(0xFFB38337).withValues(alpha: .72),
        );
        for (var index = 0; index < 5; index++) {
          final angle = index * math.pi * 2 / 5 + game.time * .9;
          canvas.drawLine(
            Offset(math.cos(angle) * 7, math.sin(angle) * 7),
            Offset(math.cos(angle) * 21, math.sin(angle) * 21),
            Paint()
              ..color = const Color(0xFFFFD36A).withValues(alpha: .8)
              ..strokeWidth = 2.5
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawCircle(
          Offset.zero,
          5,
          Paint()..color = const Color(0xFF372118),
        );
        _eye(canvas, const Offset(2, 0), const Color(0xFFFFF1BF), radius: 2);
    }
    canvas.restore();
  }

  void _collector(Canvas canvas, _FutureCollector collector) {
    canvas.save();
    canvas.translate(collector.position.dx, collector.position.dy);
    final facing = math.atan2(
      game.player.dy - collector.position.dy,
      game.player.dx - collector.position.dx,
    );
    final breathe = math.sin(game.time * 2.1);
    final contract = (breathe + 1) / 2;
    canvas.rotate(facing + math.sin(game.time * 1.7) * .055);
    final limb = Paint()
      ..color = const Color(0xFFB787E8)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 7; index++) {
      final baseAngle = index * math.pi * 2 / 7;
      final sweep = math.sin(game.time * 2.4 + index * 1.27) * .28;
      final angle = baseAngle + sweep;
      final base = Offset(math.cos(angle) * 13, math.sin(angle) * 13);
      final reach = 39 + math.sin(game.time * 3.1 + index * 1.6) * 6;
      final tipAngle = angle + math.sin(game.time * 2.8 + index) * .18;
      final tip = Offset(
        math.cos(tipAngle) * reach,
        math.sin(tipAngle) * reach,
      );
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..cubicTo(
            math.cos(angle + .5) * 24,
            math.sin(angle + .5) * 24,
            math.cos(tipAngle - .45) * 34,
            math.sin(tipAngle - .45) * 34,
            tip.dx,
            tip.dy,
          ),
        limb,
      );
      canvas.drawCircle(
        tip,
        2.4 + contract * 1.3,
        Paint()..color = const Color(0xFFE5C9FF).withValues(alpha: .7),
      );
    }
    canvas.save();
    canvas.scale(1 + contract * .045, 1 - contract * .025);
    final carcass = Path()
      ..moveTo(-26, 0)
      ..cubicTo(-19, -29, 13, -32, 29, -10)
      ..cubicTo(39, 9, 16, 31, -9, 26)
      ..cubicTo(-29, 22, -36, 8, -26, 0)
      ..close();
    canvas.drawPath(carcass, Paint()..color = const Color(0xFF48265F));
    canvas.drawPath(
      carcass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFFD4B1FF),
    );
    canvas.drawOval(
      const Rect.fromLTWH(4, -16, 25, 32),
      Paint()..color = const Color(0xFF180D22),
    );
    for (var index = 0; index < 4; index++) {
      final y = -9.0 + index * 6;
      final blink = math
          .pow(
            math.max(0.0, math.sin(game.time * 1.35 + index * 1.8 - 1.1)),
            20,
          )
          .toDouble();
      canvas.save();
      canvas.translate(20, y);
      canvas.scale(1, math.max(.08, 1 - blink));
      _eye(canvas, Offset.zero, const Color(0xFFFFE7A8), radius: 2.5);
      canvas.restore();
    }
    for (final y in [-13.0, 13.0]) {
      final gill = Path()
        ..moveTo(-6, y)
        ..quadraticBezierTo(-13 - contract * 3, y * .8, -17, y * .55);
      canvas.drawPath(
        gill,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFE1B7FF).withValues(alpha: .7),
      );
    }
    final mawWidth = 7 + contract * 4;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(29, 0),
        width: mawWidth,
        height: 13 - contract * 3,
      ),
      Paint()..color = const Color(0xFF100815),
    );
    canvas.restore();
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
      Paint()..color = const Color(0xEE060D17),
    );
    canvas.drawRect(
      map.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF2E4566),
    );

    // Rotating radar scanner line
    final radarSweep = (game.time * 2.8) % (math.pi * 2);
    final sweepEnd = map.center + Offset(math.cos(radarSweep) * 55, math.sin(radarSweep) * 35);
    canvas.drawLine(
      map.center,
      sweepEnd,
      Paint()
        ..color = const Color(0xFF58E8FF).withValues(alpha: 0.28)
        ..strokeWidth = 1.2,
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
        2.2,
        Paint()..color = const Color(0xFFC995FF),
      );
    }
    if (game.levelExit != null) {
      canvas.drawCircle(
        Offset(
          origin.dx + game.levelExit!.position.dx * sx,
          origin.dy + game.levelExit!.position.dy * sy,
        ),
        3.0,
        Paint()..color = const Color(0xFFFFD36A),
      );
    }
    canvas.drawCircle(
      Offset(origin.dx + game.player.dx * sx, origin.dy + game.player.dy * sy),
      3.5,
      Paint()..color = const Color(0xFF58E8FF),
    );
    for (final enemy in game.enemies.take(30)) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            origin.dx + enemy.position.dx * sx,
            origin.dy + enemy.position.dy * sy,
          ),
          width: 2.5,
          height: 2.5,
        ),
        Paint()..color = const Color(0xFFFF587D),
      );
    }

    // High-tech corner bracket accents
    final bracketPaint = Paint()
      ..color = const Color(0xFF6DE8FF).withValues(alpha: 0.75)
      ..strokeWidth = 1.4;
    const bLen = 6.0;
    // Top-left
    canvas.drawLine(map.topLeft, map.topLeft + const Offset(bLen, 0), bracketPaint);
    canvas.drawLine(map.topLeft, map.topLeft + const Offset(0, bLen), bracketPaint);
    // Top-right
    canvas.drawLine(map.topRight, map.topRight + const Offset(-bLen, 0), bracketPaint);
    canvas.drawLine(map.topRight, map.topRight + const Offset(0, bLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(map.bottomLeft, map.bottomLeft + const Offset(bLen, 0), bracketPaint);
    canvas.drawLine(map.bottomLeft, map.bottomLeft + const Offset(0, -bLen), bracketPaint);
    // Bottom-right
    canvas.drawLine(map.bottomRight, map.bottomRight + const Offset(-bLen, 0), bracketPaint);
    canvas.drawLine(map.bottomRight, map.bottomRight + const Offset(0, -bLen), bracketPaint);
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
        'SEIZED: ${seized.join(' / ')}',
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
      '${zone?.name ?? 'BETWEEN ACCOUNTS'}  •  ${game.enemies.length} CLAIMANTS',
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
