part of 'future_debt_game.dart';

enum _FuturePhase { intro, playing, dead }

enum _DebtKind { move, dash }

enum _FutureEnemyType { hound, auditor, interest, bailiff }

enum _FutureEchoType { runner, anchor }

enum _FuturePickupKind { time, writeoff, compound, cashOut, caseFile }

enum _FutureShotType { player, audit, collector }

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
  static const maturitySeconds = 5.0;

  /// The amount of arena visible at a uniform scale, without letterboxing.
  static Size arenaView(Size surface) {
    if (surface.isEmpty) return Size.zero;
    final aspect = surface.width / surface.height;
    final portraitAmount = ((1.25 - aspect) / .75).clamp(0.0, 1.0);
    final height = _FutureDebtGame.height + 160 * portraitAmount;
    final scale = math.max(
      surface.height / height,
      surface.width / _FutureDebtGame.worldWidth,
    );
    return Size(surface.width / scale, surface.height / scale);
  }

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

  static double dashTravelFraction(double progress) {
    final t = progress.clamp(0.0, 1.0);
    return t + .30 * t * (1 - t);
  }

  /// First point of contact along a step, expressed as a fraction of it.
  static double? sweptCircleImpact(
    Offset origin,
    Offset step,
    Offset target,
    double radius,
  ) {
    final relative = origin - target;
    final separation = relative.distanceSquared - radius * radius;
    if (separation <= 0) return 0;
    final lengthSquared = step.distanceSquared;
    final along = relative.dx * step.dx + relative.dy * step.dy;
    if (lengthSquared <= gameEpsilon || along >= 0) return null;
    final discriminant = along * along - lengthSquared * separation;
    if (discriminant < 0) return null;
    final impact = (-along - math.sqrt(discriminant)) / lengthSquared;
    return impact <= 1 ? impact : null;
  }

  /// Sweeps a shot's round footprint against flat faces and rounded corners.
  static double? sweptCoverImpact(
    Offset origin,
    Offset step,
    Rect cover,
    double radius,
  ) {
    final broadHit = _rayRectDistance(origin, step, cover.inflate(radius));
    if (broadHit == null || broadHit > 1) return null;
    final vertical = Rect.fromLTRB(
      cover.left,
      cover.top - radius,
      cover.right,
      cover.bottom + radius,
    );
    final horizontal = Rect.fromLTRB(
      cover.left - radius,
      cover.top,
      cover.right + radius,
      cover.bottom,
    );
    var closest = math.min(
      _rayRectDistance(origin, step, vertical) ?? double.infinity,
      _rayRectDistance(origin, step, horizontal) ?? double.infinity,
    );
    for (final corner in [
      cover.topLeft,
      cover.topRight,
      cover.bottomLeft,
      cover.bottomRight,
    ]) {
      final hit = sweptCircleImpact(origin, step, corner, radius);
      if (hit != null && hit < closest) closest = hit;
    }
    return closest <= 1 ? closest : null;
  }
}

class _FutureDebtGame {
  static const musicTheme = 'ember_current';
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
  static const _dashDuration = .12;

  final GeneratedGameLevel? _campaign;
  final _FutureDebtCasePlan _plan;
  final int _campaignLevel;
  final int _layoutSeed;
  _FutureDebtPace _pace = _FutureDebtPace.standard;
  late math.Random _random;
  final walls = <_FutureWall>[];
  final arenaBlocks = <_ArenaBlock>[];
  final arenaTurf = <Rect>[];
  final arenaGroves = <_ArenaGrove>[];
  final pickups = <_FuturePickup>[];
  final enemies = <_FutureEnemy>[];
  final portals = <_FuturePortal>[];
  final shots = <_FutureShot>[];
  final enemyShots = <_FutureShot>[];
  final particles = <_FutureParticle>[];
  final pulses = <_FuturePowerPulse>[];
  final ghostTrail = <({Offset position, double time})>[];
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
  Offset cameraCenter = Offset.zero;
  Offset moveDirection = Offset.zero;
  Offset velocity = Offset.zero;
  Offset aimDirection = const Offset(1, 0);
  Offset dashDirection = const Offset(1, 0);
  Offset _dashTravelDirection = Offset.zero;
  Offset dashOrigin = Offset.zero;
  Offset? _lastClearGhostPosition;
  double dashRemaining = 0;
  bool _borrowedDash = false;
  double lastShotAt = double.negativeInfinity;
  double lastHitAt = double.negativeInfinity;
  double stride = 0;
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
  bool get totalDefaultActive => _totalDefaultTime > 0;
  bool get hasAnyLock =>
      totalDefaultActive || locks.values.any((value) => value > 0);
  bool get hasCollector => collector != null;
  bool get canBankrupt => isPlaying && !hasCollector && debtAmount >= .15;
  bool get levelExitOpen => levelExit != null;
  bool get canDash =>
      isPlaying &&
      !isLocked(_DebtKind.dash) &&
      dashCooldown <= 0 &&
      dashRemaining <= 0;
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
      totalDefaultActive ||
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
    if (borrowBoostRemaining(kind) > 0) return true;
    final type = _echoFor(kind);
    return echoes.any((echo) => !echo.dead && echo.type == type);
  }

  double borrowBoostRemaining(_DebtKind kind) =>
      kind == _DebtKind.move ? moveBoost : reversalBoost;

  _FutureEchoType _echoFor(_DebtKind kind) =>
      kind == _DebtKind.move ? _FutureEchoType.runner : _FutureEchoType.anchor;

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
      locks.values.fold(0.0, (sum, value) => sum + value) +
      _totalDefaultTime;

  String get formName {
    if (totalDefaultActive) return 'DEFAULT';
    if (hasCollector) return 'IN COLLECTION';
    if (hasAnyLock) return 'SEIZED';
    if (bills.length > 1) return 'OVERDRAWN';
    return hasOutstandingDebt ? 'LEVERAGED' : 'PRIME';
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
    cameraCenter = player;
    moveDirection = Offset.zero;
    velocity = Offset.zero;
    aimDirection = const Offset(1, 0);
    dashDirection = const Offset(1, 0);
    dashOrigin = player;
    dashRemaining = 0;
    _borrowedDash = false;
    _lastClearGhostPosition = null;
    lastShotAt = double.negativeInfinity;
    lastHitAt = double.negativeInfinity;
    stride = 0;
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
    pulses.clear();
    ghostTrail.clear();
    echoes.clear();
    collector = null;
    levelExit = null;
    levelExitReached = false;
    for (final kind in _DebtKind.values) {
      locks[kind] = 0;
    }
    _buildMaze();
    _followCamera(immediate: true);
    _flash(caseInstruction);
    GameFeedback.selection();
  }

  void cancelTransientInput() {
    moveDirection = Offset.zero;
    velocity = Offset.zero;
  }

  void setPace(_FutureDebtPace pace) {
    if (phase != _FuturePhase.intro) return;
    _pace = pace;
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
    }
    if (_defaultWasActive && !totalDefaultActive) {
      score += 900 + _plan.act * 180;
      _flash('DEFAULT SURVIVED — settlement bonus posted.');
      _defaultWasActive = false;
    }
    if (ghostWasActive && moveBoost == 0) _reconcileAfterPhase();
    _collectDueBills();
    _openLevelExitIfReady();

    if (dashRemaining > 0) {
      _advanceDash(dt);
    } else {
      _advancePlayer(dt, input);
    }
    _updatePortals(dt);
    if (moveBoost > 0 && !_blocked(player, playerRadius)) {
      _lastClearGhostPosition = player;
    }
    ghostTrail.removeWhere((frame) => time - frame.time > .28);
    if (moveBoost > 0 &&
        (ghostTrail.isEmpty ||
            (ghostTrail.last.position - player).distanceSquared >= 14 * 14)) {
      if (ghostTrail.length >= 7) ghostTrail.removeAt(0);
      ghostTrail.add((position: player, time: time));
    }
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
    const maturity = FutureDebtRules.maturitySeconds;
    final interest = FutureDebtRules.interestForDelay(maturity);
    final amount = kind == _DebtKind.move ? 1.7 : 1.5;
    switch (kind) {
      case _DebtKind.move:
        moveBoost = 2.4;
        _lastClearGhostPosition = player;
        _powerPulse(player, const Color(0xFF9DEDF4), 52);
        _flash('GHOST WAGE — phase through walls and hostile bullets.');
      case _DebtKind.dash:
        reversalBoost = 2.4;
        _powerPulse(player, _futureLilac, 56);
        _flash('REVERSE PAYMENT — hostile bullets and damage rebound.');
    }
    bills.add(_FutureBill(kind, amount * interest, time + maturity, player));
    totalBorrowed += amount;
    _burst(player, 13, _FutureParticleType.borrow);
    GameFeedback.selection();
  }

  void _collectDueBills() {
    for (var index = bills.length - 1; index >= 0; index--) {
      final bill = bills[index];
      if (bill.due > time) continue;
      bills.removeAt(index);
      _applyBill(bill);
    }
    if (_plan.act >= 2 &&
        !totalDefaultActive &&
        locks.values.every((value) => value > 0)) {
      _totalDefaultTime = locks.values.reduce(math.max);
      for (final kind in _DebtKind.values) {
        locks[kind] = 0;
      }
      defaults++;
      _defaultWasActive = true;
      screenShake = 12;
      _flash('TOTAL DEFAULT — all controls seized.');
      GameFeedback.heavyImpact();
    }
  }

  void _applyBill(_FutureBill bill) {
    locks[bill.kind] = math.max(locks[bill.kind]!, bill.duration);
    totalRepaid += bill.duration;
    final type = _echoFor(bill.kind);
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
      'DEBT MATURED — ${bill.kind.name.toUpperCase()} temporarily seized.',
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
    _defaultWasActive = false;
    for (final kind in _DebtKind.values) {
      locks[kind] = 0;
    }
    if (moveBoost > 0) {
      moveBoost = 0;
      _reconcileAfterPhase();
    }
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
    _borrowedDash = dashCharges > 0;
    if (_borrowedDash) dashCharges--;
    dashOrigin = player;
    _dashTravelDirection = direction;
    dashRemaining = _dashDuration;
    velocity = Offset.zero;
    invulnerable = math.max(invulnerable, _dashDuration + .3);
    dashCooldown = _dashDuration + (_borrowedDash ? .12 : 1.15);
    _burst(player, 8, _FutureParticleType.dash);
    _powerPulse(player, _futureGold, 36, direction: -direction);
    GameFeedback.lightImpact();
  }

  void _fire() {
    if (totalDefaultActive || shotCooldown > 0) return;
    aimDirection = _aimWithAssist();
    final spread = shootBoost > 0 ? const [-.13, 0.0, .13] : const [0.0];
    for (final offset in spread) {
      final angle = math.atan2(aimDirection.dy, aimDirection.dx) + offset;
      final direction = Offset(math.cos(angle), math.sin(angle));
      _addPlayerShot(
        _FutureShot(
          player + direction * (playerRadius - 4),
          direction * 610,
          radius: 4,
          damage: 1,
          charged: shootBoost > 0,
        ),
      );
    }
    lastShotAt = time;
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
      if (hit != null && hit < distance) return false;
    }
    return true;
  }

  void _reconcileAfterPhase() {
    final lastClear = _lastClearGhostPosition;
    _lastClearGhostPosition = null;
    if (!_blocked(player, playerRadius)) return;
    final trappedAt = player;
    if (lastClear != null &&
        (lastClear - player).distanceSquared < 176 * 176 &&
        !_blocked(lastClear, playerRadius)) {
      player = lastClear;
      velocity = Offset.zero;
      _powerPulse(trappedAt, const Color(0xFF9DEDF4), 30);
      _powerPulse(player, const Color(0xFF9DEDF4), 42);
      _flash('GHOST WAGE EXPIRED — back at the last clear footing.');
      return;
    }
    // Find nearby free footing when the last valid position is too far away.
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
          velocity = Offset.zero;
          _powerPulse(player, const Color(0xFF9DEDF4), 42);
          _flash('GHOST WAGE EXPIRED — position reconciled outside the lien.');
          return;
        }
      }
    }
    player =
        _randomOpenPoint(player, minimumDistance: 0) ??
        const Offset(1515, 1010);
    velocity = Offset.zero;
    _powerPulse(player, const Color(0xFF9DEDF4), 42);
    _flash('GHOST WAGE EXPIRED — emergency relocation posted.');
  }

  bool _spawnEnemy({_FutureEnemyType? force}) {
    if (!_canSpawnClaim()) return false;
    var type = force ?? _FutureEnemyType.hound;
    final roll = _random.nextDouble();
    final liveClaims = enemies.where((enemy) => !enemy.dead).length;
    if (force == null) {
      if ((_plan.objective == _FutureObjectiveKind.reflectAudit || time > 10) &&
          roll > .5) {
        type = _FutureEnemyType.auditor;
      }
      if ((time > 14 || _plan.act > 0) && roll > .78) {
        type = _FutureEnemyType.interest;
      }
      if ((time > 46 || _plan.act > 1) && roll > .94) {
        type = _FutureEnemyType.bailiff;
      }
      // The second claimant teaches ranged fire early, even in the first case.
      if (claimsDefeated + liveClaims == 1) type = _FutureEnemyType.auditor;
    }
    final radius = _enemyRadius(type);
    if (force == null && time < 2 && enemies.isEmpty && claimsDefeated == 0) {
      const entrance = Offset(1808, 1046);
      if ((entrance - player).distance > 235 &&
          !_pointInWall(entrance, radius) &&
          _hasClearShot(entrance, player)) {
        enemies.add(_FutureEnemy(entrance, type, 1));
        return true;
      }
    }
    Offset position = const Offset(60, 60);
    var found = false;
    for (var attempt = 0; attempt < 30; attempt++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final openingFight = time < 2 && enemies.isEmpty && claimsDefeated == 0;
      final distance = openingFight
          ? 340 + _random.nextDouble() * 140
          : 560 + _random.nextDouble() * 650;
      position = _clampWorld(
        player + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius,
      );
      if (!_pointInWall(position, radius) &&
          (position - player).distance > (openingFight ? 330 : 500) &&
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

  void _updateEnemies(double dt) {
    for (final enemy in enemies) {
      if (enemy.dead) continue;
      final previous = enemy.position;
      enemy.impulse = dampOffset(enemy.impulse, .00004, dt);
      if (enemy.impulse.distanceSquared > 4) {
        final step = enemy.impulse * dt;
        enemy.position = _moveCircle(
          enemy.position,
          enemy.radius,
          step.dx,
          step.dy,
        );
      }
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
          enemy.lastShotAt = time;
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
      enemy.stride += (enemy.position - previous).distance * .13;
      if (circlesOverlap(
        player,
        playerRadius + 2,
        enemy.position,
        enemy.radius,
      )) {
        _hitPlayer(
          enemy.type == _FutureEnemyType.bailiff
              ? 3.8
              : enemy.type == _FutureEnemyType.interest
              ? 2.4
              : 1.8,
          source: enemy.position,
        );
        if (enemy.impulse.distanceSquared < 165 * 165) {
          enemy.impulse = normalizedOr(-vector) * 165;
        }
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
      if (echo.type == _FutureEchoType.runner) {
        final vector = player - echo.position;
        final direction = normalizedOr(vector);
        final step = direction * (185 * dt);
        echo.position = _moveCircle(
          echo.position,
          echo.radius,
          step.dx,
          step.dy,
        );
        if (vector.distance < echo.radius + playerRadius + 4) {
          _hitPlayer(1.6, source: echo.position);
          final recoil = direction * -40;
          echo.position = _moveCircle(
            echo.position,
            echo.radius,
            recoil.dx,
            recoil.dy,
          );
        }
      }
      if (echo.life <= 0) _settleEcho(echo);
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
        case _FuturePickupKind.compound:
          shootBoost = math.max(shootBoost, 3.6);
          _powerPulse(player, const Color(0xFFFF9C6D), 44);
          _flash('COMPOUND FIRE — triple-shot overcharge.');
        case _FuturePickupKind.cashOut:
          _grantLifetime(8);
          _powerPulse(player, _futureGold, 47);
          _flash('CASH OUT — +8s lifetime.');
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
    if (portalCooldown > 0 || dashRemaining > 0) return;
    for (final portal in portals) {
      if ((portal.position - player).distance > portal.radius + playerRadius) {
        continue;
      }
      final destination = _randomOpenPoint(player, minimumDistance: 360);
      if (destination == null) return;
      final origin = player;
      player = destination;
      ghostTrail.clear();
      _followCamera(immediate: true);
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
      target.lastShotAt = time;
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
      GameFeedback.shockwave();
      ArcadeShake.shake(0.5);
      ArcadeFlash.flash(const Color(0x66FF4F7F));
      ArcadeHitStop.freeze(0.08);
      ArcadeFever.charge(0.35, switchMusic: false);
      ArcadeAchievements.unlock('default_survivor');
    }
  }

  void _hitEcho(_FutureShot shot, _FutureEcho echo) {
    echo.health -= shot.damage;
    _burst(shot.position, 5, _FutureParticleType.debt);
    if (echo.health > 0) return;
    score += 350;
    _burst(echo.position, 20, _FutureParticleType.debt);
    _settleEcho(echo);
  }

  void _settleEcho(_FutureEcho echo) {
    if (echo.dead) return;
    echo.dead = true;
    maturitiesSurvived++;
  }

  void _killEnemy(_FutureEnemy enemy) {
    enemy.dead = true;
    claimsDefeated++;
    score += (enemy.value * _plan.rewardMultiplier).round();
    ArcadeFever.charge(0.06, switchMusic: false);
    if (_DebtKind.values.every(_hasOutstandingCredit)) {
      ArcadeAchievements.unlock('credit_limit');
    }
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
    if (_random.nextDouble() < powerChance) {
      final power = switch (enemy.type) {
        _FutureEnemyType.hound ||
        _FutureEnemyType.interest => _FuturePickupKind.cashOut,
        _FutureEnemyType.auditor ||
        _FutureEnemyType.bailiff => _FuturePickupKind.compound,
      };
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
    if (!wall.crate) wallsBreached++;
    screenShake = math.max(screenShake, 7);
    _burst(
      wall.bounds.center,
      wall.secret ? 32 : 18,
      wall.secret ? _FutureParticleType.gold : _FutureParticleType.wall,
    );
    score += wall.secret ? 420 : (wall.crate ? 40 : 70);
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
    _powerPulse(
      shot.position,
      _futureLilac,
      37,
      direction: normalizedOr(-shot.velocity),
    );
    _addPlayerShot(
      _FutureShot(
        shot.position,
        -shot.velocity * 1.45,
        radius: shot.radius,
        damage: 2.6,
        life: math.min(1.7, shot.life),
        charged: true,
      ),
    );
    if (shot.type == _FutureShotType.audit) {
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
    lastHitAt = time;
    if (source != null && dashRemaining == 0 && !isLocked(_DebtKind.move)) {
      velocity += normalizedOr(player - source, fallback: Offset.zero) * 115;
    }
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
        score += 350;
        _settleEcho(echo);
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
      particle.velocity = dampOffset(particle.velocity, .00058, dt);
    }
    particles.removeWhere((particle) => particle.age >= particle.life);
    for (final pulse in pulses) {
      pulse.age += dt;
    }
    pulses.removeWhere((pulse) => pulse.age >= _FuturePowerPulse.life);
  }

  void _powerPulse(
    Offset position,
    Color color,
    double radius, {
    Offset? direction,
  }) {
    if (pulses.length >= 20) pulses.removeAt(0);
    pulses.add(_FuturePowerPulse(position, color, radius, direction));
  }

  void _emitMovementTrail(double dt) {
    movementTrailTimer -= dt;
    if (movementTrailTimer > 0) return;
    movementTrailTimer = moveBoost > 0 ? .035 : .075;
    final travel = normalizedOr(velocity, fallback: moveDirection);
    final side = Offset(-travel.dy, travel.dx);
    final count = moveBoost > 0 ? 2 : 1;
    for (var index = 0; index < count; index++) {
      _addParticle(
        _FutureParticle(
          player - travel * (9 + _random.nextDouble() * 8),
          -travel * (42 + _random.nextDouble() * 65) +
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
    GameFeedback.defeat();
    ArcadeShake.shake(0.65);
    ArcadeFlash.flash(const Color(0x77FF2A55));
    ArcadeFever.reset();
  }

  void _followCamera({double dt = 0, bool immediate = false}) {
    cameraCenter = immediate
        ? player
        : cameraCenter + (player - cameraCenter) * math.min(1, dt * 7.5);
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
    for (final center in const [
      Offset(1286, 1010),
      Offset(1322, 1037),
      Offset(1745, 939),
      Offset(1781, 967),
      Offset(1775, 1170),
      Offset(930, 835),
      Offset(2117, 1160),
      Offset(1220, 1475),
    ]) {
      if (!_blocked(center, 26)) {
        _addWall(center.dx - 17, center.dy - 16, 34, 32, hp: 3, crate: true);
      }
    }
    const openingShard = Offset(1662, 1000);
    if (!_blocked(openingShard, 11)) {
      _addPickup(_FuturePickup(openingShard, _FuturePickupKind.time, .4));
    }
    for (final position in const [
      Offset(290, 220),
      Offset(1700, 840),
      Offset(2500, 850),
      Offset(840, 1660),
    ]) {
      _addPortal(position);
    }
    _buildArenaScenery();
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
    bool crate = false,
  }) {
    walls.add(
      _FutureWall(
        Rect.fromLTWH(x, y, w, h),
        hp: hp,
        destructible: destructible,
        secret: secret,
        crate: crate,
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
    required this.crate,
  }) : health = hp,
       maxHealth = hp;
  final Rect bounds;
  final bool destructible;
  final bool secret;
  final bool crate;
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
  double lastShotAt = double.negativeInfinity;
  double lastHitAt = double.negativeInfinity;
  double stride = 0;
  Offset impulse = Offset.zero;
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
  }) : maxHealth = health;
  final _FutureEchoType type;
  Offset position;
  final double radius;
  final double maxHealth;
  double health;
  double life;
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
  double lastShotAt = double.negativeInfinity;
  double lastHitAt = double.negativeInfinity;
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

class _FuturePowerPulse {
  _FuturePowerPulse(this.position, this.color, this.radius, this.direction);

  static const life = .46;
  final Offset position;
  final Color color;
  final double radius;
  final Offset? direction;
  double age = 0;
}
