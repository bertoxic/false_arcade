import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/core/game_input.dart';

void main() {
  test('directional keyboard input normalizes diagonals and resets', () {
    final input = DirectionalInput();
    input.handleKey(
      KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyD,
        logicalKey: LogicalKeyboardKey.keyD,
        timeStamp: Duration.zero,
      ),
    );
    input.handleKey(
      KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyW,
        logicalKey: LogicalKeyboardKey.keyW,
        timeStamp: Duration.zero,
      ),
    );

    expect(input.axis.distance, closeTo(1, 1e-9));
    expect(input.axis.dx, greaterThan(0));
    expect(input.axis.dy, lessThan(0));

    input.reset();
    expect(input.axis, Offset.zero);
  });

  test('unrelated keyboard input is not consumed', () {
    final input = DirectionalInput();
    expect(
      input.handleKey(
        KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.escape,
          logicalKey: LogicalKeyboardKey.escape,
          timeStamp: Duration.zero,
        ),
      ),
      isFalse,
    );
  });
}
