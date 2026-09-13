part of 'not_yet_game.dart';

enum GamePhase { title, playing, settling, levelClear, gameOver, victory }

enum ConsequenceType { damage, heal, bounty, defeat, blast }

enum EnemyKind { drone, charger, sentinel }

enum PickupKind { credit, repair, stasis, overdrive }

class RealityGameTuning {
  const RealityGameTuning({
    this.playerAcceleration = 1150,
    this.playerSpeed = 238,
    this.playerVelocityRetainedPerSecond = .0009,
    this.holdInterestPerSecond = 2.4,
    this.interestPerPendingConsequence = .18,
    this.settlementBaseBonus = 72,
    this.cleanSettlementChainGain = .22,
  });

  final double playerAcceleration;
  final double playerSpeed;
  final double playerVelocityRetainedPerSecond;
  final double holdInterestPerSecond;
  final double interestPerPendingConsequence;
  final double settlementBaseBonus;
  final double cleanSettlementChainGain;
}

class RealityGame {
  static const worldWidth = 960.0;
  static const worldHeight = 540.0;
  static const maxHitPoints = 8;
  static const maxDebt = 120.0;

  RealityGame({
    this.tuning = const RealityGameTuning(),
    math.Random? random,
    int campaignLevel = 1,
    GeneratedGameLevel? campaign,
  }) : _random = random ?? math.Random(campaign?.seed),
       _initialLevelIndex = (campaignLevel - 1) % levels.length,
       _campaignSpec = campaign == null ? null : _campaignLevelSpec(campaign);

  final int _initialLevelIndex;
  final LevelSpec? _campaignSpec;

  static const levels = <LevelSpec>[
    LevelSpec(
      'First Wake',
      'Learn the cost of a deferred moment.',
      [
        EnemyKind.drone,
        EnemyKind.drone,
        EnemyKind.drone,
        EnemyKind.drone,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.charger,
      ],
      1.08,
      3,
      parTime: 36,
      drumCount: 3,
    ),
    LevelSpec(
      'Red Shift',
      'Runners close the distance before they fire.',
      [
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
      ],
      .91,
      4,
      parTime: 42,
      drumCount: 4,
    ),
    LevelSpec(
      'Glass Orbit',
      'Sentinels claim the edges of the arena.',
      [
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
      ],
      .78,
      5,
      parTime: 48,
      drumCount: 5,
      drumDrift: 14,
    ),
    LevelSpec(
      'Overdraft',
      'The arena now expects you to take risks.',
      [
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
      ],
      .66,
      6,
      parTime: 54,
      drumCount: 6,
      drumDrift: 22,
      holdInterest: 3,
    ),
    LevelSpec(
      'The Collector',
      'Everything you deferred has led here.',
      [
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
      ],
      .57,
      7,
      parTime: 62,
      drumCount: 7,
      drumDrift: 30,
      holdInterest: 3.5,
    ),
    LevelSpec(
      'Compound Interest',
      'Moving liabilities turn every settlement into a positioning test.',
      [
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.drone,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.drone,
        EnemyKind.charger,
        EnemyKind.sentinel,
        EnemyKind.charger,
        EnemyKind.sentinel,
      ],
      .5,
      8,
      parTime: 70,
      drumCount: 8,
      drumDrift: 38,
      holdInterest: 4,
    ),
  ];

  final RealityGameTuning tuning;
  final math.Random _random;
  final Player _player = Player();
  final List<Enemy> _enemies = [];
  final List<Projectile> _projectiles = [];
  final List<Pickup> _pickups = [];
  final List<Drum> _drums = [];
  final List<Particle> _particles = [];
  final List<FloatingLabel> _labels = [];
  final List<Consequence> _stack = [];
  final List<Shockwave> _shockwaves = [];

  GamePhase phase = GamePhase.title;
  int levelIndex = 0;
  int score = 0;
  int hitPoints = maxHitPoints;
  int defeated = 0;
  int _spawned = 0;
  int _nextId = 1;
  int lastClearBonus = 0;
  double debt = 0;
  double chain = 1;
  double _spawnTimer = 0;
  double _settlementTimer = 0;
  double _introTimer = 0;
  double _stasisTimer = 0;
  double _overdriveTimer = 0;
  double _holdTime = 0;
  double _levelTime = 0;
  double _settlementPeakDebt = 0;
  int _settlementItems = 0;
  int _settlementDamage = 0;
  bool _forcedSettlement = false;
  double time = 0;
  bool holding = false;
  String statusText = 'Hold NOT YET to defer consequences';

  LevelSpec get level => _campaignSpec ?? levels[levelIndex];

  static LevelSpec _campaignLevelSpec(GeneratedGameLevel campaign) {
    final base = levels[(campaign.number - 1) % levels.length];
    final random = math.Random(campaign.seed);
    // A campaign sector is a three-beat breach: establish control, survive a
    // complication, then settle the final wave. It is intentionally longer
    // than a quick-play arena without relying only on enemy speed.
    final totalEnemies =
        ((base.goal + 16 + campaign.number * 3) * campaign.lengthMultiplier)
            .round();
    final roster = <EnemyKind>[...base.roster];
    while (roster.length < totalEnemies) {
      final roll = random.nextDouble();
      roster.add(
        roll < .36
            ? EnemyKind.drone
            : roll < .73
            ? EnemyKind.charger
            : EnemyKind.sentinel,
      );
    }
    return LevelSpec(
      'Sector ${campaign.number.toString().padLeft(2, '0')} · ${campaign.chapterTitle}',
      '${campaign.storyBeat} ${campaign.objective} A $totalEnemies-host breach.',
      roster,
      (base.spawnInterval / campaign.enemyPressure).clamp(.38, 1.15).toDouble(),
      (base.maxOnField + (campaign.number / 6).floor()).clamp(3, 10).toInt(),
      parTime: base.parTime + 12 + campaign.number * 1.4,
      drumCount: (base.drumCount + 1 + campaign.number ~/ 7)
          .clamp(3, 10)
          .toInt(),
      drumDrift: base.drumDrift + random.nextInt(34),
      holdInterest:
          (base.holdInterest ?? 2.4) + (campaign.difficulty - 1) * 1.4,
    );
  }

  double get payoutMultiplier => 1 + debt / 100 * .85 + (chain - 1) * .06;
  double get holdPressure => (debt / maxDebt).clamp(0, 1);
  double get holdDuration => _holdTime;
  double get elapsedSeconds => _levelTime;
  String get rank {
    if (score >= 9000) return 'PARADOX';
    if (score >= 6000) return 'BREACHER';
    return 'SURVIVOR';
  }

  String get powerupLabel {
    final effects = <String>[];
    if (_stasisTimer > 0) {
      effects.add('FREEZE ${_stasisTimer.toStringAsFixed(1)}s');
    }
    if (_overdriveTimer > 0) {
      effects.add('OVERDRIVE ${_overdriveTimer.toStringAsFixed(1)}s');
    }
    return effects.join('  ');
  }

  void startRun() {
    score = 0;
    hitPoints = maxHitPoints;
    chain = 1;
    levelIndex = _initialLevelIndex;
    _startLevel();
  }

  void nextLevel() {
    if (levelIndex + 1 >= levels.length) {
      phase = GamePhase.victory;
      return;
    }
    levelIndex++;
    hitPoints = math.min(maxHitPoints, hitPoints + 2);
    _startLevel();
  }

  void _startLevel() {
    phase = GamePhase.playing;
    holding = false;
    debt = 0;
    defeated = 0;
    _spawned = 0;
    _spawnTimer = .75;
    _introTimer = 2.4;
    _stasisTimer = 0;
    _overdriveTimer = 0;
    _holdTime = 0;
    _levelTime = 0;
    _settlementPeakDebt = 0;
    _settlementItems = 0;
    _settlementDamage = 0;
    _forcedSettlement = false;
    statusText = '${level.title} — ${level.flavour}';
    _enemies.clear();
    _projectiles.clear();
    _pickups.clear();
    _drums
      ..clear()
      ..addAll(List.generate(level.drumCount, (_) => _createDrum()));
    _particles.clear();
    _labels.clear();
    _stack.clear();
    _shockwaves.clear();
    _player
      ..position = const Offset(worldWidth / 2, worldHeight / 2)
      ..velocity = Offset.zero
      ..fireCooldown = .1
      ..invulnerable = 1.0
      ..aim = const Offset(1, 0);
  }

  void setHolding(bool value) {
    if (phase != GamePhase.playing || value == holding) return;
    holding = value;
    if (holding) {
      statusText = 'The world moves. The consequences wait.';
      GameFeedback.selection();
      return;
    }
    _beginSettlement();
  }

  void _beginSettlement({bool forced = false}) {
    holding = false;
    if (_stack.isNotEmpty) {
      phase = GamePhase.settling;
      _settlementTimer = .22;
      _settlementPeakDebt = debt;
      _settlementItems = _stack.length;
      _settlementDamage = 0;
      _forcedSettlement = forced;
      statusText = forced
          ? 'MARGIN CALL — the entire stack is resolving now.'
          : 'Newest consequence resolves first.';
      if (forced) {
        GameFeedback.alarm();
        ArcadeShake.shake(0.75);
      } else {
        GameFeedback.settlement();
      }
    } else {
      debt = 0;
      _holdTime = 0;
      statusText = 'Nothing is owed. Keep moving.';
    }
  }

  void step(double dt, Offset input, bool firing) {
    time += dt;
    _updateEffects(dt);
    if (phase == GamePhase.title ||
        phase == GamePhase.gameOver ||
        phase == GamePhase.victory ||
        phase == GamePhase.levelClear) {
      return;
    }
    if (phase == GamePhase.settling) {
      _levelTime += dt;
      _stepSettlement(dt);
      return;
    }
    _levelTime += dt;
    _introTimer = math.max(0, _introTimer - dt);
    _player.invulnerable = math.max(0, _player.invulnerable - dt);
    _stasisTimer = math.max(0, _stasisTimer - dt);
    _overdriveTimer = math.max(0, _overdriveTimer - dt);
    if (holding) {
      _holdTime += dt;
      final interest =
          (level.holdInterest ?? tuning.holdInterestPerSecond) +
          _stack.length * tuning.interestPerPendingConsequence;
      debt = math.min(maxDebt, debt + interest * dt);
      if (debt >= maxDebt) {
        _beginSettlement(forced: true);
        return;
      }
    }
    _updatePlayer(dt, input, firing);
    _spawnTimer -= dt;
    if (_spawnTimer <= 0 &&
        _spawned < level.goal &&
        _activeEnemyCount < level.maxOnField) {
      _spawnEnemy();
      _spawnTimer = level.spawnInterval * (.86 + _random.nextDouble() * .28);
    }
    _updateDrums(dt);
    _updateProjectiles(dt);
    _updateEnemies(dt);
    _collectPickups();
    _cleanupWorld();
    if (defeated >= level.goal && _enemies.isEmpty && _spawned >= level.goal) {
      _clearLevel();
    }
  }

  void _updateDrums(double dt) {
    for (final drum in _drums) {
      if (!drum.alive || drum.velocity == Offset.zero) continue;
      drum.position += drum.velocity * dt;
      if (drum.position.dx < 55 || drum.position.dx > worldWidth - 55) {
        drum.position = Offset(
          drum.position.dx.clamp(55, worldWidth - 55).toDouble(),
          drum.position.dy,
        );
        drum.velocity = Offset(-drum.velocity.dx, drum.velocity.dy);
      }
      if (drum.position.dy < 55 || drum.position.dy > worldHeight - 55) {
        drum.position = Offset(
          drum.position.dx,
          drum.position.dy.clamp(55, worldHeight - 55).toDouble(),
        );
        drum.velocity = Offset(drum.velocity.dx, -drum.velocity.dy);
      }
    }
  }

  int get _activeEnemyCount =>
      _enemies.where((enemy) => enemy.alive && !enemy.pending).length;

  void _updatePlayer(double dt, Offset input, bool firing) {
    final direction = input.distance > 1 ? input / input.distance : input;
    final acceleration = direction * tuning.playerAcceleration;
    _player.velocity += acceleration * dt;
    final speed = _player.velocity.distance;
    final speedCap = tuning.playerSpeed;
    if (speed > speedCap) {
      _player.velocity = _player.velocity / speed * speedCap;
    }
    _player.velocity = dampOffset(
      _player.velocity,
      tuning.playerVelocityRetainedPerSecond,
      dt,
    );
    _player.position += _player.velocity * dt;
    _player.position = Offset(
      _player.position.dx.clamp(20.0, worldWidth - 20).toDouble(),
      _player.position.dy.clamp(20.0, worldHeight - 20).toDouble(),
    );
    if (direction.distance > .1) _player.aim = direction;
    _player.fireCooldown = math.max(0, _player.fireCooldown - dt);
    if (firing && _player.fireCooldown <= 0) _firePlayerShot();
  }

  void _firePlayerShot() {
    Enemy? target;
    var bestDistance = double.infinity;
    for (final enemy in _enemies) {
      if (!enemy.alive || enemy.pending) continue;
      final distance = (enemy.position - _player.position).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        target = enemy;
      }
    }
    final aim = target == null
        ? _player.aim
        : _normal(target.position - _player.position);
    _player.aim = aim;
    _projectiles.add(
      Projectile(
        position: _player.position + aim * 18,
        velocity: aim * 650,
        allied: true,
        radius: 4,
        damage: _overdriveTimer > 0 ? 2 : 1,
        life: 1.05,
      ),
    );
    _player.fireCooldown = _overdriveTimer > 0 ? .075 : .135;
    _burst(_player.position + aim * 17, 3, const Color(0xFFAAF7FF), .18);
  }

  void _spawnEnemy() {
    final kind = level.roster[_spawned++];
    final side = _random.nextInt(4);
    final position = switch (side) {
      0 => Offset(-22, 40 + _random.nextDouble() * (worldHeight - 80)),
      1 => Offset(
        worldWidth + 22,
        40 + _random.nextDouble() * (worldHeight - 80),
      ),
      2 => Offset(45 + _random.nextDouble() * (worldWidth - 90), -22),
      _ => Offset(
        45 + _random.nextDouble() * (worldWidth - 90),
        worldHeight + 22,
      ),
    };
    _enemies.add(Enemy(_nextId++, kind, position));
  }

  void _updateProjectiles(double dt) {
    for (final shot in _projectiles) {
      if (!shot.alive) continue;
      shot.position += shot.velocity * dt;
      shot.life -= dt;
      if (shot.life <= 0 ||
          shot.position.dx < -30 ||
          shot.position.dx > worldWidth + 30 ||
          shot.position.dy < -30 ||
          shot.position.dy > worldHeight + 30) {
        shot.alive = false;
        continue;
      }
      if (shot.allied) {
        for (final enemy in _enemies) {
          if (!enemy.alive || enemy.pending) continue;
          if ((enemy.position - shot.position).distance <
              enemy.radius + shot.radius) {
            shot.alive = false;
            enemy.health -= shot.damage;
            _burst(shot.position, 4, const Color(0xFFE7FCFF), .2);
            if (enemy.health <= 0) _defeatEnemy(enemy);
            break;
          }
        }
        if (shot.alive) {
          for (final drum in _drums) {
            if (drum.alive &&
                (drum.position - shot.position).distance <
                    drum.radius + shot.radius) {
              shot.alive = false;
              _triggerDrum(drum);
              break;
            }
          }
        }
      } else if ((shot.position - _player.position).distance <
          shot.radius + _player.radius) {
        shot.alive = false;
        _takeHit(shot.damage);
      } else if (!shot.nearMissAwarded &&
          circlesOverlap(
            shot.position,
            shot.radius + 22,
            _player.position,
            _player.radius,
          )) {
        shot.nearMissAwarded = true;
        final reward = (8 * chain).round();
        score += reward;
        chain = math.min(9.9, chain + .025);
        _label(_player.position, 'THREAD +$reward', const Color(0xFF8DDCFF));
      }
    }
  }

  void _updateEnemies(double dt) {
    for (final enemy in _enemies) {
      if (!enemy.alive || enemy.pending) continue;
      if (_stasisTimer > 0) {
        enemy.velocity *= math.pow(.002, dt).toDouble();
        continue;
      }
      enemy.fireCooldown -= dt;
      final toPlayer = _player.position - enemy.position;
      final direction = _normal(toPlayer);
      final distance = toPlayer.distance;
      switch (enemy.kind) {
        case EnemyKind.drone:
          enemy.velocity += direction * 130 * dt;
          if (enemy.fireCooldown <= 0 && distance < 330) {
            _enemyShot(enemy, direction, 215);
            enemy.fireCooldown = 1.55 + _random.nextDouble() * .55;
          }
        case EnemyKind.charger:
          final charge = distance > 75 ? direction * 180 : -direction * 135;
          enemy.velocity += charge * dt;
          if (enemy.fireCooldown <= 0 && distance < 190) {
            enemy.velocity += direction * 175;
            enemy.fireCooldown = 1.7;
          }
        case EnemyKind.sentinel:
          final desired = distance > 230
              ? direction
              : (distance < 150
                    ? -direction
                    : Offset(-direction.dy, direction.dx));
          enemy.velocity += desired * 104 * dt;
          if (enemy.fireCooldown <= 0 && distance < 440) {
            _enemyShot(enemy, direction, 258, spread: .19);
            enemy.fireCooldown = 2.05;
          }
      }
      final cap = enemy.kind == EnemyKind.charger
          ? 165.0
          : enemy.kind == EnemyKind.sentinel
          ? 103.0
          : 112.0;
      if (enemy.velocity.distance > cap) {
        enemy.velocity = _normal(enemy.velocity) * cap;
      }
      enemy.velocity *= math.pow(.018, dt).toDouble();
      enemy.position += enemy.velocity * dt;
      if (distance < enemy.radius + _player.radius + 3) {
        _takeHit(enemy.kind == EnemyKind.charger ? 2 : 1);
        enemy.velocity -= direction * 160;
      }
    }
    for (var first = 0; first < _enemies.length; first++) {
      final a = _enemies[first];
      if (!a.alive || a.pending) continue;
      for (var second = first + 1; second < _enemies.length; second++) {
        final b = _enemies[second];
        if (!b.alive || b.pending) continue;
        final delta = b.position - a.position;
        final minimum = a.radius + b.radius + 4;
        if (delta.distanceSquared <= gameEpsilon ||
            delta.distanceSquared >= minimum * minimum) {
          continue;
        }
        final normal = normalizedOr(delta);
        final correction = (minimum - delta.distance) * .5;
        a.position -= normal * correction;
        b.position += normal * correction;
        a.velocity -= normal * 18;
        b.velocity += normal * 18;
      }
    }
  }

  void _enemyShot(
    Enemy enemy,
    Offset direction,
    double speed, {
    double spread = 0,
  }) {
    final angles = spread == 0 ? [0.0] : [-spread, 0.0, spread];
    for (final angle in angles) {
      final aim = _rotate(direction, angle);
      _projectiles.add(
        Projectile(
          position: enemy.position + aim * (enemy.radius + 3),
          velocity: aim * speed,
          allied: false,
          radius: enemy.kind == EnemyKind.sentinel ? 5 : 4,
          damage: 1,
          life: 3.3,
        ),
      );
    }
  }

  void _defeatEnemy(Enemy enemy, {bool resolved = false}) {
    if (!enemy.alive || enemy.pending) return;
    if (holding && !resolved) {
      enemy.pending = true;
      _addConsequence(
        Consequence(
          ConsequenceType.defeat,
          enemy.position,
          6,
          enemy.id,
          'Enemy defeat',
        ),
      );
      _label(enemy.position, 'DEFEAT DEFERRED', const Color(0xFFFF83A1));
      return;
    }
    enemy.alive = false;
    defeated++;
    final reward =
        ((enemy.kind == EnemyKind.sentinel
                    ? 155
                    : enemy.kind == EnemyKind.charger
                    ? 115
                    : 80) *
                payoutMultiplier)
            .round();
    score += reward;
    _burst(enemy.position, 15, _enemyColor(enemy.kind), .55);
    _label(enemy.position, '+$reward', const Color(0xFFFFD166));
    if (_random.nextDouble() < .34) {
      const drops = [
        PickupKind.credit,
        PickupKind.repair,
        PickupKind.stasis,
        PickupKind.overdrive,
      ];
      _pickups.add(
        Pickup(enemy.position, drops[_random.nextInt(drops.length)]),
      );
    }
  }

  void _triggerDrum(Drum drum) {
    if (!drum.alive) return;
    drum.alive = false;
    if (holding) {
      _addConsequence(
        Consequence(
          ConsequenceType.blast,
          drum.position,
          9,
          -1,
          'Volatile drum',
        ),
      );
      _label(drum.position, 'BLAST DEFERRED', const Color(0xFFFFB26B));
    } else {
      _detonate(drum.position);
    }
  }

  void _detonate(Offset center) {
    _burst(center, 27, const Color(0xFFFF9C4E), .72);
    _shockwave(center, const Color(0xFFFF9C4E), 115);
    GameFeedback.explosion();
    ArcadeShake.shake(0.65);
    for (final enemy in _enemies) {
      if (enemy.alive &&
          !enemy.pending &&
          (enemy.position - center).distance < 105) {
        _defeatEnemy(enemy, resolved: true);
      }
    }
    if ((_player.position - center).distance < 88) _takeHit(2);
  }

  void _takeHit(int damage) {
    if (_player.invulnerable > 0 || phase != GamePhase.playing) return;
    _player.invulnerable = .55;
    GameFeedback.heavyImpact();
    ArcadeShake.shake(0.4);
    if (holding) {
      _addConsequence(
        Consequence(
          ConsequenceType.damage,
          _player.position,
          damage * 8,
          -1,
          'Hull −$damage',
          amount: damage,
        ),
      );
      _label(_player.position, '−$damage HP PENDING', const Color(0xFFFF6D8D));
      return;
    }
    hitPoints -= damage;
    chain = math.max(1, chain * .72);
    _label(_player.position, '−$damage HP', const Color(0xFFFF6D8D));
    _burst(_player.position, 9, const Color(0xFFFF5F83), .38);
    if (hitPoints <= 0) _lose();
  }

  void _collectPickups() {
    for (final pickup in _pickups) {
      if (!pickup.alive ||
          (pickup.position - _player.position).distance >
              pickup.radius + _player.radius + 4) {
        continue;
      }
      pickup.alive = false;
      if (pickup.kind == PickupKind.stasis ||
          pickup.kind == PickupKind.overdrive) {
        _activatePowerup(pickup.kind, pickup.position);
        continue;
      }
      if (holding) {
        final type = pickup.kind == PickupKind.credit
            ? ConsequenceType.bounty
            : ConsequenceType.heal;
        final amount = pickup.kind == PickupKind.credit ? 90 : 2;
        _addConsequence(
          Consequence(
            type,
            pickup.position,
            pickup.kind == PickupKind.credit ? 4 : 5,
            -1,
            pickup.kind == PickupKind.credit ? 'Credit cache' : 'Repair kit',
            amount: amount,
          ),
        );
        _label(
          pickup.position,
          pickup.kind == PickupKind.credit
              ? 'CREDIT DEFERRED'
              : 'REPAIR DEFERRED',
          const Color(0xFF83F2C0),
        );
      } else if (pickup.kind == PickupKind.credit) {
        final amount = (90 * payoutMultiplier).round();
        score += amount;
        _label(pickup.position, '+$amount', const Color(0xFFFFD166));
      } else {
        final before = hitPoints;
        hitPoints = math.min(maxHitPoints, hitPoints + 2);
        _label(
          pickup.position,
          '+${hitPoints - before} HP',
          const Color(0xFF83F2C0),
        );
      }
      _burst(
        pickup.position,
        9,
        pickup.kind == PickupKind.credit
            ? const Color(0xFFFFD166)
            : const Color(0xFF83F2C0),
        .35,
      );
    }
  }

  void _activatePowerup(PickupKind kind, Offset position) {
    switch (kind) {
      case PickupKind.stasis:
        _stasisTimer = math.max(_stasisTimer, 3.5);
        statusText = 'STASIS FIELD: hostile time frozen.';
        _label(position, 'FREEZE', const Color(0xFF8DDCFF));
      case PickupKind.overdrive:
        _overdriveTimer = math.max(_overdriveTimer, 5);
        statusText = 'OVERDRIVE: rapid double-damage fire.';
        _label(position, 'OVERDRIVE', const Color(0xFFFFD166));
      case PickupKind.credit:
      case PickupKind.repair:
        return;
    }
    _burst(position, 15, _pickupColor(kind), .5);
    GameFeedback.pickup();
  }

  void _addConsequence(Consequence consequence) {
    _stack.add(consequence);
    debt = math.min(maxDebt, debt + consequence.weight);
    _burst(consequence.position, 6, _consequenceColor(consequence.type), .3);
    if (debt >= 100) {
      statusText = 'OVERDRAFT — release before the stack buries you.';
    }
  }

  void _stepSettlement(double dt) {
    _settlementTimer -= dt;
    if (_settlementTimer > 0) return;
    _settlementTimer = .1;
    if (_stack.isEmpty) {
      _finishSettlement();
      return;
    }
    final consequence = _stack.removeLast();
    _resolve(consequence);
    if (hitPoints <= 0) _lose();
  }

  void _resolve(Consequence consequence) {
    switch (consequence.type) {
      case ConsequenceType.damage:
        _settlementDamage += consequence.amount;
        hitPoints -= consequence.amount;
        _label(
          _player.position,
          '−${consequence.amount} HP',
          const Color(0xFFFF617F),
        );
        _burst(_player.position, 11, const Color(0xFFFF5F83), .38);
      case ConsequenceType.heal:
        final before = hitPoints;
        hitPoints = math.min(maxHitPoints, hitPoints + consequence.amount);
        _label(
          consequence.position,
          '+${hitPoints - before} HP',
          const Color(0xFF83F2C0),
        );
      case ConsequenceType.bounty:
        final reward = (consequence.amount * payoutMultiplier).round();
        score += reward;
        _label(consequence.position, '+$reward', const Color(0xFFFFD166));
      case ConsequenceType.defeat:
        final enemy = _enemies
            .where((candidate) => candidate.id == consequence.id)
            .firstOrNull;
        if (enemy != null) {
          enemy.pending = false;
          _defeatEnemy(enemy, resolved: true);
        }
      case ConsequenceType.blast:
        _detonate(consequence.position);
    }
    GameFeedback.selection();
  }

  void _finishSettlement() {
    final risk = (_settlementPeakDebt / maxDebt).clamp(0.0, 1.0);
    final clean = _settlementDamage == 0;
    final stackDepth = 1 + math.max(0, _settlementItems - 1) * .16;
    final controlFactor = _forcedSettlement ? .42 : 1.0;
    final bonus =
        (tuning.settlementBaseBonus *
                (1 + risk * 3.2) *
                stackDepth *
                controlFactor *
                (clean ? 1.25 : .65))
            .round();
    score += bonus;
    if (clean && !_forcedSettlement && risk >= .35) {
      chain = math.min(
        9.9,
        chain + tuning.cleanSettlementChainGain + risk * .18,
      );
      _player.invulnerable = .75;
    } else {
      chain = math.max(1, chain * (_forcedSettlement ? .5 : .8));
    }
    debt = 0;
    _holdTime = 0;
    phase = GamePhase.playing;
    _player.invulnerable = math.max(_player.invulnerable, .45);

    _shockwave(
      _player.position,
      clean ? const Color(0xFF48F2C1) : const Color(0xFFFF557D),
      160,
    );

    if (clean && !_forcedSettlement && _settlementItems >= 4) {
      _overdriveTimer = math.max(_overdriveTimer, 2.2);
      _player.invulnerable = math.max(_player.invulnerable, 2.0);
      _shockwave(_player.position, const Color(0xFF48F2C1), 220);
      _label(_player.position, 'SETTLEMENT SURGE!', const Color(0xFF48F2C1));
      GameFeedback.heavyImpact();
    }

    statusText = clean && !_forcedSettlement && risk >= .35
        ? 'CLEAN RELEASE ×${chain.toStringAsFixed(1)} — +$bonus.'
        : _forcedSettlement
        ? 'MARGIN CALL PAID — control bonus reduced to +$bonus.'
        : 'Stack paid under pressure. +$bonus.';
    if (defeated >= level.goal &&
        _enemies.where((enemy) => enemy.alive).isEmpty) {
      _clearLevel();
    }
  }

  void _clearLevel() {
    phase = GamePhase.levelClear;
    holding = false;
    final timeBonus = math.max(0, (level.parTime - _levelTime) * 14).round();
    lastClearBonus = (300 * chain).round() + timeBonus;
    score += lastClearBonus;
    statusText = 'Sector cleared.';
    GameFeedback.victory();
  }

  void _lose() {
    hitPoints = 0;
    holding = false;
    phase = GamePhase.gameOver;
    statusText = 'Reality won this round.';
    GameFeedback.explosion();
  }

  void _cleanupWorld() {
    _enemies.removeWhere((enemy) => !enemy.alive);
    _projectiles.removeWhere((projectile) => !projectile.alive);
    _pickups.removeWhere((pickup) => !pickup.alive);
    _drums.removeWhere((drum) => !drum.alive);
  }

  void _updateEffects(double dt) {
    for (final particle in _particles) {
      particle.time += dt;
      particle.position += particle.velocity * dt;
      particle.velocity *= math.pow(.06, dt).toDouble();
    }
    _particles.removeWhere((particle) => particle.time >= particle.life);
    for (final label in _labels) {
      label.time += dt;
      label.position += const Offset(0, -26) * dt;
    }
    _labels.removeWhere((label) => label.time >= label.life);
    for (final wave in _shockwaves) {
      wave.time += dt;
    }
    _shockwaves.removeWhere((wave) => wave.time >= wave.life);
  }

  void _shockwave(Offset position, Color color, [double maxRadius = 130]) {
    if (_shockwaves.length >= 8) _shockwaves.removeAt(0);
    _shockwaves.add(Shockwave(position, color, maxRadius: maxRadius));
  }

  Drum _createDrum() {
    Offset point;
    do {
      point = Offset(
        115 + _random.nextDouble() * (worldWidth - 230),
        84 + _random.nextDouble() * (worldHeight - 168),
      );
    } while ((point - const Offset(worldWidth / 2, worldHeight / 2)).distance <
        115);
    if (level.drumDrift <= 0) return Drum(point);
    final angle = _random.nextDouble() * math.pi * 2;
    return Drum(
      point,
      velocity: Offset(math.cos(angle), math.sin(angle)) * level.drumDrift,
    );
  }

  void _burst(Offset position, int amount, Color color, double life) {
    // I cap transient effects so a large settlement cannot create frame debt.
    final available = math.max(0, 240 - _particles.length);
    for (var index = 0; index < math.min(amount, available); index++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 35 + _random.nextDouble() * 160;
      _particles.add(
        Particle(
          position,
          Offset(math.cos(angle), math.sin(angle)) * speed,
          color,
          life * (.6 + _random.nextDouble() * .7),
        ),
      );
    }
  }

  void _label(Offset position, String text, Color color) {
    if (_labels.length >= 24) _labels.removeAt(0);
    _labels.add(FloatingLabel(position, text, color));
  }
}

class LevelSpec {
  const LevelSpec(
    this.title,
    this.flavour,
    this.roster,
    this.spawnInterval,
    this.maxOnField, {
    this.parTime = 45,
    this.drumCount = 3,
    this.drumDrift = 0,
    this.holdInterest,
  });

  final String title;
  final String flavour;
  final List<EnemyKind> roster;
  final double spawnInterval;
  final int maxOnField;
  final double parTime;
  final int drumCount;
  final double drumDrift;
  final double? holdInterest;
  int get goal => roster.length;
}

class Player {
  Offset position = const Offset(
    RealityGame.worldWidth / 2,
    RealityGame.worldHeight / 2,
  );
  Offset velocity = Offset.zero;
  Offset aim = const Offset(1, 0);
  double fireCooldown = 0;
  double invulnerable = 0;
  final double radius = 13;
}

class Enemy {
  Enemy(this.id, this.kind, this.position) {
    switch (kind) {
      case EnemyKind.drone:
        radius = 13;
        health = 2;
        fireCooldown = .9;
      case EnemyKind.charger:
        radius = 16;
        health = 3;
        fireCooldown = 1.2;
      case EnemyKind.sentinel:
        radius = 19;
        health = 5;
        fireCooldown = 1.55;
    }
  }

  final int id;
  final EnemyKind kind;
  Offset position;
  Offset velocity = Offset.zero;
  double radius = 12;
  int health = 1;
  double fireCooldown = 0;
  bool alive = true;
  bool pending = false;
}

class Projectile {
  Projectile({
    required this.position,
    required this.velocity,
    required this.allied,
    required this.radius,
    required this.damage,
    required this.life,
  });

  Offset position;
  Offset velocity;
  final bool allied;
  final double radius;
  final int damage;
  double life;
  bool alive = true;
  bool nearMissAwarded = false;
}

class Pickup {
  Pickup(this.position, this.kind);

  Offset position;
  final PickupKind kind;
  final double radius = 10;
  bool alive = true;
}

class Drum {
  Drum(this.position, {this.velocity = Offset.zero});

  Offset position;
  Offset velocity;
  final double radius = 14;
  bool alive = true;
}

class Particle {
  Particle(this.position, this.velocity, this.color, this.life);

  Offset position;
  Offset velocity;
  final Color color;
  final double life;
  double time = 0;
}

class FloatingLabel {
  FloatingLabel(this.position, this.text, this.color);

  Offset position;
  final String text;
  final Color color;
  double time = 0;
  final double life = .85;
}

class Consequence {
  const Consequence(
    this.type,
    this.position,
    this.weight,
    this.id,
    this.label, {
    this.amount = 0,
  });

  final ConsequenceType type;
  final Offset position;
  final double weight;
  final int id;
  final String label;
  final int amount;
}

class Shockwave {
  Shockwave(this.position, this.color, {this.maxRadius = 130, this.life = .45});

  final Offset position;
  final Color color;
  final double maxRadius;
  final double life;
  double time = 0;
}
