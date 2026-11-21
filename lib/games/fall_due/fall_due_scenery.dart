part of 'fall_due_game.dart';

enum _DueLandscape {
  grove(
    'Golden Grove',
    'golden_grove',
    Color(0xFF2F2939),
    Color(0xFF98684F),
    Color(0xFF2D382A),
    Color(0xFF939549),
    Color(0xFFFFDA76),
  ),
  canyon(
    'Ember Canyon',
    'ember_canyon',
    Color(0xFF432A39),
    Color(0xFFBE7350),
    Color(0xFF57402B),
    Color(0xFFA18642),
    Color(0xFFFFC876),
  ),
  ridge(
    'Moonlit Ridge',
    'moonlit_ridge',
    Color(0xFF28283E),
    Color(0xFF777293),
    Color(0xFF233C3D),
    Color(0xFF558778),
    Color(0xFFC7E7BB),
  );

  const _DueLandscape(
    this.title,
    this.asset,
    this.stone,
    this.stoneLight,
    this.moss,
    this.leaf,
    this.rim,
  );

  final String title;
  final String asset;
  final Color stone;
  final Color stoneLight;
  final Color moss;
  final Color leaf;
  final Color rim;

  String get path => 'assets/images/fall_due/$asset.jpg';

  String get music => switch (this) {
    grove => 'sunset_steps',
    canyon => 'ember_current',
    ridge => 'settlement',
  };
}

_DueLandscape _landscapeForStage(int index) => index < _chapters.length
    ? _chapters[index].landscape
    : _DueLandscape.values[index % _DueLandscape.values.length];

/// The selector uses the opening stretch of the actual game scene.
class FallDueCover extends StatelessWidget {
  const FallDueCover({super.key, this.muted = false});

  final bool muted;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      fit: StackFit.expand,
      children: [
        const _DueBackdrop(_DueLandscape.grove),
        CustomPaint(painter: _FallPainter(_FallDueGame(), _DueLandscape.grove)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(muted ? 0x66231B26 : 0x18231B26),
                Colors.transparent,
                Color(muted ? 0xDD18141B : 0xB318141B),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _DueBackdrop extends StatelessWidget {
  const _DueBackdrop(this.landscape, {this.camera = 0});

  final _DueLandscape landscape;
  final double camera;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [landscape.stone, landscape.stoneLight, landscape.moss],
        ),
      ),
      child: Transform.scale(
        scale: 1.10,
        alignment: Alignment((camera / 1200 - 1).clamp(-1.0, 1.0), 0),
        child: Image.asset(
          landscape.path,
          fit: BoxFit.cover,
          alignment: const Alignment(.30, 0),
          gaplessPlayback: true,
          excludeFromSemantics: true,
        ),
      ),
    ),
  );
}

Paint _dueGradient(
  Rect rect,
  List<Color> colors, {
  Alignment begin = Alignment.topCenter,
  Alignment end = Alignment.bottomCenter,
}) => Paint()
  ..shader = LinearGradient(
    begin: begin,
    end: end,
    colors: colors,
  ).createShader(rect);

Paint _dueShade(
  Rect rect,
  List<Color> colors, {
  Alignment center = const Alignment(.44, -.71),
  double radius = 1.02,
}) => Paint()
  ..shader = RadialGradient(
    center: center,
    radius: radius,
    colors: colors,
  ).createShader(rect);

void _dueRounded(Canvas canvas, Rect rect, double radius, Paint paint) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    paint,
  );
}

void _dueGlow(Canvas canvas, Offset center, double radius, Color color) {
  final bounds = Rect.fromCircle(center: center, radius: radius);
  canvas.drawCircle(
    center,
    radius,
    _dueShade(
      bounds,
      [color, color.withValues(alpha: 0)],
      center: Alignment.center,
      radius: .5,
    ),
  );
}

Path _duePolygon(List<Offset> points) => Path()..addPolygon(points, true);

void _drawDueGem(Canvas canvas, Offset center, double size, Color color) {
  final top = center - Offset(0, size * 1.28);
  final right = center + Offset(size, 0);
  final bottom = center + Offset(0, size * 1.28);
  final left = center - Offset(size, 0);
  _dueGlow(canvas, center, size * 3.2, color.withValues(alpha: .42));
  canvas.drawPath(
    _duePolygon([top, right, bottom, left]),
    Paint()..color = color,
  );
  canvas.drawPath(
    _duePolygon([top, left, center]),
    Paint()..color = Color.lerp(color, Colors.white, .67)!,
  );
  canvas.drawPath(
    _duePolygon([center, right, bottom]),
    Paint()..color = Color.lerp(color, const Color(0xFF954322), .40)!,
  );
  canvas.drawPath(
    _duePolygon([top, right, bottom, left]),
    Paint()
      ..color = const Color(0xBFFFF3C2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..strokeJoin = StrokeJoin.round,
  );
}

extension on _FallPainter {
  void _drawAtmosphere(Canvas canvas) {
    const view = Rect.fromLTWH(
      0,
      0,
      _FallDueGame.viewWidth,
      _FallDueGame.viewHeight,
    );
    canvas.drawRect(
      view,
      _dueGradient(view, [
        const Color(0x21191330),
        Colors.transparent,
        const Color(0x28302540),
      ]),
    );
    final shaft = Path()
      ..moveTo(view.right * .78, 86)
      ..lineTo(view.right * .90, 84)
      ..lineTo(view.right * .63, view.bottom)
      ..lineTo(view.right * .30, view.bottom)
      ..close();
    final tint = landscape.rim;
    canvas.drawPath(
      shaft,
      _dueGradient(
        shaft.getBounds(),
        [
          tint.withValues(alpha: .07),
          tint.withValues(alpha: .021),
          Colors.transparent,
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
    // Motes at two depths drift independently of the terrain.
    for (var i = 0; i < 25; i++) {
      final x =
          (i * 143.71 -
              game.camera * (.17 + i % 2 * .12) +
              game.time * (3 + i % 4)) %
          view.width;
      final y = 118 + (i * 53 % 390) + math.sin(game.time * 1.2 + i) * 10;
      final alpha = .25 + .21 * math.sin(game.time * 1.8 + i);
      canvas.drawCircle(
        Offset(x, y),
        i % 5 == 0 ? 2.0 : 1.05,
        Paint()..color = landscape.rim.withValues(alpha: alpha),
      );
      if (i % 5 == 0) {
        final point = Offset(x, y);
        canvas.drawLine(
          point - const Offset(4, -1),
          point,
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..color = tint.withValues(alpha: alpha * .40),
        );
      }
    }
  }

  void _drawPlatform(Canvas canvas, Rect platform) {
    final shelf = platform.height < 70;
    final depth = shelf
        ? math.max(43.0, platform.height)
        : platform.height + 24;
    final r = Rect.fromLTWH(platform.left, platform.top, platform.width, depth);
    final bevel = math.min(16.0, r.width * .15);
    final lip = math.min(15.0, r.width * .17);
    final rock = Path()
      ..moveTo(r.left, r.top + lip)
      ..quadraticBezierTo(r.left, r.top + 2, r.left + bevel, r.top + 2)
      ..lineTo(r.right - bevel, r.top + 2)
      ..quadraticBezierTo(r.right, r.top + 2, r.right, r.top + lip)
      ..lineTo(r.right, r.bottom - (shelf ? 21 : 12))
      ..quadraticBezierTo(
        r.right,
        r.bottom - 8,
        r.right - bevel,
        r.bottom - (shelf ? 7 : 0),
      )
      ..quadraticBezierTo(
        r.center.dx,
        r.bottom + (shelf ? 7 : 0),
        r.left + bevel * 1.2,
        r.bottom - (shelf ? 8 : 0),
      )
      ..quadraticBezierTo(r.left, r.bottom - 11, r.left, r.bottom - 23)
      ..close();
    canvas.drawPath(
      rock,
      _dueGradient(
        r,
        [
          landscape.stoneLight,
          landscape.stone,
          Color.lerp(landscape.stone, const Color(0xFF151321), .68)!,
        ],
        begin: Alignment.topRight,
        end: const Alignment(-.48, .86),
      ),
    );

    canvas.save();
    canvas.clipPath(rock);
    final rockShade = Color.lerp(
      landscape.stone,
      const Color(0xFF0C1018),
      .32,
    )!;
    final rightFace = _duePolygon([
      Offset(r.right - bevel * 1.8, r.top + 12),
      Offset(r.right, r.top + 9),
      r.bottomRight,
      Offset(r.right - bevel * 1.4, r.bottom - 8),
    ]);
    canvas.drawPath(
      rightFace,
      _dueGradient(r, [
        landscape.stoneLight,
        landscape.stoneLight.withValues(alpha: .05),
      ]),
    );
    for (var y = 0; y < (shelf ? 1 : 2); y++) {
      for (var x = r.left + (y == 0 ? 9.0 : -27.0); x < r.right - 7; x += 61) {
        final start = r.top + 20 + y * 45 + (x.abs().toInt() % 11);
        final block = Rect.fromLTWH(
          x,
          start,
          49 + (x.abs().toInt() % 14),
          shelf ? 28 : 50,
        );
        final edge = _duePolygon([
          Offset(block.left, block.top + 9),
          Offset(block.left + 10, block.top),
          Offset(block.right - 8, block.top + 1),
          Offset(block.right, block.top + 9),
          Offset(block.right - 3, block.bottom - 7),
          Offset(block.left + 14, block.bottom),
          Offset(block.left + 1, block.bottom - 11),
        ]);
        canvas.drawPath(
          edge,
          _dueGradient(block, [
            Color.lerp(landscape.stoneLight, rockShade, .59)!,
            rockShade,
          ]),
        );
        canvas.drawPath(
          _duePolygon([
            Offset(block.left, block.top + 9),
            Offset(block.left + 10, block.top),
            Offset(block.right - 8, block.top + 1),
            Offset(block.right, block.top + 9),
            Offset(block.left + block.width * .46, block.top + 16),
          ]),
          Paint()..color = landscape.stoneLight.withValues(alpha: .18),
        );
      }
    }
    final shade = Rect.fromLTWH(r.left, r.top + 10, r.width, 22);
    canvas.drawRect(
      shade,
      _dueGradient(shade, [const Color(0xBA171321), Colors.transparent]),
    );
    canvas.restore();

    final moss = Path()
      ..moveTo(r.left, r.top + 13)
      ..quadraticBezierTo(r.left, r.top, r.left + lip, r.top)
      ..lineTo(r.right - lip, r.top)
      ..quadraticBezierTo(r.right, r.top, r.right, r.top + 13)
      ..lineTo(r.right, r.top + 16);
    final scallops = math.max(1, (r.width / 17).round());
    final step = r.width / scallops;
    for (var i = 0; i < scallops; i++) {
      final x = r.right - i * step;
      final drop = 20.0 + (i * 7 % 9);
      moss.quadraticBezierTo(
        x - step * .49,
        r.top + drop * 1.40,
        x - step,
        r.top + 15,
      );
    }
    moss.close();
    final crown = Rect.fromLTWH(r.left, r.top, r.width, 28);
    canvas.drawPath(
      moss,
      _dueGradient(crown, [
        landscape.rim,
        landscape.leaf,
        landscape.moss,
        landscape.moss,
      ]),
    );
    canvas.drawLine(
      Offset(r.left + lip, r.top + 1.6),
      Offset(r.right - lip, r.top + 1.6),
      Paint()
        ..shader = LinearGradient(
          colors: [
            landscape.rim.withValues(alpha: .15),
            landscape.rim,
            const Color(0xFFFFE9AD),
          ],
        ).createShader(crown)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.1,
    );
  }

  void _drawScenery(Canvas canvas, Rect platform) {
    if (platform.height < 70 || platform.width < 85) return;
    final seed = platform.left.round().abs();
    final root = platform.topLeft + Offset(seed == 40 ? 89 : 40 + seed % 32, 0);
    canvas.drawOval(
      Rect.fromCenter(center: root, width: 83, height: 8),
      Paint()..color = const Color(0x6327222B),
    );
    canvas.save();
    canvas.translate(root.dx, root.dy);
    if (platform.width > 220) {
      switch (landscape) {
        case _DueLandscape.grove:
          _drawTree(canvas, seed == 40 ? 1.12 : .58 + (seed % 31) / 70);
        case _DueLandscape.canyon:
          _drawCanyonSpire(canvas);
        case _DueLandscape.ridge:
          _drawPine(canvas, const Offset(-12, 0), 130);
          _drawPine(canvas, const Offset(24, 0), 86);
      }
    }
    _drawLeaves(canvas, const Offset(-24, -1), .86);
    _drawLeaves(canvas, const Offset(27, 0), seed % 2 == 0 ? 1.15 : .68);
    if (platform.width > 160) {
      _drawSurfaceRock(canvas, const Rect.fromLTWH(-51, -19, 23, 19));
      _drawSurfaceRock(canvas, const Rect.fromLTWH(-34, -12, 15, 12));
    }
    canvas.restore();
    _drawLeaves(canvas, platform.topRight - const Offset(30, 1), .62);
  }

  void _drawSurfaceRock(Canvas canvas, Rect bounds) {
    final center = bounds.topCenter;
    final edge = Path()
      ..moveTo(bounds.left, bounds.bottom)
      ..quadraticBezierTo(
        bounds.left + 3,
        bounds.top,
        center.dx - 2,
        bounds.top,
      )
      ..lineTo(bounds.right - 5, bounds.top + 2)
      ..quadraticBezierTo(
        bounds.right,
        bounds.top + 4,
        bounds.right,
        bounds.bottom,
      )
      ..close();
    canvas.drawPath(
      edge,
      _dueShade(bounds, [landscape.stoneLight, landscape.stone, _dueInk]),
    );
  }

  void _drawTree(Canvas canvas, double scale) {
    canvas.save();
    canvas.scale(scale);
    final trunk = Path()
      ..moveTo(-27, 0)
      ..cubicTo(-8, -13, -15, -49, -12, -97)
      ..cubicTo(-10, -128, -15, -155, -13, -171)
      ..lineTo(16, -172)
      ..cubicTo(8, -138, 14, -109, 10, -85)
      ..cubicTo(9, -32, 4, -9, 31, 0)
      ..close();
    final wood = _dueGradient(
      const Rect.fromLTWH(-24, -174, 49, 174),
      [
        const Color(0xFF372933),
        const Color(0xFF684031),
        const Color(0xFFBE7750),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final limbs = Path()
      ..moveTo(-5, -93)
      ..quadraticBezierTo(-37, -109, -56, -144)
      ..moveTo(7, -78)
      ..quadraticBezierTo(41, -93, 48, -124);
    canvas.drawPath(
      limbs,
      Paint()
        ..color = const Color(0xFF674134)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(trunk, wood);
    const canopy = [
      Rect.fromLTWH(-93, -191, 95, 79),
      Rect.fromLTWH(-11, -193, 92, 90),
      Rect.fromLTWH(-53, -240, 112, 112),
      Rect.fromLTWH(-108, -221, 100, 87),
      Rect.fromLTWH(22, -179, 79, 77),
      Rect.fromLTWH(-65, -203, 95, 71),
    ];
    for (var i = 0; i < canopy.length; i++) {
      final crown = canopy[i];
      final crownShape = Path()
        ..moveTo(crown.left, crown.center.dy)
        ..cubicTo(
          crown.left - 3,
          crown.top + 14,
          crown.center.dx - 23,
          crown.top,
          crown.center.dx,
          crown.top,
        )
        ..cubicTo(
          crown.center.dx + 37,
          crown.top - 4,
          crown.right,
          crown.top + 14,
          crown.right,
          crown.center.dy,
        )
        ..cubicTo(
          crown.right + 4,
          crown.bottom - 9,
          crown.right - 18,
          crown.bottom,
          crown.center.dx,
          crown.bottom,
        )
        ..cubicTo(
          crown.left + 12,
          crown.bottom + 3,
          crown.left + 3,
          crown.bottom - 15,
          crown.left,
          crown.center.dy,
        )
        ..close();
      canvas.drawPath(
        crownShape,
        _dueShade(
          crown,
          [
            i.isEven ? const Color(0xFFC0AA56) : const Color(0xFF96964E),
            const Color(0xFF4C603A),
            const Color(0xFF203A32),
          ],
          center: const Alignment(.83, -.76),
          radius: 1.04,
        ),
      );
    }
    canvas.restore();
  }

  void _drawCanyonSpire(Canvas canvas) {
    final spire = _duePolygon(const [
      Offset(-49, 0),
      Offset(-37, -50),
      Offset(-23, -64),
      Offset(-20, -111),
      Offset(-2, -127),
      Offset(17, -123),
      Offset(30, -103),
      Offset(25, -61),
      Offset(38, -46),
      Offset(45, 0),
    ]);
    const bounds = Rect.fromLTWH(-49, -127, 94, 127);
    canvas.drawPath(
      spire,
      _dueGradient(
        bounds,
        [
          const Color(0xFFCF835B),
          const Color(0xFF7B4B47),
          const Color(0xFF3E2A36),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
    canvas.save();
    canvas.clipPath(spire);
    for (var i = 0; i < 5; i++) {
      final y = -104.0 + i * 22;
      canvas.drawLine(
        Offset(-54, y + 13),
        Offset(53, y),
        Paint()
          ..color = const Color(0x3EEFAB80)
          ..strokeWidth = 1.6 + i % 3,
      );
    }
    canvas.restore();
  }

  void _drawPine(Canvas canvas, Offset root, double height) {
    canvas.drawLine(
      root,
      root.translate(0, -height * .7),
      Paint()
        ..color = landscape.stone
        ..strokeWidth = 7,
    );
    for (var i = 0; i < 3; i++) {
      final peak = root.translate(0, -height * (.70 + i * .15));
      final width = height * (.25 - i * .054);
      final tier = Path()
        ..moveTo(peak.dx, peak.dy)
        ..quadraticBezierTo(
          peak.dx + width * .38,
          peak.dy + height * .31,
          peak.dx + width,
          peak.dy + height * .49,
        )
        ..quadraticBezierTo(
          peak.dx,
          peak.dy + height * .61,
          peak.dx - width,
          peak.dy + height * .49,
        )
        ..quadraticBezierTo(
          peak.dx - width * .44,
          peak.dy + height * .34,
          peak.dx,
          peak.dy,
        );
      canvas.drawPath(
        tier,
        _dueGradient(
          tier.getBounds(),
          [landscape.leaf, landscape.moss, const Color(0xFF1E303E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      );
    }
  }

  void _drawLeaves(Canvas canvas, Offset root, double scale) {
    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.scale(scale);
    for (final tilt in [-.92, -.44, .22, .84]) {
      canvas.save();
      canvas.rotate(tilt);
      final blade = Path()
        ..moveTo(0, 0)
        ..cubicTo(-16, -15, -10, -27, 0, -28)
        ..cubicTo(12, -27, 11, -13, 0, 0);
      canvas.drawPath(
        blade,
        _dueGradient(
          blade.getBounds(),
          [landscape.rim, landscape.leaf, landscape.moss],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      );
      canvas.restore();
    }
    canvas.restore();
  }
}
