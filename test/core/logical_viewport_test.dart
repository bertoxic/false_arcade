import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/core/logical_viewport.dart';

void main() {
  test('letterboxes and round-trips world coordinates', () {
    final viewport = LogicalViewport.fit(
      const Size(1200, 600),
      const Size(960, 540),
    );
    const point = Offset(731, 247);

    expect(viewport.screenWorldRect.width, closeTo(1066.6667, .001));
    expect(viewport.origin.dx, closeTo(66.6667, .001));
    expect(viewport.screenToWorld(viewport.worldToScreen(point)), point);
  });
}
