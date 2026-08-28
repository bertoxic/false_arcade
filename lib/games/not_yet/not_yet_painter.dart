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
    final center = Offset(480 + math.sin(game.time * .22) * 22, 248);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          game.holding ? const Color(0xFF243451) : const Color(0xFF172B41),
          const Color(0xFF07101D),
          const Color(0xFF04060B),
        ],
        stops: const [0, .48, 1],
      ).createShader(Rect.fromCircle(center: center, radius: 650));
    canvas.drawRect(
      const Rect.fromLTWH(
        0,
        0,
        RealityGame.worldWidth,
        RealityGame.worldHeight,
      ),
      paint,
    );
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color =
          (game.holding ? const Color(0xFF885069) : const Color(0xFF29415C))
              .withValues(alpha: .38);
    for (var x = -24.0; x <= RealityGame.worldWidth + 24; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, RealityGame.worldHeight), grid);
    }
    for (var y = -12.0; y <= RealityGame.worldHeight + 12; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(RealityGame.worldWidth, y), grid);
    }
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF40577A).withValues(alpha: .58);
    canvas.drawRect(
      const Rect.fromLTWH(
        1.5,
        1.5,
        RealityGame.worldWidth - 3,
        RealityGame.worldHeight - 3,
      ),
      border,
    );
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
      final body = Paint()..color = const Color(0xFFB57432);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: drum.position, width: 22, height: 29),
          const Radius.circular(3),
        ),
        body,
      );
      final band = Paint()..color = const Color(0xFF553616);
      canvas.drawRect(
        Rect.fromCenter(
          center: drum.position - const Offset(0, 7),
          width: 24,
          height: 4,
        ),
        band,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: drum.position + const Offset(0, 7),
          width: 24,
          height: 4,
        ),
        band,
      );
      _text(
        canvas,
        '!',
        drum.position + const Offset(0, 4),
        12,
        const Color(0xFFFFE1A6),
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
      final glow = Paint()
        ..color = color.withValues(alpha: enemy.pending ? .15 : .27);
      canvas.drawCircle(enemy.position, enemy.radius + 7, glow);
      final body = Paint()..color = color;
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF150B12);
      switch (enemy.kind) {
        case EnemyKind.drone:
          canvas.drawCircle(enemy.position, enemy.radius, body);
          canvas.drawCircle(enemy.position, enemy.radius, outline);
          canvas.drawCircle(
            enemy.position,
            4,
            Paint()..color = const Color(0xFFFFD5DF),
          );
        case EnemyKind.charger:
          final path = Path()
            ..moveTo(enemy.position.dx, enemy.position.dy - enemy.radius)
            ..lineTo(enemy.position.dx + enemy.radius, enemy.position.dy)
            ..lineTo(enemy.position.dx, enemy.position.dy + enemy.radius)
            ..lineTo(enemy.position.dx - enemy.radius, enemy.position.dy)
            ..close();
          canvas.drawPath(path, body);
          canvas.drawPath(path, outline);
          _text(
            canvas,
            '›',
            enemy.position + const Offset(0, 5),
            20,
            const Color(0xFFFFECF1),
            align: TextAlign.center,
            bold: true,
          );
        case EnemyKind.sentinel:
          canvas.drawCircle(enemy.position, enemy.radius, body);
          canvas.drawCircle(
            enemy.position,
            enemy.radius - 6,
            Paint()..color = const Color(0xFF532B6A),
          );
          canvas.drawCircle(enemy.position, enemy.radius, outline);
          canvas.drawCircle(
            enemy.position,
            4,
            Paint()..color = const Color(0xFFEED8FF),
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

  void _paintPlayer(Canvas canvas) {
    final player = game._player;
    final color = game.holding
        ? const Color(0xFFFF819F)
        : game._overdriveTimer > 0
        ? const Color(0xFFFFD166)
        : const Color(0xFF63E8F6);
    final glow = Paint()
      ..color = color.withValues(alpha: player.invulnerable > 0 ? .14 : .28);
    canvas.drawCircle(player.position, 25, glow);
    canvas.save();
    canvas.translate(player.position.dx, player.position.dy);
    canvas.rotate(math.atan2(player.aim.dy, player.aim.dx));
    final ship = Path()
      ..moveTo(18, 0)
      ..lineTo(-9, -11)
      ..lineTo(-4, 0)
      ..lineTo(-9, 11)
      ..close();
    canvas.drawPath(
      ship,
      Paint()
        ..color = player.invulnerable > 0 && (game.time * 12).floor().isEven
            ? const Color(0xFFEAFDFF)
            : color,
    );
    canvas.drawPath(
      ship,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF112033),
    );
    canvas.drawCircle(
      const Offset(4, 0),
      3.5,
      Paint()..color = const Color(0xFFF6FEFF),
    );
    canvas.restore();
  }

  void _paintLabels(Canvas canvas) {
    for (final label in game._labels) {
      final opacity = (1 - label.time / label.life).clamp(0.0, 1.0);
      _text(
        canvas,
        label.text,
        label.position,
        11,
        label.color,
        align: TextAlign.center,
        opacity: opacity,
        bold: true,
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
