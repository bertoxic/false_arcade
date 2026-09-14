import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Compact, game-specific cover illustrations used by the arcade selector.
///
/// These stay in code on purpose: the art can share each game's neon language,
/// scales cleanly on every screen, and does not turn the launcher into a web
/// catalogue of stock images.
class ArcadeGameArtwork extends StatelessWidget {
  const ArcadeGameArtwork({
    super.key,
    required this.gameId,
    required this.colors,
    this.muted = false,
  });

  final String gameId;
  final List<Color> colors;
  final bool muted;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _ArcadeGameArtworkPainter(
        gameId: gameId,
        colors: colors,
        muted: muted,
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class ArcadeGridField extends StatelessWidget {
  const ArcadeGridField({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: const _ArcadeGridFieldPainter(),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ArcadeGridFieldPainter extends CustomPainter {
  const _ArcadeGridFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    const step = 36.0;
    for (var x = 0.0; x <= size.width; x += step) {
      paint.color = const Color(0xFF133644).withValues(alpha: .28);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      paint.color = const Color(0xFF133644).withValues(alpha: .25);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Glowing grid intersection crosses
    final crossPaint = Paint()
      ..color = const Color(0xFF48F2C1).withValues(alpha: .18)
      ..strokeWidth = 1.2;
    for (var x = step; x < size.width; x += step * 2) {
      for (var y = step; y < size.height; y += step * 2) {
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), crossPaint);
        canvas.drawLine(Offset(x, y - 3), Offset(x, y + 3), crossPaint);
      }
    }

    // Outer cybernetic border and corner brackets
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF48F2C1).withValues(alpha: .32);

    const cornerLen = 16.0;
    const margin = 14.0;
    // Top-left
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + cornerLen, margin), cornerPaint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + cornerLen), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerLen, margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerLen, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerLen), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerLen, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcadeGridFieldPainter oldDelegate) => false;
}

class _ArcadeGameArtworkPainter extends CustomPainter {
  const _ArcadeGameArtworkPainter({
    required this.gameId,
    required this.colors,
    required this.muted,
  });

  final String gameId;
  final List<Color> colors;
  final bool muted;

  Color get _primary => colors.first;
  Color get _secondary => colors.length > 1 ? colors[1] : colors.first;
  double get _alpha => muted ? .52 : 1;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _primary.withValues(alpha: muted ? .10 : .20),
          const Color(0xFF071019),
          const Color(0xFF03070D),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, background);
    _drawGrid(canvas, size);
    switch (gameId) {
      case 'not_yet':
        _drawNotYet(canvas, size);
        break;
      case 'edge_load':
        _drawEdgeLoad(canvas, size);
        break;
      case 'false_habit':
        _drawFalseHabit(canvas, size);
        break;
      case 'numberfall':
        _drawNumberfall(canvas, size);
        break;
      case 'fall_due':
        _drawFallDue(canvas, size);
        break;
      case 'future_debt':
        _drawFutureDebt(canvas, size);
        break;
      default:
        _drawFutureDebt(canvas, size);
    }
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF02050A).withValues(alpha: .76),
        ],
        stops: const [.36, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, vignette);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    final gap = math.max(22.0, size.shortestSide / 11);
    for (double x = -gap; x < size.width + gap; x += gap) {
      paint.color = _primary.withValues(alpha: .09 * _alpha);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -gap; y < size.height + gap; y += gap) {
      paint.color = _secondary.withValues(alpha: .075 * _alpha);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _glowCircle(Canvas canvas, Offset center, double radius, Color color) {
    final glow = Paint()
      ..color = color.withValues(alpha: .12 * _alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, radius * 1.8, glow);
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color.withValues(alpha: .8 * _alpha),
    );
  }

  void _drawNotYet(Canvas canvas, Size size) {
    final center = Offset(size.width * .58, size.height * .5);
    final orbitPaint = Paint()
      ..color = _secondary.withValues(alpha: .4 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .56,
        height: size.height * .38,
      ),
      orbitPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .35,
        height: size.height * .67,
      ),
      orbitPaint,
    );
    _glowCircle(
      canvas,
      center,
      math.max(13, size.shortestSide * .055),
      _primary,
    );
    for (var index = 0; index < 7; index++) {
      final angle = index * math.pi * 2 / 7 + .35;
      final position =
          center +
          Offset(
            math.cos(angle) * size.width * .28,
            math.sin(angle) * size.height * .19,
          );
      _glowCircle(
        canvas,
        position,
        math.max(4, size.shortestSide * .018),
        index.isEven ? _secondary : _primary,
      );
    }
    final ship = Path()
      ..moveTo(center.dx - size.width * .18, center.dy + size.height * .23)
      ..lineTo(center.dx - size.width * .10, center.dy + size.height * .16)
      ..lineTo(center.dx - size.width * .12, center.dy + size.height * .28)
      ..close();
    canvas.drawPath(
      ship,
      Paint()..color = Colors.white.withValues(alpha: .68 * _alpha),
    );
  }

  void _drawEdgeLoad(Canvas canvas, Size size) {
    final house = Rect.fromCenter(
      center: Offset(size.width * .6, size.height * .5),
      width: size.width * .64,
      height: size.height * .64,
    );
    final roomPaint = Paint()
      ..color = const Color(0xFF2C394D).withValues(alpha: .62 * _alpha);
    final walls = Paint()
      ..color = _secondary.withValues(alpha: .55 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rooms = [
      Rect.fromLTWH(
        house.left,
        house.top,
        house.width * .42,
        house.height * .42,
      ),
      Rect.fromLTWH(
        house.left + house.width * .56,
        house.top,
        house.width * .44,
        house.height * .42,
      ),
      Rect.fromLTWH(
        house.left,
        house.top + house.height * .57,
        house.width * .42,
        house.height * .43,
      ),
      Rect.fromLTWH(
        house.left + house.width * .56,
        house.top + house.height * .57,
        house.width * .44,
        house.height * .43,
      ),
    ];
    for (final room in rooms) {
      canvas.drawRect(room, roomPaint);
      canvas.drawRect(room, walls);
    }
    final guard = Offset(
      house.left + house.width * .3,
      house.top + house.height * .27,
    );
    final player = Offset(
      house.left + house.width * .72,
      house.top + house.height * .76,
    );
    final cone = Path()
      ..moveTo(guard.dx, guard.dy)
      ..lineTo(house.right, house.top + house.height * .1)
      ..lineTo(house.right, house.top + house.height * .53)
      ..close();
    canvas.drawPath(
      cone,
      Paint()..color = const Color(0xFFFF5D70).withValues(alpha: .12 * _alpha),
    );
    _glowCircle(
      canvas,
      guard,
      math.max(7, size.shortestSide * .03),
      const Color(0xFFFF6672),
    );
    _glowCircle(
      canvas,
      player,
      math.max(6, size.shortestSide * .026),
      _secondary,
    );
    final diamond = Path()
      ..moveTo(house.center.dx, house.center.dy - 11)
      ..lineTo(house.center.dx + 8, house.center.dy)
      ..lineTo(house.center.dx, house.center.dy + 11)
      ..lineTo(house.center.dx - 8, house.center.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()..color = const Color(0xFF7FE3FF).withValues(alpha: .92 * _alpha),
    );
  }

  void _drawFalseHabit(Canvas canvas, Size size) {
    final room = Rect.fromCenter(
      center: Offset(size.width * .58, size.height * .52),
      width: size.width * .62,
      height: size.height * .63,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(room, const Radius.circular(8)),
      Paint()
        ..color = _secondary.withValues(alpha: .35 * _alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final warden = Offset(
      room.left + room.width * .27,
      room.top + room.height * .4,
    );
    final player = Offset(
      room.right - room.width * .24,
      room.bottom - room.height * .25,
    );
    final cone = Path()
      ..moveTo(warden.dx, warden.dy)
      ..lineTo(room.right - 6, room.top + 14)
      ..lineTo(room.right - 6, room.bottom - 14)
      ..close();
    canvas.drawPath(
      cone,
      Paint()..color = _primary.withValues(alpha: .10 * _alpha),
    );
    _glowCircle(
      canvas,
      warden,
      math.max(11, size.shortestSide * .047),
      _primary,
    );
    canvas.drawCircle(
      warden,
      math.max(3, size.shortestSide * .012),
      Paint()..color = const Color(0xFF050A10),
    );
    _glowCircle(
      canvas,
      player,
      math.max(7, size.shortestSide * .03),
      _secondary,
    );
    final gate = Rect.fromCenter(
      center: Offset(room.right, room.center.dy),
      width: 14,
      height: room.height * .34,
    );
    canvas.drawRect(
      gate,
      Paint()..color = const Color(0xFF83F2C0).withValues(alpha: .9 * _alpha),
    );
    canvas.drawRect(
      gate,
      Paint()
        ..color = const Color(0xFF071018)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final echo = Offset(
      room.left + room.width * .48,
      room.bottom - room.height * .2,
    );
    _glowCircle(
      canvas,
      echo,
      math.max(4, size.shortestSide * .017),
      const Color(0xFFC3A2FF),
    );
  }

  void _drawNumberfall(Canvas canvas, Size size) {
    final x = size.width * .55;
    final y = size.height * .17;
    final unit = math.max(12.0, size.shortestSide * .062);
    final segment = Paint()..color = _primary.withValues(alpha: .82 * _alpha);
    for (final digit in [0, 1, 4]) {
      final dx =
          x +
          (digit == 0
              ? -unit * 3.3
              : digit == 1
              ? 0
              : unit * 3.3);
      final segments = switch (digit) {
        0 => [0, 1, 2, 4, 5, 6],
        1 => [2, 5],
        _ => [1, 2, 3, 5],
      };
      for (final side in segments) {
        final r = switch (side) {
          0 => Rect.fromLTWH(dx - unit, y, unit * 2, unit * .28),
          1 => Rect.fromLTWH(dx - unit, y, unit * .28, unit * 1.15),
          2 => Rect.fromLTWH(dx + unit * .72, y, unit * .28, unit * 1.15),
          3 => Rect.fromLTWH(dx - unit, y + unit * 1.06, unit * 2, unit * .28),
          4 => Rect.fromLTWH(
            dx - unit,
            y + unit * 1.86,
            unit * .28,
            unit * 1.15,
          ),
          5 => Rect.fromLTWH(
            dx + unit * .72,
            y + unit * 1.86,
            unit * .28,
            unit * 1.15,
          ),
          _ => Rect.fromLTWH(dx - unit, y + unit * 2.9, unit * 2, unit * .28),
        };
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(unit * .1)),
          segment,
        );
      }
    }
    final platforms = Paint()
      ..color = _secondary.withValues(alpha: .7 * _alpha);
    for (var index = 0; index < 4; index++) {
      final width = size.width * (.13 + index * .018);
      final left = size.width * (.1 + index * .18);
      final top = size.height * (.77 - (index % 2) * .13);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width, 6),
          const Radius.circular(3),
        ),
        platforms,
      );
    }
    _glowCircle(
      canvas,
      Offset(size.width * .52, size.height * .67),
      math.max(6, size.shortestSide * .025),
      const Color(0xFFFFE66D),
    );
  }

  void _drawFallDue(Canvas canvas, Size size) {
    // 1. Distant skyscraper silhouettes
    final cityPaint = Paint()..color = const Color(0xFF0C1728).withValues(alpha: 0.6 * _alpha);
    for (var i = 0; i < 6; i++) {
      final bx = size.width * (0.05 + i * 0.17);
      final bh = size.height * (0.28 + (i * 3 % 4) * 0.08);
      canvas.drawRect(Rect.fromLTWH(bx, size.height * 0.82 - bh, size.width * 0.12, bh), cityPaint);
    }

    // 2. Glowing gravitational field distortion rings
    final center = Offset(size.width * .55, size.height * .48);
    final arcPaint = Paint()
      ..color = const Color(0xFFFFD36A).withValues(alpha: .75 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.shortestSide * .28),
      math.pi * 0.9,
      math.pi * 1.25,
      false,
      arcPaint,
    );
    final cyanArc = Paint()
      ..color = _primary.withValues(alpha: .65 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.shortestSide * .36),
      math.pi * 1.3,
      math.pi * 0.9,
      false,
      cyanArc,
    );

    // 3. Floating high-tech modular platforms
    final platformPaint = Paint()..color = const Color(0xFF19283E).withValues(alpha: 0.9 * _alpha);
    final railPaint = Paint()
      ..color = _primary.withValues(alpha: .95 * _alpha)
      ..strokeWidth = 2.5;
    for (var index = 0; index < 4; index++) {
      final width = size.width * (.18 + (index % 2) * .05);
      final left = size.width * (.08 + index * .23);
      final top = size.height * (.76 - (index % 3) * .13);
      final pRect = Rect.fromLTWH(left, top, width, 10);
      canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(3)), platformPaint);
      canvas.drawLine(pRect.topLeft, pRect.topRight, railPaint);
    }

    // 4. Heavy Gravity Cargo Crate on lower platform
    final cratePos = Offset(size.width * 0.22, size.height * 0.70);
    final crateRect = Rect.fromCenter(center: cratePos, width: 22, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(crateRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF2A1C0E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(crateRect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFFFD36A).withValues(alpha: 0.9 * _alpha),
    );
    canvas.drawCircle(cratePos, 4, Paint()..color = const Color(0xFFFFD36A).withValues(alpha: 0.9 * _alpha));

    // 5. Cyber-Astronaut Hero leaping in mid-air
    final heroPos = Offset(size.width * 0.58, size.height * 0.36);
    // Thruster exhaust plumes
    canvas.drawLine(
      heroPos + const Offset(-4, 12),
      heroPos + const Offset(-6, 24),
      Paint()
        ..color = _primary.withValues(alpha: 0.85 * _alpha)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      heroPos + const Offset(4, 12),
      heroPos + const Offset(2, 24),
      Paint()
        ..color = _primary.withValues(alpha: 0.85 * _alpha)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    // Torso & backpack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: heroPos + const Offset(0, 3), width: 14, height: 16),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E2D44),
    );
    // Helmet
    canvas.drawCircle(heroPos - const Offset(0, 7), 8, Paint()..color = const Color(0xFFE5F3FF));
    // Glowing visor glint
    canvas.drawOval(
      Rect.fromCenter(center: heroPos - const Offset(-2, 7), width: 7, height: 5),
      Paint()..color = _primary.withValues(alpha: _alpha),
    );

    // 6. Quantum Siphon Lightning Tether connecting Hero to Crate
    final tetherPaint = Paint()
      ..color = const Color(0xFFFFD36A).withValues(alpha: 0.85 * _alpha)
      ..strokeWidth = 1.8;
    canvas.drawLine(heroPos + const Offset(0, 8), cratePos, tetherPaint);
    canvas.drawCircle(
      cratePos,
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFD36A).withValues(alpha: 0.65 * _alpha),
    );

    // 7. Floating Holographic Chronal Seal in upper-right
    final sealPos = Offset(size.width * 0.84, size.height * 0.28);
    _glowCircle(canvas, sealPos, math.max(6, size.shortestSide * 0.026), const Color(0xFF52FFB8));
  }

  void _drawFutureDebt(Canvas canvas, Size size) {
    final arena = Rect.fromCenter(
      center: Offset(size.width * .58, size.height * .50),
      width: size.width * .72,
      height: size.height * .74,
    );

    // 1. High-Tech Cyber-Floor Grid with glowing intersection crosses
    final gridPaint = Paint()
      ..color = _primary.withValues(alpha: .20 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(arena, gridPaint);

    final spacing = math.max(18.0, arena.height / 7);
    for (double x = arena.left; x <= arena.right; x += spacing) {
      canvas.drawLine(Offset(x, arena.top), Offset(x, arena.bottom), gridPaint);
    }
    for (double y = arena.top; y <= arena.bottom; y += spacing) {
      canvas.drawLine(Offset(arena.left, y), Offset(arena.right, y), gridPaint);
    }

    // 2. Tactical Flashlight Illumination Cone
    final player = Offset(
      arena.center.dx - size.width * 0.06,
      arena.center.dy + arena.height * .14,
    );
    final aimTarget = Offset(arena.right - size.width * 0.08, arena.top + arena.height * 0.16);
    final aimDiff = aimTarget - player;
    final aimLength = math.sqrt(aimDiff.dx * aimDiff.dx + aimDiff.dy * aimDiff.dy);
    final aimDir = aimLength > 0.001 ? aimDiff / aimLength : const Offset(1, 0);

    final beamPath = Path()
      ..moveTo(player.dx, player.dy)
      ..lineTo(aimTarget.dx - 30, aimTarget.dy - 35)
      ..lineTo(aimTarget.dx + 35, aimTarget.dy + 30)
      ..close();
    canvas.drawPath(
      beamPath,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (player.dx / size.width) * 2 - 1,
            (player.dy / size.height) * 2 - 1,
          ),
          radius: 0.8,
          colors: [
            _primary.withValues(alpha: 0.25 * _alpha),
            Colors.transparent,
          ],
        ).createShader(arena),
    );

    // 3. Directional Targeting Laser Sight Beam
    final laserPaint = Paint()
      ..color = const Color(0xFFFF3355).withValues(alpha: 0.8 * _alpha)
      ..strokeWidth = 1.4;
    canvas.drawLine(player, aimTarget, laserPaint);
    canvas.drawCircle(aimTarget, 3.5, Paint()..color = const Color(0xFFFF3355).withValues(alpha: 0.9 * _alpha));

    // 4. Spec-Ops Operative (Player)
    canvas.drawCircle(player, 11, Paint()..color = const Color(0xFF162338));
    canvas.drawCircle(
      player,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = _primary.withValues(alpha: 0.9 * _alpha),
    );
    // Weapon barrel
    canvas.drawLine(
      player,
      player + aimDir * 18,
      Paint()
        ..color = const Color(0xFFE2F8FF)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.square,
    );
    // Muzzle flash
    canvas.drawCircle(player + aimDir * 19, 4.5, Paint()..color = const Color(0xFFFFF0A0));

    // 5. Orbiting Holographic Debt Contract Slips
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi * 2 / 3 + 0.4;
      final slipPos = player + Offset(math.cos(angle) * 24, math.sin(angle) * 24);
      final slipRect = Rect.fromCenter(center: slipPos, width: 8, height: 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(slipRect, const Radius.circular(1.5)),
        Paint()..color = const Color(0xFFFF4F7F).withValues(alpha: 0.8 * _alpha),
      );
    }

    // 6. Menacing Eldritch Creditor Entities lurking in darkness
    for (final pos in [
      aimTarget,
      Offset(arena.left + arena.width * .16, arena.top + arena.height * .24),
      Offset(arena.right - arena.width * .14, arena.bottom - arena.height * .26),
    ]) {
      // Dark matter aura
      canvas.drawCircle(
        pos,
        14,
        Paint()..color = const Color(0xFFFF3355).withValues(alpha: .22 * _alpha),
      );
      // Entity core
      canvas.drawCircle(
        pos,
        8,
        Paint()..color = const Color(0xFF381022),
      );
      canvas.drawCircle(
        pos,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFF5277).withValues(alpha: 0.9 * _alpha),
      );
      // Glowing evil eye
      canvas.drawCircle(
        pos,
        2.5,
        Paint()..color = const Color(0xFFFFF0A0),
      );
    }

    // 7. Swirling Quantum Extraction Rift
    final portalPos = Offset(arena.left + arena.width * 0.14, arena.bottom - arena.height * 0.18);
    canvas.drawCircle(
      portalPos,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFFC995FF).withValues(alpha: 0.85 * _alpha),
    );
    canvas.drawCircle(
      portalPos,
      6,
      Paint()..color = const Color(0xFFC995FF).withValues(alpha: 0.45 * _alpha),
    );
  }

  @override
  bool shouldRepaint(covariant _ArcadeGameArtworkPainter oldDelegate) =>
      oldDelegate.gameId != gameId ||
      oldDelegate.colors != colors ||
      oldDelegate.muted != muted;
}
