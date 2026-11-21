part of 'fall_due_game.dart';

const _deck = Rect.fromLTWH(0, 454, 960, 86);
const _hoistTop = Rect.fromLTWH(862, 156, 73, 104);
const _leftBank = Rect.fromLTWH(0, 454, 365, 86);
const _rightBank = Rect.fromLTWH(641, 454, 319, 86);
const _pitFloor = Rect.fromLTWH(365, 528, 276, 12);
const _pitSteps = [
  Rect.fromLTWH(373, 487, 85, 13),
  Rect.fromLTWH(514, 480, 58, 12),
];
const _crackedShelf = Rect.fromLTWH(345, 355, 66, 14);
const _entryAct = 'The Entry Ledger';
const _worksAct = 'The Transfer Works';
const _towerAct = 'Settlement Tower';

Rect _rail(double x, double top, double bottom) =>
    Rect.fromLTRB(x, top, x, bottom);
Rect _area(double x, double y, [double w = 64, double h = 24]) =>
    Rect.fromCenter(center: Offset(x, y), width: w, height: h);

_Sensor _weight(
  String id,
  String label,
  double x, {
  double y = 454,
  double units = 2,
  double width = 76,
  List<String> props = const [],
  bool latch = true,
  List<String> requires = const [],
}) => _Sensor(
  id,
  label,
  _Sense.load,
  Rect.fromLTWH(x - width / 2, y - 12, width, 12),
  threshold: units,
  props: props,
  latch: latch,
  requires: requires,
);

_Sensor _catch(
  String id,
  String label,
  double x,
  double y,
  List<String> props, {
  double width = 70,
  double height = 25,
  bool capture = true,
  List<String> requires = const [],
}) => _Sensor(
  id,
  label,
  _Sense.catchBody,
  _area(x, y, width, height),
  props: props,
  capture: capture,
  requires: requires,
);

_Sensor _strike(
  String id,
  String label,
  double x,
  double y,
  List<String> props, {
  double load = 0,
  double speed = 225,
  List<String> requires = const [],
  double width = 65,
  double height = 26,
}) => _Sensor(
  id,
  label,
  _Sense.impact,
  _area(x, y, width, height),
  props: props,
  threshold: load,
  speed: speed,
  requires: requires,
);

_Prop _metal(
  String id,
  String label,
  double x,
  double y, {
  double? up,
  double? down,
  bool hanging = false,
  Size size = const Size(42, 42),
}) => _Prop(
  id,
  label,
  Offset(x, y),
  material: _Material.metal,
  hanging: hanging,
  size: size,
  rail: up == null ? null : _rail(x, up, down ?? y),
);

_Prop _ballast(
  String id,
  String label,
  double x,
  double y, {
  double? up,
  double? down,
  bool hanging = false,
}) => _Prop(
  id,
  label,
  Offset(x, y),
  material: _Material.ballast,
  hanging: hanging,
  rail: up == null ? null : _rail(x, up, down ?? y),
);

_Prop _float(
  String id,
  String label,
  double x,
  double y, {
  double? up,
  double? down,
  bool hanging = false,
  Size size = const Size(58, 35),
}) => _Prop(
  id,
  label,
  Offset(x, y),
  material: _Material.float,
  rail: up == null ? null : _rail(x, up, down ?? y),
  hanging: hanging,
  size: size,
);

_Prop _patrol(
  String id,
  String label,
  double x,
  double y,
  double left,
  double right, {
  _Material type = _Material.guard,
  bool recall = false,
}) => _Prop(
  id,
  label,
  Offset(x, y),
  material: type,
  rail: Rect.fromLTRB(
    left,
    type == _Material.drone ? y - 30 : y - 95,
    right,
    533,
  ),
  recall: recall,
);

_Room _rest(String title, String hint, {Offset? secret}) => _Room(
  title,
  hint,
  secret: secret,
  floors: const [
    _deck,
    Rect.fromLTWH(280, 389, 102, 13),
    Rect.fromLTWH(417, 296, 111, 13),
    Rect.fromLTWH(558, 362, 142, 13),
    Rect.fromLTWH(747, 406, 82, 13),
  ],
);

final _chapters = <_Chapter>[
  _Chapter(
    'First Instalment',
    _entryAct,
    _DueLandscape.grove,
    'The Grove’s freight system is carrying away more than cargo.',
    'A dispatch lists shipments of gravity taken from the orchard to Settlement Tower.',
    [
      _Room(
        'Freight school',
        'GIVE the load on the scale. TAKE the other crate into the upper catch.',
        props: [
          _metal('load', 'Scale crate', 254, 433, up: 318),
          _metal('rise', 'Lift crate', 451, 433, up: 277),
        ],
        sensors: [
          _weight('weight', 'Scale', 254, props: ['load']),
          _catch('up', 'Overhead catch', 451, 277, ['rise']),
        ],
        goals: const [
          ['weight', 'up'],
        ],
      ),
      _Room(
        'Loading Gate',
        'TAKE the silver reflector to bend the beam into the receiver. GIVE the floor freight for another route.',
        optic: const _Optic(
          'reflector',
          Offset(86, 301),
          594,
          Offset(267, 161),
        ),
        floors: const [
          _deck,
          Rect.fromLTWH(623, 349, 78, 13),
          Rect.fromLTWH(719, 304, 85, 13),
        ],
        props: [
          _metal('reflector', 'Silver reflector', 267, 433, up: 301),
          _metal('load', 'Floor freight', 375, 433, up: 330),
          _metal('paddle', 'Paddle freight', 525, 433, up: 286),
          _metal('chute', 'Return freight', 665, 328, up: 203, down: 328),
        ],
        sensors: [
          const _Sensor(
            'reflector',
            'Reflected beam',
            _Sense.optical,
            Rect.fromLTWH(256, 150, 22, 22),
            props: ['reflector'],
            capture: true,
          ),
          _weight('load', 'Floor plate', 375),
          _catch('paddle', 'Upper paddle', 525, 286, ['paddle']),
          _catch('crest', 'Return chute', 665, 208, ['chute'], capture: false),
          _strike(
            'drop',
            'Balcony return',
            665,
            337,
            ['chute'],
            load: 2,
            requires: ['crest'],
          ),
        ],
        goals: const [
          ['reflector'],
          ['load'],
          ['paddle'],
          ['drop'],
        ],
        barriers: const [
          _Barrier(Rect.fromLTWH(829, 290, 22, 164), [
            'reflector',
            'load',
            'paddle',
            'drop',
          ]),
        ],
        secret: const Offset(759, 279),
      ),
      _Room(
        'Broken Span',
        'Weight a press into the rack, ride a crate to the high ledge, or strike the hinge below.',
        floors: const [
          _leftBank,
          _rightBank,
          _pitFloor,
          ..._pitSteps,
          Rect.fromLTWH(633, 318, 106, 14),
        ],
        props: [
          _ballast(
            'press',
            'Rack press',
            405,
            320,
            up: 250,
            down: 493,
            hanging: true,
          ),
          _metal(
            'ride',
            'Lift freight',
            605,
            507,
            up: 353,
            down: 507,
            size: const Size(62, 42),
          ),
          _metal(
            'hinge',
            'Hinge weight',
            575,
            324,
            up: 254,
            down: 459,
            hanging: true,
          ),
        ],
        sensors: [
          _strike('rack', 'Pinned spike rack', 405, 484, ['press'], load: 3),
          _strike('hinge', 'Hinged crossing', 575, 466, ['hinge'], load: 2),
          const _Sensor(
            'high',
            'High crossing',
            _Sense.visit,
            Rect.fromLTWH(645, 255, 80, 63),
          ),
        ],
        goals: const [
          ['rack'],
          ['high'],
          ['hinge'],
        ],
        lift: const _Lift(Rect.fromLTWH(361, 521, 285, 14), Offset(0, -71), [
          'rack',
          'hinge',
        ]),
        traps: const [_Trap(Rect.fromLTWH(464, 502, 81, 25), off: 'rack')],
        service: const [Rect.fromLTWH(641, 454, 24, 72)],
      ),
      _bailiff(false),
      _bailiff(true),
      _rest(
        'Freight platform',
        'The repaired line heads toward the viaduct. Freight records point to the ridge.',
      ),
    ],
    290,
  ),
  _Chapter(
    'Transfer Bridge',
    _entryAct,
    _DueLandscape.grove,
    'Climb the workers’ viaduct and find where the missing weight went.',
    'A workers’ map marks a service approach into the inspection yard.',
    [
      _Room(
        'Counterweight practice',
        'Make the far pan heavier or lift the near load. Watch the carriage rise.',
        props: [
          _metal('near', 'Near load', 245, 433, up: 332),
          _metal('far', 'Far load', 449, 433, up: 314),
        ],
        sensors: [
          _weight('far', 'Far pan', 449),
          _catch('near', 'Unloaded near pan', 245, 350, ['near']),
        ],
        goals: const [
          ['far'],
          ['near'],
        ],
        lift: const _Lift(Rect.fromLTWH(555, 449, 145, 14), Offset(0, -85), [
          'far',
          'near',
        ]),
      ),
      _Room(
        'Counterweight Hoist',
        'Raise the carriage. Load the far pan, unload the near one, or take the spare above its stop.',
        spawn: const Offset(94, 431),
        exit: _hoistTop,
        floors: const [
          _deck,
          Rect.fromLTWH(542, 260, 418, 16),
          Rect.fromLTWH(750, 365, 78, 16),
          Rect.fromLTWH(800, 316, 73, 13),
        ],
        props: [
          _metal('near', 'Near-pan cargo', 309, 433, up: 310),
          _ballast('far', 'Far ballast', 553, 433, up: 365),
          _metal('spare', 'Service weight', 224, 433, up: 303),
        ],
        sensors: [
          _weight('far', 'Weighted far pan', 553, units: 3),
          _catch('near', 'Unloaded carriage', 309, 328, ['near']),
          _catch('spareup', 'Spare over stop', 224, 322, [
            'spare',
          ], capture: false),
          _strike(
            'spare',
            'Service weight returned',
            224,
            443,
            ['spare'],
            load: 2,
            requires: ['spareup'],
          ),
          const _Sensor(
            'dock',
            'Upper berth',
            _Sense.dock,
            Rect.fromLTWH(370, 232, 155, 27),
            requires: [],
          ),
        ],
        goals: const [
          ['far', 'dock'],
          ['near', 'dock'],
          ['spare', 'dock'],
        ],
        lift: const _Lift(Rect.fromLTWH(365, 445, 174, 16), Offset(0, -185), [
          'far',
          'near',
          'spare',
        ]),
        secret: const Offset(670, 238),
      ),
      _Room(
        'Balance Lock',
        'Balance the weight on both pans. Loading and unloading can reach the same result.',
        props: [
          _metal('left', 'Light pan load', 389, 433, up: 300),
          _ballast('right', 'Two-unit ballast', 604, 433, up: 350),
          const _Prop('loose', 'Movable one-unit freight', Offset(517, 433)),
        ],
        sensors: [
          _Sensor(
            'balanced',
            'Balanced route',
            _Sense.load,
            _area(391, 448, 135, 12),
            balance: _area(555, 448, 150, 12),
            threshold: .65,
          ),
          _catch('stored', 'Ballast removed', 604, 357, ['right']),
          _catch(
            'slide',
            'Distributed weight',
            420,
            433,
            ['loose'],
            width: 74,
            capture: false,
            requires: ['balanced'],
          ),
        ],
        goals: const [
          ['slide', 'balanced'],
          ['stored', 'balanced'],
          ['balanced'],
        ],
        traps: const [
          _Trap(
            Rect.fromLTWH(658, 348, 47, 106),
            kind: _Threat.sweep,
            off: 'balanced',
          ),
        ],
      ),
      _keeper(false),
      _keeper(true),
      _rest(
        'Canyon overlook',
        'The viaduct opens onto Ember Canyon. An inspection bell answers in the yard.',
      ),
    ],
    330,
  ),
  _Chapter(
    'Collection Day',
    _worksAct,
    _DueLandscape.canyon,
    'Make inspection machinery and its patrols work for you.',
    'The inspection manifest ties the transfer orders to the Auditor.',
    [
      _Room(
        'Shield demonstration',
        'Watch the firing lane from behind the divider. GIVE the shield or raise the reflector.',
        optic: const _Optic('mirror', Offset(331, 418), 670, Offset(484, 217)),
        props: [
          _metal(
            'shield',
            'Opaque shield',
            346,
            322,
            up: 260,
            down: 428,
            hanging: true,
            size: const Size(45, 52),
          ),
          _metal('mirror', 'Angled reflector', 484, 433, up: 418),
        ],
        sensors: [
          _weight('shield', 'Lowered shield', 346),
          const _Sensor(
            'reflect',
            'Reflector receiver',
            _Sense.optical,
            Rect.fromLTWH(473, 206, 22, 22),
            props: ['mirror'],
            capture: true,
          ),
        ],
        goals: const [
          ['shield'],
          ['reflect'],
        ],
        traps: const [
          _Trap(
            Rect.fromLTWH(331, 411, 339, 15),
            kind: _Threat.beam,
            shield: true,
            warning: 1.4,
          ),
        ],
      ),
      _Room(
        'Crossfire Switchback',
        'Lower the shield, raise the reflector, or cross behind the Inspector as the beam fires.',
        optic: const _Optic('mirror', Offset(400, 417), 739, Offset(550, 218)),
        floors: const [
          _deck,
          Rect.fromLTWH(313, 368, 88, 12),
          Rect.fromLTWH(658, 358, 88, 12),
        ],
        props: [
          _metal(
            'shield',
            'Guided shield',
            440,
            312,
            up: 256,
            down: 428,
            hanging: true,
            size: const Size(43, 52),
          ),
          _metal('mirror', 'Angled reflector', 550, 433, up: 417),
          _patrol(
            'inspector',
            'Armored Inspector',
            620,
            433,
            594,
            747,
            type: _Material.heavy,
          ),
          _patrol('loader-guard', 'Loading guard', 739, 433, 690, 776),
        ],
        sensors: [
          _weight('shield', 'Lowered cover', 440, props: ['shield']),
          const _Sensor(
            'mirror',
            'Redirected beam',
            _Sense.optical,
            Rect.fromLTWH(539, 207, 22, 22),
            props: ['mirror'],
            capture: true,
          ),
          const _Sensor(
            'bypass',
            'Service approach',
            _Sense.visit,
            Rect.fromLTWH(755, 335, 72, 116),
          ),
        ],
        goals: const [
          ['shield'],
          ['mirror'],
          ['bypass'],
        ],
        traps: const [
          _Trap(
            Rect.fromLTWH(400, 408, 339, 19),
            kind: _Threat.beam,
            shield: true,
            period: 4.6,
          ),
        ],
      ),
      _Room(
        'Freight Grate',
        'Drop an impact load, lift the release slug, or ground the drone onto the grate.',
        floors: const [
          _deck,
          Rect.fromLTWH(464, 448, 96, 6),
          _crackedShelf,
          Rect.fromLTWH(720, 345, 90, 12),
        ],
        service: const [Rect.fromLTWH(464, 448, 96, 6)],
        crumbling: const [_crackedShelf],
        props: [
          _ballast(
            'cargo',
            'Heavy cargo',
            474,
            297,
            up: 241,
            down: 425,
            hanging: true,
          ),
          _metal('slug', 'Release slug', 652, 433, up: 305),
          _patrol(
            'drone',
            'Inspection drone',
            533,
            287,
            533,
            533,
            type: _Material.drone,
            recall: true,
          ),
          _patrol('grate-guard', 'Grate guard', 508, 431, 459, 553),
        ],
        sensors: [
          _strike('cargo', 'Cargo impact', 477, 438, ['cargo'], load: 3),
          _strike('drone', 'Drone impact', 539, 438, ['drone'], load: 2),
          _catch('slug', 'Service release', 652, 309, ['slug']),
        ],
        goals: const [
          ['cargo'],
          ['slug'],
          ['drone'],
        ],
        secret: const Offset(763, 319),
      ),
      _marshal(false),
      _marshal(true),
      _rest(
        'Service tunnel',
        'The inspection manifest leads below the yard to a live coolant line.',
      ),
    ],
    380,
  ),
  _Chapter(
    'Debt Dive',
    _worksAct,
    _DueLandscape.canyon,
    'Reroute the coolant and keep the shelter pumps supplied.',
    'A maintenance memo records the shelters that stayed online through the diversion.',
    [
      _Room(
        'Buoyancy test',
        'Lift the test plug. Watch water leave the first basin and rise in the second.',
        basin: const _Basin(Rect.fromLTWH(300, 326, 252, 128), ['plug']),
        reserve: const Rect.fromLTWH(609, 326, 252, 128),
        props: [
          _float('plug', 'Upper valve plug', 334, 365, up: 259),
          _float('float', 'Test float', 460, 369, up: 241, down: 436),
        ],
        sensors: [
          _catch('plug', 'Bypass valve', 334, 260, ['plug']),
        ],
        goals: const [
          ['plug'],
        ],
      ),
      _Room(
        'Spill Junction',
        'Divert the runoff with ballast, lift the bottom plug, or reach the supply cutoff.',
        floors: const [
          _deck,
          Rect.fromLTWH(369, 368, 118, 14),
          Rect.fromLTWH(678, 337, 195, 15),
        ],
        basin: const _Basin(Rect.fromLTWH(442, 326, 225, 128), [
          'ballast',
          'plug',
          'cutoff',
        ], hot: true),
        reserve: const Rect.fromLTWH(741, 331, 170, 123),
        props: [
          _ballast('ballast', 'Diverter ballast', 346, 433, up: 362),
          _metal('plug', 'Bypass plug', 514, 423, up: 306),
          _float('float', 'Supply float', 619, 347, up: 236, down: 434),
        ],
        sensors: [
          _weight(
            'ballast',
            'Runoff diverted',
            346,
            units: 3,
            props: ['ballast'],
          ),
          _catch('plug', 'Lower drain', 514, 318, ['plug']),
          _catch('cutoff', 'Supply cut off', 619, 246, ['float']),
        ],
        goals: const [
          ['ballast'],
          ['plug'],
          ['cutoff'],
        ],
        secret: const Offset(730, 313),
      ),
      _Room(
        'Flooded Steps',
        'Moor the pontoon, ride the guided float, or move water to build a staircase.',
        exit: _hoistTop,
        floors: const [
          _deck,
          Rect.fromLTWH(580, 260, 380, 15),
          Rect.fromLTWH(229, 373, 95, 15),
          Rect.fromLTWH(479, 352, 46, 14),
        ],
        basin: const _Basin(
          Rect.fromLTWH(339, 268, 249, 186),
          ['sluice'],
          initial: .22,
          end: .84,
        ),
        reserve: const Rect.fromLTWH(87, 295, 211, 159),
        props: [
          _float(
            'pontoon',
            'Mooring pontoon',
            433,
            394,
            up: 294,
            down: 433,
            hanging: true,
          ),
          _float('ride', 'Guided lift float', 557, 431, up: 298),
          _metal('sluice', 'Side sluice', 330, 397, up: 273, hanging: true),
          _float('free', 'Free float', 375, 428, up: 275, down: 432),
          _float('free2', 'Free float', 505, 417, up: 273, down: 437),
        ],
        sensors: [
          _weight('moor', 'Moored pontoon', 433, y: 454, props: ['pontoon']),
          _catch('ride', 'Lift float docked', 557, 302, ['ride']),
          _catch('sluice', 'Side basin filled', 330, 278, ['sluice']),
        ],
        goals: const [
          ['moor'],
          ['ride'],
          ['sluice'],
        ],
        lift: const _Lift(Rect.fromLTWH(379, 451, 88, 14), Offset(0, -145), [
          'moor',
        ]),
      ),
      _custodian(false),
      _custodian(true),
      _rest(
        'Dry ascent',
        'The shelter pumps stay on as you climb toward the observatory.',
      ),
    ],
    405,
  ),
  _Chapter(
    'Compound Interest',
    _towerAct,
    _DueLandscape.ridge,
    'Ride the observatory’s currents before the blackout reaches the Grove.',
    'From the telescope archive, the outage line is visible on the horizon.',
    [
      _Room(
        'Current practice',
        'GIVE or TAKE the marked vane and follow the shape of the field.',
        floors: const [_deck, Rect.fromLTWH(597, 325, 117, 12)],
        props: [_metal('vane', 'Field vane', 318, 433, up: 324)],
        fields: const [
          _Field(
            Rect.fromLTWH(373, 232, 201, 221),
            Offset(630, 1020),
            vane: 'vane',
          ),
        ],
        sensors: [
          _weight('down', 'Vane lowered', 318, props: ['vane']),
          _catch('up', 'Vane raised', 318, 327, ['vane'], capture: false),
        ],
        goals: const [
          ['down'],
          ['up'],
        ],
      ),
      _Room(
        'Courier Loop',
        'Use the upper current, the low ballast chute, or drop freight behind the receiver.',
        props: [
          _metal('courier', 'Light courier', 434, 434, up: 279),
          _ballast(
            'heavy',
            'Heavy courier',
            613,
            301,
            up: 232,
            down: 433,
            hanging: true,
          ),
          const _Prop(
            'free',
            'Return courier',
            Offset(514, 433),
            material: _Material.brittle,
          ),
        ],
        fields: const [
          _Field(Rect.fromLTWH(503, 208, 81, 144), Offset(480, -650)),
        ],
        sensors: [
          _catch('top', 'Upper mouth', 434, 286, ['courier']),
          _strike('bottom', 'Lower chute', 613, 440, ['heavy'], load: 3),
          _catch(
            'crest',
            'Loop crest',
            541,
            268,
            ['free'],
            width: 120,
            height: 48,
            capture: false,
          ),
          _strike(
            'return',
            'Return mouth',
            640,
            438,
            ['free'],
            width: 198,
            load: 2,
            requires: ['crest'],
          ),
        ],
        goals: const [
          ['top'],
          ['bottom'],
          ['return'],
        ],
      ),
      _Room(
        'Observatory Brake',
        'Lift the rail platform, seat the shutter, or send a Collector into the brake.',
        exit: _hoistTop,
        floors: const [
          _deck,
          Rect.fromLTWH(629, 260, 331, 15),
          Rect.fromLTWH(486, 358, 48, 13),
        ],
        props: [
          _metal('lift', 'Rail platform switch', 319, 432, up: 312),
          _metal(
            'vane',
            'Current shutter',
            554,
            301,
            up: 230,
            down: 337,
            hanging: true,
          ),
          _patrol('collector', 'Collector', 555, 433, 511, 702),
        ],
        sensors: [
          _catch('lift', 'Outbound drift', 319, 314, ['lift']),
          _weight('vane', 'Isolated field', 554, y: 358, props: ['vane']),
          _strike('brake', 'Brake struck', 676, 423, ['collector'], speed: 255),
        ],
        goals: const [
          ['lift'],
          ['vane'],
          ['brake'],
        ],
        lift: const _Lift(Rect.fromLTWH(541, 448, 84, 14), Offset(0, -188), [
          'lift',
          'vane',
          'brake',
        ]),
        fields: const [
          _Field(
            Rect.fromLTWH(420, 240, 109, 214),
            Offset(560, -360),
            off: 'vane',
          ),
        ],
        secret: const Offset(777, 238),
      ),
      _cartographer(false),
      _cartographer(true),
      _rest(
        'Observatory deck',
        'Below the ridge, the orchard is going dark. Settlement Tower is still lit.',
      ),
    ],
    470,
  ),
  _Chapter(
    'Final Audit',
    _towerAct,
    _DueLandscape.ridge,
    'Restore the evacuation circuit and make the Tower release the Grove’s weight.',
    'The original transfer orders survive the evacuation. The Grove learns who signed them.',
    [
      _Room(
        'Routing schematic',
        'Power either bus. Once a route catches, the door will stay open.',
        props: [
          _metal('lower', 'Lower conductor', 322, 433, up: 317),
          _metal('upper', 'Upper rail arm', 486, 433, up: 309),
        ],
        sensors: [
          _weight('lower', 'Ground bus', 322),
          _catch('upper', 'Upper bus', 486, 311, ['upper']),
        ],
        goals: const [
          ['lower'],
          ['upper'],
        ],
      ),
      _Room(
        'Wake Override',
        'Raise and seat either branch. A Collector can push the service trolley onto the ground bus.',
        floors: const [_deck, Rect.fromLTWH(655, 373, 45, 12)],
        props: [
          _metal('lower', 'Lower conductor', 366, 433, up: 297),
          _metal('upper', 'Upper arm', 548, 432, up: 297),
          _ballast('shoe', 'Guide brake', 652, 352, up: 288),
          const _Prop(
            'trolley',
            'Service trolley',
            Offset(678, 433),
            material: _Material.metal,
          ),
          _patrol('collector', 'Collector', 584, 433, 554, 697),
        ],
        sensors: [
          _catch('above', 'Conductor over lip', 366, 306, [
            'lower',
          ], capture: false),
          _weight(
            'lower',
            'Ground circuit',
            366,
            props: ['lower'],
            requires: ['above'],
          ),
          _catch('upper', 'Upper contact', 548, 303, ['upper']),
          _weight(
            'shoe',
            'Guide clamped',
            652,
            y: 373,
            props: ['shoe'],
            units: 3,
            requires: ['upper'],
          ),
          _weight(
            'trolley',
            'Trolley circuit',
            751,
            props: ['trolley'],
            width: 126,
          ),
        ],
        goals: const [
          ['lower'],
          ['upper', 'shoe'],
          ['trolley'],
        ],
        traps: const [
          _Trap(
            Rect.fromLTWH(782, 352, 42, 102),
            kind: _Threat.sweep,
            period: 4.8,
          ),
        ],
        secret: const Offset(869, 413),
      ),
      _Room(
        'Isolate the Evacuation Lift',
        'Drop the breaker, raise the roof governor, or use the displacement pedal.',
        floors: const [
          _deck,
          Rect.fromLTWH(555, 358, 107, 15),
          Rect.fromLTWH(772, 313, 171, 15),
        ],
        props: [
          _ballast(
            'breaker',
            'Breaker slug',
            379,
            299,
            up: 244,
            down: 433,
            hanging: true,
          ),
          _metal('governor', 'Roof governor', 570, 338, up: 211),
          _float(
            'pontoon',
            'Displacement pontoon',
            671,
            341,
            up: 260,
            down: 437,
            hanging: true,
          ),
          _float('step', 'Buoyant step', 735, 424, up: 278, down: 434),
        ],
        basin: const _Basin(
          Rect.fromLTWH(649, 298, 180, 156),
          ['pedal'],
          initial: .1,
          end: .89,
        ),
        reserve: const Rect.fromLTWH(138, 333, 199, 121),
        fields: const [
          _Field(
            Rect.fromLTWH(582, 230, 87, 224),
            Offset(20, -1670),
            off: 'floor',
          ),
        ],
        sensors: [
          _strike('floor', 'Ground cutoff', 379, 442, ['breaker'], load: 3),
          _catch('roof', 'Roof governor', 570, 218, ['governor']),
          _weight('pedal', 'Displaced coolant', 671, props: ['pontoon']),
          const _Sensor(
            'manual',
            'Manual cutoff',
            _Sense.visit,
            Rect.fromLTWH(792, 257, 88, 55),
            requires: ['pedal'],
          ),
        ],
        goals: const [
          ['floor'],
          ['roof'],
          ['manual'],
        ],
      ),
      _auditorFuse(),
      _auditorCutoff(),
      _rest(
        'Evacuation',
        'The weight returns to the Grove. Follow the quiet platform to the exit.',
      ),
    ],
    560,
  ),
];

_Room _bailiff(bool second) {
  final x = second ? 683.0 : 562.0;
  final cover = x - 136;
  return _Room(
    second ? 'Moving press' : 'Freight press',
    'TAKE the crown guard into its catch. GIVE the press head so it breaks the exposed bearing.',
    props: [
      _metal('guard', 'Crown guard', cover, 433, up: 294),
      _ballast(
        'head',
        'Suspended press head',
        x,
        309,
        up: 224,
        down: 433,
        hanging: true,
      ),
    ],
    sensors: [
      _catch('guard', 'Crown exposed', cover, 300, ['guard']),
      _strike(
        'bearing',
        'Crown bearing',
        x,
        442,
        ['head'],
        load: 3,
        requires: ['guard'],
      ),
    ],
    goals: const [
      ['guard', 'bearing'],
    ],
    traps: [
      _Trap(
        Rect.fromLTWH(x - 115, 422, 207, 32),
        kind: _Threat.sweep,
        alternate: second ? Rect.fromLTWH(x - 270, 421, 137, 33) : null,
        warning: 1.12,
        travel: second ? const Offset(52, 0) : Offset.zero,
      ),
    ],
    boss: 'Yard Bailiff',
    weak: Offset(x, 427),
    checkpoint: !second,
  );
}

_Room _keeper(bool second) {
  final x = second ? 692.0 : 551.0;
  return _Room(
    second ? 'Second dock' : 'Docking deck',
    'TAKE the near cargo to raise the carriage. GIVE the station brake to hold at the axle.',
    floors: const [
      _deck,
      Rect.fromLTWH(240, 375, 87, 13),
      Rect.fromLTWH(786, 373, 73, 14),
    ],
    props: [
      _metal('cargo', 'Near-pan cargo', x - 143, 433, up: 311),
      _metal('shoe', 'Brake shoe', x + 26, 433, up: 348),
    ],
    sensors: [
      _catch('cargo', 'Carriage unloaded', x - 143, 316, ['cargo']),
      _Sensor('dock', 'Carriage docked', _Sense.dock, _area(x, 333)),
      _weight(
        'shoe',
        'Axle collar clamped',
        x + 26,
        requires: ['dock'],
        props: ['shoe'],
      ),
    ],
    goals: const [
      ['cargo', 'dock', 'shoe'],
    ],
    lift: _Lift(
      Rect.fromLTWH(x - 80, 443, 78, 13),
      const Offset(0, -113),
      const ['cargo'],
      speed: 164,
    ),
    traps: [
      _Trap(
        Rect.fromLTWH(x - 183, 404, 148, 21),
        kind: _Threat.sweep,
        warning: 1.05,
        alternate: second ? Rect.fromLTWH(x + 4, 365, 91, 89) : null,
      ),
    ],
    boss: 'Span Keeper',
    weak: Offset(x, 324),
    checkpoint: !second,
  );
}

_Room _marshal(bool second) {
  final x = second ? 716.0 : 629.0;
  return _Room(
    second ? 'Rear receptor' : 'Charge lane',
    'GIVE the front boot. From the left, TAKE a pulse into the rear receptor.',
    props: [
      _ballast('boot', 'Marshal front boot', x - 48, 433, up: 365),
      _Prop(
        'slug',
        'Guided pulse',
        Offset(x - 155, 384),
        material: _Material.pulse,
        size: const Size(28, 25),
        rail: Rect.fromLTRB(x - 180, 381, x + 65, 390),
        hanging: true,
      ),
      _patrol(
        'drone',
        'Inspection drone',
        x + 66,
        338,
        x + 45,
        x + 100,
        type: _Material.drone,
      ),
    ],
    sensors: [
      _weight('boot', 'Charge shortened', x - 48, units: 3, props: ['boot']),
      _strike(
        'back',
        'Rear receptor hit',
        x,
        386,
        ['slug', 'drone'],
        width: 43,
        requires: ['boot'],
      ),
    ],
    goals: const [
      ['boot', 'back'],
    ],
    traps: [
      _Trap(
        Rect.fromLTWH(x - 255, 422, 191, 32),
        kind: _Threat.sweep,
        off: 'boot',
        travel: const Offset(70, 0),
        alternate: second ? Rect.fromLTWH(x - 139, 397, 236, 19) : null,
      ),
    ],
    boss: 'Collection Marshal',
    weak: Offset(x, 386),
    checkpoint: !second,
  );
}

_Room _custodian(bool second) {
  final x = second ? 591.0 : 435.0;
  return _Room(
    second ? 'Return sump' : 'Pump chamber',
    'TAKE the cap into the bypass catch. GIVE the ballast to turn the flush through the bypass.',
    floors: const [
      _deck,
      Rect.fromLTWH(366, 352, 76, 13),
      Rect.fromLTWH(682, 347, 109, 13),
    ],
    props: [
      _float('cap', 'Sealed bypass cap', x - 105, 432, up: 292),
      _ballast('diverter', 'Diverter ballast', x, 433, up: 366),
    ],
    sensors: [
      _catch('cap', 'Bypass caught', x - 105, 298, ['cap']),
      _weight(
        'diverter',
        'Diverter held',
        x,
        units: 3,
        requires: ['cap'],
        props: ['diverter'],
      ),
      _Sensor(
        'drained',
        'Impeller exposed',
        _Sense.basin,
        _area(x + 151, 402),
        threshold: .22,
        requires: ['diverter'],
      ),
    ],
    goals: const [
      ['cap', 'diverter', 'drained'],
    ],
    basin: _Basin(Rect.fromLTWH(x + 73, 324, 194, 130), const [
      'diverter',
    ], hot: true),
    reserve: const Rect.fromLTWH(108, 356, 224, 98),
    traps: [
      _Trap(
        Rect.fromLTWH(x + 34, 406, 195, 48),
        kind: _Threat.flush,
        duration: .82,
        delay: 2.15,
        alternate: second ? Rect.fromLTWH(x - 161, 412, 183, 42) : null,
        off: 'drained',
      ),
    ],
    boss: 'Sump Custodian',
    weak: Offset(x + 135, 391),
    checkpoint: !second,
  );
}

_Room _cartographer(bool second) {
  final x = second ? 638.0 : 492.0;
  return _Room(
    second ? 'Return circuit' : 'Pulse circuit',
    'TAKE the upper vane to send a pulse over the shield. GIVE the return vane to drive the pulse down.',
    props: [
      _metal('up', 'Upper vane', x - 166, 433, up: 325),
      _metal('down', 'Return vane', x + 112, 433, up: 344),
      _Prop(
        'pulse',
        'Pulse carriage',
        Offset(x, 366),
        material: _Material.metal,
        rail: _rail(x, 225, 440),
        hanging: true,
        releaseOn: const ['up'],
        size: const Size(31, 31),
      ),
    ],
    sensors: [
      _catch('up', 'Upper lane raised', x - 166, 327, ['up']),
      _weight(
        'down',
        'Return lane lowered',
        x + 112,
        props: ['down'],
        requires: ['up'],
      ),
      _strike(
        'hit',
        'Receiver fin',
        x,
        435,
        ['pulse'],
        requires: ['up', 'down'],
      ),
    ],
    goals: const [
      ['up', 'down', 'hit'],
    ],
    fields: [
      _Field(
        Rect.fromLTWH(x - 42, 223, 84, 181),
        const Offset(0, -2040),
        off: 'down',
      ),
    ],
    traps: [
      _Trap(
        Rect.fromLTWH(x - 129, 386, 264, 32),
        kind: _Threat.beam,
        alternate: second ? Rect.fromLTWH(x - 264, 346, 192, 33) : null,
      ),
    ],
    boss: 'Field Cartographer',
    weak: Offset(x, 427),
    checkpoint: !second,
  );
}

_Room _auditorFuse() => _Room(
  'Auditor · fuse',
  'GIVE the lower relay into its saddle and TAKE the shutter weight to expose the fuse.',
  props: [
    _metal('relay', 'Lower relay', 419, 433, up: 303),
    _metal('shutter', 'Captive shutter', 585, 433, up: 300),
    const _Prop(
      'pulse',
      'Slow pulse',
      Offset(710, 420),
      material: _Material.pulse,
      size: Size(26, 26),
      velocity: Offset(-184, 0),
      rail: Rect.fromLTRB(643, 414, 770, 434),
      hanging: true,
      releaseOn: ['relay', 'shutter'],
    ),
  ],
  sensors: [
    _weight('relay', 'Relay seated', 419, props: ['relay']),
    _catch('shutter', 'Fuse uncovered', 585, 305, ['shutter']),
    _catch(
      'pulse',
      'Fuse blown',
      664,
      420,
      ['pulse'],
      width: 51,
      capture: false,
      requires: ['relay', 'shutter'],
    ),
  ],
  goals: const [
    ['relay', 'shutter', 'pulse'],
  ],
  traps: const [
    _Trap(
      Rect.fromLTWH(480, 394, 263, 25),
      kind: _Threat.beam,
      alternate: Rect.fromLTWH(326, 364, 242, 26),
      period: 4.8,
    ),
  ],
  boss: 'The Auditor',
  weak: const Offset(668, 419),
);

_Room _auditorCutoff() => _Room(
  'Auditor · cutoff',
  'Seat a scaffold brake with GIVE and reach the upper socket with TAKE. Either approach works.',
  floors: const [_deck, Rect.fromLTWH(722, 372, 92, 13)],
  props: [
    _ballast('ballast', 'Scaffold ballast', 354, 433, up: 366),
    _metal('direct', 'Scaffold carriage', 487, 433, up: 276),
    _metal('bypass', 'Bypass carriage', 669, 433, up: 272),
    _metal('shoe', 'Bypass brake shoe', 773, 351, up: 284),
  ],
  sensors: [
    _weight('ballast', 'Scaffold seated', 354, units: 3, props: ['ballast']),
    _catch(
      'direct',
      'Scaffold cutoff',
      487,
      284,
      ['direct'],
      capture: false,
      requires: ['ballast'],
    ),
    _catch('bypass', 'Roof carriage caught', 669, 283, ['bypass']),
    _weight(
      'shoe',
      'Bypass cutoff',
      773,
      y: 372,
      props: ['shoe'],
      requires: ['bypass'],
    ),
  ],
  goals: const [
    ['ballast', 'direct'],
    ['bypass', 'shoe'],
  ],
  lift: const _Lift(Rect.fromLTWH(571, 448, 91, 14), Offset(0, -74), [
    'ballast',
  ]),
  traps: const [
    _Trap(
      Rect.fromLTWH(388, 390, 171, 36),
      kind: _Threat.sweep,
      alternate: Rect.fromLTWH(572, 380, 143, 40),
      period: 4.6,
    ),
  ],
  fields: const [_Field(Rect.fromLTWH(574, 276, 83, 138), Offset(57, -1050))],
  boss: 'The Auditor',
  weak: const Offset(487, 278),
);

final _contracts = <_Chapter>[
  _Chapter(
    'High freight',
    'Contract 1',
    _DueLandscape.grove,
    'Remix · climb and transfer exposed freight.',
    'All freight accounted for.',
    [_chapters[0].rooms[1], _chapters[1].rooms[1], _bailiff(true)],
    175,
    rule: _ContractRule.quickSweeps,
  ),
  _Chapter(
    'Cooling shift',
    'Contract 2',
    _DueLandscape.canyon,
    'Remix · work through cover and a live sump.',
    'The pumps are stable.',
    [_chapters[2].rooms[1], _chapters[3].rooms[2], _custodian(true)],
    190,
    rule: _ContractRule.fastCoolant,
  ),
  _Chapter(
    'Night circuit',
    'Contract 3',
    _DueLandscape.ridge,
    'Remix · route a pulse under alternating pressure.',
    'The relay has cleared.',
    [_chapters[4].rooms[2], _chapters[5].rooms[1], _cartographer(true)],
    205,
    rule: _ContractRule.strongCurrent,
  ),
];
