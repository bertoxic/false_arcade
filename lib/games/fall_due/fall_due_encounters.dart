part of 'fall_due_game.dart';

enum _WellRig {
  hoist(
    'Orchard hoist',
    'GIVE to lift toward the upper bank. TAKE to draw cargo in.',
  ),
  ferry(
    'Span winch',
    'GIVE to ride the current across. TAKE to pull the crate off its stop.',
  ),
  arrestor(
    'Sump arrestor',
    'GIVE to brake your fall. TAKE to draw freight to the catch shelf.',
  );

  const _WellRig(this.title, this.hint);
  final String title, hint;
}

enum _BossAttack { rake, hammer, pulse, flood, rail, shutters }

class _BossSpec {
  const _BossSpec(
    this.name,
    this.first,
    this.second,
    this.opening,
    this.valve,
    this.weakPoint,
    this.motion, {
    this.reverseAtLast = false,
  });

  final String name, valve, weakPoint;
  final _BossAttack first, second;
  final _Gravity opening;
  final double motion;
  int get health => 3;
  final bool reverseAtLast;

  static const all = [
    _BossSpec(
      'Yard Bailiff',
      _BossAttack.rake,
      _BossAttack.hammer,
      _Gravity.take,
      'Crown latch',
      'Press shoe',
      34,
    ),
    _BossSpec(
      'Span Keeper',
      _BossAttack.hammer,
      _BossAttack.rail,
      _Gravity.give,
      'Carriage brake',
      'Axle pin',
      66,
    ),
    _BossSpec(
      'Collection Marshal',
      _BossAttack.pulse,
      _BossAttack.rake,
      _Gravity.take,
      'Armor catch',
      'Rear ballast',
      48,
    ),
    _BossSpec(
      'Sump Custodian',
      _BossAttack.flood,
      _BossAttack.pulse,
      _Gravity.give,
      'Diverter plate',
      'Impeller stopper',
      22,
    ),
    _BossSpec(
      'Field Cartographer',
      _BossAttack.rail,
      _BossAttack.shutters,
      _Gravity.take,
      'Field shroud',
      'Steering vane',
      62,
    ),
    _BossSpec(
      'The Auditor',
      _BossAttack.shutters,
      _BossAttack.flood,
      _Gravity.give,
      'Grounding bus',
      'Cutoff fuse',
      48,
      reverseAtLast: true,
    ),
  ];
}

class _DueBoss {
  _DueBoss(this.spec, this.left) : health = spec.health {
    armor = _DueBossTarget(this, weak: false);
    core = _DueBossTarget(this, weak: true);
  }

  final _BossSpec spec;
  final double left;
  static const span = 790.0;
  late final _DueBossTarget armor, core;
  int health;
  int attackIndex = 0;
  bool engaged = false;
  double age = 0, cycle = 0, exposed = 0, recoil = 0, stun = 0;
  double aim = 0;
  double attackOrigin = 0;
  double motionOffset = 0;
  bool aimed = false;
  bool get defeated => health == 0;
  double get right => left + span;
  Offset get checkpoint => Offset(left + 40, 393);
  bool get phaseTwo => health < spec.health;

  Offset get center {
    final bob =
        spec.first == _BossAttack.rail || spec.first == _BossAttack.hammer
        ? math.sin(age * 1.7) * 20
        : 0.0;
    return Offset(left + 402 + motionOffset, 328 + bob + recoil * 17);
  }

  _Gravity get opening =>
      spec.reverseAtLast && health == 1 ? _Gravity.take : spec.opening;
  _Gravity get finishing =>
      opening == _Gravity.take ? _Gravity.give : _Gravity.take;
  _BossAttack get attack =>
      phaseTwo && attackIndex.isEven ? spec.second : spec.first;
  double get warning => attack == _BossAttack.shutters ? 1.2 : 1;
  static const attackDuration = .57;
  double get recovery => phaseTwo ? 3.1 : 3.5;
  bool get telegraph => engaged && !defeated && aimed && cycle < warning;
  bool get striking =>
      engaged &&
      !defeated &&
      aimed &&
      cycle >= warning &&
      cycle < warning + attackDuration;
  bool get recovering => aimed && cycle >= warning + attackDuration;

  double get crown => center.dy - 70;

  Rect get bounds => Rect.fromLTWH(left, 112, span, 360);

  // The warning is the union of the future strike path. The live collision
  // follows the blade, head or beam instead of filling its warning zone.
  List<Rect> threatAreas({required bool warningOnly}) {
    final t = ((cycle - warning) / attackDuration).clamp(0.0, 1.0);
    final x = aim.clamp(left + 126, right - 126);
    final arena = Rect.fromLTWH(left + 117, 130, span - 234, 300);
    Rect sweep(double from, double to, double y, double width, double height) {
      final start = Rect.fromLTWH(from - width / 2, y, width, height);
      return warningOnly
          ? start
                .expandToInclude(start.shift(Offset(to - from, 0)))
                .intersect(arena)
          : start.shift(Offset((to - from) * t, 0)).intersect(arena);
    }

    return switch (attack) {
      _BossAttack.rake => [sweep(attackOrigin, x, 399, 146, 31)],
      _BossAttack.hammer => [
        Rect.fromLTWH(
          x - 37,
          warningOnly ? 142 : 142 + 215 * t,
          74,
          warningOnly ? 288 : 73,
        ),
        if (phaseTwo)
          Rect.fromLTWH(
            (x + 142).clamp(arena.left, arena.right - 38),
            166,
            38,
            264,
          ),
      ],
      _BossAttack.pulse => [
        sweep(attackOrigin, left + 128, phaseTwo ? 332 : 365, 128, 49),
        sweep(attackOrigin, right - 128, phaseTwo ? 332 : 365, 128, 49),
      ],
      _BossAttack.flood => [
        Rect.fromLTWH(
          arena.left,
          warningOnly ? 373 : 409 - 36 * t,
          arena.width,
          warningOnly ? 57 : 21 + 36 * t,
        ),
      ],
      _BossAttack.rail => [
        Rect.fromLTWH(
          arena.left,
          attackIndex.isEven ? 365 : 278,
          arena.width,
          22,
        ),
      ],
      _BossAttack.shutters => [
        Rect.fromLTWH(x - 47, 135, 94, 295),
        if (phaseTwo)
          Rect.fromLTWH(
            (2 * attackOrigin - x - 32).clamp(arena.left, arena.right - 64),
            174,
            64,
            256,
          ),
      ],
    };
  }

  void restore(int? remaining) {
    health = remaining ?? spec.health;
    engaged = aimed = false;
    age = cycle = exposed = recoil = motionOffset = stun = 0;
    attackIndex = 0;
  }
}

class _DueBossTarget implements _DueGravityTarget {
  const _DueBossTarget(this.boss, {required this.weak});
  final _DueBoss boss;
  final bool weak;
  @override
  bool get alive =>
      boss.engaged && !boss.defeated && (weak == (boss.exposed > 0));
  @override
  Offset get center =>
      boss.center + (weak ? const Offset(4, 13) : const Offset(-38, -5));
  @override
  Rect get rect =>
      Rect.fromCenter(center: center, width: weak ? 35 : 43, height: 41);
  @override
  String get label => weak ? boss.spec.weakPoint : boss.spec.valve;
}

class _RouteLoadout {
  const _RouteLoadout(this.rigs, this.height, this.enemies, this.hint);
  final List<_WellRig> rigs;
  final double height;
  final List<(double, double, _TargetKind)> enemies;
  final String hint;

  static const all = [
    _RouteLoadout(
      [_WellRig.hoist],
      265,
      [(708, 292, _TargetKind.drone)],
      'The hoist above the spikes can lift you to the high seal. The reflector powers the low bridge.',
    ),
    _RouteLoadout(
      [_WellRig.ferry, _WellRig.hoist],
      281,
      [(730, 384, _TargetKind.swordsman), (1478, 382, _TargetKind.enemy)],
      'Use the winch for the high handoff or weigh the loose crate to make a low bridge.',
    ),
    _RouteLoadout(
      [_WellRig.ferry, _WellRig.arrestor],
      273,
      [
        (588, 238, _TargetKind.drone),
        (899, 382, _TargetKind.heavy),
        (1480, 273, _TargetKind.archer),
        (1578, 391, _TargetKind.leecher),
      ],
      'Lure Collectors into the turret lane. GIVE grounds the drone before its ring fires.',
    ),
    _RouteLoadout(
      [_WellRig.arrestor, _WellRig.hoist],
      278,
      [(633, 237, _TargetKind.drone), (945, 386, _TargetKind.leecher)],
      'The lower catch shelf survives the fall. GIVE the arrestor when you want a slower descent.',
    ),
    _RouteLoadout(
      [_WellRig.hoist, _WellRig.ferry, _WellRig.arrestor],
      267,
      [(645, 246, _TargetKind.drone), (1067, 385, _TargetKind.swordsman)],
      'Chain the lift and side current. Use the ledges to pause between casts.',
    ),
    _RouteLoadout(
      [_WellRig.ferry, _WellRig.arrestor, _WellRig.hoist],
      269,
      [
        (700, 385, _TargetKind.heavy),
        (1110, 191, _TargetKind.archer),
        (1595, 385, _TargetKind.leecher),
      ],
      'Choose a field before you leave cover. Under the high ledges, wait for the Auditor’s shutters to cycle.',
    ),
  ];
}

extension on _FallDueGame {
  void _installRouteSystems(_DueStage stage) {
    activeBoss = null;
    final authored = levelIndex < _RouteLoadout.all.length;
    final profile = _RouteLoadout.all[levelIndex % _RouteLoadout.all.length];
    for (
      var index = 0;
      index < profile.rigs.length && index < stage.spikes.length;
      index++
    ) {
      final bed = stage.spikes[index];
      gravityWells.add(
        _DueGravityWell(
          Offset(bed.center.dx, profile.height - (index.isOdd ? 15 : 0)),
          radius: 205,
          rig: profile.rigs[index],
        ),
      );
      if (levelIndex == 3 && index == 0) {
        // The rust lid already sits above this bed. This shelf gives a
        // deliberate second route for players who break through it.
        platforms.add(Rect.fromLTWH(bed.left + 37, 450, bed.width - 70, 11));
      } else if (authored && levelIndex >= 4 && index > 0) {
        platforms.add(
          Rect.fromLTWH(bed.left + bed.width * .33, 419, bed.width * .32, 11),
        );
      }
    }
    if (!authored) {
      final decks = stage.platforms
          .where((deck) => deck.top == 430 && deck.left > 0)
          .toList();
      for (
        var index = 0;
        index < profile.enemies.length && index < decks.length;
        index++
      ) {
        final (_, _, type) = profile.enemies[index];
        final deck = decks[index];
        targets.add(
          _targetFromSpec(
            _DueTargetSpec(
              deck.center.dx,
              deck.top - (type == _TargetKind.drone ? 130 : 50),
              type,
            ),
          ),
        );
      }
      return;
    }
    if (levelIndex == 1) {
      // Keep the long Anchor Bay spike bed and its grounded crate route.
      // The winch and hanging service steps offer a higher timed crossing.
      gravityWells.add(
        _DueGravityWell(
          const Offset(2303, 279),
          radius: 205,
          rig: _WellRig.ferry,
        ),
      );
      platforms.addAll(const [
        Rect.fromLTWH(2330, 347, 94, 13),
        Rect.fromLTWH(2470, 300, 76, 13),
      ]);
    }
    if (levelIndex == 3) {
      vents.add(
        _DueKineticVent(
          const Rect.fromLTWH(773, 336, 43, 83),
          isUpdraft: false,
          cycleOffset: 1.55,
        ),
      );
    }
    for (final (x, y, type) in profile.enemies) {
      targets.add(_targetFromSpec(_DueTargetSpec(x, y, type)));
    }
    if (levelIndex >= 2) {
      // The sentry is on the far bank. The low ledge interrupts its sight
      // line and gives the player time to select a target.
      final bed = stage.spikes[1];
      final shelter = Rect.fromLTWH(bed.left - 130, 355, 82, 12);
      if (!platforms.any(shelter.overlaps)) platforms.add(shelter);
    }
  }

  void _installBossHall() {
    final from = exit.left - 65;
    final boss = _DueBoss(
      _BossSpec.all[levelIndex % _BossSpec.all.length],
      from,
    );
    activeBoss = boss;
    platforms.add(Rect.fromLTWH(from - 60, 430, _DueBoss.span + 214, 110));
    final shelves = switch (boss.spec.first) {
      _BossAttack.rake => [(155.0, 350.0, 98.0), (520.0, 351.0, 100.0)],
      _BossAttack.hammer => [(182.0, 367.0, 86.0), (472.0, 312.0, 116.0)],
      _BossAttack.pulse => [(149.0, 358.0, 105.0), (466.0, 348.0, 101.0)],
      _BossAttack.flood => [
        (147.0, 364.0, 106.0),
        (367.0, 350.0, 111.0),
        (574.0, 355.0, 94.0),
      ],
      _BossAttack.rail => [(158.0, 304.0, 106.0), (454.0, 350.0, 112.0)],
      _BossAttack.shutters => [
        (172.0, 362.0, 93.0),
        (432.0, 329.0, 107.0),
        (609.0, 374.0, 77.0),
      ],
    };
    for (final (x, y, w) in shelves) {
      platforms.add(Rect.fromLTWH(from + x, y, w, 16));
    }
    _activeExit = Rect.fromLTWH(boss.right + 42, 350, 56, 80);
  }

  void _updateBoss(double dt) {
    final boss = activeBoss;
    if (boss == null || boss.defeated) return;
    final inside =
        player.center.dx >= boss.left + 82 &&
        player.center.dx <= boss.right + 42;
    if (!boss.engaged) {
      if (!inside) return;
      boss.engaged = true;
      boss.cycle = -1.15;
      message =
          '${boss.spec.name.toUpperCase()} · ${boss.opening.name.toUpperCase()} ${boss.spec.valve}.';
      GameFeedback.selection();
    }
    boss.stun = math.max(0, boss.stun - dt);
    if (boss.stun > 0) return;
    boss.age += dt;
    if (boss.exposed <= 0) {
      final desired =
          math.sin(boss.age * (boss.phaseTwo ? 1.55 : 1.0)) * boss.spec.motion;
      boss.motionOffset = _toward(boss.motionOffset, desired, 112 * dt);
    }
    boss.exposed = math.max(0, boss.exposed - dt);
    boss.recoil = math.max(0, boss.recoil - dt * 2.3);
    boss.cycle += dt;
    if (boss.cycle >= 0 && !boss.aimed) {
      boss.aimed = true;
      boss.aim = player.center.dx;
      boss.attackOrigin = boss.center.dx;
      GameFeedback.lightImpact();
    }
    if (boss.cycle >= boss.warning + _DueBoss.attackDuration + boss.recovery) {
      boss.cycle = 0;
      boss.aimed = false;
      boss.attackIndex++;
    }
    if (boss.striking &&
        _spawnGrace <= 0 &&
        !isInvulnerable &&
        boss
            .threatAreas(warningOnly: false)
            .any(player.rect.deflate(4).overlaps)) {
      _die(
        '${boss.spec.name} caught you in its attack lane.',
        settleDebt: false,
      );
    }
  }

  void _castBoss(_DueBossTarget target, _Gravity verb) {
    final boss = target.boss;
    final need = target.weak ? boss.finishing : boss.opening;
    if (verb != need) {
      message = '${need.name.toUpperCase()} ${target.label}.';
      return;
    }
    if (!target.weak && !boss.recovering) {
      message =
          'WAIT FOR RECOVERY · ${target.label} is locked during the attack.';
      return;
    }
    _transferCooldown.tryTrigger(.35);
    _showTransfer(target.center, taking: verb == _Gravity.take);
    _burst(target.center, target.weak ? _dueCoral : _dueMint, 19);
    if (!target.weak) {
      boss.exposed = 4.6;
      _selectedTarget = null;
      message =
          'EXPOSED · ${boss.finishing.name.toUpperCase()} ${boss.spec.weakPoint}.';
      GameFeedback.mediumImpact();
      return;
    }
    _damageBoss(boss);
  }

  bool _stompBoss(double previousFeet, double impactSpeed, bool slam) {
    final boss = activeBoss;
    if (boss == null || !boss.engaged || boss.defeated) return false;
    final horizontalDist = (player.center.dx - boss.center.dx).abs();
    final inHorizontalRange = horizontalDist <= 85;
    final feet = player.rect.bottom;
    final fromAbove =
        (feet >= boss.crown - 20 && previousFeet <= boss.crown + 35) ||
        (player.y <= boss.center.dy &&
            (impactSpeed > 0 || player.vy > 0 || slam));
    if (!inHorizontalRange || !fromAbove) {
      return false;
    }
    player.y = boss.crown - player.h;
    player.vy = slam ? -520 : -410;
    player.grounded = false;
    _slamming = false;
    _hasAirDashed = false;
    final stunDuration = slam ? 3.8 : 2.2;
    _burst(player.rect.bottomCenter, _dueGold, slam ? 24 : 14);
    if (slam) {
      shockwaves.add(
        _FallDueShockwave(
          position: boss.center,
          color: const Color(0xFFFF7186),
          maxRadius: 110,
        ),
      );
      ArcadeShake.shake(0.35);
      GameFeedback.heavyImpact();
    } else {
      ArcadeShake.shake(0.18);
      GameFeedback.mediumImpact();
    }
    _damageBoss(boss, stun: stunDuration);
    message = slam
        ? 'CRITICAL SLAM! ${boss.spec.name} STUNNED (${stunDuration.toStringAsFixed(1)}s)!'
        : 'BOSS STOMP! ${boss.spec.name} STUNNED (${stunDuration.toStringAsFixed(1)}s)!';
    return true;
  }

  void _damageBoss(_DueBoss boss, {double stun = 0}) {
    boss.health--;
    boss.stun = stun;
    boss.exposed = 0;
    boss.recoil = 1;
    boss.cycle = -1;
    boss.aimed = false;
    boss.attackIndex = 0;
    _selectedTarget = null;
    GameFeedback.heavyImpact();
    if (boss.defeated) {
      score += 1600;
      message =
          '${boss.spec.name.toUpperCase()} DEFEATED · Continue to the exit.';
      _burst(boss.center, _dueMint, 28);
    } else {
      message =
          '${stun > 0 ? 'STUNNED · ' : ''}${boss.health} LIVE${boss.health == 1 ? '' : 'S'} LEFT · ${boss.opening.name.toUpperCase()} ${boss.spec.valve}.';
    }
  }

  void _activateRig(_DueGravityWell well, _Gravity verb) {
    well.inverted = verb == _Gravity.give;
    well.invertedTimer = 3.8;
    well.drawing = verb == _Gravity.take;
    _transferCooldown.tryTrigger(.35);
    _showTransfer(well.center, taking: verb == _Gravity.take);
    _burst(well.center, _dueBlue, 17);
    message = well.drawing
        ? '${well.rig!.title.toUpperCase()} · Drawing cargo.'
        : '${well.rig!.title.toUpperCase()} · Current active. Jump into the marked stream.';
    GameFeedback.mediumImpact();
  }

  void _applyRig(_DueGravityWell well, double dt) {
    if (well.invertedTimer <= 0) return;
    well.invertedTimer = math.max(0, well.invertedTimer - dt);
    if (well.invertedTimer == 0) {
      well.inverted = well.drawing = false;
      return;
    }
    Offset field(Offset at) {
      final dx = well.center.dx - at.dx;
      final dy = at.dy - well.center.dy;
      if (dy < -28 || dy > 184 || dx.abs() > 112) return Offset.zero;
      final pull = (1 - dx.abs() / 112).clamp(.17, 1.0);
      if (well.drawing) return Offset(dx * 4.6, -640 * pull);
      final force = switch (well.rig!) {
        _WellRig.hoist => const Offset(170, -2300),
        _WellRig.ferry => const Offset(1240, -1910),
        _WellRig.arrestor => const Offset(310, -1840),
      };
      return force * pull;
    }

    final impulse = field(player.center) * dt;
    if (impulse != Offset.zero && !player.grounded) {
      player.vx = (player.vx + impulse.dx).clamp(-420.0, 420.0);
      player.vy = math.max(-480, player.vy + impulse.dy);
      if (well.rig == _WellRig.arrestor && !well.drawing) {
        player.vy = math.min(110, player.vy);
      }
    }
    for (final target in targets) {
      if (target.alive && !target.anchored && target.kind.isCrate) {
        final effect = field(target.center) * dt;
        target.vx = (target.vx + effect.dx * .8).clamp(-420.0, 420.0);
        target.vy = math.max(-450, target.vy + effect.dy);
      }
    }
  }
}

extension _DueEnemyAbilities on _FallDueGame {
  void _stepEnemyAbility(_DueTarget target, double dt) {
    final type = target.kind!;
    if (target.stunTimer > 0 ||
        target.debt >= 12 ||
        (type == _TargetKind.drone && target.droneRecoveryTimer > 0)) {
      target
        ..preparedAttack = null
        ..attackTell = 0;
      return;
    }
    if (target.preparedAttack case final lane?) {
      target.attackTell = math.max(0, target.attackTell - dt);
      target.vx *= math.pow(.05, dt);
      if (target.attackTell > 0) return;
      target.preparedAttack = null;
      target.abilityCooldown = switch (type) {
        _TargetKind.enemy => 2.8,
        _TargetKind.drone => 3.3,
        _TargetKind.heavy => 3.6,
        _TargetKind.leecher => 3.0,
        _TargetKind.swordsman => 1.85,
        _TargetKind.archer => 2.65,
        _TargetKind.crate => 0,
      };
      if (type == _TargetKind.enemy) {
        target.vx = target.attackDirection * 365;
        _burst(target.rect.bottomCenter, _dueGold, 8);
        return;
      }
      if (type == _TargetKind.archer) {
        final start = target.center + Offset(target.attackDirection * 19, -5);
        final aim = target.attackAim - start;
        final flight = math.max(.17, aim.dx.abs() / 380);
        bullets.add(_DueBullet(start.dx - 7, start.dy - 7, 380 * target.attackDirection)
          ..vy = aim.dy / flight - 180 * flight
          ..arrow = true);
        return;
      }
      final color = type == _TargetKind.drone
          ? _dueBlue
          : type == _TargetKind.leecher
          ? const Color(0xFFD7A8FF)
          : _dueCoral;
      _burst(lane.center, color, 14);
      if (_spawnGrace > 0 ||
          isInvulnerable ||
          !player.rect.deflate(3).overlaps(lane)) {
        return;
      }
      switch (type) {
        case _TargetKind.swordsman:
          _die('Caught by a sword slash.');
        case _TargetKind.drone:
          player.vx += target.attackDirection * 230;
          player.vy = math.min(player.vy, -180);
          message = 'DRONE PULSE · GIVE while the ring charges to ground it.';
        case _TargetKind.heavy:
          player.vx += target.attackDirection * 175;
          player.vy = math.min(player.vy, -286);
          message = 'ENFORCER QUAKE · Jump over the ground warning.';
        case _TargetKind.leecher:
          final drained = math.min(debt, 18.0);
          debt -= drained;
          _payback = math.min(FallDueTuning.maxDebt, _payback + 14);
          message = 'LEECHER SIPHON · TAKE to break its tether.';
        default:
          return;
      }
      GameFeedback.mediumImpact();
      return;
    }

    if (target.abilityCooldown > 0 ||
        (type != _TargetKind.drone && !target.grounded)) {
      return;
    }
    final delta = player.center - target.center;
    final reach = switch (type) {
      _TargetKind.enemy => 106.0,
      _TargetKind.drone => 106.0,
      _TargetKind.heavy => 138.0,
      _TargetKind.leecher => 121.0,
      _TargetKind.swordsman => 64.0,
      _TargetKind.archer => 320.0,
      _TargetKind.crate => 0.0,
    };
    if (delta.dx.abs() > reach ||
        delta.dy.abs() > (type == _TargetKind.archer ? 165 : type == _TargetKind.drone ? 100 : 63)) {
      return;
    }
    target.attackDirection = delta.dx < 0 ? -1 : 1;
    target.attackAim = player.center;
    target.attackTell = switch (type) {
      _TargetKind.enemy => .64,
      _TargetKind.drone => .84,
      _TargetKind.heavy => 1.02,
      _TargetKind.leecher => .86,
      _TargetKind.swordsman => .51,
      _TargetKind.archer => .92,
      _TargetKind.crate => 0,
    };
    target.preparedAttack = switch (type) {
      _TargetKind.swordsman => Rect.fromCenter(
        center: target.center + Offset(target.attackDirection * 40, 1),
        width: 68, height: 45,
      ),
      _TargetKind.archer => Rect.fromPoints(target.center, target.attackAim).inflate(6),
      _TargetKind.enemy => Rect.fromCenter(
        center: target.center + Offset(target.attackDirection * 51, 5),
        width: 125,
        height: 38,
      ),
      _TargetKind.drone => Rect.fromCenter(
        center: target.center,
        width: 204,
        height: 158,
      ),
      _TargetKind.heavy => Rect.fromCenter(
        center: target.rect.bottomCenter - const Offset(0, 18),
        width: 274,
        height: 36,
      ),
      _TargetKind.leecher => Rect.fromCenter(
        center: target.center + Offset(target.attackDirection * 58, 0),
        width: 129,
        height: 55,
      ),
      _TargetKind.crate => null,
    };
    if (delta.distance < 185) GameFeedback.lightImpact();
  }
}
