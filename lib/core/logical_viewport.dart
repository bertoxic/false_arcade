import 'dart:ui';

/// Letterboxes a fixed logical world into an arbitrary render surface.
class LogicalViewport {
  const LogicalViewport._({
    required this.surfaceSize,
    required this.worldSize,
    required this.scale,
    required this.origin,
  });

  factory LogicalViewport.fit(Size surfaceSize, Size worldSize) {
    assert(surfaceSize.width >= 0 && surfaceSize.height >= 0);
    assert(worldSize.width > 0 && worldSize.height > 0);
    final sx = surfaceSize.width / worldSize.width;
    final sy = surfaceSize.height / worldSize.height;
    final scale = sx < sy ? sx : sy;
    return LogicalViewport._(
      surfaceSize: surfaceSize,
      worldSize: worldSize,
      scale: scale,
      origin: Offset(
        (surfaceSize.width - worldSize.width * scale) / 2,
        (surfaceSize.height - worldSize.height * scale) / 2,
      ),
    );
  }

  final Size surfaceSize;
  final Size worldSize;
  final double scale;
  final Offset origin;

  Rect get screenWorldRect => origin & (worldSize * scale);

  Offset worldToScreen(Offset point) => origin + point * scale;

  Offset screenToWorld(Offset point) => (point - origin) / scale;

  void applyTo(Canvas canvas) {
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
  }
}
