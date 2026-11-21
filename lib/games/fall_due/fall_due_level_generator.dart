part of 'fall_due_game.dart';

/// Deterministic procedural level generator for Fall Due.
///
/// Builds expansive, multi-tiered stages spanning 5,000 to 8,500+ logical pixels
/// with diverse spatial challenges: moving elevator shafts, kinetic spike chasms,
/// crossfire parry gauntlets, fracture trenches, and collector combat arenas.
abstract final class _FallDueLevelGenerator {
  /// Generates a full contract stage for a given index (0-based).
  static _DueStage generateStage(int index, {DifficultyCurve? difficultyCurve}) {
    final run = index >= _FallDueGame.stages.length
        ? index - _FallDueGame.stages.length + 1
        : index + 1;
    final seed = 0xA4F281B ^ (index * 0x9E3779B9);
    final rng = math.Random(seed);
    final curveScale = difficultyCurve?.scale(run - 1, start: 1.0) ?? 1.0;
    final difficulty = (1.0 + run * 0.06 + (curveScale - 1.0) * 0.4).clamp(1.0, 2.4);

    final title = _generateStageTitle(run, rng);
    final briefing = _generateStageBriefing(run, rng);

    // 1. Opening Section (0 - 1800 px)
    final openingPlatforms = <Rect>[
      const Rect.fromLTWH(-40, 430, 320, 110),
      const Rect.fromLTWH(420, 430, 260, 110),
      const Rect.fromLTWH(860, 430, 280, 110),
      const Rect.fromLTWH(1320, 430, 540, 110),
      // Stepped approach shelves
      const Rect.fromLTWH(340, 340, 130, 18),
      const Rect.fromLTWH(1180, 325, 140, 18),
    ];

    final openingSpikes = <Rect>[
      const Rect.fromLTWH(280, 465, 140, 55),
      const Rect.fromLTWH(1140, 465, 180, 55),
    ];

    final openingTargets = <_DueTargetSpec>[
      const _DueTargetSpec(180, 390, _TargetKind.crate),
      _DueTargetSpec(560, 388, _TargetKind.enemy),
      const _DueTargetSpec(910, 390, _TargetKind.crate),
      _DueTargetSpec(1060, 388, _TargetKind.heavy),
      _DueTargetSpec(780, 230, _TargetKind.drone),
      _DueTargetSpec(1240, 275, _TargetKind.archer),
      _DueTargetSpec(1680, 388, _TargetKind.swordsman),
      _DueTargetSpec(1780, 388, _TargetKind.leecher),
    ];

    final openingSeals = <Offset>[
      const Offset(220, 385),
      const Offset(400, 290),
      const Offset(810, 240),
      const Offset(1240, 230),
      const Offset(1540, 320),
    ];

    final openingSafePads = <Rect>[
      const Rect.fromLTWH(440, 423, 90, 7),
      const Rect.fromLTWH(1340, 423, 90, 7),
    ];

    final openingWeakPanels = <Rect>[
      const Rect.fromLTWH(680, 390, 180, 16),
    ];

    final openingCrumblingLedges = <Rect>[
      const Rect.fromLTWH(740, 300, 140, 18),
    ];

    final openingSpikeTraps = <_DueSpikeTrapSpec>[
      const _DueSpikeTrapSpec(680, 465, 180, 55, cycleOffset: 0.5),
    ];

    final openingVents = <_DueKineticVentSpec>[
      const _DueKineticVentSpec(1540, 420, 60, 20, isUpdraft: true),
    ];

    final openingGravityWells = <_DueGravityWellSpec>[];
    final openingLaserGates = <_DueLaserGateSpec>[];
    final openingConduits = <_DueConduitSpec>[];
    final openingWeightPlates = <_DueWeightPlateSpec>[];

    // 2. Procedural Route Segments (1850 px to 6500-8000+ px)
    final segmentCount = 3 + (run % 3); // 3 to 5 dynamic segments
    final routeSections = <_DueSectionSpec>[];
    final routePlatforms = <Rect>[];
    final routeSpikes = <Rect>[];
    final routeTargets = <_DueTargetSpec>[];
    final routeEmitters = <_DueEmitterSpec>[];
    final routePuzzles = <_GravityPuzzleSpec>[];
    final routeWeakPanels = <Rect>[];
    final routeSafePads = <Rect>[];
    final routeSeals = <Offset>[];
    final routeCrumblingLedges = <Rect>[];
    final routeSpikeTraps = <_DueSpikeTrapSpec>[];
    final routeGravityWells = <_DueGravityWellSpec>[];
    final routeLaserGates = <_DueLaserGateSpec>[];
    final routeVents = <_DueKineticVentSpec>[];
    final routeConduits = <_DueConduitSpec>[];
    final routeWeightPlates = <_DueWeightPlateSpec>[];

    var currentX = 1860.0;
    var puzzleIdCounter = 1000 + run * 10;

    // Shuffle archetypes for this run
    final archetypePool = <_SegmentType>[
      _SegmentType.ascentShaft,
      _SegmentType.chasmBridge,
      _SegmentType.crossfireGauntlet,
      _SegmentType.fractureTrench,
      _SegmentType.collectorArena,
    ]..shuffle(rng);

    for (var i = 0; i < segmentCount; i++) {
      final type = archetypePool[i % archetypePool.length];
      final segmentStart = currentX;

      switch (type) {
        case _SegmentType.ascentShaft:
          final puzzleId = puzzleIdCounter++;
          _buildAscentShaft(
            rng: rng,
            startX: segmentStart,
            puzzleId: puzzleId,
            difficulty: difficulty,
            outPlatforms: routePlatforms,
            outSpikes: routeSpikes,
            outTargets: routeTargets,
            outPuzzles: routePuzzles,
            outSeals: routeSeals,
            outSafePads: routeSafePads,
            outCrumblingLedges: routeCrumblingLedges,
            outVents: routeVents,
            outWeightPlates: routeWeightPlates,
          );
          routeSections.add(
            _DueSectionSpec(
              segmentStart,
              'ASCENSION SHAFT ${i + 1}',
              'Take gravity from the audit crate to float it upward and latch the overhead gate lever.',
            ),
          );
          currentX += 1300.0;

        case _SegmentType.chasmBridge:
          _buildChasmBridge(
            rng: rng,
            startX: segmentStart,
            difficulty: difficulty,
            outPlatforms: routePlatforms,
            outSpikes: routeSpikes,
            outTargets: routeTargets,
            outSeals: routeSeals,
            outWeakPanels: routeWeakPanels,
            outSafePads: routeSafePads,
            outSpikeTraps: routeSpikeTraps,
            outGravityWells: routeGravityWells,
            outCrumblingLedges: routeCrumblingLedges,
          );
          routeSections.add(
            _DueSectionSpec(
              segmentStart,
              'KINETIC CHASM ${i + 1}',
              'Give gravity to the loose crate and push it into the deep spike bed to build a safe bridge.',
            ),
          );
          currentX += 1250.0;

        case _SegmentType.crossfireGauntlet:
          _buildCrossfireGauntlet(
            rng: rng,
            startX: segmentStart,
            difficulty: difficulty,
            outPlatforms: routePlatforms,
            outSpikes: routeSpikes,
            outTargets: routeTargets,
            outEmitters: routeEmitters,
            outSeals: routeSeals,
            outSafePads: routeSafePads,
            outLaserGates: routeLaserGates,
            outSpikeTraps: routeSpikeTraps,
            outVents: routeVents,
          );
          routeSections.add(
            _DueSectionSpec(
              segmentStart,
              'CROSSFIRE GAUNTLET ${i + 1}',
              'Time your moves between turret bursts. Use Take to parry plasma back at emitters, or Slam to clear the floor.',
            ),
          );
          currentX += 1350.0;

        case _SegmentType.fractureTrench:
          _buildFractureTrench(
            rng: rng,
            startX: segmentStart,
            difficulty: difficulty,
            outPlatforms: routePlatforms,
            outSpikes: routeSpikes,
            outTargets: routeTargets,
            outWeakPanels: routeWeakPanels,
            outSeals: routeSeals,
            outSafePads: routeSafePads,
            outCrumblingLedges: routeCrumblingLedges,
            outGravityWells: routeGravityWells,
            outWeightPlates: routeWeightPlates,
          );
          routeSections.add(
            _DueSectionSpec(
              segmentStart,
              'FRACTURE TRENCH ${i + 1}',
              'Build up Payback through aerial Borrow, then perform a Kinetic Slam to shatter through brittle floors.',
            ),
          );
          currentX += 1200.0;

        case _SegmentType.collectorArena:
          _buildCollectorArena(
            rng: rng,
            startX: segmentStart,
            difficulty: difficulty,
            outPlatforms: routePlatforms,
            outSpikes: routeSpikes,
            outTargets: routeTargets,
            outSeals: routeSeals,
            outSafePads: routeSafePads,
            outGravityWells: routeGravityWells,
            outLaserGates: routeLaserGates,
            outConduits: routeConduits,
            outWeightPlates: routeWeightPlates,
          );
          routeSections.add(
            _DueSectionSpec(
              segmentStart,
              'COLLECTOR COMMISSARY ${i + 1}',
              'Give weight to shove patrolling collectors off ledges, or Take weight to launch them into each other.',
            ),
          );
          currentX += 1250.0;
      }
    }

    // 3. Final Vault Landing & Exit Platform
    final vaultStart = currentX;
    routePlatforms.add(Rect.fromLTWH(vaultStart, 430, 480, 110));
    routeSafePads.add(Rect.fromLTWH(vaultStart + 60, 423, 100, 7));
    routeSeals.add(Offset(vaultStart + 180, 385));
    routeSeals.add(Offset(vaultStart + 320, 330));

    final finalExit = Rect.fromLTWH(vaultStart + 360, 350, 56, 80);

    return _DueStage(
      title: title,
      briefing: briefing,
      platforms: openingPlatforms,
      spikes: openingSpikes,
      targets: openingTargets,
      seals: openingSeals,
      safeDebtPads: openingSafePads,
      weakPanels: openingWeakPanels,
      crumblingLedges: openingCrumblingLedges,
      spikeTraps: openingSpikeTraps,
      gravityWells: openingGravityWells,
      laserGates: openingLaserGates,
      vents: openingVents,
      conduits: openingConduits,
      weightPlates: openingWeightPlates,
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: _DueRoute(
        sections: routeSections,
        platforms: routePlatforms,
        spikes: routeSpikes,
        targets: routeTargets,
        emitters: routeEmitters,
        gravityPuzzles: routePuzzles,
        weakPanels: routeWeakPanels,
        safeDebtPads: routeSafePads,
        seals: routeSeals,
        crumblingLedges: routeCrumblingLedges,
        spikeTraps: routeSpikeTraps,
        gravityWells: routeGravityWells,
        laserGates: routeLaserGates,
        vents: routeVents,
        conduits: routeConduits,
        weightPlates: routeWeightPlates,
        exit: finalExit,
      ),
    );
  }

  /// Builds a dynamic, cohesive campaign annex extension (1,400 to 2,800+ px)
  /// tailored to the campaign mission's story beat, gameplay focus, and difficulty.
  static _DueAnnexData generateAnnex({
    required int campaignLevel,
    required int campaignSeed,
    required double lengthMultiplier,
    required double startX,
  }) {
    final rng = math.Random(campaignSeed ^ (campaignLevel * 0x9E3779B9));
    final difficulty = (1.0 + campaignLevel * 0.05).clamp(1.0, 2.0);
    final beats = 2 + (campaignLevel > 10 ? 1 : 0);

    final platforms = <Rect>[];
    final spikes = <Rect>[];
    final targets = <_DueTargetSpec>[];
    final emitters = <_DueEmitterSpec>[];
    final seals = <Offset>[];
    final weakPanels = <Rect>[];
    final safeDebtPads = <Rect>[];
    final crumblingLedges = <Rect>[];
    final spikeTraps = <_DueSpikeTrapSpec>[];
    final gravityWells = <_DueGravityWellSpec>[];
    final laserGates = <_DueLaserGateSpec>[];
    final vents = <_DueKineticVentSpec>[];
    final conduits = <_DueConduitSpec>[];
    final weightPlates = <_DueWeightPlateSpec>[];

    var curX = startX;

    for (var b = 0; b < beats; b++) {
      final beatType = b % 3;
      final segLen = (680.0 + rng.nextInt(260)) * lengthMultiplier;

      // Base solid foundation
      platforms.add(Rect.fromLTWH(curX, 430, segLen * 0.42, 110));
      // Spike bed gap (beatType 1 uses timed pneumatic spike traps instead of static spikes)
      final spikeGap = (120.0 + rng.nextDouble() * 100).clamp(100.0, 220.0);
      if (beatType != 1) {
        spikes.add(Rect.fromLTWH(curX + segLen * 0.42, 465, spikeGap, 55));
      }
      // Receiving solid platform
      platforms.add(
        Rect.fromLTWH(
          curX + segLen * 0.42 + spikeGap,
          430,
          segLen - (segLen * 0.42 + spikeGap),
          110,
        ),
      );

      // Elevated shelves
      final shelfY = 250.0 + rng.nextDouble() * 70;
      platforms.add(Rect.fromLTWH(curX + segLen * 0.28, shelfY, 140, 18));
      platforms.add(Rect.fromLTWH(curX + segLen * 0.65, shelfY - 45, 130, 18));

      // Items & Hazards based on beat
      if (beatType == 0) {
        // Crate + Safe Pad beat
        targets.add(_DueTargetSpec(curX + 50, 390, _TargetKind.crate));
        safeDebtPads.add(Rect.fromLTWH(curX + 130, 423, 90, 7));
        weakPanels.add(
          Rect.fromLTWH(curX + segLen * 0.42, 390, spikeGap, 16),
        );
        crumblingLedges.add(
          Rect.fromLTWH(curX + segLen * 0.45, shelfY - 20, 110, 16),
        );
        vents.add(
          _DueKineticVentSpec(
            curX + segLen * 0.38,
            420,
            50,
            20,
            isUpdraft: true,
            cycleOffset: b * 0.5,
          ),
        );
      } else if (beatType == 1) {
        // Enforcer or Swordsman patrol on launch dais + Drone/Archer + receiving laser gate
        final enemyKind = difficulty > 1.4 && rng.nextBool()
            ? _TargetKind.heavy
            : (rng.nextBool() ? _TargetKind.swordsman : _TargetKind.enemy);
        targets.add(_DueTargetSpec(curX + segLen * 0.22, 388, enemyKind));
        if (difficulty > 1.3 && rng.nextBool()) {
          targets.add(
            _DueTargetSpec(
              curX + segLen * 0.65,
              shelfY - 45,
              rng.nextBool() ? _TargetKind.archer : _TargetKind.drone,
            ),
          );
        }
        emitters.add(
          _DueEmitterSpec(
            curX + segLen * 0.88,
            396,
            -250.0,
            (1.5 / difficulty).clamp(0.7, 1.8),
          ),
        );
        laserGates.add(
          _DueLaserGateSpec(
            curX + segLen * 0.68,
            200,
            24,
            230,
            cycleOffset: b * 0.7,
          ),
        );
        spikeTraps.add(
          _DueSpikeTrapSpec(
            curX + segLen * 0.42,
            465,
            spikeGap,
            55,
            cycleOffset: b * 0.4,
          ),
        );
      } else {
        // Mixed enemy assault + aerial seals
        final flyer = difficulty > 1.2 && rng.nextBool()
            ? _TargetKind.drone
            : _TargetKind.leecher;
        targets.add(_DueTargetSpec(curX + 90, 388, _TargetKind.enemy));
        targets.add(_DueTargetSpec(curX + segLen * 0.7, 240, flyer));
        gravityWells.add(
          _DueGravityWellSpec(curX + segLen * 0.5, 230, radius: 150.0),
        );
        weightPlates.add(
          _DueWeightPlateSpec(2000 + b, curX + segLen * 0.2, 423, 80, 8),
        );
      }

      seals.add(Offset(curX + segLen * 0.35, shelfY - 22));
      seals.add(Offset(curX + segLen * 0.72, shelfY - 67));

      curX += segLen;
    }

    // Annex final vault dais
    platforms.add(Rect.fromLTWH(curX, 430, 360, 110));
    safeDebtPads.add(Rect.fromLTWH(curX + 40, 423, 90, 7));
    seals.add(Offset(curX + 160, 385));
    final exit = Rect.fromLTWH(curX + 240, 350, 56, 80);

    return _DueAnnexData(
      platforms: platforms,
      spikes: spikes,
      targets: targets,
      emitters: emitters,
      seals: seals,
      weakPanels: weakPanels,
      safeDebtPads: safeDebtPads,
      crumblingLedges: crumblingLedges,
      spikeTraps: spikeTraps,
      gravityWells: gravityWells,
      laserGates: laserGates,
      vents: vents,
      conduits: conduits,
      weightPlates: weightPlates,
      exit: exit,
    );
  }

  // --- Segment Builders ---

  static void _buildAscentShaft({
    required math.Random rng,
    required double startX,
    required int puzzleId,
    required double difficulty,
    required List<Rect> outPlatforms,
    required List<Rect> outSpikes,
    required List<_DueTargetSpec> outTargets,
    required List<_GravityPuzzleSpec> outPuzzles,
    required List<Offset> outSeals,
    required List<Rect> outSafePads,
    required List<Rect> outCrumblingLedges,
    required List<_DueKineticVentSpec> outVents,
    required List<_DueWeightPlateSpec> outWeightPlates,
  }) {
    // Left dais
    outPlatforms.add(Rect.fromLTWH(startX, 430, 240, 110));
    // Shaft spike pit
    outSpikes.add(Rect.fromLTWH(startX + 240, 465, 180, 55));
    // Shaft mid floor
    outPlatforms.add(Rect.fromLTWH(startX + 420, 430, 260, 110));
    // Second gap with spikes
    outSpikes.add(Rect.fromLTWH(startX + 680, 465, 160, 55));
    // Landing floor before gate
    outPlatforms.add(Rect.fromLTWH(startX + 840, 430, 460, 110));

    // Multi-tier climbing shelves inside the shaft
    outPlatforms.add(Rect.fromLTWH(startX + 300, 355, 135, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 480, 290, 140, 18));
    outCrumblingLedges.add(Rect.fromLTWH(startX + 660, 230, 135, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 860, 175, 160, 18));

    // Updraft kinetic vent to propel upward to high crumbling shelf
    outVents.add(
      _DueKineticVentSpec(startX + 590, 420, 60, 20, isUpdraft: true),
    );

    // Weight plate
    outWeightPlates.add(
      _DueWeightPlateSpec(puzzleId + 10, startX + 440, 423, 80, 7),
    );

    // Gravity puzzle: unweight crate to float to overhead lever
    final leverY = 205.0 + rng.nextDouble() * 25;
    outPuzzles.add(
      _GravityPuzzleSpec(
        id: puzzleId,
        boxPosition: Offset(startX + 460, 390),
        leverPosition: Offset(startX + 490, leverY),
        gate: Rect.fromLTWH(startX + 1060, 145, 32, 285),
      ),
    );

    // Stalking leecher on mid-shelf guarding elevator route
    outTargets.add(
      _DueTargetSpec(startX + 520, 248, _TargetKind.leecher),
    );

    // High seals along the elevator trajectory
    outSeals.add(Offset(startX + 360, 310));
    outSeals.add(Offset(startX + 550, 170));
    outSeals.add(Offset(startX + 730, 185));
    outSeals.add(Offset(startX + 1150, 385));

    outSafePads.add(Rect.fromLTWH(startX + 900, 423, 90, 7));
  }

  static void _buildChasmBridge({
    required math.Random rng,
    required double startX,
    required double difficulty,
    required List<Rect> outPlatforms,
    required List<Rect> outSpikes,
    required List<_DueTargetSpec> outTargets,
    required List<Offset> outSeals,
    required List<Rect> outWeakPanels,
    required List<Rect> outSafePads,
    required List<_DueSpikeTrapSpec> outSpikeTraps,
    required List<_DueGravityWellSpec> outGravityWells,
    required List<Rect> outCrumblingLedges,
  }) {
    // Launch ledge
    outPlatforms.add(Rect.fromLTWH(startX, 430, 260, 110));
    // Vast spike chasm requiring bridge anchor (pneumatic trap bed that crushes to bridge)
    final chasmWidth = (280.0 + rng.nextDouble() * 80).clamp(260.0, 360.0);
    outSpikeTraps.add(
      _DueSpikeTrapSpec(
        startX + 260,
        465,
        chasmWidth,
        55,
        cycleOffset: 0.2,
      ),
    );
    // Island platform
    outPlatforms.add(
      Rect.fromLTWH(startX + 260 + chasmWidth, 430, 240, 110),
    );
    // Secondary spike pit
    outSpikes.add(
      Rect.fromLTWH(startX + 500 + chasmWidth, 465, 160, 55),
    );
    // Reception runway
    outPlatforms.add(
      Rect.fromLTWH(startX + 660 + chasmWidth, 430, 330, 110),
    );

    // Upper bypass / high-wire platforms
    outPlatforms.add(Rect.fromLTWH(startX + 180, 330, 140, 18));
    outCrumblingLedges.add(Rect.fromLTWH(startX + 380, 265, 150, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 600, 315, 140, 18));

    // Elevated gravity well assisting the high-wire leap
    outGravityWells.add(
      _DueGravityWellSpec(
        startX + 260 + chasmWidth / 2,
        230,
        radius: 150.0,
      ),
    );

    // Weak panel shortcut on upper shelf bypass
    outWeakPanels.add(
      Rect.fromLTWH(startX + 520, 265, 110, 16),
    );

    // Heavy crate ready to be pushed into the chasm
    outTargets.add(_DueTargetSpec(startX + 180, 390, _TargetKind.crate));
    // Drone hovering above the spike chasm
    outTargets.add(_DueTargetSpec(startX + 380, 210, _TargetKind.drone));
    // Guard collector on the far side
    outTargets.add(
      _DueTargetSpec(
        startX + 320 + chasmWidth,
        388,
        _TargetKind.enemy,
      ),
    );

    outSeals.add(Offset(startX + 250, 285));
    outSeals.add(Offset(startX + 450, 220));
    outSeals.add(Offset(startX + 670, 270));
    outSeals.add(Offset(startX + 850 + chasmWidth, 385));

    outSafePads.add(Rect.fromLTWH(startX + 690 + chasmWidth, 423, 90, 7));
  }

  static void _buildCrossfireGauntlet({
    required math.Random rng,
    required double startX,
    required double difficulty,
    required List<Rect> outPlatforms,
    required List<Rect> outSpikes,
    required List<_DueTargetSpec> outTargets,
    required List<_DueEmitterSpec> outEmitters,
    required List<Offset> outSeals,
    required List<Rect> outSafePads,
    required List<_DueLaserGateSpec> outLaserGates,
    required List<_DueSpikeTrapSpec> outSpikeTraps,
    required List<_DueKineticVentSpec> outVents,
  }) {
    // Stepped floor terrain with trenches for dodging shots
    outPlatforms.add(Rect.fromLTWH(startX, 430, 280, 110));
    outSpikeTraps.add(
      _DueSpikeTrapSpec(startX + 280, 465, 140, 55, cycleOffset: 0.8),
    );
    outPlatforms.add(Rect.fromLTWH(startX + 420, 430, 320, 110));
    outSpikes.add(Rect.fromLTWH(startX + 740, 465, 150, 55));
    outPlatforms.add(Rect.fromLTWH(startX + 890, 430, 460, 110));

    // Raised barricades and cover shelves
    outPlatforms.add(Rect.fromLTWH(startX + 220, 335, 130, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 520, 280, 150, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 760, 330, 140, 18));

    // Laser gate crossing the crossfire lane
    outLaserGates.add(
      _DueLaserGateSpec(
        startX + 680,
        210,
        20,
        220,
        switchId: 100,
        cycleOffset: 0.5,
      ),
    );

    // Downdraft vent to impede high jumps
    outVents.add(
      _DueKineticVentSpec(
        startX + 1040,
        420,
        60,
        20,
        isUpdraft: false,
        cycleOffset: 1.0,
      ),
    );

    // Dual opposing emitters (true crossfire: left fires right, right fires left)
    final interval = (1.6 / difficulty).clamp(0.75, 1.8);
    outEmitters.add(
      _DueEmitterSpec(startX + 520, 260, 260.0, interval),
    );
    outEmitters.add(
      _DueEmitterSpec(startX + 1280, 396, -260.0, interval + 0.15),
    );

    // Crate on Floor 2 ready to use as mobile shield or projectile block
    outTargets.add(_DueTargetSpec(startX + 460, 390, _TargetKind.crate));
    // Collectors in the crossfire lane + Drone flyer + Archer sniper
    outTargets.add(_DueTargetSpec(startX + 590, 388, _TargetKind.swordsman));
    outTargets.add(_DueTargetSpec(startX + 780, 240, _TargetKind.drone));
    outTargets.add(_DueTargetSpec(startX + 980, 388, _TargetKind.archer));

    outSafePads.add(Rect.fromLTWH(startX + 1200, 423, 90, 7));

    outSeals.add(Offset(startX + 280, 290));
    outSeals.add(Offset(startX + 590, 235));
    outSeals.add(Offset(startX + 830, 285));
    outSeals.add(Offset(startX + 1220, 385));
  }

  static void _buildFractureTrench({
    required math.Random rng,
    required double startX,
    required double difficulty,
    required List<Rect> outPlatforms,
    required List<Rect> outSpikes,
    required List<_DueTargetSpec> outTargets,
    required List<Rect> outWeakPanels,
    required List<Offset> outSeals,
    required List<Rect> outSafePads,
    required List<Rect> outCrumblingLedges,
    required List<_DueGravityWellSpec> outGravityWells,
    required List<_DueWeightPlateSpec> outWeightPlates,
  }) {
    outPlatforms.add(Rect.fromLTWH(startX, 430, 240, 110));
    outSpikes.add(Rect.fromLTWH(startX + 240, 465, 200, 55));
    outPlatforms.add(Rect.fromLTWH(startX + 440, 430, 220, 110));
    outSpikes.add(Rect.fromLTWH(startX + 660, 465, 200, 55));
    outPlatforms.add(Rect.fromLTWH(startX + 860, 430, 340, 110));

    // Multi-layer brittle rust panels designed for Slam destruction
    outWeakPanels.add(Rect.fromLTWH(startX + 240, 385, 200, 16));
    outWeakPanels.add(Rect.fromLTWH(startX + 660, 385, 200, 16));

    // High staging ledges for building payback momentum
    outPlatforms.add(Rect.fromLTWH(startX + 180, 280, 140, 18));
    outCrumblingLedges.add(Rect.fromLTWH(startX + 380, 220, 160, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 600, 280, 140, 18));

    // Gravity well elevated above trench
    outGravityWells.add(
      _DueGravityWellSpec(startX + 550, 220, radius: 140.0),
    );

    // Weight plate
    outWeightPlates.add(
      _DueWeightPlateSpec(3000 + (startX ~/ 100), startX + 450, 423, 80, 7),
    );

    outTargets.add(_DueTargetSpec(startX + 140, 390, _TargetKind.crate));
    // Heavy Enforcer guarding the fracture zone
    outTargets.add(_DueTargetSpec(startX + 600, 388, _TargetKind.heavy));
    outTargets.add(_DueTargetSpec(startX + 950, 388, _TargetKind.enemy));

    // Safe pad on the reception runway after completing the trench
    outSafePads.add(Rect.fromLTWH(startX + 920, 423, 90, 7));

    outSeals.add(Offset(startX + 250, 235));
    outSeals.add(Offset(startX + 460, 175));
    outSeals.add(Offset(startX + 670, 235));
    outSeals.add(Offset(startX + 1020, 385));
  }

  static void _buildCollectorArena({
    required math.Random rng,
    required double startX,
    required double difficulty,
    required List<Rect> outPlatforms,
    required List<Rect> outSpikes,
    required List<_DueTargetSpec> outTargets,
    required List<Offset> outSeals,
    required List<Rect> outSafePads,
    required List<_DueGravityWellSpec> outGravityWells,
    required List<_DueLaserGateSpec> outLaserGates,
    required List<_DueConduitSpec> outConduits,
    required List<_DueWeightPlateSpec> outWeightPlates,
  }) {
    // Broad, tiered combat arena
    outPlatforms.add(Rect.fromLTWH(startX, 430, 380, 110));
    outSpikes.add(Rect.fromLTWH(startX + 380, 465, 140, 55));
    outPlatforms.add(Rect.fromLTWH(startX + 520, 430, 420, 110));
    outSpikes.add(Rect.fromLTWH(startX + 940, 465, 130, 55));
    outPlatforms.add(Rect.fromLTWH(startX + 1070, 430, 180, 110));

    // Staggered battle ledges
    outPlatforms.add(Rect.fromLTWH(startX + 160, 340, 150, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 380, 275, 150, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 620, 335, 160, 18));
    outPlatforms.add(Rect.fromLTWH(startX + 840, 270, 140, 18));

    // Gravity well centered above battle arena
    outGravityWells.add(
      _DueGravityWellSpec(startX + 680, 240, radius: 160.0),
    );

    // Laser barrier
    outLaserGates.add(
      _DueLaserGateSpec(startX + 920, 200, 20, 230, cycleOffset: 1.2),
    );

    // Conduit puzzle
    outConduits.add(
      _DueConduitSpec(
        4000 + (startX ~/ 100),
        Offset(startX + 180, 330),
        Offset(startX + 820, 330),
        [1, 2, 3],
      ),
    );

    // Weight plate on right side of combat arena
    outWeightPlates.add(
      _DueWeightPlateSpec(5000 + (startX ~/ 100), startX + 820, 423, 80, 7),
    );

    // Elite forces with clear combat corridors:
    outTargets.add(_DueTargetSpec(startX + 220, 388, _TargetKind.swordsman));
    outTargets.add(_DueTargetSpec(startX + 740, 388, _TargetKind.heavy));
    outTargets.add(_DueTargetSpec(startX + 450, 200, _TargetKind.drone));
    outTargets.add(_DueTargetSpec(startX + 880, 225, _TargetKind.leecher));
    outTargets.add(_DueTargetSpec(startX + 1110, 388, _TargetKind.archer));

    // Crate to fling into enemies or use as shield
    outTargets.add(_DueTargetSpec(startX + 650, 390, _TargetKind.crate));

    outSafePads.add(Rect.fromLTWH(startX + 530, 423, 90, 7));

    outSeals.add(Offset(startX + 230, 295));
    outSeals.add(Offset(startX + 455, 230));
    outSeals.add(Offset(startX + 700, 290));
    outSeals.add(Offset(startX + 910, 225));
    outSeals.add(Offset(startX + 1140, 385));
  }

  static String _generateStageTitle(int run, math.Random rng) {
    const prefixes = [
      'KINETIC',
      'GRAVITY',
      'SETTLEMENT',
      'PRESSURE',
      'VECTOR',
      'RESONANCE',
      'MOMENTUM',
      'COUNTERWEIGHT',
      'AUDIT',
      'COLLATERAL',
    ];
    const suffixes = [
      'VAULT',
      'ASCENSION',
      'CONVERGENCE',
      'EXPEDITION',
      'CHASM',
      'SHAFT',
      'CORRIDOR',
      'BASTION',
      'TRENCH',
      'TERMINUS',
    ];
    final prefix = prefixes[rng.nextInt(prefixes.length)];
    final suffix = suffixes[rng.nextInt(suffixes.length)];
    return '$prefix $suffix $run';
  }

  static String _generateStageBriefing(int run, math.Random rng) {
    const briefings = [
      'Sprawling multi-tier facility. Coordinate unweighted elevator lifts, anchor bridges over long chasms, and parry incoming plasma fire.',
      'High-altitude gravity audit. Build payback momentum to smash weak floors, or discharge into a radial Kinetic Slam to neutralize collectors.',
      'Heavy-debt sector. Use Give to anchor moving bridges and Take to slingshot skyward through interlocking security gates.',
      'Hostile crossfire zone. Deflect turret bullets back into collectors, or drop heavy crates from overhead gantries to clear the route.',
    ];
    return briefings[rng.nextInt(briefings.length)];
  }
}

enum _SegmentType {
  ascentShaft,
  chasmBridge,
  crossfireGauntlet,
  fractureTrench,
  collectorArena,
}

class _DueAnnexData {
  const _DueAnnexData({
    required this.platforms,
    required this.spikes,
    required this.targets,
    required this.emitters,
    required this.seals,
    required this.weakPanels,
    required this.safeDebtPads,
    required this.exit,
    this.crumblingLedges = const [],
    this.spikeTraps = const [],
    this.gravityWells = const [],
    this.laserGates = const [],
    this.vents = const [],
    this.conduits = const [],
    this.weightPlates = const [],
  });

  final List<Rect> platforms;
  final List<Rect> spikes;
  final List<_DueTargetSpec> targets;
  final List<_DueEmitterSpec> emitters;
  final List<Offset> seals;
  final List<Rect> weakPanels;
  final List<Rect> safeDebtPads;
  final List<Rect> crumblingLedges;
  final List<_DueSpikeTrapSpec> spikeTraps;
  final List<_DueGravityWellSpec> gravityWells;
  final List<_DueLaserGateSpec> laserGates;
  final List<_DueKineticVentSpec> vents;
  final List<_DueConduitSpec> conduits;
  final List<_DueWeightPlateSpec> weightPlates;
  final Rect exit;
}
