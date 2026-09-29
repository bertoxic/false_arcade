import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/canvas_text.dart';
import '../../core/game_feedback.dart';
import '../../core/game_loop.dart';
import '../../core/level_campaign.dart';
import '../../core/game_math.dart';
import '../../core/game_presentation.dart';
import '../../core/gameplay.dart';
import '../../core/logical_viewport.dart';
import '../../core/arcade_achievements.dart';
import '../../core/arcade_fever.dart';
import '../../ui/arcade_screen_filter.dart';
import '../../ui/game_controls.dart';
import '../../ui/screen_shake.dart';

part 'fall_due_page.dart';
part 'fall_due_simulation.dart';
part 'fall_due_painter.dart';
part 'fall_due_level_generator.dart';

/// Central tuning for Fall Due's deliberately arcade-like physics.
///
/// Distances are logical pixels, velocities are pixels/second, and
/// accelerations are pixels/second squared. Keeping these values together is
/// important: the gravity ledger is meant to be surprising, never arbitrary.
abstract final class FallDueTuning {
  static const viewWidth = 960.0;
  static const viewHeight = 540.0;
  static const interactionRange = 220.0;

  static const gravity = 1520.0;
  static const terminalVelocity = 1500.0;
  static const runSpeed = 300.0;
  static const groundAcceleration = 2350.0;
  static const airAcceleration = 1450.0;
  static const groundVelocityRetainedPerSecond = .00025;
  static const airVelocityRetainedPerSecond = .12;
  static const jumpImpulse = 635.0;
  static const jumpCutVelocity = 285.0;
  static const borrowLaunchImpulse = 415.0;
  static const borrowRate = 21.0;
  static const borrowInitialCharge = 10.0;
  static const maxDebt = 100.0;
  static const settlementWindow = 1.25;
  static const anchorDebt = 10.0;
  static const anchorImpactSpeed = 135.0;
  static const crateVelocityRetainedPerSecond = .025;
  static const deathLedgerFee = 28.0;
  static const deathScoreFee = 150;

  static const slamSpeed = 820.0;
  static const shockwaveRadius = 80.0;
  static const dashImpulse = 350.0;
  static const dashDebtCost = 22.0;
  static const parryRange = 170.0;
  static const parryBonusScore = 450;

  /// Borrow starts as strong lift, then smoothly exhausts over the final 35%.
  static double borrowLiftAcceleration(double debt) {
    final exhaustion = smoothStep(65, maxDebt, debt);
    return 1120 + (420 - 1120) * exhaustion;
  }

  static double borrowGravityScale(double debt) {
    final exhaustion = smoothStep(65, maxDebt, debt);
    return .28 + (.75 - .28) * exhaustion;
  }

  static double borrowNetAcceleration(double debt) =>
      gravity * borrowGravityScale(debt) - borrowLiftAcceleration(debt);

  static double paybackGravityMultiplier(double payback) =>
      1 + payback.clamp(0, maxDebt) * .014;
}

/// Pure run rules kept public so campaign and ledger invariants can be tested.
abstract final class FallDueRules {
  static bool objectivesComplete({
    required int remainingSeals,
    required int lockedGates,
  }) => remainingSeals == 0 && lockedGates == 0;

  static double paybackAfterDeath({
    required double carriedDebt,
    required double payback,
  }) => (payback + carriedDebt * .7 + FallDueTuning.deathLedgerFee)
      .clamp(0, FallDueTuning.maxDebt)
      .toDouble();

  static int cleanExitBonus({
    required double carriedDebt,
    required double payback,
  }) {
    final outstanding = (carriedDebt + payback).clamp(0, FallDueTuning.maxDebt);
    return ((FallDueTuning.maxDebt - outstanding) * 10).round();
  }

  static int generatedStageLength(int stageIndex) {
    final stage = _FallDueLevelGenerator.generateStage(stageIndex);
    return stage.finalExit.right.round();
  }

  static String generatedStageTitle(int stageIndex) =>
      _FallDueLevelGenerator.generateStage(stageIndex).title;

  static int generatedStageSectionCount(int stageIndex) =>
      _FallDueLevelGenerator.generateStage(stageIndex).route?.sections.length ?? 0;

  static Set<String> generatedStageTargetKinds(int stageIndex) =>
      _FallDueLevelGenerator.generateStage(stageIndex)
          .allTargets
          .map((t) => t.kind.name)
          .toSet();

  static double slamDescentSpeed(double borrowPower) {
    final clamped = borrowPower.clamp(0.0, FallDueTuning.maxDebt);
    return 640.0 + (clamped / FallDueTuning.maxDebt) * 440.0;
  }

  static bool slamCausesShockwave(double borrowPower) => borrowPower >= 70.0;

  static bool canInitiateSlam(double borrowPower) => borrowPower >= 8.0;

  static double droneGiveDownwardSpeed() => 750.0;

  static double droneTakeBlastSpeed() => 920.0;

  static double enemyTakeBlastSpeed() => 920.0;

  static double slamConcussionRadius(double borrowPower) =>
      70.0 + (borrowPower.clamp(0.0, FallDueTuning.maxDebt) * 0.2);

  static double slamConcussionPush(double borrowPower) =>
      70.0 + (borrowPower.clamp(0.0, FallDueTuning.maxDebt) * 0.3);
}
