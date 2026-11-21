part of 'fall_due_game.dart';

/// An encounter in the scrolling world. Its mechanism data is also used by the
/// practice mode, but the campaign owns the player, camera, collisions and HUD.
class _DueWorkshop {
  _DueWorkshop(this.id, this.room, double x, {this.inline = false})
    : origin = Offset(x, -24),
      run = _StoryRun([room])..started = true {
    targets = [
      for (final prop in room.props) _DueWorkshopTarget(this, prop.id),
    ];
  }

  static const width = 960.0;
  final int id;
  final _Room room;
  final Offset origin;
  final _StoryRun run;
  final bool inline;
  late final List<_DueWorkshopTarget> targets;
  bool entered = false;
  bool cleared = false;
  bool archived = false;

  double get left => origin.dx;
  double get right => left + (inline ? 500 : width);
  Rect get view => Rect.fromLTRB(left, 0, right, 540);
  Rect get boundary => Rect.fromLTWH(right - 13, 210, 14, 230);
  Offset get checkpoint => origin + const Offset(49, 417);

  bool near(double x) => x >= left - 120 && x < right + 70;

  Iterable<Rect> get surfaces sync* {
    if (inline) {
      if (run.liftProgress >= .995) yield run.lift!.shift(origin);
      return;
    }
    for (final surface in run.solids) {
      yield surface.shift(origin);
    }
    if (!cleared) yield boundary;
  }

  Iterable<Rect> get cargo sync* {
    for (final body in run.bodies.values) {
      if (!body.lost && run._canStand(body)) yield body.box.shift(origin);
    }
  }

  void setPlayer(_DueBody player) {
    run.player = player.center - origin;
    run.embeddedPlayerBox = player.rect.shift(-origin);
    run.grounded = player.grounded;
    run.velocity = Offset(player.vx, player.vy);
  }

  void syncCargo(Iterable<_DueTarget> targets) {
    run.externalCargo = [
      for (final target in targets)
        if (target.alive && target.kind.isCrate && target.rect.overlaps(view))
          _Body(
              _Prop(
                'route freight',
                target.label,
                target.center - origin,
                material: _Material.metal,
                size: target.rect.size,
                recall: false,
              ),
            )
            ..supported = target.grounded || target.anchored
            ..gravity = target.debt >= FallDueTuning.anchorDebt
                ? _Gravity.give
                : target.debt < -1
                ? _Gravity.take
                : _Gravity.normal,
    ];
  }

  Offset advance(_DueBody player, double dt) {
    setPlayer(player);
    run.clock += dt;
    run.cooldown = math.max(0, run.cooldown - dt);
    final before = run.player;
    final localBox = player.rect.shift(-origin);
    final oldLift = run.lift;
    final riding = run.bodies.values
        .where(
          (body) =>
              !body.lost &&
              run._canStand(body) &&
              _StoryRun._feet(localBox, body.box),
        )
        .firstOrNull;
    final oldCargo = riding?.at;
    run._machinery(dt);
    final liftCarry = oldLift != null && _StoryRun._feet(localBox, oldLift)
        ? run.lift!.topLeft - oldLift.topLeft
        : Offset.zero;
    for (final body in run.bodies.values.toList()) {
      run._stepBody(body, dt);
    }
    run.player = before;
    var movement = liftCarry;
    if (riding != null && oldCargo != null && !riding.lost) {
      movement = riding.at - oldCargo;
    }
    if (movement == Offset.zero) return movement;
    return _sweep(
          localBox,
          movement,
          run.solids.where(
            (surface) =>
                surface != run.lift && !_StoryRun._feet(localBox, surface),
          ),
        ).box.center -
        localBox.center;
  }

  void pushCargo(_DueBody player, int direction) {
    if (direction == 0) return;
    final side = player.rect
        .shift(Offset(direction * 5, 0) - origin)
        .deflate(1);
    for (final body in run.bodies.values) {
      if (body.lost ||
          body.spec.rail != null ||
          body.caught ||
          body.hanging ||
          !run._canStand(body) ||
          !side.overlaps(body.box)) {
        continue;
      }
      body.velocity = Offset(
        direction * (body.spec.material.massive ? 92 : 153),
        body.velocity.dy,
      );
    }
  }

  void observe(_DueBody player, double dt) {
    setPlayer(player);
    run._updateMechanisms(dt);
  }

  bool danger(Rect box) => run._dangerAt(box.shift(-origin));

  _WorkshopSave save() => _WorkshopSave(
    cleared,
    archived,
    run.opened,
    run.route,
    Set.of(run.signals),
  );

  void restore(_WorkshopSave? snapshot) {
    entered = false;
    cleared = snapshot?.cleared ?? false;
    archived = snapshot?.archived ?? false;
    run.load(0);
    if (snapshot == null || !snapshot.opened) return;
    run.opened = true;
    run.route = snapshot.route;
    run.signals.addAll(snapshot.signals);
    for (final sensor in room.sensors.where(
      (sensor) => sensor.capture && run.signals.contains(sensor.id),
    )) {
      final body = run.bodies[sensor.props.firstOrNull];
      if (body != null) {
        body.at = sensor.kind == _Sense.optical
            ? Offset(body.spec.at.dx, room.optic!.source.dy)
            : sensor.area.center;
        body.caught = true;
      }
    }
    if (room.lift case final lift?
        when lift.channels.any(run.signals.contains)) {
      run.liftProgress = 1;
    }
    if (room.basin case final basin?
        when basin.channels.any(run.signals.contains)) {
      run.fill = basin.end;
    }
    run.openBarriers.addAll(
      room.barriers.where(
        (barrier) => barrier.channels.any(run.signals.contains),
      ),
    );
  }
}

class _WorkshopSave {
  const _WorkshopSave(
    this.cleared,
    this.archived,
    this.opened,
    this.route,
    this.signals,
  );
  final bool cleared, archived, opened;
  final String? route;
  final Set<String> signals;
}

class _DueWorkshopTarget implements _DueGravityTarget {
  const _DueWorkshopTarget(this.workshop, this.id);
  final _DueWorkshop workshop;
  final String id;
  _Body get body => workshop.run.bodies[id]!;
  @override
  bool get alive => !body.lost && !body.caught;
  @override
  Offset get center => body.at + workshop.origin;
  @override
  Rect get rect => body.box.shift(workshop.origin);
  @override
  String get label => body.spec.label;
}

class _RouteJoint {
  const _RouteJoint(this.x, this.rooms);
  final double x;
  final List<_Room> rooms;
  double get span => rooms.length * _DueWorkshop.width;
}

extension on _FallDueGame {
  _DueWorkshop _buildOpeningRelay() => _DueWorkshop(
    -1,
    _Room(
      'Freight reflector',
      'TAKE the silver reflector to raise the bridge across the first gap.',
      floors: const [Rect.fromLTWH(-40, 454, 400, 110)],
      optic: const _Optic('reflector', Offset(105, 301), 339, Offset(242, 169)),
      props: [
        _metal(
          'reflector',
          'Silver reflector',
          242,
          375,
          up: 301,
          hanging: true,
        ),
      ],
      sensors: const [
        _Sensor(
          'reflector',
          'Reflected beam',
          _Sense.optical,
          Rect.fromLTWH(231, 158, 22, 22),
          props: ['reflector'],
          capture: true,
        ),
      ],
      goals: const [
        ['reflector'],
      ],
      lift: const _Lift(Rect.fromLTWH(360, 508, 110, 12), Offset(0, -54), [
        'reflector',
      ], speed: 180),
    ),
    0,
    inline: true,
  );

  /// Split only clear stretches of the original ground. Existing hazards,
  /// sections and objectives move together with the original terrain.
  void _installWorkshops(_DueStage stage) {
    workshops.clear();
    _openingRelay = levelIndex == 0 ? _buildOpeningRelay() : null;
    _worldSections = stage.route?.sections ?? const [];
    _worldPuzzles = stage.allGravityPuzzles;
    if (levelIndex >= _chapters.length) return;
    final chapter = _chapters[levelIndex];
    final oldExit = exit;
    final obstacles = [
      ...platforms.where((rect) => (rect.top - 430).abs() > .5),
      ...spikes,
      ...targets.map((target) => target.rect),
      ...seals.map(
        (seal) => Rect.fromCircle(center: seal.position, radius: 16),
      ),
      ...gates.map((gate) => gate.rect),
      ...levers.map(
        (lever) => Rect.fromCircle(center: lever.position, radius: 17),
      ),
      ...emitters.map(
        (emitter) => Rect.fromCircle(center: emitter.position, radius: 18),
      ),
      ...weakPanels.map((panel) => panel.rect),
      ...safeDebtPads.map((pad) => pad.rect),
      ...spikeTraps.map((trap) => trap.rect),
      ...crumblingLedges.map((ledge) => ledge.rect),
      ...laserGates.map((laser) => laser.rect),
      ...weightPlates.map((plate) => plate.rect),
      ...gravityWells.map((well) => well.rect),
      ...vents.map((vent) => vent.rect),
    ];
    final candidates = <double>[];
    for (final floor in platforms.where(
      (rect) => (rect.top - 430).abs() < .5,
    )) {
      for (var x = floor.left + 62; x <= floor.right - 62; x += 18) {
        if (x < 310 ||
            x > oldExit.left - 82 ||
            obstacles.any(
              (obstacle) => x >= obstacle.left - 19 && x <= obstacle.right + 19,
            )) {
          continue;
        }
        candidates.add(x);
      }
    }

    double pick(double ideal, {required double after, required double before}) {
      final fits = candidates.where((x) => x >= after && x <= before).toList()
        ..sort((a, b) => (a - ideal).abs().compareTo((b - ideal).abs()));
      if (fits.isNotEmpty) return fits.first;
      // Authored route validation checks every fallback remains inside the route.
      return ideal.clamp(after, before);
    }

    final end = oldExit.left - 82;
    final first = pick(oldExit.left * .24, after: 310, before: end - 510);
    final second = pick(
      oldExit.left * .57,
      after: first + 240,
      before: end - 240,
    );
    final joints = [
      _RouteJoint(first, [chapter.rooms[1]]),
      _RouteJoint(second, [chapter.rooms[2]]),
    ];
    var inserted = 0.0;
    for (final joint in joints) {
      for (final room in joint.rooms) {
        workshops.add(_DueWorkshop(workshops.length, room, joint.x + inserted));
        inserted += _DueWorkshop.width;
      }
    }
    double worldX(double source) =>
        source +
        joints
            .where((joint) => source >= joint.x)
            .fold(0.0, (sum, joint) => sum + joint.span);
    Offset point(Offset source) => Offset(worldX(source.dx), source.dy);
    Rect box(Rect source) =>
        source.shift(Offset(worldX(source.center.dx) - source.center.dx, 0));
    void replace<T>(List<T> objects, T Function(T) map) {
      final next = objects.map(map).toList();
      objects
        ..clear()
        ..addAll(next);
    }

    final terrain = <Rect>[];
    for (final floor in platforms) {
      var start = floor.left;
      var shift = worldX(start) - start;
      for (final joint in joints.where(
        (joint) => joint.x > floor.left && joint.x < floor.right,
      )) {
        terrain.add(
          Rect.fromLTRB(
            start + shift,
            floor.top,
            joint.x + shift,
            floor.bottom,
          ),
        );
        start = joint.x;
        shift = worldX(start) - start;
      }
      terrain.add(
        Rect.fromLTRB(
          start + shift,
          floor.top,
          floor.right + shift,
          floor.bottom,
        ),
      );
    }
    platforms
      ..clear()
      ..addAll(terrain);
    replace(spikes, box);
    replace(targets, (target) {
      target.x = worldX(target.rect.center.dx) - target.w / 2;
      return target;
    });
    replace(seals, (seal) => _DueSeal(point(seal.position)));
    replace(
      emitters,
      (emitter) =>
          _DueEmitter(point(emitter.position), emitter.speed, emitter.interval),
    );
    replace(levers, (lever) => _DueLever(lever.id, point(lever.position)));
    replace(gates, (gate) => _DueGate(gate.id, box(gate.rect)));
    replace(weakPanels, (panel) => _DueWeakPanel(box(panel.rect)));
    replace(safeDebtPads, (pad) => _DueSafeDebtPad(box(pad.rect)));
    replace(crumblingLedges, (ledge) => _DueCrumblingLedge(box(ledge.rect)));
    replace(
      spikeTraps,
      (trap) => _DueSpikeTrap(box(trap.rect), cycleOffset: trap.cycleOffset),
    );
    replace(
      gravityWells,
      (well) => _DueGravityWell(
        point(well.center),
        radius: well.radius,
        rig: well.rig,
      ),
    );
    replace(
      laserGates,
      (laser) => _DueLaserGate(
        box(laser.rect),
        switchId: laser.switchId,
        cycleOffset: laser.cycleOffset,
      ),
    );
    replace(
      vents,
      (vent) => _DueKineticVent(
        box(vent.rect),
        isUpdraft: vent.isUpdraft,
        cycleOffset: vent.cycleOffset,
      ),
    );
    replace(
      conduits,
      (conduit) => _DueConduit(
        conduit.id,
        point(conduit.emitterPos),
        point(conduit.receptorPos),
        List.of(conduit.alignment),
      ),
    );
    replace(
      weightPlates,
      (plate) => _DueWeightPlate(plate.id, box(plate.rect)),
    );
    _activeExit = box(oldExit);
    _worldSections = [
      for (final section in _worldSections)
        _DueSectionSpec(
          worldX(section.start),
          section.title,
          section.instruction,
        ),
    ];
    _worldPuzzles = [
      for (final puzzle in _worldPuzzles)
        _GravityPuzzleSpec(
          id: puzzle.id,
          boxPosition: point(puzzle.boxPosition),
          leverPosition: point(puzzle.leverPosition),
          gate: box(puzzle.gate),
        ),
    ];
  }

  Iterable<_DueWorkshop> _workshopsAt(double x) sync* {
    if (_openingRelay case final opening? when opening.near(x)) yield opening;
    yield* workshops.where((room) => room.near(x));
  }

  _DueWorkshop? get currentWorkshop => workshops
      .where(
        (room) =>
            !room.cleared &&
            player.center.dx >= room.left &&
            player.center.dx < room.right,
      )
      .firstOrNull;

  void resetWorkshop() {
    final workshop = currentWorkshop;
    if (workshop == null) return;
    final foundArchive = workshop.archived;
    workshop.restore(null);
    workshop.archived = foundArchive;
    _selectedTarget = null;
    debt = _payback = 0;
    _resetPlayerAt(workshop.checkpoint);
    _spawnGrace = .85;
    camera = (player.center.dx - _FallDueGame.viewWidth * .58).clamp(
      0.0,
      _maxCamera,
    );
    message = 'ENCOUNTER RESET · ${workshop.room.hint}';
  }

  void _moveWorkshopWorld(double dt) {
    for (final workshop in _workshopsAt(player.center.dx)) {
      workshop.syncCargo(targets);
      final carry = workshop.advance(player, dt);
      player.x += carry.dx;
      player.y += carry.dy;
      final force = workshop.run.forceAt(player.center - workshop.origin);
      player.vx += force.dx * dt;
      player.vy += force.dy * dt;
      workshop.pushCargo(player, (right ? 1 : 0) - (left ? 1 : 0));
    }
  }

  void _updateWorkshops(double dt) {
    final active = _workshopsAt(player.center.dx).toList();
    for (final workshop in active) {
      if (player.center.dx < workshop.left) continue;
      if (!workshop.entered &&
          !workshop.cleared &&
          player.center.dx >= workshop.left + 72) {
        workshop.entered = true;
        message =
            '${workshop.room.title.toUpperCase()} · ${workshop.room.hint}';
      }
      final wasOpen = workshop.run.opened;
      workshop.syncCargo(targets);
      workshop.observe(player, dt);
      if (!wasOpen && workshop.run.opened) {
        message = workshop.inline
            ? 'BEAM REFLECTED · First bridge powered.'
            : workshop.room.boss == null
            ? '${workshop.run.route} · Route open.'
            : 'WEAK POINT DISABLED · Move through the open arch.';
        _burst(
          (workshop.room.optic?.receiver ?? workshop.room.exit.center) +
              workshop.origin,
          _dueMint,
          18,
        );
        GameFeedback.selection();
      }
      if (workshop.inline) continue;
      final secret = workshop.room.secret;
      if (!workshop.archived &&
          secret != null &&
          (player.center - secret - workshop.origin).distance < 25) {
        workshop.archived = true;
        score += 350;
        message = _chapters[levelIndex].archive;
        _burst(secret + workshop.origin, _dueBlue, 15);
      }
      final standing = player.rect.shift(-workshop.origin);
      if (!workshop.cleared &&
          workshop.run.opened &&
          standing.overlaps(workshop.room.exit)) {
        workshop.cleared = true;
        score += workshop.room.boss == null ? 450 : 800;
        if (_selectedTarget is _DueWorkshopTarget) _selectedTarget = null;
      }
      if (_spawnGrace <= 0 && !isInvulnerable && workshop.danger(player.rect)) {
        _die('The machinery caught you.', settleDebt: false);
        return;
      }
    }
  }

  bool _castWorkshop(_DueWorkshopTarget target, _Gravity verb) {
    final workshop = target.workshop;
    workshop.setPlayer(player);
    workshop.run.selection = target.id;
    workshop.run.self = false;
    if (!workshop.run.cast(verb)) {
      if (workshop.run.noticeTime > 0) message = workshop.run.notice;
      return false;
    }
    _transferCooldown.tryTrigger(.35);
    _burst(target.center, verb == _Gravity.give ? _dueGold : _dueBlue, 12);
    _showTransfer(target.center, taking: verb == _Gravity.take);
    message = verb == _Gravity.give
        ? 'GAVE GRAVITY · ${target.label}'
        : 'TOOK GRAVITY · ${target.label}';
    return true;
  }
}
