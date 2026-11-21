part of 'fall_due_game.dart';

@visibleForTesting
List<String> auditFallDueRoutes() {
  final errors = <String>[];
  void verify(
    int chapter,
    int room,
    List<(String, _Gravity, Offset, double)> steps, {
    String? route,
    void Function(_StoryRun, void Function(double))? traverse,
  }) {
    final location = _chapters[chapter].rooms[room];
    final run = _StoryRun([location])..started = true;
    void advance(double seconds) {
      for (var n = 0; n < (seconds * 120).ceil(); n++) {
        run.grace = 1;
        run.step(1 / 120);
      }
    }

    advance(.15);
    for (final (target, verb, player, ticks) in steps) {
      run.player = player;
      run.velocity = Offset.zero;
      run.grounded = false;
      run.selection = target;
      if (!run.cast(verb)) {
        errors.add(
          '${location.title} $target @$player → ${run.bodies[target]?.at}: ${run.notice}',
        );
        return;
      }
      advance(ticks);
    }
    traverse?.call(run, advance);
    if (!run.opened || (route != null && run.route != route)) {
      errors.add(
        '${location.title} expected ${route ?? 'any'}: ${run.route} ${run.signals} ${run.bodies.values.map((body) => '${body.spec.id}=${body.at}${body.supported ? '*' : ''}').join(' ')}',
      );
    }
    if (location.boss == null) return;
    for (final verb in [_Gravity.give, _Gravity.take]) {
      final solo = _StoryRun([location])..started = true;
      void tick(double seconds) {
        for (var n = 0; n < (seconds * 120).ceil(); n++) {
          solo.grace = 1;
          solo.step(1 / 120);
        }
      }

      tick(.15);
      for (final (target, step, player, seconds) in steps) {
        solo.player = player;
        solo.velocity = Offset.zero;
        solo.selection = target;
        if (step == verb) solo.cast(verb);
        tick(seconds);
      }
      if (solo.opened) {
        errors.add('${location.title} opened with ${verb.name} alone');
      }
    }
  }

  const g = _Gravity.give;
  const t = _Gravity.take;
  (String, _Gravity, Offset, double) arm(
    String id,
    _Gravity verb,
    double x, [
    double ticks = 1.4,
    double y = 431,
  ]) => (id, verb, Offset(x, y), ticks);
  verify(0, 0, [arm('load', g, 140, .4), arm('rise', t, 351)]);
  verify(0, 1, [arm('load', g, 255)], route: 'Floor plate');
  verify(0, 1, [arm('paddle', t, 420)], route: 'Upper paddle');
  verify(0, 1, [
    arm('chute', t, 590, .7, 331),
    arm('chute', g, 584, 1.4, 330),
  ], route: 'Balcony return');
  verify(0, 2, [arm('press', g, 285)], route: 'Pinned spike rack');
  verify(0, 2, [arm('hinge', g, 474, 1.4, 471)], route: 'Hinged crossing');
  verify(
    0,
    2,
    [arm('ride', t, 605, .94, 463)],
    route: 'High crossing',
    traverse: (run, advance) {
      run.right = true;
      run.jump(true);
      advance(.33);
      run.right = false;
      advance(.65);
    },
  );
  verify(0, 3, [arm('guard', t, 312), arm('head', g, 465)]);
  verify(0, 4, [arm('guard', t, 435), arm('head', g, 590)]);
  verify(1, 0, [arm('far', g, 335)]);
  verify(1, 0, [arm('near', t, 131)]);
  verify(1, 1, [arm('far', g, 450, 2.6)]);
  verify(1, 1, [arm('near', t, 175, 2.6)]);
  verify(1, 1, [arm('spare', t, 130, .6), arm('spare', g, 158, 2.8)]);
  verify(1, 2, [arm('left', g, 280)]);
  verify(1, 2, [arm('right', t, 472)]);
  verify(
    1,
    2,
    [],
    route: 'Distributed weight',
    traverse: (run, advance) {
      run.player = const Offset(557, 431);
      run.left = true;
      advance(1.3);
    },
  );
  verify(1, 3, [arm('cargo', t, 300, 2), arm('shoe', g, 536)]);
  verify(1, 4, [arm('cargo', t, 476, 2), arm('shoe', g, 658)]);
  verify(2, 0, [arm('shield', g, 235)]);
  verify(2, 0, [arm('mirror', t, 395)]);
  verify(2, 1, [arm('shield', g, 356, 1.4, 341)], route: 'Lowered cover');
  verify(2, 1, [arm('mirror', t, 455)], route: 'Redirected beam');
  verify(
    2,
    1,
    [],
    route: 'Service approach',
    traverse: (run, advance) {
      run.player = const Offset(653, 431);
      run.right = true;
      advance(.65);
    },
  );
  verify(2, 2, [arm('cargo', g, 475)], route: 'Cargo impact');
  verify(2, 2, [arm('slug', t, 550)], route: 'Service release');
  verify(2, 2, [arm('drone', g, 600)], route: 'Drone impact');
  verify(2, 3, [arm('boot', g, 481, .4), arm('slug', t, 352)]);
  verify(2, 4, [arm('boot', g, 555, .4), arm('slug', t, 478)]);
  verify(3, 0, [arm('plug', t, 250)]);
  verify(3, 1, [arm('ballast', g, 234)], route: 'Runoff diverted');
  verify(3, 1, [arm('plug', t, 405)], route: 'Lower drain');
  verify(3, 1, [arm('float', t, 577, 1.4, 315)], route: 'Supply cut off');
  verify(3, 2, [arm('pontoon', g, 370)], route: 'Moored pontoon');
  verify(3, 2, [arm('ride', t, 583)], route: 'Lift float docked');
  verify(3, 2, [arm('sluice', t, 221)], route: 'Side basin filled');
  verify(3, 3, [arm('cap', t, 205), arm('diverter', g, 392, 2.3)]);
  verify(3, 4, [arm('cap', t, 354), arm('diverter', g, 570, 2.3)]);
  verify(4, 0, [arm('vane', g, 220)]);
  verify(4, 0, [arm('vane', t, 220)]);
  verify(4, 1, [arm('courier', t, 328)], route: 'Upper mouth');
  verify(4, 1, [arm('heavy', g, 497)], route: 'Lower chute');
  verify(4, 1, [
    arm('free', t, 540, .78),
    arm('free', g, 578, 1.4),
  ], route: 'Return mouth');
  verify(4, 2, [arm('lift', t, 224)], route: 'Outbound drift');
  verify(4, 2, [arm('vane', g, 644)], route: 'Isolated field');
  verify(4, 2, [arm('collector', t, 472)], route: 'Brake struck');
  verify(4, 3, [arm('up', t, 223, 1.5), arm('down', g, 560, 2)]);
  verify(4, 4, [arm('up', t, 328, 1.5), arm('down', g, 646, 2)]);
  verify(5, 0, [arm('lower', g, 225)]);
  verify(5, 1, [
    arm('lower', t, 290, .72),
    arm('lower', g, 300),
  ], route: 'Ground circuit');
  verify(5, 1, [
    arm('upper', t, 460),
    arm('shoe', g, 617),
  ], route: 'Guide clamped');
  verify(5, 1, [
    arm('collector', t, 496, .6),
    arm('trolley', g, 620),
  ], route: 'Trolley circuit');
  verify(5, 2, [arm('breaker', g, 282)], route: 'Ground cutoff');
  verify(5, 2, [arm('governor', t, 565, 1.4, 330)], route: 'Roof governor');
  verify(
    5,
    2,
    [arm('pontoon', g, 602, 2.35, 335)],
    route: 'Manual cutoff',
    traverse: (run, advance) {
      run.player = Offset(735, run.bodies['step']!.box.top - 23);
      run.velocity = Offset.zero;
      advance(.1);
      run.right = true;
      run.jump(true);
      advance(.42);
      run.right = false;
      advance(.60);
    },
  );
  verify(5, 3, [arm('relay', g, 306, .5), arm('shutter', t, 479, 2)]);
  verify(5, 4, [
    arm('ballast', g, 238, .45),
    arm('direct', t, 390),
  ], route: 'Scaffold cutoff');
  verify(5, 4, [
    arm('bypass', t, 700),
    arm('shoe', g, 823, 1.4, 348),
  ], route: 'Bypass cutoff');
  final ledger = _StoryRun([_chapters.first.rooms.first], ledger: true)
    ..started = true
    ..charge = 0
    ..player = const Offset(130, 431)
    ..selection = 'load';
  if (!ledger.cast(g)) errors.add('An empty Ledger prevented a base GIVE');
  for (var i = 0; i < 50; i++) {
    ledger.step(1 / 120);
  }
  if (!ledger.cast(t) || ledger.charge != 0) {
    errors.add('TAKE failed or earned charge by reclaiming an active GIVE');
  }
  ledger.reset();
  if (ledger.hearts != 3 ||
      ledger.cooldown != 0 ||
      ledger.signals.isNotEmpty ||
      ledger.charge != 0) {
    errors.add('Checkpoint reset left stale room state');
  }
  return errors;
}

/// Checks the authored set pieces after insertion into the actual scrolling game.
@visibleForTesting
List<String> auditFallDueWorldIntegration() {
  final errors = <String>[];
  const give = _Gravity.give;
  const take = _Gravity.take;
  final traces = <List<List<(String, _Gravity, double)>>>[
    [
      [('load', give, 255)],
      [('press', give, 285)],
      [('guard', take, 312), ('head', give, 465)],
      [('guard', take, 435), ('head', give, 590)],
    ],
    [
      [('far', give, 450)],
      [('left', give, 280)],
      [('cargo', take, 300), ('shoe', give, 536)],
      [('cargo', take, 476), ('shoe', give, 658)],
    ],
    [
      [('mirror', take, 455)],
      [('cargo', give, 475)],
      [('boot', give, 481), ('slug', take, 352)],
      [('boot', give, 555), ('slug', take, 478)],
    ],
    [
      [('ballast', give, 234)],
      [('ride', take, 583)],
      [('cap', take, 205), ('diverter', give, 392)],
      [('cap', take, 354), ('diverter', give, 570)],
    ],
    [
      [('courier', take, 328)],
      [('lift', take, 224)],
      [('up', take, 223), ('down', give, 560)],
      [('up', take, 328), ('down', give, 646)],
    ],
    [
      [('upper', take, 460), ('shoe', give, 617)],
      [('breaker', give, 282)],
      [('relay', give, 306), ('shutter', take, 479)],
      [('ballast', give, 238), ('direct', take, 390)],
    ],
  ];

  for (var stage = 0; stage < traces.length; stage++) {
    final blueprint = GameLevelGenerator.generate('fall_due', stage + 1);
    final game = _FallDueGame(campaignLevel: stage + 1, campaign: blueprint)
      ..start();
    if (game.workshops.length != 2 ||
        game.seals.length < game.level.allSeals.length ||
        game.exit.left <= game.level.finalExit.left + 2650) {
      errors.add(
        '${game.level.title} lost original geometry, seals, or encounter slots',
      );
      continue;
    }
    final staticWorld = [
      ...game.platforms,
      ...game.workshops.expand((room) => room.surfaces),
    ];
    for (final workshop in game.workshops) {
      final name = '${game.level.title} / ${workshop.room.title}';
      if (!staticWorld.any(
            (floor) => floor.contains(Offset(workshop.left - 1, 431)),
          ) ||
          !staticWorld.any(
            (floor) => floor.contains(Offset(workshop.right + 1, 431)),
          )) {
        errors.add('$name is disconnected at a ground seam');
      }
      if (!game.checkpoints.any(
        (beacon) => beacon.position == workshop.checkpoint,
      )) {
        errors.add('$name lacks a safe retry point');
      }
      for (final floor in game.platforms) {
        if (floor.overlaps(Rect.fromLTWH(workshop.left + 8, 60, 944, 460))) {
          errors.add('$name overlaps a platform on the original route');
        }
      }

      void at(Offset local) {
        game.player
          ..x = workshop.left + local.dx - game.player.w / 2
          ..y = workshop.origin.dy + local.dy - game.player.h / 2
          ..vx = 0
          ..vy = 0;
      }

      void advance(double seconds) {
        for (var frame = 0; frame < seconds * 120; frame++) {
          game._spawnGrace = 1;
          game.update(1 / 120);
        }
      }

      // The native resolver must hold the route shut before its objective.
      at(const Offset(915, 420));
      game.player.vx = 300;
      game._resolve(game.player, .2, 1);
      if (game.player.rect.right > workshop.boundary.left + 1) {
        errors.add('$name allowed a premature crossing');
      }

      at(const Offset(-21, 435));
      game.right = true;
      advance(.42);
      game.right = false;
      if (game.player.center.dx < workshop.left + 50 || !game.player.grounded) {
        errors.add(
          '$name could not be entered on foot from the scrolling route',
        );
      }
      for (final (target, verb, x) in traces[stage][workshop.id]) {
        final actor = workshop.targets.firstWhere((body) => body.id == target);
        at(Offset(x, 435));
        game.selectTargetAt(actor.center, 0);
        if (!identical(game._manualTarget, actor)) {
          errors.add('$name did not select $target in the original playfield');
          break;
        }
        if (verb == give) {
          game.transferDebt();
        } else {
          game.stealDebt();
        }
        advance(
          target == 'boot' ||
                  target == 'relay' ||
                  target == 'ballast' && stage == 5
              ? .42
              : 1.65,
        );
      }
      advance(1);
      if (!workshop.run.opened) {
        errors.add(
          '$name could not resolve through native casts: ${workshop.run.signals} ${game.message}',
        );
        continue;
      }
      if (workshop.cleared) {
        errors.add('$name completed without the route exit');
      }
      final destination = workshop.room.exit.center;
      at(destination);
      advance(.025);
      if (!workshop.cleared) {
        errors.add('$name did not unlock the original route');
      }
      final snapshot = game._captureCheckpoint();
      game._checkpointSnapshot = snapshot;
      game._restoreCheckpointWorld();
      if (!workshop.cleared ||
          !workshop.run.opened ||
          game.exit != snapshot.exit) {
        errors.add('$name lost committed route progress on checkpoint restore');
      }
    }
  }
  final freightRun = _FallDueGame()..start();
  final gate = freightRun.workshops.first;
  freightRun.targets.add(
    _DueTarget(gate.left + 333, 390, 20, 40, _TargetKind.crate)..debt = 25,
  );
  freightRun.player.x = gate.left + 94;
  for (var tick = 0; tick < 72; tick++) {
    freightRun.update(1 / 120);
  }
  if (gate.run.route != 'Floor plate') {
    errors.add(
      'Cargo from the original route could not operate a workshop plate',
    );
  }
  final opening = _FallDueGame()..preparePreview();
  if (opening._openingRelay?.run.opticTrace?.corner != const Offset(339, 301) ||
      !opening.platforms.contains(const Rect.fromLTWH(-40, 430, 400, 110)) ||
      !opening.platforms.contains(const Rect.fromLTWH(470, 430, 360, 110))) {
    errors.add(
      'The reflector was missing from the original First Instalment opening',
    );
  }
  opening.start();
  final lightingGate = opening._openingRelay!;
  final mirror = lightingGate.targets.firstWhere(
    (target) => target.id == 'reflector',
  );
  opening.selectTargetAt(mirror.center, 0);
  opening.stealDebt();
  for (var tick = 0; tick < 110; tick++) {
    opening.update(1 / 120);
  }
  final trace = lightingGate.run.opticTrace;
  final receiver = lightingGate.room.optic!.receiver;
  if (lightingGate.run.route != 'Reflected beam' ||
      trace?.powered != true ||
      trace?.redirected != receiver ||
      trace?.corner.dx != receiver.dx) {
    errors.add(
      'Native TAKE did not light the original opening’s beam receiver',
    );
  }
  if (!lightingGate.surfaces.contains(const Rect.fromLTWH(360, 430, 110, 12))) {
    errors.add(
      'The reflected beam did not raise a walkable bridge across the original gap',
    );
  }
  if (trace != null) {
    final optic = lightingGate.room.optic!;
    final stop = Offset(
      (optic.source.dx + trace.corner.dx) / 2,
      optic.source.dy,
    );
    lightingGate.run.externalCargo = [
      _Body(_Prop('blocker', 'Freight', stop, material: _Material.metal)),
    ];
    if (lightingGate.run.opticTrace?.redirected != null) {
      errors.add('The reflector redirected a beam through an opaque crate');
    }
  }
  return errors;
}

@visibleForTesting
List<String> auditFallDueNativeEncounters() {
  final errors = <String>[];
  for (var stage = 0; stage <= _BossSpec.all.length; stage++) {
    final blueprint = GameLevelGenerator.generate('fall_due', stage + 1);
    final game = _FallDueGame(campaignLevel: stage + 1, campaign: blueprint)
      ..start();
    final boss = game.activeBoss!;
    final name = boss.spec.name;
    final rigs = game.gravityWells.where((well) => well.rig != null).toList();
    if (rigs.isEmpty ||
        rigs.any(
          (well) => !game.spikes.any(
            (bed) =>
                well.center.dx > bed.left &&
                well.center.dx < bed.right &&
                well.center.dy < bed.top,
          ),
        )) {
      errors.add('$name has a gravity rig without a spike bed below it');
    }
    if (!game.checkpoints.any((point) => point.position == boss.checkpoint) ||
        game.exit.left <= boss.right) {
      errors.add('$name is missing its approach checkpoint or closing exit');
    }
    final well = rigs.first;
    game.player
      ..x = well.center.dx - 65
      ..y = 340
      ..vx = 0
      ..vy = 52
      ..grounded = false;
    game.selectTargetAt(well.center, 0);
    game.transferDebt();
    game._applyRig(well, .10);
    if (!well.inverted || game.player.vy >= 52) {
      errors.add('$name route well did not lift an airborne player');
    }
    game._transferCooldown.clear();
    game.stealDebt();
    if (!well.drawing || well.inverted) {
      errors.add('$name route well ignored TAKE');
    }
    game._transferCooldown.clear();

    for (final seal in game.seals) {
      seal.collected = true;
    }
    for (final gate in game.gates) {
      gate.open = true;
    }
    for (final lever in game.levers) {
      lever.latched = lever.active = true;
    }
    for (final room in game.workshops) {
      room.cleared = true;
    }
    game.player.x = game.exit.center.dx;
    game.player.y = game.exit.center.dy;
    game._tryExit();
    if (game.phase != _DuePhase.playing) {
      errors.add('$name could be skipped at the exit');
    }

    void tick(double seconds) {
      for (var i = 0; i < seconds * 120; i++) {
        game._spawnGrace = 1;
        game.update(1 / 120);
      }
    }

    void place(double x, [double y = 393]) {
      game.player
        ..x = x
        ..y = y
        ..vx = 0
        ..vy = 0;
    }

    void cast(_DueBossTarget target, _Gravity verb) {
      game.selectTargetAt(target.center, 0);
      if (verb == _Gravity.give) {
        game.transferDebt();
      } else {
        game.stealDebt();
      }
    }

    place(boss.left + 91);
    tick(.1);
    place(boss.center.dx - 117);
    cast(boss.armor, boss.opening);
    if (boss.exposed > 0) {
      errors.add('$name opened before committing to an attack');
    }

    final seen = <_BossAttack>{};
    var showedWarning = false;
    while (!boss.defeated) {
      place(boss.left + 91);
      var limit = 540;
      while (!boss.recovering && limit-- > 0) {
        tick(1 / 120);
        if (boss.telegraph &&
            boss.threatAreas(warningOnly: true).any((area) => !area.isEmpty)) {
          showedWarning = true;
        }
        if (boss.striking) seen.add(boss.attack);
      }
      if (!boss.recovering) {
        errors.add('$name never opened a recovery window');
        break;
      }
      place(boss.center.dx - 103);
      final before = boss.health;
      final wrong = boss.opening == _Gravity.give
          ? _Gravity.take
          : _Gravity.give;
      cast(boss.armor, wrong);
      if (boss.exposed > 0) errors.add('$name accepted the wrong opening cast');
      cast(boss.armor, boss.opening);
      tick(.43);
      cast(boss.core, boss.finishing);
      if (boss.health != before - 1) {
        errors.add('$name did not lose an armor plate to its two-verb counter');
        break;
      }
    }
    if (!showedWarning ||
        !seen.containsAll([boss.spec.first, boss.spec.second])) {
      errors.add('$name did not telegraph and perform both attack patterns');
    }
    if (boss.defeated) {
      place(game.exit.left + 10, 383);
      game._tryExit();
      if (game.phase == _DuePhase.playing) {
        errors.add('$name did not release the exit');
      }
    }
  }

  final combat = _FallDueGame(campaignLevel: 3)..start();
  final warnings = <Size>{};
  for (final type in [
    _TargetKind.enemy,
    _TargetKind.drone,
    _TargetKind.heavy,
    _TargetKind.leecher,
  ]) {
    final actor = combat.targets.firstWhere((target) => target.kind == type);
    actor.grounded = true;
    combat.player.x = actor.x + 57;
    combat.player.y = actor.y;
    combat._stepEnemyAbility(actor, .01);
    final lane = actor.preparedAttack;
    if (lane == null) {
      errors.add('${actor.label} never charged its role attack');
      continue;
    }
    warnings.add(lane.size);
    actor.debt = 19;
    combat._stepEnemyAbility(actor, .02);
    if (actor.preparedAttack != null) {
      errors.add('${actor.label} could not be interrupted with gravity');
    }
  }
  if (warnings.length != 4) {
    errors.add('Enemy roles did not have distinct threat areas');
  }

  final approach = _FallDueGame()..start();
  final hoist = approach.gravityWells.first;
  approach.right = true;
  var steps = 160;
  while (approach.player.center.dx < 305 && steps-- > 0) {
    approach.update(1 / 120);
  }
  approach.selectTargetAt(hoist.center, 0);
  approach.transferDebt();
  approach.setJump(true);
  final beforeJump = approach.player.center;
  steps = 155;
  var highest = approach.player.bottom;
  while (approach.player.center.dx < 518 && steps-- > 0) {
    approach.update(1 / 120);
    highest = math.min(highest, approach.player.bottom);
  }
  approach.right = false;
  for (var tick = 0; tick < 130; tick++) {
    approach.update(1 / 120);
  }
  if (approach.lives != 5 ||
      approach.player.center.dx < 501 ||
      (approach.player.bottom - 335).abs() > 2) {
    errors.add(
      'The opening hoist did not reach the high shelf from $beforeJump: '
      '${approach.player.center} with lowest y $highest and ${approach.lives} hearts left',
    );
  }
  final dangerRun = _FallDueGame()
    ..start()
    .._spawnGrace = 0;
  final bailiff = dangerRun.activeBoss!
    ..engaged = true
    ..aimed = true;
  bailiff.aim = bailiff.attackOrigin = bailiff.center.dx;
  bailiff.cycle = bailiff.warning + .14;
  dangerRun.player
    ..x = bailiff.left + 40
    ..y = 393;
  dangerRun._updateBoss(0);
  if (dangerRun.lives != 5) {
    errors.add('The Bailiff hit its approach shelter');
  }
  dangerRun.player.x = bailiff.aim - dangerRun.player.w / 2;
  dangerRun._updateBoss(0);
  if (dangerRun.lives != 4) {
    errors.add('The Bailiff strike had no live collision');
  }
  return errors;
}
