part of 'fall_due_game.dart';

enum _DuePhase { intro, playing, stageClear, dead, won }

class _FallDueGame {
  static const viewWidth = FallDueTuning.viewWidth;
  static const viewHeight = FallDueTuning.viewHeight;
  static const interactionRange = FallDueTuning.interactionRange;
  static const _contractDifficulty = DifficultyCurve(
    rampStages: 15,
    exponent: 1.15,
    endlessGrowth: .018,
  );
  static final stages = <_DueStage>[
    _DueStage(
      title: 'WEIGHT & VELOCITY',
      briefing:
          'Feather Borrow to glide and Slam to land. Push crates onto weight plates to open route blast gates.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 400, 110),
        Rect.fromLTWH(470, 430, 360, 110),
        Rect.fromLTWH(960, 430, 420, 110),
        Rect.fromLTWH(1460, 430, 500, 110),
        Rect.fromLTWH(500, 335, 140, 18),
        Rect.fromLTWH(960, 250, 150, 18),
        Rect.fromLTWH(1330, 260, 135, 18),
      ],
      spikes: const [
        Rect.fromLTWH(360, 465, 110, 55),
        Rect.fromLTWH(890, 465, 70, 55),
        Rect.fromLTWH(1380, 465, 80, 55),
      ],
      targets: const [
        _DueTargetSpec(560, 390, _TargetKind.crate),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(1, 700, 423, 85, 8),
      ],
      gravityPuzzles: const [
        _GravityPuzzleSpec(
          id: 1,
          boxPosition: Offset(560, 390),
          leverPosition: Offset(700, 270),
          gate: Rect.fromLTWH(850, 175, 30, 255),
        ),
      ],
      vents: const [
        _DueKineticVentSpec(1000, 423, 70, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(1380, 465, 80, 55, cycleOffset: 0.0),
      ],
      weakPanels: const [
        Rect.fromLTWH(1510, 335, 130, 16),
      ],
      seals: const [
        Offset(300, 390),
        Offset(700, 230),
        Offset(1035, 195),
        Offset(1395, 220),
        Offset(1740, 390),
      ],
      safeDebtPads: const [Rect.fromLTWH(1560, 423, 92, 7)],
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1900,
            'LASER OCCLUSION',
            'Push the crate down to block the laser beam, or phase shift safely across.',
          ),
          _DueSectionSpec(
            3350,
            'CRUMBLING SPAN',
            'Traverse crumbling ledges with feather Borrow hops; open the upper route gate.',
          ),
          _DueSectionSpec(
            4650,
            'SETTLEMENT VAULT',
            'Invert the gravity well to clear the final chasm, then settle debt at the safe pad.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1900, 430, 320, 110),
          Rect.fromLTWH(2300, 430, 240, 110),
          Rect.fromLTWH(2600, 430, 280, 110),
          Rect.fromLTWH(2180, 320, 130, 18),
          Rect.fromLTWH(2420, 270, 140, 18),
          Rect.fromLTWH(2980, 430, 260, 110),
          Rect.fromLTWH(3350, 430, 270, 110),
          Rect.fromLTWH(3680, 430, 130, 110),
          Rect.fromLTWH(3910, 430, 120, 110),
          Rect.fromLTWH(4140, 430, 130, 110),
          Rect.fromLTWH(4360, 430, 280, 110),
          Rect.fromLTWH(4700, 430, 220, 110),
          Rect.fromLTWH(5060, 430, 580, 110),
        ],
        spikes: [
          Rect.fromLTWH(2220, 465, 80, 55),
          Rect.fromLTWH(2540, 465, 60, 55),
          Rect.fromLTWH(2880, 465, 100, 55),
          Rect.fromLTWH(3240, 465, 110, 55),
          Rect.fromLTWH(3810, 465, 100, 55),
          Rect.fromLTWH(4270, 465, 90, 55),
          Rect.fromLTWH(4640, 465, 60, 55),
          Rect.fromLTWH(4920, 465, 140, 55),
        ],
        targets: [
          _DueTargetSpec(2220, 275, _TargetKind.crate),
          _DueTargetSpec(3450, 390, _TargetKind.crate),
        ],
        laserGates: [
          _DueLaserGateSpec(2480, 215, 20, 215, cycleOffset: 0.0),
        ],
        crumblingLedges: [
          Rect.fromLTWH(3700, 340, 130, 18),
          Rect.fromLTWH(3920, 280, 130, 18),
        ],
        vents: [
          _DueKineticVentSpec(3380, 423, 60, 16, isUpdraft: true),
        ],
        spikeTraps: [
          _DueSpikeTrapSpec(4030, 465, 110, 55, cycleOffset: 0.5),
        ],
        gravityWells: [
          _DueGravityWellSpec(4800, 340, radius: 180),
        ],
        weightPlates: [
          _DueWeightPlateSpec(11, 3500, 423, 80, 8),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 11,
            boxPosition: Offset(3450, 390),
            leverPosition: Offset(3500, 220),
            gate: Rect.fromLTWH(4300, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(2050, 390),
          Offset(2240, 220),
          Offset(2750, 380),
          Offset(3765, 290),
          Offset(4190, 380),
          Offset(5370, 390),
        ],
        safeDebtPads: [
          Rect.fromLTWH(3020, 423, 92, 7),
          Rect.fromLTWH(5150, 423, 92, 7),
        ],
        exit: Rect.fromLTWH(5600, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'KINETIC BREACH',
      briefing:
          'Slam down to shatter weak floor panels. Block laser barriers with heavy freight to advance.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 330, 110),
        Rect.fromLTWH(470, 430, 340, 110),
        Rect.fromLTWH(940, 430, 340, 110),
        Rect.fromLTWH(1430, 430, 530, 110),
        Rect.fromLTWH(510, 335, 145, 18),
        Rect.fromLTWH(985, 300, 145, 18),
        Rect.fromLTWH(1255, 350, 135, 18),
      ],
      spikes: const [
        Rect.fromLTWH(290, 465, 180, 55),
        Rect.fromLTWH(1280, 465, 150, 55),
      ],
      targets: const [
        _DueTargetSpec(220, 390, _TargetKind.crate),
        _DueTargetSpec(620, 390, _TargetKind.crate),
        _DueTargetSpec(1030, 258, _TargetKind.crate),
      ],
      weakPanels: const [
        Rect.fromLTWH(290, 370, 170, 16),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(20, 680, 423, 85, 8),
      ],
      laserGates: const [
        _DueLaserGateSpec(1180, 215, 20, 215, cycleOffset: 0.0),
      ],
      vents: const [
        _DueKineticVentSpec(1250, 423, 60, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(810, 465, 130, 55, cycleOffset: 0.3),
      ],
      gravityPuzzles: const [
        _GravityPuzzleSpec(
          id: 20,
          boxPosition: Offset(635, 390),
          leverPosition: Offset(650, 280),
          gate: Rect.fromLTWH(835, 175, 30, 255),
        ),
      ],
      seals: const [
        Offset(360, 390),
        Offset(570, 300),
        Offset(1045, 265),
        Offset(1320, 315),
        Offset(1710, 390),
      ],
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1900,
            'ANCHOR BAY',
            'Give the loose crate weight and shove it into the spike bed to bridge the crossing.',
          ),
          _DueSectionSpec(
            3400,
            'COUNTERWEIGHT TOWER',
            'Take gravity from the tower crate, ride its rise, and open the upper route lock.',
          ),
          _DueSectionSpec(
            4650,
            'HANDOFF WALK',
            'Trade weight between the final crates to cross alternating low and high lanes.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1900, 430, 300, 110),
          Rect.fromLTWH(2360, 360, 120, 18),
          Rect.fromLTWH(2590, 430, 240, 110),
          Rect.fromLTWH(2860, 365, 130, 18),
          Rect.fromLTWH(3025, 300, 135, 18),
          Rect.fromLTWH(3190, 235, 145, 18),
          Rect.fromLTWH(3380, 430, 310, 110),
          Rect.fromLTWH(3725, 430, 180, 110),
          Rect.fromLTWH(3990, 355, 130, 18),
          Rect.fromLTWH(4170, 285, 140, 18),
          Rect.fromLTWH(4360, 215, 155, 18),
          Rect.fromLTWH(4580, 430, 270, 110),
          Rect.fromLTWH(4885, 330, 135, 18),
          Rect.fromLTWH(5055, 270, 145, 18),
          Rect.fromLTWH(5230, 335, 125, 18),
          Rect.fromLTWH(5050, 430, 550, 110),
        ],
        spikes: [
          Rect.fromLTWH(2200, 465, 390, 55),
          Rect.fromLTWH(2830, 465, 170, 55),
          Rect.fromLTWH(3690, 465, 35, 55),
          Rect.fromLTWH(3905, 465, 175, 55),
          Rect.fromLTWH(4515, 465, 65, 55),
          Rect.fromLTWH(4850, 465, 200, 55),
        ],
        targets: [
          _DueTargetSpec(2110, 390, _TargetKind.crate),
          _DueTargetSpec(3760, 390, _TargetKind.crate),
          _DueTargetSpec(4750, 388, _TargetKind.enemy),
        ],
        weightPlates: [
          _DueWeightPlateSpec(21, 2680, 423, 80, 8),
        ],
        laserGates: [
          _DueLaserGateSpec(3600, 215, 20, 215, cycleOffset: 0.4),
        ],
        vents: [
          _DueKineticVentSpec(4200, 423, 60, 16, isUpdraft: true),
        ],
        crumblingLedges: [
          Rect.fromLTWH(4750, 340, 130, 18),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 21,
            boxPosition: Offset(2680, 390),
            leverPosition: Offset(2680, 218),
            gate: Rect.fromLTWH(2840, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 22,
            boxPosition: Offset(3825, 390),
            leverPosition: Offset(3825, 195),
            gate: Rect.fromLTWH(4030, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(2640, 390),
          Offset(3050, 265),
          Offset(3825, 340),
          Offset(4415, 180),
          Offset(5100, 235),
          Offset(5400, 390),
        ],
        safeDebtPads: [
          Rect.fromLTWH(2610, 423, 92, 7),
          Rect.fromLTWH(4610, 423, 92, 7),
        ],
        exit: Rect.fromLTWH(5550, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'COLLECTION DAY',
      briefing:
          'Manipulate collectors and arc shots through a stepped vault; the high line is faster but exposed.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 300, 110),
        Rect.fromLTWH(400, 430, 330, 110),
        Rect.fromLTWH(870, 430, 350, 110),
        Rect.fromLTWH(1360, 430, 600, 110),
        Rect.fromLTWH(275, 345, 135, 18),
        Rect.fromLTWH(500, 285, 145, 18),
        Rect.fromLTWH(1120, 260, 150, 18),
        Rect.fromLTWH(1440, 315, 145, 18),
      ],
      spikes: const [
        Rect.fromLTWH(260, 465, 140, 55),
        Rect.fromLTWH(1220, 465, 140, 55),
      ],
      targets: const [
        _DueTargetSpec(325, 303, _TargetKind.enemy),
        _DueTargetSpec(555, 243, _TargetKind.enemy),
        _DueTargetSpec(965, 288, _TargetKind.enemy),
        _DueTargetSpec(1490, 273, _TargetKind.enemy),
        _DueTargetSpec(1160, 390, _TargetKind.crate),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(30, 1140, 423, 85, 8),
      ],
      weakPanels: const [
        Rect.fromLTWH(915, 330, 135, 16),
      ],
      vents: const [
        _DueKineticVentSpec(650, 423, 60, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(730, 465, 140, 55, cycleOffset: 0.2),
      ],
      laserGates: const [
        _DueLaserGateSpec(1260, 215, 20, 215, cycleOffset: 0.0),
      ],
      gravityPuzzles: const [
        _GravityPuzzleSpec(
          id: 30,
          boxPosition: Offset(1035, 390),
          leverPosition: Offset(1050, 275),
          gate: Rect.fromLTWH(1300, 175, 30, 255),
        ),
      ],
      safeDebtPads: const [Rect.fromLTWH(1390, 423, 92, 7)],
      seals: const [
        Offset(330, 310),
        Offset(565, 250),
        Offset(980, 295),
        Offset(1180, 225),
        Offset(1580, 390),
      ],
      emitters: const [
        _DueEmitterSpec(700, 390, -260, 1.8),
        _DueEmitterSpec(1420, 390, 255, 2.0),
      ],
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1900,
            'PATROL CLOCK',
            'Borrow only to change lanes: collectors make the low route unsafe while the ledges stay quiet.',
          ),
          _DueSectionSpec(
            3400,
            'SHOT VAULT',
            'Wait for the firing rhythm, use the shelter ledges, and turn a turret shot heavy if the lane closes.',
          ),
          _DueSectionSpec(
            4700,
            'LAUNCH RELAY',
            'Take from a collector to send it into the last gravity lock, then sprint the cleared corridor.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1900, 430, 320, 110),
          Rect.fromLTWH(2260, 430, 250, 110),
          Rect.fromLTWH(2550, 345, 130, 18),
          Rect.fromLTWH(2720, 280, 145, 18),
          Rect.fromLTWH(2910, 430, 270, 110),
          Rect.fromLTWH(3360, 430, 190, 110),
          Rect.fromLTWH(3760, 275, 140, 18),
          Rect.fromLTWH(4140, 430, 300, 110),
          Rect.fromLTWH(4480, 430, 180, 110),
          Rect.fromLTWH(4850, 430, 260, 110),
          Rect.fromLTWH(5150, 330, 135, 18),
          Rect.fromLTWH(5320, 270, 145, 18),
          Rect.fromLTWH(5080, 430, 560, 110),
        ],
        spikes: [
          Rect.fromLTWH(2220, 465, 40, 55),
          Rect.fromLTWH(2510, 465, 220, 55),
          Rect.fromLTWH(2865, 465, 45, 55),
          Rect.fromLTWH(3180, 465, 180, 55),
          Rect.fromLTWH(3550, 465, 210, 55),
          Rect.fromLTWH(4070, 465, 70, 55),
          Rect.fromLTWH(4440, 465, 40, 55),
          Rect.fromLTWH(4660, 465, 190, 55),
          Rect.fromLTWH(5110, 465, 40, 55),
        ],
        targets: [
          _DueTargetSpec(2410, 388, _TargetKind.enemy),
          _DueTargetSpec(3040, 388, _TargetKind.enemy),
          _DueTargetSpec(4210, 388, _TargetKind.enemy),
          _DueTargetSpec(4560, 388, _TargetKind.enemy),
        ],
        weightPlates: [
          _DueWeightPlateSpec(31, 2370, 423, 80, 8),
        ],
        gravityWells: [
          _DueGravityWellSpec(3180, 350, radius: 170),
        ],
        vents: [
          _DueKineticVentSpec(4400, 423, 60, 16, isUpdraft: true),
        ],
        crumblingLedges: [
          Rect.fromLTWH(3590, 350, 120, 18),
          Rect.fromLTWH(3950, 340, 120, 18),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 31,
            boxPosition: Offset(2370, 390),
            leverPosition: Offset(2370, 205),
            gate: Rect.fromLTWH(2875, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 32,
            boxPosition: Offset(4570, 390),
            leverPosition: Offset(4570, 255),
            gate: Rect.fromLTWH(4690, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(2580, 315),
          Offset(2790, 245),
          Offset(3650, 315),
          Offset(3830, 240),
          Offset(4560, 340),
          Offset(5390, 235),
        ],
        emitters: [
          _DueEmitterSpec(3290, 390, -260, 1.55),
          _DueEmitterSpec(4010, 390, 265, 1.45),
          _DueEmitterSpec(4950, 390, -260, 1.35),
        ],
        safeDebtPads: [
          Rect.fromLTWH(2960, 423, 92, 7),
          Rect.fromLTWH(4890, 423, 92, 7),
        ],
        exit: Rect.fromLTWH(5580, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'DEBT DIVE',
      briefing:
          'Build payback, break marked rust floors, and choose between a safe lower line and a fast technical line.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 300, 110),
        Rect.fromLTWH(440, 430, 260, 110),
        Rect.fromLTWH(880, 430, 280, 110),
        Rect.fromLTWH(1340, 430, 620, 110),
        Rect.fromLTWH(285, 310, 130, 18),
        Rect.fromLTWH(500, 270, 145, 18),
        Rect.fromLTWH(925, 300, 145, 18),
        Rect.fromLTWH(1180, 250, 140, 18),
        Rect.fromLTWH(1430, 300, 150, 18),
      ],
      spikes: const [
        Rect.fromLTWH(260, 465, 180, 55),
        Rect.fromLTWH(1160, 465, 180, 55),
      ],
      targets: const [
        _DueTargetSpec(210, 390, _TargetKind.crate),
        _DueTargetSpec(535, 228, _TargetKind.enemy),
        _DueTargetSpec(1020, 258, _TargetKind.crate),
        _DueTargetSpec(1480, 258, _TargetKind.enemy),
      ],
      weakPanels: const [
        Rect.fromLTWH(260, 390, 180, 16),
        Rect.fromLTWH(700, 390, 180, 16),
        Rect.fromLTWH(1160, 390, 180, 16),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(40, 920, 423, 85, 8),
      ],
      vents: const [
        _DueKineticVentSpec(1350, 423, 60, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(700, 465, 180, 55, cycleOffset: 0.1),
      ],
      laserGates: const [
        _DueLaserGateSpec(860, 215, 20, 215, cycleOffset: 0.0),
      ],
      safeDebtPads: const [
        Rect.fromLTWH(470, 423, 92, 7),
        Rect.fromLTWH(1380, 423, 92, 7),
      ],
      seals: const [
        Offset(350, 275),
        Offset(565, 235),
        Offset(1000, 265),
        Offset(1240, 215),
        Offset(1530, 265),
      ],
      emitters: const [_DueEmitterSpec(1100, 390, -265, 1.65)],
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1900,
            'CREDIT CLIMB',
            'Climb the staggered shelves with Borrow, but save enough ledger room to make a controlled debt dive.',
          ),
          _DueSectionSpec(
            3400,
            'DIVE VAULTS',
            'Crack the thin rust floors with payback to drop into the protected lower lanes.',
          ),
          _DueSectionSpec(
            4700,
            'RECOVERY RAIL',
            'Use the debt pads between dives; the final low route is safer but demands short timing jumps.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1900, 430, 300, 110),
          Rect.fromLTWH(2225, 370, 135, 18),
          Rect.fromLTWH(2400, 305, 135, 18),
          Rect.fromLTWH(2575, 235, 150, 18),
          Rect.fromLTWH(2780, 430, 350, 110),
          Rect.fromLTWH(3160, 430, 190, 110),
          Rect.fromLTWH(3400, 355, 135, 18),
          Rect.fromLTWH(3580, 290, 145, 18),
          Rect.fromLTWH(3780, 225, 150, 18),
          Rect.fromLTWH(3820, 430, 360, 110),
          Rect.fromLTWH(4230, 430, 180, 110),
          Rect.fromLTWH(4460, 340, 135, 18),
          Rect.fromLTWH(4635, 275, 145, 18),
          Rect.fromLTWH(4830, 430, 250, 110),
          Rect.fromLTWH(5120, 430, 500, 110),
        ],
        spikes: [
          Rect.fromLTWH(2200, 465, 125, 55),
          Rect.fromLTWH(2725, 465, 55, 55),
          Rect.fromLTWH(3130, 465, 30, 55),
          Rect.fromLTWH(3350, 465, 230, 55),
          Rect.fromLTWH(3725, 465, 95, 55),
          Rect.fromLTWH(4180, 465, 50, 55),
          Rect.fromLTWH(4410, 465, 50, 55),
          Rect.fromLTWH(4780, 465, 50, 55),
          Rect.fromLTWH(5080, 465, 40, 55),
        ],
        targets: [
          _DueTargetSpec(2020, 390, _TargetKind.crate),
          _DueTargetSpec(2475, 263, _TargetKind.enemy),
          _DueTargetSpec(3490, 313, _TargetKind.crate),
          _DueTargetSpec(3880, 388, _TargetKind.enemy),
          _DueTargetSpec(4750, 233, _TargetKind.enemy),
        ],
        seals: [
          Offset(2290, 335),
          Offset(2640, 200),
          Offset(2940, 390),
          Offset(3660, 255),
          Offset(4000, 390),
          Offset(4690, 240),
          Offset(5410, 390),
        ],
        weakPanels: [
          Rect.fromLTWH(2810, 315, 235, 16),
          Rect.fromLTWH(3840, 300, 245, 16),
          Rect.fromLTWH(4870, 315, 180, 16),
        ],
        safeDebtPads: [
          Rect.fromLTWH(2820, 423, 92, 7),
          Rect.fromLTWH(3850, 423, 92, 7),
          Rect.fromLTWH(5150, 423, 92, 7),
        ],
        emitters: [
          _DueEmitterSpec(3320, 390, -250, 1.55),
          _DueEmitterSpec(4520, 390, 255, 1.45),
        ],
        exit: Rect.fromLTWH(5570, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'COMPOUND INTEREST',
      briefing:
          'Two gravity locks, alternating firing lanes, and a risky roof route reward clean transfers.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 320, 110),
        Rect.fromLTWH(450, 430, 300, 110),
        Rect.fromLTWH(920, 430, 290, 110),
        Rect.fromLTWH(1380, 430, 660, 110),
        Rect.fromLTWH(310, 335, 120, 18),
        Rect.fromLTWH(500, 280, 150, 18),
        Rect.fromLTWH(780, 335, 120, 18),
        Rect.fromLTWH(970, 260, 150, 18),
        Rect.fromLTWH(1240, 325, 120, 18),
        Rect.fromLTWH(1450, 270, 155, 18),
      ],
      spikes: const [
        Rect.fromLTWH(280, 465, 170, 55),
        Rect.fromLTWH(750, 465, 170, 55),
        Rect.fromLTWH(1210, 465, 170, 55),
      ],
      targets: const [
        _DueTargetSpec(235, 390, _TargetKind.crate),
        _DueTargetSpec(545, 238, _TargetKind.enemy),
        _DueTargetSpec(1015, 218, _TargetKind.enemy),
        _DueTargetSpec(1310, 390, _TargetKind.crate),
        _DueTargetSpec(1510, 228, _TargetKind.enemy),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(50, 680, 423, 85, 8),
        _DueWeightPlateSpec(51, 1150, 423, 85, 8),
      ],
      vents: const [
        _DueKineticVentSpec(880, 423, 60, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(750, 465, 170, 55, cycleOffset: 0.25),
      ],
      laserGates: const [
        _DueLaserGateSpec(1200, 215, 20, 215, cycleOffset: 0.3),
      ],
      weakPanels: const [
        Rect.fromLTWH(780, 335, 120, 16),
      ],
      gravityPuzzles: const [
        _GravityPuzzleSpec(
          id: 50,
          boxPosition: Offset(635, 390),
          leverPosition: Offset(650, 235),
          gate: Rect.fromLTWH(850, 170, 30, 260),
        ),
        _GravityPuzzleSpec(
          id: 51,
          boxPosition: Offset(1105, 390),
          leverPosition: Offset(1120, 215),
          gate: Rect.fromLTWH(1320, 170, 30, 260),
        ),
      ],
      safeDebtPads: const [Rect.fromLTWH(1410, 423, 92, 7)],
      seals: const [
        Offset(355, 300),
        Offset(560, 245),
        Offset(1020, 225),
        Offset(1280, 290),
        Offset(1525, 235),
      ],
      emitters: const [
        _DueEmitterSpec(735, 390, -270, 1.45),
        _DueEmitterSpec(1395, 390, 265, 1.6),
      ],
      exit: const Rect.fromLTWH(1920, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1980,
            'DOUBLE ENTRY',
            'Two vertical locks share one room: lift each audit crate, then choose the safer low route or the quick roof.',
          ),
          _DueSectionSpec(
            3650,
            'ROOF EXCHANGE',
            'The upper platforms avoid the spike floor, but turret fire makes every transfer a timing choice.',
          ),
          _DueSectionSpec(
            4850,
            'COMPOUND EXIT',
            'Open the final paired gates and settle your payback before the last crossfire lane.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1980, 430, 260, 110),
          Rect.fromLTWH(2260, 430, 190, 110),
          Rect.fromLTWH(2620, 430, 220, 110),
          Rect.fromLTWH(2870, 350, 130, 18),
          Rect.fromLTWH(3040, 280, 145, 18),
          Rect.fromLTWH(3230, 215, 150, 18),
          Rect.fromLTWH(3470, 430, 260, 110),
          Rect.fromLTWH(3770, 340, 130, 18),
          Rect.fromLTWH(3950, 260, 145, 18),
          Rect.fromLTWH(4140, 330, 125, 18),
          Rect.fromLTWH(4330, 430, 250, 110),
          Rect.fromLTWH(4610, 430, 180, 110),
          Rect.fromLTWH(4900, 430, 210, 110),
          Rect.fromLTWH(5150, 335, 135, 18),
          Rect.fromLTWH(5330, 265, 150, 18),
          Rect.fromLTWH(5120, 430, 700, 110),
        ],
        spikes: [
          Rect.fromLTWH(2240, 465, 20, 55),
          Rect.fromLTWH(2450, 465, 170, 55),
          Rect.fromLTWH(2840, 465, 200, 55),
          Rect.fromLTWH(3380, 465, 90, 55),
          Rect.fromLTWH(3730, 465, 220, 55),
          Rect.fromLTWH(4095, 465, 235, 55),
          Rect.fromLTWH(4580, 465, 30, 55),
          Rect.fromLTWH(4790, 465, 110, 55),
          Rect.fromLTWH(5110, 465, 40, 55),
        ],
        targets: [
          _DueTargetSpec(2140, 390, _TargetKind.crate),
          _DueTargetSpec(2700, 390, _TargetKind.crate),
          _DueTargetSpec(3590, 388, _TargetKind.enemy),
          _DueTargetSpec(4020, 218, _TargetKind.enemy),
          _DueTargetSpec(4690, 390, _TargetKind.crate),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 52,
            boxPosition: Offset(2340, 390),
            leverPosition: Offset(2340, 210),
            gate: Rect.fromLTWH(2470, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 53,
            boxPosition: Offset(2760, 390),
            leverPosition: Offset(2760, 195),
            gate: Rect.fromLTWH(2860, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 54,
            boxPosition: Offset(4750, 390),
            leverPosition: Offset(4750, 205),
            gate: Rect.fromLTWH(4930, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(2180, 390),
          Offset(2350, 175),
          Offset(2770, 165),
          Offset(3120, 245),
          Offset(3980, 225),
          Offset(4760, 340),
          Offset(5400, 230),
          Offset(5660, 390),
        ],
        safeDebtPads: [
          Rect.fromLTWH(2650, 423, 92, 7),
          Rect.fromLTWH(4370, 423, 92, 7),
          Rect.fromLTWH(5180, 423, 92, 7),
        ],
        emitters: [
          _DueEmitterSpec(3420, 390, -270, 1.3),
          _DueEmitterSpec(4230, 390, 265, 1.35),
          _DueEmitterSpec(5020, 390, -265, 1.25),
        ],
        exit: Rect.fromLTWH(5780, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'FINAL AUDIT',
      briefing:
          'Settle every system: bridge, lift, collector launch, crossfire, debt dive, and a clean final gate.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 340, 110),
        Rect.fromLTWH(480, 430, 310, 110),
        Rect.fromLTWH(970, 430, 300, 110),
        Rect.fromLTWH(1450, 430, 300, 110),
        Rect.fromLTWH(1930, 430, 410, 110),
        Rect.fromLTWH(330, 340, 130, 18),
        Rect.fromLTWH(535, 280, 150, 18),
        Rect.fromLTWH(820, 335, 125, 18),
        Rect.fromLTWH(1020, 255, 150, 18),
        Rect.fromLTWH(1300, 325, 125, 18),
        Rect.fromLTWH(1500, 270, 150, 18),
        Rect.fromLTWH(1780, 330, 125, 18),
        Rect.fromLTWH(1980, 250, 155, 18),
      ],
      spikes: const [
        Rect.fromLTWH(300, 465, 180, 55),
        Rect.fromLTWH(790, 465, 180, 55),
        Rect.fromLTWH(1270, 465, 180, 55),
        Rect.fromLTWH(1750, 465, 180, 55),
      ],
      targets: const [
        _DueTargetSpec(240, 390, _TargetKind.crate),
        _DueTargetSpec(580, 238, _TargetKind.enemy),
        _DueTargetSpec(875, 293, _TargetKind.enemy),
        _DueTargetSpec(1080, 213, _TargetKind.crate),
        _DueTargetSpec(1550, 228, _TargetKind.enemy),
        _DueTargetSpec(1850, 390, _TargetKind.crate),
        _DueTargetSpec(2040, 208, _TargetKind.enemy),
      ],
      weightPlates: const [
        _DueWeightPlateSpec(60, 710, 423, 85, 8),
        _DueWeightPlateSpec(61, 1680, 423, 85, 8),
      ],
      vents: const [
        _DueKineticVentSpec(940, 423, 60, 16, isUpdraft: true),
        _DueKineticVentSpec(1420, 423, 60, 16, isUpdraft: true),
      ],
      spikeTraps: const [
        _DueSpikeTrapSpec(790, 465, 180, 55, cycleOffset: 0.2),
        _DueSpikeTrapSpec(1750, 465, 180, 55, cycleOffset: 0.4),
      ],
      weakPanels: const [
        Rect.fromLTWH(820, 335, 125, 16),
        Rect.fromLTWH(1270, 390, 180, 16),
        Rect.fromLTWH(1750, 390, 180, 16),
        Rect.fromLTWH(1780, 330, 125, 16),
      ],
      laserGates: const [
        _DueLaserGateSpec(1240, 215, 20, 215, cycleOffset: 0.35),
      ],
      gravityPuzzles: const [
        _GravityPuzzleSpec(
          id: 60,
          boxPosition: Offset(670, 390),
          leverPosition: Offset(685, 235),
          gate: Rect.fromLTWH(900, 165, 30, 265),
        ),
        _GravityPuzzleSpec(
          id: 61,
          boxPosition: Offset(1635, 390),
          leverPosition: Offset(1650, 225),
          gate: Rect.fromLTWH(1900, 165, 30, 265),
        ),
      ],
      safeDebtPads: const [
        Rect.fromLTWH(1000, 423, 92, 7),
        Rect.fromLTWH(1960, 423, 92, 7),
      ],
      seals: const [
        Offset(390, 305),
        Offset(600, 245),
        Offset(1080, 220),
        Offset(1350, 290),
        Offset(1570, 235),
        Offset(1835, 295),
        Offset(2070, 215),
      ],
      emitters: const [
        _DueEmitterSpec(770, 390, -275, 1.35),
        _DueEmitterSpec(1240, 390, 270, 1.45),
        _DueEmitterSpec(1730, 390, -280, 1.3),
      ],
      exit: const Rect.fromLTWH(2240, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            2300,
            'BRIDGE AUDIT',
            'Build a heavy-crate bridge, then use its neighbour as a floating lift before the first paired gates.',
          ),
          _DueSectionSpec(
            3800,
            'VAULT & VOLLEY',
            'Debt dive through the rust floor, recover at the pad, and time the shelter route through crossfire.',
          ),
          _DueSectionSpec(
            5200,
            'CLOSING BALANCE',
            'The last three locks demand crate lifts, a collector launch, and one deliberate final settlement.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(2300, 430, 300, 110),
          Rect.fromLTWH(3000, 430, 250, 110),
          Rect.fromLTWH(3290, 355, 130, 18),
          Rect.fromLTWH(3460, 280, 145, 18),
          Rect.fromLTWH(3650, 215, 150, 18),
          Rect.fromLTWH(3840, 430, 340, 110),
          Rect.fromLTWH(4230, 430, 180, 110),
          Rect.fromLTWH(4460, 345, 135, 18),
          Rect.fromLTWH(4640, 270, 145, 18),
          Rect.fromLTWH(4830, 335, 125, 18),
          Rect.fromLTWH(5020, 430, 300, 110),
          Rect.fromLTWH(5360, 430, 190, 110),
          Rect.fromLTWH(5710, 350, 135, 18),
          Rect.fromLTWH(5890, 280, 145, 18),
          Rect.fromLTWH(6080, 215, 155, 18),
          Rect.fromLTWH(6300, 430, 450, 110),
        ],
        spikes: [
          Rect.fromLTWH(2600, 465, 400, 55),
          Rect.fromLTWH(3250, 465, 210, 55),
          Rect.fromLTWH(3800, 465, 40, 55),
          Rect.fromLTWH(4180, 465, 50, 55),
          Rect.fromLTWH(4410, 465, 50, 55),
          Rect.fromLTWH(4955, 465, 65, 55),
          Rect.fromLTWH(5320, 465, 40, 55),
          Rect.fromLTWH(5550, 465, 160, 55),
          Rect.fromLTWH(6035, 465, 265, 55),
        ],
        targets: [
          _DueTargetSpec(2505, 390, _TargetKind.crate),
          _DueTargetSpec(3090, 390, _TargetKind.crate),
          _DueTargetSpec(3520, 238, _TargetKind.enemy),
          _DueTargetSpec(4010, 388, _TargetKind.enemy),
          _DueTargetSpec(4750, 228, _TargetKind.enemy),
          _DueTargetSpec(5430, 390, _TargetKind.crate),
          _DueTargetSpec(5900, 238, _TargetKind.enemy),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 62,
            boxPosition: Offset(3100, 390),
            leverPosition: Offset(3100, 205),
            gate: Rect.fromLTWH(3260, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 63,
            boxPosition: Offset(4000, 390),
            leverPosition: Offset(4000, 190),
            gate: Rect.fromLTWH(4210, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 64,
            boxPosition: Offset(5460, 390),
            leverPosition: Offset(5460, 205),
            gate: Rect.fromLTWH(5590, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 65,
            boxPosition: Offset(5960, 390),
            leverPosition: Offset(5960, 190),
            gate: Rect.fromLTWH(6130, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(3070, 390),
          Offset(3300, 315),
          Offset(3550, 245),
          Offset(3960, 390),
          Offset(4700, 235),
          Offset(5440, 340),
          Offset(5920, 245),
          Offset(6500, 390),
        ],
        weakPanels: [
          Rect.fromLTWH(3860, 300, 240, 16),
          Rect.fromLTWH(5040, 315, 210, 16),
        ],
        safeDebtPads: [
          Rect.fromLTWH(3020, 423, 92, 7),
          Rect.fromLTWH(3880, 423, 92, 7),
          Rect.fromLTWH(5070, 423, 92, 7),
          Rect.fromLTWH(6340, 423, 92, 7),
        ],
        emitters: [
          _DueEmitterSpec(3740, 390, -275, 1.25),
          _DueEmitterSpec(4320, 390, 270, 1.2),
          _DueEmitterSpec(5160, 390, -280, 1.15),
          _DueEmitterSpec(6220, 390, 270, 1.1),
        ],
        exit: Rect.fromLTWH(6700, 350, 56, 80),
      ),
    ),
  ];
  final int _initialLevelIndex;
  final int _campaignLevel;
  final int _campaignSeed;
  final double _campaignLength;

  _FallDueGame({int campaignLevel = 1, GeneratedGameLevel? campaign})
    : _initialLevelIndex = campaignLevel - 1,
      _campaignLevel = campaign?.number ?? campaignLevel,
      _campaignSeed = campaign?.seed ?? campaignLevel,
      _campaignLength = campaign?.lengthMultiplier ?? 1;

  final Map<int, _DueStage> _generatedStages = {};
  final math.Random _random = math.Random();
  final List<Rect> platforms = [];
  final List<Rect> spikes = [];
  final List<_DueTarget> targets = [];
  final List<_DueBullet> bullets = [];
  final List<_DueSeal> seals = [];
  final List<_DueEmitter> emitters = [];
  final List<_DueLever> levers = [];
  final List<_DueGate> gates = [];
  final List<_DueCheckpoint> checkpoints = [];
  final List<_DueWeakPanel> weakPanels = [];
  final List<_DueSafeDebtPad> safeDebtPads = [];
  final List<_DueCrumblingLedge> crumblingLedges = [];
  final List<_DueSpikeTrap> spikeTraps = [];
  final List<_DueGravityWell> gravityWells = [];
  final List<_DueLaserGate> laserGates = [];
  final List<_DueKineticVent> vents = [];
  final List<_DueConduit> conduits = [];
  final List<_DueWeightPlate> weightPlates = [];
  final List<_DueParticle> particles = [];
  final List<_FallDueShockwave> shockwaves = [];
  final List<_DueTransferArc> transferArcs = [];
  final List<_DueWorkshop> workshops = [];
  _DueWorkshop? _openingRelay;
  _DueBoss? activeBoss;
  List<_DueSectionSpec> _worldSections = const [];
  List<_GravityPuzzleSpec> _worldPuzzles = const [];
  final Set<int> disabledSpikes = {};
  final Set<int> rewardedSpikes = {};
  Rect? _activeExit;
  _DueBody player = _DueBody(70, 370, 27, 37);
  _DueGravityTarget? _selectedTarget;
  _DuePhase phase = _DuePhase.intro;
  int levelIndex = 0;
  bool left = false;
  bool right = false;
  bool _jumpHeld = false;
  bool _borrowHeld = false;
  bool _slamming = false;
  double _slamBorrowPower = 0.0;
  bool _slamHeld = false;
  bool _hasAirDashed = false;
  double _airDashRemaining = 0;
  double _dashDirX = 1.0;
  double _dashDirY = 0.0;
  double get dashDirX => _dashDirX;
  double get dashDirY => _dashDirY;
  double _phaseShiftRemaining = 0.0;
  double _phaseShiftCooldown = 0.0;
  bool get isPhaseShiftActive => _phaseShiftRemaining > 0;
  bool _isWallSliding = false;
  double _wallSlideDirection = 0.0;
  bool get isWallSliding => _isWallSliding;
  _DueGravityTarget? _tetherTarget;
  bool get isTetherActive => _tetherTarget != null;
  double _invulnerableTimer = 0.0;
  bool get isInvulnerable => _invulnerableTimer > 0 || isPhaseShiftActive;
  double _landedAt = double.negativeInfinity;
  double _landingForce = 0;
  bool _antiGravityActive = false;
  double _jumpBuffer = 0;
  double debt = 0;
  double _payback = 0;
  double _settleGrace = 0;
  final Cooldown _transferCooldown = Cooldown();
  final Cooldown _slamCooldown = Cooldown();
  double _spawnGrace = 0;
  double camera = 0;
  double time = 0;
  int score = 0;
  int lives = 5;
  int _stageStartScore = 0;
  int _checkpointIndex = -1;
  int _sectionIndex = -1;
  _DueCheckpointSnapshot? _checkpointSnapshot;
  bool _ridingLightBox = false;
  String message = 'Borrow gravity. Pay it back deliberately.';

  double get debtMultiplier => FallDueTuning.paybackGravityMultiplier(_payback);
  double get gravityMeter => _antiGravityActive || debt > 0 ? debt : _payback;
  bool get inPayback => !_antiGravityActive && _payback > 0;
  String get gravityReadout => '${gravityMeter.round()}%';
  _DueStage get level => _stageFor(levelIndex);
  Rect get exit => _activeExit ?? level.exit;
  int get stageNumber => levelIndex + 1;
  String get stageProgress => stageNumber <= stages.length
      ? '$stageNumber/${stages.length}'
      : 'RUN ${stageNumber - stages.length}';
  double get _maxCamera => math.max(0, exit.right + 20 - viewWidth);
  bool get allSealsCollected => seals.every((seal) => seal.collected);
  bool get allObjectivesComplete => FallDueRules.objectivesComplete(
    remainingSeals: seals.length - collectedSeals,
    lockedGates: lockedGates,
  );
  int get collectedSeals => seals.where((seal) => seal.collected).length;
  int get activeLevers => levers.where((lever) => lever.active).length;
  int get lockedGates => gates.where((gate) => !gate.open).length +
      workshops.where((workshop) => !workshop.cleared).length +
      ((activeBoss?.defeated ?? true) ? 0 : 1);
  String get objectiveReadout {
    final sealsDue = seals.length - collectedSeals;
    if (sealsDue > 0 && lockedGates > 0) {
      return 'SEALS $collectedSeals/${seals.length} · LOCKS $lockedGates';
    }
    if (sealsDue > 0) return 'SEALS $collectedSeals/${seals.length}';
    if (lockedGates > 0) return 'GRAVITY LOCKS $lockedGates';
    return 'EXIT OPEN · SETTLE THE LEDGER';
  }

  int get activatedCheckpoints => _checkpointIndex + 1;
  List<_DueSectionSpec> get routeSections => _worldSections;
  int get visibleCollectors => targets
      .where(
        (target) =>
            target.alive &&
            target.kind == _TargetKind.enemy &&
            target.center.dx >= camera - 40 &&
            target.center.dx <= camera + viewWidth + 40,
      )
      .length;

  void preparePreview() {
    levelIndex = _initialLevelIndex;
    _buildStageWorld(level);
    _resetPlayerAtFieldStart();
  }

  void start() {
    score = 0;
    lives = 5;
    levelIndex = _initialLevelIndex;
    _generatedStages.clear();
    _loadStage();
  }

  void startEndlessContracts() {
    if (phase != _DuePhase.won) return;
    levelIndex = stages.length;
    lives = math.max(3, lives);
    _loadStage();
    message = 'CONTRACT RUN 1: seeded challenge families now escalate.';
  }

  void retryFromCheckpoint() {
    if (phase != _DuePhase.dead) return;
    lives = 5;
    phase = _DuePhase.playing;
    _restoreCheckpointWorld();
    _resetPlayerAtCheckpoint();
    _spawnGrace = 1.1;
    message = _checkpointIndex >= 0
        ? 'LEDGER RESTORED AT SAVE POINT ${_checkpointIndex + 1}. Five hearts replenished.'
        : 'LEDGER RESTORED AT THE STAGE START. Five hearts replenished.';
  }

  void nextStage() {
    if (phase != _DuePhase.stageClear) return;
    levelIndex++;
    _loadStage();
  }

  void _loadStage() {
    final stage = level;
    phase = _DuePhase.playing;
    left = false;
    right = false;
    _jumpHeld = false;
    _borrowHeld = false;
    _antiGravityActive = false;
    _jumpBuffer = 0;
    debt = 0;
    _payback = 0;
    _settleGrace = 0;
    camera = 0;
    _transferCooldown.clear();
    _resetPlayerAtFieldStart();
    _buildStageWorld(stage);
    _buildCheckpoints();
    _checkpointSnapshot = null;
    _sectionIndex = -1;
    _stageStartScore = score;
    message = 'Stage $stageNumber · ${stage.briefing}';
  }

  void _buildStageWorld(_DueStage stage) {
    platforms
      ..clear()
      ..addAll(stage.allPlatforms);
    _activeExit = stage.finalExit;
    spikes
      ..clear()
      ..addAll(stage.allSpikes);
    targets
      ..clear()
      ..addAll(stage.allTargets.map(_targetFromSpec));
    for (final puzzle in stage.allGravityPuzzles) {
      targets.add(_puzzleTarget(puzzle));
    }
    _selectedTarget = null;
    seals
      ..clear()
      ..addAll(stage.allSeals.map(_DueSeal.new));
    emitters
      ..clear()
      ..addAll(stage.allEmitters.map(_DueEmitter.fromSpec));
    levers
      ..clear()
      ..addAll(stage.allGravityPuzzles.map(_DueLever.fromSpec));
    gates
      ..clear()
      ..addAll(stage.allGravityPuzzles.map(_DueGate.fromSpec));
    weakPanels
      ..clear()
      ..addAll(stage.allWeakPanels.map(_DueWeakPanel.new));
    safeDebtPads
      ..clear()
      ..addAll(stage.allSafeDebtPads.map(_DueSafeDebtPad.new));
    crumblingLedges
      ..clear()
      ..addAll(stage.allCrumblingLedges.map(_DueCrumblingLedge.new));
    spikeTraps
      ..clear()
      ..addAll(
        stage.allSpikeTraps.map(
          (s) => _DueSpikeTrap(s.rect, cycleOffset: s.cycleOffset),
        ),
      );
    gravityWells
      ..clear()
      ..addAll(
        stage.allGravityWells.map(
          (w) => _DueGravityWell(
            w.center,
            radius: w.radius,
          ),
        ),
      );
    laserGates
      ..clear()
      ..addAll(
        stage.allLaserGates.map(
          (l) => _DueLaserGate(
            l.rect,
            switchId: l.switchId,
            cycleOffset: l.cycleOffset,
          ),
        ),
      );
    vents
      ..clear()
      ..addAll(
        stage.allVents.map(
          (v) => _DueKineticVent(
            v.rect,
            isUpdraft: v.isUpdraft,
            cycleOffset: v.cycleOffset,
          ),
        ),
      );
    conduits
      ..clear()
      ..addAll(
        stage.allConduits.map(
          (c) => _DueConduit(c.id, c.emitterPos, c.receptorPos, c.alignment),
        ),
      );
    weightPlates
      ..clear()
      ..addAll(stage.allWeightPlates.map((w) => _DueWeightPlate(w.id, w.rect)));
    bullets.clear();
    particles.clear();
    shockwaves.clear();
    transferArcs.clear();
    disabledSpikes.clear();
    rewardedSpikes.clear();
    _phaseShiftRemaining = 0.0;
    _phaseShiftCooldown = 0.0;
    _isWallSliding = false;
    _wallSlideDirection = 0.0;
    _tetherTarget = null;
    _invulnerableTimer = 0.0;
    _appendCampaignAnnex();
    _installRouteSystems(stage);
    _installWorkshops(stage);
    _installBossHall();
    _addExitBase();
  }

  /// Every exit gets an overlapping solid dais. The authored floors often end
  /// precisely at the door's baseline, which is visually ambiguous and can be
  /// skipped by a fast falling body on the final approach.
  void _addExitBase() {
    final door = exit;
    platforms.add(Rect.fromLTWH(door.left - 118, 410, door.width + 236, 130));
  }

  void _appendCampaignAnnex() {
    if (_campaignLevel <= 1) return;
    final annex = _FallDueLevelGenerator.generateAnnex(
      campaignLevel: _campaignLevel,
      campaignSeed: _campaignSeed,
      lengthMultiplier: _campaignLength,
      startX: exit.left - 18,
    );
    platforms.addAll(annex.platforms);
    spikes.addAll(annex.spikes);
    targets.addAll(annex.targets.map(_targetFromSpec));
    emitters.addAll(annex.emitters.map(_DueEmitter.fromSpec));
    seals.addAll(annex.seals.map(_DueSeal.new));
    weakPanels.addAll(annex.weakPanels.map(_DueWeakPanel.new));
    safeDebtPads.addAll(annex.safeDebtPads.map(_DueSafeDebtPad.new));
    crumblingLedges.addAll(annex.crumblingLedges.map(_DueCrumblingLedge.new));
    spikeTraps.addAll(
      annex.spikeTraps.map(
        (s) => _DueSpikeTrap(s.rect, cycleOffset: s.cycleOffset),
      ),
    );
    gravityWells.addAll(
      annex.gravityWells.map(
        (w) => _DueGravityWell(w.center, radius: w.radius),
      ),
    );
    laserGates.addAll(
      annex.laserGates.map(
        (l) => _DueLaserGate(
          l.rect,
          switchId: l.switchId,
          cycleOffset: l.cycleOffset,
        ),
      ),
    );
    vents.addAll(
      annex.vents.map(
        (v) => _DueKineticVent(
          v.rect,
          isUpdraft: v.isUpdraft,
          cycleOffset: v.cycleOffset,
        ),
      ),
    );
    conduits.addAll(
      annex.conduits.map(
        (c) => _DueConduit(c.id, c.emitterPos, c.receptorPos, c.alignment),
      ),
    );
    weightPlates.addAll(
      annex.weightPlates.map((w) => _DueWeightPlate(w.id, w.rect)),
    );
    _activeExit = annex.exit;
  }

  _DueTarget _targetFromSpec(_DueTargetSpec target) {
    final (w, h) = switch (target.kind) {
      _TargetKind.heavy => (40.0, 46.0),
      _TargetKind.drone => (34.0, 30.0),
      _TargetKind.leecher => (28.0, 32.0),
      _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => (32.0, 42.0),
      _TargetKind.crate => (35.0, 40.0),
    };
    return _DueTarget(target.x, target.y, w, h, target.kind);
  }

  _DueTarget _puzzleTarget(_GravityPuzzleSpec puzzle) => _DueTarget(
    puzzle.boxPosition.dx,
    puzzle.boxPosition.dy,
    35,
    40,
    _TargetKind.crate,
    puzzleId: puzzle.id,
  );

  void _buildCheckpoints() {
    checkpoints.clear();
    _checkpointIndex = -1;
    final ground =
        platforms.where((platform) => (platform.top - 430).abs() < 1).toList()
          ..sort((a, b) => a.left.compareTo(b.left));
    if (ground.isEmpty) return;
    for (final milestone in [exit.left * .36, exit.left * .7]) {
      final platform = ground.firstWhere(
        (candidate) => candidate.right > milestone,
        orElse: () => ground.last,
      );
      final x = math.min(platform.right - player.w - 8, platform.left + 34);
      if (checkpoints.any(
        (checkpoint) => (checkpoint.position.dx - x).abs() < 8,
      )) {
        continue;
      }
      checkpoints.add(_DueCheckpoint(Offset(x, platform.top - player.h)));
    }
    checkpoints.addAll(workshops.map((workshop) => _DueCheckpoint(workshop.checkpoint)));
    if (activeBoss case final boss?) {
      checkpoints.add(_DueCheckpoint(boss.checkpoint));
    }
    checkpoints.sort((a, b) => a.position.dx.compareTo(b.position.dx));
  }

  double _lastBorrowTapTime = double.negativeInfinity;

  void setBorrow(bool value) {
    if (value && !_borrowHeld && !_slamming && phase == _DuePhase.playing) {
      if (time - _lastBorrowTapTime < 0.35) {
        performPhaseShift();
      }
      _lastBorrowTapTime = time;

      final direction = (right ? 1.0 : 0.0) - (left ? 1.0 : 0.0);
      if (!player.grounded && direction != 0 && !_hasAirDashed) {
        performDash(dirX: direction, dirY: 0.0);
      }
      _antiGravityActive = true;
      _settleGrace = 0;
      debt = math.min(
        FallDueTuning.maxDebt,
        debt + FallDueTuning.borrowInitialCharge,
      );
      if (player.grounded) {
        player.vy = -FallDueTuning.borrowLaunchImpulse;
        player.grounded = false;
        player.coyote = 0;
        GameFeedback.jump();
      }
    }
    if (!value && _antiGravityActive) {
      _openSettlementWindow();
    }
    _borrowHeld = value;
  }

  void performDash({double? dirX, double? dirY}) {
    if (player.grounded || _hasAirDashed || phase != _DuePhase.playing) return;
    var dx = dirX ?? ((right ? 1.0 : 0.0) - (left ? 1.0 : 0.0));
    var dy = dirY ?? ((_slamHeld ? 1.0 : 0.0) - (_jumpHeld ? 1.0 : 0.0));
    if (dx == 0 && dy == 0) {
      dx = player.vx < -12 || (player.vx.abs() <= 12 && left) ? -1.0 : 1.0;
    }
    final len = math.sqrt(dx * dx + dy * dy);
    dx /= len;
    dy /= len;

    _hasAirDashed = true;
    _airDashRemaining = FallDueTuning.airDashDuration;
    _dashDirX = dx;
    _dashDirY = dy;
    player.vx = dx * FallDueTuning.dashImpulse;
    player.vy = dy * FallDueTuning.dashImpulse;
    debt = math.min(FallDueTuning.maxDebt, debt + FallDueTuning.dashDebtCost);
    _invulnerableTimer = 0.12;
    _burst(player.center, const Color(0xFF8DE1FF), 16);
    ArcadeShake.shake(0.18);
    GameFeedback.jump();
    message = 'OMNI-DIRECTIONAL AIR DASH: burst impulse borrowed!';
  }

  void performRepulsorBurst() {
    if (phase != _DuePhase.playing) return;
    if (_payback <= 0 && debt < 15) {
      debt = math.min(FallDueTuning.maxDebt, debt + 15.0);
    }
    final discharged = _payback > 0 ? _payback * 0.30 : math.min(debt, 15.0);
    if (_payback > 0) {
      _payback = math.max(0, _payback - discharged);
    } else {
      debt = math.max(0, debt - discharged);
    }
    final pushForce = FallDueRules.repulsorBurstPushForce(debt);

    shockwaves.add(
      _FallDueShockwave(
        position: player.center,
        color: const Color(0xFF6DE8FF),
        maxRadius: FallDueTuning.repulsorRadius,
      ),
    );

    for (final enemy in targets.where((t) => t.alive && t.kind!.isEnemy)) {
      final dist = (enemy.center - player.center).distance;
      if (dist <= FallDueTuning.repulsorRadius) {
        final dir = enemy.center - player.center;
        final norm =
            dir.distance > 0 ? dir / dir.distance : const Offset(1, 0);
        enemy.vx += norm.dx * pushForce;
        enemy.vy += norm.dy * pushForce * 0.5;
        enemy.stunTimer = FallDueTuning.repulsorStunDuration;
        _burst(enemy.center, const Color(0xFF6DE8FF), 12);
      }
    }

    for (final bullet in bullets.where((b) => b.alive)) {
      final dist = (bullet.rect.center - player.center).distance;
      if (dist <= FallDueTuning.repulsorRadius) {
        bullet.alive = false;
        score += 100;
        _burst(bullet.rect.center, const Color(0xFF6DE8FF), 8);
      }
    }

    ArcadeShake.shake(0.24);
    GameFeedback.heavyImpact();
    message =
        'KINETIC REPULSOR SHIELD BURST! Discharged ${discharged.round()}% into kinetic blast.';
  }

  void performPhaseShift() {
    if (phase != _DuePhase.playing) return;
    if (debt > 75.0) {
      message = 'LEDGER OVERBURDENED: Debt too high to initiate phase shift.';
      return;
    }
    if (_phaseShiftCooldown > 0) {
      message = 'PHASE SHIFT RECHARGING: Stabilizing quantum coherence.';
      return;
    }
    _phaseShiftRemaining = FallDueRules.phaseShiftDuration();
    _phaseShiftCooldown = 0.80;
    debt = math.min(FallDueTuning.maxDebt, debt + 25.0);
    _burst(player.center, const Color(0xFF00E5FF), 20);
    ArcadeShake.shake(0.18);
    GameFeedback.selection();
    message = 'PHASE SHIFT ENGAGED: 0.40s intangibility active (+25 debt).';
  }

  void performTether() {
    if (phase != _DuePhase.playing) return;
    if (_tetherTarget != null) {
      _tetherTarget = null;
      message = 'GRAVITATIONAL TETHER DISCONNECTED.';
      GameFeedback.selection();
      return;
    }
    final anchor = _gravityRecipient;
    if (anchor != null &&
        (anchor.center - player.center).distance <=
            FallDueTuning.tetherMaxDistance) {
      _tetherTarget = anchor;
      _burst(anchor.center, const Color(0xFF8CFFB1), 14);
      GameFeedback.selection();
      message = 'GRAVITATIONAL TETHER LINKED to ${anchor.label}!';
    } else {
      message = 'NO ANCHOR IN RANGE: Move closer to crate or target.';
    }
  }

  void setSlam(bool value) {
    _slamHeld = value;
    if (value && phase == _DuePhase.playing) {
      if (!player.grounded && math.max(debt, _payback) >= 8) {
        performSlam();
      } else if (!player.grounded && math.max(debt, _payback) < 8) {
        message =
            'HOLDING SLAM: Charge Borrow (W/Shift/Borrow) to execute slam!';
      }
    }
  }

  void performSlam() {
    if (phase != _DuePhase.playing) return;
    if (_slamCooldown.isActive) {
      message = 'SLAM RECHARGING: allow kinetic inertia to stabilize.';
      return;
    }
    if (player.grounded) {
      message = 'SLAM REQUIRES AIR: leap and slam downward!';
      return;
    }
    final currentPower = math.max(debt, _payback);
    if (currentPower < 8) {
      message =
          'INSUFFICIENT BORROW: Hold Borrow in the air to power your slam!';
      return;
    }
    _slamCooldown.tryTrigger(1.2);
    _slamming = true;
    _slamBorrowPower = currentPower;
    final scaledSpeed = FallDueRules.slamDescentSpeed(currentPower);
    player.vy = scaledSpeed;
    _antiGravityActive = false;
    _airDashRemaining = 0;
    _burst(player.center, const Color(0xFFFF7186), 14);
    GameFeedback.jump();
    if (currentPower >= 70) {
      message =
          'MAXIMUM KINETIC SLAM: High borrow ready to detonate shockwave!';
    } else if (currentPower >= 35) {
      message = 'MEDIUM KINETIC SLAM: Heavy downward plunge initiated.';
    } else {
      message = 'LIGHT KINETIC SLAM: Descending downward.';
    }
  }

  Set<_DueTarget> _triggerGravitationalShockwave(
    Offset center, {
    bool isSlam = false,
  }) {
    final discharged = _payback > 0 ? _payback : debt;
    // Discharges 65% of debt/payback into kinetic blast, leaving 35% due
    _payback = discharged * 0.35;
    debt = math.max(0, debt - discharged);
    final dynamicRadius =
        FallDueTuning.shockwaveRadius + (discharged * 0.3).clamp(0.0, 30.0);

    shockwaves.add(
      _FallDueShockwave(
        position: isSlam ? player.rect.bottomCenter : center,
        color: isSlam ? const Color(0xFFFF7186) : const Color(0xFFFFD86E),
        maxRadius: dynamicRadius,
      ),
    );
    ArcadeShake.shake(0.48);
    ArcadeFlash.flash(
      isSlam ? const Color(0x66FF7186) : const Color(0x55FFD86E),
    );
    ArcadeHitStop.freeze(0.08);
    ArcadeFever.charge(0.25, switchMusic: false);
    GameFeedback.shockwave();
    if (isSlam) {
      ArcadeAchievements.unlock('gravity_hammer');
    }
    _burst(center, const Color(0xFFFF7186), 26);
    player.vx *= 0.35; // Landing recovery lag prevents instant sprint

    final affectedTargets = <_DueTarget>{};
    for (final enemy in targets) {
      if (!enemy.alive || !enemy.kind!.isEnemy) continue;
      final dist = (enemy.center - center).distance;
      if (dist < dynamicRadius) {
        affectedTargets.add(enemy);
        final damage = discharged >= 45 ? 2 : 1;
        enemy.health -= damage;
        final pushDir = enemy.center.dx >= center.dx ? 1.0 : -1.0;
        enemy.vx += pushDir * 95.0 * (1 - .65 * dist / dynamicRadius);
        enemy.vy = math.min(enemy.vy, -35.0);
        if (enemy.kind == _TargetKind.drone) {
          enemy.droneRecoveryTimer = 0.4;
          enemy.abilityCooldown = math.max(enemy.abilityCooldown, 1.2);
        }
        if (enemy.health <= 0) {
          enemy.alive = false;
          final killScore = switch (enemy.kind) {
            _TargetKind.heavy => 950,
            _TargetKind.drone => 750,
            _TargetKind.leecher => 600,
            _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 650,
            _TargetKind.crate || null => 0,
          };
          score += killScore;
          _burst(enemy.center, const Color(0xFFFF7186), 18);
        }
      }
    }

    for (final crate in targets) {
      if (!crate.alive || crate.kind != _TargetKind.crate || crate.anchored) {
        continue;
      }
      final dist = (crate.center - center).distance;
      if (dist < dynamicRadius + 20) {
        affectedTargets.add(crate);
        final pushDir = crate.center.dx >= center.dx ? 1.0 : -1.0;
        crate.vx += pushDir * 75.0 * (1 - .65 * dist / (dynamicRadius + 20));
        crate.vy = math.min(crate.vy, -25.0);
        _burst(crate.center, const Color(0xFFFFD86E), 12);
      }
    }

    for (final bullet in bullets) {
      if (!bullet.alive) continue;
      final dist = (bullet.rect.center - center).distance;
      if (dist < dynamicRadius + 15) {
        bullet.alive = false;
        score += 150;
        _burst(bullet.rect.center, const Color(0xFF8DE1FF), 10);
      }
    }

    for (final panel in weakPanels) {
      if (panel.broken) continue;
      if ((panel.rect.center - center).distance < dynamicRadius + 15) {
        panel.broken = true;
        score += 400;
        _burst(panel.rect.center, const Color(0xFFFFD86E), 20);
      }
    }

    if (discharged > 5) {
      message =
          'KINETIC DISCHARGE! Converted ${(discharged * 0.6).round()}% payback into shockwave (${_payback.round()}% debt still due).';
    } else {
      message = 'GRAVITATIONAL SHOCKWAVE deployed!';
    }
    return affectedTargets;
  }

  void _openSettlementWindow() {
    _antiGravityActive = false;
    if (debt < 1) return;
    _settleGrace = FallDueTuning.settlementWindow;
    message = 'LOAN OPEN: give or take gravity before the ledger settles it.';
  }

  void _settleBorrowing() {
    _antiGravityActive = false;
    _settleGrace = 0;
    if (debt < 1) return;
    _payback = math.min(100, _payback + debt * .7);
    message =
        'LOAN RELEASED: ${debt.round()}% comes due. Use the landing, or give it away first.';
    debt = 0;
  }

  void jump() {
    if (phase != _DuePhase.playing) return;
    if (_isWallSliding) {
      player.vx = -_wallSlideDirection * 280.0;
      player.vy = -520.0;
      _hasAirDashed = false;
      _isWallSliding = false;
      _jumpBuffer = 0;
      _burst(player.center, const Color(0xFF8DE1FF), 12);
      GameFeedback.jump();
      message = 'WALL KICK-OFF!';
      return;
    }
    _jumpBuffer = .14;
  }

  void setJump(bool value) {
    if (value && !_jumpHeld) jump();
    if (!value && _jumpHeld && player.vy < -FallDueTuning.jumpCutVelocity) {
      player.vy = -FallDueTuning.jumpCutVelocity;
    }
    _jumpHeld = value;
  }

  void clearInput() {
    left = false;
    right = false;
    _jumpHeld = false;
    _borrowHeld = false;
    _slamHeld = false;
    if (_antiGravityActive) _openSettlementWindow();
  }

  void update(double dt) {
    time += dt;
    _updateEffects(dt);
    if (phase != _DuePhase.playing) return;
    _spawnGrace = math.max(0, _spawnGrace - dt);
    _transferCooldown.tick(dt);
    _slamCooldown.tick(dt);
    _jumpBuffer = math.max(0, _jumpBuffer - dt);
    for (final pad in safeDebtPads) {
      pad.cooldown = math.max(0, pad.cooldown - dt);
    }
    _ridingLightBox = _isPlayerRidingLightBox();
    _moveWorkshopWorld(dt);
    _updatePlayer(dt);
    if (phase != _DuePhase.playing) return;
    _updateTargets(dt);
    _updateLevers();
    _updateBullets(dt);
    _updateTrapsAndPuzzles(dt);
    _updateTether(dt);
    if (phase != _DuePhase.playing) return;
    _updateWorkshops(dt);
    if (phase != _DuePhase.playing) return;
    _updateBoss(dt);
    if (phase != _DuePhase.playing) return;
    _collectSeals();
    _updateCheckpoints();
    _updateRouteSection();
    final desiredCamera = math.max(0, player.center.dx - viewWidth * .58);
    camera +=
        (desiredCamera.clamp(0, _maxCamera) - camera) * math.min(1, dt * 7);
    if (player.y > 570) _die('You fell due.');
  }

  void _updateRouteSection() {
    final sections = routeSections;
    while (_sectionIndex + 1 < sections.length &&
        player.center.dx >= sections[_sectionIndex + 1].start) {
      _sectionIndex++;
      final section = sections[_sectionIndex];
      message =
          'SECTION ${_sectionIndex + 2}/${sections.length + 1}: '
          '${section.title}. ${section.instruction}';
      _burst(player.center, const Color(0xFF8DE1FF), 10);
      GameFeedback.selection();
    }
  }

  void _updatePlayer(double dt) {
    _invulnerableTimer = math.max(0, _invulnerableTimer - dt);
    if (_phaseShiftRemaining > 0) {
      _phaseShiftRemaining = math.max(0, _phaseShiftRemaining - dt);
    }
    if (_phaseShiftCooldown > 0) {
      _phaseShiftCooldown = math.max(0, _phaseShiftCooldown - dt);
    }
    final direction = (right ? 1 : 0) - (left ? 1 : 0);
    final acceleration = player.grounded
        ? FallDueTuning.groundAcceleration
        : FallDueTuning.airAcceleration;
    player.vx += direction * acceleration * dt;
    if (direction == 0) {
      player.vx = damp(
        player.vx,
        player.grounded
            ? FallDueTuning.groundVelocityRetainedPerSecond
            : FallDueTuning.airVelocityRetainedPerSecond,
        dt,
      );
    }
    final speedLimit = FallDueTuning.airDashSpeedLimit(_airDashRemaining);
    player.vx = player.vx.clamp(-speedLimit, speedLimit);
    _airDashRemaining = math.max(0, _airDashRemaining - dt);

    _isWallSliding = false;
    _wallSlideDirection = 0.0;
    if (!player.grounded && player.vy > 0) {
      final leftRect =
          Rect.fromLTWH(player.x - 4, player.y + 4, 4, player.h - 8);
      final rightRect =
          Rect.fromLTWH(player.right, player.y + 4, 4, player.h - 8);
      final activeWeak =
          weakPanels.where((p) => !p.broken).map((p) => p.rect);
      final activeCrum =
          crumblingLedges.where((l) => !l.collapsed).map((l) => l.rect);
      final checkSurfaces = [...platforms, ...activeWeak, ...activeCrum];
      final hasLeft = checkSurfaces.any((s) => s.overlaps(leftRect));
      final hasRight = checkSurfaces.any((s) => s.overlaps(rightRect));
      if (hasLeft && left) {
        _isWallSliding = true;
        _wallSlideDirection = -1.0;
      } else if (hasRight && right) {
        _isWallSliding = true;
        _wallSlideDirection = 1.0;
      }
      if (_isWallSliding) {
        final maxSlide =
            _payback >= 50.0 ? 240.0 : FallDueTuning.wallSlideSpeed;
        if (player.vy > maxSlide) player.vy = maxSlide;
        _hasAirDashed = false;
        if (_random.nextDouble() < 0.25) {
          final sparkX = _wallSlideDirection < 0 ? player.x : player.right;
          _burst(
            Offset(sparkX, player.y + player.h * 0.7),
            const Color(0xFFFFD56F),
            2,
          );
        }
      }
    }

    player.coyote = player.grounded ? .12 : math.max(0, player.coyote - dt);
    if (_jumpBuffer > 0 && player.coyote > 0) {
      final onCrate = targets.any(
        (t) =>
            t.alive &&
            t.kind == _TargetKind.crate &&
            (player.rect.bottom - t.y).abs() < 10 &&
            player.rect.right > t.x &&
            player.rect.left < t.x + t.w,
      );
      if (onCrate) {
        player.vy = -FallDueTuning.jumpImpulse * 1.15;
        _hasAirDashed = false;
        _burst(player.rect.bottomCenter, const Color(0xFF8CFFB1), 14);
        message = 'SPRINGBOARD BOOST! +15% vertical leap.';
      } else {
        player.vy = -FallDueTuning.jumpImpulse;
      }
      player.coyote = 0;
      player.grounded = false;
      _jumpBuffer = 0;
      GameFeedback.lightImpact();
    }
    final playerRectBeforeMove = player.rect;
    double gravity = 1;
    if (_antiGravityActive) {
      debt = math.min(
        FallDueTuning.maxDebt,
        debt + FallDueTuning.borrowRate * dt,
      );
      final lift = FallDueTuning.borrowLiftAcceleration(debt);
      player.vy = math.max(-540, player.vy - lift * dt);
      gravity = FallDueTuning.borrowGravityScale(debt);
      if (debt >= FallDueTuning.maxDebt - .1) {
        message =
            'CREDIT LINE EXHAUSTED: lift is fading—give it away or prepare to settle.';
      }
    } else {
      if (_settleGrace > 0) {
        _settleGrace = math.max(0, _settleGrace - dt);
      }
      if (_settleGrace <= 0 && debt > 0) {
        _settleBorrowing();
      }
      if (_payback > .1) {
        gravity = debtMultiplier;
        _payback = math.max(0, _payback - (player.grounded ? 15 : 5) * dt);
      }
    }
    if (_slamHeld && !_slamming && !player.grounded) {
      final power = math.max(debt, _payback);
      if (power >= 8 && !_slamCooldown.isActive) {
        performSlam();
      }
    }
    final impactSpeed = player.vy;
    final wasSlamming = _slamming;
    final slamPower = _slamBorrowPower;
    Set<_DueTarget> shockwaveHitTargets = const {};
    final wasGrounded = player.grounded;
    final previousFeet = player.rect.bottom;
    final landed = _resolve(player, dt, gravity);
    final stompedBoss = _stompBoss(previousFeet, impactSpeed, wasSlamming);
    if (landed && !stompedBoss) {
      _hasAirDashed = false;
      _airDashRemaining = 0;
      if (!wasGrounded && impactSpeed > 105) {
        _landedAt = time;
        _landingForce = (impactSpeed / 820).clamp(.25, 1.0);
        if (!wasSlamming || !FallDueRules.slamCausesShockwave(slamPower)) {
          shockwaves.add(
            _FallDueShockwave(
              position: player.rect.bottomCenter,
              color: wasSlamming
                  ? const Color(0xFFFF827A)
                  : const Color(0xFFE5B58D),
              maxRadius: (wasSlamming ? 56 : 26) * (.4 + .6 * _landingForce),
            ),
          );
        }
      }
      if (wasSlamming) {
        for (final workshop in _workshopsAt(player.center.dx)) {
          for (final panel in workshop.room.service.where((panel) => panel.height <= 12)) {
            if (player.rect.inflate(4).overlaps(panel.shift(workshop.origin))) {
              workshop.run.broken.add(panel);
            }
          }
        }
        _slamming = false;
        if (FallDueRules.slamCausesShockwave(slamPower)) {
          // Highest borrow causes shockwaves!
          shockwaveHitTargets = _triggerGravitationalShockwave(
            player.center,
            isSlam: true,
          );
        } else if (slamPower >= 35.0) {
          // Medium slam: heavy landing, breaks panels directly underfoot, no radial shockwave
          final discharged = _payback > 0 ? _payback : debt;
          _payback = discharged * 0.5;
          debt = math.max(0, debt - discharged);
          _breakWeakPanels(player.rect, impactSpeed, source: 'MEDIUM SLAM');
          _burst(player.center, const Color(0xFFFF7186), 16);
          ArcadeShake.shake(0.22);
          GameFeedback.mediumImpact();
          player.vx *= 0.5;
          message =
              'MEDIUM SLAM: Heavy landing! Highest borrow required for shockwaves.';
        } else {
          // Light slam: direct stomp, no radial shockwave
          final discharged = _payback > 0 ? _payback : debt;
          _payback = discharged * 0.6;
          debt = math.max(0, debt - discharged);
          _burst(player.center, const Color(0xFFFF7186), 10);
          GameFeedback.lightImpact();
          message =
              'LIGHT SLAM: Borrow more gravity to unleash heavier impact.';
        }
      }
      _settleDebtOnSafePad();
      if (!wasSlamming && gravity > 1.6 && impactSpeed > 450) {
        _breakWeakPanels(player.rect, impactSpeed, source: 'DEBT DIVE');
      }
    }
    _DueTarget? directlyStompedEnemy;
    for (final target in targets) {
      if (!target.kind!.isEnemy ||
          !target.alive ||
          !player.rect.overlaps(target.rect)) {
        continue;
      }
      final stomped =
          impactSpeed > 20 &&
          playerRectBeforeMove.bottom <= target.y + 12 &&
          player.rect.bottom >= target.y;
      if (stomped) {
        if (target.kind == _TargetKind.heavy && !wasSlamming) {
          // Heavy Armor Deflection on normal stomp
          player.y = target.y - player.h;
          player.vy = -310;
          _burst(target.rect.topCenter, const Color(0xFFFFD86E), 10);
          GameFeedback.selection();
          message =
              'ARMOR DEFLECTION: Slam or drop crates to break heavy plating!';
        } else {
          // Enemies slammed on die instantly!
          final damage = wasSlamming ? target.health : 1;
          target.health -= damage;
          player.y = target.y - player.h;
          player.vy = -280;
          _slamming = false;
          if (wasSlamming) {
            directlyStompedEnemy = target;
          }
          if (target.health <= 0) {
            target.alive = false;
            final killScore = switch (target.kind) {
              _TargetKind.heavy => 950,
              _TargetKind.drone => 750,
              _TargetKind.leecher => 600,
              _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 550,
              _TargetKind.crate || null => 0,
            };
            score += killScore;
            final name = switch (target.kind) {
              _TargetKind.heavy => 'ENFORCER',
              _TargetKind.drone => 'DRONE',
              _TargetKind.leecher => 'LEECHER',
              _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 'LIABILITY',
              _TargetKind.crate || null => 'CRATE',
            };
            message = wasSlamming
                ? 'KINETIC OBLITERATION! $name CRUSHED INSTANTLY +$killScore'
                : '$name CRUSHED +$killScore';
            _burst(target.center, const Color(0xFFFF7186), 22);
            ArcadeShake.shake(0.35);
            GameFeedback.heavyImpact();
          } else {
            message = 'STOMP HIT — ${target.health} HITS LEFT';
          }
        }
      } else if (_spawnGrace <= 0) {
        if (wasSlamming) {
          // Slam descent impact directly crushes enemy
          target.health = 0;
          target.alive = false;
          directlyStompedEnemy = target;
          score += 550;
          message = 'KINETIC OBLITERATION! Enemy crushed by slam +550';
          _burst(target.center, const Color(0xFFFF7186), 22);
          ArcadeShake.shake(0.35);
          GameFeedback.heavyImpact();
        } else if (target.kind == _TargetKind.leecher) {
          player.vx = player.center.dx < target.center.dx ? -150 : 150;
          _spawnGrace = .18;
        } else {
          _die('Crushed by liability.');
          return;
        }
      }
    }
    if (wasSlamming && (landed || directlyStompedEnemy != null)) {
      final impact = landed
          ? player.rect.bottomCenter
          : directlyStompedEnemy!.center;
      // Concussion push: if slam fails to land a direct hit, at least push nearby enemies away!
      final radius = FallDueRules.slamConcussionRadius(slamPower);
      final pushForce = FallDueRules.slamConcussionPush(slamPower);
      var enemiesPushed = 0;
      for (final target in targets) {
        if (!target.alive ||
            target == directlyStompedEnemy ||
            shockwaveHitTargets.contains(target)) {
          continue;
        }
        final dist = (target.center - impact).distance;
        if (dist > radius) continue;

        final pushDir = target.center.dx >= impact.dx ? 1.0 : -1.0;
        final localPush = pushForce * (1 - .65 * dist / radius);
        if (target.kind!.isEnemy) {
          enemiesPushed++;
          target.vx += pushDir * localPush;
          target.vy = math.min(target.vy, -35.0);
          if (target.kind == _TargetKind.drone) {
            target.droneRecoveryTimer = 0.4;
            target.abilityCooldown = math.max(target.abilityCooldown, 1.2);
          }
          _burst(target.center, const Color(0xFFFF7186), 8);
        } else if (target.kind == _TargetKind.crate && !target.anchored) {
          target.vx += pushDir * localPush * .5;
          target.vy = math.min(target.vy, -25.0);
          _burst(target.center, const Color(0xFFFFD86E), 6);
        }
      }
      if (directlyStompedEnemy == null && enemiesPushed > 0) {
        message =
            'KINETIC CONCUSSION: Direct hit missed, but shock nudged $enemiesPushed ${enemiesPushed == 1 ? "enemy" : "enemies"} back!';
        ArcadeShake.shake(0.18);
        GameFeedback.mediumImpact();
      }
    }
    for (var index = 0; index < spikes.length; index++) {
      if (_spawnGrace <= 0 &&
          !disabledSpikes.contains(index) &&
          !spikeTraps.any((trap) => trap.rect.overlaps(spikes[index])) &&
          player.rect.overlaps(spikes[index])) {
        _die('Gravity collected its due.');
        return;
      }
    }
    _tryExit();
  }

  void _collectSeals() {
    for (final seal in seals) {
      if (seal.collected ||
          !player.rect.overlaps(
            Rect.fromCircle(center: seal.position, radius: seal.radius),
          )) {
        continue;
      }
      seal.collected = true;
      score += 250;
      message = 'SEAL $collectedSeals/${seals.length} COLLECTED +250';
      _burst(seal.position, const Color(0xFF8CFFB1), 16);
      GameFeedback.selection();
    }
  }

  void _settleDebtOnSafePad() {
    if (_payback <= 0) return;
    for (final pad in safeDebtPads) {
      if (pad.cooldown > 0 || !player.rect.overlaps(pad.rect.inflate(5))) {
        continue;
      }
      final paid = math.min(32.0, _payback);
      _payback -= paid;
      pad.cooldown = .9;
      message = 'SAFE DEBT PAD: ${paid.round()}% PAYBACK ABSORBED.';
      _burst(pad.rect.center, const Color(0xFF8CFFB1), 12);
      GameFeedback.selection();
    }
  }

  void _breakWeakPanels(
    Rect impactRect,
    double impactSpeed, {
    required String source,
  }) {
    if (impactSpeed < 300) return;
    for (final panel in weakPanels) {
      if (panel.broken || !impactRect.overlaps(panel.rect.inflate(5))) {
        continue;
      }
      panel.broken = true;
      score += 400;
      message = '$source BROKE A WEAK FLOOR +400.';
      _burst(panel.rect.center, const Color(0xFFFFD86E), 22);
      GameFeedback.mediumImpact();
    }
  }

  void _updateCheckpoints() {
    for (
      var index = _checkpointIndex + 1;
      index < checkpoints.length;
      index++
    ) {
      final checkpoint = checkpoints[index];
      if (player.center.dx < checkpoint.position.dx ||
          (player.center.dy - checkpoint.position.dy).abs() > 130) {
        break;
      }
      _checkpointIndex = index;
      checkpoint.active = true;
      score += 120;
      _checkpointSnapshot = _captureCheckpoint();
      message = 'SAVE POINT ${index + 1}/${checkpoints.length} SECURED +120.';
      _burst(
        checkpoint.position + Offset(player.w / 2, 8),
        const Color(0xFF8DE1FF),
        16,
      );
      GameFeedback.selection();
    }
  }

  _DueCheckpointSnapshot _captureCheckpoint() => _DueCheckpointSnapshot(
    score: score,
    platforms: List<Rect>.from(platforms),
    spikes: List<Rect>.from(spikes),
    exit: exit,
    targets: targets.map((target) => target.copy()).toList(),
    seals: seals.map((seal) => seal.copy()).toList(),
    emitters: emitters.map((emitter) => emitter.copy()).toList(),
    levers: levers.map((lever) => lever.copy()).toList(),
    gates: gates.map((gate) => gate.copy()).toList(),
    weakPanels: weakPanels.map((panel) => panel.copy()).toList(),
    disabledSpikes: Set<int>.of(disabledSpikes),
    rewardedSpikes: Set<int>.of(rewardedSpikes),
    crumblingLedges: crumblingLedges.map((l) => l.copy()).toList(),
    spikeTraps: spikeTraps.map((s) => s.copy()).toList(),
    gravityWells: gravityWells.map((w) => w.copy()).toList(),
    laserGates: laserGates.map((l) => l.copy()).toList(),
    vents: vents.map((v) => v.copy()).toList(),
    conduits: conduits.map((c) => c.copy()).toList(),
    weightPlates: weightPlates.map((w) => w.copy()).toList(),
    safeDebtPads: safeDebtPads.map((pad) => pad.rect).toList(),
    workshops: workshops.map((workshop) => workshop.save()).toList(),
    openingRelay: _openingRelay?.save(),
    bossHealth: activeBoss?.health,
  );

  void _restoreCheckpointWorld() {
    final snapshot = _checkpointSnapshot;
    if (snapshot == null) {
      _buildStageWorld(level);
      score = math.max(0, _stageStartScore - FallDueTuning.deathScoreFee);
    } else {
      platforms
        ..clear()
        ..addAll(snapshot.platforms);
      spikes
        ..clear()
        ..addAll(snapshot.spikes);
      _activeExit = snapshot.exit;
      targets
        ..clear()
        ..addAll(snapshot.targets.map((target) => target.copy()));
      seals
        ..clear()
        ..addAll(snapshot.seals.map((seal) => seal.copy()));
      emitters
        ..clear()
        ..addAll(snapshot.emitters.map((emitter) => emitter.copy()));
      levers
        ..clear()
        ..addAll(snapshot.levers.map((lever) => lever.copy()));
      gates
        ..clear()
        ..addAll(snapshot.gates.map((gate) => gate.copy()));
      weakPanels
        ..clear()
        ..addAll(snapshot.weakPanels.map((panel) => panel.copy()));
      safeDebtPads
        ..clear()
        ..addAll(snapshot.safeDebtPads.map(_DueSafeDebtPad.new));
      for (var i = 0; i < workshops.length; i++) {
        workshops[i].restore(i < snapshot.workshops.length ? snapshot.workshops[i] : null);
      }
      _openingRelay?.restore(snapshot.openingRelay);
      activeBoss?.restore(snapshot.bossHealth);
      disabledSpikes
        ..clear()
        ..addAll(snapshot.disabledSpikes);
      rewardedSpikes
        ..clear()
        ..addAll(snapshot.rewardedSpikes);
      crumblingLedges
        ..clear()
        ..addAll(snapshot.crumblingLedges.map((l) => l.copy()));
      spikeTraps
        ..clear()
        ..addAll(snapshot.spikeTraps.map((s) => s.copy()));
      gravityWells
        ..clear()
        ..addAll(snapshot.gravityWells.map((w) => w.copy()));
      laserGates
        ..clear()
        ..addAll(snapshot.laserGates.map((l) => l.copy()));
      vents
        ..clear()
        ..addAll(snapshot.vents.map((v) => v.copy()));
      conduits
        ..clear()
        ..addAll(snapshot.conduits.map((c) => c.copy()));
      weightPlates
        ..clear()
        ..addAll(snapshot.weightPlates.map((w) => w.copy()));
      for (final target in targets) {
        if (target.anchored) {
          if (target.bridgeSurface case final bridge? when !platforms.contains(bridge)) {
            platforms.add(bridge);
          }
        }
      }
      score = math.max(0, snapshot.score - FallDueTuning.deathScoreFee);
      bullets.clear();
      particles.clear();
      shockwaves.clear();
      _selectedTarget = null;
    }
    for (final puzzle in _worldPuzzles) {
      if (targets.any((target) => target.puzzleId == puzzle.id)) continue;
      targets.add(_puzzleTarget(puzzle));
      final checkpointX = _checkpointIndex >= 0
          ? checkpoints[_checkpointIndex].position.dx
          : 0.0;
      if (checkpointX > puzzle.gate.right) {
        final lever = levers.firstWhere((lever) => lever.id == puzzle.id);
        final gate = gates.firstWhere((gate) => gate.id == puzzle.id);
        lever
          ..latched = true
          ..active = true;
        gate.open = true;
      }
    }
    for (var index = 0; index < checkpoints.length; index++) {
      checkpoints[index].active = index <= _checkpointIndex;
    }
  }

  void _tryExit() {
    if (!player.rect.overlaps(exit)) return;
    if (!allSealsCollected) {
      message =
          'GATE LOCKED: collect ${seals.length - collectedSeals} more seal(s).';
      return;
    }
    if (lockedGates > 0) {
      if (activeBoss case final boss? when !boss.defeated) {
        message = 'EXIT SEALED · Defeat ${boss.spec.name}.';
        return;
      }
      message = 'GATE LOCKED: latch $lockedGates remaining gravity lock(s).';
      return;
    }
    final cleanBonus = FallDueRules.cleanExitBonus(
      carriedDebt: debt,
      payback: _payback,
    );
    score += 800 + cleanBonus;
    if (debt <= 1.0 && _payback <= 1.0) {
      ArcadeAchievements.unlock('zero_sum');
    }
    if (levelIndex == stages.length - 1) {
      phase = _DuePhase.won;
      message = 'CORE LEDGER CLEARED. Optional contract runs are now open.';
    } else {
      phase = _DuePhase.stageClear;
      final next = _stageFor(levelIndex + 1);
      message = '${level.title} settled. Next: ${next.title}.';
    }
    _burst(exit.center, const Color(0xFF8CFFB1), 32);
    GameFeedback.victory();
  }

  void _updateEffects(double dt) {
    for (final particle in particles) {
      particle.position += particle.velocity * dt;
      particle.velocity *= math.pow(.08, dt).toDouble();
      particle.life -= dt;
    }
    particles.removeWhere((particle) => particle.life <= 0);
    for (final wave in shockwaves) {
      wave.time += dt;
    }
    shockwaves.removeWhere((wave) => wave.time >= _FallDueShockwave.life);
    for (final arc in transferArcs) {
      arc.time += dt;
    }
    transferArcs.removeWhere((arc) => arc.time >= _DueTransferArc.life);
  }

  void _showTransfer(Offset target, {bool taking = false}) {
    final origin = player.center;
    final color = taking ? const Color(0xFFA4DDFF) : const Color(0xFFFFD56F);
    transferArcs.add(
      _DueTransferArc(
        taking ? target : origin,
        taking ? origin : target,
        color,
      ),
    );
  }

  void _burst(Offset position, Color color, int count) {
    for (var index = 0; index < count; index++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 35 + _random.nextDouble() * 125;
      particles.add(
        _DueParticle(
          position,
          Offset(math.cos(angle), math.sin(angle)) * speed,
          color,
          .45 + _random.nextDouble() * .35,
        ),
      );
    }
  }

  void _updateTargets(double dt) {
    for (final target in targets) {
      if (!target.alive) continue;
      if (target.anchored) continue;
      target.lastY = target.y;
      target.abilityCooldown = math.max(0, target.abilityCooldown - dt);
      final playerRiding =
          target.kind.isCrate &&
          target.debt < -1 &&
          player.rect.right > target.rect.left + 4 &&
          player.rect.left < target.rect.right - 4 &&
          player.rect.bottom >= target.y - 4 &&
          player.rect.bottom <= target.y + 6;

      if (target.kind == _TargetKind.enemy ||
          target.kind == _TargetKind.swordsman ||
          target.kind == _TargetKind.archer) {
        if (target.stunTimer > 0) {
          target.stunTimer = math.max(0, target.stunTimer - dt);
          target.vx = damp(target.vx, 0.28, dt);
        } else {
          final weight = (target.debt / 35).clamp(0.0, .78).toDouble();
          final patrolSpeed = (target.kind == _TargetKind.swordsman
              ? 83 : target.kind == _TargetKind.archer ? 30 : 58) * (1 - weight);
          target.vx = target.vx == 0 ? patrolSpeed : target.vx;
          final desiredSpeed = target.vx.sign * patrolSpeed;
          if (target.debt > 0 || target.vx.abs() > patrolSpeed) {
            target.vx += (desiredSpeed - target.vx) * math.min(1, dt * 8);
          }
          if (target.grounded &&
              target.vx.abs() <= patrolSpeed + 12 &&
              !_hasPatrolLedgeAhead(target, dt)) {
            target.vx = -target.vx;
          }
        }
      } else if (target.kind == _TargetKind.drone) {
        // Aerial drone floats, stabilizes, and bobs
        if (target.droneRecoveryTimer > 0) {
          target.droneRecoveryTimer = math.max(
            0,
            target.droneRecoveryTimer - dt,
          );
          target.vx = damp(target.vx, 0.28, dt);
          final altitudeErr = target.droneHomeY - target.y;
          if (target.grounded && target.droneRecoveryTimer < 1.4) {
            // Hit ground from GIVE: unstick and thrust upward toward hover altitude
            target.grounded = false;
            target.vy = -280.0;
          } else if (!target.grounded) {
            target.vy = damp(target.vy, 0.16, dt);
            target.vy += altitudeErr.clamp(-120.0, 120.0) * dt * 3.2;
          }
        } else {
          if (target.debt.abs() < 1) {
            target.vy = math.sin(time * 3.2 + target.x * 0.05) * 25.0;
            target.vx = math.cos(time * 1.5 + target.x * 0.02) * 35.0;
            final altitudeErr = target.droneHomeY - target.y;
            if (altitudeErr.abs() > 15) {
              target.vy += altitudeErr.clamp(-60.0, 60.0) * dt * 2.0;
            }
          } else if (target.debt < -1) {
            target.vy = -160.0;
          }
        }
      } else if (target.kind == _TargetKind.heavy) {
        if (target.stunTimer > 0) {
          target.stunTimer = math.max(0, target.stunTimer - dt);
          target.vx = damp(target.vx, 0.28, dt);
        } else {
          final weight = (target.debt / 45).clamp(0.0, .85).toDouble();
          final patrolSpeed = 38 * (1 - weight);
          target.vx = target.vx == 0 ? patrolSpeed : target.vx;
          final desiredSpeed = target.vx.sign * patrolSpeed;
          if (target.debt > 0 || target.vx.abs() > patrolSpeed) {
            target.vx += (desiredSpeed - target.vx) * math.min(1, dt * 8);
          }
          if (target.grounded &&
              target.vx.abs() <= 50 &&
              !_hasPatrolLedgeAhead(target, dt)) {
            target.vx = -target.vx;
          }
        }
      } else if (target.kind == _TargetKind.leecher) {
        if (target.stunTimer > 0) {
          target.stunTimer = math.max(0, target.stunTimer - dt);
          target.vx = damp(target.vx, 0.28, dt);
        } else {
          final dist = (target.center - player.center).distance;
          if (dist < 260) {
            final dir = player.center.dx >= target.center.dx ? 1.0 : -1.0;
            final runSpeed = dir * 110.0;
            if (target.vx.abs() > 110.0) {
              target.vx = damp(target.vx, 0.1, dt);
            } else {
              target.vx = runSpeed;
            }
          } else {
            final weight = (target.debt / 25).clamp(0.0, .6).toDouble();
            final patrolSpeed = 75 * (1 - weight);
            target.vx = target.vx == 0 ? patrolSpeed : target.vx;
            final desiredSpeed = target.vx.sign * patrolSpeed;
            if (target.debt > 0 || target.vx.abs() > patrolSpeed) {
              target.vx += (desiredSpeed - target.vx) * math.min(1, dt * 8);
            }
            if (target.grounded &&
                target.vx.abs() <= 90 &&
                !_hasPatrolLedgeAhead(target, dt)) {
              target.vx = -target.vx;
            }
          }
        }
      }

      if (target.kind.isEnemy) _stepEnemyAbility(target, dt);
      double gravity = (1 + target.debt * .035).clamp(.22, 2.4).toDouble();
      if (target.kind == _TargetKind.drone) {
        gravity = 0;
      }
      final fallImpact = target.vy + FallDueTuning.gravity * gravity * dt;
      _resolve(target, dt, gravity);
      if (playerRiding) {
        player.y += target.y - target.lastY;
        _ridingLightBox = true;
      }
      if (target.kind == _TargetKind.crate && fallImpact > 210) {
        _crushEnemiesWithCrate(target);
        _breakWeakPanels(target.rect, fallImpact, source: 'CRATE DROP');
      }
      if (target.kind.isCrate && !target.anchored) {
        if (player.rect.inflate(4).overlaps(target.rect) &&
            player.rect.bottom > target.y + 6) {
          if (player.center.dx < target.center.dx && player.vx > 10) {
            target.vx = math.max(target.vx, player.vx * 0.9);
          } else if (player.center.dx > target.center.dx && player.vx < -10) {
            target.vx = math.min(target.vx, player.vx * 0.9);
          }
        }
      }
      if (target.kind.isCrate) _pushEnemiesWithCrate(target, dt);
      if (target.kind == _TargetKind.crate && target.grounded) {
        target.vx = damp(
          target.vx,
          FallDueTuning.crateVelocityRetainedPerSecond,
          dt,
        );
        if (target.vx.abs() < 2) target.vx = 0;
      }
      if (target.kind!.isEnemy &&
          target.kind != _TargetKind.drone &&
          (target.debt < -1 || target.vx.abs() > 180)) {
        _launchEnemyIntoTargets(target);
      }
      if (target.debt >= FallDueTuning.anchorDebt &&
          target.kind == _TargetKind.crate) {
        _tryAnchorCrate(target, fallImpact);
      }
      if (target.grounded &&
          target.kind == _TargetKind.enemy &&
          target.vx.abs() < 1) {
        target.vx = -54;
      }
      if (target.debt != 0) {
        final recovery = target.debt.isNegative ? 6.5 : -4.5;
        target.debt += recovery * dt;
        if (target.debt.abs() < .2) target.debt = 0;
      }
      if (target.y > 610) {
        if (target.puzzleId case final puzzleId?) {
          final puzzle = _worldPuzzles.firstWhere(
            (candidate) => candidate.id == puzzleId,
          );
          target
            ..x = puzzle.boxPosition.dx
            ..y = puzzle.boxPosition.dy
            ..vx = 0
            ..vy = 0
            ..debt = 0
            ..grounded = false
            ..anchored = false
            ..bridgeSpikeIndex = null
            ..bridgeSurface = null;
          message = 'AUDIT CRATE RECALLED: the gravity lock remains solvable.';
        } else {
          target.alive = false;
        }
      }
      if (target.kind!.isEnemy &&
          spikes.asMap().entries.any(
            (entry) =>
                !disabledSpikes.contains(entry.key) &&
                target.rect.overlaps(entry.value),
          )) {
        target.alive = false;
        score += 350;
        message = 'ENEMY LOST TO THE SPIKE BED +350.';
        _burst(target.center, const Color(0xFFFF7186), 14);
      }
    }
    targets.removeWhere((target) => !target.alive);
  }

  bool _isPlayerRidingLightBox() => targets.any(
    (target) =>
        target.alive &&
        target.kind == _TargetKind.crate &&
        target.debt < -1 &&
        player.rect.right > target.rect.left + 4 &&
        player.rect.left < target.rect.right - 4 &&
        player.rect.bottom >= target.y - 4 &&
        player.rect.bottom <= target.y + 6,
  );

  void _crushEnemiesWithCrate(_DueTarget crate) {
    for (final enemy in targets) {
      if (!enemy.alive || enemy == crate || !enemy.kind!.isEnemy) {
        continue;
      }
      if (!crate.rect.overlaps(enemy.rect)) continue;
      enemy.alive = false;
      final killScore = switch (enemy.kind) {
        _TargetKind.heavy => 950,
        _TargetKind.drone => 750,
        _TargetKind.leecher => 600,
        _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 700,
        _TargetKind.crate || null => 0,
      };
      score += killScore;
      message = 'CRATE DROP: enemy crushed +$killScore.';
      _burst(enemy.center, const Color(0xFFFFD86E), 20);
      GameFeedback.mediumImpact();
    }
  }

  void _pushEnemiesWithCrate(_DueTarget crate, double dt) {
    if (!crate.alive) return;
    for (final enemy in targets) {
      if (!enemy.alive || enemy == crate || !enemy.kind!.isEnemy) continue;
      if (!crate.rect.inflate(3).overlaps(enemy.rect)) continue;
      final pushDir = crate.vx.abs() > 4
          ? crate.vx.sign
          : (enemy.center.dx >= crate.center.dx ? 1.0 : -1.0);
      final pushSpeed = math.max(crate.vx.abs(), 145.0);
      enemy.vx = pushDir * pushSpeed;
      if (pushDir > 0 && enemy.rect.left < crate.rect.right) {
        enemy.x = crate.rect.right;
      } else if (pushDir < 0 && enemy.rect.right > crate.rect.left) {
        enemy.x = crate.rect.left - enemy.w;
      }
      enemy.stunTimer = math.max(enemy.stunTimer, 0.45);
      if (crate.vx.abs() > 210) {
        enemy.health -= 1;
        if (enemy.health <= 0) {
          enemy.alive = false;
          score += 650;
          message = 'KINETIC CRATE IMPACT: enemy crushed +650!';
          _burst(enemy.center, const Color(0xFFFFD86E), 16);
          GameFeedback.heavyImpact();
        }
      }
    }
  }

  _DueTarget? _closestEnemy(Offset from) {
    _DueTarget? closest;
    var bestDist = double.infinity;
    for (final t in targets) {
      if (!t.alive || !t.kind!.isEnemy) continue;
      final d = (t.center - from).distance;
      if (d < bestDist) {
        bestDist = d;
        closest = t;
      }
    }
    return closest;
  }

  void _launchEnemyIntoTargets(_DueTarget launched) {
    for (final other in targets) {
      if (!other.alive || other == launched || !other.kind!.isEnemy) {
        continue;
      }
      if (!launched.rect.overlaps(other.rect)) continue;
      other.alive = false;
      launched.vx *= .4;
      score += 450;
      message = 'GRAVITY LAUNCH: collision neutralized enemy +450.';
      _burst(other.center, const Color(0xFF8DE1FF), 18);
      GameFeedback.mediumImpact();
    }
  }

  void _tryAnchorCrate(_DueTarget crate, double impactSpeed) {
    if (impactSpeed < FallDueTuning.anchorImpactSpeed) return;
    for (var index = 0; index < spikes.length; index++) {
      if (disabledSpikes.contains(index)) continue;
      final spike = spikes[index];
      final overlapsBed = crate.rect.overlaps(spike.inflate(4));
      if (!overlapsBed) continue;
      disabledSpikes.add(index);
      // The crate crushes the teeth down into a short, lower bridge. It is a
      // safe foothold rather than a cosmetic "hazard disabled" state.
      final bridge = Rect.fromLTWH(spike.left, spike.top, spike.width, 55);
      platforms.add(bridge);
      crate
        ..anchored = true
        ..bridgeSpikeIndex = index
        ..bridgeSurface = bridge
        ..x = crate.x.clamp(spike.left - crate.w + 8, spike.right - 8)
        ..y = spike.top - crate.h
        ..vx = 0
        ..vy = 0;
      if (rewardedSpikes.add(index)) {
        score += 350;
        message = 'WEIGHT ANCHORED: crate sealed a spike bed +350.';
      } else {
        message = 'WEIGHT ANCHORED: bridge restored.';
      }
      _burst(crate.center, const Color(0xFF8CFFB1), 16);
      GameFeedback.mediumImpact();
      return;
    }
    for (final trap in spikeTraps) {
      if (trap.crushedToBridge) continue;
      if (crate.rect.overlaps(trap.rect.inflate(4))) {
        trap.crushedToBridge = true;
        final bridge =
            Rect.fromLTWH(trap.rect.left, trap.rect.top, trap.rect.width, 14);
        platforms.add(bridge);
        crate
          ..anchored = true
          ..bridgeSurface = bridge
          ..x = crate.x.clamp(trap.rect.left - crate.w + 8, trap.rect.right - 8)
          ..y = trap.rect.top - crate.h
          ..vx = 0
          ..vy = 0;
        score += 350;
        message =
            'WEIGHT ANCHORED: crate crushed retractable spike field into bridge dais +350.';
        _burst(crate.center, const Color(0xFF8CFFB1), 16);
        GameFeedback.mediumImpact();
        return;
      }
    }
  }

  void _updateLevers() {
    for (final lever in levers) {
      final trigger = Rect.fromCircle(center: lever.position, radius: 20);
      var boxTouching = false;
      var launchedEnemyHit = false;
      for (final target in targets) {
        if (!target.alive || !target.rect.overlaps(trigger)) continue;
        boxTouching |= target.kind.isCrate &&
            (target.puzzleId == lever.id || target.debt < -1 && target.vy <= 0);
        launchedEnemyHit |= target.kind.isEnemy &&
            (target.debt < -1 || target.stunTimer > 0 && target.vx.abs() > 190);
      }
      if (launchedEnemyHit || boxTouching) lever.latched = true;
      final wasActive = lever.active;
      lever.active = lever.latched;
      for (final gate in gates.where((gate) => gate.id == lever.id)) {
        gate.open = lever.active;
      }
      if (!wasActive && lever.active) {
        score += launchedEnemyHit ? 700 : 500;
        message = launchedEnemyHit
            ? 'LAUNCHED ENEMY HIT THE RECEIVER · Route open +700.'
            : 'LIFTED FREIGHT HIT THE RECEIVER · Route open +500.';
        _burst(lever.position, const Color(0xFF8CFFB1), 22);
        GameFeedback.mediumImpact();
      }
    }
  }

  void _updateTether(double dt) {
    final target = _tetherTarget;
    if (target == null) return;
    if (!target.alive) {
      _tetherTarget = null;
      return;
    }
    final r = target.center - player.center;
    final dist = r.distance;
    if (dist > FallDueTuning.tetherMaxDistance + 80) {
      _tetherTarget = null;
      message = 'TETHER SNAPPED: target exceeded range.';
      return;
    }
    if (dist > 40) {
      final pull = (dist - 40) * 12.0;
      final norm = r / dist;
      player.vx += norm.dx * pull * dt;
      player.vy += norm.dy * pull * dt;
      if (target is _DueTarget &&
          target.kind == _TargetKind.crate &&
          !target.anchored) {
        target.vx -= norm.dx * pull * 0.5 * dt;
        target.vy -= norm.dy * pull * 0.5 * dt;
      }
    }
  }

  void _updateTrapsAndPuzzles(double dt) {
    // 1. Crumbling Ledges
    for (final ledge in crumblingLedges) {
      if (ledge.collapsed) {
        ledge.respawnTimer += dt;
        if (ledge.respawnTimer >= ledge.maxRespawnTime) {
          ledge.collapsed = false;
          ledge.collapsing = false;
          ledge.collapseTimer = 0.0;
          ledge.respawnTimer = 0.0;
          _burst(ledge.rect.center, const Color(0xFF8DE1FF), 10);
        }
      } else if (ledge.collapsing) {
        ledge.collapseTimer += dt;
        if (ledge.collapseTimer >= ledge.maxCollapseTime) {
          ledge.collapsed = true;
          _burst(ledge.rect.center, const Color(0xFFC5ABD8), 18);
          GameFeedback.mediumImpact();
        }
      } else {
        final onLedge = player.grounded &&
            player.rect.bottom <= ledge.rect.top + 6 &&
            player.rect.bottom >= ledge.rect.top - 4 &&
            player.rect.right > ledge.rect.left + 4 &&
            player.rect.left < ledge.rect.right - 4;
        if (onLedge) {
          ledge.collapsing = true;
          ledge.maxCollapseTime =
              FallDueRules.crumblingLedgeCollapseDuration(_payback);
          ledge.collapseTimer = 0.0;
        }
      }
    }

    // 2. Retractable Spike Fields
    for (final trap in spikeTraps) {
      if (trap.disarmed) {
        trap.disarmedTimer -= dt;
        if (trap.disarmedTimer <= 0) trap.disarmed = false;
      }
      if (_spawnGrace <= 0 && trap.isActive(time) && !isInvulnerable) {
        if (player.rect.overlaps(trap.rect)) {
          _die('Pierced by pneumatic spike bed.');
          return;
        }
      }
    }

    // 3. Gravity Wells
    for (final well in gravityWells) {
      if (well.rig != null) {
        _applyRig(well, dt);
        continue;
      }
      if (well.inverted) {
        well.invertedTimer -= dt;
        if (well.invertedTimer <= 0) well.inverted = false;
      }
      final pDist = (well.center - player.center).distance;
      if (pDist < well.radius) {
        final dir = well.center - player.center;
        final norm =
            dir.distance > 0 ? dir / dir.distance : const Offset(0, -1);
        final factor = (1.0 - pDist / well.radius);
        if (well.inverted) {
          player.vx -= norm.dx * well.pullForce * 1.4 * factor * dt;
          player.vy = math.min(player.vy, -620.0);
          player.grounded = false;
        } else {
          player.vx +=
              norm.dx * well.pullForce * (1.0 + 0.01 * debt) * factor * dt;
          player.vy +=
              norm.dy * well.pullForce * (1.0 + 0.01 * debt) * factor * dt;
        }
      }
      for (final crate in targets.where(
        (t) => t.alive && t.kind == _TargetKind.crate && !t.anchored,
      )) {
        final cDist = (well.center - crate.center).distance;
        if (cDist < well.radius) {
          final dir = well.center - crate.center;
          final norm =
              dir.distance > 0 ? dir / dir.distance : const Offset(0, -1);
          final factor = (1.0 - cDist / well.radius);
          crate.vx += norm.dx *
              (well.inverted ? -1 : 1) *
              well.pullForce *
              0.7 *
              factor *
              dt;
          crate.vy += norm.dy *
              (well.inverted ? -1 : 1) *
              well.pullForce *
              0.7 *
              factor *
              dt;
        }
      }
      // Gravity well affects enemies
      for (final enemy in targets.where((t) => t.alive && t.kind!.isEnemy)) {
        final eDist = (well.center - enemy.center).distance;
        if (eDist < well.radius) {
          final dir = well.center - enemy.center;
          final norm =
              dir.distance > 0 ? dir / dir.distance : const Offset(0, -1);
          final factor = (1.0 - eDist / well.radius);
          if (well.inverted) {
            enemy.vx -= norm.dx * well.pullForce * 1.35 * factor * dt;
            enemy.vy = math.min(enemy.vy, -420.0);
            enemy.grounded = false;
            enemy.stunTimer = math.max(enemy.stunTimer, 0.6);
          } else {
            enemy.vx += norm.dx * well.pullForce * 0.9 * factor * dt;
            enemy.vy += norm.dy * well.pullForce * 0.9 * factor * dt;
            enemy.grounded = false;
            if (eDist < 32) {
              enemy.stunTimer = math.max(enemy.stunTimer, 0.4);
            }
          }
        }
      }
      // Gravity well affects turret bullets
      for (final bullet in bullets.where((b) => b.alive)) {
        final bDist = (well.center - bullet.rect.center).distance;
        if (bDist < well.radius) {
          final dir = well.center - bullet.rect.center;
          final norm =
              dir.distance > 0 ? dir / dir.distance : const Offset(1, 0);
          final factor = (1.0 - bDist / well.radius);
          if (well.inverted) {
            bullet.vx -= norm.dx * well.pullForce * 1.8 * factor * dt;
            bullet.vy -= norm.dy * well.pullForce * 1.8 * factor * dt;
          } else {
            bullet.vx += norm.dx * well.pullForce * 1.5 * factor * dt;
            bullet.vy += norm.dy * well.pullForce * 1.5 * factor * dt;
            if (bDist < 28 && !bullet.reflected) {
              bullet.reflected = true;
              bullet.debt = 25.0;
              final targetEnemy = _closestEnemy(well.center);
              if (targetEnemy != null) {
                final toEnemy = targetEnemy.center - well.center;
                final ed = toEnemy.distance;
                bullet.vx = (toEnemy.dx / ed) * 460;
                bullet.vy = (toEnemy.dy / ed) * 460;
              } else {
                bullet.vx = -bullet.vx * 1.3;
              }
              _burst(bullet.rect.center, const Color(0xFF6DE8FF), 10);
            }
          }
        }
      }
    }

    // 4. Laser Gates
    for (final gate in laserGates) {
      final switchEngaged = gate.switchId != null &&
          (levers.any((l) => l.id == gate.switchId && l.active) ||
              conduits.any((c) => c.id == gate.switchId && c.connected) ||
              weightPlates.any((w) => w.id == gate.switchId && w.satisfied));
      if (gate.isActive(time, switchEngaged)) {
        final occludingCrate = targets.where((t) =>
            t.alive &&
            t.kind == _TargetKind.crate &&
            t.rect.right > gate.rect.left + 2 &&
            t.rect.left < gate.rect.right - 2 &&
            (t.rect.overlaps(gate.rect) ||
                (t.rect.bottom >= gate.rect.top - 8 &&
                    t.rect.top <= gate.rect.top + 20)),
        ).firstOrNull;

        final blockedAtTop = occludingCrate != null &&
            (occludingCrate.rect.bottom <= gate.rect.top + 10 ||
                occludingCrate.rect.top <= gate.rect.top + 6);

        final lethalZone = blockedAtTop
            ? Rect.zero
            : (occludingCrate != null
                ? Rect.fromLTRB(
                    gate.rect.left,
                    gate.rect.top,
                    gate.rect.right,
                    math.max(gate.rect.top, occludingCrate.rect.top),
                  )
                : gate.rect);

        final warpingWell = gravityWells.where((w) =>
            (w.center.dx - gate.rect.center.dx).abs() < w.radius &&
            w.center.dy >= gate.rect.top - 30 &&
            w.center.dy <= gate.rect.bottom + 30).firstOrNull;

        final isDeflectedFromPlayer = warpingWell != null &&
            (player.center - warpingWell.center).distance < warpingWell.radius * 0.72;

        if (!lethalZone.isEmpty &&
            !isDeflectedFromPlayer &&
            _spawnGrace <= 0 &&
            !isInvulnerable) {
          if (player.rect.overlaps(lethalZone)) {
            _die('Vaporized by laser flux barrier.');
            return;
          }
        }
      }
    }

    // 5. Kinetic Vents
    for (final vent in vents) {
      if (vent.isActive(time)) {
        if (player.rect.overlaps(vent.rect)) {
          if (vent.isUpdraft) {
            player.vy = math.min(player.vy, -720.0);
            player.grounded = false;
          } else {
            player.vy += 2800.0 * dt;
          }
        }
        for (final crate in targets.where(
          (t) => t.alive && t.kind == _TargetKind.crate && !t.anchored,
        )) {
          if (crate.rect.overlaps(vent.rect)) {
            if (vent.isUpdraft) {
              crate.vy = math.min(crate.vy, -600.0);
              crate.grounded = false;
            } else {
              crate.vy += 2400.0 * dt;
            }
          }
        }
      }
    }

    // 6. Conduits
    for (final conduit in conduits) {
      conduit.connected = conduit.checkConnected();
      if (conduit.connected) {
        for (final gate in gates.where((g) => g.id == conduit.id)) {
          gate.open = true;
        }
      }
    }

    // 7. Weight Plates
    for (final plate in weightPlates) {
      var weight = 0.0;
      for (final crate in targets.where(
        (t) => t.alive && t.kind == _TargetKind.crate,
      )) {
        if (crate.rect.overlaps(plate.rect.inflate(4))) {
          weight += 10.0 + math.max(0, crate.debt);
        }
      }
      if (player.rect.overlaps(plate.rect.inflate(4))) {
        weight += 10.0 + _payback;
      }
      plate.currentWeight = weight;
      final wasSatisfied = plate.satisfied;
      plate.satisfied = plate.checkSatisfied();
      if (plate.satisfied) {
        for (final gate in gates.where((g) => g.id == plate.id)) {
          gate.open = true;
        }
        if (!wasSatisfied) {
          score += 450;
          message = 'WEIGHT PLATE SATISFIED: route gate unlocked +450.';
          _burst(plate.rect.center, const Color(0xFF8CFFB1), 16);
          GameFeedback.mediumImpact();
        }
      }
    }
  }

  bool _hasPatrolLedgeAhead(_DueTarget target, double dt) {
    final lookAhead = math.max(8, target.vx.abs() * dt * 1.5);
    final leadingEdge = target.vx >= 0
        ? target.x + target.w + lookAhead
        : target.x - lookAhead;
    final feet = target.y + target.h;
    return platforms.any(
      (platform) =>
          (platform.top - feet).abs() < 7 &&
          leadingEdge > platform.left + 3 &&
          leadingEdge < platform.right - 3,
    );
  }

  _DueStage _stageFor(int index) {
    if (index < stages.length) return stages[index];
    final cached = _generatedStages[index];
    if (cached != null) return cached;
    if (_generatedStages.length >= 10) {
      final oldest = _generatedStages.keys.reduce(math.min);
      _generatedStages.remove(oldest);
    }
    return _generatedStages[index] = _generateStage(index);
  }

  _DueStage _generateStage(int index) {
    return _FallDueLevelGenerator.generateStage(
      index,
      difficultyCurve: _contractDifficulty,
    );
  }

  void _updateBullets(double dt) {
    for (final emitter in emitters) {
      if (emitter.debt > 0) {
        emitter.debt = math.max(0, emitter.debt - 4 * dt);
      }
      emitter.cooldown -= dt;
      final nearActiveView =
          emitter.position.dx >= camera - 420 &&
          emitter.position.dx <= camera + viewWidth + 420;
      if (emitter.cooldown <= 0 && nearActiveView) {
        final shotDebt = emitter.debt * .75;
        final direction = emitter.speed.sign;
        bullets.add(
          _DueBullet(
              emitter.position.dx + direction * 18,
              emitter.position.dy - 20,
              emitter.speed / (1 + shotDebt * .012),
            )
            ..vy = -210
            ..debt = shotDebt
            ..reflected = emitter.reprogrammed,
        );
        emitter.cooldown = emitter.interval * (1 + emitter.debt * .014);
      }
    }
    for (final bullet in bullets) {
      bullet.vy += 360 * (1 + bullet.debt * .025) * dt;
      bullet.x += bullet.vx * dt;
      bullet.y += bullet.vy * dt;
      if (bullet.debt > 0) bullet.debt = math.max(0, bullet.debt - 5 * dt);
      if (!bullet.reflected &&
          _spawnGrace <= 0 &&
          player.rect.overlaps(bullet.rect)) {
        _die(bullet.arrow ? 'Pierced by an archer arrow.' : 'Projectile due.');
        return;
      }
      if ((bullet.reflected || bullet.debt > 3) && bullet.alive) {
        for (final target in targets) {
          if (!target.alive ||
              !target.kind!.isEnemy ||
              !bullet.rect.overlaps(target.rect)) {
            continue;
          }
          final damage = target.kind == _TargetKind.heavy ? 3 : target.health;
          target.health -= damage;
          if (target.health <= 0) {
            target.alive = false;
            final killScore = switch (target.kind) {
              _TargetKind.heavy => 950,
              _TargetKind.drone => 750,
              _TargetKind.leecher => 600,
              _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 500,
              _TargetKind.crate || null => 0,
            };
            score += killScore;
            message = 'PARRIED PLASMA SHREDDED ENEMY +$killScore';
            _burst(target.center, const Color(0xFFFFD86E), 18);
          } else {
            message =
                'PARRIED PLASMA STRUCK ENFORCER! ${target.health} HP LEFT';
            _burst(target.center, const Color(0xFFFFD86E), 12);
          }
          bullet.alive = false;
          break;
        }
        _breakWeakPanels(bullet.rect, 330, source: 'HEAVY TURRET SHOT');
        for (final lever in levers) {
          if (bullet.rect.overlaps(
            Rect.fromCircle(center: lever.position, radius: 14),
          )) {
            lever.latched = true;
            bullet.alive = false;
            message = 'SABOTAGED SHOT LATCHED A LEVER.';
          }
        }
      }
      if (bullet.alive &&
          targets.any(
            (target) =>
                target.alive &&
                (target.kind.isCrate ||
                    (target.kind!.isEnemy && target.debt >= 10)) &&
                bullet.rect.overlaps(target.rect),
          )) {
        bullet.alive = false;
      }
      final hitsWorld =
          platforms.any(bullet.rect.overlaps) ||
          _workshopsAt(bullet.rect.center.dx).any(
            (workshop) => workshop.surfaces.any(bullet.rect.overlaps) ||
                workshop.cargo.any(bullet.rect.overlaps),
          ) ||
          weakPanels.any(
            (panel) => !panel.broken && bullet.rect.overlaps(panel.rect),
          ) ||
          gates.any((gate) => !gate.open && bullet.rect.overlaps(gate.rect));
      if (hitsWorld ||
          bullet.y > 560 ||
          bullet.x < -120 ||
          bullet.x > exit.right + 140) {
        bullet.alive = false;
      }
    }
    bullets.removeWhere((bullet) => !bullet.alive);
  }

  bool _resolve(_DueBody body, double dt, double gravity) {
    body.grounded = false;
    body.vy = math.min(
      FallDueTuning.terminalVelocity,
      body.vy + FallDueTuning.gravity * gravity * dt,
    );
    final bodyIsEnemy = body is _DueTarget && body.kind!.isEnemy;
    final solidCrates = targets
        .where(
          (target) =>
              target != body &&
              target.alive &&
              target.kind == _TargetKind.crate,
        )
        .map((target) => target.rect);
    final heavyEnemies = targets
        .where(
          (target) =>
              target != body &&
              target.alive &&
              target.kind!.isEnemy &&
              target.debt >= 10,
        )
        .map((target) => target.rect);
    final activeWeakPanels = weakPanels
        .where((panel) => !panel.broken)
        .map((panel) => panel.rect);
    final activeCrumbling = crumblingLedges
        .where((l) => !l.collapsed)
        .map((l) => l.rect);
    final bridgeSpikes = spikeTraps
        .where((s) => s.crushedToBridge)
        .map((s) => Rect.fromLTWH(s.rect.left, s.rect.top, s.rect.width, 14));
    final nonDynamicPlatforms = platforms.where((p) =>
        !weakPanels.any((w) => w.rect == p) &&
        !crumblingLedges.any((c) => c.rect == p));
    final stableSurfaces = <Rect>[
      ...nonDynamicPlatforms,
      ...activeWeakPanels,
      ...activeCrumbling,
      ...bridgeSpikes,
    ];
    final nearbyWorkshops = _workshopsAt(body.center.dx);
    final surfaces = <Rect>[
      ...stableSurfaces,
      ...nearbyWorkshops.expand((workshop) => workshop.surfaces),
      ...nearbyWorkshops.expand((workshop) => workshop.cargo),
      ...gates.where((gate) => !gate.open).map((gate) => gate.rect),
      if (body == player || bodyIsEnemy || body is _DueTarget) ...solidCrates,
      if (body == player) ...heavyEnemies,
    ];
    final canRiseThroughPlatforms =
        (body is _DueTarget && body.kind!.isCrate && body.debt < -1) ||
        (body == player && _ridingLightBox);
    final distance = math.max(body.vx.abs(), body.vy.abs()) * dt;
    final steps = (distance / 5).ceil().clamp(1, 16);
    final slice = dt / steps;
    var landed = false;

    for (var index = 0; index < steps; index++) {
      final beforeX = body.rect;
      body.x += body.vx * slice;
      for (final platform in surfaces) {
        if (!body.rect.overlaps(platform)) continue;
        final wasBeside =
            beforeX.bottom > platform.top + 1 &&
            beforeX.top < platform.bottom - 1;
        if (!wasBeside) continue;
        if (body.vx > 0 && beforeX.right <= platform.left + 2) {
          body.x = platform.left - body.w;
        } else if (body.vx < 0 && beforeX.left >= platform.right - 2) {
          body.x = platform.right;
        } else {
          continue;
        }
        body.vx = (body.kind?.isEnemy ?? false) ? -body.vx : 0;
      }

      final beforeY = body.rect;
      body.y += body.vy * slice;
      for (final platform in surfaces) {
        if (!body.rect.overlaps(platform)) continue;
        if (body.vy >= 0 && beforeY.bottom <= platform.top + 2) {
          body.y = platform.top - body.h;
          body.vy = 0;
          body.grounded = true;
          landed = true;
        } else if (body.vy < 0 && beforeY.top >= platform.bottom - 2) {
          if (canRiseThroughPlatforms && stableSurfaces.contains(platform)) {
            continue;
          }
          body.y = platform.bottom;
          body.vy = 0;
        }
      }
    }
    return landed;
  }

  _DueGravityTarget? get _manualTarget {
    final selected = _selectedTarget;
    return selected != null && selected.alive ? selected : null;
  }

  Iterable<_DueGravityTarget> get _gravityTargets sync* {
    yield* targets.where((target) => target.alive);
    yield* emitters;
    yield* gravityWells;
    if (activeBoss case final boss? when boss.engaged && !boss.defeated) {
      yield boss.armor;
      yield boss.core;
    }
    for (final workshop in _workshopsAt(player.center.dx)) {
      yield* workshop.targets;
    }
  }

  double _distanceToTarget(_DueGravityTarget target) =>
      (target.center - player.center).distanceSquared;

  bool _targetInRange(_DueGravityTarget target) =>
      _distanceToTarget(target) < interactionRange * interactionRange;

  _DueGravityTarget? get _gravityRecipient =>
      _manualTarget ?? _closestGravityTarget(_gravityTargets);

  T? _closestGravityTarget<T extends _DueGravityTarget>(
    Iterable<T> candidates,
  ) {
    T? closest;
    var distance = interactionRange * interactionRange;
    for (final target in candidates) {
      if (!target.alive) continue;
      final next = _distanceToTarget(target);
      if (next < distance) {
        closest = target;
        distance = next;
      }
    }
    return closest;
  }

  void selectTargetAt(Offset point, double padding) {
    if (phase != _DuePhase.playing) return;
    _DueGravityTarget? closest;
    var closestDistance = double.infinity;
    var hitBody = false;
    for (final target in _gravityTargets) {
      if (!target.alive || !target.rect.inflate(padding).contains(point)) continue;
      final onBody = target.rect.contains(point);
      final distance = (point - target.center).distanceSquared;
      if (closest == null ||
          (onBody && !hitBody) ||
          (onBody == hitBody && distance < closestDistance)) {
        closest = target;
        closestDistance = distance;
        hitBody = onBody;
      }
    }

    if (closest == null) {
      if (_manualTarget == null) return;
      _selectedTarget = null;
      message = 'TARGET CLEARED — automatic targeting active.';
      GameFeedback.selection();
    } else {
      _selectTarget(closest);
    }
  }

  // Keep the existing shortcut available when playing without a pointer.
  void cycleTarget() {
    if (phase != _DuePhase.playing) return;
    final candidates = _gravityTargets.where((target) => target.alive && _targetInRange(target)).toList()
      ..sort((a, b) => _distanceToTarget(a).compareTo(_distanceToTarget(b)));
    if (candidates.isEmpty) {
      message = 'NO TARGETS IN RANGE — move closer.';
      return;
    }
    final current = candidates.indexWhere(
      (target) => identical(target, _manualTarget),
    );
    _selectTarget(candidates[(current + 1) % candidates.length]);
  }

  void _selectTarget(_DueGravityTarget target) {
    _selectedTarget = target;
    message = _targetInRange(target)
        ? 'SELECTED ${target.label} — Give or Take gravity.'
        : '${target.label} OUT OF RANGE — move closer.';
    GameFeedback.selection();
  }

  bool _checkSelectedTargetRange() {
    final target = _manualTarget;
    if (target == null || _targetInRange(target)) return true;
    message = '${target.label} OUT OF RANGE — move closer.';
    return false;
  }

  _DueBullet? _nearestBullet() {
    _DueBullet? closest;
    var distance = interactionRange;
    for (final bullet in bullets) {
      if (!bullet.alive || bullet.reflected) continue;
      final dist = (bullet.rect.center - player.center).distance;
      if (dist < distance) {
        closest = bullet;
        distance = dist;
      }
    }
    return closest;
  }

  void transferDebt() {
    if (phase != _DuePhase.playing) return;
    if (!_checkSelectedTargetRange()) return;
    if (_transferCooldown.isActive) {
      message = 'GRAVITY CHANNEL RECHARGING.';
      return;
    }
    final selected = _gravityRecipient;
    if (selected is _DueBossTarget) {
      _castBoss(selected, _Gravity.give);
      return;
    }
    if (selected is _DueGravityWell && selected.rig != null) {
      _activateRig(selected, _Gravity.give);
      return;
    }
    if (selected is _DueWorkshopTarget) {
      _castWorkshop(selected, _Gravity.give);
      return;
    }
    final bullet = selected == null ? _nearestBullet() : null;
    if (debt < 10 && (selected != null || bullet != null)) {
      debt = math.min(FallDueTuning.maxDebt, debt + 15.0);
      _burst(player.center, const Color(0xFFFFD86E), 6);
    }

    // Bullet gravity redirect if bullet is nearby and no other closer target
    if (bullet != null && (bullet.rect.center - player.center).distance < 200) {
      final targetEnemy = _closestEnemy(bullet.rect.center);
      if (targetEnemy != null) {
        final toEnemy = targetEnemy.center - bullet.rect.center;
        final dist = toEnemy.distance;
        final speed = 480.0;
        bullet.vx = (toEnemy.dx / dist) * speed;
        bullet.vy = (toEnemy.dy / dist) * speed;
      } else {
        bullet.vx = -bullet.vx * 1.3;
        bullet.vy = -180.0;
      }
      bullet.reflected = true;
      bullet.debt = 35.0;
      debt = math.max(0, debt - 10.0);
      score += 250;
      _transferCooldown.tryTrigger(.35);
      _burst(bullet.rect.center, const Color(0xFFFFD86E), 16);
      _showTransfer(bullet.rect.center);
      GameFeedback.mediumImpact();
      message = 'GRAVITY REDIRECT: bullet turned toward enemies +250.';
      return;
    }

    if (selected == null) {
      message = 'Move closer to an enemy, crate, or turret to give gravity.';
      return;
    }
    final requested = math
        .min(debt, math.min(30.0, math.max(10.0, debt * .65)))
        .toDouble();
    if (selected is _DueGravityWell) {
      final well = selected;
      well.inverted = true;
      well.invertedTimer = 4.0;
      debt = math.max(0, debt - 25.0);
      _transferCooldown.tryTrigger(.35);
      _burst(well.center, const Color(0xFF8CFFB1), 22);
      _showTransfer(well.center);
      ArcadeShake.shake(0.24);
      GameFeedback.heavyImpact();
      message =
          'VORTEX INVERSION! Gravity well converted to upward kinetic slingshot for 4.0s!';
      return;
    }
    if (selected is _DueEmitter) {
      final amount = math.min(requested, 60 - selected.debt).toDouble();
      debt -= amount;
      selected.debt += amount;
      final targetEnemy = _closestEnemy(selected.position);
      if (targetEnemy != null) {
        final dir = (targetEnemy.center.dx - selected.position.dx).sign;
        selected.speed = selected.speed.abs() * (dir == 0 ? 1 : dir);
      } else {
        selected.speed = -selected.speed;
      }
      selected.reprogrammed = true;
      selected.cooldown = 0;
      _transferCooldown.tryTrigger(.35);
      message = 'GAVE GRAVITY: Turret re-aimed toward enemies!';
      _burst(selected.position, const Color(0xFFFFD86E), 14);
      _showTransfer(selected.position);
      GameFeedback.selection();
      return;
    }
    final recipient = selected as _DueTarget;
    if (recipient.kind == _TargetKind.leecher && requested >= 15.0) {
      // Overload Siphon Leecher with excess debt!
      debt -= requested;
      recipient.alive = false;
      score += 600;
      _transferCooldown.tryTrigger(.35);
      _burst(recipient.center, const Color(0xFFC77DFF), 22);
      _showTransfer(recipient.center);
      GameFeedback.heavyImpact();
      message = 'SIPHON OVERLOAD! Leecher detonated by excess debt +600.';
      return;
    }
    if (recipient.kind == _TargetKind.drone) {
      // Drone GIVE: shove down into the ground ("like giving gravity")
      final amount = math.min(requested, 25.0);
      debt -= amount;
      recipient.vx *= 0.1;
      recipient.vy = FallDueRules.droneGiveDownwardSpeed();
      recipient.droneRecoveryTimer = 2.0;
      recipient.abilityCooldown = math.max(recipient.abilityCooldown, 2.5);
      _transferCooldown.tryTrigger(.35);
      _burst(recipient.center, const Color(0xFFFFD86E), 18);
      _showTransfer(recipient.center);
      GameFeedback.heavyImpact();
      ArcadeShake.shake(0.25);
      message =
          'GAVE ${amount.round()}% GRAVITY: drone shoved down into the ground!';
      return;
    }
    final amount = math.min(requested, 40 - recipient.debt).toDouble();
    if (amount < 1) {
      message = 'TARGET LEDGER FULL: Take weight back before giving more.';
      return;
    }
    debt -= amount;
    recipient.debt += amount;
    final pushDirection = recipient.center.dx >= player.center.dx ? 1.0 : -1.0;
    recipient.vx += pushDirection * (125 + amount * 7);
    _transferCooldown.tryTrigger(.35);
    message = recipient.kind == _TargetKind.crate
        ? 'GAVE ${amount.round()}% TO CRATE: push it into a spike bed to build a bridge.'
        : recipient.kind == _TargetKind.drone
        ? 'GAVE ${amount.round()}% TO DRONE: gravity overload pulling drone down.'
        : recipient.kind == _TargetKind.heavy
        ? 'GAVE ${amount.round()}% TO ENFORCER: weighed down and shoved backward.'
        : 'GAVE ${amount.round()}% TO COLLECTOR: heavy, slow, and shoved toward the edge.';
    _burst(recipient.center, const Color(0xFFFFD86E), 10);
    _showTransfer(recipient.center);
    GameFeedback.selection();
  }

  void stealDebt() {
    if (phase != _DuePhase.playing) return;
    if (!_checkSelectedTargetRange()) return;
    if (_transferCooldown.isActive) {
      message = 'GRAVITY CHANNEL RECHARGING.';
      return;
    }

    var selected = _gravityRecipient;
    if (selected is _DueBossTarget) {
      _castBoss(selected, _Gravity.take);
      return;
    }
    if (selected is _DueGravityWell && selected.rig != null) {
      _activateRig(selected, _Gravity.take);
      return;
    }
    if (selected is _DueWorkshopTarget) {
      _castWorkshop(selected, _Gravity.take);
      return;
    }
    final bullet = _manualTarget == null ? _nearestBullet() : null;
    if (bullet != null &&
        (bullet.rect.center - player.center).distance <
            FallDueTuning.parryRange) {
      final targetEnemy = _closestEnemy(bullet.rect.center);
      if (targetEnemy != null) {
        final toEnemy = targetEnemy.center - bullet.rect.center;
        final dist = toEnemy.distance;
        final speed = 520.0;
        bullet.vx = (toEnemy.dx / dist) * speed;
        bullet.vy = (toEnemy.dy / dist) * speed;
      } else {
        bullet.vx = -bullet.vx * 1.5;
        bullet.vy = -140.0;
      }
      bullet.debt = 25.0;
      bullet.reflected = true;
      debt = math.min(FallDueTuning.maxDebt, debt + 12.0);
      score += FallDueTuning.parryBonusScore;
      _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
      _transferCooldown.tryTrigger(.35);
      ArcadeShake.shake(0.22);
      GameFeedback.selection();
      _burst(bullet.rect.center, const Color(0xFF8DE1FF), 18);
      _showTransfer(bullet.rect.center, taking: true);
      message =
          'PLASMA PARRY! Shot reversed and directed at enemies +${FallDueTuning.parryBonusScore}.';
      return;
    }

    if (selected == null) {
      performRepulsorBurst();
      return;
    }
    if (selected is _DueGravityWell) {
      final well = selected;
      well.inverted = false;
      well.debt = 0;
      debt = math.min(FallDueTuning.maxDebt, debt + 20.0);
      _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
      _transferCooldown.tryTrigger(.35);
      _burst(well.center, const Color(0xFF8DE1FF), 14);
      _showTransfer(well.center, taking: true);
      message = 'GRAVITY RECLAIMED: well restored to standard attraction.';
      return;
    }
    if (selected is _DueEmitter) {
      final emitter = selected;
      final targetEnemy = _closestEnemy(emitter.position);
      if (targetEnemy != null) {
        final dir = (targetEnemy.center.dx - emitter.position.dx).sign;
        emitter.speed = emitter.speed.abs() * (dir == 0 ? 1 : dir);
      } else {
        emitter.speed = -emitter.speed;
      }
      emitter.reprogrammed = true;
      emitter.cooldown = 0;
      debt = math.min(FallDueTuning.maxDebt, debt + 15.0);
      _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
      _transferCooldown.tryTrigger(.45);
      message = 'TOOK GRAVITY: Turret reversed and directed at enemies!';
      _burst(emitter.position, const Color(0xFF8DE1FF), 14);
      _showTransfer(emitter.position, taking: true);
      GameFeedback.selection();
      return;
    }
    final recipient = selected as _DueTarget;
    final isLiftableBox = recipient.kind == _TargetKind.crate;
    final isEnemy = recipient.kind.isEnemy;
    final reclaimingLoan = !isLiftableBox && recipient.debt > 1;
    final naturalGravity = isLiftableBox
        ? (32 + recipient.debt).clamp(0.0, 72.0)
        : (32 + recipient.debt).clamp(0.0, 32.0);
    final maxTransfer = math.max(0.0, FallDueTuning.maxDebt - debt);
    final amount = reclaimingLoan
        ? math.min(math.min(recipient.debt, 22), maxTransfer)
        : math.min(
            math.min(isLiftableBox ? 30.0 : 14.0, naturalGravity),
            maxTransfer,
          );
    if (isLiftableBox && naturalGravity < 1) {
      message = reclaimingLoan
          ? 'YOUR LEDGER IS FULL: release or give some gravity first.'
          : 'THAT TARGET IS ALREADY WEIGHTLESS.';
      return;
    }
    if (isLiftableBox) {
      // Boxes have their own natural weight. A TAKE operation pulls that as
      // well as any loaned weight, guaranteeing a useful upward response.
      if (recipient.anchored) {
        recipient.anchored = false;
        if (recipient.bridgeSurface case final bridge?) {
          platforms.remove(bridge);
        }
        if (recipient.bridgeSpikeIndex case final spikeIndex?) {
          disabledSpikes.remove(spikeIndex);
        }
        recipient
          ..bridgeSurface = null
          ..bridgeSpikeIndex = null;
        message = 'BRIDGE RECALLED: the spike bed is exposed again.';
      }
      recipient.debt = math.max(-32, recipient.debt - math.min(30, naturalGravity) - 8);
    } else if (reclaimingLoan) {
      recipient.debt -= amount;
    } else if (amount > 0) {
      recipient.debt = math.max(-32, recipient.debt - amount);
    }
    if (amount > 0) {
      debt = math.min(FallDueTuning.maxDebt, debt + amount);
    }
    final pushDirection = recipient.center.dx >= player.center.dx ? 1.0 : -1.0;
    if (isLiftableBox) {
      recipient
        ..vx *= .22
        ..vy = math.min(recipient.vy, -470);
      // MOMENTUM SLINGSHOT: If player is standing on or right beside the crate being lifted, catapult player upward!
      final pRect = player.rect;
      final cRect = recipient.rect;
      if ((pRect.bottom - cRect.top).abs() < 16 &&
          pRect.right > cRect.left - 6 &&
          pRect.left < cRect.right + 6) {
        player.vy = math.min(player.vy, -560.0);
        player.grounded = false;
        _burst(player.center, const Color(0xFF6EF0B7), 16);
        ArcadeShake.shake(0.35);
        GameFeedback.jump();
      }
    } else if (isEnemy) {
      // TAKE on Enemies: repulsor siphon blasts enemy away by 500 to 1000 pixels!
      recipient.vx = pushDirection * FallDueRules.enemyTakeBlastSpeed();
      recipient.vy = math.min(recipient.vy, -120.0);
      recipient.grounded = false;
      recipient.stunTimer = 1.6;
      recipient.droneRecoveryTimer = 2.4;
      recipient.abilityCooldown = math.max(recipient.abilityCooldown, 3.0);
    } else {
      recipient.vx += pushDirection * (245 + amount * 11);
    }
    _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
    _transferCooldown.tryTrigger(.45);
    message = isEnemy
        ? 'GRAVITY SIPHON: enemy blasted away (500-1000px)!'
        : recipient.kind == _TargetKind.crate && recipient.debt < -1
        ? 'YELLOW CRATE UNWEIGHTED: it is rising through the overhead route.'
        : recipient.kind == _TargetKind.crate
        ? 'CRATE LIGHTENED: Take once more to reverse its gravity.'
        : reclaimingLoan
        ? 'TOOK ${amount.round()}% BACK: credit is ready for another lift.'
        : 'TOOK ${amount.round()}% OF NATURAL GRAVITY: target is light and knocked outward.';
    _burst(recipient.center, const Color(0xFF8DE1FF), isEnemy ? 18 : 10);
    _showTransfer(recipient.center, taking: true);
    if (isEnemy) ArcadeShake.shake(0.24);
    GameFeedback.selection();
  }

  void _die(String reason, {bool settleDebt = true}) {
    if (phase != _DuePhase.playing || _spawnGrace > 0) return;
    final impact = player.center;
    lives--;
    if (lives > 0) {
      _spawnGrace = 1.2;
      if (player.y > 570) {
        _resetPlayerAtCheckpoint();
      } else {
        player.vy = -180;
        player.vx = player.vx >= 0 ? -120 : 120;
      }
      message = '$reason  $lives heart${lives == 1 ? '' : 's'} left.';
      _burst(impact, const Color(0xFFFF7186), 14);
      GameFeedback.heavyImpact();
      ArcadeShake.shake(0.35);
      ArcadeFlash.flash(const Color(0x44FF7186));
      return;
    }
    _payback = !settleDebt ? 0 : FallDueRules.paybackAfterDeath(
      carriedDebt: debt,
      payback: _payback,
    );
    debt = 0;
    _settleGrace = 0;
    _antiGravityActive = false;
    _borrowHeld = false;
    _restoreCheckpointWorld();
    _resetPlayerAtCheckpoint();
    if (lives > 0) {
      _spawnGrace = .85;
      final checkpointNote = _checkpointIndex >= 0
          ? ' Returned to save point ${_checkpointIndex + 1}.'
          : '';
      message =
          '$reason  ${_payback.round()}% is still due. $lives heart${lives == 1 ? '' : 's'} left.$checkpointNote';
      _burst(impact, const Color(0xFFFF7186), 14);
      GameFeedback.heavyImpact();
      ArcadeShake.shake(0.35);
      ArcadeFlash.flash(const Color(0x44FF7186));
    } else {
      phase = _DuePhase.dead;
      message = '$reason  No hearts left; ${_payback.round()}% remains due.';
      GameFeedback.defeat();
      ArcadeShake.shake(0.65);
      ArcadeFlash.flash(const Color(0x77FF2A55));
      ArcadeFever.reset();
    }
  }

  void _resetPlayerAtFieldStart() {
    _resetPlayerAt(const Offset(70, 393));
  }

  void _resetPlayerAtCheckpoint() {
    final position = _checkpointIndex >= 0
        ? checkpoints[_checkpointIndex].position
        : const Offset(70, 393);
    _resetPlayerAt(position);
  }

  void _resetPlayerAt(Offset position) {
    left = false;
    right = false;
    _jumpHeld = false;
    _borrowHeld = false;
    _antiGravityActive = false;
    _jumpBuffer = 0;
    _settleGrace = 0;
    _transferCooldown.clear();
    _slamCooldown.clear();
    _slamming = false;
    _slamBorrowPower = 0.0;
    _slamHeld = false;
    _hasAirDashed = false;
    _airDashRemaining = 0;
    _landedAt = double.negativeInfinity;
    _landingForce = 0;
    transferArcs.clear();
    player = _DueBody(position.dx, position.dy, 27, 37)..grounded = true;
  }
}

class _FallDueShockwave {
  _FallDueShockwave({
    required this.position,
    required this.color,
    this.maxRadius = FallDueTuning.shockwaveRadius,
  });

  final Offset position;
  final Color color;
  final double maxRadius;
  static const double life = 0.45;
  double time = 0;
}

class _DueTransferArc {
  _DueTransferArc(this.origin, this.destination, this.color);

  static const life = .42;
  final Offset origin;
  final Offset destination;
  final Color color;
  double time = 0;
}

enum _TargetKind { crate, enemy, drone, heavy, leecher, swordsman, archer }

extension _TargetKindX on _TargetKind? {
  bool get isEnemy => this != null && this != _TargetKind.crate;
  bool get isCrate => this == _TargetKind.crate;
}

class _DueStage {
  const _DueStage({
    required this.title,
    required this.briefing,
    required this.platforms,
    required this.spikes,
    required this.targets,
    required this.seals,
    required this.exit,
    this.emitters = const [],
    this.gravityPuzzles = const [],
    this.weakPanels = const [],
    this.safeDebtPads = const [],
    this.crumblingLedges = const [],
    this.spikeTraps = const [],
    this.gravityWells = const [],
    this.laserGates = const [],
    this.vents = const [],
    this.conduits = const [],
    this.weightPlates = const [],
    this.route,
  });

  final String title;
  final String briefing;
  final List<Rect> platforms;
  final List<Rect> spikes;
  final List<_DueTargetSpec> targets;
  final List<Offset> seals;
  final List<_DueEmitterSpec> emitters;
  final List<_GravityPuzzleSpec> gravityPuzzles;
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
  final _DueRoute? route;

  List<Rect> get allPlatforms => [...platforms, ...?route?.platforms];
  List<Rect> get allSpikes => [...spikes, ...?route?.spikes];
  List<_DueTargetSpec> get allTargets => [...targets, ...?route?.targets];
  List<Offset> get allSeals => [...seals, ...?route?.seals];
  List<_DueEmitterSpec> get allEmitters => [...emitters, ...?route?.emitters];
  List<_GravityPuzzleSpec> get allGravityPuzzles => [
    ...gravityPuzzles,
    ...?route?.gravityPuzzles,
  ];
  List<Rect> get allWeakPanels => [...weakPanels, ...?route?.weakPanels];
  List<Rect> get allSafeDebtPads => [...safeDebtPads, ...?route?.safeDebtPads];
  List<Rect> get allCrumblingLedges => [
    ...crumblingLedges,
    ...?route?.crumblingLedges,
  ];
  List<_DueSpikeTrapSpec> get allSpikeTraps => [
    ...spikeTraps,
    ...?route?.spikeTraps,
  ];
  List<_DueGravityWellSpec> get allGravityWells => [
    ...gravityWells,
    ...?route?.gravityWells,
  ];
  List<_DueLaserGateSpec> get allLaserGates => [
    ...laserGates,
    ...?route?.laserGates,
  ];
  List<_DueKineticVentSpec> get allVents => [...vents, ...?route?.vents];
  List<_DueConduitSpec> get allConduits => [...conduits, ...?route?.conduits];
  List<_DueWeightPlateSpec> get allWeightPlates => [
    ...weightPlates,
    ...?route?.weightPlates,
  ];
  Rect get finalExit => route?.exit ?? exit;
}

/// A deliberately authored tail that turns the compact opening layout into a
/// full route. The opening teaches the stage's core verb; these sections ask
/// the player to apply it in a different kind of space instead of repeating
/// the same ground-gap pattern.
class _DueRoute {
  const _DueRoute({
    required this.sections,
    required this.platforms,
    required this.spikes,
    required this.seals,
    required this.exit,
    this.targets = const [],
    this.emitters = const [],
    this.gravityPuzzles = const [],
    this.weakPanels = const [],
    this.safeDebtPads = const [],
    this.crumblingLedges = const [],
    this.spikeTraps = const [],
    this.gravityWells = const [],
    this.laserGates = const [],
    this.vents = const [],
    this.conduits = const [],
    this.weightPlates = const [],
  });

  final List<_DueSectionSpec> sections;
  final List<Rect> platforms;
  final List<Rect> spikes;
  final List<_DueTargetSpec> targets;
  final List<Offset> seals;
  final List<_DueEmitterSpec> emitters;
  final List<_GravityPuzzleSpec> gravityPuzzles;
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

class _DueSectionSpec {
  const _DueSectionSpec(this.start, this.title, this.instruction);

  final double start;
  final String title;
  final String instruction;
}

class _GravityPuzzleSpec {
  const _GravityPuzzleSpec({
    required this.id,
    required this.boxPosition,
    required this.leverPosition,
    required this.gate,
  });

  final int id;
  final Offset boxPosition;
  final Offset leverPosition;
  final Rect gate;
}

class _DueTargetSpec {
  const _DueTargetSpec(this.x, this.y, this.kind);
  final double x;
  final double y;
  final _TargetKind kind;
}

class _DueEmitterSpec {
  const _DueEmitterSpec(this.x, this.y, this.speed, this.interval);
  final double x;
  final double y;
  final double speed;
  final double interval;
}

class _DueBody {
  _DueBody(this.x, this.y, this.w, this.h, {this.kind});
  double x;
  double y;
  final double w;
  final double h;
  double vx = 0;
  double vy = 0;
  double coyote = 0;
  bool grounded = false;
  _TargetKind? kind;
  double get left => x;
  double get right => x + w;
  double get top => y;
  double get bottom => y + h;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
  Offset get center => Offset(x + w / 2, y + h / 2);
}

sealed class _DueGravityTarget {
  Offset get center;
  Rect get rect;
  String get label;
  bool get alive;
}

class _DueTarget extends _DueBody implements _DueGravityTarget {
  _DueTarget(
    super.x,
    super.y,
    super.w,
    super.h,
    _TargetKind kind, {
    this.puzzleId,
  }) : super(kind: kind) {
    health = switch (kind) {
      _TargetKind.heavy => 5,
      _TargetKind.enemy || _TargetKind.swordsman || _TargetKind.archer => 3,
      _TargetKind.drone => 2,
      _TargetKind.leecher => 2,
      _TargetKind.crate => 2,
    };
    maxHealth = health;
    lastY = y;
    droneHomeY = y;
  }
  int health = 2;
  int maxHealth = 2;
  double debt = 0;
  double lastY = 0;
  double droneHomeY = 0;
  double droneRecoveryTimer = 0;
  double stunTimer = 0;
  double abilityCooldown = 0;
  double attackTell = 0;
  Rect? preparedAttack;
  double attackDirection = 1;
  Offset attackAim = Offset.zero;
  @override
  bool alive = true;
  bool anchored = false;
  final int? puzzleId;
  int? bridgeSpikeIndex;
  Rect? bridgeSurface;

  @override
  String get label => switch (kind) {
    _TargetKind.heavy => 'ENFORCER',
    _TargetKind.drone => 'DRONE',
    _TargetKind.leecher => 'LEECHER',
    _TargetKind.enemy => 'COLLECTOR',
    _TargetKind.swordsman => 'SWORD GUARD',
    _TargetKind.archer => 'ARCHER',
    _TargetKind.crate => 'CRATE',
    null => 'TARGET',
  };

  _DueTarget copy() => _DueTarget(x, y, w, h, kind!, puzzleId: puzzleId)
    ..vx = vx
    ..vy = vy
    ..coyote = coyote
    ..grounded = grounded
    ..health = health
    ..maxHealth = maxHealth
    ..debt = debt
    ..lastY = lastY
    ..droneHomeY = droneHomeY
    ..droneRecoveryTimer = droneRecoveryTimer
    ..stunTimer = stunTimer
    ..abilityCooldown = abilityCooldown
    ..attackTell = attackTell
    ..preparedAttack = preparedAttack
    ..attackDirection = attackDirection
    ..attackAim = attackAim
    ..alive = alive
    ..anchored = anchored
    ..bridgeSpikeIndex = bridgeSpikeIndex
    ..bridgeSurface = bridgeSurface;
}

class _DueBullet {
  _DueBullet(this.x, this.y, this.vx);
  double x;
  double y;
  double vx;
  double vy = 0;
  double debt = 0;
  bool alive = true;
  bool reflected = false;
  bool arrow = false;
  Rect get rect => Rect.fromLTWH(x, y, 14, 14);
}

class _DueSeal {
  _DueSeal(this.position);
  final Offset position;
  final double radius = 11;
  bool collected = false;

  _DueSeal copy() => _DueSeal(position)..collected = collected;
}

class _DueEmitter implements _DueGravityTarget {
  _DueEmitter(this.position, this.speed, this.interval) : cooldown = interval;
  _DueEmitter.fromSpec(_DueEmitterSpec spec)
    : this(Offset(spec.x, spec.y), spec.speed, spec.interval);
  final Offset position;
  double speed;
  final double interval;
  double cooldown;
  double debt = 0;
  bool reprogrammed = false;

  @override
  Offset get center => position;

  @override
  Rect get rect => Rect.fromCenter(center: position, width: 30, height: 30);

  @override
  String get label => 'TURRET';

  @override
  bool get alive => true;

  _DueEmitter copy() => _DueEmitter(position, speed, interval)
    ..cooldown = cooldown
    ..debt = debt
    ..reprogrammed = reprogrammed;
}

class _DueLever {
  _DueLever(this.id, this.position);
  _DueLever.fromSpec(_GravityPuzzleSpec spec)
    : this(spec.id, spec.leverPosition);

  final int id;
  final Offset position;
  bool active = false;
  bool latched = false;

  _DueLever copy() => _DueLever(id, position)
    ..active = active
    ..latched = latched;
}

class _DueGate {
  _DueGate(this.id, this.rect);
  _DueGate.fromSpec(_GravityPuzzleSpec spec) : this(spec.id, spec.gate);

  final int id;
  final Rect rect;
  bool open = false;

  _DueGate copy() => _DueGate(id, rect)..open = open;
}

class _DueCheckpoint {
  _DueCheckpoint(this.position);

  final Offset position;
  bool active = false;
}

class _DueWeakPanel {
  _DueWeakPanel(this.rect);

  final Rect rect;
  bool broken = false;

  _DueWeakPanel copy() => _DueWeakPanel(rect)..broken = broken;
}

class _DueSafeDebtPad {
  _DueSafeDebtPad(this.rect);

  final Rect rect;
  double cooldown = 0;
}

class _DueCheckpointSnapshot {
  const _DueCheckpointSnapshot({
    required this.score,
    required this.platforms,
    required this.spikes,
    required this.exit,
    required this.targets,
    required this.seals,
    required this.emitters,
    required this.levers,
    required this.gates,
    required this.weakPanels,
    required this.disabledSpikes,
    required this.rewardedSpikes,
    this.crumblingLedges = const [],
    this.spikeTraps = const [],
    this.gravityWells = const [],
    this.laserGates = const [],
    this.vents = const [],
    this.conduits = const [],
    this.weightPlates = const [],
    this.safeDebtPads = const [],
    this.workshops = const [],
    this.openingRelay,
    this.bossHealth,
  });

  final int score;
  final List<Rect> platforms;
  final List<Rect> spikes;
  final Rect exit;
  final List<_DueTarget> targets;
  final List<_DueSeal> seals;
  final List<_DueEmitter> emitters;
  final List<_DueLever> levers;
  final List<_DueGate> gates;
  final List<_DueWeakPanel> weakPanels;
  final Set<int> disabledSpikes;
  final Set<int> rewardedSpikes;
  final List<_DueCrumblingLedge> crumblingLedges;
  final List<_DueSpikeTrap> spikeTraps;
  final List<_DueGravityWell> gravityWells;
  final List<_DueLaserGate> laserGates;
  final List<_DueKineticVent> vents;
  final List<_DueConduit> conduits;
  final List<_DueWeightPlate> weightPlates;
  final List<Rect> safeDebtPads;
  final List<_WorkshopSave> workshops;
  final _WorkshopSave? openingRelay;
  final int? bossHealth;
}

class _DueParticle {
  _DueParticle(this.position, this.velocity, this.color, this.life);
  Offset position;
  Offset velocity;
  final Color color;
  double life;
}

class _DueCrumblingLedge {
  _DueCrumblingLedge(this.rect);
  final Rect rect;
  double collapseTimer = 0.0;
  double maxCollapseTime = 1.20;
  bool collapsing = false;
  bool collapsed = false;
  double respawnTimer = 0.0;
  double maxRespawnTime = 3.50;

  _DueCrumblingLedge copy() => _DueCrumblingLedge(rect)
    ..collapseTimer = collapseTimer
    ..maxCollapseTime = maxCollapseTime
    ..collapsing = collapsing
    ..collapsed = collapsed
    ..respawnTimer = respawnTimer
    ..maxRespawnTime = maxRespawnTime;
}

class _DueSpikeTrap {
  _DueSpikeTrap(this.rect, {this.cycleOffset = 0.0});
  final Rect rect;
  final double cycleOffset;
  bool disarmed = false;
  double disarmedTimer = 0.0;
  bool crushedToBridge = false;

  bool isActive(double time) =>
      !disarmed &&
      !crushedToBridge &&
      FallDueRules.retractableSpikeActive(time + cycleOffset);

  bool isTelegraphing(double time) {
    if (disarmed || crushedToBridge) return false;
    final t = (time + cycleOffset) % 3.20;
    return t >= 2.80; // 0.40s prior to extension
  }

  _DueSpikeTrap copy() => _DueSpikeTrap(rect, cycleOffset: cycleOffset)
    ..disarmed = disarmed
    ..disarmedTimer = disarmedTimer
    ..crushedToBridge = crushedToBridge;
}

class _DueGravityWell implements _DueGravityTarget {
  _DueGravityWell(
    this.center, {
    this.radius = 180.0,
    this.rig,
  });
  @override
  final Offset center;
  final double radius;
  final _WellRig? rig;
  double get pullForce => FallDueTuning.gravityWellPull;
  bool inverted = false;
  bool drawing = false;
  double invertedTimer = 0.0;
  double debt = 0.0;

  @override
  Rect get rect => Rect.fromCircle(center: center, radius: 24.0);

  @override
  String get label => rig?.title ?? (inverted ? 'KINETIC UPDRAFT' : 'GRAVITY WELL');

  @override
  bool get alive => true;

  _DueGravityWell copy() =>
      _DueGravityWell(center, radius: radius, rig: rig)
        ..inverted = inverted
        ..drawing = drawing
        ..invertedTimer = invertedTimer
        ..debt = debt;
}

class _DueLaserGate {
  _DueLaserGate(
    this.rect, {
    this.switchId,
    this.cycleOffset = 0.0,
  });
  final Rect rect;
  final int? switchId;
  final double cycleOffset;

  bool isActive(double time, bool switchEngaged) {
    if (switchEngaged) return false;
    return FallDueRules.laserGateActive(time + cycleOffset, switchEngaged);
  }

  _DueLaserGate copy() => _DueLaserGate(
    rect,
    switchId: switchId,
    cycleOffset: cycleOffset,
  );
}

class _DueKineticVent {
  _DueKineticVent(
    this.rect, {
    this.isUpdraft = true,
    this.cycleOffset = 0.0,
  });
  final Rect rect;
  final bool isUpdraft;
  final double cycleOffset;
  static const double cyclePeriod = 2.40;
  static const double activeDuration = 1.40;

  bool isActive(double time) =>
      ((time + cycleOffset) % cyclePeriod) < activeDuration;

  _DueKineticVent copy() =>
      _DueKineticVent(rect, isUpdraft: isUpdraft, cycleOffset: cycleOffset);
}

class _DueConduit {
  _DueConduit(this.id, this.emitterPos, this.receptorPos, this.alignment);
  final int id;
  final Offset emitterPos;
  final Offset receptorPos;
  final List<int> alignment;
  bool connected = false;

  bool checkConnected() => FallDueRules.conduitPowerConnected(alignment);

  _DueConduit copy() => _DueConduit(
    id,
    emitterPos,
    receptorPos,
    List<int>.from(alignment),
  )..connected = connected;
}

class _DueWeightPlate {
  _DueWeightPlate(this.id, this.rect);
  final int id;
  final Rect rect;
  double currentWeight = 0.0;
  bool satisfied = false;

  bool checkSatisfied() => FallDueRules.weightAnchorSatisfied(currentWeight);

  _DueWeightPlate copy() => _DueWeightPlate(id, rect)
    ..currentWeight = currentWeight
    ..satisfied = satisfied;
}

class _DueSpikeTrapSpec {
  const _DueSpikeTrapSpec(
    this.x,
    this.y,
    this.w,
    this.h, {
    this.cycleOffset = 0.0,
  });
  final double x;
  final double y;
  final double w;
  final double h;
  final double cycleOffset;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
}

class _DueGravityWellSpec {
  const _DueGravityWellSpec(
    this.x,
    this.y, {
    this.radius = 180.0,
  });
  final double x;
  final double y;
  final double radius;
  Offset get center => Offset(x, y);
}

class _DueLaserGateSpec {
  const _DueLaserGateSpec(
    this.x,
    this.y,
    this.w,
    this.h, {
    this.switchId,
    this.cycleOffset = 0.0,
  });
  final double x;
  final double y;
  final double w;
  final double h;
  final int? switchId;
  final double cycleOffset;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
}

class _DueKineticVentSpec {
  const _DueKineticVentSpec(
    this.x,
    this.y,
    this.w,
    this.h, {
    this.isUpdraft = true,
    this.cycleOffset = 0.0,
  });
  final double x;
  final double y;
  final double w;
  final double h;
  final double cycleOffset;
  final bool isUpdraft;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
}

class _DueConduitSpec {
  const _DueConduitSpec(
    this.id,
    this.emitterPos,
    this.receptorPos,
    this.alignment,
  );
  final int id;
  final Offset emitterPos;
  final Offset receptorPos;
  final List<int> alignment;
}

class _DueWeightPlateSpec {
  const _DueWeightPlateSpec(this.id, this.x, this.y, this.w, this.h);
  final int id;
  final double x;
  final double y;
  final double w;
  final double h;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
}
