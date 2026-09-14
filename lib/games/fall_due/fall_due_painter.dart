part of 'fall_due_game.dart';

class _FallPainter extends CustomPainter {
  _FallPainter(this.game);
  final _FallDueGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = LogicalViewport.fit(
      size,
      const Size(_FallDueGame.viewWidth, _FallDueGame.viewHeight),
    );
    canvas.drawColor(const Color(0xFF060910), BlendMode.src);
    canvas.save();
    viewport.applyTo(canvas);
    final view = const Rect.fromLTWH(
      0,
      0,
      _FallDueGame.viewWidth,
      _FallDueGame.viewHeight,
    );

    // 1. Deep Space / Cyber-Nebula Background
    canvas.drawRect(
      view,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C1424),
            Color(0xFF080D18),
            Color(0xFF04060C),
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(view),
    );

    // Multi-layered Parallax Skyline & Cyber Atmosphere
    _drawSkyline(canvas);

    canvas.save();
    canvas.translate(-game.camera, 0);
    final worldView = Rect.fromLTWH(
      game.camera - 80,
      -80,
      _FallDueGame.viewWidth + 160,
      _FallDueGame.viewHeight + 160,
    );

    // 2. High-Tech Composite Girders & Platforms
    for (final platform in game.platforms) {
      if (!worldView.overlaps(platform)) continue;
      _drawPlatform(canvas, platform);
    }

    // 3. Route Section Checkpoint Holograms
    for (final section in game.routeSections) {
      if (section.start < worldView.left - 220 ||
          section.start > worldView.right + 20) {
        continue;
      }
      _drawSectionMarker(canvas, section);
    }

    // 4. Interactive Environment Hazards & Objectives
    for (final panel in game.weakPanels) {
      if (!worldView.overlaps(panel.rect)) continue;
      _drawWeakPanel(canvas, panel);
    }

    for (final pad in game.safeDebtPads) {
      if (!worldView.overlaps(pad.rect)) continue;
      _drawSafeDebtPad(canvas, pad);
    }

    for (var index = 0; index < game.spikes.length; index++) {
      if (!worldView.overlaps(game.spikes[index])) continue;
      if (game.disabledSpikes.contains(index)) {
        _drawSealedSpikes(canvas, game.spikes[index]);
      } else {
        _drawSpikes(canvas, game.spikes[index]);
      }
    }

    if (worldView.overlaps(game.exit)) _drawExit(canvas);

    for (final seal in game.seals) {
      if (!worldView.contains(seal.position)) continue;
      _drawSeal(canvas, seal);
    }

    for (final checkpoint in game.checkpoints) {
      if (!worldView.contains(checkpoint.position)) continue;
      _drawCheckpoint(canvas, checkpoint);
    }

    for (final gate in game.gates) {
      if (!worldView.overlaps(gate.rect)) continue;
      _drawGate(canvas, gate);
    }

    for (final lever in game.levers) {
      if (!worldView.contains(lever.position)) continue;
      _drawLever(canvas, lever);
    }

    for (final emitter in game.emitters) {
      if (!worldView.contains(emitter.position)) continue;
      _drawEmitter(canvas, emitter);
    }

    for (final target in game.targets) {
      if (!worldView.overlaps(target.rect)) continue;
      _drawTarget(canvas, target);
    }

    // 5. Plasma Bullets & Trail FX
    for (final bullet in game.bullets) {
      if (!worldView.overlaps(bullet.rect)) continue;
      _drawBullet(canvas, bullet);
    }

    // 6. Dynamic Ambient & Impact Particles
    for (final particle in game.particles) {
      if (!worldView.contains(particle.position)) continue;
      final alpha = (particle.life / 0.8).clamp(0.0, 1.0);
      canvas.drawCircle(
        particle.position,
        3.2 * alpha + 0.8,
        Paint()
          ..color = particle.color.withValues(alpha: alpha * 0.9)
          ..blendMode = BlendMode.screen,
      );
      canvas.drawCircle(
        particle.position,
        1.5,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    // 6b. Dynamic Gravitational Shockwaves
    for (final wave in game.shockwaves) {
      if (!worldView.contains(wave.position)) continue;
      _drawShockwave(canvas, wave);
    }

    // 7. Quantum Gravity Siphon Tether
    final nearestTarget = game._nearestTarget();
    final nearestEmitter = game._nearestEmitter();
    final emitterIsCloser = game._emitterIsCloser(
      nearestTarget,
      nearestEmitter,
    );
    final recipient = emitterIsCloser
        ? nearestEmitter?.position
        : nearestTarget?.center;

    if (recipient != null) {
      _drawQuantumTether(canvas, game.player.center, recipient);
    }

    // 8. Player Rendering (Cyber-Astronaut)
    _drawPlayerWithEffects(canvas);

    canvas.restore();

    // 9. Cyberpunk Telemetry HUD
    _drawDebtMeter(canvas);

    canvas.restore();
  }

  // --- PARALLAX MEGAPOLIS SKYLINE & NEBULA ---
  void _drawSkyline(Canvas canvas) {
    final time = game.time;

    // A. Cosmic Starfield & Gravity Dust
    for (var index = 0; index < 50; index++) {
      final x = (index * 73.0 + 19) % _FallDueGame.viewWidth;
      final y = 20.0 + (index * 41 % 240);
      final twinkle = (math.sin(time * 2.5 + index * 1.7) + 1.0) * 0.5;
      final isMajor = index % 7 == 0;
      final starColor = isMajor
          ? const Color(0xFF9FE7FF)
          : (index % 3 == 0 ? const Color(0xFFFFE599) : const Color(0xFF7E9DCB));

      canvas.drawCircle(
        Offset(x, y),
        isMajor ? 1.8 : 0.9,
        Paint()..color = starColor.withValues(alpha: 0.25 + twinkle * 0.55),
      );
      if (isMajor) {
        // Cross flare on bright stars
        final flarePaint = Paint()
          ..color = starColor.withValues(alpha: 0.15 + twinkle * 0.25)
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), flarePaint);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), flarePaint);
      }
    }

    // B. Distant Nebula Clouds (Deep Parallax)
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1E3A68).withValues(alpha: 0.18),
          const Color(0xFF321A52).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: const Offset(_FallDueGame.viewWidth * 0.65, 140),
          radius: 220,
        ),
      );
    canvas.drawCircle(
      const Offset(_FallDueGame.viewWidth * 0.65, 140),
      220,
      nebulaPaint,
    );

    // C. Distant Megastructures (Parallax 0.06)
    final distantBuildingPaint = Paint()..color = const Color(0xFF0D1424);
    for (var i = 0; i < 16; i++) {
      final bx = ((i * 135 - game.camera * 0.06) % 2160) - 120;
      final bh = 140.0 + (i * 37 % 160);
      final bw = 70.0 + (i % 3) * 24.0;
      final bRect = Rect.fromLTWH(bx, 440 - bh, bw, bh);
      canvas.drawRect(bRect, distantBuildingPaint);

      // Flashing red aviation warning beacon on tower apex
      if (i % 2 == 0) {
        final beaconFlash = math.sin(time * 4.0 + i) > 0.4 ? 0.9 : 0.1;
        canvas.drawCircle(
          Offset(bx + bw * 0.5, 440 - bh),
          2.0,
          Paint()..color = const Color(0xFFFF3355).withValues(alpha: beaconFlash),
        );
      }
    }

    // D. Mid-ground Cyber Towers (Parallax 0.16) with Glowing Windows & Light Beams
    final midBuildingPaint = Paint()..color = const Color(0xFF131D32);
    final roofTrimPaint = Paint()
      ..color = const Color(0xFF2E456B)
      ..strokeWidth = 2.0;

    for (var i = 0; i < 14; i++) {
      final bx = ((i * 160 - game.camera * 0.16) % 2240) - 100;
      final bh = 80.0 + (i * 47 % 190);
      final bw = 84.0 + (i % 2) * 28.0;
      final bRect = Rect.fromLTWH(bx, 440 - bh, bw, bh);

      // Building silhouette
      canvas.drawRect(bRect, midBuildingPaint);
      canvas.drawLine(bRect.topLeft, bRect.topRight, roofTrimPaint);

      // Window grid matrix (cyan / amber data centers) - steady ambient lights
      final winColor = (i % 3 == 0)
          ? const Color(0xFF48F2C1)
          : (i % 2 == 0 ? const Color(0xFF75DFFF) : const Color(0xFFFFD36A));
      final winPaint = Paint()..color = winColor.withValues(alpha: 0.18);

      final cols = ((bw - 24) / 16).floor();
      final rows = ((bh - 34) / 22).floor();
      for (var row = 0; row < rows; row++) {
        final wy = bRect.top + 14 + row * 22;
        for (var col = 0; col < cols; col++) {
          final wx = bRect.left + 12 + col * 16;
          // Deterministic pattern locked to building structure
          if ((col * 7 + row * 11 + i * 13) % 7 < 3) {
            canvas.drawRect(Rect.fromLTWH(wx, wy, 8, 12), winPaint);
          }
        }
      }

      // Vertical Skyward Searchlight Beams on select buildings
      if (i % 4 == 1) {
        final beamAngle = math.sin(time * 0.7 + i) * 0.25;
        final beamPath = Path()
          ..moveTo(bx + bw * 0.5 - 2, 440 - bh)
          ..lineTo(bx + bw * 0.5 + 2, 440 - bh)
          ..lineTo(bx + bw * 0.5 + 45 + math.tan(beamAngle) * 280, 0)
          ..lineTo(bx + bw * 0.5 - 45 + math.tan(beamAngle) * 280, 0)
          ..close();
        canvas.drawPath(
          beamPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF6DE8FF).withValues(alpha: 0.14),
                Colors.transparent,
              ],
            ).createShader(Rect.fromLTWH(bx - 50, 0, bw + 100, 440)),
        );
      }
    }

    // E. Foreground Atmospheric Haze Ribbon
    final hazeRect = const Rect.fromLTWH(0, 320, _FallDueGame.viewWidth, 140);
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0x2213233D),
            Color(0x350A101C),
          ],
        ).createShader(hazeRect),
    );
  }

  // --- HIGH-TECH MODULAR PLATFORMS ---
  void _drawPlatform(Canvas canvas, Rect platform) {
    // 1. Drop shadow beneath platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        platform.shift(const Offset(0, 5)),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xAA02050B),
    );

    // 2. High-tech composite metal slab body
    final slab = RRect.fromRectAndRadius(platform, const Radius.circular(4));
    canvas.drawRRect(
      slab,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF283A54),
            Color(0xFF1A273C),
            Color(0xFF101928),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(platform),
    );

    // 3. Neon energy conduit top-rail (glowing blue/cyan rim)
    final topRail = Rect.fromLTWH(platform.left, platform.top, platform.width, 4.5);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        topRail,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9DEFFF), Color(0xFF5AB6FF), Color(0xFF9DEFFF)],
        ).createShader(topRail),
    );

    // Soft glow line beneath top-rail
    canvas.drawLine(
      Offset(platform.left + 2, platform.top + 6),
      Offset(platform.right - 2, platform.top + 6),
      Paint()
        ..color = const Color(0xFF6DE8FF).withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );

    // 4. Industrial panel seam dividing lines
    final seamPaint = Paint()
      ..color = const Color(0xFF0D1420)
      ..strokeWidth = 1.4;
    const panelWidth = 72.0;
    for (var px = platform.left + panelWidth; px < platform.right - 10; px += panelWidth) {
      canvas.drawLine(
        Offset(px, platform.top + 5),
        Offset(px, platform.bottom - 4),
        seamPaint,
      );
      // Small cyber bolt/rivet along seam
      canvas.drawCircle(
        Offset(px, platform.top + 10),
        1.5,
        Paint()..color = const Color(0xFF4A6588),
      );
    }

    // 5. Caution hazard diagonal stripes on wide platforms
    if (platform.width >= 120 && platform.height >= 24) {
      final hazardWidth = math.min(36.0, platform.width * 0.18);
      final hazardRect = Rect.fromLTWH(
        platform.right - hazardWidth - 6,
        platform.top + 9,
        hazardWidth,
        platform.height - 15,
      );
      canvas.save();
      canvas.clipRect(hazardRect);
      canvas.drawRect(hazardRect, Paint()..color = const Color(0xFF121B29));
      final stripePaint = Paint()
        ..color = const Color(0xFFFFD36A).withValues(alpha: 0.65)
        ..strokeWidth = 2.5;
      for (var sx = hazardRect.left - 20; sx < hazardRect.right + 20; sx += 7) {
        canvas.drawLine(
          Offset(sx, hazardRect.bottom + 2),
          Offset(sx + 8, hazardRect.top - 2),
          stripePaint,
        );
      }
      canvas.restore();
    }

    // 6. Lower structural beveled edge & industrial truss brackets
    canvas.drawRect(
      Rect.fromLTWH(platform.left, platform.bottom - 5, platform.width, 5),
      Paint()..color = const Color(0xFF090E18),
    );

    // Platform outer stroke
    canvas.drawRRect(
      slab,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFF4D6E96).withValues(alpha: 0.45),
    );
  }

  // --- ROUTE SECTION MARKER HOLOGRAM ---
  void _drawSectionMarker(Canvas canvas, _DueSectionSpec section) {
    final rect = Rect.fromLTWH(section.start + 12, 70, 215, 48);

    // Holographic glass backing
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF102845).withValues(alpha: 0.88),
            const Color(0xFF081424).withValues(alpha: 0.94),
          ],
        ).createShader(rect),
    );

    // Glowing cyan neon boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF6DE8FF).withValues(alpha: 0.85),
    );

    // Vertical holographic energy beacon line to ground
    canvas.drawLine(
      Offset(rect.left + 20, rect.bottom),
      Offset(rect.left + 20, 420),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6DE8FF).withValues(alpha: 0.8),
            const Color(0xFF6DE8FF).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(rect.left, rect.bottom, 4, 350))
        ..strokeWidth = 1.8,
    );

    // Status indicator beacon orb
    canvas.drawCircle(
      rect.topLeft + const Offset(20, 24),
      7,
      Paint()..color = const Color(0xFFFFD36A),
    );
    canvas.drawCircle(
      rect.topLeft + const Offset(20, 24),
      13,
      Paint()..color = const Color(0xFFFFD36A).withValues(alpha: 0.25),
    );

    paintGameText(
      canvas,
      'SECTION // CHECKPOINT',
      rect.topLeft + const Offset(36, 8),
      8,
      const Color(0xFF8DE1FF),
      bold: true,
      letterSpacing: 1.4,
    );

    paintGameText(
      canvas,
      section.title,
      rect.topLeft + const Offset(36, 23),
      12,
      const Color(0xFFF0F8FF),
      bold: true,
      letterSpacing: 0.8,
    );
  }

  // --- WEAK NANO-ALLOY PANELS ---
  void _drawWeakPanel(Canvas canvas, _DueWeakPanel panel) {
    if (panel.broken) {
      // Disintegrated fractured state: fading embers and energy arcs
      final crackPaint = Paint()
        ..color = const Color(0xFFFF7B38).withValues(alpha: 0.7)
        ..strokeWidth = 2.0;
      canvas.drawLine(panel.rect.topLeft, panel.rect.bottomRight, crackPaint);
      canvas.drawLine(panel.rect.bottomLeft, panel.rect.topRight, crackPaint);
      for (var i = 0; i < 4; i++) {
        final sparkOffset = Offset(
          panel.rect.left + (i * 13) % panel.rect.width,
          panel.rect.top + (i * 7) % panel.rect.height,
        );
        canvas.drawCircle(
          sparkOffset,
          1.8,
          Paint()..color = const Color(0xFFFFC04D).withValues(alpha: 0.6),
        );
      }
      return;
    }

    // High-tech fragile nano-alloy panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel.rect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF4A2B15),
    );

    // Glowing orange thermal stress fracture lines
    final stressPaint = Paint()
      ..color = const Color(0xFFFF9540)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      panel.rect.topLeft + const Offset(10, 2),
      panel.rect.center,
      stressPaint,
    );
    canvas.drawLine(
      panel.rect.center,
      panel.rect.bottomRight - const Offset(10, 2),
      stressPaint,
    );
    canvas.drawLine(
      panel.rect.bottomLeft + const Offset(8, -2),
      panel.rect.center,
      stressPaint,
    );

    // Metallic frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel.rect, const Radius.circular(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFD67F38),
    );
  }

  // --- SAFE DEBT BIOLUMINESCENT RECHARGE PADS ---
  void _drawSafeDebtPad(Canvas canvas, _DueSafeDebtPad pad) {
    final active = pad.cooldown <= 0;
    final color = active ? const Color(0xFF52FFB8) : const Color(0xFF339C72);

    // Outer emerald levitation glow
    canvas.drawRect(
      pad.rect.inflate(3),
      Paint()..color = color.withValues(alpha: active ? 0.22 : 0.08),
    );

    // Deep technological dock housing
    canvas.drawRect(pad.rect, Paint()..color = const Color(0xFF09211C));

    // Glowing border frame
    canvas.drawRect(
      pad.rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color,
    );

    // Animated chevron energy flux arrows
    for (var x = pad.rect.left + 8; x < pad.rect.right - 6; x += 14) {
      final chevron = Path()
        ..moveTo(x, pad.rect.bottom - 1)
        ..lineTo(x + 4, pad.rect.top + 2)
        ..lineTo(x + 8, pad.rect.bottom - 1);
      canvas.drawPath(
        chevron,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: active ? 0.9 : 0.4),
      );
    }

    // Rising energy particles when active
    if (active) {
      final pulse = (math.sin(game.time * 6.0) + 1.0) * 0.5;
      final moteX = pad.rect.left + (game.time * 25) % pad.rect.width;
      canvas.drawCircle(
        Offset(moteX, pad.rect.top - 4 - pulse * 6),
        1.8,
        Paint()..color = color.withValues(alpha: 0.8),
      );
    }
  }

  // --- SUPERHEATED THERMAL SPIKES ---
  void _drawSpikes(Canvas canvas, Rect rect) {
    final path = Path();
    final amount = math.max(2, (rect.width / 15).floor());

    // Hazard base rail
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.bottom - 4, rect.width, 4),
      Paint()..color = const Color(0xFF2E0F14),
    );

    for (var index = 0; index < amount; index++) {
      final left = rect.left + rect.width / amount * index;
      final right = rect.left + rect.width / amount * (index + 1);
      final mid = (left + right) / 2;
      path
        ..moveTo(left, rect.bottom)
        ..lineTo(mid, rect.top)
        ..lineTo(right, rect.bottom);
    }

    // Fiery red glowing spike bodies
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: const [
            Color(0xFF6E0D1B),
            Color(0xFFFF2449),
            Color(0xFFFFF0A0), // White-hot plasma tip
          ],
        ).createShader(rect),
    );

    // Heated tip glow halo
    for (var index = 0; index < amount; index++) {
      final mid = rect.left + rect.width / amount * (index + 0.5);
      canvas.drawCircle(
        Offset(mid, rect.top + 2),
        3.5,
        Paint()
          ..color = const Color(0xFFFF5277).withValues(alpha: 0.4)
          ..blendMode = BlendMode.screen,
      );
    }
  }

  void _drawSealedSpikes(Canvas canvas, Rect rect) {
    // Heavy protective bulkhead covering dangerous spikes
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF0F2622),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 4),
      Paint()..color = const Color(0xFF52FFB8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF328F76),
    );
    _text(
      canvas,
      'SHIELDED',
      rect.center + const Offset(0, 3),
      8,
      const Color(0xFFD5FFF1),
      center: true,
      bold: true,
    );
  }

  // --- QUANTUM EXTRACTION GATEWAY (EXIT) ---
  void _drawExit(Canvas canvas) {
    final rect = game.exit;
    final unlocked = game.allObjectivesComplete;
    final accentColor = unlocked ? const Color(0xFF52FFB8) : const Color(0xFF7085A3);
    final coreGlow = unlocked ? const Color(0xFFB8FFE2) : const Color(0xFF889AB5);

    // Archway threshold plate
    final threshold = Rect.fromLTWH(
      rect.left - 18,
      rect.bottom - 6,
      rect.width + 36,
      16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(threshold, const Radius.circular(4)),
      Paint()..color = const Color(0xFF141F30),
    );
    canvas.drawRect(
      Rect.fromLTWH(threshold.left + 4, threshold.top + 2, threshold.width - 8, 3),
      Paint()..color = accentColor,
    );

    // Swirling Portal Field inside the arch
    if (unlocked) {
      final portalRect = rect.deflate(4);
      final spin = game.time * 3.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(portalRect, const Radius.circular(6)),
        Paint()
          ..shader = RadialGradient(
            colors: [
              coreGlow.withValues(alpha: 0.6),
              accentColor.withValues(alpha: 0.3),
              const Color(0xFF08211A),
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(portalRect),
      );

      // Rotating energy vortex arcs
      canvas.save();
      canvas.translate(portalRect.center.dx, portalRect.center.dy);
      canvas.rotate(spin);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = accentColor.withValues(alpha: 0.85);
      canvas.drawCircle(Offset.zero, 16, ringPaint);
      canvas.restore();
    } else {
      // Locked state: dark containment grid
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF131A26),
      );
    }

    // Heavy Gateway Frame Pillars
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = accentColor,
    );

    _text(
      canvas,
      unlocked
          ? 'EXTRACT'
          : game.lockedGates > 0 && game.allSealsCollected
          ? '${game.lockedGates} LOCKS'
          : '${game.collectedSeals}/${game.seals.length} SEALS',
      rect.center + const Offset(0, 5),
      10,
      unlocked ? Colors.white : accentColor,
      center: true,
      bold: true,
    );
  }

  // --- 3D ROTATING HOLOGRAPHIC SEALS ---
  void _drawSeal(Canvas canvas, _DueSeal seal) {
    final collected = seal.collected;
    final color = collected ? const Color(0xFF48687A) : const Color(0xFF52FFB8);
    final coreColor = collected ? const Color(0xFF283B46) : const Color(0xFFC4FFE8);
    final spin = game.time * 2.8;

    canvas.save();
    canvas.translate(seal.position.dx, seal.position.dy);

    if (!collected) {
      // Pulsing outer aura
      final pulse = (math.sin(game.time * 4.0) + 1.0) * 0.5;
      canvas.drawCircle(
        Offset.zero,
        seal.radius + 8 + pulse * 4,
        Paint()..color = color.withValues(alpha: 0.16 + pulse * 0.1),
      );

      // Gyroscopic rotating orbital rings
      canvas.save();
      canvas.rotate(spin);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: seal.radius * 2.6, height: seal.radius * 1.1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: 0.8),
      );
      canvas.restore();

      canvas.save();
      canvas.rotate(-spin * 0.7);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: seal.radius * 1.2, height: seal.radius * 2.4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFF8DE1FF).withValues(alpha: 0.75),
      );
      canvas.restore();

      // Glowing central hyper-diamond core
      final diamond = Path()
        ..moveTo(0, -seal.radius)
        ..lineTo(seal.radius * 0.8, 0)
        ..lineTo(0, seal.radius)
        ..lineTo(-seal.radius * 0.8, 0)
        ..close();
      canvas.drawPath(diamond, Paint()..color = coreColor);
      canvas.drawPath(
        diamond,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color,
      );
    } else {
      // Collected state: dormant tech ring
      canvas.drawCircle(Offset.zero, seal.radius, Paint()..color = color.withValues(alpha: 0.3));
      _text(canvas, 'OK', const Offset(0, 3.5), 8, color, center: true, bold: true);
    }

    canvas.restore();
  }

  // --- QUANTUM TELE-RELAY CHECKPOINT OBELISK ---
  void _drawCheckpoint(Canvas canvas, _DueCheckpoint checkpoint) {
    final base = checkpoint.position + const Offset(14, 37);
    final active = checkpoint.active;
    final color = active ? const Color(0xFF52FFB8) : const Color(0xFF6DE8FF);

    // Skyward beam column when activated
    if (active) {
      final beamRect = Rect.fromLTWH(base.dx - 10, 0, 20, base.dy);
      canvas.drawRect(
        beamRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color.withValues(alpha: 0.45),
              Colors.transparent,
            ],
          ).createShader(beamRect),
      );
    }

    // High-tech transmission spire
    canvas.drawLine(
      base,
      base + const Offset(0, -38),
      Paint()
        ..color = const Color(0xFFCBDDF5)
        ..strokeWidth = 2.5,
    );

    // Floating diamond beacon crystal
    final bob = math.sin(game.time * 3.5) * 3;
    final beaconCenter = base + Offset(0, -44 + bob);

    canvas.drawCircle(
      beaconCenter,
      14,
      Paint()..color = color.withValues(alpha: active ? 0.28 : 0.12),
    );

    final diamond = Path()
      ..moveTo(beaconCenter.dx, beaconCenter.dy - 7)
      ..lineTo(beaconCenter.dx + 6, beaconCenter.dy)
      ..lineTo(beaconCenter.dx, beaconCenter.dy + 7)
      ..lineTo(beaconCenter.dx - 6, beaconCenter.dy)
      ..close();
    canvas.drawPath(diamond, Paint()..color = active ? Colors.white : color);

    _text(
      canvas,
      active ? 'ONLINE' : 'SAVE',
      base + const Offset(0, 14),
      7.5,
      color,
      center: true,
      bold: true,
    );
  }

  // --- QUANTUM POWER LEVER TERMINAL ---
  void _drawLever(Canvas canvas, _DueLever lever) {
    final active = lever.active;
    final color = active ? const Color(0xFF52FFB8) : const Color(0xFF6DE8FF);

    // Ambient glow ring
    canvas.drawCircle(
      lever.position,
      22,
      Paint()..color = color.withValues(alpha: active ? 0.25 : 0.1),
    );

    // Terminal pedestal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: lever.position + const Offset(0, 16), width: 18, height: 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF131D2E),
    );

    // Animated toggle throw arm
    final armAngle = active ? 0.45 : -0.45;
    final armLength = 22.0;
    final pivot = lever.position + const Offset(0, 12);
    final knob = pivot + Offset(math.sin(armAngle) * armLength, -math.cos(armAngle) * armLength);

    canvas.drawLine(
      pivot,
      knob,
      Paint()
        ..color = const Color(0xFFC7D7EE)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(knob, 7.5, Paint()..color = color);
    canvas.drawCircle(knob, 3.5, Paint()..color = Colors.white);

    _text(
      canvas,
      active ? 'LIFT ON' : 'ACTIVATE',
      lever.position + const Offset(0, 32),
      8,
      color,
      center: true,
      bold: true,
    );
  }

  // --- HEAVY HYDRAULIC BLAST GATES ---
  void _drawGate(Canvas canvas, _DueGate gate) {
    final rect = gate.rect;
    final isOpen = gate.open;
    final accentColor = isOpen ? const Color(0xFF52FFB8) : const Color(0xFFFF3355);
    final steelDark = const Color(0xFF111724);
    final steelPlate = const Color(0xFF1E2B3E);

    // Top and bottom hydraulic wall mounts
    final topAnchor = Rect.fromLTWH(rect.left - 4, rect.top - 6, rect.width + 8, 14);
    final bottomAnchor = Rect.fromLTWH(rect.left - 4, rect.bottom - 8, rect.width + 8, 14);

    void drawMount(Rect mount) {
      canvas.drawRRect(RRect.fromRectAndRadius(mount, const Radius.circular(3)), Paint()..color = steelDark);
      canvas.drawRRect(
        RRect.fromRectAndRadius(mount, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF3F5472),
      );
      for (final bx in [mount.left + 5, mount.right - 5]) {
        canvas.drawCircle(Offset(bx, mount.center.dy), 1.8, Paint()..color = const Color(0xFF829BBB));
      }
    }

    drawMount(topAnchor);
    drawMount(bottomAnchor);

    if (isOpen) {
      // Retracted safe guide rails
      canvas.drawRect(Rect.fromLTWH(rect.left + 1, rect.top + 8, 4, rect.height - 16), Paint()..color = steelPlate);
      canvas.drawRect(Rect.fromLTWH(rect.right - 5, rect.top + 8, 4, rect.height - 16), Paint()..color = steelPlate);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accentColor.withValues(alpha: 0.4),
      );
      _text(canvas, 'OPEN', rect.center, 7.5, accentColor, center: true, bold: true);
    } else {
      // Locked barrier with animated electric forcefield lattice
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = steelDark);

      // Warning hazard louvers
      const louverHeight = 16.0;
      final count = ((rect.height - 20) / louverHeight).floor();
      for (var i = 0; i < count; i++) {
        final ly = rect.top + 10 + i * louverHeight;
        final louverRect = Rect.fromLTWH(rect.left + 5, ly, rect.width - 10, louverHeight - 3);
        canvas.drawRRect(RRect.fromRectAndRadius(louverRect, const Radius.circular(2)), Paint()..color = steelPlate);

        // Caution diagonal hazard lines
        final hazardPaint = Paint()
          ..color = const Color(0xFFFFD36A).withValues(alpha: 0.85)
          ..strokeWidth = 2.0;
        for (var hx = louverRect.left - 4; hx < louverRect.right + 4; hx += 8) {
          canvas.drawLine(Offset(hx, louverRect.bottom), Offset(hx + 5, louverRect.top), hazardPaint);
        }
      }

      // Outer energized force barrier border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = accentColor,
      );

      // Center security lock badge
      final badge = Rect.fromCenter(center: rect.center, width: 36, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(badge, const Radius.circular(5)), Paint()..color = const Color(0xFF090E17));
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, const Radius.circular(5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = accentColor,
      );
      _text(canvas, 'LOCKED', badge.center, 7, accentColor, center: true, bold: true);
    }
  }

  // --- INTERACTIVE TARGETS: GRAVITY CRATES & COLLECTOR SENTINELS ---
  void _drawTarget(Canvas canvas, _DueTarget target) {
    final color = target.anchored
        ? const Color(0xFF4F8C78)
        : target.debt < -1
        ? const Color(0xFF62BDE8)
        : switch (target.kind) {
            _TargetKind.heavy => const Color(0xFFFF3B5C),
            _TargetKind.drone => const Color(0xFF4EE4FF),
            _TargetKind.leecher => const Color(0xFFD066FF),
            _TargetKind.enemy => const Color(0xFF9C5EB6),
            _TargetKind.crate => const Color(0xFFD29A43),
            null => const Color(0xFFD29A43),
          };

    if (target.kind == _TargetKind.drone) {
      // --- AERIAL REPULSOR DRONE ---
      final alertColor = target.droneRecoveryTimer > 0
          ? const Color(0xFFFFD86E)
          : target.abilityCooldown < 0.6
          ? const Color(0xFFFF3B5C)
          : const Color(0xFF4EE4FF);

      // Hovering ground shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(target.center.dx, target.rect.bottom + 16),
          width: 24,
          height: 4,
        ),
        Paint()..color = const Color(0x33000000),
      );

      // Stabilizing or pulse charge aura
      if (target.droneRecoveryTimer > 0) {
        final recoverAlpha = (target.droneRecoveryTimer / 1.8).clamp(0.0, 1.0);
        canvas.drawCircle(
          target.center,
          18 + math.sin(game.time * 20) * 3,
          Paint()
            ..color =
                const Color(0xFFFFD86E).withValues(alpha: 0.3 * recoverAlpha),
        );
      } else if (target.abilityCooldown < 0.6) {
        final pulseAlpha =
            (1.0 - target.abilityCooldown / 0.6).clamp(0.0, 1.0);
        canvas.drawCircle(
          target.center,
          22 + pulseAlpha * 8,
          Paint()..color = alertColor.withValues(alpha: 0.25 * pulseAlpha),
        );
      }

      // Twin propulsion thrusters
      final thrusterLeft = Offset(target.x + 8, target.rect.bottom);
      final thrusterRight = Offset(target.rect.right - 8, target.rect.bottom);
      final jetLength = target.droneRecoveryTimer > 0
          ? 3 + math.sin(game.time * 30 + target.x) * 2
          : 5 + math.sin(game.time * 24 + target.x) * 3;
      final jetColor = target.droneRecoveryTimer > 0
          ? const Color(0xFFFFD86E)
          : const Color(0xFF8DE1FF);
      final jetPaint = Paint()..color = jetColor;
      canvas.drawLine(thrusterLeft, thrusterLeft + Offset(0, jetLength), jetPaint..strokeWidth = 2.5);
      canvas.drawLine(thrusterRight, thrusterRight + Offset(0, jetLength), jetPaint..strokeWidth = 2.5);

      // Drone octagonal chassis
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(8)),
        Paint()..color = const Color(0xFF10192A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = alertColor,
      );

      // Central glowing sensor lens
      canvas.drawCircle(target.center, 5.5, Paint()..color = alertColor.withValues(alpha: 0.35));
      canvas.drawCircle(target.center, 3.5, Paint()..color = alertColor);

      // Top antenna
      canvas.drawLine(
        Offset(target.center.dx, target.y),
        Offset(target.center.dx, target.y - 5),
        Paint()
          ..color = alertColor
          ..strokeWidth = 1.4,
      );

      _text(
        canvas,
        target.abilityCooldown < 0.6 ? 'PULSE' : 'DRONE',
        target.center + const Offset(0, -22),
        7,
        alertColor,
        center: true,
        bold: true,
      );
    } else if (target.kind == _TargetKind.heavy) {
      // --- JUGGERNAUT ENFORCER ---
      final alertColor = target.debt > 1
          ? const Color(0xFFFFD86E)
          : const Color(0xFFFF3B5C);

      // Heavy ground shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(target.center.dx, target.rect.bottom + 3),
          width: 38,
          height: 6,
        ),
        Paint()..color = const Color(0x77000000),
      );

      // Armored heavy chassis
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF1C131A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect.deflate(2), const Radius.circular(5)),
        Paint()..color = const Color(0xFF2E1724),
      );

      // Hydraulic shoulder pauldrons
      final leftShoulder = Rect.fromLTWH(target.x - 2, target.y + 4, 8, 14);
      final rightShoulder = Rect.fromLTWH(target.rect.right - 6, target.y + 4, 8, 14);
      final armorPaint = Paint()..color = color;
      canvas.drawRRect(RRect.fromRectAndRadius(leftShoulder, const Radius.circular(3)), armorPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightShoulder, const Radius.circular(3)), armorPaint);

      // Crimson visor slit
      final visor = Rect.fromLTWH(target.x + 8, target.y + 12, target.w - 16, 6);
      canvas.drawRRect(RRect.fromRectAndRadius(visor, const Radius.circular(3)), Paint()..color = const Color(0xFF0F070C));
      canvas.drawLine(
        Offset(visor.left + 2, visor.center.dy),
        Offset(visor.right - 2, visor.center.dy),
        Paint()
          ..color = alertColor
          ..strokeWidth = 2.2,
      );

      // Armor health pips above head
      final pipsTotal = target.maxHealth;
      const pipW = 4.0;
      const pipGap = 2.0;
      final totalPipsWidth = pipsTotal * pipW + (pipsTotal - 1) * pipGap;
      final startPipX = target.center.dx - totalPipsWidth / 2;
      for (var i = 0; i < pipsTotal; i++) {
        final pipRect = Rect.fromLTWH(startPipX + i * (pipW + pipGap), target.y - 12, pipW, 4);
        final pipActive = i < target.health;
        canvas.drawRRect(
          RRect.fromRectAndRadius(pipRect, const Radius.circular(1)),
          Paint()..color = pipActive ? alertColor : const Color(0xFF4A3542),
        );
      }

      _text(
        canvas,
        'ENFORCER',
        target.center + const Offset(0, -22),
        7,
        alertColor,
        center: true,
        bold: true,
      );
    } else if (target.kind == _TargetKind.leecher) {
      // --- SIPHON SPECTRE (LEECHER) ---
      final alertColor = target.debt > 1
          ? const Color(0xFFFFD86E)
          : const Color(0xFFD066FF);

      // Fast shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(target.center.dx, target.rect.bottom + 2),
          width: 22,
          height: 4,
        ),
        Paint()..color = const Color(0x55000000),
      );

      // Ethereal phase body
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(10)),
        Paint()..color = const Color(0xFF1E0A2A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(10)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = alertColor,
      );

      // Glowing core
      canvas.drawCircle(target.center, 5.0, Paint()..color = alertColor);
      canvas.drawCircle(target.center, 2.5, Paint()..color = Colors.white);

      // Energy tendrils
      final sway = math.sin(game.time * 8 + target.x) * 4;
      canvas.drawLine(
        Offset(target.center.dx - 4, target.rect.bottom - 4),
        Offset(target.center.dx - 8 + sway, target.rect.bottom + 8),
        Paint()
          ..color = alertColor.withValues(alpha: 0.6)
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        Offset(target.center.dx + 4, target.rect.bottom - 4),
        Offset(target.center.dx + 8 - sway, target.rect.bottom + 8),
        Paint()
          ..color = alertColor.withValues(alpha: 0.6)
          ..strokeWidth = 1.5,
      );

      _text(
        canvas,
        'LEECHER',
        target.center + const Offset(0, -22),
        7,
        alertColor,
        center: true,
        bold: true,
      );
    } else if (target.kind == _TargetKind.enemy) {
      final alertColor = target.debt < -1
          ? const Color(0xFF8DE1FF)
          : target.debt > 1
          ? const Color(0xFFFFD86E)
          : const Color(0xFFFF7186);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(target.center.dx, target.rect.bottom + 3),
          width: 28,
          height: 5,
        ),
        Paint()..color = const Color(0x66000000),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(8)),
        Paint()..color = color,
      );
      final visor = Rect.fromLTWH(target.x + 5, target.y + 9, 22, 9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(visor, const Radius.circular(4)),
        Paint()..color = const Color(0xFF171223),
      );
      canvas.drawCircle(
        Offset(target.x + 11, target.y + 13.5),
        2,
        Paint()..color = const Color(0xFFFFA0B5),
      );
      canvas.drawCircle(
        Offset(target.x + 21, target.y + 13.5),
        2,
        Paint()..color = const Color(0xFFFFA0B5),
      );
      canvas.drawLine(
        Offset(target.center.dx, target.y + 4),
        Offset(target.center.dx + 4, target.y),
        Paint()
          ..color = const Color(0xFFE5D9FF)
          ..strokeWidth = 1.2,
      );
      final warning = target.center + const Offset(0, -16);
      canvas.drawCircle(
        warning,
        12,
        Paint()..color = alertColor.withValues(alpha: .22),
      );
      canvas.drawCircle(warning, 6, Paint()..color = alertColor);
      _text(
        canvas,
        '!',
        warning + const Offset(0, -5),
        9,
        const Color(0xFF111725),
        center: true,
        bold: true,
      );
      _text(
        canvas,
        'COLLECTOR',
        target.center + const Offset(0, -34),
        7,
        alertColor,
        center: true,
        bold: true,
      );
    } else {
      // Industrial reinforced heavy gravity crate
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF1F180F),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect.deflate(2), const Radius.circular(3)),
        Paint()..color = color,
      );

      // Industrial hazard warning stripes across middle
      canvas.save();
      final hazardBand = Rect.fromLTWH(
        target.x + 2,
        target.y + target.h * 0.32,
        target.w - 4,
        target.h * 0.36,
      );
      canvas.clipRect(hazardBand);
      canvas.drawRect(hazardBand, Paint()..color = const Color(0xFFFFD166));
      final stripePaint = Paint()
        ..color = const Color(0xFF221606)
        ..strokeWidth = 3.5;
      for (double x = -20; x <= target.w + 20; x += 8) {
        canvas.drawLine(
          Offset(target.x + x, hazardBand.top - 2),
          Offset(target.x + x + 8, hazardBand.bottom + 2),
          stripePaint,
        );
      }
      canvas.restore();

      // Steel perimeter frame & corner brackets
      final framePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF332011);
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect.deflate(2), const Radius.circular(3)),
        framePaint,
      );

      // Central gravity core socket
      final isHeavy = target.debt > 1;
      final isLight = target.debt < -1;
      final coreColor = isLight
          ? const Color(0xFF7BE5FF)
          : isHeavy
          ? const Color(0xFFFF5277)
          : const Color(0xFFFFE082);
      canvas.drawCircle(
        target.center,
        5.5,
        Paint()..color = const Color(0xFF1A130B),
      );
      canvas.drawCircle(
        target.center,
        3.5,
        Paint()..color = coreColor,
      );
    }
    if (target.anchored) {
      _text(
        canvas,
        'BRIDGE',
        Offset(target.x + target.w / 2, target.y - 14),
        8,
        const Color(0xFF8CFFB1),
        center: true,
        bold: true,
      );
    } else if (target.debt < -1) {
      _text(
        canvas,
        'LIGHT',
        Offset(target.x + target.w / 2, target.y - 14),
        9,
        const Color(0xFF8DE1FF),
        center: true,
        bold: true,
      );
    } else if (target.debt > 1) {
      _text(
        canvas,
        '×${(1 + target.debt * .035).toStringAsFixed(1)}',
        Offset(target.x + target.w / 2, target.y - 14),
        10,
        const Color(0xFFFFD86E),
        center: true,
        bold: true,
      );
    }
  }

  // --- AUTOMATED DEFENSE TURRETS (EMITTERS) ---
  void _drawEmitter(Canvas canvas, _DueEmitter emitter) {
    final rect = Rect.fromCenter(center: emitter.position, width: 30, height: 30);
    final color = emitter.debt > 1 ? const Color(0xFFFFD36A) : const Color(0xFFFF3355);

    // Ambient threat aura
    canvas.drawCircle(
      emitter.position,
      24 + emitter.debt * 0.15,
      Paint()..color = color.withValues(alpha: emitter.debt > 1 ? 0.18 : 0.08),
    );

    // Turret base mounting box
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF1F1218),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = color,
    );

    // Heavy Cannon Barrel pointing in fire direction
    final aim = emitter.speed.sign;
    final barrelEnd = emitter.position + Offset(aim * 19, 0);
    canvas.drawLine(
      emitter.position,
      barrelEnd,
      Paint()
        ..color = const Color(0xFFFFCCD5)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.square,
    );

    // Charged muzzle flare
    canvas.drawCircle(barrelEnd, 3.5, Paint()..color = color);

    if (emitter.debt > 1) {
      _text(
        canvas,
        '${emitter.debt.round()}%',
        emitter.position + const Offset(0, -23),
        8,
        const Color(0xFFFFD36A),
        center: true,
        bold: true,
      );
    }
  }

  // --- PLASMA PROJECTILE BULLETS ---
  void _drawBullet(Canvas canvas, _DueBullet bullet) {
    final color = bullet.debt >= 20
        ? const Color(0xFF6DE8FF)
        : bullet.debt > 1
        ? const Color(0xFFFFD36A)
        : const Color(0xFFFF4868);
    final center = bullet.rect.center;
    final isParried = bullet.debt >= 20;

    // Glowing energy halo
    canvas.drawCircle(
      center,
      isParried ? 16 : 12,
      Paint()
        ..color = color.withValues(alpha: isParried ? 0.45 : 0.35)
        ..blendMode = BlendMode.screen,
    );
    // Outer plasma sphere
    canvas.drawCircle(center, isParried ? 8.5 : 7.5, Paint()..color = color);
    // Super-hot white core
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  // --- GRAVITATIONAL SHOCKWAVES ---
  void _drawShockwave(Canvas canvas, _FallDueShockwave wave) {
    final progress = (wave.time / _FallDueShockwave.life).clamp(0.0, 1.0);
    final radius = wave.maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * (1.0 - progress * 0.7)
      ..color = wave.color.withValues(alpha: opacity * 0.8)
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(wave.position, radius, paint);
    if (radius > 15) {
      canvas.drawCircle(
        wave.position,
        radius * 0.82,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = wave.color.withValues(alpha: opacity * 0.4)
          ..blendMode = BlendMode.screen,
      );
    }
  }

  // --- QUANTUM GRAVITY SIPHON TETHER ---
  void _drawQuantumTether(Canvas canvas, Offset start, Offset target) {
    final tetherColor = game.debt >= 3 ? const Color(0xFFFFD36A) : const Color(0xFF6DE8FF);

    // 1. Broad outer glowing sheath
    canvas.drawLine(
      start,
      target,
      Paint()
        ..color = tetherColor.withValues(alpha: 0.28)
        ..strokeWidth = 7.0
        ..blendMode = BlendMode.screen,
    );

    // 2. High-energy central quantum beam
    canvas.drawLine(
      start,
      target,
      Paint()
        ..color = tetherColor.withValues(alpha: 0.85)
        ..strokeWidth = 2.2,
    );

    // 3. Electric Lightning arcs along the beam
    final count = 5;
    final diff = target - start;
    for (var i = 1; i < count; i++) {
      final t = i / count;
      final mid = start + diff * t;
      final perp = normalizedOr(Offset(-diff.dy, diff.dx)) * math.sin(game.time * 20.0 + i * 2.0) * 8.0;
      canvas.drawCircle(
        mid + perp,
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    // 4. Target Acquisition Reticle
    final reticlePulse = 26 + math.sin(game.time * 7) * 3;
    canvas.drawCircle(
      target,
      reticlePulse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = tetherColor.withValues(alpha: 0.8),
    );
  }

  // --- CYBER-ASTRONAUT HERO WITH DETAILED RIG & JETPACK FX ---
  void _drawPlayerWithEffects(Canvas canvas) {
    final player = game.player;
    final accent = game.inPayback ? const Color(0xFFFFD36A) : const Color(0xFF6DE8FF);

    // 0. High-Velocity Kinetic Slam Streaks (Scaled with Borrow Power)
    if (game._slamming) {
      final power = game._slamBorrowPower;
      final isHigh = power >= 70.0;
      final isMedium = power >= 35.0;
      final streakColor = isHigh
          ? const Color(0xFFFF2E63)
          : isMedium
          ? const Color(0xFFFF7186)
          : const Color(0xFFFF9E79);
      final streakLength = isHigh ? 48.0 : (isMedium ? 36.0 : 24.0);
      final streakStroke = isHigh ? 4.2 : (isMedium ? 3.2 : 2.2);

      final streakPaint = Paint()
        ..color = streakColor.withValues(alpha: isHigh ? 0.85 : 0.6)
        ..strokeWidth = streakStroke
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen;
      canvas.drawLine(
        player.center - Offset(7, streakLength),
        player.center - const Offset(7, 10),
        streakPaint,
      );
      canvas.drawLine(
        player.center - Offset(-7, streakLength),
        player.center - const Offset(-7, 10),
        streakPaint,
      );
      canvas.drawCircle(
        player.center,
        isHigh ? 36 : (isMedium ? 30 : 24),
        Paint()
          ..color = streakColor.withValues(alpha: isHigh ? 0.42 : 0.25)
          ..blendMode = BlendMode.screen,
      );
      if (isHigh) {
        // Trailing plasma shock rings for highest borrow
        final ringRadius = 24.0 + (game.time * 60) % 18.0;
        canvas.drawCircle(
          player.center,
          ringRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = const Color(0xFF6DE8FF).withValues(alpha: 0.6)
            ..blendMode = BlendMode.screen,
        );
      }
    }

    // 1. Gravitational Distortion Space-Time Rings (When Borrowing Gravity)
    if (game._antiGravityActive) {
      final pulseRadius = 26.0 + (game.time * 42) % 22.0;
      final pulseAlpha = (1.0 - (pulseRadius - 26) / 22.0).clamp(0.0, 1.0);
      canvas.drawCircle(
        player.center,
        pulseRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = const Color(0xFF6DE8FF).withValues(alpha: pulseAlpha * 0.7),
      );
      canvas.drawCircle(
        player.center,
        34,
        Paint()..color = const Color(0xFF6DE8FF).withValues(alpha: 0.18),
      );
    }

    // 2. Heavy Overload Crackling Sparks (During Payback State)
    if (game.inPayback) {
      final sparkPulse = math.sin(game.time * 25.0);
      if (sparkPulse > 0.3) {
        final sparkOffset = player.center + Offset(sparkPulse * 14, -sparkPulse * 12);
        canvas.drawCircle(
          sparkOffset,
          2.5,
          Paint()..color = const Color(0xFFFFD36A),
        );
      }
    }

    // 3. Ground Contact Shadow beneath astronaut
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(player.center.dx, player.y + player.h + 3),
        width: 30,
        height: 6,
      ),
      Paint()..color = const Color(0x9903060C),
    );

    // 4. Cyber-Astronaut Model
    _drawCyberAstronaut(canvas, player, accent);
  }

  void _drawCyberAstronaut(Canvas canvas, _DueBody player, Color accent) {
    final facing = player.vx < -12 ? -1.0 : 1.0;
    // Gravitational Levitation Ability Effect (Innate Superpower Aura - No Gadgets/Jetpack)
    if (game._antiGravityActive || player.vy < -40) {
      final feetCenter = Offset(player.center.dx, player.rect.bottom + 2);
      final auraRadius = 12.0 + math.sin(game.time * 20.0) * 3.0;
      final liftAlpha = game._antiGravityActive ? 0.75 : 0.45;

      // Ethereal gravitational lift glow beneath feet
      canvas.drawOval(
        Rect.fromCenter(
          center: feetCenter,
          width: auraRadius * 2.2,
          height: 6.0,
        ),
        Paint()
          ..color = accent.withValues(alpha: liftAlpha * 0.4)
          ..blendMode = BlendMode.screen,
      );

      // Expanding concentric gravitational energy rings
      final ringProgress = (game.time * 2.5) % 1.0;
      final ringRadius = 8.0 + ringProgress * 14.0;
      final ringAlpha = (1.0 - ringProgress).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: feetCenter + Offset(0, ringProgress * 4.0),
          width: ringRadius * 2.0,
          height: 5.0,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = accent.withValues(alpha: ringAlpha * liftAlpha)
          ..blendMode = BlendMode.screen,
      );
    }

    // Torso (Classic vibrant cyan/gold loan accent)
    final torso = Rect.fromLTWH(player.x + 4, player.y + 15, 19, 17);
    canvas.drawRRect(
      RRect.fromRectAndRadius(torso, const Radius.circular(5)),
      Paint()..color = accent,
    );

    // Helmet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 5, player.y + 2, 17, 16),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFFE5F3FF),
    );

    // Visor
    final visor = Rect.fromLTWH(
      facing > 0 ? player.x + 12 : player.x + 6,
      player.y + 7,
      8,
      6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor, const Radius.circular(3)),
      Paint()..color = const Color(0xFF102238),
    );
    canvas.drawCircle(
      Offset(visor.center.dx + facing * 1.5, visor.center.dy),
      1.3,
      Paint()..color = accent,
    );

    // Boots
    final bootPaint = Paint()..color = const Color(0xFF162338);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 5, player.y + 30, 7, 6),
        const Radius.circular(2),
      ),
      bootPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(player.x + 16, player.y + 30, 7, 6),
        const Radius.circular(2),
      ),
      bootPaint,
    );

    // Comms Antenna
    canvas.drawLine(
      Offset(player.x + 13.5, player.y + 2),
      Offset(player.x + 13.5 + facing * 3, player.y - 3),
      Paint()
        ..color = const Color(0xFFCDEBFF)
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      Offset(player.x + 13.5 + facing * 3, player.y - 3),
      1.5,
      Paint()..color = accent,
    );
  }

  // --- CYBERPUNK TELEMETRY HUD & GRAVITY LEDGER METER ---
  void _drawDebtMeter(Canvas canvas) {
    const meter = Rect.fromLTWH(20, 18, 256, 16);

    // Glassmorphic meter tray
    canvas.drawRRect(
      RRect.fromRectAndRadius(meter, const Radius.circular(8)),
      Paint()..color = const Color(0xFF101928),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(meter, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF354B6E),
    );

    // Segmented Active Gravity Loan Energy Fill
    final fillWidth = (meter.width * (game.gravityMeter / 100).clamp(0.0, 1.0));
    final fillColor = game.inPayback ? const Color(0xFFFFD36A) : const Color(0xFF6DE8FF);

    if (fillWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(meter.left, meter.top, fillWidth, meter.height),
          const Radius.circular(8),
        ),
        Paint()..color = fillColor,
      );

      // Neon highlight gloss line
      canvas.drawLine(
        Offset(meter.left + 4, meter.top + 3),
        Offset(meter.left + fillWidth - 4, meter.top + 3),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = 1.2,
      );
    }

    // Ledger Status Text Readout
    _text(
      canvas,
      game._antiGravityActive
          ? 'BORROWING // TRANSFER GRAVITY BEFORE EXPIRATION'
          : game.inPayback
          ? 'HEAVY PAYBACK // LAND CLEANLY TO DISSIPATE'
          : game._settleGrace > 0
          ? 'LOAN OPEN // GIVE OR ABSORB CHARGE'
          : game.debt > 0
          ? 'CARRIED LOAN // SPEND OR DISCHARGE'
          : 'LEDGER NOMINAL // ALL ACCOUNTS BALANCED',
      const Offset(20, 48),
      9.5,
      const Color(0xFFE2EDFF),
      bold: true,
      letterSpacing: 0.6,
    );
  }



  void _text(
    Canvas canvas,
    String text,
    Offset point,
    double size,
    Color color, {
    bool center = false,
    bool bold = false,
    bool right = false,
    double letterSpacing = 0.0,
  }) {
    paintGameText(
      canvas,
      text,
      point,
      size,
      color,
      align: center
          ? TextAlign.center
          : right
          ? TextAlign.right
          : TextAlign.left,
      bold: bold,
      letterSpacing: letterSpacing,
    );
  }

  @override
  bool shouldRepaint(covariant _FallPainter oldDelegate) => true;
}
