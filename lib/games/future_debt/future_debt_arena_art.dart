part of 'future_debt_game.dart';

const _futureAssetPath = 'assets/images/future_debt';
const _futureCream = Color(0xFFFFEFCD);
const _futureGold = Color(0xFFFFCD70);
const _futureCoral = Color(0xFFFF766C);
const _futureMint = Color(0xFFBCE9AA);
const _futureLilac = Color(0xFFD8B6FF);
const _futureInk = Color(0xFF29222D);
const _futurePanel = Color(0xE8312732);

enum _ArenaPalette {
  courtyard(
    'Amber Courtyard',
    Color(0xFFAF775B),
    Color(0xFFFFF4E4),
    Color(0xFF5A633C),
    Color(0xFF96934C),
    Color(0xFFF5CB77),
    Color(0xFF69606A),
  ),
  ruins(
    'Saffron Ruins',
    Color(0xFFBC7955),
    Color(0xFFFFE4BD),
    Color(0xFF715040),
    Color(0xFFB68E51),
    Color(0xFFFFC780),
    Color(0xFF826267),
  ),
  grove(
    'Twilight Grove',
    Color(0xFF927585),
    Color(0xFFC3ADDD),
    Color(0xFF354E48),
    Color(0xFF6E9268),
    Color(0xFFD8E2A0),
    Color(0xFF5E5C77),
  );

  const _ArenaPalette(
    this.label,
    this.soil,
    this.tint,
    this.grass,
    this.leaf,
    this.rim,
    this.stone,
  );
  final String label;
  final Color soil;
  final Color tint;
  final Color grass;
  final Color leaf;
  final Color rim;
  final Color stone;
}

class _ArenaBlock {
  const _ArenaBlock(this.wall, this.bounds);
  final _FutureWall wall;
  final Rect bounds;
}

class _ArenaGrove {
  const _ArenaGrove(this.foot, this.width);
  final Offset foot;
  final double width;
}

class _ArenaLayer {
  const _ArenaLayer(this.depth, this.draw);
  final double depth;
  final VoidCallback draw;
}

Paint _arenaLinear(
  Rect rect,
  List<Color> colors, {
  Alignment from = Alignment.topRight,
  Alignment to = Alignment.bottomLeft,
}) => Paint()
  ..shader = LinearGradient(
    begin: from,
    end: to,
    colors: colors,
  ).createShader(rect);

Paint _arenaClay(Rect rect, List<Color> colors) => Paint()
  ..shader = RadialGradient(
    center: const Alignment(.48, -.77),
    radius: 1.02,
    colors: colors,
  ).createShader(rect);

void _arenaRound(Canvas canvas, Rect rect, double radius, Paint paint) => canvas
    .drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);

Path _arenaShape(List<Offset> points) => Path()..addPolygon(points, true);

void _arenaGlow(Canvas canvas, Offset at, double radius, Color color) {
  final bounds = Rect.fromCircle(center: at, radius: radius);
  canvas.drawCircle(
    at,
    radius,
    Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(bounds),
  );
}

extension on _FuturePainter {
  void _floor(Canvas canvas, Rect visible) {
    canvas.drawRect(visible, Paint()..color = palette.soil);
    if (floorArt case final image?) {
      const tile = 640.0;
      final source = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final paint = Paint()
        ..filterQuality = FilterQuality.low
        ..colorFilter = ColorFilter.mode(palette.tint, BlendMode.modulate);
      for (
        var y = (visible.top / tile).floor() * tile;
        y < visible.bottom;
        y += tile
      ) {
        for (
          var x = (visible.left / tile).floor() * tile;
          x < visible.right;
          x += tile
        ) {
          canvas.drawImageRect(
            image,
            source,
            Rect.fromLTWH(x, y, tile, tile),
            paint,
          );
        }
      }
    }

    for (final patch in game.arenaTurf) {
      if (!patch.inflate(30).overlaps(visible)) continue;
      _turf(canvas, patch);
    }
    _scatterStones(canvas, visible);
    final lightField = Rect.fromLTWH(
      0,
      0,
      _FutureDebtGame.worldWidth,
      _FutureDebtGame.worldHeight,
    );
    canvas.drawRect(
      visible,
      _arenaLinear(lightField, const [
        Color(0x12FFE3A2),
        Color(0x02FFCA83),
        Color(0x2F282239),
      ]),
    );
    for (final zone in game.zones) {
      if (!visible.overlaps(zone.bounds.inflate(80))) continue;
      final light = Offset.lerp(zone.bounds.topRight, zone.bounds.center, .55)!;
      _arenaGlow(
        canvas,
        light,
        zone.bounds.width * .47,
        palette.rim.withValues(alpha: .16),
      );
    }
    for (var i = 0; i < 22; i++) {
      final origin = Offset(
        (i * 419.1 + game.time * (6 + i % 5)) % _FutureDebtGame.worldWidth,
        (i * 191.7 - game.time * (2 + i % 3)) % _FutureDebtGame.worldHeight,
      );
      if (!visible.contains(origin)) continue;
      canvas.drawCircle(
        origin,
        i.isEven ? 1.8 : 1.1,
        Paint()
          ..color = palette.rim.withValues(
            alpha: .23 + math.sin(game.time * 2 + i) * .14,
          ),
      );
    }
  }

  void _turf(Canvas canvas, Rect patch) {
    final corner = math.min(patch.shortestSide * .45, 40.0);
    final edge = Path()
      ..moveTo(patch.left + corner, patch.top + 1)
      ..lineTo(patch.center.dx + corner * .4, patch.top + 1)
      ..quadraticBezierTo(
        patch.center.dx + corner * .8,
        patch.top + 1,
        patch.center.dx + corner,
        patch.top + 7,
      )
      ..lineTo(patch.right - corner, patch.top + 7)
      ..quadraticBezierTo(
        patch.right - 1,
        patch.top + 7,
        patch.right - 1,
        patch.top + corner,
      );
    final border = Path.from(edge)
      ..lineTo(patch.right - 1, patch.bottom - corner)
      ..quadraticBezierTo(
        patch.right - 1,
        patch.bottom,
        patch.right - corner,
        patch.bottom,
      )
      ..lineTo(patch.center.dx - corner * .18, patch.bottom)
      ..quadraticBezierTo(
        patch.center.dx - corner * .8,
        patch.bottom,
        patch.center.dx - corner,
        patch.bottom - 8,
      )
      ..lineTo(patch.left + corner, patch.bottom - 8)
      ..quadraticBezierTo(
        patch.left,
        patch.bottom - 8,
        patch.left,
        patch.bottom - corner - 2,
      )
      ..lineTo(patch.left, patch.top + corner)
      ..quadraticBezierTo(
        patch.left,
        patch.top + 1,
        patch.left + corner,
        patch.top + 1,
      )
      ..close();
    canvas.drawPath(
      border.shift(const Offset(-7, 14)),
      Paint()
        ..color = const Color(0x502C2632)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      border.shift(const Offset(0, 5)),
      Paint()..color = Color.lerp(palette.grass, _futureInk, .45)!,
    );
    canvas.drawPath(
      border,
      _arenaLinear(patch, [
        palette.leaf,
        palette.grass,
        Color.lerp(palette.grass, _futureInk, .34)!,
      ]),
    );
    canvas.drawPath(
      edge,
      Paint()
        ..color = palette.rim.withValues(alpha: .58)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    _tuft(canvas, Offset(patch.left + corner, patch.bottom - 24), .9);
    _tuft(canvas, Offset(patch.right - corner * .66, patch.top + 41), 1.0);
    final pebble = Offset(patch.left + corner * .6, patch.top + 32);
    _pebble(canvas, pebble, 12);
    _pebble(canvas, pebble.translate(19, 8), 6);
  }

  void _tuft(Canvas canvas, Offset root, double scale) {
    canvas.drawOval(
      Rect.fromCenter(
        center: root.translate(-5, 3),
        width: 29 * scale,
        height: 11 * scale,
      ),
      Paint()
        ..color = const Color(0x70352C30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.7),
    );
    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.scale(scale);
    for (final angle in [-.93, -.46, .17, .83]) {
      canvas.save();
      canvas.rotate(angle);
      final leaf = Path()
        ..moveTo(0, 1)
        ..cubicTo(-12, -8, -9, -24, -1, -23)
        ..cubicTo(9, -23, 12, -9, 0, 1)
        ..close();
      canvas.drawPath(
        leaf,
        _arenaLinear(leaf.getBounds(), [
          palette.rim,
          palette.leaf,
          palette.grass,
        ]),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  void _scatterStones(Canvas canvas, Rect visible) {
    const spacing = 118;
    final startX = math.max(0, (visible.left / spacing).floor());
    final startY = math.max(0, (visible.top / spacing).floor());
    for (var column = startX; column <= visible.right / spacing; column++) {
      for (var row = startY; row <= visible.bottom / spacing; row++) {
        final hash = (row * 167 + column * 269 + row * column * 39) % 101;
        if (hash > 39) continue;
        final center = Offset(
          column * spacing + 11.0 + hash * 2,
          row * spacing + (hash * 11 % 105) + 6.0,
        );
        _pebble(canvas, center, 4.0 + hash % 8);
        if (hash % 3 == 0) _pebble(canvas, center.translate(-13, 9), 4);
      }
    }
  }

  void _pebble(Canvas canvas, Offset center, double radius) {
    final bounds = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 1.36,
    );
    canvas.drawOval(
      bounds.shift(Offset(-radius * .34, radius * .36)),
      Paint()..color = const Color(0x642B222D),
    );
    final rock = _arenaShape([
      bounds.centerLeft,
      bounds.topLeft + Offset(radius * .42, 1),
      bounds.topRight - Offset(radius * .48, 0),
      bounds.centerRight,
      bounds.bottomRight - Offset(radius * .37, 1),
      bounds.bottomLeft + Offset(radius * .35, 0),
    ]);
    canvas.drawPath(
      rock,
      _arenaClay(bounds, [
        Color.lerp(palette.stone, palette.rim, .68)!,
        Color.lerp(palette.stone, palette.soil, .55)!,
        palette.stone,
      ]),
    );
  }

  void _longShadow(
    Canvas canvas,
    Rect bounds,
    Offset drift, {
    double blur = 5,
  }) {
    final side = _arenaShape([
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomRight + drift,
      bounds.bottomLeft + drift,
      bounds.topLeft + drift,
    ]);
    final cast = bounds.expandToInclude(bounds.shift(drift));
    final paint = _arenaLinear(cast, const [
      Color(0x85302431),
      Color(0x70302431),
      Color(0x06302431),
    ]);
    canvas.drawPath(
      side,
      paint..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void _treeShadow(Canvas canvas, _ArenaGrove grove) {
    final foot = grove.foot;
    final size = grove.width;
    final shadowCenter = foot + Offset(-size * .23, size * .21);
    canvas.save();
    canvas.translate(shadowCenter.dx, shadowCenter.dy);
    canvas.rotate(-.61);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size * 1.07,
      height: size * .51,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xAD2C2330), Color(0x672C2330), Color(0x002C2330)],
        ).createShader(rect),
    );
    canvas.restore();
  }

  void _tree(Canvas canvas, _ArenaGrove grove) {
    final p = grove.foot;
    final size = grove.width;
    if (palette == _ArenaPalette.ruins && p.dx.round().isOdd) {
      _boulder(canvas, p.translate(14, -3), size * .55);
      _boulder(canvas, p.translate(-size * .24, 5), size * .30);
      _tuft(canvas, p.translate(size * .28, 4), 1.25);
      return;
    }
    if (treeArt case final sprite?) {
      final source = Rect.fromLTWH(
        0,
        0,
        sprite.width.toDouble(),
        sprite.height.toDouble(),
      );
      final height = size * source.height / source.width;
      final sway = math.sin(game.time * 1.2 + p.dx * .013) * 1.5;
      final target = Rect.fromLTWH(
        p.dx - size / 2 + sway,
        p.dy - height * .90,
        size,
        height,
      );
      final obscuresPlayer =
          game.player.dy <= p.dy &&
          target.deflate(size * .12).contains(game.player.translate(0, -17));
      canvas.drawImageRect(
        sprite,
        source,
        target,
        Paint()
          ..color = Colors.white.withValues(alpha: obscuresPlayer ? .43 : 1)
          ..filterQuality = FilterQuality.low
          ..colorFilter = ColorFilter.mode(palette.tint, BlendMode.modulate),
      );
      return;
    }
    final trunk = Rect.fromCenter(
      center: p.translate(0, -size * .12),
      width: size * .18,
      height: size * .26,
    );
    _arenaRound(
      canvas,
      trunk,
      12,
      _arenaLinear(trunk, [const Color(0xFFB57751), _futureInk]),
    );
    for (final offset in const [
      Offset(-.20, -.37),
      Offset(.20, -.35),
      Offset(0, -.54),
    ]) {
      final crown = Rect.fromCircle(
        center: p + offset * size,
        radius: size * .27,
      );
      canvas.drawOval(
        crown,
        _arenaClay(crown, [palette.rim, palette.leaf, palette.grass]),
      );
    }
  }

  void _boulder(Canvas canvas, Offset foot, double width) {
    final bounds = Rect.fromCenter(
      center: foot.translate(0, -width * .32),
      width: width,
      height: width * .66,
    );
    final crown = _arenaShape([
      bounds.centerLeft.translate(0, 5),
      bounds.topLeft.translate(width * .21, 6),
      bounds.topCenter.translate(width * .10, 0),
      bounds.topRight.translate(-width * .11, 10),
      bounds.centerRight,
      bounds.bottomRight.translate(-width * .21, 0),
      bounds.bottomLeft.translate(width * .14, -2),
    ]);
    canvas.drawPath(
      crown,
      _arenaClay(bounds, [
        const Color(0xFFFFBA86),
        const Color(0xFFBC7968),
        const Color(0xFF574052),
      ]),
    );
    final face = _arenaShape([
      bounds.centerLeft.translate(0, 5),
      bounds.center.translate(-width * .10, -5),
      bounds.centerRight,
      bounds.bottomRight.translate(-width * .21, 0),
      bounds.bottomLeft.translate(width * .14, -2),
    ]);
    canvas.drawPath(
      face,
      _arenaLinear(bounds, const [Color(0x11712E39), Color(0xBF4B3547)]),
    );
  }

  void _stoneBlock(Canvas canvas, _ArenaBlock block) {
    final ground = block.bounds;
    final top = ground.shift(const Offset(0, -13));
    final body = Rect.fromLTRB(top.left, top.top, top.right, ground.bottom);
    final rim = block.wall.secret ? _futureGold : palette.rim;
    final stone = palette.stone;
    _arenaRound(
      canvas,
      body,
      5,
      _arenaLinear(body, [stone, Color.lerp(stone, _futureInk, .68)!]),
    );
    _arenaRound(
      canvas,
      top,
      5,
      _arenaClay(top, [
        Color.lerp(stone, rim, .76)!,
        Color.lerp(stone, const Color(0xFFE4B191), .41)!,
        stone,
      ]),
    );
    final lip = Path()
      ..moveTo(top.left + 4, top.top + 2)
      ..lineTo(top.right - 5, top.top + 2)
      ..quadraticBezierTo(
        top.right - 2,
        top.top + 2,
        top.right - 2,
        top.top + 6,
      );
    canvas.drawPath(
      lip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.65
        ..strokeCap = StrokeCap.round
        ..color = rim.withValues(alpha: .68),
    );
    if (block.wall.secret || block.wall.health < block.wall.maxHealth * .60) {
      final crack = Path()
        ..moveTo(top.left + 2, top.center.dy + 1)
        ..lineTo(top.center.dx - 3, top.center.dy - 2)
        ..lineTo(top.center.dx + 3, top.center.dy + 3)
        ..lineTo(top.right - 4, top.center.dy - 5);
      canvas.drawPath(
        crack,
        Paint()
          ..color = block.wall.secret
              ? const Color(0xC8FFCE78)
              : const Color(0xA3422B35)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    if (block.wall.secret) {
      final c = top.center;
      canvas.drawPath(
        _arenaShape([
          c.translate(0, -5),
          c.translate(4, 0),
          c.translate(0, 5),
          c.translate(-4, 0),
        ]),
        Paint()..color = rim,
      );
    }
  }

  void _crate(Canvas canvas, Rect ground, double health) {
    final top = ground.shift(const Offset(0, -13));
    final body = Rect.fromLTRB(top.left, top.top, top.right, ground.bottom);
    _arenaRound(
      canvas,
      body,
      5,
      _arenaLinear(body, const [Color(0xFFD79658), Color(0xFF4A3232)]),
    );
    _arenaRound(
      canvas,
      top,
      5,
      _arenaLinear(top, const [
        Color(0xFFFFC882),
        Color(0xFFB46B42),
        Color(0xFF754833),
      ]),
    );
    final inset = top.deflate(4);
    _arenaRound(
      canvas,
      inset,
      2,
      _arenaLinear(inset, const [Color(0xFF84503A), Color(0xFFBA7546)]),
    );
    final braces = Path()
      ..moveTo(inset.left, inset.top)
      ..lineTo(inset.right, inset.bottom)
      ..moveTo(inset.right, inset.top)
      ..lineTo(inset.left, inset.bottom);
    canvas.drawPath(
      braces,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.1
        ..color = const Color(0xFFF2BC7B)
        ..strokeCap = StrokeCap.round,
    );
    if (health < .55) {
      canvas.drawLine(
        inset.topCenter,
        top.bottomCenter,
        Paint()
          ..color = const Color(0xC0513133)
          ..strokeWidth = 1.4,
      );
    }
  }
}

extension on _FutureDebtGame {
  void _buildArenaScenery() {
    arenaBlocks.clear();
    for (final wall in walls) {
      if (wall.crate) continue;
      final bounds = wall.bounds;
      final columns = math.max(1, (bounds.width / 43).round());
      final rows = math.max(1, (bounds.height / 40).round());
      final width = bounds.width / columns;
      final height = bounds.height / rows;
      for (var row = 0; row < rows; row++) {
        for (var column = 0; column < columns; column++) {
          arenaBlocks.add(
            _ArenaBlock(
              wall,
              Rect.fromLTWH(
                bounds.left + column * width + .6,
                bounds.top + row * height + .6,
                width - 1.2,
                height - 1.2,
              ),
            ),
          );
        }
      }
    }

    arenaTurf
      ..clear()
      ..addAll(const [
        Rect.fromLTWH(1055, 766, 255, 124),
        Rect.fromLTWH(1237, 884, 282, 103),
        Rect.fromLTWH(1170, 1000, 190, 168),
        Rect.fromLTWH(1689, 746, 270, 124),
        Rect.fromLTWH(1694, 912, 230, 75),
        Rect.fromLTWH(1718, 1122, 245, 163),
        Rect.fromLTWH(1065, 1207, 235, 108),
        Rect.fromLTWH(1422, 1124, 159, 151),
      ]);
    arenaGroves
      ..clear()
      ..addAll(const [
        _ArenaGrove(Offset(1167, 858), 211),
        _ArenaGrove(Offset(1883, 841), 176),
        _ArenaGrove(Offset(1898, 1252), 221),
        _ArenaGrove(Offset(1157, 1289), 155),
      ]);

    for (final zone in zones) {
      if (zone.bounds.contains(const Offset(1515, 1010))) continue;
      final rect = zone.bounds;
      final index = zone.name.length;
      final upper = rect.topLeft + Offset(41 + index % 5 * 12, 33);
      final lower = rect.bottomRight - Offset(231 + index % 4 * 9, 125);
      arenaTurf.addAll([
        Rect.fromLTWH(upper.dx, upper.dy, 208 + index % 3 * 17, 115),
        Rect.fromLTWH(lower.dx, lower.dy, 171 + index % 4 * 14, 111),
        Rect.fromLTWH(rect.center.dx - 76, rect.center.dy + 55, 148, 86),
      ]);
      arenaGroves.addAll([
        _ArenaGrove(upper.translate(85, 93), 146.0 + index % 5 * 11),
        _ArenaGrove(lower.translate(118, 94), 132.0 + index % 4 * 14),
      ]);
    }
  }
}
