part of 'fall_due_game.dart';

class _StoryPainter extends CustomPainter {
  const _StoryPainter({
    required this.run,
    required this.theme,
    required this.contrast,
    required this.reduced,
  });
  final _StoryRun run;
  final _DueLandscape theme;
  final bool contrast, reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final view = LogicalViewport.fit(size, _duePlayfieldSize);
    if (view.scale <= 0) return;
    canvas.save();
    canvas.clipRect(view.screenWorldRect);
    view.applyTo(canvas);
    const world = Rect.fromLTWH(0, 0, 960, 540);
    canvas.drawRect(
      world,
      _dueGradient(
        world,
        [
          const Color(0x2912121C),
          const Color(0x86151422),
          const Color(0xF01A1721),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
    _field(canvas);
    _fluid(canvas);
    _platforms(canvas);
    _exit(canvas);
    _sensors(canvas);
    _hazards(canvas);
    _paintOpticBeam(canvas, run, Offset.zero);
    _boss(canvas);
    if (run.room.secret != null && !run.found.contains(run.index)) {
      _drawDueGem(canvas, run.room.secret!, 10, _dueBlue);
    }
    for (final body in run.bodies.values) {
      _body(canvas, body);
    }
    _avatar(canvas);
    _castEffect(canvas);
    _caption(canvas);
    canvas.restore();
  }

  void _field(Canvas canvas) {
    for (final field in run.room.fields) {
      if (run.signals.contains(field.off)) continue;
      final force = run.forceAt(field.area.center);
      if (force.distanceSquared <= 1) continue;
      final direction = force / force.distance;
      final color = _dueBlue.withValues(alpha: .60);
      canvas.drawRect(
        field.area,
        Paint()..color = _dueBlue.withValues(alpha: .09),
      );
      canvas.save();
      canvas.clipRect(field.area);
      for (var x = field.area.left + 12; x < field.area.right; x += 34) {
        for (var y = field.area.top + 16; y < field.area.bottom; y += 35) {
          final shift = reduced ? 0.0 : (run.clock * 32 % 22);
          final point = Offset(x, y) + direction * shift;
          _arrow(
            canvas,
            point - direction * 9,
            point + direction * 9,
            color,
            1.5,
          );
        }
      }
      canvas.restore();
    }
  }

  void _fluid(Canvas canvas) {
    final wet = run.water;
    if (wet == null) return;
    final basin = run.room.basin!;
    _pool(canvas, basin.area, wet, basin.hot ? _dueCoral : _dueBlue);
    if (run.reserveWater case final reservoir?) {
      _pool(canvas, run.room.reserve!, reservoir, _dueBlue);
    }
  }

  void _pool(Canvas canvas, Rect area, Rect wet, Color color) {
    canvas.drawRect(
      area,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: .37)
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      wet,
      _dueGradient(wet, [
        color.withValues(alpha: .37),
        color.withValues(alpha: .68),
      ]),
    );
    canvas.drawLine(
      wet.topLeft,
      wet.topRight,
      Paint()
        ..color = color
        ..strokeWidth = 3,
    );
    for (var y = area.top + 11; y < area.bottom; y += 20) {
      canvas.drawLine(
        Offset(area.left + 1, y),
        Offset(area.left + 12, y),
        Paint()..color = color.withValues(alpha: .55),
      );
    }
  }

  void _platforms(Canvas canvas) {
    for (final floor in run.solids) {
      final lift = floor == run.lift;
      final hatch = run.room.service.contains(floor) && floor.height <= 12;
      final cracked = run.room.crumbling.contains(floor);
      final top = lift ? _dueBlue : (hatch ? _dueCoral : theme.rim);
      canvas.drawRect(
        floor,
        _dueGradient(floor, [
          lift ? const Color(0xFF37485D) : theme.stone,
          const Color(0xFF211C29),
        ]),
      );
      canvas.drawLine(
        floor.topLeft,
        floor.topRight,
        Paint()
          ..color = top.withValues(alpha: .85)
          ..strokeWidth = 3,
      );
      if (cracked) {
        final stress = (run.shelfStress[floor] ?? 0).clamp(0.0, 1.2) / 1.2;
        final crack = Paint()
          ..color = _dueCoral.withValues(alpha: .36 + stress * .6)
          ..strokeWidth = 1.8;
        for (var x = floor.left + 7; x < floor.right - 9; x += 18) {
          canvas.drawLine(
            Offset(x, floor.top + 3),
            Offset(x + 8, floor.bottom - 3),
            crack,
          );
        }
      }
      for (
        var x = floor.left + 12;
        x < floor.right - 6;
        x += (lift ? 25 : 54)
      ) {
        canvas.drawCircle(
          Offset(x, floor.top + math.min(9, floor.height / 2)),
          1.6,
          Paint()..color = top.withValues(alpha: .65),
        );
      }
      if (run.room.barriers.any((barrier) => barrier.area == floor)) {
        for (var y = floor.top + 9; y < floor.bottom - 7; y += 15) {
          canvas.drawLine(
            Offset(floor.left + 3, y + 5),
            Offset(floor.right - 3, y - 5),
            Paint()
              ..color = _dueGold.withValues(alpha: .64)
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  void _exit(Canvas canvas) {
    final door = run.room.exit;
    final color = run.opened ? _dueMint : _dueGold;
    final frame = RRect.fromRectAndCorners(
      door,
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xE91B1825));
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: .75)
        ..strokeWidth = 3,
    );
    if (run.opened) {
      _arrow(
        canvas,
        door.center - const Offset(12, 0),
        door.center + const Offset(12, 0),
        color,
        3,
      );
    } else {
      final lock = door.center;
      canvas.drawArc(
        Rect.fromCenter(
          center: lock - const Offset(0, 5),
          width: 14,
          height: 18,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = 2,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: lock + const Offset(0, 4),
          width: 16,
          height: 12,
        ),
        Paint()..color = color,
      );
    }
  }

  void _sensors(Canvas canvas) {
    for (final sensor in run.room.sensors) {
      final on = run.signals.contains(sensor.id);
      final color = on
          ? _dueMint
          : (sensor.kind == _Sense.impact ? _dueCoral : _dueBlue);
      final rect = sensor.area;
      if (sensor.kind == _Sense.visit) continue;
      final paint = Paint()
        ..color = color.withValues(alpha: on ? .65 : .49)
        ..strokeWidth = 2;
      if (sensor.kind == _Sense.load) {
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.bottom - 5, rect.width, 5),
          paint,
        );
        canvas.drawLine(rect.bottomLeft, rect.bottomRight, paint);
        if (sensor.balance case final right?) {
          canvas.drawRect(
            Rect.fromLTWH(right.left, right.bottom - 5, right.width, 5),
            paint,
          );
          canvas.drawLine(
            rect.topCenter - const Offset(0, 10),
            right.topCenter - const Offset(0, 10),
            Paint()
              ..color = color.withValues(alpha: .38)
              ..strokeWidth = 1.6,
          );
        }
        if (sensor.balance == null) {
          final label =
              '${sensor.threshold.toStringAsFixed(sensor.threshold % 1 == 0 ? 0 : 1)} WT';
          paintGameText(
            canvas,
            label,
            rect.bottomCenter + const Offset(0, 7),
            10,
            color,
            align: TextAlign.center,
          );
        }
      } else {
        _corners(canvas, rect, paint, 8);
        if (sensor.kind == _Sense.catchBody) {
          _arrow(
            canvas,
            rect.center + const Offset(0, 6),
            rect.center - const Offset(0, 6),
            color,
            1.6,
          );
        }
      }
    }
  }

  void _hazards(Canvas canvas) {
    for (final trap in run.room.traps) {
      final phase = run.phase(trap);
      if (phase == 0) continue;
      final rect = run.trapArea(trap);
      if (rect.isEmpty) continue;
      final active = phase == 2;
      final color = active ? _dueCoral : _dueGold;
      canvas.drawRect(
        rect,
        Paint()..color = color.withValues(alpha: active ? .39 : .20),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = active ? 3.0 : 1.6,
      );
      if (trap.kind == _Threat.spikes) {
        for (var x = rect.left + 3; x + 14 < rect.right; x += 16) {
          canvas.drawPath(
            _duePolygon([
              Offset(x, rect.bottom),
              Offset(x + 7, active ? rect.top : rect.bottom - 8),
              Offset(x + 14, rect.bottom),
            ]),
            Paint()..color = color,
          );
        }
      } else {
        for (var x = rect.left + 7; x < rect.right - 4; x += 34) {
          canvas.drawLine(
            Offset(x, rect.bottom - 4),
            Offset(x + 5, rect.top + 4),
            Paint()
              ..color = color.withValues(alpha: .64)
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  void _boss(Canvas canvas) {
    if (run.room.weak case final center?) {
      final color = run.opened ? _dueMint : _dueCoral;
      final hull = Rect.fromCenter(
        center: center - const Offset(10, 31),
        width: 95,
        height: 83,
      );
      final base = Paint()..color = const Color(0xDE241F2C);
      canvas.drawPath(
        _duePolygon([
          hull.bottomLeft,
          hull.topLeft + const Offset(6, 18),
          hull.topLeft + const Offset(31, 0),
          hull.topRight - const Offset(23, 0),
          hull.topRight + const Offset(5, 34),
          hull.bottomRight,
        ]),
        base,
      );
      canvas.drawLine(
        hull.bottomLeft,
        hull.bottomRight,
        Paint()
          ..color = color.withValues(alpha: .33)
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        center,
        14,
        Paint()..color = color.withValues(alpha: .18),
      );
      canvas.drawCircle(
        center,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = color,
      );
      canvas.drawCircle(center, 2.8, Paint()..color = color);
    }
  }

  void _body(Canvas canvas, _Body body) {
    final box = body.box;
    final type = body.spec.material;
    if (body.lost) {
      if (body.spec.recall) {
        _corners(
          canvas,
          Rect.fromCenter(center: body.spec.at, width: 44, height: 44),
          Paint()
            ..color = _dueBlue.withValues(alpha: .45)
            ..strokeWidth = 1.6,
          7,
        );
      }
      return;
    }
    if (body.spec.rail case final rail?) {
      if (rail.width <= 1 && rail.height > 20) {
        final left = body.at.dx - body.spec.size.width / 2 - 5;
        final right = body.at.dx + body.spec.size.width / 2 + 5;
        final track = Paint()
          ..color = _dueBlue.withValues(alpha: .31)
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(left, rail.top),
          Offset(left, rail.bottom),
          track,
        );
        canvas.drawLine(
          Offset(right, rail.top),
          Offset(right, rail.bottom),
          track,
        );
      }
    }
    final color = switch (body.gravity) {
      _Gravity.give => _dueGold,
      _Gravity.take => _dueBlue,
      _Gravity.normal =>
        body.caught
            ? _dueMint
            : switch (type) {
                _Material.float => _dueBlue,
                _Material.guard ||
                _Material.heavy ||
                _Material.drone => _dueCoral,
                _Material.metal || _Material.pulse => const Color(0xFFC3ACE2),
                _ => theme.rim,
              },
    };
    final trim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: .91);
    if (type == _Material.pulse) {
      _drawDueGem(canvas, body.at, box.width / 2, color);
    } else {
      final frame = RRect.fromRectAndRadius(
        box,
        Radius.circular(type == _Material.float ? 11 : 5),
      );
      canvas.drawRRect(
        frame,
        Paint()..color = Color.lerp(const Color(0xFF23202D), color, .26)!,
      );
      canvas.drawRRect(frame, trim);
      if (type.enemy) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: box.center,
              width: box.width * .66,
              height: 9,
            ),
            const Radius.circular(4),
          ),
          Paint()..color = _dueInk,
        );
        canvas.drawCircle(
          box.center + Offset(body.patrol * 5, 0),
          3.6,
          Paint()..color = color,
        );
        if (body.brace > 0 && body.gravity != _Gravity.take) {
          _corners(
            canvas,
            box.inflate(4),
            Paint()
              ..color = _dueCream.withValues(alpha: .45)
              ..strokeWidth = 1.5,
            5,
          );
        }
      } else {
        canvas.drawRect(
          box.deflate(6),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = color.withValues(alpha: .35),
        );
        final weighted =
            body.gravity == _Gravity.give ||
            (body.gravity == _Gravity.normal && type.massive);
        canvas.drawCircle(box.center, weighted ? 6 : 4, Paint()..color = color);
      }
    }
    if (body.gravity != _Gravity.normal && !body.caught) {
      final sign = body.gravity == _Gravity.give ? 1.0 : -1.0;
      final where = body.at + Offset(0, sign * (box.height / 2 + 10));
      final opacity = body.timer < .3 ? .48 : .9;
      _arrow(
        canvas,
        where - Offset(0, sign * 5),
        where + Offset(0, sign * 6),
        color.withValues(alpha: opacity),
        2.5,
      );
    }
    if (run.target == body && !run.self && !body.caught) {
      final valid = run.valid(body);
      final selected = valid ? (contrast ? Colors.white : _dueGold) : _dueCoral;
      final ready = Paint()
        ..color = selected
        ..strokeWidth = contrast ? 3.5 : 2.5;
      _corners(canvas, box.inflate(6), ready, 10);
      paintGameText(
        canvas,
        body.spec.label,
        box.topCenter - const Offset(0, 26),
        14,
        selected,
        align: TextAlign.center,
        bold: true,
        glowColor: _dueInk,
      );
    }
  }

  void _avatar(Canvas canvas) {
    final box = run.playerBox;
    final active = run.grace == 0 || reduced || (run.grace * 14).floor().isEven;
    final alpha = active ? 1.0 : .53;
    final cloak = Paint()
      ..color = const Color(0xFFCF9667).withValues(alpha: alpha);
    final pale = Paint()..color = _dueCream.withValues(alpha: alpha);
    final dark = Paint()
      ..color = const Color(0xFF231D2B).withValues(alpha: alpha);
    final visor = Rect.fromCenter(
      center: box.center + Offset(run.facing * 3, -11),
      width: 16,
      height: 6,
    );
    canvas.drawPath(
      _duePolygon([
        box.bottomLeft + const Offset(-3, -3),
        box.topLeft + const Offset(3, 14),
        box.topRight + const Offset(-3, 14),
        box.bottomRight + const Offset(3, -2),
      ]),
      cloak,
    );
    _dueRounded(
      canvas,
      Rect.fromLTWH(box.left + 3, box.top, box.width - 6, 23),
      7,
      pale,
    );
    _dueRounded(canvas, visor, 2, dark);
    canvas.drawCircle(
      visor.center + Offset(run.facing * 3, 0),
      2.0,
      Paint()..color = _dueMint,
    );
    canvas.drawRect(Rect.fromLTWH(box.left + 5, box.bottom - 5, 6, 5), dark);
    canvas.drawRect(Rect.fromLTWH(box.right - 11, box.bottom - 5, 6, 5), dark);
    if (run.self) {
      _corners(
        canvas,
        box.inflate(7),
        Paint()
          ..color = _dueMint
          ..strokeWidth = 2.5,
        9,
      );
    }
  }

  void _castEffect(Canvas canvas) {
    if (run.arcTarget case final at? when run.arcTime > 0) {
      final color = run.arcGravity == _Gravity.give ? _dueGold : _dueBlue;
      final alpha = (run.arcTime / .23).clamp(0.0, 1.0);
      canvas.drawCircle(
        at,
        21 + (reduced ? 0 : (1 - alpha) * 16),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = color.withValues(alpha: alpha),
      );
      if (!reduced && (run.player - at).distance > 12) {
        final mid = Offset(
          (run.player.dx + at.dx) * .5,
          (run.player.dy + at.dy) * .5 - 21,
        );
        final arc = Path()
          ..moveTo(run.player.dx, run.player.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, at.dx, at.dy);
        canvas.drawPath(
          arc,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.7
            ..color = color.withValues(alpha: alpha * .8),
        );
      }
    }
  }

  void _caption(Canvas canvas) {
    paintGameText(
      canvas,
      run.room.title.toUpperCase(),
      const Offset(26, 30),
      23,
      _dueCream,
      bold: true,
      letterSpacing: 2,
      glowColor: _dueInk,
    );
    paintGameText(
      canvas,
      run.opened
          ? 'EXIT OPEN'
          : (run.room.boss == null ? 'ROUTE LOCKED' : 'WEAK POINT ACTIVE'),
      const Offset(934, 34),
      13,
      run.opened ? _dueMint : _dueGold,
      align: TextAlign.right,
      bold: true,
      letterSpacing: 1.4,
      glowColor: _dueInk,
    );
    final bar = const Rect.fromLTWH(824, 58, 110, 4);
    canvas.drawRect(bar, Paint()..color = Colors.white24);
    canvas.drawRect(
      Rect.fromLTWH(
        bar.left,
        bar.top,
        bar.width * (1 - run.cooldown / .35).clamp(0, 1),
        bar.height,
      ),
      Paint()..color = _dueMint,
    );
  }

  static void _corners(Canvas canvas, Rect rect, Paint paint, double length) {
    for (final (point, x, y) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomLeft, 1.0, -1.0),
      (rect.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(point, point + Offset(x * length, 0), paint);
      canvas.drawLine(point, point + Offset(0, y * length), paint);
    }
  }

  static void _arrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
    double thickness,
  ) {
    final delta = to - from;
    if (delta.distanceSquared <= 1) return;
    final forward = delta / delta.distance;
    final side = Offset(-forward.dy, forward.dx);
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    canvas.drawLine(to, to - forward * 5 + side * 3, paint);
    canvas.drawLine(to, to - forward * 5 - side * 3, paint);
  }

  @override
  bool shouldRepaint(covariant _StoryPainter oldDelegate) => true;
}
