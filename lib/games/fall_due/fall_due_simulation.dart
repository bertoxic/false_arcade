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
      title: 'FIRST INSTALMENT',
      briefing:
          'Learn the rhythm across a full route: jump, feather Borrow, and land with control.',
      platforms: const [
        Rect.fromLTWH(-40, 430, 400, 110),
        Rect.fromLTWH(470, 430, 360, 110),
        Rect.fromLTWH(960, 430, 410, 110),
        Rect.fromLTWH(1480, 430, 480, 110),
        Rect.fromLTWH(500, 335, 150, 18),
        Rect.fromLTWH(1005, 315, 155, 18),
        Rect.fromLTWH(1330, 260, 135, 18),
      ],
      spikes: const [
        Rect.fromLTWH(360, 465, 110, 55),
        Rect.fromLTWH(830, 465, 130, 55),
        Rect.fromLTWH(1370, 465, 110, 55),
      ],
      targets: const [],
      seals: const [
        Offset(300, 390),
        Offset(560, 300),
        Offset(1060, 280),
        Offset(1395, 225),
        Offset(1740, 390),
      ],
      safeDebtPads: const [Rect.fromLTWH(1530, 423, 92, 7)],
      exit: const Rect.fromLTWH(1840, 350, 56, 80),
      route: const _DueRoute(
        sections: [
          _DueSectionSpec(
            1900,
            'LOAN LAB',
            'Use Take on the yellow audit crate to float it through the lift shaft and hold the first lock.',
          ),
          _DueSectionSpec(
            3500,
            'NARROW MARGIN',
            'A tight sequence rewards controlled short hops; the second crate opens the only clean exit.',
          ),
          _DueSectionSpec(
            4650,
            'SETTLEMENT RUN',
            'Finish on staggered ledges, then use the safe pad before the final landing.',
          ),
        ],
        platforms: [
          Rect.fromLTWH(1900, 430, 270, 110),
          Rect.fromLTWH(2180, 430, 230, 110),
          Rect.fromLTWH(2525, 430, 260, 110),
          Rect.fromLTWH(2790, 360, 135, 18),
          Rect.fromLTWH(2960, 300, 130, 18),
          Rect.fromLTWH(3130, 235, 145, 18),
          Rect.fromLTWH(3350, 430, 270, 110),
          Rect.fromLTWH(3680, 430, 125, 110),
          Rect.fromLTWH(3910, 430, 105, 110),
          Rect.fromLTWH(4140, 430, 115, 110),
          Rect.fromLTWH(4315, 430, 280, 110),
          Rect.fromLTWH(4635, 335, 125, 18),
          Rect.fromLTWH(4795, 275, 140, 18),
          Rect.fromLTWH(4965, 335, 120, 18),
          Rect.fromLTWH(4820, 430, 210, 110),
          Rect.fromLTWH(5110, 430, 540, 110),
        ],
        spikes: [
          Rect.fromLTWH(2410, 465, 115, 55),
          Rect.fromLTWH(3620, 465, 60, 55),
          Rect.fromLTWH(3805, 465, 105, 55),
          Rect.fromLTWH(4015, 465, 125, 55),
          Rect.fromLTWH(4255, 465, 60, 55),
          Rect.fromLTWH(4595, 465, 225, 55),
          Rect.fromLTWH(5030, 465, 80, 55),
        ],
        gravityPuzzles: [
          _GravityPuzzleSpec(
            id: 11,
            boxPosition: Offset(2300, 390),
            leverPosition: Offset(2318, 218),
            gate: Rect.fromLTWH(2470, 145, 32, 285),
          ),
          _GravityPuzzleSpec(
            id: 12,
            boxPosition: Offset(3980, 390),
            leverPosition: Offset(3980, 205),
            gate: Rect.fromLTWH(4270, 145, 32, 285),
          ),
        ],
        seals: [
          Offset(2050, 390),
          Offset(2320, 180),
          Offset(3025, 265),
          Offset(3970, 350),
          Offset(4795, 240),
          Offset(5370, 390),
        ],
        safeDebtPads: [
          Rect.fromLTWH(3370, 423, 92, 7),
          Rect.fromLTWH(4870, 423, 92, 7),
        ],
        exit: Rect.fromLTWH(5600, 350, 56, 80),
      ),
    ),
    _DueStage(
      title: 'TRANSFER BRIDGE',
      briefing:
          'Give weight to build a bridge, then Take from the marked crate to latch the route gate.',
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
        Rect.fromLTWH(810, 465, 130, 55),
        Rect.fromLTWH(1280, 465, 150, 55),
      ],
      targets: const [
        _DueTargetSpec(220, 390, _TargetKind.crate),
        _DueTargetSpec(1030, 258, _TargetKind.crate),
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
            'Give the loose crate weight and shove it into the long spike bed to make your first bridge.',
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
        Rect.fromLTWH(915, 330, 135, 18),
        Rect.fromLTWH(1120, 260, 150, 18),
        Rect.fromLTWH(1440, 315, 145, 18),
      ],
      spikes: const [
        Rect.fromLTWH(260, 465, 140, 55),
        Rect.fromLTWH(730, 465, 140, 55),
        Rect.fromLTWH(1220, 465, 140, 55),
      ],
      targets: const [
        _DueTargetSpec(325, 303, _TargetKind.enemy),
        _DueTargetSpec(555, 243, _TargetKind.enemy),
        _DueTargetSpec(965, 288, _TargetKind.enemy),
        _DueTargetSpec(1490, 273, _TargetKind.enemy),
        _DueTargetSpec(1160, 390, _TargetKind.crate),
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
          Rect.fromLTWH(3590, 350, 120, 18),
          Rect.fromLTWH(3760, 275, 140, 18),
          Rect.fromLTWH(3950, 340, 120, 18),
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
        Rect.fromLTWH(700, 465, 180, 55),
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
      weakPanels: const [
        Rect.fromLTWH(1270, 390, 180, 16),
        Rect.fromLTWH(1750, 390, 180, 16),
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
  final List<_DueParticle> particles = [];
  final List<_FallDueShockwave> shockwaves = [];
  final Set<int> disabledSpikes = {};
  final Set<int> rewardedSpikes = {};
  Rect? _activeExit;
  _DueBody player = _DueBody(70, 370, 27, 37);
  _DueTarget? _selectedTarget;
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
  int get lockedGates => gates.where((gate) => !gate.open).length;
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
  List<_DueSectionSpec> get routeSections => level.route?.sections ?? const [];
  int get visibleCollectors => targets
      .where(
        (target) =>
            target.alive &&
            target.kind == _TargetKind.enemy &&
            target.center.dx >= camera - 40 &&
            target.center.dx <= camera + viewWidth + 40,
      )
      .length;

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
    message = 'STAGE $stageNumber: $stage.briefing';
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
    bullets.clear();
    particles.clear();
    shockwaves.clear();
    disabledSpikes.clear();
    rewardedSpikes.clear();
    _appendCampaignAnnex();
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
    _activeExit = annex.exit;
  }

  _DueTarget _targetFromSpec(_DueTargetSpec target) {
    final (w, h) = switch (target.kind) {
      _TargetKind.heavy => (40.0, 46.0),
      _TargetKind.drone => (34.0, 30.0),
      _TargetKind.leecher => (28.0, 32.0),
      _TargetKind.enemy => (32.0, 42.0),
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
  }

  void setBorrow(bool value) {
    if (value && !_borrowHeld && phase == _DuePhase.playing) {
      final hasHorizontal = left || right;
      if (!player.grounded && hasHorizontal && !_hasAirDashed) {
        // GRAVITY DASH: Directional horizontal aerial impulse (once per jump)
        _hasAirDashed = true;
        final dir = (right ? 1.0 : 0.0) - (left ? 1.0 : 0.0);
        player.vx = dir * FallDueTuning.dashImpulse;
        player.vy = math.min(player.vy, -130.0);
        debt = math.min(
          FallDueTuning.maxDebt,
          debt + FallDueTuning.dashDebtCost,
        );
        _burst(player.center, const Color(0xFF8DE1FF), 14);
        ArcadeShake.shake(0.18);
        GameFeedback.jump();
        message = 'GRAVITY DASH: directional air burst borrowed!';
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
    if (!value && _borrowHeld) {
      _openSettlementWindow();
    }
    _borrowHeld = value;
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
    _borrowHeld = false;
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

  Set<_DueTarget> _triggerGravitationalShockwave(Offset center, {bool isSlam = false}) {
    final discharged = _payback > 0 ? _payback : debt;
    // Discharges 65% of debt/payback into kinetic blast, leaving 35% due
    _payback = discharged * 0.35;
    debt = math.max(0, debt - discharged);
    final dynamicRadius = FallDueTuning.shockwaveRadius +
        (discharged * 0.3).clamp(0.0, 30.0);

    shockwaves.add(
      _FallDueShockwave(
        position: center,
        color: isSlam ? const Color(0xFFFF7186) : const Color(0xFFFFD86E),
        maxRadius: dynamicRadius,
      ),
    );
    ArcadeShake.shake(0.48);
    ArcadeFlash.flash(isSlam ? const Color(0x66FF7186) : const Color(0x55FFD86E));
    ArcadeHitStop.freeze(0.08);
    ArcadeFever.charge(0.25, currentMusicTheme: 'platform_theme');
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
        enemy.vx += pushDir * 95.0;
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
            _TargetKind.enemy => 650,
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
        crate.vx += pushDir * 75.0;
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
    _updatePlayer(dt);
    if (phase != _DuePhase.playing) return;
    _updateTargets(dt);
    _updateLevers();
    _updateBullets(dt);
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
    player.vx = player.vx
        .clamp(-FallDueTuning.runSpeed, FallDueTuning.runSpeed)
        .toDouble();
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
    final landed = _resolve(player, dt, gravity);
    if (landed) {
      _hasAirDashed = false;
      if (wasSlamming) {
        _slamming = false;
        if (FallDueRules.slamCausesShockwave(slamPower)) {
          // Highest borrow causes shockwaves!
          shockwaveHitTargets =
              _triggerGravitationalShockwave(player.center, isSlam: true);
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
          message = 'LIGHT SLAM: Borrow more gravity to unleash heavier impact.';
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
              _TargetKind.enemy => 550,
              _TargetKind.crate || null => 0,
            };
            score += killScore;
            final name = switch (target.kind) {
              _TargetKind.heavy => 'ENFORCER',
              _TargetKind.drone => 'DRONE',
              _TargetKind.leecher => 'LEECHER',
              _TargetKind.enemy => 'LIABILITY',
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
          // Siphon Leecher latches on and drains balance into Payback!
          target.alive = false;
          _payback = math.min(FallDueTuning.maxDebt, _payback + 28.0);
          _burst(player.center, const Color(0xFFC77DFF), 18);
          GameFeedback.heavyImpact();
          ArcadeShake.shake(0.24);
          message =
              'LEDGER LEECHED! Siphon leech attached +28% Payback to your balance!';
        } else {
          _die('Crushed by liability.');
          return;
        }
      }
    }
    if (wasSlamming) {
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
        final dist = (target.center - player.center).distance;
        if (dist > radius) continue;

        final pushDir = target.center.dx >= player.center.dx ? 1.0 : -1.0;
        if (target.kind!.isEnemy) {
          enemiesPushed++;
          target.vx += pushDir * pushForce;
          target.vy = math.min(target.vy, -35.0);
          if (target.kind == _TargetKind.drone) {
            target.droneRecoveryTimer = 0.4;
            target.abilityCooldown = math.max(target.abilityCooldown, 1.2);
          }
          _burst(target.center, const Color(0xFFFF7186), 8);
        } else if (target.kind == _TargetKind.crate && !target.anchored) {
          target.vx += pushDir * (pushForce * 0.5);
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
        ..addAll(level.allSafeDebtPads.map(_DueSafeDebtPad.new));
      disabledSpikes
        ..clear()
        ..addAll(snapshot.disabledSpikes);
      rewardedSpikes
        ..clear()
        ..addAll(snapshot.rewardedSpikes);
      for (final target in targets) {
        if (target.anchored) {
          if (target.bridgeSurface case final bridge?) {
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
    for (final puzzle in level.allGravityPuzzles) {
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
      message = 'GATE LOCKED: latch $lockedGates remaining gravity lock(s).';
      return;
    }
    final cleanBonus = FallDueRules.cleanExitBonus(carriedDebt: debt, payback: _payback);
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

      if (target.kind == _TargetKind.enemy) {
        if (target.stunTimer > 0) {
          target.stunTimer = math.max(0, target.stunTimer - dt);
          target.vx = damp(target.vx, 0.28, dt);
        } else {
          final weight = (target.debt / 35).clamp(0.0, .78).toDouble();
          final patrolSpeed = 58 * (1 - weight);
          target.vx = target.vx == 0 ? patrolSpeed : target.vx;
          final desiredSpeed = target.vx.sign * patrolSpeed;
          if (target.debt > 0 || target.vx.abs() > patrolSpeed) {
            target.vx += (desiredSpeed - target.vx) * math.min(1, dt * 8);
          }
          if (target.grounded &&
              target.vx.abs() <= 70 &&
              !_hasPatrolLedgeAhead(target, dt)) {
            target.vx = -target.vx;
          }
        }
      } else if (target.kind == _TargetKind.drone) {
        // Aerial drone floats, stabilizes, and bobs
        if (target.droneRecoveryTimer > 0) {
          target.droneRecoveryTimer =
              math.max(0, target.droneRecoveryTimer - dt);
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
        // Drone Repulsor Pulse
        if (target.droneRecoveryTimer <= 0 && target.abilityCooldown <= 0) {
          final dist = (target.center - player.center).distance;
          if (dist < 220) {
            target.abilityCooldown = 2.4;
            final pushDir = player.center - target.center;
            if (pushDir.distance > 0) {
              player.vx += (pushDir.dx / pushDir.distance) * 260.0;
              player.vy = math.min(player.vy, -160.0);
            }
            shockwaves.add(_FallDueShockwave(
              position: target.center,
              color: const Color(0xFF6DE8FF),
              maxRadius: 70,
            ));
            debt = math.min(FallDueTuning.maxDebt, debt + 10.0);
            message = 'REPULSOR PULSE! Drone blast pushed you with +10% debt.';
            GameFeedback.lightImpact();
            ArcadeShake.shake(0.18);
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
        // Heavy Quake Stomp
        if (target.stunTimer <= 0 &&
            target.grounded &&
            target.abilityCooldown <= 0) {
          final dist = (target.center - player.center).distance;
          if (dist < 240 && player.grounded) {
            target.abilityCooldown = 3.2;
            shockwaves.add(_FallDueShockwave(
              position: target.rect.bottomCenter,
              color: const Color(0xFFFF5277),
              maxRadius: 90,
            ));
            ArcadeShake.shake(0.28);
            GameFeedback.heavyImpact();
            if (dist < 180 && player.grounded) {
              player.vy = -260.0;
              player.grounded = false;
              message = 'QUAKE STOMP! Enforcer ground tremor popped you into the air!';
            }
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
          final puzzle = level.allGravityPuzzles.firstWhere(
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
        _TargetKind.enemy => 700,
        _TargetKind.crate || null => 0,
      };
      score += killScore;
      message = 'CRATE DROP: enemy crushed +$killScore.';
      _burst(enemy.center, const Color(0xFFFFD86E), 20);
      GameFeedback.mediumImpact();
    }
  }

  void _launchEnemyIntoTargets(_DueTarget launched) {
    for (final other in targets) {
      if (!other.alive ||
          other == launched ||
          !other.kind!.isEnemy) {
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
  }

  void _updateLevers() {
    for (final lever in levers) {
      final trigger = Rect.fromCircle(center: lever.position, radius: 20);
      var boxTouching = false;
      var launchedEnemyHit = false;
      for (final target in targets) {
        if (!target.alive || !target.rect.overlaps(trigger)) continue;
        boxTouching |= target.puzzleId == lever.id;
        launchedEnemyHit |=
            target.kind == _TargetKind.enemy && target.debt < -1;
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
            ? 'LAUNCHED COLLECTOR HIT THE LEVER: gate latched open +700.'
            : 'CRATE LATCHED THE LEVER: route gate stays open +500.';
        _burst(lever.position, const Color(0xFF8CFFB1), 22);
        GameFeedback.mediumImpact();
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
            ..debt = shotDebt,
        );
        emitter.cooldown = emitter.interval * (1 + emitter.debt * .014);
      }
    }
    for (final bullet in bullets) {
      bullet.vy += 360 * (1 + bullet.debt * .025) * dt;
      bullet.x += bullet.vx * dt;
      bullet.y += bullet.vy * dt;
      if (bullet.debt > 0) bullet.debt = math.max(0, bullet.debt - 5 * dt);
      if (_spawnGrace <= 0 && player.rect.overlaps(bullet.rect)) {
        _die('Projectile due.');
        return;
      }
      if (bullet.debt > 3 && bullet.alive) {
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
              _TargetKind.enemy => 500,
              _TargetKind.crate || null => 0,
            };
            score += killScore;
            message = 'PARRIED PLASMA SHREDDED ENEMY +$killScore';
            _burst(target.center, const Color(0xFFFFD86E), 18);
          } else {
            message = 'PARRIED PLASMA STRUCK ENFORCER! ${target.health} HP LEFT';
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
    final stableSurfaces = <Rect>[...platforms, ...activeWeakPanels];
    final surfaces = <Rect>[
      ...stableSurfaces,
      ...gates.where((gate) => !gate.open).map((gate) => gate.rect),
      if (body == player || bodyIsEnemy || body is _DueTarget) ...solidCrates,
      if (body == player) ...heavyEnemies,
    ];
    final canRiseThroughPlatforms =
        (body is _DueTarget &&
            body.kind!.isCrate &&
            body.debt < -1) ||
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

  _DueTarget? _nearestTarget() {
    final candidates = _targetCandidates();
    if (_selectedTarget != null && candidates.contains(_selectedTarget)) {
      return _selectedTarget;
    }
    return candidates.isEmpty ? null : candidates.first;
  }

  List<_DueTarget> _targetCandidates() {
    final candidates =
        targets
            .where(
              (target) =>
                  target.alive &&
                  (target.center - player.center).distance < interactionRange,
            )
            .toList()
          ..sort(
            (a, b) => (a.center - player.center).distance.compareTo(
              (b.center - player.center).distance,
            ),
          );
    return candidates;
  }

  void cycleTarget() {
    if (phase != _DuePhase.playing) return;
    final candidates = _targetCandidates();
    if (candidates.isEmpty) {
      message = 'NO TARGETS IN RANGE: move closer, then cycle with F.';
      return;
    }
    final current = _selectedTarget == null
        ? -1
        : candidates.indexOf(_selectedTarget!);
    _selectedTarget = candidates[(current + 1) % candidates.length];
    final label = switch (_selectedTarget!.kind) {
      _TargetKind.heavy => 'ENFORCER',
      _TargetKind.drone => 'DRONE',
      _TargetKind.leecher => 'LEECHER',
      _TargetKind.enemy => 'COLLECTOR',
      _TargetKind.crate => 'CRATE',
      null => 'TARGET',
    };
    message =
        'TARGET ${candidates.indexOf(_selectedTarget!) + 1}/${candidates.length}: $label.';
    GameFeedback.selection();
  }

  _DueBullet? _nearestBullet() {
    _DueBullet? closest;
    var distance = interactionRange;
    for (final bullet in bullets) {
      if (!bullet.alive) continue;
      final dist = (bullet.rect.center - player.center).distance;
      if (dist < distance) {
        closest = bullet;
        distance = dist;
      }
    }
    return closest;
  }

  _DueEmitter? _nearestEmitter() {
    _DueEmitter? closest;
    var distance = interactionRange;
    for (final emitter in emitters) {
      final next = (emitter.position - player.center).distance;
      if (next < distance) {
        closest = emitter;
        distance = next;
      }
    }
    return closest;
  }

  bool _emitterIsCloser(_DueTarget? target, _DueEmitter? emitter) {
    if (_selectedTarget != null && target == _selectedTarget) return false;
    if (emitter == null) return false;
    if (target == null) return true;
    return (emitter.position - player.center).distance <
        (target.center - player.center).distance;
  }

  void transferDebt() {
    if (phase != _DuePhase.playing) return;
    if (_transferCooldown.isActive) {
      message = 'GRAVITY CHANNEL RECHARGING.';
      return;
    }
    // Instant micro-loan if debt is low, so player is never locked out of using Give
    if (debt < 10) {
      debt = math.min(FallDueTuning.maxDebt, debt + 15.0);
      _burst(player.center, const Color(0xFFFFD86E), 6);
    }
    final target = _nearestTarget();
    final emitter = _nearestEmitter();
    final bullet = _nearestBullet();

    // Bullet gravity slam if bullet is nearby and no other closer target
    if (bullet != null &&
        (bullet.rect.center - player.center).distance < 160 &&
        target == null &&
        emitter == null) {
      bullet.vy = 850.0;
      bullet.debt = 35.0;
      debt = math.max(0, debt - 10.0);
      score += 200;
      _transferCooldown.tryTrigger(.35);
      _burst(bullet.rect.center, const Color(0xFFFFD86E), 14);
      GameFeedback.mediumImpact();
      message = 'GRAVITY OVERLOAD: bullet grounded into the floor +200.';
      return;
    }

    if (target == null && emitter == null) {
      message = 'Move closer to an enemy, crate, or turret to give gravity.';
      return;
    }
    final requested = math
        .min(debt, math.min(30.0, math.max(10.0, debt * .65)))
        .toDouble();
    if (_emitterIsCloser(target, emitter)) {
      final amount = math.min(requested, 60 - emitter!.debt).toDouble();
      if (amount < 1) {
        message = 'TURRET LEDGER FULL: Take weight back before giving more.';
        return;
      }
      debt -= amount;
      emitter.debt += amount;
      emitter.cooldown += .3 + amount * .02;
      _transferCooldown.tryTrigger(.35);
      message =
          'GAVE ${amount.round()}% TO TURRET: its shots slow and fall sooner.';
      _burst(emitter.position, const Color(0xFFFFD86E), 10);
      GameFeedback.selection();
      return;
    }
    final recipient = target!;
    if (recipient.kind == _TargetKind.leecher && requested >= 15.0) {
      // Overload Siphon Leecher with excess debt!
      debt -= requested;
      recipient.alive = false;
      score += 600;
      _transferCooldown.tryTrigger(.35);
      _burst(recipient.center, const Color(0xFFC77DFF), 22);
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
    GameFeedback.selection();
  }

  void stealDebt() {
    if (phase != _DuePhase.playing) return;
    if (_transferCooldown.isActive) {
      message = 'GRAVITY CHANNEL RECHARGING.';
      return;
    }

    final bullet = _nearestBullet();
    if (bullet != null &&
        (bullet.rect.center - player.center).distance <
            FallDueTuning.parryRange) {
      // PLASMA PARRY: Invert and accelerate bullet back with heavy debt
      bullet.vx = -bullet.vx * 1.5;
      bullet.vy = -140.0;
      bullet.debt = 25.0;
      debt = math.min(FallDueTuning.maxDebt, debt + 12.0);
      score += FallDueTuning.parryBonusScore;
      _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
      _transferCooldown.tryTrigger(.35);
      ArcadeShake.shake(0.22);
      GameFeedback.selection();
      _burst(bullet.rect.center, const Color(0xFF8DE1FF), 18);
      message =
          'PLASMA PARRY! Shot reversed with +25 debt +${FallDueTuning.parryBonusScore}.';
      return;
    }

    final target = _nearestTarget();
    final emitter = _nearestEmitter();
    if (target == null && emitter == null) {
      message = 'Move closer to an enemy, crate, or turret to take gravity.';
      return;
    }
    if (emitter != null && (target == null || _emitterIsCloser(target, emitter))) {
      if (emitter.debt >= 2) {
        final amount = math.min(
          math.min(emitter.debt, 18),
          FallDueTuning.maxDebt - debt,
        );
        if (amount < 1) {
          message = 'YOUR LEDGER IS FULL: release or give gravity first.';
          return;
        }
        emitter.debt -= amount;
        debt += amount;
        _settleGrace = math.max(_settleGrace, FallDueTuning.settlementWindow);
        _transferCooldown.tryTrigger(.45);
        message =
            'TOOK ${amount.round()}% BACK: credit is ready for your next lift.';
        _burst(emitter.position, const Color(0xFF8DE1FF), 10);
        GameFeedback.selection();
        return;
      } else if (target == null) {
        message = 'That turret has no borrowed gravity to take.';
        return;
      }
      // If emitter has no debt to siphon, fallback to adjacent target!
    }
    final recipient = target!;
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
    if (!isEnemy && amount < 1) {
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
      recipient.debt = math.max(-32, recipient.debt - amount - 8);
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
    if (isEnemy) ArcadeShake.shake(0.24);
    GameFeedback.selection();
  }

  void _die(String reason) {
    if (phase != _DuePhase.playing) return;
    final impact = player.center;
    _payback = FallDueRules.paybackAfterDeath(
      carriedDebt: debt,
      payback: _payback,
    );
    debt = 0;
    _settleGrace = 0;
    _antiGravityActive = false;
    _borrowHeld = false;
    lives--;
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

enum _TargetKind { crate, enemy, drone, heavy, leecher }

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
  Rect get rect => Rect.fromLTWH(x, y, w, h);
  Offset get center => Offset(x + w / 2, y + h / 2);
}

class _DueTarget extends _DueBody {
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
      _TargetKind.enemy => 3,
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
  bool alive = true;
  bool anchored = false;
  final int? puzzleId;
  int? bridgeSpikeIndex;
  Rect? bridgeSurface;

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
  Rect get rect => Rect.fromLTWH(x, y, 14, 14);
}

class _DueSeal {
  _DueSeal(this.position);
  final Offset position;
  final double radius = 11;
  bool collected = false;

  _DueSeal copy() => _DueSeal(position)..collected = collected;
}

class _DueEmitter {
  _DueEmitter(this.position, this.speed, this.interval) : cooldown = interval;
  _DueEmitter.fromSpec(_DueEmitterSpec spec)
    : this(Offset(spec.x, spec.y), spec.speed, spec.interval);
  final Offset position;
  final double speed;
  final double interval;
  double cooldown;
  double debt = 0;

  _DueEmitter copy() => _DueEmitter(position, speed, interval)
    ..cooldown = cooldown
    ..debt = debt;
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
}

class _DueParticle {
  _DueParticle(this.position, this.velocity, this.color, this.life);
  Offset position;
  Offset velocity;
  final Color color;
  double life;
}
