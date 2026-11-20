part of 'future_debt_game.dart';

extension on _FuturePainter {
  void _hound(
    Canvas canvas,
    Offset foot,
    Offset aim,
    double size,
    double stride, {
    double hurt = 0,
    bool echo = false,
  }) {
    final coat = echo ? _futureLilac : const Color(0xFFDF6545);
    final dark = echo ? const Color(0xFF533A75) : const Color(0xFF67313D);
    final lit = Color.lerp(coat, _futureCream, .45 + hurt * .45)!;

    canvas.save();
    canvas.translate(foot.dx, foot.dy - 5);
    canvas.rotate(math.atan2(aim.dy, aim.dx));
    final tail = Path()
      ..moveTo(-size * .67, 0)
      ..quadraticBezierTo(
        -size * 1.25,
        math.sin(stride) * size * .4,
        -size * 1.43,
        -size * .34,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size * .23,
    );
    for (final side in [-1, 1]) {
      for (final end in [-1, 1]) {
        final swing = math.sin(stride + (side == end ? 0 : math.pi)) * .22;
        final paw = Rect.fromCenter(
          center: Offset(size * (end * .54 + swing), size * side * .54),
          width: size * .48,
          height: size * .37,
        );
        _arenaRound(canvas, paw, 3, _arenaClay(paw, [coat, dark]));
      }
    }
    final body = Rect.fromCenter(
      center: Offset(-size * .30, 0),
      width: size * 1.46,
      height: size * .97,
    );
    canvas.drawOval(body, _arenaClay(body, [lit, coat, dark]));

    for (final side in [-1, 1]) {
      final ear = _arenaShape([
        Offset(size * .22, side * size * .30),
        Offset(-size * .30, side * size * .80),
        Offset(size * .85, side * size * .51),
      ]);
      canvas.drawPath(ear, _arenaClay(ear.getBounds(), [lit, coat, dark]));
    }
    final head = Rect.fromCenter(
      center: Offset(size * .61, 0),
      width: size * 1.20,
      height: size * 1.04,
    );
    canvas.drawOval(head, _arenaClay(head, [lit, coat, dark]));
    final snout = Rect.fromCenter(
      center: Offset(size * 1.03, 0),
      width: size * .65,
      height: size * .49,
    );
    _arenaRound(canvas, snout, 3.8, _arenaClay(snout, [lit, dark]));
    canvas.drawCircle(
      Offset(size * 1.32, 0),
      size * .14,
      Paint()..color = _futureInk,
    );
    for (final side in [-1, 1]) {
      canvas.drawCircle(
        Offset(size * .80, side * size * .33),
        size * .12,
        Paint()..color = _futureCream,
      );
    }
    canvas.restore();
  }

  void _auditor(
    Canvas canvas,
    Offset foot,
    Offset aim,
    double size,
    double stride,
    double muzzle, {
    double hurt = 0,
  }) {
    const coat = Color(0xFF3F7186);
    final shade = Color.lerp(coat, _futureInk, .78)!;
    final seam = Color.lerp(coat, _futureCream, .38 + hurt * .5)!;
    final step = math.sin(stride);
    canvas.save();
    canvas.translate(foot.dx, foot.dy);
    canvas.rotate(step * .045);
    for (final side in [-1, 1]) {
      final boot = Rect.fromCenter(
        center: Offset(side * size * .30, step * side * size * .14),
        width: size * .45,
        height: size * .50,
      );
      _arenaRound(canvas, boot, 2.5, _arenaClay(boot, [coat, shade]));
    }
    final jacket = _arenaShape([
      Offset(-size * .46, -size * 1.49),
      Offset(size * .46, -size * 1.49),
      Offset(size * .82, -size * .31),
      Offset(size * .15, -size * .21),
      Offset(0, -size * .40),
      Offset(-size * .23, -size * .21),
      Offset(-size * .82, -size * .33),
    ]);
    canvas.drawPath(
      jacket,
      _arenaClay(jacket.getBounds(), [seam, coat, shade]),
    );
    canvas.drawLine(
      Offset(0, -size * 1.27),
      Offset(0, -size * .47),
      Paint()
        ..color = _futureGold
        ..strokeWidth = 1.5,
    );
    _blaster(canvas, aim, size * 1.13, muzzle, false);

    final face = Rect.fromCenter(
      center: Offset(aim.dx * size * .12, -size * 1.63),
      width: size * 1.02,
      height: size * .69,
    );
    _arenaRound(canvas, face, size * .19, _arenaClay(face, [seam, shade]));
    final visor = Rect.fromCenter(
      center: face.center.translate(aim.dx * 2, 1),
      width: size * .74,
      height: size * .15,
    );
    _arenaRound(canvas, visor, 2, Paint()..color = _futureGold);
    final brim = Rect.fromCenter(
      center: Offset(aim.dx * 2, -size * 1.98),
      width: size * 2.04,
      height: size * .51,
    );
    canvas.drawOval(brim, _arenaLinear(brim, [seam, coat, shade]));
    final crown = Rect.fromCenter(
      center: brim.center.translate(0, -size * .29),
      width: size * 1.16,
      height: size * .54,
    );
    _arenaRound(
      canvas,
      crown,
      size * .12,
      _arenaClay(crown, [seam, coat, shade]),
    );
    canvas.drawLine(
      crown.bottomLeft + const Offset(2, -1),
      crown.bottomRight + const Offset(-2, -1),
      Paint()
        ..color = _futureGold
        ..strokeWidth = 1.7,
    );
    canvas.restore();
  }

  void _leech(
    Canvas canvas,
    Offset foot,
    Offset aim,
    double size, {
    double hurt = 0,
    bool charging = false,
  }) {
    final phase = game.time * 5 + foot.dx * .025;
    final bob = math.sin(phase) * size * .19;
    const skin = Color(0xFF6ECCAB);
    const shade = Color(0xFF244950);
    final light = Color.lerp(skin, _futureCream, .55 + hurt * .4)!;
    canvas.save();
    canvas.translate(foot.dx, foot.dy - size * .79 + bob);
    if (charging) {
      final warning = Rect.fromCenter(
        center: Offset(0, size * .80 - bob),
        width: size * (2.8 + math.sin(phase * 3) * .35),
        height: size * 1.60,
      );
      canvas.drawOval(
        warning,
        Paint()
          ..color = _futureGold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
    for (var i = -1; i <= 1; i++) {
      final ripple = math.sin(phase + i);
      final arm = Path()
        ..moveTo(i * size * .42, size * .13)
        ..cubicTo(
          (i * .67 + ripple * .26) * size,
          size * .32,
          (i * .35 - ripple * .25) * size,
          size * .79,
          (i * .72 - ripple * .30) * size,
          size * 1.05,
        );
      canvas.drawPath(
        arm,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shade, skin.withValues(alpha: .49)],
          ).createShader(arm.getBounds().inflate(1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * .24
          ..strokeCap = StrokeCap.round,
      );
    }
    final bell = Rect.fromCenter(
      center: Offset.zero,
      width: size * 2.06,
      height: size * 1.60,
    );
    canvas.drawOval(bell, _arenaClay(bell, [light, skin, shade]));
    final eye = Rect.fromCenter(
      center: aim * (size * .20),
      width: size * .90,
      height: size * .61,
    );
    canvas.drawOval(eye, _arenaClay(eye, [_futureCream, skin, shade]));
    _arenaRound(
      canvas,
      Rect.fromCenter(
        center: eye.center,
        width: size * .24,
        height: size * .51,
      ),
      size * .10,
      Paint()..color = _futureInk,
    );
    canvas.restore();
  }

  void _bailiff(
    Canvas canvas,
    Offset foot,
    Offset aim,
    double size,
    double stride, {
    double hurt = 0,
    bool collector = false,
    double muzzle = 0,
  }) {
    final shell = collector ? const Color(0xFF97557D) : const Color(0xFF9D7366);
    final shadow = collector
        ? const Color(0xFF302039)
        : const Color(0xFF493B4A);
    final light = Color.lerp(shell, _futureCream, .54 + hurt * .39)!;
    final step = math.sin(stride);
    canvas.save();
    canvas.translate(foot.dx, foot.dy);
    final armor = Rect.fromCenter(
      center: Offset(0, -size * .61),
      width: size * 1.73,
      height: size * 1.29,
    );
    for (final side in [-1, 1]) {
      final boot = Rect.fromCenter(
        center: Offset(side * size * .44, step * side * size * .16),
        width: size * .57,
        height: size * .47,
      );
      _arenaRound(canvas, boot, 4, _arenaLinear(boot, [shell, shadow]));
    }
    _arenaRound(
      canvas,
      armor,
      size * .18,
      _arenaLinear(armor, [light, shell, shadow]),
    );
    for (final side in [-1, 1]) {
      final fist = Rect.fromCenter(
        center: Offset(side * size * .87, -size * (.65 + step * side * .15)),
        width: size * .65,
        height: size * .86,
      );
      _arenaRound(
        canvas,
        fist,
        size * .16,
        _arenaLinear(fist, [light, shell, shadow]),
      );
      canvas.drawLine(
        fist.topLeft + const Offset(3, 4),
        fist.topRight + const Offset(-4, 4),
        Paint()
          ..color = _futureGold.withValues(alpha: .70)
          ..strokeWidth = 2.0,
      );
    }
    if (collector) _blaster(canvas, aim, size * 1.05, muzzle, false);
    final helm = Rect.fromCenter(
      center: Offset(aim.dx * size * .12, -size * 1.35),
      width: size * 1.10,
      height: size * .78,
    );
    if (collector) {
      for (final side in [-1, 1]) {
        final horn = _arenaShape([
          helm.topCenter.translate(side * size * .34, size * .20),
          helm.topCenter.translate(side * size * .84, -size * .65),
          helm.topCenter.translate(side * size * .52, -size * .44),
          helm.topCenter.translate(side * size * .08, size * .12),
        ]);
        canvas.drawPath(
          horn,
          _arenaLinear(horn.getBounds(), [_futureGold, shell]),
        );
      }
    }
    _arenaRound(
      canvas,
      helm,
      size * .17,
      _arenaLinear(helm, [light, shell, shadow]),
    );
    final slit = Rect.fromCenter(
      center: helm.center.translate(aim.dx * 2, 1),
      width: size * .78,
      height: size * .20,
    );
    _arenaRound(canvas, slit, 2, Paint()..color = _futureInk);
    canvas.drawLine(
      slit.centerLeft.translate(3, 0),
      slit.centerRight.translate(-3, 0),
      Paint()
        ..color = collector ? _futureLilac : _futureCoral
        ..strokeWidth = 1.75,
    );
    canvas.restore();
  }
}
