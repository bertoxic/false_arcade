part of 'numberfall_game.dart';

enum _NumberPhase { intro, playing, stageClear, dead, won }

/// Canonical three-digit representation used by collision and rendering.
List<int> numberfallDisplayDigits(int value) {
  final normalized = value.abs() % 1000;
  return [normalized ~/ 100, (normalized ~/ 10) % 10, normalized % 10];
}

String numberfallDisplayString(int value) =>
    numberfallDisplayDigits(value).join();

class _NumberStageConfig {
  const _NumberStageConfig({
    required this.name,
    required this.pickupGoal,
    required this.enemySpeed,
    required this.enemyRespawns,
    required this.rewriteLead,
    required this.supportGrace,
    required this.alternateRoutes,
    required this.riskyChoice,
  });

  final String name;
  final int pickupGoal;
  final double enemySpeed;
  final int enemyRespawns;
  final double rewriteLead;
  final double supportGrace;
  final bool alternateRoutes;
  final bool riskyChoice;
}

class _PendingNumberRewrite {
  _PendingNumberRewrite(this.targetScore, this.cause, this.opensExit);

  int targetScore;
  String cause;
  bool opensExit;
}

class _NumSurface {
  const _NumSurface(this.rect, this.digitIndex, this.segment);

  final Rect rect;
  final int digitIndex;
  final String segment;
}

class _NumBounceDash {
  _NumBounceDash(this.rect);

  final Rect rect;
  double _remaining = -1;

  bool get isAvailable => _remaining != 0;
  bool get isFading => _remaining > 0;
  double get opacity => _remaining < 0
      ? 1
      : (_remaining / _NumberfallGame._bounceDashLifetime).clamp(0.0, 1.0);

  void trigger() => _remaining = _NumberfallGame._bounceDashLifetime;

  void update(double dt) {
    if (_remaining <= 0) return;
    _remaining = math.max(0, _remaining - dt);
  }
}

class _NumberfallGame {
  static const width = 960.0;
  static const height = 540.0;
  static const _gravity = 1120.0;
  static const _jumpImpulse = 620.0;
  static const _bounceDashImpulse = 750.0;
  static const _bounceDashLifetime = 2.6;
  static const _maxMoveSpeed = 275.0;
  static const _stageConfigs = [
    _NumberStageConfig(
      name: 'FOUNDATION',
      pickupGoal: 6,
      enemySpeed: 56,
      enemyRespawns: 0,
      rewriteLead: .28,
      supportGrace: .3,
      alternateRoutes: false,
      riskyChoice: false,
    ),
    _NumberStageConfig(
      name: 'SPLIT ROUTE',
      pickupGoal: 8,
      enemySpeed: 66,
      enemyRespawns: 1,
      rewriteLead: .25,
      supportGrace: .28,
      alternateRoutes: true,
      riskyChoice: false,
    ),
    _NumberStageConfig(
      name: 'RISKY SUMS',
      pickupGoal: 10,
      enemySpeed: 76,
      enemyRespawns: 1,
      rewriteLead: .22,
      supportGrace: .26,
      alternateRoutes: true,
      riskyChoice: true,
    ),
    _NumberStageConfig(
      name: 'FAST REWRITE',
      pickupGoal: 12,
      enemySpeed: 88,
      enemyRespawns: 2,
      rewriteLead: .19,
      supportGrace: .24,
      alternateRoutes: true,
      riskyChoice: true,
    ),
    _NumberStageConfig(
      name: 'FINAL EQUATION',
      pickupGoal: 14,
      enemySpeed: 102,
      enemyRespawns: 3,
      rewriteLead: .16,
      supportGrace: .22,
      alternateRoutes: true,
      riskyChoice: true,
    ),
  ];
  static const _segments = <int, List<String>>{
    0: ['a', 'b', 'c', 'd', 'e', 'f'],
    1: ['b', 'c'],
    2: ['a', 'b', 'g', 'e', 'd'],
    3: ['a', 'b', 'c', 'd', 'g'],
    4: ['f', 'g', 'b', 'c'],
    5: ['a', 'f', 'g', 'c', 'd'],
    6: ['a', 'f', 'e', 'd', 'c', 'g'],
    7: ['a', 'b', 'c'],
    8: ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
    9: ['a', 'b', 'c', 'd', 'f', 'g'],
  };
  final int _initialStageIndex;
  final math.Random _random;
  final _NumberStageConfig? _campaignConfig;
  final int _initialScore;
  _NumBody player = _NumBody(0, 0, 22, 33);
  _NumBody enemy = _NumBody(0, 0, 25, 25);
  final List<_NumPickup> pickupsOnField = [];
  List<Rect> _activePlatforms = const [];
  List<Rect> _supportPlatforms = const [];
  List<Rect> _collisionPlatforms = const [];
  final List<_NumBounceDash> _bounceDashes = [];
  _NumberPhase phase = _NumberPhase.intro;
  int score = 14;
  int pickups = 0;
  int stageIndex = 0;
  bool left = false;
  bool right = false;
  bool _jumpHeld = false;
  bool _jumpCutRequested = false;
  double _jumpBuffer = 0;
  bool exitOpen = false;
  double _pulse = 0;
  double _rewriteTimer = 0;
  double _supportGrace = 0;
  _PendingNumberRewrite? _pendingRewrite;
  int _enemyRespawnsRemaining = 0;
  double _enemyRespawnTimer = 0;
  String message = 'Collect +1. Do not trust the floor.';

  _NumberfallGame({
    int campaignLevel = 1,
    math.Random? random,
    GeneratedGameLevel? campaign,
  }) : _initialStageIndex = (campaignLevel - 1) % _stageConfigs.length,
       _random = random ?? math.Random(campaign?.seed),
       _campaignConfig = campaign == null
           ? null
           : _campaignStageConfig(campaign),
       _initialScore = campaign == null
           ? 14
           : 100 + math.Random(campaign.seed ^ 0x74A1).nextInt(900);

  int get stageNumber => stageIndex + 1;
  int get stageCount => _stageConfigs.length;
  _NumberStageConfig get stageConfig =>
      _campaignConfig ?? _stageConfigs[stageIndex];
  int get pickupGoal => stageConfig.pickupGoal;
  String get displayString => numberfallDisplayString(score);
  String? get previewDisplayString => _pendingRewrite == null
      ? null
      : numberfallDisplayString(_pendingRewrite!.targetScore);
  double get rewriteFraction => _pendingRewrite == null
      ? 0
      : (1 - _rewriteTimer / stageConfig.rewriteLead).clamp(0.0, 1.0);
  List<Rect> get fadingPlatforms => _supportPlatforms;
  List<Rect> get platforms => _collisionPlatforms;
  List<_NumBounceDash> get bounceDashes => _bounceDashes;

  void start() {
    score = _initialScore;
    stageIndex = _initialStageIndex;
    _loadStage();
  }

  static _NumberStageConfig _campaignStageConfig(GeneratedGameLevel campaign) {
    final base = _stageConfigs[(campaign.number - 1) % _stageConfigs.length];
    return _NumberStageConfig(
      name:
          'SEQUENCE ${campaign.number.toString().padLeft(2, '0')} · ${campaign.chapterTitle}',
      // The level needs enough rewrites to create a route-reading arc rather
      // than ending as soon as the player learns the first digit.
      pickupGoal:
          ((base.pickupGoal + 14 + campaign.number * 3) *
                  campaign.lengthMultiplier)
              .round(),
      enemySpeed: base.enemySpeed * campaign.enemyPressure,
      enemyRespawns: base.enemyRespawns + campaign.number ~/ 7,
      rewriteLead: (base.rewriteLead / campaign.difficulty)
          .clamp(.11, .32)
          .toDouble(),
      supportGrace: (base.supportGrace / campaign.difficulty)
          .clamp(.14, .34)
          .toDouble(),
      alternateRoutes: true,
      riskyChoice: campaign.number >= 3,
    );
  }

  void nextStage() {
    if (phase != _NumberPhase.stageClear) return;
    stageIndex++;
    _loadStage();
  }

  void _loadStage() {
    pickups = 0;
    phase = _NumberPhase.playing;
    clearInput();
    _pulse = 0;
    _rewriteTimer = 0;
    _pendingRewrite = null;
    _supportGrace = 0;
    _supportPlatforms = const [];
    _bounceDashes
      ..clear()
      ..addAll(_buildBounceDashes());
    exitOpen = false;
    _enemyRespawnsRemaining = stageConfig.enemyRespawns;
    _enemyRespawnTimer = 0;
    _rebuildActiveGeometry();
    final surfaces = _horizontalSurfacesFor(score);
    final playerPlatform = _safeSurface(surfaces, preferRight: true).rect;
    final enemyPlatform = _safeSurface(
      surfaces,
      preferRight: false,
      avoidX: playerPlatform.center.dx,
    ).rect;
    player = _NumBody(
      playerPlatform.center.dx - 11,
      playerPlatform.top - 33,
      22,
      33,
    )..grounded = true;
    enemy =
        _NumBody(enemyPlatform.center.dx - 12.5, enemyPlatform.top - 25, 25, 25)
          ..vx = stageConfig.enemySpeed
          ..grounded = true;
    _spawnPickups();
    message =
        'STAGE $stageNumber · ${stageConfig.name}: collect $pickupGoal fragments.';
  }

  void clearInput() {
    left = false;
    right = false;
    _jumpHeld = false;
    _jumpCutRequested = false;
    _jumpBuffer = 0;
  }

  double get _digitWidth => 150;
  double get _digitHeight => 250;
  double get _thick => 21;
  double get _top => 132;
  double get _gap => 35;
  double get _startX => (width - (_digitWidth * 3 + _gap * 2)) / 2;

  List<Rect> _platformsFor(int value) {
    final digits = numberfallDisplayDigits(value);
    final result = <Rect>[];
    for (var i = 0; i < digits.length; i++) {
      final x = _startX + i * (_digitWidth + _gap);
      final map = _segmentsForDigit(digits[i], x, _top);
      for (final name in _segments[digits[i]]!) {
        result.addAll(map[name]!);
      }
    }
    return result;
  }

  void _rebuildActiveGeometry() {
    _activePlatforms = List.unmodifiable(_platformsFor(score));
    _refreshCollisionPlatforms();
  }

  void _refreshCollisionPlatforms() {
    _collisionPlatforms = List.unmodifiable([
      ..._activePlatforms,
      if (_supportGrace > 0) ..._supportPlatforms,
      if (exitOpen) exitPlatform,
    ]);
  }

  Rect get exitPlatform => Rect.fromLTWH(width - 205, height - 76, 96, 14);
  Rect get exitDoor => Rect.fromLTWH(width - 183, height - 136, 52, 60);

  Map<String, Rect> _rawSegments(double x, double y) {
    final inset = _thick * .42;
    return {
      'a': Rect.fromLTWH(x + inset, y, _digitWidth - inset * 2, _thick),
      'g': Rect.fromLTWH(
        x + inset,
        y + _digitHeight / 2 - _thick / 2,
        _digitWidth - inset * 2,
        _thick,
      ),
      'd': Rect.fromLTWH(
        x + inset,
        y + _digitHeight - _thick,
        _digitWidth - inset * 2,
        _thick,
      ),
      'f': Rect.fromLTWH(
        x,
        y + inset,
        _thick,
        _digitHeight / 2 - inset - _thick / 2,
      ),
      'b': Rect.fromLTWH(
        x + _digitWidth - _thick,
        y + inset,
        _thick,
        _digitHeight / 2 - inset - _thick / 2,
      ),
      'e': Rect.fromLTWH(
        x,
        y + _digitHeight / 2 + _thick / 2,
        _thick,
        _digitHeight / 2 - inset - _thick / 2,
      ),
      'c': Rect.fromLTWH(
        x + _digitWidth - _thick,
        y + _digitHeight / 2 + _thick / 2,
        _thick,
        _digitHeight / 2 - inset - _thick / 2,
      ),
    };
  }

  /// Some seven-segment digits form fully closed counters. Their original
  /// joins were only 21 logical pixels tall, while the actor is 33 pixels
  /// tall, making the visibly empty centre of 0 and 8 impossible to enter.
  /// Opening a 48px doorway beside a counter keeps the glyph recognizable and
  /// makes every visible interior a legitimate route.
  Map<String, List<Rect>> _segmentsForDigit(int digit, double x, double y) {
    final raw = _rawSegments(x, y);
    final upperCounter = digit == 0 || digit == 8 || digit == 9;
    final lowerCounter = digit == 0 || digit == 6 || digit == 8;
    const doorway = 48.0;

    return {
      for (final entry in raw.entries)
        entry.key: switch (entry.key) {
          'f' || 'b' when upperCounter => [
            Rect.fromLTRB(
              entry.value.left,
              entry.value.top,
              entry.value.right,
              entry.value.bottom - doorway,
            ),
          ],
          'e' || 'c' when lowerCounter => [
            Rect.fromLTRB(
              entry.value.left,
              entry.value.top + doorway,
              entry.value.right,
              entry.value.bottom,
            ),
          ],
          _ => [entry.value],
        },
    };
  }

  List<_NumBounceDash> _buildBounceDashes() => List.generate(3, (index) {
    final x = _startX + index * (_digitWidth + _gap) + _digitWidth / 2;
    return _NumBounceDash(
      Rect.fromCenter(
        center: Offset(x, _top + _digitHeight + 76),
        width: 80,
        height: 8,
      ),
    );
  });

  void setJump(bool value) {
    if (phase != _NumberPhase.playing) return;
    if (value && !_jumpHeld) _jumpBuffer = .12;
    if (!value && _jumpHeld) _jumpCutRequested = true;
    _jumpHeld = value;
  }

  void update(double dt) {
    _pulse = math.max(0, _pulse - dt * 3);
    if (phase != _NumberPhase.playing) return;
    _jumpBuffer = math.max(0, _jumpBuffer - dt);
    if (_pendingRewrite != null) {
      _rewriteTimer -= dt;
      if (_rewriteTimer <= 0) _commitRewrite();
    }
    if (_supportGrace > 0) {
      _supportGrace = math.max(0, _supportGrace - dt);
      if (_supportGrace == 0) {
        _supportPlatforms = const [];
        _refreshCollisionPlatforms();
      }
    }
    for (final dash in _bounceDashes) {
      dash.update(dt);
    }
    if (!enemy.alive && _enemyRespawnsRemaining > 0) {
      _enemyRespawnTimer -= dt;
      if (_enemyRespawnTimer <= 0) _respawnEnemy();
    }
    final move = (right ? 1 : 0) - (left ? 1 : 0);
    final acceleration = player.grounded ? 1260 : 820;
    player.vx += move * acceleration * dt;
    if (move == 0) {
      player.vx = damp(player.vx, player.grounded ? .0008 : .08, dt);
    }
    player.vx = player.vx.clamp(-_maxMoveSpeed, _maxMoveSpeed).toDouble();
    player.coyote = player.grounded ? .1 : math.max(0, player.coyote - dt);
    if (_jumpCutRequested && player.vy < -80) player.vy *= .48;
    _jumpCutRequested = false;
    if (_jumpBuffer > 0 && player.coyote > 0) {
      player.vy = -_jumpImpulse;
      player.coyote = 0;
      player.grounded = false;
      _jumpBuffer = 0;
      GameFeedback.lightImpact();
    }
    _resolve(player, dt, enemyMode: false);
    if (_pendingRewrite == null && exitOpen && player.rect.overlaps(exitDoor)) {
      if (stageIndex + 1 == stageCount) {
        phase = _NumberPhase.won;
        message = 'You found the stable exit beyond the final display.';
      } else {
        phase = _NumberPhase.stageClear;
        message = 'DISPLAY $stageNumber STABLE. The next rewrite is waiting.';
      }
      clearInput();
      GameFeedback.mediumImpact();
      return;
    }
    if (enemy.alive) {
      if (enemy.grounded && !_hasPatrolLedgeAhead(enemy, dt)) {
        enemy.vx = -enemy.vx;
      }
      _resolve(enemy, dt, enemyMode: true);
      if (enemy.x < 10 || enemy.x > width - enemy.w - 10) enemy.vx *= -1;
      if (enemy.y > height + 60) _restoreEnemyToLedge();
      if (player.rect.overlaps(enemy.rect)) {
        if (player.vy > 110 && player.y + player.h - enemy.y < 19) {
          enemy.alive = false;
          player.vy = -300;
          _enemyRespawnTimer = .85;
          _requestRewrite(3, 'ENEMY DROP +3', opensExit: false);
        } else {
          _die('A red digit knocked you out of the equation.');
        }
      }
    }
    _NumPickup? collected;
    if (_pendingRewrite == null) {
      for (final candidate in pickupsOnField) {
        if (player.rect.overlaps(candidate.rect)) {
          collected = candidate;
          break;
        }
      }
    }
    if (collected != null) {
      pickups++;
      pickupsOnField.clear();
      GameFeedback.mediumImpact();
      _requestRewrite(
        collected.delta,
        collected.risky ? 'RISK ROUTE +${collected.delta}' : 'FRAGMENT +1',
        opensExit: pickups >= pickupGoal,
      );
    }
    if (player.y > height + 70) {
      _die('You changed the number—and the floor was gone.');
    }
    if (player.x < -60 || player.x > width + 60) {
      _die('You slipped outside the display.');
    }
  }

  void _resolve(_NumBody body, double dt, {required bool enemyMode}) {
    body.grounded = false;
    body.vy = math.min(950, body.vy + _gravity * dt);
    final previousLeft = body.x;
    final previousRight = body.x + body.w;
    body.x += body.vx * dt;
    for (final platform in platforms) {
      if (!body.rect.overlaps(platform)) continue;
      if (body.vx > 0 && previousRight <= platform.left + 3) {
        body.x = platform.left - body.w;
      } else if (body.vx < 0 && previousLeft >= platform.right - 3) {
        body.x = platform.right;
      } else {
        final pushLeft = body.rect.right - platform.left;
        final pushRight = platform.right - body.rect.left;
        body.x += pushLeft < pushRight ? -pushLeft : pushRight;
      }
      body.vx = enemyMode ? -body.vx : 0;
    }
    final previousBottom = body.y + body.h;
    final previousTop = body.y;
    body.y += body.vy * dt;
    for (final platform in platforms) {
      if (!body.rect.overlaps(platform)) continue;
      if (body.vy >= 0 && previousBottom <= platform.top + 7) {
        body.y = platform.top - body.h;
        body.vy = 0;
        body.grounded = true;
      } else if (body.vy < 0 && previousTop >= platform.bottom - 7) {
        body.y = platform.bottom;
        body.vy = 0;
      } else {
        _depenetrateBody(body, [platform]);
      }
    }
    if (!enemyMode) {
      for (final dash in _bounceDashes) {
        if (!dash.isAvailable || !body.rect.overlaps(dash.rect)) continue;
        if (body.vy >= 0 && previousBottom <= dash.rect.top + 7) {
          body.y = dash.rect.top - body.h;
          body.vy = -_bounceDashImpulse;
          body.grounded = false;
          body.coyote = 0;
          dash.trigger();
          _pulse = 1;
          message = 'CATCH DASH — REBOUNDING INTO THE DISPLAY.';
          GameFeedback.lightImpact();
          break;
        }
      }
    }
  }

  bool _hasPatrolLedgeAhead(_NumBody body, double dt) {
    final lookAhead = math.max(8, body.vx.abs() * dt * 1.5);
    final leadingEdge = body.vx >= 0
        ? body.x + body.w + lookAhead
        : body.x - lookAhead;
    final feet = body.y + body.h;
    return platforms.any(
      (platform) =>
          (platform.top - feet).abs() < 7 &&
          leadingEdge > platform.left + 3 &&
          leadingEdge < platform.right - 3,
    );
  }

  void _restoreEnemyToLedge() {
    final surfaces = _horizontalSurfacesFor(score);
    if (surfaces.isEmpty) {
      enemy.alive = false;
      return;
    }
    final ledge = _safeSurface(
      surfaces,
      preferRight: _random.nextBool(),
      avoidX: player.center.dx,
    ).rect;
    enemy = _NumBody(ledge.center.dx - 12.5, ledge.top - 25, 25, 25)
      ..vx = _random.nextBool()
          ? stageConfig.enemySpeed
          : -stageConfig.enemySpeed
      ..grounded = true;
  }

  void _respawnEnemy() {
    if (_enemyRespawnsRemaining <= 0 || phase != _NumberPhase.playing) return;
    _enemyRespawnsRemaining--;
    _restoreEnemyToLedge();
    message =
        'RED DIGIT RESTORED — ${_enemyRespawnsRemaining + 1} PATROLS REMAIN.';
  }

  List<_NumSurface> _horizontalSurfacesFor(int value) {
    final result = <_NumSurface>[];
    final digits = numberfallDisplayDigits(value);
    for (var i = 0; i < digits.length; i++) {
      final digit = digits[i];
      final segments = _segments[digit]!.toSet();
      final map = _segmentsForDigit(
        digit,
        _startX + i * (_digitWidth + _gap),
        _top,
      );
      for (final segment in ['a', 'g', 'd', 'f', 'b', 'e', 'c']) {
        if (!segments.contains(segment)) {
          continue;
        }
        for (final rect in map[segment]!) {
          result.add(_NumSurface(rect, i, segment));
        }
      }
    }
    return result;
  }

  _NumSurface _safeSurface(
    List<_NumSurface> surfaces, {
    required bool preferRight,
    double? avoidX,
  }) {
    if (surfaces.isEmpty) {
      return _NumSurface(
        Rect.fromLTWH(width / 2 - 48, height - 80, 96, 14),
        1,
        'fallback',
      );
    }
    final ordered = [...surfaces]
      ..sort((a, b) {
        if (avoidX != null) {
          final distanceOrder = (b.rect.center.dx - avoidX).abs().compareTo(
            (a.rect.center.dx - avoidX).abs(),
          );
          if (distanceOrder != 0) return distanceOrder;
        }
        return preferRight
            ? b.rect.center.dx.compareTo(a.rect.center.dx)
            : a.rect.center.dx.compareTo(b.rect.center.dx);
      });
    return ordered.first;
  }

  bool _canJumpBetween(Rect from, Rect to) {
    final verticalDelta = to.top - from.top;
    final discriminant =
        _jumpImpulse * _jumpImpulse + 2 * _gravity * verticalDelta;
    if (discriminant < 0) return false;
    final flightTime = (_jumpImpulse + math.sqrt(discriminant)) / _gravity;
    final horizontalGap = math.max(
      0,
      (to.center.dx - from.center.dx).abs() - (from.width + to.width) / 2,
    );
    return horizontalGap <= _maxMoveSpeed * flightTime + player.w * .8;
  }

  List<_NumSurface> _reachableSurfaces() {
    final surfaces = _horizontalSurfacesFor(score);
    if (surfaces.isEmpty) return const [];
    final supported = <int>[];
    for (var index = 0; index < surfaces.length; index++) {
      final rect = surfaces[index].rect;
      if ((player.rect.bottom - rect.top).abs() < 12 &&
          player.rect.right > rect.left &&
          player.rect.left < rect.right) {
        supported.add(index);
      }
    }
    if (supported.isEmpty) {
      var nearest = 0;
      var distance = double.infinity;
      for (var index = 0; index < surfaces.length; index++) {
        final candidate =
            (surfaces[index].rect.center - player.center).distance;
        if (candidate < distance) {
          distance = candidate;
          nearest = index;
        }
      }
      supported.add(nearest);
    }
    final visited = <int>{...supported};
    final queue = <int>[...supported];
    while (queue.isNotEmpty) {
      final from = queue.removeAt(0);
      for (var to = 0; to < surfaces.length; to++) {
        if (visited.contains(to) ||
            !_canJumpBetween(surfaces[from].rect, surfaces[to].rect)) {
          continue;
        }
        visited.add(to);
        queue.add(to);
      }
    }
    return [for (final index in visited) surfaces[index]];
  }

  void _spawnPickups() {
    pickupsOnField.clear();
    if (exitOpen || phase != _NumberPhase.playing) return;
    var candidates = _reachableSurfaces()
        .where(
          (surface) =>
              (surface.rect.center - player.center).distance >
              (stageConfig.alternateRoutes ? 125 : 90),
        )
        .toList();
    if (candidates.isEmpty) candidates = _reachableSurfaces();
    if (candidates.isEmpty) {
      pickupsOnField.add(
        _NumPickup(player.center + const Offset(0, -44), delta: 1),
      );
      return;
    }
    if (stageConfig.alternateRoutes) {
      final seekUpper = pickups.isEven;
      final biased = candidates
          .where(
            (surface) => seekUpper
                ? surface.rect.top < _top + _digitHeight / 2
                : surface.rect.top >= _top + _digitHeight / 2 - _thick,
          )
          .toList();
      if (biased.isNotEmpty) candidates = biased;
    }
    final safe = candidates[_random.nextInt(candidates.length)];
    pickupsOnField.add(
      _NumPickup(Offset(safe.rect.center.dx, safe.rect.top - 17), delta: 1),
    );
    if (stageConfig.riskyChoice) {
      final risky = [..._reachableSurfaces()]
        ..removeWhere(
          (surface) =>
              (surface.rect.center - safe.rect.center).distance < 145 ||
              (surface.rect.center - player.center).distance < 120,
        )
        ..sort(
          (a, b) => (b.rect.center - player.center).distance.compareTo(
            (a.rect.center - player.center).distance,
          ),
        );
      if (risky.isNotEmpty) {
        pickupsOnField.add(
          _NumPickup(
            Offset(risky.first.rect.center.dx, risky.first.rect.top - 17),
            delta: 2,
            risky: true,
          ),
        );
      }
    }
  }

  void _requestRewrite(int delta, String cause, {required bool opensExit}) {
    if (phase != _NumberPhase.playing) return;
    pickupsOnField.clear();
    if (_pendingRewrite != null) {
      _pendingRewrite!
        ..targetScore += delta
        ..cause = cause
        ..opensExit = _pendingRewrite!.opensExit || opensExit;
      _rewriteTimer = math.max(_rewriteTimer, stageConfig.rewriteLead * .55);
    } else {
      _pendingRewrite = _PendingNumberRewrite(score + delta, cause, opensExit);
      _rewriteTimer = stageConfig.rewriteLead;
    }
    message =
        '${numberfallDisplayString(score)} → ${numberfallDisplayString(_pendingRewrite!.targetScore)} · $cause · REWRITE PRIMED';
    GameFeedback.selection();
  }

  void _commitRewrite() {
    final rewrite = _pendingRewrite;
    if (rewrite == null) return;
    final previous = _activePlatforms;
    score = rewrite.targetScore;
    _pendingRewrite = null;
    _rewriteTimer = 0;
    _activePlatforms = List.unmodifiable(_platformsFor(score));
    _supportPlatforms = List.unmodifiable(
      previous.where((old) => !_activePlatforms.contains(old)),
    );
    _supportGrace = _supportPlatforms.isEmpty ? 0 : stageConfig.supportGrace;
    exitOpen = exitOpen || rewrite.opensExit;
    _refreshCollisionPlatforms();
    _depenetrateBody(player, _activePlatforms);
    if (enemy.alive) _depenetrateBody(enemy, _activePlatforms);
    _pulse = 1;
    if (exitOpen) {
      message = 'THE NUMBER IS STABLE — reach the EXIT portal.';
    } else {
      _spawnPickups();
      message =
          '${numberfallDisplayString(score)} COMMITTED · ${rewrite.cause}${pickupsOnField.length > 1 ? ' · CHOOSE SAFE +1 OR RISK +2' : ''}';
    }
  }

  void _depenetrateBody(_NumBody body, Iterable<Rect> obstacles) {
    for (var pass = 0; pass < 6; pass++) {
      Rect? hit;
      for (final obstacle in obstacles) {
        if (body.rect.overlaps(obstacle)) {
          hit = obstacle;
          break;
        }
      }
      if (hit == null) return;
      final rect = body.rect;
      final translations = <Offset>[
        Offset(hit.left - rect.right, 0),
        Offset(hit.right - rect.left, 0),
        Offset(0, hit.top - rect.bottom),
        Offset(0, hit.bottom - rect.top),
      ]..sort((a, b) => a.distanceSquared.compareTo(b.distanceSquared));
      final correction = translations.first;
      body.x += correction.dx;
      body.y += correction.dy;
      if (correction.dx != 0) body.vx = 0;
      if (correction.dy != 0) {
        body.vy = 0;
        if (correction.dy < 0) body.grounded = true;
      }
    }
  }

  void _die(String reason) {
    phase = _NumberPhase.dead;
    clearInput();
    message = reason;
    GameFeedback.heavyImpact();
  }
}

class _NumBody {
  _NumBody(this.x, this.y, this.w, this.h);
  double x;
  double y;
  final double w;
  final double h;
  double vx = 0;
  double vy = 0;
  bool grounded = false;
  bool alive = true;
  double coyote = 0;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
  Offset get center => Offset(x + w / 2, y + h / 2);
}

class _NumPickup {
  _NumPickup(this.position, {required this.delta, this.risky = false});
  final Offset position;
  final int delta;
  final bool risky;
  Rect get rect => Rect.fromCircle(center: position, radius: 15);
}
