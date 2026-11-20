part of 'not_yet_game.dart';

class GamePainter extends CustomPainter {
  GamePainter(this.game);

  final RealityGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(RealityGame.worldWidth, RealityGame.worldHeight),
    );
    canvas.drawColor(const Color(0xFF04060B), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    _paintBackground(canvas);
    _paintDebtTethers(canvas);
    _paintDrums(canvas);
    _paintPickups(canvas);
    _paintProjectiles(canvas);
    _paintEnemies(canvas);
    _paintParticles(canvas);
    _paintShockwaves(canvas);
    _paintPlayer(canvas);
    _paintLabels(canvas);
    if (game._introTimer > 0 && game.phase == GamePhase.playing) {
      final opacity = math.min(1, game._introTimer * 1.5).toDouble();
      _text(
        canvas,
        game.level.title.toUpperCase(),
        const Offset(480, 44),
        20,
        const Color(0xFFFFFFFF),
        align: TextAlign.center,
        opacity: opacity,
        bold: true,
        letterSpacing: 2,
      );
      _text(
        canvas,
        game.level.flavour,
        const Offset(480, 64),
        11,
        const Color(0xFFC7D7F5),
        align: TextAlign.center,
        opacity: opacity,
      );
    }
    canvas.restore();
  }

  void _paintBackground(Canvas canvas) {
    const arena = Rect.fromLTWH(
      0,
      0,
      RealityGame.worldWidth,
      RealityGame.worldHeight,
    );
    final accent = game.holding
        ? const Color(0xFFFF527C)
        : const Color(0xFF49DCEB);
    canvas.drawRect(
      arena,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -.15),
          radius: .85,
          colors: [
            game.holding ? const Color(0xFF302037) : const Color(0xFF102C3D),
            const Color(0xFF09131F),
            const Color(0xFF03070E),
          ],
          stops: const [0, .55, 1],
        ).createShader(arena),
    );

    // Recessed floor plates give the arena scale without competing with combat.
    final minor = Paint()
      ..color = const Color(0xFF83C8D7).withValues(alpha: .055)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = accent.withValues(alpha: .11)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= RealityGame.worldWidth; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, RealityGame.worldHeight),
        (x % 160 == 0) ? major : minor,
      );
    }
    for (var y = 0.0; y <= RealityGame.worldHeight; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(RealityGame.worldWidth, y),
        (y % 160 == 0) ? major : minor,
      );
    }
    final cross = Paint()
      ..color = accent.withValues(alpha: .19)
      ..strokeWidth = 1;
    for (var x = 80.0; x < RealityGame.worldWidth; x += 160) {
      for (var y = 80.0; y < RealityGame.worldHeight; y += 160) {
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), cross);
        canvas.drawLine(Offset(x, y - 3), Offset(x, y + 3), cross);
      }
    }

    // A segmented perimeter reads as an illuminated containment chamber.
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: .24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(arena.deflate(12), const Radius.circular(12)),
      frame,
    );
    final corner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 3
      ..color = accent.withValues(alpha: .65);
    for (final point in [
      const Offset(12, 12),
      const Offset(948, 12),
      const Offset(12, 528),
      const Offset(948, 528),
    ]) {
      final dx = point.dx < 480 ? 1.0 : -1.0;
      final dy = point.dy < 270 ? 1.0 : -1.0;
      final path = Path()
        ..moveTo(point.dx, point.dy + 24 * dy)
        ..lineTo(point.dx, point.dy + 8 * dy)
        ..quadraticBezierTo(point.dx, point.dy, point.dx + 8 * dx, point.dy)
        ..lineTo(point.dx + 24 * dx, point.dy);
      canvas.drawPath(path, corner);
    }
  }

  void _paintDebtTethers(Canvas canvas) {
    if (!game.holding || game._stack.isEmpty) return;
    final tether = Paint()
      ..color = const Color(0xFFFF6387).withValues(alpha: .38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final consequence in game._stack.reversed.take(14)) {
      canvas.drawLine(game._player.position, consequence.position, tether);
      canvas.drawCircle(
        consequence.position,
        5,
        Paint()
          ..color = _consequenceColor(consequence.type).withValues(alpha: .55),
      );
    }
  }

  void _paintDrums(Canvas canvas) {
    for (final drum in game._drums) {
      final pulse = (math.sin(game.time * 5 + drum.position.dx) * 0.5 + 0.5);
      final warningColor = Color.lerp(
        const Color(0xFFFF9C4E),
        const Color(0xFFFF4868),
        pulse,
      )!;

      // Outer warning radiation aura
      canvas.drawCircle(
        drum.position,
        22 + pulse * 4,
        Paint()..color = warningColor.withValues(alpha: 0.18 + pulse * 0.15),
      );

      // Drum octagonal / rounded metal barrel
      final barrelRect = Rect.fromCenter(
        center: drum.position,
        width: 24,
        height: 32,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barrelRect, const Radius.circular(5)),
        Paint()..color = const Color(0xFF281C14),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barrelRect.deflate(2),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFB56A2B),
      );

      // Hazard diagonal stripes
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          barrelRect.deflate(2),
          const Radius.circular(4),
        ),
      );
      final stripePaint = Paint()
        ..color = const Color(0xFF2B190B)
        ..strokeWidth = 3;
      for (double x = -30; x <= 30; x += 7) {
        canvas.drawLine(
          drum.position + Offset(x, -18),
          drum.position + Offset(x + 12, 18),
          stripePaint,
        );
      }
      canvas.restore();

      // Center hazard indicator plate
      canvas.drawCircle(
        drum.position,
        7,
        Paint()..color = const Color(0xFF1B0F07),
      );
      canvas.drawCircle(drum.position, 6, Paint()..color = warningColor);
      _text(
        canvas,
        '!',
        drum.position + const Offset(0, 3.5),
        10,
        const Color(0xFF1B0F07),
        align: TextAlign.center,
        bold: true,
      );
    }
  }

  void _paintPickups(Canvas canvas) {
    for (final pickup in game._pickups) {
      if (pickup.kind == PickupKind.stasis ||
          pickup.kind == PickupKind.overdrive) {
        final color = _pickupColor(pickup.kind);
        canvas.drawCircle(
          pickup.position,
          16,
          Paint()..color = color.withValues(alpha: .18),
        );
        canvas.drawCircle(pickup.position, 10, Paint()..color = color);
        _text(
          canvas,
          pickup.kind == PickupKind.stasis ? 'II' : '2X',
          pickup.position + const Offset(0, 4),
          8,
          const Color(0xFF07111B),
          align: TextAlign.center,
          bold: true,
        );
        continue;
      }
      final color = pickup.kind == PickupKind.credit
          ? const Color(0xFFFFD166)
          : const Color(0xFF75EDB9);
      final paint = Paint()..color = color;
      if (pickup.kind == PickupKind.credit) {
        canvas.drawCircle(pickup.position, 9, paint);
        _text(
          canvas,
          '¢',
          pickup.position + const Offset(0, 4),
          12,
          const Color(0xFF6F5112),
          align: TextAlign.center,
          bold: true,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: pickup.position, width: 19, height: 12),
            const Radius.circular(3),
          ),
          paint,
        );
        final cross = Paint()..color = const Color(0xFF134A3B);
        canvas.drawRect(
          Rect.fromCenter(center: pickup.position, width: 11, height: 3),
          cross,
        );
        canvas.drawRect(
          Rect.fromCenter(center: pickup.position, width: 3, height: 11),
          cross,
        );
      }
    }
  }

  void _paintProjectiles(Canvas canvas) {
    for (final shot in game._projectiles) {
      final color = shot.allied
          ? const Color(0xFFA8F6FF)
          : const Color(0xFFFF6A8E);
      canvas.drawCircle(
        shot.position,
        shot.radius + 3,
        Paint()..color = color.withValues(alpha: .18),
      );
      canvas.drawCircle(shot.position, shot.radius, Paint()..color = color);
    }
  }

  void _paintEnemies(Canvas canvas) {
    for (final enemy in game._enemies) {
      final color = enemy.pending
          ? const Color(0xFF7E4357)
          : _enemyColor(enemy.kind);
      canvas.drawCircle(
        enemy.position,
        enemy.radius + 10,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  color.withValues(alpha: enemy.pending ? .14 : .26),
                  color.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(
                  center: enemy.position,
                  radius: enemy.radius + 10,
                ),
              ),
      );
      canvas.drawCircle(
        enemy.position,
        enemy.radius + 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = color.withValues(alpha: .4),
      );
      final body = Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-.4, -.5),
              colors: [
                Color.lerp(color, Colors.white, .48)!,
                color,
                Color.lerp(color, Colors.black, .55)!,
              ],
              stops: const [0, .5, 1],
            ).createShader(
              Rect.fromCircle(center: enemy.position, radius: enemy.radius),
            );
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF150B12);
      switch (enemy.kind) {
        case EnemyKind.drone:
          // Rotating tri-blade shuriken rotor
          final rotorAngle = game.time * 8 + enemy.position.dx;
          final bladePaint = Paint()
            ..color = color
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round;
          for (var i = 0; i < 3; i++) {
            final a = rotorAngle + (i * 2 * math.pi / 3);
            final tip =
                enemy.position +
                Offset(math.cos(a), math.sin(a)) * (enemy.radius + 3);
            canvas.drawLine(enemy.position, tip, bladePaint);
            canvas.drawCircle(
              tip,
              2.5,
              Paint()..color = const Color(0xFFFF85A1),
            );
          }
          canvas.drawCircle(enemy.position, enemy.radius * 0.75, body);
          canvas.drawCircle(enemy.position, enemy.radius * 0.75, outline);
          canvas.drawCircle(
            enemy.position,
            3.5,
            Paint()..color = const Color(0xFFFFE6EE),
          );
        case EnemyKind.charger:
          // Predatory arrowhead with forward ramming spikes and engine exhaust
          final chargeDir = enemy.velocity.distance > 10
              ? enemy.velocity
              : const Offset(1, 0);
          final angle = math.atan2(chargeDir.dy, chargeDir.dx);
          canvas.save();
          canvas.translate(enemy.position.dx, enemy.position.dy);
          canvas.rotate(angle);

          // Rear exhaust burn
          final exhaustDist = 8 + math.sin(game.time * 24) * 4;
          canvas.drawLine(
            const Offset(-8, 0),
            Offset(-8 - exhaustDist, 0),
            Paint()
              ..color = const Color(0xFFFF9254)
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round,
          );

          final path = Path()
            ..moveTo(enemy.radius + 4, 0)
            ..lineTo(-enemy.radius * 0.6, -enemy.radius * 0.85)
            ..lineTo(-enemy.radius * 0.2, 0)
            ..lineTo(-enemy.radius * 0.6, enemy.radius * 0.85)
            ..close();
          canvas.drawPath(
            path,
            Paint()
              ..shader =
                  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(color, Colors.white, .4)!,
                      color,
                      Color.lerp(color, Colors.black, .5)!,
                    ],
                  ).createShader(
                    Rect.fromCircle(center: Offset.zero, radius: enemy.radius),
                  ),
          );
          canvas.drawPath(path, outline);
          canvas.drawCircle(
            const Offset(3, 0),
            3,
            Paint()..color = const Color(0xFFFFEDF2),
          );
          canvas.restore();
        case EnemyKind.sentinel:
          // Orbital energy shield segments around a glowing cyclops sensor
          final orbAngle = game.time * 3;
          final arcPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = color;
          for (var i = 0; i < 3; i++) {
            final start = orbAngle + i * (2 * math.pi / 3);
            canvas.drawArc(
              Rect.fromCircle(center: enemy.position, radius: enemy.radius + 2),
              start,
              1.2,
              false,
              arcPaint,
            );
          }
          canvas.drawCircle(enemy.position, enemy.radius, body);
          canvas.drawCircle(
            enemy.position,
            enemy.radius - 5,
            Paint()..color = const Color(0xFF381B4B),
          );
          canvas.drawCircle(enemy.position, enemy.radius, outline);
          // Pulsing cyclops sensor eye
          final eyePulse = (math.sin(game.time * 6) * 1.2).clamp(-1.0, 1.0);
          canvas.drawCircle(
            enemy.position,
            4 + eyePulse,
            Paint()..color = const Color(0xFFF2DEFF),
          );
      }
      if (enemy.pending) {
        _text(
          canvas,
          'DEFERRED',
          enemy.position + Offset(0, -enemy.radius - 9),
          7,
          const Color(0xFFFFBED0),
          align: TextAlign.center,
          bold: true,
          letterSpacing: .8,
        );
      } else {
        final health = Paint()..color = const Color(0xFF122033);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              enemy.position.dx - 14,
              enemy.position.dy - enemy.radius - 10,
              28,
              3,
            ),
            const Radius.circular(2),
          ),
          health,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              enemy.position.dx - 14,
              enemy.position.dy - enemy.radius - 10,
              28 * enemy.health / _enemyMaxHealth(enemy.kind),
              3,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFF89F3C0),
        );
      }
    }
  }

  void _paintParticles(Canvas canvas) {
    for (final particle in game._particles) {
      final opacity = 1 - particle.time / particle.life;
      canvas.drawCircle(
        particle.position,
        2.6,
        Paint()
          ..color = particle.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
      );
    }
  }

  void _paintShockwaves(Canvas canvas) {
    for (final wave in game._shockwaves) {
      final progress = (wave.time / wave.life).clamp(0.0, 1.0);
      final radius = wave.maxRadius * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * (1.0 - progress * 0.7)
        ..color = wave.color.withValues(alpha: opacity * 0.75);
      canvas.drawCircle(wave.position, radius, paint);
      if (radius > 12) {
        canvas.drawCircle(
          wave.position,
          radius * 0.85,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = wave.color.withValues(alpha: opacity * 0.35),
        );
      }
    }
  }

  void _paintPlayer(Canvas canvas) {
    final player = game._player;
    final color = game.holding
        ? const Color(0xFFFF819F)
        : game._overdriveTimer > 0
        ? const Color(0xFFFFD166)
        : const Color(0xFF63E8F6);
    canvas.drawCircle(
      player.position,
      40,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: player.invulnerable > 0 ? .18 : .32),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: player.position, radius: 40)),
    );
    canvas.drawCircle(
      player.position,
      25,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: .35),
    );
    canvas.save();
    canvas.translate(player.position.dx, player.position.dy);
    canvas.rotate(math.atan2(player.aim.dy, player.aim.dx));

    // Dual thruster exhaust flames
    if (player.velocity.distance > 15) {
      final speedRatio = (player.velocity.distance / 240).clamp(0.6, 1.5);
      final flicker = math.sin(game.time * 36);
      final flameLen = (14 + flicker * 5) * speedRatio;

      // Port & starboard engine flames
      for (final ey in [-6.0, 6.0]) {
        final outerFlame = Path()
          ..moveTo(-7, ey - 2.5)
          ..lineTo(-7 - flameLen, ey)
          ..lineTo(-7, ey + 2.5)
          ..close();
        canvas.drawPath(
          outerFlame,
          Paint()
            ..color =
                (game.holding
                        ? const Color(0xFFFF4870)
                        : const Color(0xFF4EE8FF))
                    .withValues(alpha: 0.65),
        );
        final innerFlame = Path()
          ..moveTo(-7, ey - 1.2)
          ..lineTo(-7 - flameLen * 0.65, ey)
          ..lineTo(-7, ey + 1.2)
          ..close();
        canvas.drawPath(
          innerFlame,
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        );
      }
    }

    // Main fighter fuselage and delta wings
    final hullPath = Path()
      ..moveTo(22, 0)
      ..lineTo(3, -7)
      ..lineTo(-8, -16)
      ..lineTo(-5, -6)
      ..lineTo(-9, -4)
      ..lineTo(-7, 0)
      ..lineTo(-9, 4)
      ..lineTo(-5, 6)
      ..lineTo(-8, 16)
      ..lineTo(3, 7)
      ..close();

    final shipColor = player.invulnerable > 0 && (game.time * 14).floor().isEven
        ? const Color(0xFFEAFDFF)
        : color;

    canvas.drawPath(
      hullPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFE7FFFF), shipColor, const Color(0xFF145068)],
          stops: const [0, .46, 1],
        ).createShader(const Rect.fromLTWH(-9, -16, 31, 32)),
    );
    canvas.drawPath(
      hullPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF091420),
    );

    // Insets split the wings into armor panels and keep the nose readable.
    final panel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF092534).withValues(alpha: .65);
    canvas.drawLine(const Offset(-5, -11), const Offset(8, -3), panel);
    canvas.drawLine(const Offset(-5, 11), const Offset(8, 3), panel);
    canvas.drawLine(const Offset(-2, -5), const Offset(12, 0), panel);
    canvas.drawLine(const Offset(-2, 5), const Offset(12, 0), panel);

    // Wingtip plasma cannon emitters
    final emitterPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(const Offset(-7, -15), 1.8, emitterPaint);
    canvas.drawCircle(const Offset(-7, 15), 1.8, emitterPaint);

    // Center armor ridge
    canvas.drawLine(
      const Offset(-4, 0),
      const Offset(14, 0),
      Paint()
        ..color = const Color(0xFF091420).withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );

    // Glowing cockpit canopy with glass reflection
    final canopyRect = Rect.fromCenter(
      center: const Offset(4, 0),
      width: 9,
      height: 5.5,
    );
    canvas.drawOval(canopyRect, Paint()..color = const Color(0xFF07121E));
    canvas.drawOval(
      canopyRect.deflate(0.8),
      Paint()
        ..color = (game.holding
            ? const Color(0xFFFFD2DE)
            : const Color(0xFFD4FAFF)),
    );
    // Specular canopy glint
    canvas.drawCircle(
      const Offset(5, -1),
      1.2,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    canvas.restore();
  }

  void _paintLabels(Canvas canvas) {
    for (final label in game._labels) {
      final opacity = (1 - label.time / label.life).clamp(0.0, 1.0);
      final scale = 1.0 + (1.0 - opacity) * 0.25;
      _text(
        canvas,
        label.text,
        label.position,
        11 * scale,
        label.color,
        align: TextAlign.center,
        opacity: opacity,
        bold: true,
        glowColor: label.color,
      );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset position,
    double size,
    Color color, {
    TextAlign align = TextAlign.left,
    double opacity = 1,
    bool bold = false,
    double letterSpacing = 0,
    Color? glowColor,
  }) {
    paintGameText(
      canvas,
      text,
      position,
      size,
      color,
      align: align,
      opacity: opacity,
      bold: bold,
      letterSpacing: letterSpacing,
      glowColor: glowColor,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

Offset _normal(Offset vector) =>
    vector.distance == 0 ? const Offset(1, 0) : vector / vector.distance;

Offset _rotate(Offset vector, double radians) {
  final cosine = math.cos(radians);
  final sine = math.sin(radians);
  return Offset(
    vector.dx * cosine - vector.dy * sine,
    vector.dx * sine + vector.dy * cosine,
  );
}

Color _enemyColor(EnemyKind kind) => switch (kind) {
  EnemyKind.drone => const Color(0xFFED4D6D),
  EnemyKind.charger => const Color(0xFFFF8A55),
  EnemyKind.sentinel => const Color(0xFFAC75F4),
};

Color _pickupColor(PickupKind kind) => switch (kind) {
  PickupKind.credit => const Color(0xFFFFD166),
  PickupKind.repair => const Color(0xFF75EDB9),
  PickupKind.stasis => const Color(0xFF8DDCFF),
  PickupKind.overdrive => const Color(0xFFFFD166),
};

int _enemyMaxHealth(EnemyKind kind) => switch (kind) {
  EnemyKind.drone => 2,
  EnemyKind.charger => 3,
  EnemyKind.sentinel => 5,
};

Color _consequenceColor(ConsequenceType type) => switch (type) {
  ConsequenceType.damage => const Color(0xFFFF6687),
  ConsequenceType.heal => const Color(0xFF83F2C0),
  ConsequenceType.bounty => const Color(0xFFFFD166),
  ConsequenceType.defeat => const Color(0xFFFF7695),
  ConsequenceType.blast => const Color(0xFFFF9E4E),
};
