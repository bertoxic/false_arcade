part of 'future_debt_game.dart';

enum _FuturePhase { intro, playing, dead }

enum _DebtKind { move, shoot, dash, life }

enum _FutureEnemyType { hound, auditor, interest, bailiff }

enum _FutureEchoType { runner, auditor, anchor, claim }

enum _FuturePickupKind { time, writeoff, ghost, compound, reverse, caseFile }

enum _FutureShotType { player, audit, echo, collector }

enum _FutureParticleType {
  borrow,
  debt,
  dash,
  trail,
  portal,
  hit,
  kill,
  spark,
  compound,
  repay,
  wall,
  gold,
}

/// Pure helpers kept public for gameplay-rule regression tests.
abstract final class FutureDebtRules {
  static const campaignScoreMultiplier = 1;

  static double interestForDelay(double delay) =>
      1 + math.max(0, delay - 4) * .11;

  /// Future Debt is built around escalating bills, so its levels need a
  /// longer survival window than the arcade-wide campaign default.
  static double startingLifetimeForLevel(int level) =>
      90 + math.min(18, math.max(0, level - 1) * .75).toDouble();

  static int campaignTargetScore(int baseTarget) =>
      baseTarget * campaignScoreMultiplier;

  static bool canSpawnEnemy({
    required int kills,
    required int alive,
    required int goal,
    required int maximumAlive,
  }) => kills < goal && alive < maximumAlive && kills + alive < goal;

  static Offset dashVector({
    required Offset moveDirection,
    required Offset storedDirection,
    required Offset fireDirection,
  }) => normalizedOr(
    moveDirection.distance > .1 ? moveDirection : storedDirection,
    fallback: fireDirection,
  );
}

class _FutureDebtGame {
  _FutureDebtGame({GeneratedGameLevel? campaign})
    : _campaign = campaign,
      _plan = _FutureDebtCasePlan.fromCampaign(campaign),
      _campaignLevel = campaign?.number ?? 1,
      _layoutSeed = campaign?.seed ?? math.Random().nextInt(0x7fffffff) {
    _random = math.Random(_layoutSeed ^ 0x39AB71);
    _buildMaze();
    _followCamera(immediate: true);
  }

  static const width = 960.0;
  static const height = 540.0;
  static const worldWidth = 3040.0;
  static const worldHeight = 1900.0;
  static const playerRadius = 15.0;
  static const portalRadius = 25.0;
  static const _maxParticles = 180;
  static const _maxPickups = 42;
  static const _maxPlayerShots = 84;
  static const _maxEnemyShots = 72;
  static const _maximumLifetime = 120.0;

  final GeneratedGameLevel? _campaign;
  final _FutureDebtCasePlan _plan;
  final int _campaignLevel;
  final int _layoutSeed;
  _FutureDebtPace _pace = _FutureDebtPace.standard;
  late math.Random _random;
  final walls = <_FutureWall>[];
  final pickups = <_FuturePickup>[];
  final enemies = <_FutureEnemy>[];
  final portals = <_FuturePortal>[];
  final shots = <_FutureShot>[];
  final enemyShots = <_FutureShot>[];
  final particles = <_FutureParticle>[];
  final echoes = <_FutureEcho>[];
  final bills = <_FutureBill>[];

  final zones = const <_FutureZone>[
    _FutureZone(Rect.fromLTWH(120, 120, 720, 510), 'LATE FEE ATRIUM', 'I'),
    _FutureZone(Rect.fromLTWH(1030, 120, 720, 520), 'REPO WARD', 'II'),
    _FutureZone(Rect.fromLTWH(1990, 140, 760, 500), 'AUDIT CHAPEL', 'III'),
    _FutureZone(Rect.fromLTWH(260, 760, 700, 540), 'COLLATERAL HALL', 'IV'),
    _FutureZone(Rect.fromLTWH(1120, 720, 790, 590), 'THE COMPOUND', 'V'),
    _FutureZone(Rect.fromLTWH(2070, 770, 700, 540), 'DEFAULT COURT', 'VI'),
    _FutureZone(Rect.fromLTWH(540, 1440, 760, 330), 'WRITE-OFF TUNNELS', 'VII'),
    _FutureZone(Rect.fromLTWH(1660, 1420, 800, 350), 'MATURITY VAULT', 'VIII'),
  ];

  _FuturePhase phase = _FuturePhase.intro;
  Offset player = const Offset(1515, 1010);
  Offset camera = Offset.zero;
  Offset moveDirection = Offset.zero;
  Offset aimDirection = const Offset(1, 0);
  Offset dashDirection = const Offset(1, 0);
  _FutureCollector? collector;
  _FutureLevelExit? levelExit;
  double time = 0;
  double lifetime = FutureDebtRules.startingLifetimeForLevel(1);
  double score = 0;
  double spawnTimer = .45 / .7;
  double eliteTimer = 11 / .7;
  double shotCooldown = 0;
  double dashCooldown = 0;
  double invulnerable = 0;
  double portalCooldown = 0;
  double movementTrailTimer = 0;
  double moveBoost = 0;
  double shootBoost = 0;
  double reversalBoost = 0;
  double screenShake = 0;
  double selectedDelay = 6;
  double totalBorrowed = 0;
  double totalRepaid = 0;
  double _totalDefaultTime = 0;
  int defaults = 0;
  int bankruptcies = 0;
  int dashCharges = 0;
  int claimsDefeated = 0;
  int wallsBreached = 0;
  int recordsRecovered = 0;
  int auditReturns = 0;
  int maturitiesSurvived = 0;
  bool collectorSettled = false;
  bool _defaultWasActive = false;
  bool _manualAimActive = false;
  bool levelExitReached = false;
  String message =
      'Breach walls. Hidden Time Shards can erase pieces of your future debt.';
  final locks = <_DebtKind, double>{
    for (final kind in _DebtKind.values) kind: 0,
  };

  bool get isPlaying => phase == _FuturePhase.playing;
  _FutureDebtPace get pace => _pace;
  double get _enemyFlow => .7 * _pace.enemyFlow;
  bool get totalDefaultActive => locks[_DebtKind.life] == -1;
  bool get hasAnyLock =>
      totalDefaultActive || locks.values.any((value) => value > 0);
  bool get hasCollector => collector != null;
  bool get levelExitOpen => levelExit != null;
  bool get canDash =>
      isPlaying && !isLocked(_DebtKind.dash) && dashCooldown <= 0;
  int get scoreTarget => _plan.scoreTarget;
  String get caseTitle => _plan.title;
  String get caseInstruction => _plan.instruction;
  String get objectiveProgress => switch (_plan.objective) {
    _FutureObjectiveKind.clearClaims =>
      '$claimsDefeated / ${_plan.objectiveTarget} CLAIMS CLEARED',
    _FutureObjectiveKind.recoverRecords =>
      '$recordsRecovered / ${_plan.objectiveTarget} CASE FILES RECOVERED',
    _FutureObjectiveKind.breachLien =>
      '$wallsBreached / ${_plan.objectiveTarget} LIENS BREACHED',
    _FutureObjectiveKind.reflectAudit =>
      '$auditReturns / ${_plan.objectiveTarget} AUDIT SHOTS RETURNED',
    _FutureObjectiveKind.surviveMaturities =>
      '$maturitiesSurvived / ${_plan.objectiveTarget} MATURITIES SURVIVED',
    _FutureObjectiveKind.settleCollector =>
      collectorSettled
          ? 'COLLECTOR SETTLED'
          : 'DECLARE BANKRUPTCY, THEN SETTLE THE COLLECTOR',
    _FutureObjectiveKind.closeLedger =>
      hasOutstandingDebt ? 'WAIT FOR EVERY BILL TO CLEAR' : 'LEDGER CLEAR',
  };
  bool get hasOutstandingDebt =>
      bills.isNotEmpty ||
      locks.values.any((value) => value != 0) ||
      echoes.any((echo) => !echo.dead) ||
      collector != null;
  int get outstandingContractCount =>
      bills.length +
      locks.values.where((value) => value > 0).length +
      echoes.where((echo) => !echo.dead).length +
      (collector == null ? 0 : 1);
  bool get objectiveComplete => switch (_plan.objective) {
    _FutureObjectiveKind.clearClaims => claimsDefeated >= _plan.objectiveTarget,
    _FutureObjectiveKind.recoverRecords =>
      recordsRecovered >= _plan.objectiveTarget,
    _FutureObjectiveKind.breachLien => wallsBreached >= _plan.objectiveTarget,
    _FutureObjectiveKind.reflectAudit => auditReturns >= _plan.objectiveTarget,
    _FutureObjectiveKind.surviveMaturities =>
      maturitiesSurvived >= _plan.objectiveTarget,
    _FutureObjectiveKind.settleCollector => collectorSettled,
    _FutureObjectiveKind.closeLedger => !hasOutstandingDebt,
  };
  bool isLocked(_DebtKind kind) => totalDefaultActive || (locks[kind] ?? 0) > 0;
  bool canBorrow(_DebtKind kind) =>
      isPlaying &&
      !isLocked(kind) &&
      collector == null &&
      !_hasOutstandingCredit(kind) &&
      outstandingContractCount < _plan.contractLimit;

  bool _hasOutstandingCredit(_DebtKind kind) {
    if (bills.any((bill) => bill.kind == kind)) return true;
    if ((locks[kind] ?? 0) > 0) return true;
    if (kind == _DebtKind.move && moveBoost > 0) return true;
    if (kind == _DebtKind.shoot && shootBoost > 0) return true;
    if (kind == _DebtKind.dash && reversalBoost > 0) return true;
    return switch (kind) {
      _DebtKind.move => echoes.any(
        (echo) => !echo.dead && echo.type == _FutureEchoType.runner,
      ),
      _DebtKind.shoot => echoes.any(
        (echo) => !echo.dead && echo.type == _FutureEchoType.auditor,
      ),
      _DebtKind.dash => echoes.any(
        (echo) => !echo.dead && echo.type == _FutureEchoType.anchor,
      ),
      _DebtKind.life => echoes.any(
        (echo) => !echo.dead && echo.type == _FutureEchoType.claim,
      ),
    };
  }

  bool _canSpawnClaim() => FutureDebtRules.canSpawnEnemy(
    kills: claimsDefeated,
    alive: enemies.where((enemy) => !enemy.dead).length,
    goal: _plan.encounterBudget,
    maximumAlive: _plan.maximumAlive,
  );

  void _grantLifetime(double amount) {
    lifetime = math.min(_maximumLifetime, lifetime + amount);
  }

  void _addPickup(_FuturePickup pickup) {
    // I keep rewards bounded so a long encounter cannot turn into a growing
    // pile of off-screen work for the simulation and painter.
    if (pickups.length >= _maxPickups) {
      final discard = pickups.indexWhere(
        (candidate) => candidate.kind != _FuturePickupKind.caseFile,
      );
      if (discard >= 0) pickups.removeAt(discard);
    }
    if (pickups.length < _maxPickups) pickups.add(pickup);
  }

  void _addPlayerShot(_FutureShot shot) {
    if (shots.length >= _maxPlayerShots) shots.removeAt(0);
    shots.add(shot);
  }

  void _addEnemyShot(_FutureShot shot) {
    if (enemyShots.length >= _maxEnemyShots) enemyShots.removeAt(0);
    enemyShots.add(shot);
  }

  double get debtAmount =>
      bills.fold(0.0, (sum, bill) => sum + bill.duration) +
      locks.values.fold(
        0.0,
        (sum, value) => sum + (value == -1 ? _totalDefaultTime : value),
      );
  String get formName {
    final debt = debtAmount;
    return debt < 4
        ? 'PRIME'
        : debt < 10
        ? 'LEVERAGED'
        : debt < 18
        ? 'OVERDRAWN'
        : debt < 28
        ? 'DEFAULTING'
        : 'OWNED';
  }

  _FutureZone? get currentZone {
    for (final zone in zones) {
      if (zone.bounds.contains(player)) return zone;
    }
    return null;
  }

  void start() {
    _random = math.Random(_layoutSeed ^ 0x39AB71);
    phase = _FuturePhase.playing;
    player = const Offset(1515, 1010);
    camera = Offset.zero;
    moveDirection = Offset.zero;
    aimDirection = const Offset(1, 0);
    dashDirection = const Offset(1, 0);
    time = 0;
    lifetime =
        (FutureDebtRules.startingLifetimeForLevel(_campaignLevel) +
                _pace.lifetimeAdjustment)
            .clamp(35, _maximumLifetime)
            .toDouble();
    score = 0;
    spawnTimer = .45 / _enemyFlow;
    eliteTimer = 11 / _enemyFlow;
    shotCooldown = 0;
    dashCooldown = 0;
    invulnerable = 0;
    portalCooldown = 0;
    movementTrailTimer = 0;
    moveBoost = 0;
    shootBoost = 0;
    reversalBoost = 0;
    screenShake = 0;
    selectedDelay = 6;
    totalBorrowed = 0;
    totalRepaid = 0;
    defaults = 0;
    bankruptcies = 0;
    dashCharges = 0;
    claimsDefeated = 0;
    wallsBreached = 0;
    recordsRecovered = 0;
    auditReturns = 0;
    maturitiesSurvived = 0;
    collectorSettled = false;
    _totalDefaultTime = 0;
    _defaultWasActive = false;
    _manualAimActive = false;
    bills.clear();
    enemies.clear();
    shots.clear();
    enemyShots.clear();
    particles.clear();
    echoes.clear();
    collector = null;
    levelExit = null;
    levelExitReached = false;
    for (final kind in _DebtKind.values) {
      locks[kind] = 0;
    }
    _buildMaze();
    _followCamera(immediate: true);
    _flash('$caseTitle — $caseInstruction');
    GameFeedback.selection();
  }

  void cancelTransientInput() => moveDirection = Offset.zero;

  void setPace(_FutureDebtPace pace) {
    if (phase != _FuturePhase.intro) return;
    _pace = pace;
  }

  void selectDelay(double delay) {
    selectedDelay = delay;
    _flash(
      'MATURITY SET TO ${delay.round()} SECONDS — later credit costs more.',
    );
    GameFeedback.selection();
  }

  void update(double dt, Offset input, Offset aimInput, bool firing) {
    if (!isPlaying) return;
    final ghostWasActive = moveBoost > 0;
    time += dt;
    lifetime -= dt;
    shotCooldown = math.max(0, shotCooldown - dt);
    dashCooldown = math.max(0, dashCooldown - dt);
    invulnerable = math.max(0, invulnerable - dt);
    portalCooldown = math.max(0, portalCooldown - dt);
    moveBoost = math.max(0, moveBoost - dt);
    shootBoost = math.max(0, shootBoost - dt);
    reversalBoost = math.max(0, reversalBoost - dt);
    screenShake = math.max(0, screenShake - dt * 35);
    for (final kind in _DebtKind.values) {
      if (locks[kind]! > 0) locks[kind] = math.max(0, locks[kind]! - dt);
    }
    if (_totalDefaultTime > 0) {
      _totalDefaultTime = math.max(0, _totalDefaultTime - dt);
      if (_totalDefaultTime == 0) locks[_DebtKind.life] = 0;
    }
    if (_defaultWasActive && !totalDefaultActive) {
      score += 900 + _plan.act * 180;
      _flash('DEFAULT SURVIVED — settlement bonus posted.');
      _defaultWasActive = false;
    }
    if (ghostWasActive && moveBoost == 0) _reconcileAfterPhase();
    _collectDueBills();
    _openLevelExitIfReady();

    if (input.distance > .1 && !isLocked(_DebtKind.move)) {
      final direction = normalizedOr(input);
      moveDirection = direction;
      dashDirection = direction;
      final speed = 205 * (moveBoost > 0 ? 2 : 1) * _anchorSlowdown;
      final dx = direction.dx * speed * input.distance.clamp(0.0, 1.0) * dt;
      final dy = direction.dy * speed * input.distance.clamp(0.0, 1.0) * dt;
      player = moveBoost > 0
          ? _clampWorld(player + Offset(dx, dy), playerRadius)
          : _moveCircle(player, playerRadius, dx, dy);
      _emitMovementTrail(dt);
    } else {
      moveDirection = Offset.zero;
      movementTrailTimer = 0;
    }
    _updatePortals(dt);
    _manualAimActive = aimInput.distance > .1;
    if (_manualAimActive) {
      aimDirection = normalizedOr(aimInput, fallback: aimDirection);
    }
    if (firing) _fire();
    if (!levelExitOpen) {
      spawnTimer -= dt;
      eliteTimer -= dt;
      if (spawnTimer <= 0) {
        _spawnEnemy();
        spawnTimer =
            math.max(.38, _plan.spawnInterval - time / 340) / _enemyFlow;
      }
      if (eliteTimer <= 0 && _canSpawnClaim()) {
        _spawnEnemy(force: _FutureEnemyType.bailiff);
        eliteTimer = (16 + _random.nextDouble() * 8) / _enemyFlow;
      }
    }
    _updateShots(dt);
    _updateEnemies(dt);
    _updateEchoes(dt);
    _updatePickups(dt);
    _updateCollector(dt);
    _updateParticles(dt);
    _openLevelExitIfReady();
    _updateLevelExit(dt);
    _followCamera(dt: dt);
    if (lifetime <= 0) _gameOver();
  }

  double get _anchorSlowdown =>
      echoes.any(
        (echo) =>
            echo.type == _FutureEchoType.anchor &&
            !echo.dead &&
            (echo.position - player).distance < echo.radius + 25,
      )
      ? .35
      : 1;

  void borrow(_DebtKind kind) {
    if (!canBorrow(kind)) {
      final reason = totalDefaultActive
          ? 'TOTAL DEFAULT BLOCKS NEW CREDIT.'
          : collector != null
          ? 'SETTLE THE COLLECTOR BEFORE BORROWING AGAIN.'
          : _hasOutstandingCredit(kind)
          ? '${kind.name.toUpperCase()} CREDIT IS STILL OUTSTANDING.'
          : outstandingContractCount >= _plan.contractLimit
          ? 'CREDIT LIMIT ${_plan.contractLimit} REACHED — LET A BILL CLEAR.'
          : '${kind.name.toUpperCase()} CREDIT IS LOCKED.';
      _flash(reason);
      return;
    }
    final interest = FutureDebtRules.interestForDelay(selectedDelay);
    switch (kind) {
      case _DebtKind.move:
        moveBoost = math.max(moveBoost, 2.4);
        _schedule(kind, 1.7 * interest);
        totalBorrowed += 1.7;
        _flash(
          'GHOST WAGE — phase through walls and hostile bullets. A Runner Echo matures in ${selectedDelay.round()}s.',
        );
      case _DebtKind.shoot:
        shootBoost = math.max(shootBoost, 2.4);
        _schedule(kind, 1.6 * interest);
        totalBorrowed += 1.6;
        _flash(
          'COMPOUND FIRE — triple-shot now. An Auditor Echo matures in ${selectedDelay.round()}s.',
        );
        _burst(player, 28, _FutureParticleType.compound);
      case _DebtKind.dash:
        reversalBoost = math.max(reversalBoost, 2.4);
        _schedule(kind, 1.5 * interest);
        totalBorrowed += 1.5;
        _flash(
          'REVERSE PAYMENT — hostile bullets and damage rebound. An Anchor Echo matures in ${selectedDelay.round()}s.',
        );
      case _DebtKind.life:
        _grantLifetime(8);
        _schedule(kind, 8 * interest);
        totalBorrowed += 8;
        _flash(
          'CASH OUT TOMORROW — +8 seconds now. A Maturity Claim is waiting.',
        );
    }
    _burst(player, 13, _FutureParticleType.borrow);
    GameFeedback.selection();
  }

  void _schedule(_DebtKind kind, double duration) =>
      bills.add(_FutureBill(kind, duration, time + selectedDelay, player));

  void _collectDueBills() {
    for (var index = bills.length - 1; index >= 0; index--) {
      final bill = bills[index];
      if (bill.due > time) continue;
      bills.removeAt(index);
      _applyBill(bill);
    }
    final locked = [
      _DebtKind.move,
      _DebtKind.shoot,
      _DebtKind.dash,
    ].where((kind) => locks[kind]! > 0).length;
    if (locked >= 3 && !totalDefaultActive) {
      _totalDefaultTime = [
        locks[_DebtKind.move]!,
        locks[_DebtKind.shoot]!,
        locks[_DebtKind.dash]!,
        .9,
      ].reduce(math.max);
      locks[_DebtKind.move] = 0;
      locks[_DebtKind.shoot] = 0;
      locks[_DebtKind.dash] = 0;
      locks[_DebtKind.life] = -1;
      defaults++;
      _defaultWasActive = true;
      screenShake = 12;
      _flash(
        'TOTAL DEFAULT — all controls seized. Survive it for a ×6 payout.',
      );
      GameFeedback.heavyImpact();
    }
  }

  void _applyBill(_FutureBill bill) {
    if (bill.kind == _DebtKind.life) {
      locks[_DebtKind.life] = math.max(locks[_DebtKind.life]!, bill.duration);
      totalRepaid += bill.duration;
      echoes.add(
        _FutureEcho(
          _FutureEchoType.claim,
          bill.origin,
          radius: 17,
          health: 7,
          life: bill.duration + 3,
          value: bill.duration,
        ),
      );
      screenShake = 7;
      _flash('MATURITY CLAIM — destroy it to release your time credit.');
      return;
    }
    locks[bill.kind] = math.max(locks[bill.kind]!, bill.duration);
    totalRepaid += bill.duration;
    final type = bill.kind == _DebtKind.move
        ? _FutureEchoType.runner
        : bill.kind == _DebtKind.shoot
        ? _FutureEchoType.auditor
        : _FutureEchoType.anchor;
    echoes.add(
      _FutureEcho(
        type,
        bill.origin,
        radius: type == _FutureEchoType.anchor ? 70 : 15,
        health: type == _FutureEchoType.anchor ? 6 : 4,
        life: bill.duration + 3,
      ),
    );
    _burst(bill.origin, 18, _FutureParticleType.debt);
    _flash(
      'DEBT MATURED — ${bill.kind.name.toUpperCase()} seized for ${bill.duration.toStringAsFixed(1)}s.',
    );
    GameFeedback.mediumImpact();
  }

  void forgiveDebt(double amount) {
    if (bills.isEmpty) {
      _grantLifetime(1.5);
      _flash('WRITE-OFF had no debt to erase — converted to +1.5s lifetime.');
      return;
    }
    bills.sort((a, b) => a.due.compareTo(b.due));
    final bill = bills.first;
    final cut = math.min(amount, bill.duration);
    bill.duration -= cut;
    totalRepaid += cut;
    if (bill.duration < .15) bills.removeAt(0);
    _flash(
      'WRITE-OFF — erased ${cut.toStringAsFixed(1)}s from your nearest future bill.',
    );
  }

  void bankrupt() {
    if (!isPlaying || collector != null) return;
    final amount = debtAmount;
    if (amount < .15) {
      _flash('No meaningful debt to bankrupt. Keep your powder dry.');
      return;
    }
    bankruptcies++;
    bills.clear();
    echoes.clear();
    _totalDefaultTime = 0;
    for (final kind in _DebtKind.values) {
      locks[kind] = 0;
    }
    moveBoost = 0;
    shootBoost = 0;
    reversalBoost = 0;
    // I charge an immediate time fee so Bankruptcy is a risky conversion, not
    // a way to keep borrowed life while erasing every consequence.
    lifetime = math.max(1, lifetime - math.min(8, amount * .32));
    collector = _FutureCollector(
      Offset(
        math.max(70, player.dx - 420).toDouble(),
        math.max(70, player.dy - 300).toDouble(),
      ),
      math.max(14, amount * 3.2).toDouble(),
    );
    screenShake = 14;
    _flash(
      'BANKRUPTCY FEE POSTED — defeat THE COLLECTOR before new credit opens.',
    );
    GameFeedback.heavyImpact();
  }

  void dash() {
    if (!canDash) {
      if (isPlaying) _flash('DASH IS NOT AVAILABLE.');
      return;
    }
    final direction = FutureDebtRules.dashVector(
      moveDirection: moveDirection,
      storedDirection: dashDirection,
      fireDirection: aimDirection,
    );
    final borrowed = dashCharges > 0;
    for (var index = 0; index < 12; index++) {
      if (borrowed) {
        player = _clampWorld(player + direction * 10, playerRadius);
        final wall = _wallAtCircle(player, playerRadius);
        if (wall != null) _damageWall(wall, 2.2, player);
      } else {
        player = _moveCircle(
          player,
          playerRadius,
          direction.dx * 8,
          direction.dy * 8,
        );
      }
    }
    invulnerable = .3;
    dashCooldown = borrowed ? .12 : 1.15;
    if (borrowed) dashCharges--;
    screenShake = 4;
    _burst(player, 18, _FutureParticleType.dash);
    GameFeedback.lightImpact();
  }

  void _fire() {
    if (isLocked(_DebtKind.shoot) || shotCooldown > 0) return;
    aimDirection = _aimWithAssist();
    final spread = shootBoost > 0 ? const [-.13, 0.0, .13] : const [0.0];
    for (final offset in spread) {
      final angle = math.atan2(aimDirection.dy, aimDirection.dx) + offset;
      final direction = Offset(math.cos(angle), math.sin(angle));
      _addPlayerShot(
        _FutureShot(
          player + direction * 25,
          direction * 610,
          radius: 4,
          damage: 1,
          charged: shootBoost > 0,
        ),
      );
    }
    shotCooldown = shootBoost > 0 ? .085 : .18;
    GameFeedback.shot();
    _burst(
      player + aimDirection * 25,
      shootBoost > 0 ? 7 : 2,
      shootBoost > 0 ? _FutureParticleType.compound : _FutureParticleType.spark,
    );
  }

  Offset _aimWithAssist() {
    final manualAim = aimDirection;
    Offset? bestDirection;
    var bestScore = double.negativeInfinity;
    final targets = <Offset>[
      ...enemies.where((enemy) => !enemy.dead).map((enemy) => enemy.position),
      ...echoes
          .where((echo) => !echo.dead && echo.type != _FutureEchoType.anchor)
          .map((echo) => echo.position),
      if (collector != null) collector!.position,
    ];
    for (final target in targets) {
      final vector = target - player;
      final distance = vector.distance;
      if (distance < 1) continue;
      final direction = vector / distance;
      if (!_hasClearShot(player, target)) continue;
      final alignment =
          manualAim.dx * direction.dx + manualAim.dy * direction.dy;
      // A pushed fire stick chooses the lane; a released stick acquires the
      // nearest target so holding FIRE remains useful while moving.
      if (_manualAimActive && alignment < .5) continue;
      final score = _manualAimActive
          ? alignment * 2 - distance / 1200
          : -distance / 1200;
      if (score > bestScore) {
        bestScore = score;
        bestDirection = direction;
      }
    }
    if (bestDirection == null) return manualAim;
    return _manualAimActive
        ? normalizedOr(
            manualAim * .68 + bestDirection * .32,
            fallback: manualAim,
          )
        : bestDirection;
  }

  bool _hasClearShot(Offset origin, Offset target) {
    final vector = target - origin;
    final distance = vector.distance;
    if (distance < 1) return true;
    final direction = vector / distance;
    for (final wall in walls) {
      if (wall.destructible && wall.health <= 0) continue;
      final hit = _rayRectDistance(origin, direction, wall.bounds.inflate(2));
      if (hit != null && hit > 0 && hit < distance) return false;
    }
    return true;
  }

  void _reconcileAfterPhase() {
    if (!_blocked(player, playerRadius)) return;
    // I search from the player's last position first so phasing through a
    // barricade never arbitrarily teleports a run across the whole map.
    for (var ring = 1; ring <= 8; ring++) {
      final radius = ring * 18.0;
      for (var step = 0; step < 16; step++) {
        final angle = step / 16 * math.pi * 2;
        final candidate = _clampWorld(
          player + Offset(math.cos(angle), math.sin(angle)) * radius,
          playerRadius,
        );
        if (!_blocked(candidate, playerRadius)) {
          player = candidate;
          _flash('GHOST WAGE EXPIRED — position reconciled outside the lien.');
          return;
        }
      }
    }
    player =
        _randomOpenPoint(player, minimumDistance: 0) ??
        const Offset(1515, 1010);
    _flash('GHOST WAGE EXPIRED — emergency relocation posted.');
  }

  bool _spawnEnemy({_FutureEnemyType? force}) {
    if (!_canSpawnClaim()) return false;
    var type = force ?? _FutureEnemyType.hound;
    final roll = _random.nextDouble();
    if (force == null) {
      if ((_plan.objective == _FutureObjectiveKind.reflectAudit || time > 10) &&
          roll > .5) {
        type = _FutureEnemyType.auditor;
      }
      if ((time > 24 || _plan.act > 0) && roll > .78) {
        type = _FutureEnemyType.interest;
      }
      if ((time > 46 || _plan.act > 1) && roll > .94) {
        type = _FutureEnemyType.bailiff;
      }
    }
    final radius = _enemyRadius(type);
    Offset position = const Offset(60, 60);
    var found = false;
    for (var attempt = 0; attempt < 30; attempt++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final distance = 560 + _random.nextDouble() * 650;
      position = _clampWorld(
        player + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius,
      );
      if (!_pointInWall(position, radius) &&
          (position - player).distance > 500 &&
          !portals.any(
            (portal) =>
                (position - portal.position).distance < portal.radius + radius,
          )) {
        found = true;
        break;
      }
    }
    if (!found) return false;
    enemies.add(_FutureEnemy(position, type, _random.nextBool() ? 1 : -1));
    return true;
  }

  void _updateShots(double dt) {
    for (final shot in shots) {
      shot.position += shot.velocity * dt;
      shot.life -= dt;
      if (shot.life <= 0) {
        shot.dead = true;
        continue;
      }
      final wall = _pointWall(shot.position, shot.radius);
      if (wall != null) {
        if (wall.destructible) {
          _damageWall(wall, shot.damage, shot.position);
        } else {
          _burst(shot.position, 3, _FutureParticleType.spark);
        }
        shot.dead = true;
        continue;
      }
      for (final enemy in enemies) {
        if (enemy.dead ||
            (enemy.position - shot.position).distance >=
                enemy.radius + shot.radius) {
          continue;
        }
        enemy.health -= shot.damage;
        _burst(shot.position, 5, _FutureParticleType.spark);
        shot.dead = true;
        if (enemy.health <= 0) _killEnemy(enemy);
        break;
      }
      if (shot.dead) continue;
      for (final echo in echoes) {
        if (echo.dead ||
            echo.type == _FutureEchoType.anchor ||
            (echo.position - shot.position).distance >=
                echo.radius + shot.radius) {
          continue;
        }
        _hitEcho(shot, echo);
        shot.dead = true;
        break;
      }
      if (shot.dead) continue;
      if (collector != null &&
          (collector!.position - shot.position).distance <
              collector!.radius + shot.radius) {
        collector!.health -= shot.damage * .35;
        _burst(shot.position, 3, _FutureParticleType.repay);
        shot.dead = true;
      }
    }
    shots.removeWhere((shot) => shot.dead);

    for (final shot in enemyShots) {
      shot.position += shot.velocity * dt;
      shot.life -= dt;
      if (shot.life <= 0 || _pointWall(shot.position, shot.radius) != null) {
        shot.dead = true;
      } else if ((shot.position - player).distance <
          shot.radius + playerRadius) {
        if (moveBoost > 0) {
          continue;
        }
        if (reversalBoost > 0) {
          _reverseShot(shot);
        } else {
          _hitPlayer(
            shot.type == _FutureShotType.echo ? 2.2 : 2.6,
            source: shot.position,
          );
        }
        shot.dead = true;
      }
    }
    enemyShots.removeWhere((shot) => shot.dead);
    enemies.removeWhere((enemy) => enemy.dead);
  }

  void _updateEnemies(double dt) {
    for (final enemy in enemies) {
      if (enemy.dead) continue;
      final vector = player - enemy.position;
      final distance = vector.distance;
      final angle = math.atan2(vector.dy, vector.dx);
      if (enemy.type == _FutureEnemyType.auditor) {
        final direction = distance < 240
            ? -1
            : distance > 390
            ? 1
            : 0;
        _tryMoveEnemy(
          enemy,
          math.cos(angle) * enemy.speed * direction * dt,
          math.sin(angle) * enemy.speed * direction * dt,
        );
        enemy.shotTimer -= dt;
        if (enemy.shotTimer <= 0 && distance < 520) {
          enemy.shotTimer = 1.45;
          _shootEnemy(enemy.position, angle, 230, 6, _FutureShotType.audit);
        }
      } else {
        _tryMoveEnemy(
          enemy,
          math.cos(angle) * enemy.speed * dt,
          math.sin(angle) * enemy.speed * dt,
        );
      }
      if (enemy.type == _FutureEnemyType.interest) {
        enemy.pulseTimer -= dt;
        if (enemy.pulseTimer <= 0 && distance < 180) {
          enemy.pulseTimer = 2.2;
          if (reversalBoost > 0) {
            _reflectDamage(enemy.position, .7);
          } else {
            lifetime -= .7;
            screenShake = math.max(screenShake, 3);
            _burst(player, 6, _FutureParticleType.gold);
            _flash('INTEREST LEECH — compounded away 0.7s of lifetime.');
          }
        }
      }
      if (distance < enemy.radius + playerRadius + 2) {
        _hitPlayer(
          enemy.type == _FutureEnemyType.bailiff
              ? 3.8
              : enemy.type == _FutureEnemyType.interest
              ? 2.4
              : 1.8,
          source: enemy.position,
        );
        _tryMoveEnemy(enemy, -math.cos(angle) * 30, -math.sin(angle) * 30);
      }
    }
  }

  void _tryMoveEnemy(_FutureEnemy enemy, double dx, double dy) {
    final original = enemy.position;
    enemy.position = _moveCircle(enemy.position, enemy.radius, dx, dy);
    if ((enemy.position - original).distance < .1) {
      final wall = _wallAtCircle(
        original + Offset(dx * 2, dy * 2),
        enemy.radius,
      );
      if (enemy.type == _FutureEnemyType.bailiff && wall != null) {
        _damageWall(wall, .08, original);
      }
      enemy.position = _moveCircle(
        enemy.position,
        enemy.radius,
        -dy * enemy.steer,
        dx * enemy.steer,
      );
    }
  }

  void _shootEnemy(
    Offset position,
    double angle,
    double speed,
    double radius,
    _FutureShotType type,
  ) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    _addEnemyShot(
      _FutureShot(
        position,
        direction * speed,
        radius: radius,
        damage: 0,
        type: type,
        life: 4,
      ),
    );
  }

  void _updateEchoes(double dt) {
    for (final echo in echoes) {
      if (echo.dead) continue;
      echo.life -= dt;
      final vector = player - echo.position;
      final distance = vector.distance;
      final angle = math.atan2(vector.dy, vector.dx);
      switch (echo.type) {
        case _FutureEchoType.runner:
          echo.position = _moveCircle(
            echo.position,
            echo.radius,
            math.cos(angle) * 185 * dt,
            math.sin(angle) * 185 * dt,
          );
          if (distance < echo.radius + playerRadius + 4) {
            _hitPlayer(1.6, source: echo.position);
            echo.position -= Offset(math.cos(angle), math.sin(angle)) * 40;
          }
        case _FutureEchoType.auditor:
          echo.shotTimer -= dt;
          if (echo.shotTimer <= 0) {
            echo.shotTimer = .85;
            _shootEnemy(echo.position, angle, 260, 5, _FutureShotType.echo);
          }
          if (distance > 340) {
            echo.position = _moveCircle(
              echo.position,
              echo.radius,
              math.cos(angle) * 65 * dt,
              math.sin(angle) * 65 * dt,
            );
          }
        case _FutureEchoType.anchor:
          break;
        case _FutureEchoType.claim:
          echo.position = _moveCircle(
            echo.position,
            echo.radius,
            math.cos(angle) * 105 * dt,
            math.sin(angle) * 105 * dt,
          );
          if (distance < echo.radius + playerRadius + 3) {
            if (reversalBoost > 0) {
              _reflectDamage(echo.position, echo.value);
            } else {
              lifetime -= echo.value;
              _burst(player, 26, _FutureParticleType.gold);
              echo.dead = true;
              locks[_DebtKind.life] = 0;
              screenShake = 13;
              _flash(
                'CLAIM COLLECTED — paid ${echo.value.toStringAsFixed(1)}s of borrowed life.',
              );
            }
          }
      }
      if (echo.life <= 0 && !echo.dead) {
        if (echo.type == _FutureEchoType.claim) {
          lifetime -= echo.value;
          locks[_DebtKind.life] = 0;
          echo.dead = true;
          _burst(echo.position, 26, _FutureParticleType.gold);
          _flash(
            'MATURITY CLAIM ENFORCED — paid ${echo.value.toStringAsFixed(1)}s of borrowed life.',
          );
        } else {
          _settleEcho(echo);
        }
      }
    }
    echoes.removeWhere((echo) => echo.dead);
  }

  void _updatePickups(double dt) {
    for (final pickup in pickups) {
      pickup.spin += dt * 3;
      if ((pickup.position - player).distance >=
          pickup.radius + playerRadius + 3) {
        continue;
      }
      switch (pickup.kind) {
        case _FuturePickupKind.time:
          _grantLifetime(3.5);
          score += 160;
          _flash('LIFE SHARD — +3.5s lifetime.');
        case _FuturePickupKind.writeoff:
          forgiveDebt(2);
        case _FuturePickupKind.ghost:
          moveBoost = math.max(moveBoost, 3.6);
          _flash('GHOST DROP — free wall phase and bullet slip.');
        case _FuturePickupKind.compound:
          shootBoost = math.max(shootBoost, 3.6);
          _flash('COMPOUND DROP — free overcharge.');
        case _FuturePickupKind.reverse:
          reversalBoost = math.max(reversalBoost, 3.6);
          _flash('REVERSE DROP — incoming fire rebounds.');
        case _FuturePickupKind.caseFile:
          recordsRecovered++;
          score += 240;
          _flash(
            'CASE FILE RECOVERED — $recordsRecovered / ${_plan.objectiveTarget} sealed records.',
          );
      }
      _burst(
        pickup.position,
        14,
        pickup.kind == _FuturePickupKind.time
            ? _FutureParticleType.borrow
            : pickup.kind == _FuturePickupKind.writeoff
            ? _FutureParticleType.gold
            : _FutureParticleType.compound,
      );
      GameFeedback.pickup();
      pickup.dead = true;
    }
    pickups.removeWhere((pickup) => pickup.dead);
  }

  void _updatePortals(double dt) {
    for (final portal in portals) {
      portal.phase += dt * (1.4 + portal.index * .14);
    }
    if (portalCooldown > 0) return;
    for (final portal in portals) {
      if ((portal.position - player).distance > portal.radius + playerRadius) {
        continue;
      }
      final destination = _randomOpenPoint(player, minimumDistance: 360);
      if (destination == null) return;
      final origin = player;
      player = destination;
      portalCooldown = .8;
      invulnerable = math.max(invulnerable, .35);
      screenShake = math.max(screenShake, 6);
      _burst(origin, 18, _FutureParticleType.portal);
      _burst(destination, 24, _FutureParticleType.portal);
      _flash('RIFT GATE — your repayment has been relocated.');
      GameFeedback.mediumImpact();
      return;
    }
  }

  void _openLevelExitIfReady() {
    if (_campaign == null || levelExitOpen || levelExitReached) return;
    if (score < scoreTarget || !objectiveComplete || hasOutstandingDebt) return;
    final position = _exitPortalPosition();
    levelExit = _FutureLevelExit(position);
    screenShake = math.max(screenShake, 8);
    _burst(position, 32, _FutureParticleType.gold);
    _flash('CASE CLOSED — no contracts remain. Enter the NEXT LEVEL GATE.');
    GameFeedback.heavyImpact();
  }

  Offset _exitPortalPosition() {
    final anchor = _plan.exitAnchor;
    if (!_pointInWall(anchor, _FutureLevelExit.portalRadius + 5) &&
        !portals.any(
          (portal) =>
              (anchor - portal.position).distance <
              portal.radius + _FutureLevelExit.portalRadius + 56,
        )) {
      return anchor;
    }
    for (var attempt = 0; attempt < 32; attempt++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final distance = 150 + _random.nextDouble() * 130;
      final candidate = _clampWorld(
        anchor + Offset(math.cos(angle), math.sin(angle)) * distance,
        _FutureLevelExit.portalRadius,
      );
      if (_pointInWall(candidate, _FutureLevelExit.portalRadius + 5) ||
          portals.any(
            (portal) =>
                (candidate - portal.position).distance <
                portal.radius + _FutureLevelExit.portalRadius + 56,
          )) {
        continue;
      }
      return candidate;
    }
    return _randomOpenPoint(anchor, minimumDistance: 120) ?? anchor;
  }

  void _updateLevelExit(double dt) {
    final exit = levelExit;
    if (exit == null || levelExitReached) return;
    exit.phase += dt * 2.2;
    if ((exit.position - player).distance > exit.radius + playerRadius) return;
    levelExitReached = true;
    screenShake = math.max(screenShake, 11);
    _burst(exit.position, 42, _FutureParticleType.gold);
    _flash('GATE CROSSED — ledger transferred to the next level.');
    GameFeedback.heavyImpact();
  }

  void _updateCollector(double dt) {
    if (collector == null) return;
    final target = collector!;
    final vector = player - target.position;
    final angle = math.atan2(vector.dy, vector.dx);
    target.position = _moveCircle(
      target.position,
      target.radius,
      math.cos(angle) * (88 + math.min(70, target.maxHealth)) * dt,
      math.sin(angle) * (88 + math.min(70, target.maxHealth)) * dt,
    );
    target.shotTimer -= dt;
    if (target.shotTimer <= 0) {
      target.shotTimer = 1.2;
      _shootEnemy(target.position, angle, 240, 7, _FutureShotType.collector);
    }
    if ((target.position - player).distance < target.radius + playerRadius) {
      _hitPlayer(4, source: target.position);
    }
    if (target.health <= 0) {
      score += 2800;
      _grantLifetime(6);
      collector = null;
      collectorSettled = true;
      _flash('COLLECTOR PAID OFF — +2800 and +6s lifetime.');
      GameFeedback.mediumImpact();
    }
  }

  void _hitEcho(_FutureShot shot, _FutureEcho echo) {
    echo.health -= shot.damage;
    _burst(
      shot.position,
      5,
      echo.type == _FutureEchoType.claim
          ? _FutureParticleType.gold
          : _FutureParticleType.debt,
    );
    if (echo.health > 0) return;
    score += echo.type == _FutureEchoType.claim ? 1000 : 350;
    if (echo.type == _FutureEchoType.claim) {
      _flash(
        'MATURITY CLAIM DESTROYED — escaped the big payment and recovered +2s.',
      );
    }
    _burst(
      echo.position,
      20,
      echo.type == _FutureEchoType.claim
          ? _FutureParticleType.gold
          : _FutureParticleType.debt,
    );
    _settleEcho(echo, recoveredClaim: echo.type == _FutureEchoType.claim);
  }

  void _settleEcho(_FutureEcho echo, {bool recoveredClaim = false}) {
    if (echo.dead) return;
    echo.dead = true;
    maturitiesSurvived++;
    if (echo.type == _FutureEchoType.claim) {
      locks[_DebtKind.life] = 0;
      if (recoveredClaim) _grantLifetime(2);
    }
  }

  void _killEnemy(_FutureEnemy enemy) {
    enemy.dead = true;
    claimsDefeated++;
    score += (enemy.value * _plan.rewardMultiplier).round();
    _grantLifetime(
      (enemy.type == _FutureEnemyType.bailiff
              ? 3.6
              : enemy.type == _FutureEnemyType.interest
              ? 2.4
              : 1.2) *
          _plan.rewardMultiplier,
    );
    _burst(
      enemy.position,
      enemy.type == _FutureEnemyType.bailiff ? 28 : 14,
      enemy.type == _FutureEnemyType.interest
          ? _FutureParticleType.gold
          : _FutureParticleType.kill,
    );
    _dropEnemyReward(enemy);
    if (enemy.type == _FutureEnemyType.interest && _random.nextDouble() < .35) {
      _addPickup(_FuturePickup(enemy.position, _FuturePickupKind.writeoff, 0));
    }
  }

  void _dropEnemyReward(_FutureEnemy enemy) {
    final lifeChance = switch (enemy.type) {
      _FutureEnemyType.hound => .42,
      _FutureEnemyType.auditor => .55,
      _FutureEnemyType.interest => .7,
      _FutureEnemyType.bailiff => .9,
    };
    final powerChance = switch (enemy.type) {
      _FutureEnemyType.hound => .12,
      _FutureEnemyType.auditor => .24,
      _FutureEnemyType.interest => .32,
      _FutureEnemyType.bailiff => .55,
    };
    if (_random.nextDouble() < lifeChance) {
      _addPickup(
        _FuturePickup(
          enemy.position + const Offset(10, 0),
          _FuturePickupKind.time,
          _random.nextDouble() * 6,
        ),
      );
    }
    if (_random.nextDouble() < powerChance * .65) {
      final power = [
        _FuturePickupKind.ghost,
        _FuturePickupKind.compound,
        _FuturePickupKind.reverse,
      ][_random.nextInt(3)];
      _addPickup(
        _FuturePickup(
          enemy.position + const Offset(-10, 0),
          power,
          _random.nextDouble() * 6,
        ),
      );
    }
  }

  void _damageWall(_FutureWall wall, double amount, Offset point) {
    if (!wall.destructible || wall.health <= 0) return;
    wall.health -= amount;
    _burst(
      point,
      5,
      wall.secret ? _FutureParticleType.gold : _FutureParticleType.wall,
    );
    if (wall.health > 0) return;
    wall.health = 0;
    wallsBreached++;
    screenShake = math.max(screenShake, 7);
    _burst(
      wall.bounds.center,
      wall.secret ? 32 : 18,
      wall.secret ? _FutureParticleType.gold : _FutureParticleType.wall,
    );
    score += wall.secret ? 420 : 70;
    if (wall.secret || _random.nextDouble() < .22) {
      _addPickup(
        _FuturePickup(
          wall.bounds.center,
          wall.secret ? _FuturePickupKind.writeoff : _FuturePickupKind.time,
          _random.nextDouble() * 6,
        ),
      );
    }
  }

  void _reverseShot(_FutureShot shot) {
    _addPlayerShot(
      _FutureShot(
        shot.position,
        -shot.velocity * 1.45,
        radius: shot.radius,
        damage: shot.type == _FutureShotType.echo ? 2.2 : 2.6,
        life: math.min(1.7, shot.life),
        charged: true,
      ),
    );
    if (shot.type == _FutureShotType.audit ||
        shot.type == _FutureShotType.echo) {
      auditReturns++;
      _flash(
        'AUDIT RETURN POSTED — $auditReturns / ${_plan.objectiveTarget} shots returned.',
      );
    }
    invulnerable = .18;
    _burst(player, 10, _FutureParticleType.compound);
  }

  void _hitPlayer(double amount, {Offset? source}) {
    if (invulnerable > 0) return;
    if (reversalBoost > 0) {
      invulnerable = .22;
      _reflectDamage(source, amount);
      return;
    }
    lifetime -= amount;
    invulnerable = .6;
    screenShake = 9;
    _burst(player, 16, _FutureParticleType.hit);
    GameFeedback.lightImpact();
  }

  void _reflectDamage(Offset? source, double amount) {
    if (source == null) return;
    final reflectedDamage = amount * 1.7;
    for (final enemy in enemies) {
      if (enemy.dead ||
          (enemy.position - source).distance > enemy.radius + 34) {
        continue;
      }
      enemy.health -= reflectedDamage;
      _burst(enemy.position, 10, _FutureParticleType.compound);
      if (enemy.health <= 0) _killEnemy(enemy);
      return;
    }
    for (final echo in echoes) {
      if (echo.dead || (echo.position - source).distance > echo.radius + 34) {
        continue;
      }
      echo.health -= reflectedDamage;
      _burst(echo.position, 10, _FutureParticleType.compound);
      if (echo.health <= 0) {
        score += echo.type == _FutureEchoType.claim ? 1000 : 350;
        _settleEcho(echo, recoveredClaim: echo.type == _FutureEchoType.claim);
      }
      return;
    }
    if (collector != null &&
        (collector!.position - source).distance <= collector!.radius + 34) {
      collector!.health -= reflectedDamage;
      _burst(collector!.position, 12, _FutureParticleType.compound);
    }
  }

  void _updateParticles(double dt) {
    for (final particle in particles) {
      particle.age += dt;
      particle.position += particle.velocity * dt;
      particle.velocity *= .94;
    }
    particles.removeWhere((particle) => particle.age >= particle.life);
  }

  void _emitMovementTrail(double dt) {
    movementTrailTimer -= dt;
    if (movementTrailTimer > 0) return;
    movementTrailTimer = moveBoost > 0 ? .035 : .075;
    final side = Offset(-moveDirection.dy, moveDirection.dx);
    final count = moveBoost > 0 ? 2 : 1;
    for (var index = 0; index < count; index++) {
      _addParticle(
        _FutureParticle(
          player - moveDirection * (9 + _random.nextDouble() * 8),
          -moveDirection * (42 + _random.nextDouble() * 65) +
              side * ((_random.nextDouble() - .5) * 34),
          _FutureParticleType.trail,
          .24 + _random.nextDouble() * .18,
          1.6 + _random.nextDouble() * 1.7,
        ),
      );
    }
  }

  void _burst(Offset position, int count, _FutureParticleType type) {
    for (var index = 0; index < count; index++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 45 + _random.nextDouble() * 210;
      _addParticle(
        _FutureParticle(
          position,
          Offset(math.cos(angle), math.sin(angle)) * speed,
          type,
          .3 + _random.nextDouble() * .65,
          2 + _random.nextDouble() * 3,
        ),
      );
    }
  }

  void _addParticle(_FutureParticle particle) {
    // Effects are cosmetic. Keeping them bounded prevents a dense fight from
    // making the renderer catch up on hundreds of expired sparks at once.
    if (particles.length >= _maxParticles) particles.removeAt(0);
    particles.add(particle);
  }

  void _flash(String text) => message = text;

  void _gameOver() {
    if (phase == _FuturePhase.dead) return;
    phase = _FuturePhase.dead;
    final rating = bankruptcies == 0 && totalBorrowed < 15
        ? 'AAA'
        : bankruptcies < 2 && totalBorrowed < 42
        ? 'B'
        : 'D-';
    message =
        'Score ${score.floor()} · form $formName · borrowed ${totalBorrowed.toStringAsFixed(1)}s · rating $rating';
    GameFeedback.heavyImpact();
  }

  void _followCamera({double dt = 0, bool immediate = false}) {
    final target = Offset(
      (player.dx - width / 2).clamp(0.0, worldWidth - width).toDouble(),
      (player.dy - height / 2).clamp(0.0, worldHeight - height).toDouble(),
    );
    camera = immediate
        ? target
        : camera + (target - camera) * math.min(1, dt * 7.5);
  }

  Offset _moveCircle(Offset position, double radius, double dx, double dy) {
    var result = position + Offset(dx, 0);
    if (_blocked(result, radius)) result = position;
    final vertical = result + Offset(0, dy);
    if (!_blocked(vertical, radius)) result = vertical;
    return _clampWorld(result, radius);
  }

  Offset _clampWorld(Offset position, double radius) => Offset(
    position.dx.clamp(radius + 34, worldWidth - radius - 34).toDouble(),
    position.dy.clamp(radius + 34, worldHeight - radius - 34).toDouble(),
  );

  bool _blocked(Offset position, double radius) => walls.any(
    (wall) =>
        (!wall.destructible || wall.health > 0) &&
        _circleHitsRect(position, radius, wall.bounds),
  );

  _FutureWall? _wallAtCircle(Offset position, double radius) {
    for (final wall in walls) {
      if (wall.destructible &&
          wall.health > 0 &&
          _circleHitsRect(position, radius, wall.bounds)) {
        return wall;
      }
    }
    return null;
  }

  _FutureWall? _pointWall(Offset point, double radius) {
    for (final wall in walls) {
      if ((!wall.destructible || wall.health > 0) &&
          Rect.fromLTWH(
            wall.bounds.left - radius,
            wall.bounds.top - radius,
            wall.bounds.width + radius * 2,
            wall.bounds.height + radius * 2,
          ).contains(point)) {
        return wall;
      }
    }
    return null;
  }

  bool _pointInWall(Offset point, double radius) =>
      _pointWall(point, radius) != null;

  /// Returns the first blocking wall along a flashlight ray. The painter uses
  /// this rather than a circular light mask so the beam finishes at walls.
  double _flashlightRayDistance(
    Offset origin,
    double angle,
    double maximumDistance,
  ) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    var closest = maximumDistance;
    for (final wall in walls) {
      if (wall.destructible && wall.health <= 0) continue;
      final hit = _rayRectDistance(origin, direction, wall.bounds.inflate(1));
      if (hit != null && hit >= 0 && hit < closest) closest = hit;
    }
    return closest;
  }

  double? _rayRectDistance(Offset origin, Offset direction, Rect rect) {
    var enter = 0.0;
    var exit = double.infinity;

    bool clip(
      double originAxis,
      double directionAxis,
      double low,
      double high,
    ) {
      if (directionAxis.abs() < .000001) {
        return originAxis >= low && originAxis <= high;
      }
      final near = (low - originAxis) / directionAxis;
      final far = (high - originAxis) / directionAxis;
      enter = math.max(enter, math.min(near, far)).toDouble();
      exit = math.min(exit, math.max(near, far)).toDouble();
      return enter <= exit;
    }

    if (!clip(origin.dx, direction.dx, rect.left, rect.right) ||
        !clip(origin.dy, direction.dy, rect.top, rect.bottom) ||
        exit < 0) {
      return null;
    }
    return enter >= 0 ? enter : exit;
  }

  /// Finds a destination the player can occupy, away from the portal entrance
  /// and every gate so a transit cannot immediately loop into another transit.
  Offset? _randomOpenPoint(Offset origin, {required double minimumDistance}) {
    for (var attempt = 0; attempt < 96; attempt++) {
      final candidate = Offset(
        playerRadius +
            48 +
            _random.nextDouble() * (worldWidth - 2 * (playerRadius + 48)),
        playerRadius +
            48 +
            _random.nextDouble() * (worldHeight - 2 * (playerRadius + 48)),
      );
      if ((candidate - origin).distance < minimumDistance ||
          _pointInWall(candidate, playerRadius + 5) ||
          portals.any(
            (portal) =>
                (candidate - portal.position).distance <
                portal.radius + playerRadius + 64,
          ) ||
          enemies.any(
            (enemy) =>
                !enemy.dead &&
                (candidate - enemy.position).distance < enemy.radius + 90,
          ) ||
          echoes.any(
            (echo) =>
                !echo.dead &&
                (candidate - echo.position).distance < echo.radius + 90,
          ) ||
          (collector != null &&
              (candidate - collector!.position).distance <
                  collector!.radius + 120)) {
        continue;
      }
      return candidate;
    }
    return null;
  }

  bool _circleHitsRect(Offset center, double radius, Rect rect) {
    final nearest = Offset(
      center.dx.clamp(rect.left, rect.right).toDouble(),
      center.dy.clamp(rect.top, rect.bottom).toDouble(),
    );
    return (center - nearest).distanceSquared < radius * radius;
  }

  void _buildMaze() {
    walls.clear();
    pickups.clear();
    portals.clear();
    _addWall(0, 0, worldWidth, 32, hp: 9999, destructible: false);
    _addWall(
      0,
      worldHeight - 32,
      worldWidth,
      32,
      hp: 9999,
      destructible: false,
    );
    _addWall(0, 0, 32, worldHeight, hp: 9999, destructible: false);
    _addWall(
      worldWidth - 32,
      0,
      32,
      worldHeight,
      hp: 9999,
      destructible: false,
    );
    _room(120, 120, 720, 510, 'es');
    _room(1030, 120, 720, 520, 'ws');
    _room(1990, 140, 760, 500, 'ws');
    _room(260, 760, 700, 540, 'ne');
    _room(1120, 720, 790, 590, 'nesw');
    _room(2070, 770, 700, 540, 'nw');
    _room(540, 1440, 760, 330, 'ne');
    _room(1660, 1420, 800, 350, 'nw');
    for (final data in const [
      [880.0, 230, 30, 280],
      [880, 590, 30, 190],
      [915, 660, 280, 30],
      [1810, 250, 30, 290],
      [1810, 615, 30, 215],
      [1850, 675, 300, 30],
      [1010, 1010, 150, 30],
      [1920, 985, 180, 30],
      [1360, 1305, 30, 205],
      [1540, 1290, 30, 220],
      [390, 1345, 390, 30],
      [2390, 1340, 260, 30],
    ]) {
      _addWall(
        data[0].toDouble(),
        data[1].toDouble(),
        data[2].toDouble(),
        data[3].toDouble(),
      );
    }
    for (var index = 0; index < _coverWalls.length; index++) {
      final data = _coverWalls[index];
      _addWall(
        data[0].toDouble(),
        data[1].toDouble(),
        data[2].toDouble(),
        data[3].toDouble(),
        hp: index % 3 == 0 ? 7 : 6,
      );
    }
    for (final data in const [
      [785.0, 235, 30, 130],
      [1680, 505, 150, 30],
      [2100, 1250, 160, 30],
      [1080, 1490, 30, 160],
      [2320, 1500, 30, 150],
    ]) {
      _addWall(
        data[0].toDouble(),
        data[1].toDouble(),
        data[2].toDouble(),
        data[3].toDouble(),
        hp: 12,
        secret: true,
      );
    }
    for (final pickup in [
      _FuturePickup(const Offset(470, 480), _FuturePickupKind.time, 0),
      _FuturePickup(const Offset(1350, 420), _FuturePickupKind.time, 1),
      _FuturePickup(const Offset(2340, 1020), _FuturePickupKind.writeoff, 2),
      _FuturePickup(const Offset(810, 1600), _FuturePickupKind.time, 3),
      _FuturePickup(const Offset(1980, 1580), _FuturePickupKind.writeoff, 4),
    ]) {
      _addPickup(pickup);
    }
    if (_plan.objective == _FutureObjectiveKind.recoverRecords) {
      const recordAnchors = [
        Offset(720, 280),
        Offset(1480, 530),
        Offset(2290, 460),
        Offset(520, 1070),
        Offset(1740, 1510),
      ];
      for (var index = 0; index < _plan.objectiveTarget; index++) {
        _addPickup(
          _FuturePickup(
            recordAnchors[index % recordAnchors.length],
            _FuturePickupKind.caseFile,
            10 + index.toDouble(),
          ),
        );
      }
    }
    _addCampaignGeometry();
    for (final position in const [
      Offset(290, 220),
      Offset(1700, 840),
      Offset(2500, 850),
      Offset(840, 1660),
    ]) {
      _addPortal(position);
    }
  }

  void _addPortal(Offset preferredPosition) {
    final position = _pointInWall(preferredPosition, portalRadius + 5)
        ? _randomOpenPoint(preferredPosition, minimumDistance: 0)
        : preferredPosition;
    if (position != null) {
      portals.add(_FuturePortal(position, portals.length));
    }
  }

  void _addCampaignGeometry() {
    final random = math.Random(_layoutSeed);
    // Each campaign seed lays down a fresh set of destructible barricades
    // inside the rooms, instead of merely adding a few walls to one layout.
    final targetWallCount = 7 + _plan.act * 3 + _campaignLevel ~/ 3;
    var placed = 0;
    var attempts = 0;
    while (placed < targetWallCount && attempts < targetWallCount * 28) {
      attempts++;
      final zone = zones[random.nextInt(zones.length)];
      final horizontal = random.nextBool();
      const thickness = 28.0;
      final maximumLength =
          (horizontal ? zone.bounds.width : zone.bounds.height) - 190;
      final length =
          86 +
          random.nextDouble() * math.max(1, math.min(190, maximumLength - 86));
      final wallWidth = horizontal ? length : thickness;
      final wallHeight = horizontal ? thickness : length;
      final x =
          zone.bounds.left +
          76 +
          random.nextDouble() * (zone.bounds.width - 152 - wallWidth);
      final y =
          zone.bounds.top +
          76 +
          random.nextDouble() * (zone.bounds.height - 152 - wallHeight);
      final candidate = Rect.fromLTWH(x, y, wallWidth, wallHeight);
      if ((candidate.center - const Offset(1515, 1010)).distance < 210 ||
          pickups.any(
            (pickup) => (pickup.position - candidate.center).distance < 92,
          ) ||
          walls.any((wall) => wall.bounds.inflate(24).overlaps(candidate))) {
        continue;
      }
      _addWall(
        x,
        y,
        wallWidth,
        wallHeight,
        hp: 4 + random.nextInt(6).toDouble(),
      );
      placed++;
    }
    final extraPickups = 1 + _campaignLevel ~/ 5;
    for (var index = 0; index < extraPickups; index++) {
      final point = Offset(
        130 + random.nextDouble() * (worldWidth - 260),
        130 + random.nextDouble() * (worldHeight - 260),
      );
      if (_pointInWall(point, 12)) continue;
      _addPickup(
        _FuturePickup(
          point,
          index.isEven ? _FuturePickupKind.time : _FuturePickupKind.writeoff,
          20 + index.toDouble(),
        ),
      );
    }
  }

  static const _coverWalls = [
    [350.0, 320, 210, 30],
    [620, 450, 30, 120],
    [1220, 315, 240, 30],
    [1500, 245, 30, 130],
    [2180, 340, 210, 30],
    [2440, 440, 30, 110],
    [500, 930, 230, 30],
    [740, 1040, 30, 130],
    [1280, 930, 270, 30],
    [1510, 1060, 30, 125],
    [2200, 960, 220, 30],
    [2460, 1070, 30, 120],
    [700, 1540, 210, 30],
    [1850, 1530, 250, 30],
  ];

  void _room(double x, double y, double w, double h, String doors) {
    const thickness = 30.0;
    const gap = 120.0;
    void horizontal(double yy, bool gapInWall) {
      if (!gapInWall) {
        _addWall(x, yy, w, thickness);
        return;
      }
      _addWall(x, yy, w / 2 - gap / 2, thickness);
      _addWall(x + w / 2 + gap / 2, yy, w / 2 - gap / 2, thickness);
    }

    void vertical(double xx, bool gapInWall) {
      if (!gapInWall) {
        _addWall(xx, y, thickness, h);
        return;
      }
      _addWall(xx, y, thickness, h / 2 - gap / 2);
      _addWall(xx, y + h / 2 + gap / 2, thickness, h / 2 - gap / 2);
    }

    horizontal(y, doors.contains('n'));
    horizontal(y + h - thickness, doors.contains('s'));
    vertical(x, doors.contains('w'));
    vertical(x + w - thickness, doors.contains('e'));
  }

  void _addWall(
    double x,
    double y,
    double w,
    double h, {
    double hp = 8,
    bool destructible = true,
    bool secret = false,
  }) {
    walls.add(
      _FutureWall(
        Rect.fromLTWH(x, y, w, h),
        hp: hp,
        destructible: destructible,
        secret: secret,
      ),
    );
  }

  static double _enemyRadius(_FutureEnemyType type) => switch (type) {
    _FutureEnemyType.hound => 12,
    _FutureEnemyType.auditor => 15,
    _FutureEnemyType.interest => 14,
    _FutureEnemyType.bailiff => 22,
  };
}

class _FutureZone {
  const _FutureZone(this.bounds, this.name, this.mark);
  final Rect bounds;
  final String name;
  final String mark;
}

class _FutureWall {
  _FutureWall(
    this.bounds, {
    required double hp,
    required this.destructible,
    required this.secret,
  }) : health = hp,
       maxHealth = hp;
  final Rect bounds;
  final bool destructible;
  final bool secret;
  final double maxHealth;
  double health;
}

class _FuturePickup {
  _FuturePickup(this.position, this.kind, this.spin);
  final Offset position;
  final _FuturePickupKind kind;
  double spin;
  final double radius = 9;
  bool dead = false;
}

class _FuturePortal {
  _FuturePortal(this.position, this.index);
  final Offset position;
  final int index;
  final double radius = _FutureDebtGame.portalRadius;
  double phase = 0;
}

class _FutureLevelExit {
  _FutureLevelExit(this.position);
  static const portalRadius = 32.0;
  final Offset position;
  final double radius = portalRadius;
  double phase = 0;
}

class _FutureBill {
  _FutureBill(this.kind, this.duration, this.due, this.origin);
  final _DebtKind kind;
  double duration;
  final double due;
  final Offset origin;
}

class _FutureEnemy {
  _FutureEnemy(this.position, this.type, this.steer)
    : health = switch (type) {
        _FutureEnemyType.hound => 2,
        _FutureEnemyType.auditor => 4,
        _FutureEnemyType.interest => 5,
        _FutureEnemyType.bailiff => 13,
      };
  Offset position;
  final _FutureEnemyType type;
  final double steer;
  double health;
  double shotTimer = .8;
  double pulseTimer = 1.8;
  bool dead = false;
  double get maxHealth => switch (type) {
    _FutureEnemyType.hound => 2,
    _FutureEnemyType.auditor => 4,
    _FutureEnemyType.interest => 5,
    _FutureEnemyType.bailiff => 13,
  };
  double get radius => _FutureDebtGame._enemyRadius(type);
  double get speed => switch (type) {
    _FutureEnemyType.hound => 125,
    _FutureEnemyType.auditor => 78,
    _FutureEnemyType.interest => 92,
    _FutureEnemyType.bailiff => 66,
  };
  int get value => switch (type) {
    _FutureEnemyType.hound => 120,
    _FutureEnemyType.auditor => 220,
    _FutureEnemyType.interest => 340,
    _FutureEnemyType.bailiff => 950,
  };
}

class _FutureEcho {
  _FutureEcho(
    this.type,
    this.position, {
    required this.radius,
    required this.health,
    required this.life,
    this.value = 0,
  }) : maxHealth = health;
  final _FutureEchoType type;
  Offset position;
  final double radius;
  final double maxHealth;
  double health;
  double life;
  final double value;
  double shotTimer = .35;
  bool dead = false;
}

class _FutureShot {
  _FutureShot(
    this.position,
    this.velocity, {
    required this.radius,
    required this.damage,
    this.type = _FutureShotType.player,
    this.life = 1.55,
    this.charged = false,
  });
  Offset position;
  final Offset velocity;
  final double radius;
  final double damage;
  final _FutureShotType type;
  final bool charged;
  double life;
  bool dead = false;
}

class _FutureCollector {
  _FutureCollector(this.position, double health)
    : health = health,
      maxHealth = health;
  Offset position;
  final double radius = 24;
  double health;
  final double maxHealth;
  double shotTimer = 1;
}

class _FutureParticle {
  _FutureParticle(
    this.position,
    this.velocity,
    this.type,
    this.life,
    this.size,
  );
  Offset position;
  Offset velocity;
  final _FutureParticleType type;
  final double life;
  final double size;
  double age = 0;
}
