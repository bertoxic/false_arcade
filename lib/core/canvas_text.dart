import 'package:flutter/painting.dart';

/// Paints a short HUD/world label with consistent alignment semantics.
void paintGameText(
  Canvas canvas,
  String text,
  Offset position,
  double size,
  Color color, {
  TextAlign align = TextAlign.left,
  double opacity = 1,
  bool bold = false,
  double letterSpacing = 0,
  Color? glowColor,
  String? fontFamily,
}) {
  final alpha = opacity.clamp(0.0, 1.0);
  final shadows = glowColor != null
      ? [
          Shadow(
            color: glowColor.withValues(alpha: alpha * 0.8),
            blurRadius: 10,
          ),
          Shadow(
            color: glowColor.withValues(alpha: alpha * 0.4),
            blurRadius: 20,
          ),
        ]
      : null;

  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: alpha),
        fontSize: size,
        fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        fontFamily: fontFamily,
        letterSpacing: letterSpacing,
        shadows: shadows,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout();
  final offset = switch (align) {
    TextAlign.center => position - Offset(painter.width / 2, 0),
    TextAlign.right || TextAlign.end => position - Offset(painter.width, 0),
    _ => position,
  };
  painter.paint(canvas, offset);
}
