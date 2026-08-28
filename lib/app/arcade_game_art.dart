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
    const step = 32.0;
    for (var x = -step; x < size.width + step; x += step) {
      paint.color = const Color(0xFF19404A).withValues(alpha: .23);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = -step; y < size.height + step; y += step) {
      paint.color = const Color(0xFF19404A).withValues(alpha: .21);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF2DEAC6).withValues(alpha: .16);
    canvas.drawRect(
      Rect.fromLTWH(16, 16, size.width - 32, size.height - 32),
      paint,
    );
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
    final platform = Paint()..color = _primary.withValues(alpha: .76 * _alpha);
    final accent = Paint()..color = _secondary.withValues(alpha: .78 * _alpha);
    for (var index = 0; index < 5; index++) {
      final width = size.width * (.14 + (index % 2) * .04);
      final left = size.width * (.08 + index * .17);
      final top = size.height * (.71 - (index % 3) * .14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width, 8),
          const Radius.circular(4),
        ),
        index.isEven ? platform : accent,
      );
    }
    final center = Offset(size.width * .58, size.height * .45);
    final arc = Paint()
      ..color = const Color(0xFFFFD86E).withValues(alpha: .74 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.shortestSide * .19),
      math.pi * 1.1,
      math.pi * 1.35,
      false,
      arc,
    );
    _glowCircle(
      canvas,
      center + Offset(0, -size.shortestSide * .09),
      math.max(7, size.shortestSide * .028),
      _primary,
    );
    final debt = Rect.fromCenter(
      center: center + Offset(size.width * .15, size.height * .11),
      width: 16,
      height: 16,
    );
    canvas.drawRect(debt, accent);
  }

  void _drawFutureDebt(Canvas canvas, Size size) {
    final arena = Rect.fromCenter(
      center: Offset(size.width * .59, size.height * .51),
      width: size.width * .67,
      height: size.height * .72,
    );
    final major = Paint()
      ..color = _primary.withValues(alpha: .37 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(arena, major);
    final spacing = math.max(18.0, arena.height / 8);
    for (double x = arena.left; x <= arena.right; x += spacing) {
      canvas.drawLine(Offset(x, arena.top), Offset(x, arena.bottom), major);
    }
    for (double y = arena.top; y <= arena.bottom; y += spacing) {
      canvas.drawLine(Offset(arena.left, y), Offset(arena.right, y), major);
    }
    final player = Offset(
      arena.center.dx,
      arena.center.dy + arena.height * .11,
    );
    final body = Paint()
      ..color = const Color(0xFFB4F5FF).withValues(alpha: .94 * _alpha);
    canvas.drawCircle(player, math.max(11, size.shortestSide * .05), body);
    canvas.drawCircle(
      player,
      math.max(6, size.shortestSide * .026),
      Paint()..color = const Color(0xFF06121B),
    );
    final direction = Paint()
      ..color = _primary.withValues(alpha: .95 * _alpha)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      player,
      player + Offset(0, -size.shortestSide * .12),
      direction,
    );
    for (final position in [
      Offset(arena.left + arena.width * .18, arena.top + arena.height * .28),
      Offset(arena.right - arena.width * .17, arena.top + arena.height * .24),
      Offset(
        arena.right - arena.width * .19,
        arena.bottom - arena.height * .20,
      ),
    ]) {
      canvas.drawCircle(
        position,
        math.max(8, size.shortestSide * .035),
        Paint()
          ..color = const Color(0xFFFF4F7F).withValues(alpha: .86 * _alpha),
      );
      canvas.drawCircle(
        position,
        math.max(3, size.shortestSide * .013),
        Paint()..color = const Color(0xFF230817),
      );
    }
    final bullet = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: .9 * _alpha);
    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(player + Offset(0, -22.0 - index * 16), 3, bullet);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeGameArtworkPainter oldDelegate) =>
      oldDelegate.gameId != gameId ||
      oldDelegate.colors != colors ||
      oldDelegate.muted != muted;
}
