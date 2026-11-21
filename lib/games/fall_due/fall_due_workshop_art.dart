part of 'fall_due_game.dart';

extension on _FallPainter {
  static const _depth = Offset(18, -13);
  static const _iron = Color(0xFF373349);
  static const _darkMetal = Color(0xFF211E2C);

  void _drawOpeningRelay(Canvas canvas, _DueWorkshop opening, Rect world) {
    if (!world.overlaps(opening.view)) return;
    _drawWorkshopOptic(canvas, opening, world);
    for (final target in opening.targets) {
      _workshopActor(canvas, target, landscape.rim);
    }
    if (opening.run.opened) {
      final bridge = opening.run.lift!.shift(opening.origin);
      _workshopMetal(canvas, bridge, _dueMint, bevel: 5);
      canvas.drawLine(
        bridge.topLeft + const Offset(3, 1),
        bridge.topRight + const Offset(-3, 1),
        Paint()
          ..color = _dueMint
          ..strokeWidth = 3,
      );
    }
  }

  void _drawWorkshopOptic(Canvas canvas, _DueWorkshop workshop, Rect world) {
    final run = workshop.run;
    final optic = run.room.optic;
    if (optic == null) return;
    final offset = workshop.origin;
    final source = optic.source + offset;
    final receiver = optic.receiver + offset;
    final rim = run.opticTrace?.powered == true ? _dueMint : _dueBlue;
    if (world.contains(source)) {
      _workshopMetal(
        canvas,
        Rect.fromCenter(center: source, width: 29, height: 24),
        _dueGold,
        bevel: 7,
      );
    }
    if (world.contains(receiver)) {
      _workshopMetal(
        canvas,
        Rect.fromCenter(center: receiver, width: 34, height: 24),
        rim,
        bevel: 7,
      );
      _badge(canvas, 'BEAM RECEIVER', receiver - const Offset(0, 21), rim);
    }
    _paintOpticBeam(canvas, run, offset);
  }

  void _drawWorkshopBackground(
    Canvas canvas,
    _DueWorkshop workshop,
    Rect world,
  ) {
    final run = workshop.run;
    final left = workshop.left;
    final right = workshop.right;
    final accent = landscape.rim;
    // Supports sit behind the playable plane and use the landscape's masonry.
    for (var x = left + 32; x <= right; x += 208) {
      if (x < world.left - 85 || x > world.right + 85) continue;
      final pillar = Rect.fromLTWH(x, 126 + (x ~/ 200 % 2) * 31, 28, 294);
      canvas.drawPath(
        _duePolygon([
          pillar.topLeft,
          pillar.topRight,
          pillar.topRight + _depth,
          pillar.topLeft + _depth,
        ]),
        Paint()..color = landscape.stoneLight.withValues(alpha: .25),
      );
      canvas.drawRect(
        pillar,
        _dueGradient(pillar, [
          landscape.stone.withValues(alpha: .66),
          _darkMetal.withValues(alpha: 0),
        ]),
      );
      canvas.drawLine(
        pillar.topRight + _depth,
        pillar.bottomRight + _depth,
        Paint()
          ..color = accent.withValues(alpha: .21)
          ..strokeWidth = 2,
      );
    }
    final sign = Offset(left + 88, 217);
    if (world.contains(sign)) {
      final label = workshop.room.boss ?? workshop.room.title;
      final nameplate = Rect.fromLTWH(sign.dx - 20, sign.dy - 12, 223, 41);
      _workshopMetal(canvas, nameplate, accent, bevel: 6);
      paintGameText(
        canvas,
        label,
        nameplate.topLeft + const Offset(13, 12),
        13,
        _dueCream,
        bold: true,
        glowColor: _darkMetal,
      );
      canvas.drawLine(
        nameplate.bottomLeft + const Offset(21, 12),
        nameplate.bottomLeft,
        Paint()
          ..color = _darkMetal
          ..strokeWidth = 3,
      );
    }
    for (final field in workshop.room.fields) {
      if (run.signals.contains(field.off)) continue;
      final zone = field.area.shift(workshop.origin);
      if (!zone.overlaps(world)) continue;
      final force = run.forceAt(field.area.center);
      if (force.distanceSquared < 1) continue;
      final dir = force / force.distance;
      canvas.drawRect(
        zone,
        _dueGradient(
          zone,
          [
            _dueBlue.withValues(alpha: 0),
            _dueBlue.withValues(alpha: .25),
            _dueBlue.withValues(alpha: 0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      );
      canvas.save();
      canvas.clipRect(zone);
      final tracer = Paint()
        ..color = _dueBlue.withValues(alpha: .45)
        ..strokeWidth = 1.5;
      for (var x = zone.left + 10; x < zone.right; x += 29) {
        for (var y = zone.top + 8; y < zone.bottom; y += 39) {
          final at = Offset(x, y) + dir * ((run.clock * 42 + x) % 30);
          canvas.drawLine(at - dir * 9, at + dir * 12, tracer);
          canvas.drawCircle(at + dir * 12, 1.65, tracer);
        }
      }
      canvas.restore();
    }
    if (run.water case final wet?) {
      _workshopTank(
        canvas,
        workshop.room.basin!.area.shift(workshop.origin),
        wet.shift(workshop.origin),
        workshop.room.basin!.hot ? const Color(0xFFF69359) : _dueBlue,
      );
    }
    if (run.reserveWater case final wet?) {
      _workshopTank(
        canvas,
        workshop.room.reserve!.shift(workshop.origin),
        wet.shift(workshop.origin),
        _dueBlue,
      );
    }
  }

  void _workshopTank(Canvas canvas, Rect frame, Rect fill, Color light) {
    final dimension = const Offset(22, -9);
    canvas.drawPath(
      _duePolygon([
        frame.topLeft,
        frame.topRight,
        frame.topRight + dimension,
        frame.topLeft + dimension,
      ]),
      Paint()..color = _iron.withValues(alpha: .80),
    );
    canvas.drawRect(frame, Paint()..color = const Color(0xA3242037));
    canvas.drawRect(
      fill,
      _dueGradient(fill, [
        light.withValues(alpha: .54),
        const Color(0xDD252439),
      ]),
    );
    canvas.drawPath(
      _duePolygon([
        fill.topLeft,
        fill.topRight,
        fill.topRight + dimension,
        fill.topLeft + dimension,
      ]),
      _dueGradient(fill.inflate(1), [
        light.withValues(alpha: .25),
        light.withValues(alpha: .8),
      ]),
    );
    _workshopMetal(
      canvas,
      Rect.fromLTWH(frame.left - 4, frame.top, 7, frame.height),
      light,
      bevel: 2,
    );
    _workshopMetal(
      canvas,
      Rect.fromLTWH(frame.right - 3, frame.top, 7, frame.height),
      light,
      bevel: 2,
    );
    for (var y = frame.top + 19; y < frame.bottom; y += 15) {
      canvas.drawLine(
        Offset(frame.left + 7, y),
        Offset(frame.left + 15, y),
        Paint()
          ..color = light.withValues(alpha: .54)
          ..strokeWidth = 1.4,
      );
    }
  }

  void _drawWorkshopMachines(Canvas canvas, _DueWorkshop workshop, Rect world) {
    final run = workshop.run;
    final offset = workshop.origin;
    final chapterAccent = switch (landscape) {
      _DueLandscape.grove => const Color(0xFFCBA473),
      _DueLandscape.canyon => const Color(0xFFF2A075),
      _DueLandscape.ridge => const Color(0xFFBCB1E5),
    };
    for (final floor in workshop.room.floors.where(
      (floor) => !run.broken.contains(floor),
    )) {
      final rect = floor.shift(offset);
      if (!world.overlaps(rect)) continue;
      _drawPlatform(canvas, rect);
      if (floor.height >= 70) {
        _drawScenery(canvas, rect);
      } else {
        canvas.drawLine(
          rect.topLeft + const Offset(11, 1),
          rect.topRight - const Offset(11, -1),
          Paint()
            ..color = chapterAccent.withValues(alpha: .7)
            ..strokeWidth = 3,
        );
      }
    }
    if (run.lift case final lift?) {
      final base = workshop.room.lift!.base.shift(offset);
      final actual = lift.shift(offset);
      final path = base.expandToInclude(base.shift(workshop.room.lift!.travel));
      if (world.overlaps(path)) {
        final steel = Paint()
          ..color = chapterAccent.withValues(alpha: .47)
          ..strokeWidth = 3;
        canvas.drawLine(
          path.topLeft + const Offset(7, -23),
          path.bottomLeft + const Offset(7, 3),
          steel,
        );
        canvas.drawLine(
          path.topRight + const Offset(-7, -23),
          path.bottomRight + const Offset(-7, 3),
          steel,
        );
        _workshopMetal(canvas, actual, chapterAccent, bevel: 6);
        _dueGlow(canvas, actual.center, 22, _dueMint.withValues(alpha: .38));
      }
    }
    for (final barrier in workshop.room.barriers) {
      if (run.openBarriers.contains(barrier)) continue;
      final rect = barrier.area.shift(offset);
      if (world.overlaps(rect)) {
        _workshopMetal(canvas, rect, chapterAccent, bevel: 5);
      }
    }
    _drawWorkshopOptic(canvas, workshop, world);
    for (final sensor in workshop.room.sensors) {
      if (sensor.kind == _Sense.visit ||
          sensor.kind == _Sense.basin ||
          sensor.kind == _Sense.dock ||
          sensor.kind == _Sense.optical) {
        continue;
      }
      final rect = sensor.area.shift(offset);
      if (!world.overlaps(rect.inflate(50))) continue;
      final lit = run.signals.contains(sensor.id);
      final color = lit
          ? _dueMint
          : (sensor.kind == _Sense.impact ? _dueCoral : _dueBlue);
      if (sensor.kind == _Sense.load) {
        _workshopMetal(
          canvas,
          Rect.fromLTWH(rect.left, rect.bottom - 4, rect.width, 9),
          color,
          bevel: 3,
        );
        if (sensor.balance case final other?) {
          _workshopMetal(
            canvas,
            Rect.fromLTWH(
              other.left + offset.dx,
              other.bottom + offset.dy - 4,
              other.width,
              9,
            ),
            color,
            bevel: 3,
          );
        }
        if (sensor.balance == null) {
          _badge(
            canvas,
            '${sensor.threshold.toStringAsFixed(0)} WT',
            rect.bottomCenter + const Offset(0, 24),
            color,
          );
        }
      } else {
        final bracket = Paint()
          ..color = color.withValues(alpha: lit ? .95 : .63)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        final x = rect.center.dx;
        canvas.drawPath(
          Path()
            ..moveTo(rect.left, rect.bottom - 3)
            ..lineTo(rect.left, rect.top + 3)
            ..quadraticBezierTo(rect.left, rect.top, rect.left + 5, rect.top)
            ..lineTo(x - 11, rect.top)
            ..moveTo(x + 11, rect.top)
            ..lineTo(rect.right - 5, rect.top)
            ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 3)
            ..lineTo(rect.right, rect.bottom - 3),
          bracket,
        );
        if (lit) {
          _dueGlow(canvas, rect.center, 25, color.withValues(alpha: .43));
        }
      }
    }

    final threshold = workshop.boundary.left;
    final door = workshop.room.exit.shift(offset);
    final ready = run.opened;
    final passageLight = ready ? _dueMint : chapterAccent;
    if (world.overlaps(door.inflate(42))) {
      final pilaster = Rect.fromLTWH(threshold - 5, 118, 17, 313);
      _workshopMetal(
        canvas,
        pilaster,
        chapterAccent.withValues(alpha: .65),
        bevel: 4,
      );
      final portal = RRect.fromRectAndCorners(
        door,
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
      );
      canvas.drawRRect(
        portal,
        _dueGradient(door, [
          _darkMetal,
          ready ? const Color(0xAA264546) : const Color(0xED302840),
          _darkMetal,
        ]),
      );
      canvas.drawRRect(
        portal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = passageLight.withValues(alpha: .76),
      );
      _dueGlow(canvas, door.topCenter, 20, passageLight.withValues(alpha: .57));
      canvas.drawCircle(door.topCenter, 4, Paint()..color = passageLight);
    }

    for (final trap in workshop.room.traps) {
      final phase = run.phase(trap);
      if (phase == 0) continue;
      final area = run.trapArea(trap).shift(offset);
      if (area.isEmpty || !world.overlaps(area)) continue;
      final active = phase == 2;
      if (active && trap.kind == _Threat.spikes) {
        _drawSpikes(canvas, area, false);
      } else {
        final edge = active ? _dueCoral : _dueGold;
        canvas.drawRect(
          area,
          _dueGradient(
            area,
            [
              edge.withValues(alpha: .04),
              edge.withValues(alpha: active ? .66 : .2),
              edge.withValues(alpha: .05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
        canvas.drawRect(
          area,
          Paint()
            ..color = edge.withValues(alpha: .88)
            ..style = PaintingStyle.stroke
            ..strokeWidth = active ? 2.5 : 1.2,
        );
        for (var x = area.left + 8; x < area.right - 4; x += 32) {
          canvas.drawLine(
            Offset(x, area.bottom - 4),
            Offset(x + 4, area.top + 4),
            Paint()
              ..color = edge.withValues(alpha: .55)
              ..strokeWidth = 2,
          );
        }
      }
    }

    if (workshop.room.weak case final weak?
        when world.contains(weak + offset)) {
      _workshopBoss(canvas, workshop, weak + offset, chapterAccent);
    }
    for (final actor in workshop.targets) {
      if (world.overlaps(actor.rect.inflate(72))) {
        _workshopActor(canvas, actor, chapterAccent);
      }
    }
    if (workshop.room.secret case final secret?
        when !workshop.archived && world.contains(secret + offset)) {
      _drawDueGem(canvas, secret + offset, 8, _dueBlue);
    }
  }

  void _workshopMetal(
    Canvas canvas,
    Rect rect,
    Color accent, {
    double bevel = 4,
  }) {
    final face = _duePolygon([
      rect.topLeft,
      rect.topRight,
      rect.topRight + _depth * .47,
      rect.topLeft + _depth * .47,
    ]);
    final rim = Color.lerp(_iron, accent, .32)!;
    canvas.drawPath(face, Paint()..color = rim);
    canvas.drawPath(
      _duePolygon([
        rect.topRight,
        rect.topRight + _depth * .47,
        rect.bottomRight + _depth * .47,
        rect.bottomRight,
      ]),
      Paint()..color = _darkMetal,
    );
    _dueRounded(
      canvas,
      rect,
      bevel,
      _dueGradient(rect, [rim, _iron, _darkMetal]),
    );
    if (rect.width >= 20 && rect.height >= 12) {
      final bolt = Paint()..color = accent.withValues(alpha: .56);
      canvas.drawCircle(rect.topLeft + const Offset(5, 5), 1.4, bolt);
      canvas.drawCircle(rect.bottomRight - const Offset(5, 5), 1.4, bolt);
    }
  }

  void _workshopActor(Canvas canvas, _DueWorkshopTarget actor, Color accent) {
    final body = actor.body;
    final rect = actor.rect;
    final type = body.spec.material;
    if (body.lost) {
      if (body.spec.recall) {
        _dueGlow(
          canvas,
          body.spec.at + actor.workshop.origin,
          22,
          _dueBlue.withValues(alpha: .39),
        );
      }
      return;
    }
    if (body.spec.rail case final rail?
        when rail.width <= 1 && rail.height > 22) {
      final bounds = rail.shift(actor.workshop.origin);
      final stroke = Paint()
        ..color = accent.withValues(alpha: .45)
        ..strokeWidth = 2.2;
      final x = bounds.left;
      canvas.drawLine(
        Offset(x - rect.width * .47, bounds.top - 12),
        Offset(x - rect.width * .47, bounds.bottom + 4),
        stroke,
      );
      canvas.drawLine(
        Offset(x + rect.width * .47, bounds.top - 12),
        Offset(x + rect.width * .47, bounds.bottom + 4),
        stroke,
      );
    }
    final light = body.caught
        ? _dueMint
        : switch (body.gravity) {
            _Gravity.give => _dueGold,
            _Gravity.take => _dueBlue,
            _Gravity.normal => type.enemy ? _dueCoral : accent,
          };
    if (type == _Material.pulse) {
      _drawDueGem(canvas, rect.center, rect.width * .42, light);
      return;
    }
    _workshopMetal(
      canvas,
      rect,
      light,
      bevel: type == _Material.float ? 10 : 4,
    );
    final plate = rect.deflate(rect.width > 33 ? 7 : 5);
    if (actor.workshop.room.optic?.mirror == actor.id) {
      final glass = Paint()
        ..color = const Color(0xFFCBF3FF)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(plate.bottomLeft, plate.topRight, glass);
      canvas.drawLine(
        plate.bottomLeft + const Offset(0, 1),
        plate.topRight + const Offset(0, 1),
        Paint()
          ..strokeWidth = 1.5
          ..color = Colors.white,
      );
      if (!body.caught && actor.workshop.inline) {
        _badge(
          canvas,
          'TAKE · REFLECTOR',
          actor.center - const Offset(0, 38),
          _dueBlue,
        );
      }
    } else if (type.enemy) {
      _dueRounded(
        canvas,
        Rect.fromCenter(
          center: rect.center - const Offset(0, 4),
          width: rect.width * .67,
          height: 10,
        ),
        4,
        Paint()..color = const Color(0xFF201929),
      );
      canvas.drawCircle(
        rect.center + Offset(6 * body.patrol, -4),
        3.1,
        Paint()..color = light,
      );
    } else if (type == _Material.float) {
      canvas.drawLine(
        plate.centerLeft,
        plate.centerRight,
        Paint()
          ..color = _dueBlue.withValues(alpha: .73)
          ..strokeWidth = 4,
      );
      canvas.drawCircle(plate.center, 5, Paint()..color = light);
    } else {
      canvas.drawPath(
        _duePolygon([
          plate.bottomLeft,
          plate.topRight,
          plate.topRight - const Offset(7, 0),
          plate.bottomLeft + const Offset(6, 0),
        ]),
        Paint()..color = light.withValues(alpha: .42),
      );
    }
    if (body.gravity != _Gravity.normal && !body.caught) {
      final sign = body.gravity == _Gravity.take ? -1.0 : 1.0;
      final pos = rect.center + Offset(0, sign * (rect.height / 2 + 9));
      final arrow = _duePolygon([
        pos + Offset(0, sign * 6),
        pos + const Offset(-6, 0),
        pos + const Offset(6, 0),
      ]);
      canvas.drawPath(
        arrow,
        Paint()..color = light.withValues(alpha: body.timer < .3 ? .45 : .9),
      );
    }
  }

  void _workshopBoss(
    Canvas canvas,
    _DueWorkshop workshop,
    Offset weak,
    Color accent,
  ) {
    final active = !workshop.run.opened;
    final signal = active ? _dueCoral : _dueMint;
    final core = Rect.fromCenter(
      center: weak - const Offset(1, 48),
      width: 106,
      height: 92,
    );
    final shape = workshop.room.boss;
    if (shape == 'Sump Custodian' || shape == 'Field Cartographer') {
      final rotor = weak - const Offset(0, 51);
      canvas.drawCircle(rotor + _depth, 47, Paint()..color = _darkMetal);
      canvas.drawCircle(rotor, 47, _dueGradient(core, [_iron, _darkMetal]));
      canvas.drawCircle(
        rotor,
        38,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = accent.withValues(alpha: .72),
      );
      final parts = shape == 'Sump Custodian' ? 7 : 4;
      final paint = Paint()
        ..color = accent.withValues(alpha: .52)
        ..strokeWidth = 4.5;
      for (var i = 0; i < parts; i++) {
        final angle =
            math.pi * 2 * i / parts + workshop.run.clock * (active ? 1.8 : .18);
        final axis = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(rotor + axis * 15, rotor + axis * 31, paint);
      }
    } else {
      final silhouette = _duePolygon([
        core.bottomLeft,
        core.topLeft + const Offset(0, 25),
        core.topLeft + const Offset(22, 0),
        core.topRight - const Offset(20, 0),
        core.topRight + const Offset(0, 24),
        core.bottomRight,
      ]);
      canvas.drawPath(silhouette.shift(_depth), Paint()..color = _darkMetal);
      canvas.drawPath(
        silhouette,
        _dueGradient(core, [
          Color.lerp(_iron, accent, .52)!,
          _iron,
          _darkMetal,
        ]),
      );
      if (shape == 'The Auditor') {
        for (final dx in [-61.0, 49.0]) {
          _workshopMetal(
            canvas,
            Rect.fromLTWH(weak.dx + dx, core.top - 17, 14, 94),
            accent,
          );
        }
      } else {
        _workshopMetal(
          canvas,
          Rect.fromLTWH(core.left + 9, core.top + 28, 88, 13),
          accent,
          bevel: 4,
        );
      }
    }
    _dueGlow(canvas, weak, 27, signal.withValues(alpha: .64));
    canvas.drawCircle(
      weak,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = signal,
    );
    canvas.drawCircle(weak, 3.6, Paint()..color = signal);
  }
}

void _paintOpticBeam(Canvas canvas, _StoryRun run, Offset offset) {
  final optic = run.room.optic;
  final trace = run.opticTrace;
  if (optic == null || trace == null) return;
  final source = optic.source + offset;
  final corner = trace.corner + offset;
  void ray(Offset start, Offset end, Color light, {required bool strong}) {
    final length = (end - start).distance;
    if (length < 1) return;
    final direction = (end - start) / length;
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = light.withValues(alpha: strong ? .52 : .34)
        ..strokeWidth = strong ? 13 : 9
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..strokeWidth = strong ? 3.6 : 2.2
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(light, Colors.white, .38)!,
    );
    for (var d = (run.clock * 135 % 61); d < length; d += 61) {
      canvas.drawCircle(
        start + direction * d,
        strong ? 2.8 : 1.8,
        Paint()..color = const Color(0xFFEAFBFF),
      );
    }
  }

  ray(
    source,
    corner,
    const Color(0xFFFFA743),
    strong: trace.redirected != null,
  );
  if (trace.redirected case final hit?) {
    final end = hit + offset;
    ray(corner, end, const Color(0xFF61EAFF), strong: true);
    _dueGlow(canvas, corner, 23, _dueBlue.withValues(alpha: .71));
    if (trace.powered) {
      _dueGlow(canvas, end, 28, _dueMint.withValues(alpha: .84));
      canvas.drawCircle(end, 5, Paint()..color = _dueMint);
    }
  }
}
