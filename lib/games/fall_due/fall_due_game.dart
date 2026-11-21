import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/game_feedback.dart';
import '../../core/game_loop.dart';
import '../../core/level_campaign.dart';
import '../../core/game_math.dart';
import '../../core/game_presentation.dart';
import '../../core/gameplay.dart';
import '../../core/logical_viewport.dart';
import '../../core/arcade_achievements.dart';
import '../../core/arcade_fever.dart';
import '../../core/canvas_text.dart';
import '../../ui/game_controls.dart';
import '../../ui/screen_shake.dart';

part 'fall_due_page.dart';
part 'fall_due_controls.dart';
part 'fall_due_simulation.dart';
part 'fall_due_painter.dart';
part 'fall_due_scenery.dart';
part 'fall_due_level_generator.dart';
part 'fall_due_story.dart';
part 'fall_due_story_levels.dart';
part 'fall_due_story_page.dart';
part 'fall_due_story_painter.dart';
part 'fall_due_workshops.dart';
part 'fall_due_workshop_art.dart';
part 'fall_due_encounters.dart';
part 'fall_due_encounter_art.dart';
part '_story_audit.dart';

const _duePlayfieldSize = Size(FallDueTuning.viewWidth, FallDueTuning.viewHeight);

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
  static const airDashDuration = .18;
  static const dashDebtCost = 22.0;
  static const parryRange = 170.0;
  static const parryBonusScore = 450;

  static const double repulsorRadius = 130.0;
  static const double gravityWellPull = 450.0;
  static const double laserDamage = 100.0;
  static const double tetherMaxDistance = 240.0;
  static const double phaseShiftDuration = 0.40;
  static const double repulsorStunDuration = 1.20;
  static const double wallSlideSpeed = 180.0;

  static double airDashSpeedLimit(double remaining) =>
      runSpeed + (dashImpulse - runSpeed) *
          (remaining / airDashDuration).clamp(0.0, 1.0);

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

  static double crumblingLedgeCollapseDuration(double payback) =>
      1.20 *
      (1.0 -
          0.65 *
              (payback.clamp(0.0, FallDueTuning.maxDebt) /
                  FallDueTuning.maxDebt));

  static bool retractableSpikeActive(double time) => (time % 3.20) < 1.50;

  static bool laserGateActive(double time, bool switchEngaged) {
    if (switchEngaged) return false;
    return (time % 2.20) < 1.20;
  }

  static double repulsorBurstPushForce(double debt) =>
      480.0 + (debt.clamp(0.0, FallDueTuning.maxDebt) * 1.5);

  static double phaseShiftDuration() => FallDueTuning.phaseShiftDuration;

  static bool conduitPowerConnected(List<int> alignment) =>
      alignment.isNotEmpty && alignment.every((v) => v == 1);

  static bool weightAnchorSatisfied(double weightOnPlate) =>
      weightOnPlate >= FallDueTuning.anchorDebt;

  static int bossMaxLives() => 3;
  static double bossStompStunDuration() => 2.2;
  static double bossSlamStunDuration() => 3.8;
  static double bossStompBounceSpeed() => -410.0;
  static double bossSlamBounceSpeed() => -520.0;

  static double crateCrushVelocityThreshold() => 210.0;
  static double gravityWellPullForce() => FallDueTuning.gravityWellPull;
  static double laserDamage() => FallDueTuning.laserDamage;
}
