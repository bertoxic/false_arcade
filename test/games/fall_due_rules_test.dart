import 'package:fluga/core/level_campaign.dart';
import 'package:fluga/core/logical_viewport.dart';
import 'package:fluga/games/fall_due/fall_due_game.dart';
import 'package:fluga/ui/game_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fall Due gravity tuning', () {
    test('air dash keeps its burst speed before returning to run speed', () {
      expect(
        FallDueTuning.airDashSpeedLimit(FallDueTuning.airDashDuration),
        FallDueTuning.dashImpulse,
      );
      expect(
        FallDueTuning.airDashSpeedLimit(FallDueTuning.airDashDuration / 2),
        closeTo((FallDueTuning.runSpeed + FallDueTuning.dashImpulse) / 2, 1e-8),
      );
      expect(FallDueTuning.airDashSpeedLimit(0), FallDueTuning.runSpeed);
    });

    test('borrow exhaustion is continuous and changes lift into payback', () {
      expect(FallDueTuning.borrowNetAcceleration(0), lessThan(0));
      expect(
        FallDueTuning.borrowNetAcceleration(FallDueTuning.maxDebt),
        greaterThan(0),
      );

      var previous = FallDueTuning.borrowNetAcceleration(60);
      for (var debt = 60.1; debt <= 100; debt += .1) {
        final next = FallDueTuning.borrowNetAcceleration(debt);
        expect(next, greaterThanOrEqualTo(previous - 1e-9));
        expect((next - previous).abs(), lessThan(8));
        previous = next;
      }
    });

    test('payback multiplier is bounded to the ledger capacity', () {
      expect(FallDueTuning.paybackGravityMultiplier(-20), 1);
      expect(FallDueTuning.paybackGravityMultiplier(100), closeTo(2.4, 1e-9));
      expect(FallDueTuning.paybackGravityMultiplier(500), closeTo(2.4, 1e-9));
    });
  });

  group('Fall Due run rules', () {
    test('exit requires both seals and gravity locks', () {
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 0, lockedGates: 0),
        isTrue,
      );
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 1, lockedGates: 0),
        isFalse,
      );
      expect(
        FallDueRules.objectivesComplete(remainingSeals: 0, lockedGates: 1),
        isFalse,
      );
    });

    test('death converts carried debt and adds a capped ledger fee', () {
      expect(FallDueRules.paybackAfterDeath(carriedDebt: 40, payback: 10), 66);
      expect(
        FallDueRules.paybackAfterDeath(carriedDebt: 100, payback: 90),
        FallDueTuning.maxDebt,
      );
    });

    test('clean exit bonus counts carried and payable debt', () {
      expect(FallDueRules.cleanExitBonus(carriedDebt: 0, payback: 0), 1000);
      expect(FallDueRules.cleanExitBonus(carriedDebt: 60, payback: 20), 200);
      expect(FallDueRules.cleanExitBonus(carriedDebt: 80, payback: 80), 0);
    });
  });

  group('Fall Due procedural level generation', () {
    test(
      'contract stages generate sprawling long routes over 5,000 pixels',
      () {
        final lengthRun1 = FallDueRules.generatedStageLength(6);
        final lengthRun2 = FallDueRules.generatedStageLength(7);
        expect(lengthRun1, greaterThan(5000));
        expect(lengthRun2, greaterThan(5000));
      },
    );

    test(
      'different contract runs produce unique layouts, titles, and sections',
      () {
        final titleRun1 = FallDueRules.generatedStageTitle(6);
        final titleRun2 = FallDueRules.generatedStageTitle(7);
        expect(titleRun1, isNotEmpty);
        expect(titleRun2, isNotEmpty);
        expect(titleRun1, isNot(equals(titleRun2)));

        final sections1 = FallDueRules.generatedStageSectionCount(6);
        final sections2 = FallDueRules.generatedStageSectionCount(7);
        expect(sections1, greaterThanOrEqualTo(3));
        expect(sections2, greaterThanOrEqualTo(3));
      },
    );
  });

  group('Fall Due character powers tuning', () {
    test('kinetic slam and parry powers provide high-impact response', () {
      expect(FallDueTuning.slamSpeed, greaterThanOrEqualTo(800));
      expect(FallDueTuning.shockwaveRadius, lessThanOrEqualTo(100));
      expect(FallDueTuning.shockwaveRadius, greaterThanOrEqualTo(75));
      expect(FallDueTuning.dashImpulse, lessThanOrEqualTo(380));
      expect(FallDueTuning.dashImpulse, greaterThanOrEqualTo(300));
      expect(FallDueTuning.dashDebtCost, greaterThanOrEqualTo(20));
      expect(FallDueTuning.parryRange, greaterThanOrEqualTo(160));
      expect(FallDueTuning.parryBonusScore, greaterThanOrEqualTo(400));
    });

    test(
      'slam descent velocity scales with borrow power and requires borrow',
      () {
        expect(FallDueRules.canInitiateSlam(0), isFalse);
        expect(FallDueRules.canInitiateSlam(5), isFalse);
        expect(FallDueRules.canInitiateSlam(8), isTrue);
        expect(FallDueRules.canInitiateSlam(50), isTrue);

        expect(FallDueRules.slamDescentSpeed(0), 640.0);
        expect(FallDueRules.slamDescentSpeed(50), 860.0);
        expect(FallDueRules.slamDescentSpeed(100), 1080.0);
        expect(
          FallDueRules.slamDescentSpeed(100),
          greaterThan(FallDueRules.slamDescentSpeed(20)),
        );
      },
    );

    test('only highest borrow tier causes gravitational shockwaves', () {
      expect(FallDueRules.slamCausesShockwave(0), isFalse);
      expect(FallDueRules.slamCausesShockwave(34.9), isFalse);
      expect(FallDueRules.slamCausesShockwave(69.9), isFalse);
      expect(FallDueRules.slamCausesShockwave(70.0), isTrue);
      expect(FallDueRules.slamCausesShockwave(100.0), isTrue);
    });

    test('slam concussion pushes nearby enemies even if direct hit missed', () {
      expect(FallDueRules.slamConcussionRadius(0), 70.0);
      expect(FallDueRules.slamConcussionRadius(100), 90.0);
      expect(FallDueRules.slamConcussionPush(0), 70.0);
      expect(FallDueRules.slamConcussionPush(100), 100.0);
      expect(
        FallDueRules.slamConcussionPush(100),
        greaterThan(FallDueRules.slamConcussionPush(0)),
      );
    });
  });

  group('Fall Due unique enemies with powers', () {
    test(
      'procedural generator spawns drones, heavy enforcers, leechers, swordsmen, and archers',
      () {
        final kinds = FallDueRules.generatedStageTargetKinds(6);
        expect(kinds.contains('crate'), isTrue);
        expect(kinds.contains('enemy'), isTrue);
        expect(kinds.contains('drone'), isTrue);
        expect(kinds.contains('heavy'), isTrue);
        expect(kinds.contains('leecher'), isTrue);
        expect(kinds.contains('swordsman'), isTrue);
        expect(kinds.contains('archer'), isTrue);
      },
    );

    test('drone GIVE shoves downward and TAKE blasts across screen', () {
      expect(FallDueRules.droneGiveDownwardSpeed(), 750.0);
      expect(FallDueRules.droneTakeBlastSpeed(), 920.0);
      expect(FallDueRules.droneTakeBlastSpeed(), greaterThan(500.0));
      expect(FallDueRules.droneTakeBlastSpeed(), lessThan(1000.0));
      expect(FallDueRules.enemyTakeBlastSpeed(), 920.0);
      expect(FallDueRules.enemyTakeBlastSpeed(), greaterThan(500.0));
      expect(FallDueRules.enemyTakeBlastSpeed(), lessThan(1000.0));
    });
  });

  group('Fall Due redesigned traps and hazard rules', () {
    test(
      'crumbling ledge collapse duration scales inversely with payback and clamps bounds',
      () {
        // Zero payback gives maximum ledge stability (1.20s)
        expect(
          FallDueRules.crumblingLedgeCollapseDuration(0.0),
          closeTo(1.20, 1e-9),
        );

        // Maximum payback (100) reduces collapse time to 0.42s (1.2 * 0.35)
        expect(
          FallDueRules.crumblingLedgeCollapseDuration(FallDueTuning.maxDebt),
          closeTo(0.42, 1e-9),
        );

        // Mid-payback values scale linearly between 1.20 and 0.42
        expect(
          FallDueRules.crumblingLedgeCollapseDuration(50.0),
          closeTo(0.81, 1e-9),
        );

        // Strictly inverse monotonic relation across progression
        double prevDuration = FallDueRules.crumblingLedgeCollapseDuration(0.0);
        for (double payback = 10.0; payback <= 100.0; payback += 10.0) {
          final currentDuration =
              FallDueRules.crumblingLedgeCollapseDuration(payback);
          expect(currentDuration, lessThan(prevDuration));
          prevDuration = currentDuration;
        }

        // Clamping bounds for negative or excessive payback
        expect(
          FallDueRules.crumblingLedgeCollapseDuration(-25.0),
          closeTo(1.20, 1e-9),
        );
        expect(
          FallDueRules.crumblingLedgeCollapseDuration(250.0),
          closeTo(0.42, 1e-9),
        );
      },
    );

    test('retractable spike follows 3.2s periodicity with 1.5s active window', () {
      // Cycle is 3.20s total: [0, 1.50) is active, [1.50, 3.20) is retracted
      // Active phase in cycle 1
      expect(FallDueRules.retractableSpikeActive(0.0), isTrue);
      expect(FallDueRules.retractableSpikeActive(0.75), isTrue);
      expect(FallDueRules.retractableSpikeActive(1.49), isTrue);

      // Inactive/retracted phase in cycle 1 (including telegraph window before extension)
      expect(FallDueRules.retractableSpikeActive(1.50), isFalse);
      expect(FallDueRules.retractableSpikeActive(2.00), isFalse);
      expect(FallDueRules.retractableSpikeActive(2.80), isFalse);
      expect(FallDueRules.retractableSpikeActive(3.19), isFalse);

      // Cycle 2 wrap-around
      expect(FallDueRules.retractableSpikeActive(3.20), isTrue);
      expect(FallDueRules.retractableSpikeActive(3.20 + 0.75), isTrue);
      expect(FallDueRules.retractableSpikeActive(3.20 + 1.50), isFalse);
      expect(FallDueRules.retractableSpikeActive(3.20 + 2.50), isFalse);

      // Multi-cycle continuity across multiple periods
      for (int cycle = 1; cycle <= 5; cycle++) {
        final cycleStart = cycle * 3.20;
        expect(
          FallDueRules.retractableSpikeActive(cycleStart + 0.10),
          isTrue,
        );
        expect(
          FallDueRules.retractableSpikeActive(cycleStart + 0.75),
          isTrue,
        );
        expect(
          FallDueRules.retractableSpikeActive(cycleStart + 1.80),
          isFalse,
        );
        expect(
          FallDueRules.retractableSpikeActive(cycleStart + 2.50),
          isFalse,
        );
      }
    });

    test('laser gate cycles 2.2s period and respects manual switch override', () {
      // When switch is engaged, laser is unconditionally deactivated
      expect(FallDueRules.laserGateActive(0.0, true), isFalse);
      expect(FallDueRules.laserGateActive(0.60, true), isFalse);
      expect(FallDueRules.laserGateActive(1.19, true), isFalse);
      expect(FallDueRules.laserGateActive(1.50, true), isFalse);
      expect(FallDueRules.laserGateActive(2.20, true), isFalse);
      expect(FallDueRules.laserGateActive(50.0, true), isFalse);

      // When switch is NOT engaged, cycles 2.20s period: [0, 1.20) active, [1.20, 2.20) inactive
      // Cycle 1
      expect(FallDueRules.laserGateActive(0.0, false), isTrue);
      expect(FallDueRules.laserGateActive(0.60, false), isTrue);
      expect(FallDueRules.laserGateActive(1.19, false), isTrue);
      expect(FallDueRules.laserGateActive(1.20, false), isFalse);
      expect(FallDueRules.laserGateActive(1.80, false), isFalse);
      expect(FallDueRules.laserGateActive(2.19, false), isFalse);

      // Cycle 2 wrap-around
      expect(FallDueRules.laserGateActive(2.20, false), isTrue);
      expect(FallDueRules.laserGateActive(2.20 + 0.50, false), isTrue);
      expect(FallDueRules.laserGateActive(2.20 + 1.20, false), isFalse);
      expect(FallDueRules.laserGateActive(2.20 + 1.90, false), isFalse);

      // Multi-cycle continuity across multiple periods
      for (int cycle = 1; cycle <= 5; cycle++) {
        final cycleStart = cycle * 2.20;
        expect(
          FallDueRules.laserGateActive(cycleStart + 0.10, false),
          isTrue,
        );
        expect(
          FallDueRules.laserGateActive(cycleStart + 0.60, false),
          isTrue,
        );
        expect(
          FallDueRules.laserGateActive(cycleStart + 1.40, false),
          isFalse,
        );
        expect(
          FallDueRules.laserGateActive(cycleStart + 1.80, false),
          isFalse,
        );
      }
    });
  });

  group('Fall Due escape mechanisms and mobility rules', () {
    test('repulsor burst push force scales with carried debt and clamps bounds', () {
      // At zero debt, baseline knockback is 480 px/s
      expect(FallDueRules.repulsorBurstPushForce(0.0), closeTo(480.0, 1e-9));

      // At max debt (100.0), push force scales to 630 px/s (480 + 100 * 1.5)
      expect(
        FallDueRules.repulsorBurstPushForce(FallDueTuning.maxDebt),
        closeTo(630.0, 1e-9),
      );

      // Mid-debt scaling
      expect(FallDueRules.repulsorBurstPushForce(40.0), closeTo(540.0, 1e-9));

      // Monotonic scaling with debt
      double prevForce = FallDueRules.repulsorBurstPushForce(0.0);
      for (double d = 10.0; d <= 100.0; d += 10.0) {
        final currentForce = FallDueRules.repulsorBurstPushForce(d);
        expect(currentForce, greaterThan(prevForce));
        prevForce = currentForce;
      }

      // Clamping bounds
      expect(FallDueRules.repulsorBurstPushForce(-20.0), closeTo(480.0, 1e-9));
      expect(FallDueRules.repulsorBurstPushForce(150.0), closeTo(630.0, 1e-9));
    });

    test('phase shift duration matches tuning intangibility window', () {
      expect(
        FallDueRules.phaseShiftDuration(),
        equals(FallDueTuning.phaseShiftDuration),
      );
      expect(FallDueRules.phaseShiftDuration(), closeTo(0.40, 1e-9));
      expect(FallDueRules.phaseShiftDuration(), greaterThan(0.0));
      expect(FallDueRules.phaseShiftDuration(), lessThan(1.0));
    });

    test(
      'escape mechanism tuning bounds maintain balanced arcade traversal',
      () {
        expect(FallDueTuning.repulsorRadius, equals(130.0));
        expect(FallDueTuning.repulsorRadius, greaterThan(100.0));
        expect(FallDueTuning.repulsorRadius, lessThan(200.0));

        expect(FallDueTuning.tetherMaxDistance, equals(240.0));
        expect(FallDueTuning.tetherMaxDistance, greaterThan(200.0));
        expect(FallDueTuning.tetherMaxDistance, lessThan(300.0));

        expect(FallDueTuning.phaseShiftDuration, equals(0.40));
        expect(FallDueTuning.phaseShiftDuration, greaterThan(0.20));
        expect(FallDueTuning.phaseShiftDuration, lessThan(0.80));

        expect(FallDueTuning.repulsorStunDuration, equals(1.20));
        expect(FallDueTuning.repulsorStunDuration, greaterThan(0.50));
        expect(FallDueTuning.repulsorStunDuration, lessThan(2.00));

        expect(FallDueTuning.wallSlideSpeed, equals(180.0));
        expect(FallDueTuning.wallSlideSpeed, lessThan(FallDueTuning.runSpeed));
        expect(
          FallDueTuning.wallSlideSpeed,
          lessThan(FallDueTuning.terminalVelocity),
        );

        expect(FallDueTuning.gravityWellPull, equals(450.0));
        expect(FallDueTuning.laserDamage, equals(100.0));
      },
    );
  });

  group('Fall Due puzzles and interactive mechanisms', () {
    test('conduit power connection requires non-empty all-aligned array', () {
      // Empty alignment returns false
      expect(FallDueRules.conduitPowerConnected([]), isFalse);

      // Single aligned connection
      expect(FallDueRules.conduitPowerConnected([1]), isTrue);

      // Multi-node aligned connection
      expect(FallDueRules.conduitPowerConnected([1, 1]), isTrue);
      expect(FallDueRules.conduitPowerConnected([1, 1, 1]), isTrue);
      expect(FallDueRules.conduitPowerConnected([1, 1, 1, 1]), isTrue);

      // Any unaligned node breaks connection
      expect(FallDueRules.conduitPowerConnected([0]), isFalse);
      expect(FallDueRules.conduitPowerConnected([1, 0]), isFalse);
      expect(FallDueRules.conduitPowerConnected([0, 1]), isFalse);
      expect(FallDueRules.conduitPowerConnected([1, 1, 0, 1]), isFalse);
      expect(FallDueRules.conduitPowerConnected([1, 2, 1]), isFalse);
      expect(FallDueRules.conduitPowerConnected([-1, 1, 1]), isFalse);
    });

    test(
      'weight anchor is satisfied when weight meets or exceeds anchor debt',
      () {
        // Below anchor threshold (anchorDebt = 10.0)
        expect(FallDueRules.weightAnchorSatisfied(0.0), isFalse);
        expect(FallDueRules.weightAnchorSatisfied(5.0), isFalse);
        expect(FallDueRules.weightAnchorSatisfied(9.99), isFalse);
        expect(FallDueRules.weightAnchorSatisfied(-5.0), isFalse);

        // Exactly at anchor threshold
        expect(
          FallDueRules.weightAnchorSatisfied(FallDueTuning.anchorDebt),
          isTrue,
        );

        // Exceeding anchor threshold
        expect(FallDueRules.weightAnchorSatisfied(10.01), isTrue);
        expect(FallDueRules.weightAnchorSatisfied(25.0), isTrue);
        expect(FallDueRules.weightAnchorSatisfied(100.0), isTrue);
      },
    );
  });

  group('Fall Due interaction, combat, and spatial range hierarchy', () {
    test(
      'slam descent velocity, shockwaves, and concussion forces scale consistently',
      () {
        // Slam initiation threshold
        expect(FallDueRules.canInitiateSlam(0.0), isFalse);
        expect(FallDueRules.canInitiateSlam(7.99), isFalse);
        expect(FallDueRules.canInitiateSlam(8.0), isTrue);
        expect(FallDueRules.canInitiateSlam(100.0), isTrue);

        // Slam descent speed scaling
        expect(FallDueRules.slamDescentSpeed(0.0), closeTo(640.0, 1e-9));
        expect(FallDueRules.slamDescentSpeed(50.0), closeTo(860.0, 1e-9));
        expect(FallDueRules.slamDescentSpeed(100.0), closeTo(1080.0, 1e-9));
        expect(FallDueRules.slamDescentSpeed(-10.0), closeTo(640.0, 1e-9));
        expect(FallDueRules.slamDescentSpeed(150.0), closeTo(1080.0, 1e-9));

        // Shockwave generation threshold (>= 70 borrow power)
        expect(FallDueRules.slamCausesShockwave(0.0), isFalse);
        expect(FallDueRules.slamCausesShockwave(69.99), isFalse);
        expect(FallDueRules.slamCausesShockwave(70.0), isTrue);
        expect(FallDueRules.slamCausesShockwave(100.0), isTrue);

        // Concussion radius: 70.0 to 90.0
        expect(FallDueRules.slamConcussionRadius(0.0), closeTo(70.0, 1e-9));
        expect(FallDueRules.slamConcussionRadius(50.0), closeTo(80.0, 1e-9));
        expect(FallDueRules.slamConcussionRadius(100.0), closeTo(90.0, 1e-9));
        expect(FallDueRules.slamConcussionRadius(-10.0), closeTo(70.0, 1e-9));
        expect(FallDueRules.slamConcussionRadius(150.0), closeTo(90.0, 1e-9));

        // Concussion push: 70.0 to 100.0
        expect(FallDueRules.slamConcussionPush(0.0), closeTo(70.0, 1e-9));
        expect(FallDueRules.slamConcussionPush(50.0), closeTo(85.0, 1e-9));
        expect(FallDueRules.slamConcussionPush(100.0), closeTo(100.0, 1e-9));
        expect(FallDueRules.slamConcussionPush(-10.0), closeTo(70.0, 1e-9));
        expect(FallDueRules.slamConcussionPush(150.0), closeTo(100.0, 1e-9));
      },
    );

    test('spatial range hierarchy coordinates tether, parry, and repulsor radii', () {
      // Range hierarchy ensures intentional tactical envelopes:
      // Repulsor radius (130) < Parry range (170) < Interaction range (220) < Tether max distance (240)
      expect(
        FallDueTuning.repulsorRadius,
        lessThan(FallDueTuning.parryRange),
      );
      expect(
        FallDueTuning.parryRange,
        lessThan(FallDueTuning.interactionRange),
      );
      expect(
        FallDueTuning.interactionRange,
        lessThan(FallDueTuning.tetherMaxDistance),
      );

      // Exact values
      expect(FallDueTuning.repulsorRadius, equals(130.0));
      expect(FallDueTuning.parryRange, equals(170.0));
      expect(FallDueTuning.interactionRange, equals(220.0));
      expect(FallDueTuning.tetherMaxDistance, equals(240.0));

      // Parry reward tuning
      expect(FallDueTuning.parryBonusScore, equals(450));
    });
  });

  group('Fall Due advanced combat, bosses, and environmental mechanics', () {
    test('end bosses have 3 lives and jump/slam stuns with upward rebound', () {
      expect(FallDueRules.bossMaxLives(), equals(3));
      expect(FallDueRules.bossStompStunDuration(), equals(2.2));
      expect(FallDueRules.bossSlamStunDuration(), equals(3.8));
      expect(FallDueRules.bossSlamStunDuration(), greaterThan(FallDueRules.bossStompStunDuration()));
      expect(FallDueRules.bossStompBounceSpeed(), equals(-410.0));
      expect(FallDueRules.bossSlamBounceSpeed(), equals(-520.0));
      expect(FallDueRules.bossSlamBounceSpeed().abs(), greaterThan(FallDueRules.bossStompBounceSpeed().abs()));
    });

    test('crate pushing transfers momentum and crushes enemies at high velocity', () {
      expect(FallDueRules.crateCrushVelocityThreshold(), equals(210.0));
      expect(FallDueRules.crateCrushVelocityThreshold(), greaterThan(150.0));
      expect(FallDueRules.crateCrushVelocityThreshold(), lessThan(300.0));
    });

    test('gravity well gravitational forces and laser hazards are calibrated', () {
      expect(FallDueRules.gravityWellPullForce(), equals(450.0));
      expect(FallDueRules.laserDamage(), equals(100.0));
    });
  });

  testWidgets('Fall Due taps select a crate through the fitted viewport', (
    tester,
  ) async {
    const surface = Size(800, 600);
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: FallDuePage(level: GameLevelGenerator.generate('fall_due', 2)),
      ),
    );
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump();

    final viewport = LogicalViewport.fit(
      surface,
      const Size(FallDueTuning.viewWidth, FallDueTuning.viewHeight),
    );
    await tester.tapAt(viewport.worldToScreen(const Offset(652, 410)));
    await tester.pump();
    expect(find.textContaining('CRATE OUT OF RANGE'), findsOneWidget);

    await tester.tap(find.text('TAKE'));
    await tester.pump();
    expect(find.textContaining('CRATE OUT OF RANGE'), findsOneWidget);

    await tester.tapAt(const Offset(350, 60));
    await tester.pump();
    expect(find.textContaining('CRATE OUT OF RANGE'), findsOneWidget);

    await tester.tapAt(viewport.worldToScreen(const Offset(450, 220)));
    await tester.pump();
    expect(find.textContaining('TARGET CLEARED'), findsOneWidget);

    // This tap is just outside the crate bounds to check the touch padding.
    await tester.tapAt(viewport.worldToScreen(const Offset(214, 410)));
    await tester.pump();
    expect(find.textContaining('SELECTED CRATE'), findsOneWidget);
    await tester.tap(find.text('TAKE'));
    await tester.pump();
    expect(find.textContaining('YELLOW CRATE UNWEIGHTED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fall Due starts, accepts borrow, slam, and pauses cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FallDuePage()));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump();

    expect(find.byType(GameStageProgressMenu), findsNothing);
    expect(find.text('JUMP'), findsNothing);
    expect(find.text('BORROW'), findsOneWidget);
    expect(find.text('SLAM'), findsOneWidget);
    expect(find.text('GIVE'), findsOneWidget);
    expect(find.text('TAKE'), findsOneWidget);
    expect(find.text('CYCLE'), findsNothing);
    expect(find.text('HEARTS'), findsOneWidget);
    expect(find.text('SEALS'), findsOneWidget);
    expect(find.text('PAYBACK'), findsNothing);

    // Test tapping SLAM
    await tester.tap(find.text('SLAM'));
    await tester.pump(const Duration(milliseconds: 50));

    final borrow = await tester.startGesture(
      tester.getCenter(find.text('BORROW')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await borrow.up();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Fall Due handles keyboard shortcuts for phase shift and repulsor burst', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FallDuePage()));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump();

    // Trigger Phase Shift via 'P'
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('PHASE SHIFT ENGAGED'), findsOneWidget);

    // Trigger Kinetic Repulsor Shield Burst via 'R'
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.pump();
    expect(find.textContaining('KINETIC REPULSOR SHIELD BURST'), findsOneWidget);

    // Trigger Tether via 'T'
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
