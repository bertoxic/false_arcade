part of 'future_debt_game.dart';

/// I keep run pace separate from campaign generation: it adjusts immediate
/// pressure without altering a selected level's authored case objective.
enum _FutureDebtPace { relief, standard, ruthless }

/// I offer two complete keyboard maps so movement and aiming can swap hands
/// without asking a player to use the default layout.
enum _FutureDebtKeyboardLayout { wasdMove, arrowsMove }

extension _FutureDebtKeyboardLayoutDetails on _FutureDebtKeyboardLayout {
  String get label => switch (this) {
    _FutureDebtKeyboardLayout.wasdMove => 'WASD MOVE',
    _FutureDebtKeyboardLayout.arrowsMove => 'ARROWS MOVE',
  };

  String get description => switch (this) {
    _FutureDebtKeyboardLayout.wasdMove => 'Aim with arrow keys.',
    _FutureDebtKeyboardLayout.arrowsMove => 'Aim with I / J / K / L.',
  };
}

extension _FutureDebtPaceDetails on _FutureDebtPace {
  String get label => switch (this) {
    _FutureDebtPace.relief => 'RELIEF',
    _FutureDebtPace.standard => 'STANDARD',
    _FutureDebtPace.ruthless => 'RUTHLESS',
  };

  String get description => switch (this) {
    _FutureDebtPace.relief => 'More opening time and fewer claimants.',
    _FutureDebtPace.standard => 'The intended case-file pressure.',
    _FutureDebtPace.ruthless => 'Less time and a faster collections office.',
  };

  double get enemyFlow => switch (this) {
    _FutureDebtPace.relief => .72,
    _FutureDebtPace.standard => 1,
    _FutureDebtPace.ruthless => 1.24,
  };

  double get lifetimeAdjustment => switch (this) {
    _FutureDebtPace.relief => 18,
    _FutureDebtPace.standard => 0,
    _FutureDebtPace.ruthless => -8,
  };
}
