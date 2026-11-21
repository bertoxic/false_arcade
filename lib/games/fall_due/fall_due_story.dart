part of 'fall_due_game.dart';

enum _Gravity { normal, give, take }

enum _Material {
  freight,
  ballast,
  brittle,
  metal,
  float,
  guard,
  heavy,
  drone,
  pulse,
}

enum _Sense { load, catchBody, impact, visit, dock, basin, optical }

enum _Threat { spikes, beam, sweep, flush }

enum _ContractRule {
  standard(''),
  quickSweeps('Shorter sweep recovery'),
  fastCoolant('Faster coolant transfer'),
  strongCurrent('Stronger currents');

  const _ContractRule(this.label);
  final String label;
}

extension on _Material {
  bool get enemy =>
      this == _Material.guard ||
      this == _Material.heavy ||
      this == _Material.drone;
  bool get massive => this == _Material.ballast || this == _Material.heavy;
}

class _Prop {
  const _Prop(
    this.id,
    this.label,
    this.at, {
    this.material = _Material.freight,
    this.size = const Size(42, 42),
    this.rail,
    this.hanging = false,
    this.recall = true,
    this.velocity = Offset.zero,
    this.releaseOn = const [],
  });
  final String id, label;
  final Offset at, velocity;
  final _Material material;
  final Size size;
  final Rect? rail;
  final bool hanging, recall;
  final List<String> releaseOn;
}

class _Body {
  _Body(this.spec)
    : at = spec.at,
      previous = spec.at,
      velocity = spec.velocity,
      hanging = spec.hanging;
  final _Prop spec;
  Offset at, previous, velocity;
  Offset impact = Offset.zero;
  bool hanging, supported = false, caught = false, lost = false;
  double timer = 0, brace = 0, startRise = 0, recover = 0, patrol = 1;
  _Gravity gravity = _Gravity.normal;

  Rect get box => Rect.fromCenter(
    center: at,
    width: spec.size.width,
    height: spec.size.height,
  );
  double get load =>
      (spec.material.massive ? 2.0 : 1.0) *
      switch (gravity) {
        _Gravity.give => 2.4,
        _Gravity.take => 0,
        _Gravity.normal => 1,
      };
}

class _Sensor {
  const _Sensor(
    this.id,
    this.label,
    this.kind,
    this.area, {
    this.props = const [],
    this.threshold = 1,
    this.speed = 225,
    this.requires = const [],
    this.latch = true,
    this.capture = false,
    this.balance,
  });
  final String id, label;
  final _Sense kind;
  final Rect area;
  final List<String> props, requires;
  final double threshold, speed;
  final bool latch, capture;
  final Rect? balance;
}

class _Trap {
  const _Trap(
    this.area, {
    this.kind = _Threat.spikes,
    this.warning = 1,
    this.duration = .75,
    this.period = 5.7,
    this.delay = 1.6,
    this.off,
    this.alternate,
    this.shield = false,
    this.travel = Offset.zero,
  });
  final Rect area;
  final _Threat kind;
  final double warning, duration, period, delay;
  final String? off;
  final Rect? alternate;
  final bool shield;
  final Offset travel;
}

class _Field {
  const _Field(this.area, this.force, {this.vane, this.off});
  final Rect area;
  final Offset force;
  final String? vane, off;
}

class _Lift {
  const _Lift(this.base, this.travel, this.channels, {this.speed = 150});
  final Rect base;
  final Offset travel;
  final List<String> channels;
  final double speed;
}

class _Basin {
  const _Basin(
    this.area,
    this.channels, {
    this.initial = .82,
    this.end = .15,
    this.hot = false,
  });
  final Rect area;
  final List<String> channels;
  final double initial, end;
  final bool hot;
}

class _Barrier {
  const _Barrier(this.area, this.channels);
  final Rect area;
  final List<String> channels;
}

class _Optic {
  const _Optic(this.mirror, this.source, this.stopX, this.receiver);
  final String mirror;
  final Offset source, receiver;
  final double stopX;
}

class _Room {
  const _Room(
    this.title,
    this.hint, {
    this.spawn = const Offset(72, 431),
    this.exit = const Rect.fromLTWH(888, 350, 54, 104),
    this.floors = const [Rect.fromLTWH(0, 454, 960, 86)],
    this.service = const [],
    this.crumbling = const [],
    this.props = const [],
    this.sensors = const [],
    this.goals = const [],
    this.traps = const [],
    this.fields = const [],
    this.barriers = const [],
    this.lift,
    this.basin,
    this.reserve,
    this.optic,
    this.secret,
    this.boss,
    this.weak,
    this.checkpoint = true,
  });
  final String title, hint;
  final Offset spawn;
  final Rect exit;
  final List<Rect> floors, service, crumbling;
  final List<_Prop> props;
  final List<_Sensor> sensors;
  final List<List<String>> goals;
  final List<_Trap> traps;
  final List<_Field> fields;
  final List<_Barrier> barriers;
  final _Lift? lift;
  final _Basin? basin;
  final _Optic? optic;
  final Rect? reserve;
  final Offset? secret;
  final String? boss;
  final Offset? weak;
  final bool checkpoint;
}

class _Chapter {
  const _Chapter(
    this.title,
    this.act,
    this.landscape,
    this.summary,
    this.archive,
    this.rooms,
    this.par, {
    this.rule = _ContractRule.standard,
  });
  final String title, act, summary, archive;
  final _DueLandscape landscape;
  final List<_Room> rooms;
  final double par;
  final _ContractRule rule;

  String get mastery => switch (title) {
    'First Instalment' =>
      'Recover the dispatch and use an upper or return route.',
    'Transfer Bridge' =>
      'Return the service weight and recover the workers’ map.',
    'Collection Day' => 'Use the environment to disable two enemies.',
    'Debt Dive' => 'Clear the refinery without a recovery.',
    'Compound Interest' =>
      'Use the courier return mouth and find the telescope archive.',
    'Final Audit' =>
      'Recover the transfer orders and carry them out of the Tower.',
    _ => 'Clear within par without a recovery.',
  };

  bool mastered(_StoryRun run) => switch (title) {
    'First Instalment' =>
      run.found.isNotEmpty &&
          run.routes.values.any(
            (route) => const {
              'Upper paddle',
              'Balcony return',
              'High crossing',
            }.contains(route),
          ),
    'Transfer Bridge' =>
      run.found.isNotEmpty &&
          run.routes.values.contains('Service weight returned'),
    'Collection Day' => run.defeated.length >= 2,
    'Debt Dive' => run.hits == 0,
    'Compound Interest' =>
      run.found.isNotEmpty && run.routes.values.contains('Return mouth'),
    'Final Audit' => run.found.isNotEmpty,
    _ => run.hits == 0 && !run.assistedRun && run.elapsed <= par,
  };
}

class _StoryRun {
  _StoryRun(
    this.rooms, {
    this.ledger = false,
    this.longTells = false,
    this.rule = _ContractRule.standard,
  }) {
    load(0);
  }
  static const maxHearts = 3;
  static const playerSize = Size(29, 46);
  static const range = FallDueTuning.interactionRange;
  final List<_Room> rooms;
  final bool ledger;
  final _ContractRule rule;
  bool longTells;
  int index = 0, checkpoint = 0, hearts = maxHearts, hits = 0, charge = 1;
  double elapsed = 0,
      clock = 0,
      grace = 0,
      cooldown = 0,
      noticeTime = 0,
      arcTime = 0;
  double coyote = 0,
      buffer = 0,
      selfLift = 0,
      stable = 0,
      fill = 0,
      liftProgress = 0,
      facing = 1;
  bool left = false,
      right = false,
      jumpHeld = false,
      self = false,
      overdrive = false;
  bool usedLift = false,
      usedSlam = false,
      grounded = false,
      finished = false,
      opened = false,
      started = false;
  bool assistedRun = false;
  Offset player = Offset.zero, velocity = Offset.zero, safe = Offset.zero;
  Offset? arcTarget;
  _Gravity arcGravity = _Gravity.normal;
  String notice = '';
  String? selection, assisted, route;
  final gained = <String>{};
  final routes = <int, String>{};
  final found = <int>{};
  final defeated = <String>{};
  final signals = <String>{};
  final holds = <String, double>{};
  final broken = <Rect>{};
  final shelfStress = <Rect, double>{};
  final shelfRecovery = <Rect, double>{};
  final openBarriers = <_Barrier>{};
  final bodies = <String, _Body>{};

  _Room get room => rooms[index];
  Rect? embeddedPlayerBox;
  List<_Body> externalCargo = const [];
  Rect get playerBox =>
      embeddedPlayerBox ??
      Rect.fromCenter(
        center: player,
        width: playerSize.width,
        height: playerSize.height,
      );
  Rect? get lift => room.lift?.base.shift(room.lift!.travel * liftProgress);

  ({Offset corner, Offset? redirected, bool powered})? get opticTrace {
    final optic = room.optic;
    if (optic == null) return null;
    final mirror = bodies[optic.mirror];
    final aligned =
        mirror != null &&
        !mirror.lost &&
        (mirror.at.dy - optic.source.dy).abs() <= 4;
    final hitX = aligned ? mirror.at.dx : optic.stopX;
    final obstructions = [
      ...solids,
      for (final body in [...bodies.values, ...externalCargo])
        if (!body.lost &&
            body != mirror &&
            (body.spec.material == _Material.metal ||
                body.spec.material.massive))
          body.box,
    ];
    var stopX = hitX;
    for (final wall in obstructions) {
      if (wall.right > optic.source.dx &&
          wall.left < stopX &&
          optic.source.dy > wall.top &&
          optic.source.dy < wall.bottom) {
        stopX = math.max(optic.source.dx, wall.left);
      }
    }
    final corner = Offset(stopX, optic.source.dy);
    if (!aligned || stopX < hitX) {
      return (corner: corner, redirected: null, powered: false);
    }
    var stopY = optic.receiver.dy;
    for (final wall in obstructions) {
      if (wall.top < corner.dy &&
          wall.bottom > stopY &&
          corner.dx > wall.left &&
          corner.dx < wall.right) {
        stopY = math.min(corner.dy, wall.bottom);
      }
    }
    final redirected = Offset(corner.dx, stopY);
    return (
      corner: corner,
      redirected: redirected,
      powered: (redirected - optic.receiver).distanceSquared < 1,
    );
  }

  Rect? get water {
    final area = room.basin?.area;
    return area == null
        ? null
        : Rect.fromLTRB(
            area.left,
            area.bottom - fill * area.height,
            area.right,
            area.bottom,
          );
  }

  Rect? get reserveWater {
    final reserve = room.reserve;
    final main = room.basin;
    if (reserve == null || main == null) return null;
    final capacity = reserve.width * reserve.height;
    final volumePerFill = main.area.width * main.area.height;
    final transfer = (main.end - main.initial) * volumePerFill;
    final start = transfer > 0
        ? transfer + (capacity - transfer) * .3
        : (capacity + transfer) * .4;
    final volume = start + (main.initial - fill) * volumePerFill;
    final depth = (volume / reserve.width).clamp(0.0, reserve.height);
    return Rect.fromLTRB(
      reserve.left,
      reserve.bottom - depth,
      reserve.right,
      reserve.bottom,
    );
  }

  Iterable<Rect> get solids sync* {
    yield* room.floors.where((floor) => !broken.contains(floor));
    for (final barrier in room.barriers) {
      if (!openBarriers.contains(barrier)) yield barrier.area;
    }
    if (lift case final surface?) yield surface;
  }

  void load(int next) {
    index = next;
    if (room.checkpoint) {
      checkpoint = index;
      hearts = maxHearts;
    }
    clock = grace = cooldown = arcTime = coyote = buffer = selfLift = stable =
        liftProgress = 0;
    fill = room.basin?.initial ?? 0;
    selection = assisted = route = null;
    signals.clear();
    holds.clear();
    broken.clear();
    shelfStress.clear();
    shelfRecovery.clear();
    openBarriers.clear();
    bodies
      ..clear()
      ..addEntries(room.props.map((prop) => MapEntry(prop.id, _Body(prop))));
    velocity = Offset.zero;
    player = safe = room.spawn;
    embeddedPlayerBox = null;
    externalCargo = const [];
    usedLift = usedSlam = grounded = self = overdrive = false;
    opened = room.goals.isEmpty;
    say(room.hint, 0);
    clearInput();
  }

  void clearInput() {
    left = right = jumpHeld = false;
    buffer = 0;
  }

  void reset({bool manual = true}) {
    if (finished) return;
    hearts = maxHearts;
    if (manual) hits++;
    load(checkpoint);
    say('Checkpoint restored');
  }

  void jump(bool held) {
    if (held && !jumpHeld) buffer = .14;
    if (!held &&
        jumpHeld &&
        selfLift == 0 &&
        velocity.dy < -FallDueTuning.jumpCutVelocity) {
      velocity = Offset(velocity.dx, -FallDueTuning.jumpCutVelocity);
    }
    jumpHeld = held;
  }

  void say(String text, [double seconds = 2.4]) {
    notice = text;
    noticeTime = seconds;
  }

  void hit() {
    hits++;
    hearts--;
    GameFeedback.mediumImpact();
    if (hearts == 0) {
      reset(manual: false);
      return;
    }
    grace = 1.1;
    player = safe;
    velocity = Offset.zero;
    coyote = buffer = selfLift = 0;
    say('Returned to safe ground');
  }

  bool visible(_Body body) =>
      !solids.any((solid) => _segmentHits(player, body.at, solid.deflate(1)));
  bool inRange(_Body body) =>
      (body.at - player).distanceSquared <= range * range;
  bool valid(_Body body) =>
      !body.lost && !body.caught && inRange(body) && visible(body);
  _Body? get target => bodies[selection ?? assisted];

  void _assist() {
    if (selection != null || self) return;
    _Body? best;
    var score = double.infinity;
    for (final body in bodies.values) {
      if (!valid(body)) continue;
      final behind = (body.at.dx - player.dx) * facing < -18;
      final cost =
          (body.at - player).distance +
          (behind ? 44 : 0) -
          (assisted == body.spec.id ? 24 : 0);
      if (cost < score) {
        score = cost;
        best = body;
      }
    }
    assisted = best?.spec.id;
  }

  void point(Offset at) {
    final options =
        bodies.values
            .where(
              (body) =>
                  !body.lost &&
                  !body.caught &&
                  body.box.inflate(17).contains(at),
            )
            .toList()
          ..sort(
            (a, b) => (a.at - at).distanceSquared.compareTo(
              (b.at - at).distanceSquared,
            ),
          );
    selection = options.firstOrNull?.spec.id;
    self = false;
    _assist();
  }

  void cycle() {
    self = false;
    final options = bodies.values
        .where(valid)
        .map((body) => body.spec.id)
        .toList();
    selection = options.isEmpty
        ? null
        : options[(options.indexOf(selection ?? assisted ?? '') + 1) %
              options.length];
  }

  bool cast(_Gravity verb) {
    if (!started || finished || cooldown > 0) return false;
    if (self) {
      if (grounded || (verb == _Gravity.take ? usedLift : usedSlam)) {
        say('Self casts recover on stable ground');
        return false;
      }
      if (verb == _Gravity.take) {
        usedLift = true;
        selfLift = .4;
        velocity = Offset(velocity.dx, math.min(-210, velocity.dy));
      } else {
        usedSlam = true;
        selfLift = 0;
        velocity = Offset(velocity.dx, math.max(820, velocity.dy));
      }
      _pulse(player, verb);
      return true;
    }
    _assist();
    final body = target;
    if (body == null || body.lost || body.caught) {
      say('Select a marked target');
      return false;
    }
    if (!inRange(body)) {
      say('Target out of range');
      return false;
    }
    if (!visible(body)) {
      say('Target behind cover');
      return false;
    }
    if (body.gravity == verb && body.timer > 0) return false;
    final type = body.spec.material;
    if (verb == _Gravity.take && type.enemy && body.brace > 0) {
      say('Enemy braced');
      return false;
    }
    final reclaimed = body.gravity == _Gravity.give;
    body.gravity = verb;
    body.hanging = false;
    if (verb == _Gravity.give) {
      final boost = ledger && overdrive && charge > 0;
      if (boost) charge--;
      overdrive = false;
      body.timer = type.enemy ? 1.8 : (boost ? 3.2 : 2.4);
      if (type == _Material.drone || type == _Material.pulse) {
        body.velocity = Offset(body.velocity.dx * .25, 290);
      }
    } else if (type.enemy || type == _Material.pulse) {
      final delta = body.at.dx - player.dx;
      body.velocity = Offset(
        (delta.abs() < 1 ? facing : delta.sign) * (type.massive ? 145 : 315),
        -95,
      );
      body.timer = .48;
      body.brace = 1.68;
    } else {
      body.timer = type.massive ? 1 : 1.35;
      body.startRise = body.at.dy;
      body.velocity = Offset(body.velocity.dx, type.massive ? -85 : -145);
      if (ledger && !reclaimed && gained.add('$index/${body.spec.id}')) {
        charge = math.min(3, charge + 1);
      }
    }
    _pulse(body.at, verb);
    return true;
  }

  void _pulse(Offset at, _Gravity verb) {
    cooldown = .35;
    arcTarget = at;
    arcGravity = verb;
    arcTime = .23;
    if (verb == _Gravity.give) {
      GameFeedback.mediumImpact();
    } else {
      GameFeedback.selection();
    }
  }

  void step(double dt) {
    if (!started || finished) return;
    elapsed += dt;
    clock += dt;
    cooldown = math.max(0, cooldown - dt);
    grace = math.max(0, grace - dt);
    noticeTime = math.max(0, noticeTime - dt);
    arcTime = math.max(0, arcTime - dt);
    _machinery(dt);
    for (final body in bodies.values.toList()) {
      _stepBody(body, dt);
    }
    _stepPlayer(dt);
    final unlocked = _updateMechanisms(dt);
    _assist();
    if (unlocked) {
      say(
        room.boss == null
            ? '$route · Exit open'
            : 'Weak point disabled · Exit open',
      );
      GameFeedback.selection();
    }
    final secret = room.secret;
    if (secret != null && (secret - player).distance < 28 && found.add(index)) {
      GameFeedback.selection();
      say('Archive recovered');
    }
    if (opened && playerBox.overlaps(room.exit)) {
      if (route case final solved?) routes[index] = solved;
      if (index + 1 == rooms.length) {
        finished = true;
        clearInput();
      } else {
        load(index + 1);
      }
      return;
    }
    if (player.dy > 580) {
      if (grace == 0) {
        hit();
      } else {
        player = safe;
        velocity = Offset.zero;
      }
      return;
    }
    if (grace == 0 && _dangerAt(playerBox)) hit();
  }

  bool _updateMechanisms(double dt) {
    _readSensors(dt);
    _stepSurfaces(dt);
    _environmentalCombat();
    for (final barrier in room.barriers) {
      if (barrier.channels.any(signals.contains)) {
        openBarriers.add(barrier);
      } else if (!playerBox.overlaps(barrier.area) &&
          !bodies.values.any(
            (body) => !body.lost && body.box.overlaps(barrier.area),
          )) {
        openBarriers.remove(barrier);
      }
    }
    if (opened) return false;
    final solution = room.goals
        .where((branch) => branch.every(signals.contains))
        .firstOrNull;
    if (solution == null) return false;
    opened = true;
    final last = solution.last;
    final key = room.goals.where((branch) => branch.last == last).length > 1
        ? solution.first
        : last;
    route = room.sensors.firstWhere((sensor) => sensor.id == key).label;
    return true;
  }

  bool _dangerAt(Rect bounds) {
    if (opened) return false;
    final box = bounds.deflate(4);
    final wet = water;
    return room.basin?.hot == true && wet != null && box.overlaps(wet) ||
        room.traps.any(
          (trap) => phase(trap) == 2 && box.overlaps(trapArea(trap)),
        ) ||
        bodies.values.any(
          (body) =>
              !body.lost &&
              body.spec.material.enemy &&
              body.gravity == _Gravity.normal &&
              box.overlaps(body.box.deflate(5)),
        );
  }

  double _period(_Trap trap) =>
      trap.period +
      (longTells ? .55 : 0) -
      (rule == _ContractRule.quickSweeps && trap.kind == _Threat.sweep
          ? .65
          : 0);

  int phase(_Trap trap) {
    if (opened || signals.contains(trap.off) || clock < trap.delay) return 0;
    final assist = longTells ? .55 : 0;
    final tick = (clock - trap.delay) % _period(trap);
    final tell = trap.warning + assist;
    return tick < tell ? 1 : (tick < tell + trap.duration ? 2 : 0);
  }

  Rect trapArea(_Trap trap) {
    final assist = longTells ? .55 : 0;
    final period = _period(trap);
    final cycle = ((clock - trap.delay) / period).floor();
    var area = cycle.isOdd ? trap.alternate ?? trap.area : trap.area;
    if (trap.travel != Offset.zero) {
      final travel = cycle.isOdd ? -trap.travel : trap.travel;
      if (phase(trap) == 1) {
        area = area.expandToInclude(area.shift(travel));
      } else {
        final timer = (clock - trap.delay) % period - trap.warning - assist;
        area = area.shift(travel * (timer / trap.duration).clamp(0.0, 1.0));
      }
    }
    if (trap.shield) {
      if (room.optic case final optic?
          when trap.kind == _Threat.beam &&
              (optic.source.dy - area.center.dy).abs() < 2) {
        final end = opticTrace!.corner.dx.clamp(area.left, area.right);
        return Rect.fromLTRB(area.left, area.top, end, area.bottom);
      }
      for (final body in [...bodies.values, ...externalCargo]) {
        if (!body.lost &&
            (body.spec.material == _Material.metal ||
                body.spec.material == _Material.heavy) &&
            area.overlaps(body.box)) {
          area = Rect.fromLTRB(
            area.left,
            area.top,
            math.max(area.left, body.box.left),
            area.bottom,
          );
        }
      }
    }
    return area;
  }

  void _environmentalCombat() {
    final enemies = bodies.values
        .where((body) => !body.lost && body.spec.material.enemy)
        .toList();
    if (enemies.isEmpty) return;
    final dangers = room.traps
        .where((trap) => phase(trap) == 2)
        .map(trapArea)
        .toList();
    final payloads = bodies.values.where(
      (body) =>
          !body.lost &&
          (body.gravity == _Gravity.give && body.impact.dy > 385 ||
              body.gravity == _Gravity.take &&
                  body.spec.material.enemy &&
                  body.impact.dx.abs() > 190),
    );
    for (final enemy in enemies) {
      final trapped =
          dangers.any((area) => area.overlaps(enemy.box)) && !enemy.spec.recall;
      final struck = payloads.any(
        (body) =>
            body != enemy &&
            body.box
                .expandToInclude(body.box.shift(body.previous - body.at))
                .overlaps(enemy.box.deflate(3)),
      );
      if (trapped || struck) {
        enemy.lost = true;
        enemy.recover = 1.5;
        if ((struck || enemy.gravity != _Gravity.normal) &&
            defeated.add('$index/${enemy.spec.id}')) {
          GameFeedback.mediumImpact();
          say('Environmental takedown');
        }
      }
    }
  }

  void _stepSurfaces(double dt) {
    for (final surface in room.crumbling) {
      if (broken.contains(surface)) {
        final remaining = math.max(0.0, (shelfRecovery[surface] ?? 0) - dt);
        shelfRecovery[surface] = remaining;
        if (remaining == 0 &&
            !playerBox.overlaps(surface) &&
            !bodies.values.any(
              (body) => !body.lost && body.box.overlaps(surface),
            )) {
          broken.remove(surface);
          shelfStress.remove(surface);
        }
        continue;
      }
      final load = bodies.values
          .where((body) => !body.lost && _feet(body.box, surface))
          .fold(
            _feet(playerBox, surface) ? 1.0 : 0.0,
            (sum, body) => sum + body.load,
          );
      final stress = shelfStress[surface] ?? 0;
      shelfStress[surface] = load > 0
          ? stress + dt * math.min(3, load)
          : math.max(0, stress - dt * 1.4);
      if (shelfStress[surface]! >= 1.2) {
        broken.add(surface);
        shelfRecovery[surface] = 3.5;
      }
    }
    for (final panel in room.service) {
      if (panel.height > 12 || broken.contains(panel)) continue;
      if (bodies.values.any(
        (body) =>
            body.gravity == _Gravity.give &&
            body.impact.dy > 460 &&
            body.box.inflate(3).overlaps(panel),
      )) {
        broken.add(panel);
      }
    }
  }

  Offset forceAt(Offset at) {
    var force = Offset.zero;
    for (final field in room.fields) {
      if (!field.area.contains(at) || signals.contains(field.off)) continue;
      final vane = bodies[field.vane];
      force += switch (vane?.gravity) {
        _Gravity.give => Offset(field.force.dx, field.force.dy.abs()),
        _Gravity.take => Offset(field.force.dx, -field.force.dy.abs()),
        _ => field.force,
      };
    }
    if (rule == _ContractRule.strongCurrent) force *= 1.18;
    return Offset(force.dx.clamp(-950, 950), force.dy.clamp(-2100, 2100));
  }

  void _machinery(double dt) {
    if (room.lift case final machine?) {
      final old = lift!;
      final goal = machine.channels.any(signals.contains) ? 1.0 : 0.0;
      liftProgress = _toward(
        liftProgress,
        goal,
        machine.speed * dt / math.max(1, machine.travel.distance),
      );
      final movement = lift!.topLeft - old.topLeft;
      if (_feet(playerBox, old)) player += movement;
      for (final body in bodies.values) {
        if (!body.lost && _feet(body.box, old)) body.at += movement;
      }
    }
    if (room.basin case final basin?) {
      fill = _toward(
        fill,
        basin.channels.any(signals.contains) ? basin.end : basin.initial,
        dt * (rule == _ContractRule.fastCoolant ? .72 : .52),
      );
    }
  }

  static bool _feet(Rect body, Rect on) =>
      (body.bottom - on.top).abs() < 2 &&
      body.right > on.left + 3 &&
      body.left < on.right - 3;

  void _stepBody(_Body body, double dt) {
    body.previous = body.at;
    body.impact = Offset.zero;
    if (body.lost) {
      body.recover -= dt;
      final cradle = Rect.fromCenter(
        center: body.spec.at,
        width: body.spec.size.width,
        height: body.spec.size.height,
      );
      if (body.spec.recall &&
          body.recover <= 0 &&
          !playerBox.overlaps(cradle) &&
          !bodies.values.any(
            (other) =>
                other != body && !other.lost && other.box.overlaps(cradle),
          )) {
        bodies[body.spec.id] = _Body(body.spec);
      }
      return;
    }
    if (body.caught) return;
    if (body.hanging) {
      if (body.spec.releaseOn.isEmpty ||
          !body.spec.releaseOn.every(signals.contains)) {
        return;
      }
      body.hanging = false;
    }
    body.brace = math.max(0, body.brace - dt);
    final type = body.spec.material;
    final rail = body.spec.rail;
    final taking =
        body.gravity == _Gravity.take && !type.enemy && type != _Material.pulse;
    final drone = type == _Material.drone && body.gravity == _Gravity.normal;
    var next = body.velocity + forceAt(body.at) * dt;
    var gravity =
        FallDueTuning.gravity * (body.gravity == _Gravity.give ? 2.4 : 1);
    if (taking) gravity = -440;
    if (drone || (type == _Material.pulse && body.gravity != _Gravity.give)) {
      gravity = 0;
    }
    if (body.spec.velocity.dx == 0) {
      next = Offset(next.dx * math.pow(body.supported ? .1 : .72, dt), next.dy);
    }
    if (type.enemy &&
        body.gravity != _Gravity.take &&
        rail != null &&
        rail.width > 0) {
      if (body.at.dx >= rail.right - 1) body.patrol = -1;
      if (body.at.dx <= rail.left + 1) body.patrol = 1;
      next = Offset(
        body.patrol *
            (type.massive ? 66 : 91) *
            (body.gravity == _Gravity.give ? .5 : 1),
        next.dy,
      );
    }
    if (drone) {
      next = Offset(next.dx, (body.spec.at.dy - body.at.dy).clamp(-180, 180));
    }
    final wet = [water, reserveWater].nonNulls
        .where(
          (pool) => body.box.right > pool.left && body.box.left < pool.right,
        )
        .firstOrNull;
    if (type == _Material.float &&
        body.gravity == _Gravity.normal &&
        wet != null &&
        body.box.right > wet.left &&
        body.box.left < wet.right &&
        body.box.bottom >= wet.top) {
      next = Offset(next.dx, ((wet.top - 5 - body.at.dy) * 7).clamp(-210, 210));
      gravity = 0;
    }
    next = Offset(
      next.dx.clamp(-575, 575),
      (next.dy + dt * gravity).clamp(
        taking ? (type.massive ? -120 : -260) : -950,
        1150,
      ),
    );
    body.impact = next;
    final blockers = bodies.values
        .where(
          (other) =>
              other != body &&
              !other.lost &&
              !other.spec.material.enemy &&
              other.spec.material != _Material.pulse,
        )
        .toList();
    if (type.enemy && body.gravity == _Gravity.take) {
      for (final other in blockers) {
        if (other.spec.rail != null ||
            other.caught ||
            !body.box.shift(next * dt).overlaps(other.box)) {
          continue;
        }
        other.velocity = Offset(next.dx * .85, other.velocity.dy);
      }
    }
    final result = _sweep(body.box, next * dt, [
      ...solids,
      ...blockers.map((other) => other.box),
      ...externalCargo.map((other) => other.box),
    ]);
    body.at = result.box.center;
    body.velocity = Offset(
      result.wall ? -next.dx * .20 : next.dx,
      result.floor || result.ceiling ? 0 : next.dy,
    );
    body.supported = result.floor;
    if (rail != null && !type.enemy) {
      final end = Offset(
        body.at.dx.clamp(rail.left, rail.right),
        body.at.dy.clamp(rail.top, rail.bottom),
      );
      body.supported |= body.at.dy > rail.bottom;
      body.velocity = Offset(
        end.dx == body.at.dx ? body.velocity.dx : 0,
        end.dy == body.at.dy ? body.velocity.dy : 0,
      );
      body.at = end;
    }
    if (taking) {
      final cap = body.startRise - (type.massive ? 85 : 190);
      if (body.at.dy <= cap) {
        body.at = Offset(body.at.dx, cap);
        body.velocity = Offset(body.velocity.dx, math.max(0, body.velocity.dy));
      }
    }
    if (type == _Material.brittle && !taking && result.floor && next.dy > 610 ||
        body.at.dy > 575 ||
        body.at.dx < -40 ||
        body.at.dx > 1000) {
      body.lost = true;
      body.recover = 1.5;
    }
    if (body.timer > 0) {
      body.timer -= dt;
      if (body.timer <= 0) body.gravity = _Gravity.normal;
    }
  }

  void _stepPlayer(double dt) {
    final supports = bodies.values
        .where((body) => !body.lost && _canStand(body))
        .toList();
    for (final body in supports) {
      if (_feet(playerBox, body.box.shift(body.previous - body.at))) {
        player += body.at - body.previous;
        break;
      }
    }
    final direction = (right ? 1.0 : 0.0) - (left ? 1.0 : 0.0);
    if (direction != 0) facing = direction;
    coyote = grounded ? .12 : math.max(0, coyote - dt);
    buffer = math.max(0, buffer - dt);
    selfLift = math.max(0, selfLift - dt);
    final force = forceAt(player);
    var vx = _toward(
      velocity.dx,
      direction * FallDueTuning.runSpeed,
      dt *
          (grounded
              ? FallDueTuning.groundAcceleration
              : FallDueTuning.airAcceleration),
    );
    vx = (vx + force.dx * dt).clamp(-380, 380);
    var vy =
        (velocity.dy +
                (force.dy + FallDueTuning.gravity * (selfLift > 0 ? .14 : 1)) *
                    dt)
            .clamp(-850.0, FallDueTuning.terminalVelocity);
    if (vx.abs() > 5) {
      final side = playerBox
          .shift(Offset(vx * dt + direction * 3, 0))
          .deflate(1);
      for (final body in supports) {
        if (body.spec.rail == null &&
            !body.caught &&
            !body.hanging &&
            side.overlaps(body.box)) {
          body.velocity = Offset(
            vx.sign *
                math.max(vx.abs() * .76, body.spec.material.massive ? 92 : 153),
            body.velocity.dy,
          );
        }
      }
    }
    if (buffer > 0 && coyote > 0) {
      vy = -FallDueTuning.jumpImpulse;
      coyote = buffer = 0;
      grounded = false;
      GameFeedback.jump();
    } else if (!grounded &&
        direction != 0 &&
        room.service.any(
          playerBox.shift(Offset(direction * 3, 0)).deflate(1).overlaps,
        )) {
      if (buffer > 0) {
        vx = -direction * 240;
        vy = -537;
        buffer = 0;
      } else {
        vy = math.min(vy, 180);
      }
    }
    final result = _sweep(playerBox, Offset(vx, vy) * dt, [
      ...solids,
      ...supports.map((body) => body.box),
    ]);
    player = Offset(result.box.center.dx.clamp(20, 940), result.box.center.dy);
    grounded = result.floor;
    velocity = Offset(
      result.wall ? 0 : vx,
      result.floor || result.ceiling ? 0 : vy,
    );
    final fixed =
        room.floors.any(
          (floor) => !broken.contains(floor) && _feet(playerBox, floor),
        ) ||
        liftProgress > .995 && lift != null && _feet(playerBox, lift!);
    stable = fixed && grounded ? stable + dt : 0;
    if (stable > .12) {
      usedLift = usedSlam = false;
      if (_safeAt(playerBox)) safe = player;
    }
    if (usedSlam && vy > 735) {
      for (final panel in room.service) {
        if (panel.height <= 12 && playerBox.inflate(3).overlaps(panel)) {
          broken.add(panel);
        }
      }
    }
  }

  bool _canStand(_Body body) =>
      body.spec.material != _Material.pulse &&
      (!body.spec.material.enemy ||
          body.spec.material == _Material.drone &&
              body.gravity == _Gravity.give);

  bool _safeAt(Rect box) =>
      !room.traps.any(
        (trap) =>
            trap.area.inflate(18).overlaps(box) ||
            (trap.alternate?.inflate(18).overlaps(box) ?? false),
      ) &&
      !(room.basin?.area.overlaps(box) ?? false) &&
      !bodies.values.any(
        (body) =>
            !body.lost &&
            body.spec.material.enemy &&
            body.box.inflate(85).overlaps(box),
      );

  void _readSensors(double dt) {
    for (final sensor in room.sensors) {
      if (sensor.latch && signals.contains(sensor.id)) continue;
      if (!sensor.requires.every(signals.contains)) {
        holds[sensor.id] = 0;
        signals.remove(sensor.id);
        continue;
      }
      final candidates =
          sensor.kind == _Sense.load &&
              sensor.props.isEmpty &&
              externalCargo.isNotEmpty
          ? [...bodies.values, ...externalCargo]
          : bodies.values;
      final choices = candidates.where(
        (body) =>
            !body.lost &&
            (sensor.props.isEmpty || sensor.props.contains(body.spec.id)),
      );
      final caught = switch (sensor.kind) {
        _Sense.catchBody =>
          choices.where((body) => sensor.area.contains(body.at)).firstOrNull,
        _Sense.optical =>
          opticTrace?.powered == true ? bodies[room.optic!.mirror] : null,
        _ => null,
      };
      final active = switch (sensor.kind) {
        _Sense.catchBody || _Sense.optical => caught != null,
        _Sense.impact => choices.any(
          (body) =>
              body.load >= sensor.threshold &&
              body.impact.distance >= sensor.speed &&
              sensor.area.overlaps(
                body.box.expandToInclude(
                  body.box.shift(body.previous - body.at),
                ),
              ),
        ),
        _Sense.visit => sensor.area.overlaps(playerBox),
        _Sense.dock => liftProgress >= .995,
        _Sense.basin => fill <= sensor.threshold,
        _Sense.load => _meetsLoad(sensor, choices),
      };
      if (!active) {
        holds[sensor.id] = signals.contains(sensor.id)
            ? math.max(0, (holds[sensor.id] ?? 0) - dt)
            : 0;
        if (holds[sensor.id] == 0) signals.remove(sensor.id);
        continue;
      }
      final hold = (holds[sensor.id] ?? 0) + dt;
      holds[sensor.id] = math.min(.3, hold);
      if (sensor.kind == _Sense.load && hold < .25) continue;
      signals.add(sensor.id);
      if (sensor.capture && caught != null) {
        if (sensor.kind == _Sense.optical) {
          caught.at = Offset(caught.at.dx, room.optic!.source.dy);
        }
        caught.caught = true;
        caught.velocity = Offset.zero;
        if (selection == caught.spec.id) selection = null;
      }
    }
  }

  bool _meetsLoad(_Sensor sensor, Iterable<_Body> choices) {
    final load = _loadAt(sensor.area, choices);
    final other = sensor.balance;
    if (other == null) return load >= sensor.threshold;
    return load > 0 &&
        (load -
                    _loadAt(other, [
                      ...bodies.values.where((body) => !body.lost),
                      ...externalCargo,
                    ]))
                .abs() <=
            sensor.threshold;
  }

  double _loadAt(Rect area, Iterable<_Body> list) {
    final props = list.where((body) => body.supported || body.caught).toList();
    final weighed = <_Body>{};
    double stack(_Body body) {
      if (!weighed.add(body)) return 0;
      return props
          .where((top) => _feet(top.box, body.box))
          .fold(body.load, (sum, top) => sum + stack(top));
    }

    return props
        .where(
          (body) =>
              body.at.dx >= area.left &&
              body.at.dx <= area.right &&
              (body.box.bottom - area.bottom).abs() < area.height + 3,
        )
        .fold(0.0, (sum, body) => sum + stack(body));
  }
}

double _toward(double value, double goal, double speed) => value < goal
    ? math.min(value + speed, goal)
    : math.max(value - speed, goal);

bool _segmentHits(Offset from, Offset to, Rect rect) {
  final delta = to - from;
  var entry = 0.0;
  var exit = 1.0;
  for (final (origin, slope, low, high) in [
    (from.dx, delta.dx, rect.left, rect.right),
    (from.dy, delta.dy, rect.top, rect.bottom),
  ]) {
    if (slope.abs() < .0001) {
      if (origin <= low || origin >= high) return false;
    } else {
      final a = (low - origin) / slope;
      final b = (high - origin) / slope;
      entry = math.max(entry, math.min(a, b));
      exit = math.min(exit, math.max(a, b));
      if (entry >= exit) return false;
    }
  }
  return entry < 1 && exit > 0;
}

({Rect box, bool wall, bool floor, bool ceiling}) _sweep(
  Rect box,
  Offset delta,
  Iterable<Rect> walls,
) {
  var dx = delta.dx;
  var dy = delta.dy;
  for (final wall in walls) {
    if (box.bottom <= wall.top + .01 || box.top >= wall.bottom - .01) continue;
    if (dx > 0 && box.right <= wall.left + .04) {
      dx = math.min(dx, math.max(0, wall.left - box.right));
    }
    if (dx < 0 && box.left >= wall.right - .04) {
      dx = math.max(dx, math.min(0, wall.right - box.left));
    }
  }
  box = box.shift(Offset(dx, 0));
  for (final wall in walls) {
    if (box.right <= wall.left + .01 || box.left >= wall.right - .01) continue;
    if (dy > 0 && box.bottom <= wall.top + .04) {
      dy = math.min(dy, math.max(0, wall.top - box.bottom));
    }
    if (dy < 0 && box.top >= wall.bottom - .04) {
      dy = math.max(dy, math.min(0, wall.bottom - box.top));
    }
  }
  return (
    box: box.shift(Offset(0, dy)),
    wall: (dx - delta.dx).abs() > .0001,
    floor: dy < delta.dy - .0001,
    ceiling: dy > delta.dy + .0001,
  );
}
