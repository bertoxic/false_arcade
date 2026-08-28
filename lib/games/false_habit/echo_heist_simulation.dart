part of 'echo_heist_game.dart';

enum _HeistPhase { intro, playing, caught, stageClear, won }

enum _WardenIntent { observing, telegraphing, committed, recovering }

/// Extraction must recognize the heist's high-value objective separately from
/// the optional common-loot score target.
abstract final class EchoHeistRules {
  static bool exitUnlocked({
    required double runLoot,
    required int stageTarget,
    required bool allDiamondsTaken,
  }) => runLoot >= stageTarget || allDiamondsTaken;
}

class _HeistStageConfig {
  const _HeistStageConfig({
    required this.target,
    required this.lootScale,
    required this.playerSpawn,
    required this.wardenSpawn,
    required this.exit,
    required this.blackDiamond,
    required this.layout,
    required this.observeSpeed,
    required this.commitSpeed,
    required this.observeSeconds,
    required this.telegraphSeconds,
    required this.commitSeconds,
    required this.learnAmount,
  });

  final int target;
  final double lootScale;
  final Offset playerSpawn;
  final Offset wardenSpawn;
  final Offset exit;
  final Offset blackDiamond;
  final int layout;
  final double observeSpeed;
  final double commitSpeed;
  final double observeSeconds;
  final double telegraphSeconds;
  final double commitSeconds;
  final double learnAmount;
}

const _heistStages = <_HeistStageConfig>[
  _HeistStageConfig(
    target: 6000,
    lootScale: 1,
    playerSpawn: Offset(146, 270),
    wardenSpawn: Offset(560, 270),
    exit: Offset(885, 440),
    blackDiamond: Offset(726, 158),
    layout: 0,
    observeSpeed: 86,
    commitSpeed: 248,
    observeSeconds: 2.8,
    telegraphSeconds: .7,
    commitSeconds: 1,
    learnAmount: 1.15,
  ),
  _HeistStageConfig(
    target: 9000,
    lootScale: 1.25,
    playerSpawn: Offset(814, 270),
    wardenSpawn: Offset(400, 270),
    exit: Offset(75, 105),
    blackDiamond: Offset(244, 382),
    layout: 1,
    observeSpeed: 96,
    commitSpeed: 270,
    observeSeconds: 2.5,
    telegraphSeconds: .62,
    commitSeconds: 1.02,
    learnAmount: 1.22,
  ),
  _HeistStageConfig(
    target: 13000,
    lootScale: 1.5,
    playerSpawn: Offset(145, 420),
    wardenSpawn: Offset(555, 130),
    exit: Offset(880, 100),
    blackDiamond: Offset(720, 390),
    layout: 2,
    observeSpeed: 106,
    commitSpeed: 292,
    observeSeconds: 2.25,
    telegraphSeconds: .56,
    commitSeconds: 1.06,
    learnAmount: 1.3,
  ),
  _HeistStageConfig(
    target: 18000,
    lootScale: 1.8,
    playerSpawn: Offset(815, 420),
    wardenSpawn: Offset(405, 130),
    exit: Offset(80, 430),
    blackDiamond: Offset(250, 150),
    layout: 3,
    observeSpeed: 116,
    commitSpeed: 315,
    observeSeconds: 2,
    telegraphSeconds: .5,
    commitSeconds: 1.1,
    learnAmount: 1.38,
  ),
  _HeistStageConfig(
    target: 24000,
    lootScale: 2.15,
    playerSpawn: Offset(480, 430),
    wardenSpawn: Offset(480, 125),
    exit: Offset(480, 82),
    blackDiamond: Offset(480, 185),
    layout: 4,
    observeSpeed: 126,
    commitSpeed: 340,
    observeSeconds: 1.78,
    telegraphSeconds: .46,
    commitSeconds: 1.14,
    learnAmount: 1.46,
  ),
];

class _EchoHeist {
  static const width = 960.0;
  static const height = 540.0;
  static const _playerRadius = 13.0;
  static const _exitWidth = 34.0;
  static const _exitHeight = 58.0;
  static const _pathSampleSeconds = .075;
  final List<_HeistLoot> loot = [];
  final List<_Echo> echoes = [];
  final List<Offset> _recentPath = [];
  final Map<String, double> model = {'left': 1, 'right': 1, 'up': 1, 'down': 1};

  _HeistPhase phase = _HeistPhase.intro;
  _WardenIntent _wardenIntent = _WardenIntent.observing;
  Offset player = const Offset(146, 270);
  Offset warden = const Offset(560, 270);
  Offset wardenTarget = const Offset(146, 270);
  bool wardenFollowingEcho = false;
  String _currentMove = 'right';
  String _predictionAtCommit = 'right';
  double runLoot = 0;
  double banked = 0;
  double combo = 1;
  double _recordTimer = 0;
  double _pathTimer = 0;
  double _echoCooldown = 0;
  double _wardenStun = 0;
  double _lockdown = 0;
  double _intentTimer = 0;
  double _breakWindow = 0;
  bool _predictionBroken = false;
  bool blackDiamondTaken = false;
  int stageIndex = 0;
  String message = 'Build a habit, then betray it.';
  final int _initialStageIndex;
  final int _routeVariant;
  final int _campaignLevel;
  final bool _isCampaign;

  _EchoHeist({int campaignLevel = 1, GeneratedGameLevel? campaign})
    : _initialStageIndex = (campaignLevel - 1) % _heistStages.length,
      _routeVariant = campaign?.seed ?? campaignLevel,
      _campaignLevel = campaign?.number ?? campaignLevel,
      _isCampaign = campaign != null;

  _HeistStageConfig get _stage => _heistStages[stageIndex];
  Offset get exit => _layoutPoint(_stage.exit);
  Rect get exitBounds =>
      Rect.fromCenter(center: exit, width: _exitWidth, height: _exitHeight);
  Offset get blackDiamond => _layoutPoint(_stage.blackDiamond);
  bool get echoReady => _echoCooldown <= 0 && echoes.isEmpty;
  bool get isExitLocked => _lockdown > 0;
  bool get allDiamondLootTaken =>
      blackDiamondTaken &&
      loot.where((item) => item.diamond).every((item) => item.taken);
  bool get hasMetLootTarget => _isCampaign
      ? blackDiamondTaken && allDiamondLootTaken && runLoot >= stageTarget
      : EchoHeistRules.exitUnlocked(
          runLoot: runLoot,
          stageTarget: stageTarget,
          allDiamondsTaken: allDiamondLootTaken,
        );
  bool get isExitReady => !isExitLocked && hasMetLootTarget;
  bool get isTelegraphing => _wardenIntent == _WardenIntent.telegraphing;
  bool get isCommitted => _wardenIntent == _WardenIntent.committed;
  bool get hasBreakWindow => _breakWindow > 0 && _predictionBroken;
  String get predictedMove => _predictionAtCommit.toUpperCase();
  int get stageNumber => stageIndex + 1;
  int get stageCount => _heistStages.length;
  int get stageTarget {
    if (!_isCampaign) return _stage.target;
    final availableLoot =
        loot.fold<double>(0, (sum, item) => sum + item.value) +
        4000 * (1 + stageIndex * .3);
    return math.min(
      _stage.target + _campaignLevel * 300,
      (availableLoot * .9).round(),
    );
  }

  // The exit is painted as a tall portal, so its collision should use that
  // same footprint instead of a smaller, invisible center-radius target.
  // Include the player's visible radius so merely touching its edge extracts.
  bool get _atExit {
    final bounds = exitBounds;
    final nearest = Offset(
      player.dx.clamp(bounds.left, bounds.right).toDouble(),
      player.dy.clamp(bounds.top, bounds.bottom).toDouble(),
    );
    final delta = player - nearest;
    return delta.dx * delta.dx + delta.dy * delta.dy <=
        _playerRadius * _playerRadius;
  }

  bool get _canCashOut =>
      phase == _HeistPhase.playing && _atExit && isExitReady;
  double get confidence {
    final sum = model.values.reduce((a, b) => a + b);
    return model.values.reduce(math.max) / sum;
  }

  String get _prediction =>
      model.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  void start() {
    banked = 0;
    stageIndex = _initialStageIndex;
    _loadStage();
  }

  void nextStage() {
    if (phase != _HeistPhase.stageClear) return;
    stageIndex++;
    _loadStage();
  }

  void _loadStage() {
    phase = _HeistPhase.playing;
    player = _layoutPoint(_stage.playerSpawn);
    warden = _layoutPoint(_stage.wardenSpawn);
    wardenTarget = player;
    wardenFollowingEcho = false;
    _currentMove = 'right';
    _predictionAtCommit = 'right';
    _wardenIntent = _WardenIntent.observing;
    _intentTimer = _stage.observeSeconds;
    runLoot = 0;
    combo = 1;
    _recordTimer = 0;
    _pathTimer = 0;
    _echoCooldown = 0;
    _wardenStun = 0;
    _lockdown = 0;
    _breakWindow = 0;
    _predictionBroken = false;
    blackDiamondTaken = false;
    echoes.clear();
    _recentPath
      ..clear()
      ..add(player);
    final common = 350 * _stage.lootScale;
    final diamond = 1200 * _stage.lootScale;
    loot
      ..clear()
      ..addAll([
        _HeistLoot(_layoutPoint(const Offset(260, 136)), common),
        _HeistLoot(_layoutPoint(const Offset(365, 395)), common),
        _HeistLoot(
          _layoutPoint(const Offset(456, 173)),
          diamond,
          diamond: true,
        ),
        _HeistLoot(_layoutPoint(const Offset(570, 386)), common),
        _HeistLoot(_layoutPoint(const Offset(646, 244)), common),
        _HeistLoot(
          _layoutPoint(const Offset(780, 360)),
          diamond,
          diamond: true,
        ),
        _HeistLoot(_layoutPoint(const Offset(820, 120)), common),
        _HeistLoot(_layoutPoint(const Offset(313, 271)), common),
      ]);
    if (stageIndex >= 2) {
      loot.add(_HeistLoot(_layoutPoint(const Offset(510, 290)), common * 1.2));
    }
    if (stageIndex >= 4) {
      loot.add(
        _HeistLoot(
          _layoutPoint(const Offset(690, 110)),
          diamond * 1.1,
          diamond: true,
        ),
      );
    }
    final extendedLoot = 4 + _campaignLevel ~/ 4;
    for (var index = 0; index < extendedLoot; index++) {
      final random = math.Random(_routeVariant ^ (index * 0x45D9F3B));
      loot.add(
        _HeistLoot(
          _layoutPoint(
            Offset(
              150 + random.nextDouble() * 660,
              105 + random.nextDouble() * 320,
            ),
          ),
          common * (1.15 + random.nextDouble() * .55),
        ),
      );
    }
    model
      ..clear()
      ..addAll({'left': 1, 'right': 1, 'up': 1, 'down': 1});
    message =
        'DISTRICT $stageNumber: teach the Warden, wait for COMMIT, then cut.';
  }

  Offset _layoutPoint(Offset point) {
    final transformed = switch (_stage.layout) {
      1 => Offset(width - point.dx, point.dy),
      2 => Offset(point.dx, height - point.dy),
      3 => Offset(width - point.dx, height - point.dy),
      4 => Offset(point.dx + (point.dy > height / 2 ? 58 : -46), point.dy),
      _ => point,
    };
    final center = const Offset(width / 2, height / 2);
    final angle = ((_routeVariant % 7) - 3) * .035;
    final aroundCenter = transformed - center;
    final rotated = Offset(
      aroundCenter.dx * math.cos(angle) - aroundCenter.dy * math.sin(angle),
      aroundCenter.dx * math.sin(angle) + aroundCenter.dy * math.cos(angle),
    );
    final offset = Offset(
      ((_routeVariant >>> 8) % 5 - 2) * 13.0,
      ((_routeVariant >>> 12) % 5 - 2) * 10.0,
    );
    return _clampPoint(center + rotated + offset);
  }

  Offset _clampPoint(Offset point) => Offset(
    point.dx.clamp(65, width - 65).toDouble(),
    point.dy.clamp(72, height - 65).toDouble(),
  );

  void update(double dt, Offset input) {
    _echoCooldown = math.max(0, _echoCooldown - dt);
    _wardenStun = math.max(0, _wardenStun - dt);
    _lockdown = math.max(0, _lockdown - dt);
    _breakWindow = math.max(0, _breakWindow - dt);
    if (phase != _HeistPhase.playing) return;

    for (final key in model.keys.toList(growable: false)) {
      model[key] = 1 + (model[key]! - 1) * math.pow(.975, dt);
    }
    if (input.distance > .1) {
      final direction = normalizedOr(input);
      _currentMove = _moveName(direction);
      player = _clampPoint(player + direction * 215 * dt);
      _recordTimer -= dt;
      if (_recordTimer <= 0) {
        model[_currentMove] = model[_currentMove]! + _stage.learnAmount;
        _recordTimer += .23;
      }
    }
    _recordPath(dt);

    if (_wardenIntent == _WardenIntent.committed &&
        input.distance > .35 &&
        _currentMove != _predictionAtCommit &&
        !_predictionBroken) {
      _predictionBroken = true;
      _breakWindow = 1.25;
      message = 'PREDICTION BROKEN — steal before the Warden recovers.';
      HapticFeedback.lightImpact();
    }

    for (final item in loot) {
      if (!item.taken &&
          circlesOverlap(item.position, 9, player, _playerRadius)) {
        _takeLoot(item);
      }
    }
    if (!blackDiamondTaken &&
        confidence >= .86 &&
        circlesOverlap(player, _playerRadius, blackDiamond, 15)) {
      blackDiamondTaken = true;
      _award(4000 * (1 + stageIndex * .3), 'BLACK DIAMOND SECURED');
      _lockdown = 0;
      if (allDiamondLootTaken) {
        message = 'ALL DIAMONDS SECURED — EXIT OPEN.';
      }
    }
    _updateEchoes(dt);
    // The painted green exit is a real portal, not just a prompt for the
    // separate ESCAPE button. Resolve it before the Warden gets another
    // movement step once its existing requirements are met.
    if (_canCashOut) {
      _completeCashOut();
      return;
    }
    _updateWarden(dt);
    if (_wardenStun <= 0 && circlesOverlap(warden, 18, player, _playerRadius)) {
      phase = _HeistPhase.caught;
      runLoot = 0;
      echoes.clear();
      message = 'The Warden caught the real thief.';
      HapticFeedback.heavyImpact();
    }
  }

  void _recordPath(double dt) {
    _pathTimer -= dt;
    if (_pathTimer > 0) return;
    _pathTimer += _pathSampleSeconds;
    _recentPath.add(player);
    if (_recentPath.length > 28) _recentPath.removeAt(0);
  }

  String _moveName(Offset direction) => direction.dx.abs() > direction.dy.abs()
      ? (direction.dx > 0 ? 'right' : 'left')
      : (direction.dy > 0 ? 'down' : 'up');

  Offset _moveVector(String move) => switch (move) {
    'left' => const Offset(-1, 0),
    'up' => const Offset(0, -1),
    'down' => const Offset(0, 1),
    _ => const Offset(1, 0),
  };

  void _takeLoot(_HeistLoot item) {
    item.taken = true;
    if (hasBreakWindow) {
      combo = math.min(4.5, combo + .22 + confidence * .25);
      final multiplier = 1 + confidence * 1.55;
      _award(
        item.value * multiplier * combo,
        '${(confidence * 100).round()}% COMMITMENT BROKEN',
      );
      _breakWindow = 0;
      if (confidence >= .8) _wardenStun = math.max(_wardenStun, .7);
    } else {
      combo = math.max(1, combo * .8);
      _award(item.value, 'PATTERN CONFIRMED');
    }
    HapticFeedback.selectionClick();
  }

  void _award(double value, String text) {
    runLoot += value;
    message = '$text  +${value.round()}';
    if (runLoot >= stageTarget * .65 && !allDiamondLootTaken) {
      _lockdown = math.max(_lockdown, 1.65);
    }
    if (allDiamondLootTaken) {
      _lockdown = 0;
      message = 'ALL DIAMONDS SECURED — EXIT OPEN.';
    }
  }

  void deployEcho() {
    if (phase != _HeistPhase.playing || !echoReady) return;
    if (confidence < .42) {
      message = 'The route is not convincing yet — build Warden confidence.';
      return;
    }
    var travel = 0.0;
    for (var index = 1; index < _recentPath.length; index++) {
      travel += (_recentPath[index] - _recentPath[index - 1]).distance;
    }
    if (_recentPath.length < 8 || travel < 54) {
      message = 'Move a longer route before recording an Echo.';
      return;
    }
    echoes.add(_Echo(player, List<Offset>.of(_recentPath)));
    _echoCooldown = 5.2;
    message = 'Echo replaying your recorded route.';
    HapticFeedback.lightImpact();
  }

  void _updateEchoes(double dt) {
    for (final echo in echoes) {
      echo.advance(dt, width: width, height: height);
      if (echo.carried == null) {
        for (final item in loot) {
          if (!item.taken &&
              circlesOverlap(item.position, 9, echo.position, 10)) {
            item.taken = true;
            echo.carried = item;
            message = 'Echo took a cache. If caught, that cache is lost.';
            break;
          }
        }
      }
    }
    for (final echo in List<_Echo>.from(echoes)) {
      if (echo.life <= 0) {
        echoes.remove(echo);
        if (echo.carried != null) {
          _award(echo.carried!.value * .65, 'ECHO SMUGGLED CACHE');
        }
      }
    }
  }

  void _beginTelegraph() {
    _wardenIntent = _WardenIntent.telegraphing;
    _intentTimer = _stage.telegraphSeconds;
    _predictionAtCommit = _prediction;
    _predictionBroken = false;
    _breakWindow = 0;
    wardenTarget = _clampPoint(
      player + _moveVector(_predictionAtCommit) * (210 + stageIndex * 12),
    );
    message = 'WARDEN READ: $predictedMove — prepare to cut.';
  }

  void _updateWarden(double dt) {
    if (_wardenStun > 0) {
      wardenFollowingEcho = false;
      return;
    }

    final plausibleEcho =
        echoes.isNotEmpty &&
            confidence >= .42 &&
            _wardenIntent != _WardenIntent.committed
        ? echoes.first
        : null;
    if (plausibleEcho != null) {
      wardenFollowingEcho = true;
      wardenTarget = plausibleEcho.position;
      _moveWardenToward(wardenTarget, _stage.observeSpeed + 78, dt);
      if (circlesOverlap(warden, 18, plausibleEcho.position, 10)) {
        echoes.remove(plausibleEcho);
        if (plausibleEcho.carried != null) {
          message = 'Echo exposed — its stolen cache was lost.';
        } else {
          message = 'Echo exposed — Warden recalibrating.';
        }
        _wardenStun = confidence >= .8 ? 1.35 : .55;
        _wardenIntent = _WardenIntent.recovering;
        _intentTimer = .55;
      }
      return;
    }
    wardenFollowingEcho = false;

    switch (_wardenIntent) {
      case _WardenIntent.observing:
        wardenTarget = player;
        _moveWardenToward(player, _stage.observeSpeed, dt);
        _intentTimer -= dt;
        if (_intentTimer <= 0) _beginTelegraph();
      case _WardenIntent.telegraphing:
        _intentTimer -= dt;
        if (_intentTimer <= 0) {
          _wardenIntent = _WardenIntent.committed;
          _intentTimer = _stage.commitSeconds;
          message = 'WARDEN COMMITTED $predictedMove — BREAK NOW.';
        }
      case _WardenIntent.committed:
        _moveWardenToward(wardenTarget, _stage.commitSpeed, dt);
        _intentTimer -= dt;
        if (_intentTimer <= 0 || (wardenTarget - warden).distance < 8) {
          _wardenIntent = _WardenIntent.recovering;
          _intentTimer = .62;
        }
      case _WardenIntent.recovering:
        _intentTimer -= dt;
        if (_intentTimer <= 0) {
          _wardenIntent = _WardenIntent.observing;
          _intentTimer = _stage.observeSeconds;
          _predictionBroken = false;
          _breakWindow = 0;
        }
    }
  }

  void _moveWardenToward(Offset target, double speed, double dt) {
    final route = target - warden;
    if (route.distance > 1) {
      warden = _clampPoint(warden + normalizedOr(route) * speed * dt);
    }
  }

  void cashOut() {
    if (phase != _HeistPhase.playing) return;
    if (!_atExit) {
      message = 'Reach the green exit to cash out.';
      return;
    }
    if (isExitLocked) {
      message = 'Exit cycling — wait for the lockdown pulse.';
      return;
    }
    if (runLoot <= 0) {
      message = 'Steal something first.';
      return;
    }
    if (!hasMetLootTarget) {
      message =
          '${(stageTarget - runLoot).ceil()} more loot needed to clear this district.';
      return;
    }
    _completeCashOut();
  }

  void _completeCashOut() {
    banked += runLoot;
    phase = stageIndex + 1 == stageCount
        ? _HeistPhase.won
        : _HeistPhase.stageClear;
    HapticFeedback.mediumImpact();
  }
}

class _HeistLoot {
  _HeistLoot(this.position, this.value, {this.diamond = false});

  final Offset position;
  final double value;
  final bool diamond;
  bool taken = false;
}

class _Echo {
  _Echo(this.position, List<Offset> recorded)
    : _origin = position,
      _path = recorded
          .map((point) => point - recorded.first)
          .toList(growable: false),
      _tailDirection = recorded.length > 1
          ? normalizedOr(recorded.last - recorded[recorded.length - 2])
          : const Offset(1, 0);

  Offset position;
  final Offset _origin;
  final List<Offset> _path;
  final Offset _tailDirection;
  double _playback = 0;
  double life = 4.8;
  _HeistLoot? carried;

  void advance(double dt, {required double width, required double height}) {
    life -= dt;
    _playback += dt;
    final duration = (_path.length - 1) * _EchoHeist._pathSampleSeconds;
    if (_path.length > 1 && _playback <= duration) {
      final exact = _playback / _EchoHeist._pathSampleSeconds;
      final index = exact.floor().clamp(0, _path.length - 2);
      final localT = exact - index;
      position = _origin + Offset.lerp(_path[index], _path[index + 1], localT)!;
    } else {
      position += _tailDirection * 164 * dt;
    }
    position = Offset(
      position.dx.clamp(65, width - 65).toDouble(),
      position.dy.clamp(72, height - 65).toDouble(),
    );
  }
}
