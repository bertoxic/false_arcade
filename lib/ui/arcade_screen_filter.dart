import 'package:flutter/material.dart';

import '../core/game_feedback.dart';

import 'screen_shake.dart';

/// Wraps game content with an optional authentic CRT arcade monitor overlay
/// and responsive screen shake feedback.
class ArcadeScreenFilter extends StatelessWidget {
  const ArcadeScreenFilter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ArcadeShakeView(
      child: ValueListenableBuilder<GameFeedbackSettings>(
        valueListenable: GameFeedback.settings,
        builder: (context, settings, _) {
          if (!settings.crtEnabled) return child;
          return Stack(
            fit: StackFit.passthrough,
            children: [
              child,
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _CrtOverlayPainter(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CrtOverlayPainter extends CustomPainter {
  const _CrtOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // 1. Subtle horizontal CRT scanlines
    final scanlinePaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    const step = 3.5;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    // 2. Phosphor glow / tube vignette at edges
    final vignetteShader = RadialGradient(
      center: Alignment.center,
      radius: 1.15,
      colors: [
        Colors.transparent,
        const Color(0xFF001520).withValues(alpha: 0.05),
        const Color(0xFF000510).withValues(alpha: 0.38),
        const Color(0xFF000208).withValues(alpha: 0.72),
      ],
      stops: const [0.0, 0.65, 0.88, 1.0],
    ).createShader(Offset.zero & size);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = vignetteShader,
    );

    // 3. Subtle glass highlight at the top edge
    final topGleam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF68E0FF).withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, topGleam);
  }

  @override
  bool shouldRepaint(covariant _CrtOverlayPainter oldDelegate) => false;
}
