import 'package:flutter/material.dart';

import '../core/arcade_achievements.dart';
import '../core/arcade_fever.dart';
import '../core/game_feedback.dart';
import 'screen_shake.dart';

/// Wraps game content with an authentic CRT arcade monitor overlay,
/// screen shake, full-screen impact flashes, Fever border glow, and
/// live achievement unlock notifications.
class ArcadeScreenFilter extends StatelessWidget {
  const ArcadeScreenFilter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ArcadeShakeView(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          // 1. Full-screen screen flash on explosions / impacts
          ValueListenableBuilder<Color?>(
            valueListenable: ArcadeFlash.flashNotifier,
            builder: (context, flashColor, _) {
              if (flashColor == null) return const SizedBox.shrink();
              return Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: flashColor),
                  ),
                ),
              );
            },
          ),
          // 2. Fever / Overdrive electric pulsing border
          ValueListenableBuilder<bool>(
            valueListenable: ArcadeFever.activeNotifier,
            builder: (context, isFever, _) {
              if (!isFever) return const SizedBox.shrink();
              return const Positioned.fill(
                child: IgnorePointer(
                  child: _FeverBorderOverlay(),
                ),
              );
            },
          ),
          // 3. CRT Scanlines and phosphor vignette overlay
          ValueListenableBuilder<GameFeedbackSettings>(
            valueListenable: GameFeedback.settings,
            builder: (context, settings, _) {
              if (!settings.crtEnabled) return const SizedBox.shrink();
              return const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _CrtOverlayPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
          // 4. Achievement Unlock Banner Notification
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: _AchievementNotificationBanner(),
          ),
        ],
      ),
    );
  }
}

class _FeverBorderOverlay extends StatefulWidget {
  const _FeverBorderOverlay();

  @override
  State<_FeverBorderOverlay> createState() => _FeverBorderOverlayState();
}

class _FeverBorderOverlayState extends State<_FeverBorderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final borderGlow = Color.lerp(
          const Color(0xFF48F2C1),
          const Color(0xFFFFD36A),
          t,
        )!;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderGlow.withValues(alpha: 0.65 + t * 0.35),
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderGlow.withValues(alpha: 0.38 + t * 0.22),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementNotificationBanner extends StatelessWidget {
  const _AchievementNotificationBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ArcadeAchievement?>(
      valueListenable: ArcadeAchievements.latestUnlockNotifier,
      builder: (context, achievement, _) {
        if (achievement == null) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xF209121E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: achievement.color,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: achievement.color.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                const BoxShadow(
                  color: Colors.black87,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: achievement.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: achievement.color),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFFFFD36A),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            color: achievement.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'PressStart2P',
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: const TextStyle(
                        color: Color(0xFFBACADB),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

    // 2. Phosphor glow / neutral tube vignette at edges
    final vignetteShader = RadialGradient(
      center: Alignment.center,
      radius: 1.15,
      colors: [
        Colors.transparent,
        const Color(0xFF000000).withValues(alpha: 0.05),
        const Color(0xFF000000).withValues(alpha: 0.28),
        const Color(0xFF000000).withValues(alpha: 0.60),
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
          Colors.white.withValues(alpha: 0.025),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, topGleam);
  }

  @override
  bool shouldRepaint(covariant _CrtOverlayPainter oldDelegate) => false;
}
