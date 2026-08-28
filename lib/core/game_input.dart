import 'package:flutter/services.dart';

/// Device-independent movement state for touch, keyboard, or controller
/// adapters. Game rules consume only the normalized [axis].
class DirectionalInput {
  final Set<LogicalKeyboardKey> _pressed = {};
  Offset _analog = Offset.zero;

  Offset get axis {
    final digital = Offset(
      (_pressed.contains(LogicalKeyboardKey.arrowRight) ||
                  _pressed.contains(LogicalKeyboardKey.keyD)
              ? 1
              : 0) -
          (_pressed.contains(LogicalKeyboardKey.arrowLeft) ||
                  _pressed.contains(LogicalKeyboardKey.keyA)
              ? 1
              : 0),
      (_pressed.contains(LogicalKeyboardKey.arrowDown) ||
                  _pressed.contains(LogicalKeyboardKey.keyS)
              ? 1
              : 0) -
          (_pressed.contains(LogicalKeyboardKey.arrowUp) ||
                  _pressed.contains(LogicalKeyboardKey.keyW)
              ? 1
              : 0),
    );
    final combined = _analog + digital;
    return combined.distance > 1 ? combined / combined.distance : combined;
  }

  void setAnalog(Offset value) {
    _analog = value.distance > 1 ? value / value.distance : value;
  }

  bool handleKey(KeyEvent event) {
    if (!_movementKeys.contains(event.logicalKey)) return false;
    if (event is KeyUpEvent) {
      _pressed.remove(event.logicalKey);
    } else {
      _pressed.add(event.logicalKey);
    }
    return true;
  }

  void reset() {
    _pressed.clear();
    _analog = Offset.zero;
  }

  static final Set<LogicalKeyboardKey> _movementKeys = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyS,
  };
}

bool isActionPressed(KeyEvent event) => event is KeyDownEvent;

bool isActionReleased(KeyEvent event) => event is KeyUpEvent;
