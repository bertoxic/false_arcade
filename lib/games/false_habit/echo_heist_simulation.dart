part of 'echo_heist_game.dart';

enum _HabitPhase { intro, playing, caught, escaped }

enum _WardenMode { observing, telegraphing, folding, recovering }

enum _HabitDirection { north, east, south, west }

/// I keep these rules public so route behavior stays regression-tested without
/// exposing the game world's private actors.
abstract final class EchoHeistRules {
  static bool exitsOpen({required int stolen, required int required}) =>
      stolen >= required;

  static bool breaksRead({
    required String predicted,
    required String actual,
    required bool wardenReading,
  }) => wardenReading && predicted != actual;

  static int breakBonus({required int chain, required int campaignLevel}) =>
      420 + chain.clamp(0, 5).toInt() * 160 + campaignLevel * 35;
}

class _EchoHeist {
  static const width = 960.0;
  static const height = 540.0;
  static const worldWidth = 2240.0;
  static const worldHeight = 1360.0;
  static const _columns = 6;
  static const _rows = 4;
  static const _roomWidth = 260.0;
  static const _roomHeight = 200.0;
  static const _gapX = 72.0;
  static const _gapY = 72.0;
  static const _marginX = 130.0;
  static const _marginY = 120.0;
  static const _playerRadius = 13.0;

  _EchoHeist({int campaignLevel = 1, GeneratedGameLevel? campaign})
    : _campaignLevel = campaign?.number ?? campaignLevel,
      _random = math.Random(campaign?.seed ?? campaignLevel) {
    _buildArchive();
    _resetRun();
    phase = _HabitPhase.intro;
  }

  final int _campaignLevel;
  final math.Random _random;
  final List<_HabitRoom> rooms = [];
  final List<_HabitGate> gates = [];
  final List<_HabitShard> shards = [];
  final Map<_HabitDirection, double> _habit = {
    _HabitDirection.north: 1,
    _HabitDirection.east: 1,
    _HabitDirection.south: 1,
    _HabitDirection.west: 1,
  };
  final List<Offset> _routeTrace = [];
  final Set<int> _rewiredGateIds = {};
  final Set<int> _sealedGateIds = {};

  late final int _entryRoomId;
  late final int _wardenRoomId;
  late final Offset exit;
  late Offset player;
  late Offset warden;
  late Offset camera;
  _HabitEcho? echo;
  _HabitPhase phase = _HabitPhase.intro;
  _WardenMode _wardenMode = _WardenMode.observing;
  _HabitDirection _predictedDirection = _HabitDirection.east;
  int _lastRoomId = 0;
  int _foldOriginRoomId = 0;
  int _stolen = 0;
  int _breakChain = 0;
  int score = 0;
  double time = 0;
  double heat = 0;
  double _readTimer = 4.2;
  double _modeTimer = 0;
  double _echoCooldown = 0;
  double _traceTimer = 0;
  bool _readBroken = false;
  String message = 'Teach a route. Then betray it.';

  Rect get world => const Rect.fromLTWH(0, 0, worldWidth, worldHeight);
  Rect get visibleWorld => Rect.fromLTWH(camera.dx, camera.dy, width, height);
  _HabitRoom get entryRoom => rooms[_entryRoomId];
  _HabitRoom get wardenRoom => rooms[_wardenRoomId];
  int get requiredShards => 3 + (_campaignLevel >= 9 ? 1 : 0);
  int get stolen => _stolen;
  int get breakChain => _breakChain;
  bool get exitOpen =>
      EchoHeistRules.exitsOpen(stolen: _stolen, required: requiredShards);
  bool get echoReady => _echoCooldown <= 0 && echo == null;
  bool get wardenReading =>
      _wardenMode == _WardenMode.telegraphing ||
      _wardenMode == _WardenMode.folding;
  bool get isFolding => _wardenMode == _WardenMode.folding;
  double get habitConfidence {
    final total = _habit.values.fold<double>(0, (sum, value) => sum + value);
    return _habit.values.reduce(math.max) / total;
  }

  String get predictedDirection => _directionLabel(_predictedDirection);
  String get wardenStateReadout => switch (_wardenMode) {
    _WardenMode.observing => 'LEARNING $predictedDirection',
    _WardenMode.telegraphing => 'READING $predictedDirection',
    _WardenMode.folding =>
      echo == null ? 'FOLDING $predictedDirection' : 'FOLDING THE ECHO',
    _WardenMode.recovering => 'RECALIBRATING',
  };
  String get objectiveReadout => exitOpen
      ? 'BREACH OPEN · RETURN TO ENTRY'
      : 'STEAL $_stolen/$requiredShards TRUTH FRAGMENTS';
  String get controlHint => echoReady
      ? 'ECHO READY · E / SPACE'
      : 'ECHO RECORDING ${_echoCooldown.ceil()}s';
  List<int> get rewiredGateIds => List.unmodifiable(_rewiredGateIds);
  List<int> get sealedGateIds => List.unmodifiable(_sealedGateIds);
  int get foldOriginRoomId => _foldOriginRoomId;

  void start() {
    _resetRun();
    phase = _HabitPhase.playing;
    message = 'STEAL $requiredShards TRUTH FRAGMENTS · RETURN TO THE BREACH.';
  }

  void update(double dt, Offset input) {
    if (phase != _HabitPhase.playing) return;
    time += dt;
    _echoCooldown = math.max(0, _echoCooldown - dt);
    _updateEcho(dt);
    _decayHabit(dt);
    _movePlayer(dt, input);
    _collectShards();
    _updateWarden(dt);
    _checkForCapture();
    _updateCamera(dt);
  }

  void deployEcho() {
    if (phase != _HabitPhase.playing || !echoReady) return;
    if (_routeTrace.length < 10) {
      message = 'MOVE THROUGH A LONGER ROUTE BEFORE CASTING AN ECHO.';
      return;
    }
    echo = _HabitEcho(List<Offset>.from(_routeTrace));
    _echoCooldown = 7.5;
    message = 'ECHO CAST · THE NEXT FOLD WILL FOLLOW YOUR OLD ROUTE.';
    GameFeedback.lightImpact();
  }

  void _buildArchive() {
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _columns; col++) {
        final id = row * _columns + col;
        rooms.add(
          _HabitRoom(
            id: id,
            row: row,
            col: col,
            bounds: Rect.fromLTWH(
              _marginX + col * (_roomWidth + _gapX),
              _marginY + row * (_roomHeight + _gapY),
              _roomWidth,
              _roomHeight,
            ),
          ),
        );
      }
    }
    _entryRoomId = 0;
    _wardenRoomId = 2 * _columns + 3;
    exit = rooms[_entryRoomId].bounds.center + const Offset(-58, -46);
    for (final room in rooms) {
      if (room.col + 1 < _columns) _addGate(room.id, room.id + 1);
      if (room.row + 1 < _rows) _addGate(room.id, room.id + _columns);
    }
    _buildConnectedBaseline();
  }

  void _addGate(int a, int b) {
    final first = rooms[a];
    final second = rooms[b];
    final horizontal = first.row == second.row;
    final passage = horizontal
        ? Rect.fromCenter(
            center: Offset(
              (first.bounds.right + second.bounds.left) / 2,
              first.bounds.center.dy,
            ),
            width: second.bounds.left - first.bounds.right + 10,
            height: 76,
          )
        : Rect.fromCenter(
            center: Offset(
              first.bounds.center.dx,
              (first.bounds.bottom + second.bounds.top) / 2,
            ),
            width: 76,
            height: second.bounds.top - first.bounds.bottom + 10,
          );
    gates.add(_HabitGate(gates.length, a, b, passage));
  }

  void _buildConnectedBaseline() {
    final visited = <int>{_entryRoomId};
    while (visited.length < rooms.length) {
      final candidates = gates.where((gate) {
        final aVisited = visited.contains(gate.a);
        final bVisited = visited.contains(gate.b);
        return aVisited != bVisited;
      }).toList();
      final next = candidates[_random.nextInt(candidates.length)];
      next.baselineOpen = true;
      visited
        ..add(next.a)
        ..add(next.b);
    }
    final extras = List<_HabitGate>.from(gates)..shuffle(_random);
    for (final gate in extras.take(10 + _campaignLevel ~/ 3)) {
      gate.baselineOpen = true;
    }
  }

  void _resetRun() {
    for (final shard in shards) {
      shard.collected = false;
    }
    if (shards.isEmpty) _placeShards();
    player = entryRoom.bounds.center + const Offset(24, 30);
    warden = wardenRoom.bounds.center;
    camera = Offset.zero;
    _lastRoomId = _entryRoomId;
    _foldOriginRoomId = _entryRoomId;
    _stolen = 0;
    _breakChain = 0;
    score = 0;
    time = 0;
    heat = 0;
    _readTimer = 3.6;
    _modeTimer = 0;
    _echoCooldown = 0;
    _traceTimer = 0;
    _readBroken = false;
    _wardenMode = _WardenMode.observing;
    _predictedDirection = _HabitDirection.east;
    _habit.updateAll((key, value) => 1);
    _routeTrace
      ..clear()
      ..add(player);
    _rewiredGateIds.clear();
    _sealedGateIds.clear();
    echo = null;
  }

  void _placeShards() {
    final candidates = List<_HabitRoom>.from(rooms)
      ..remove(entryRoom)
      ..remove(wardenRoom)
      ..sort((a, b) {
        final aDistance =
            (a.col - entryRoom.col).abs() + (a.row - entryRoom.row).abs();
        final bDistance =
            (b.col - entryRoom.col).abs() + (b.row - entryRoom.row).abs();
        return bDistance.compareTo(aDistance);
      });
    final selections = <_HabitRoom>[];
    for (final room in candidates) {
      final farFromEverySelection = selections.every(
        (selected) =>
            (selected.bounds.center - room.bounds.center).distance > 360,
      );
      if (farFromEverySelection) selections.add(room);
      if (selections.length == 5) break;
    }
    for (final room in selections) {
      final offset = Offset(
        -50 + _random.nextDouble() * 100,
        -38 + _random.nextDouble() * 76,
      );
      shards.add(_HabitShard(room.id, room.bounds.center + offset));
    }
  }

  void _movePlayer(double dt, Offset input) {
    var direction = input;
    if (direction.distance > 1) direction /= direction.distance;
    final moving = direction.distanceSquared > .01;
    if (moving) {
      final delta = direction * 238.0 * dt;
      final x = Offset(player.dx + delta.dx, player.dy);
      if (_walkable(x)) player = x;
      final y = Offset(player.dx, player.dy + delta.dy);
      if (_walkable(y)) player = y;
      _traceTimer -= dt;
      if (_traceTimer <= 0) {
        _routeTrace.add(player);
        if (_routeTrace.length > 46) _routeTrace.removeAt(0);
        _traceTimer += .12;
      }
    }
    final room = _roomAt(player);
    if (room != null && room.id != _lastRoomId) {
      _enterRoom(_lastRoomId, room.id);
      _lastRoomId = room.id;
    }
  }

  bool _walkable(Offset point) {
    if (!world.inflate(-_playerRadius).contains(point)) return false;
    if (rooms.any((room) => room.bounds.contains(point))) {
      return true;
    }
    return gates.any(
      (gate) => isGateOpen(gate) && gate.passage.contains(point),
    );
  }

  bool isGateOpen(_HabitGate gate) =>
      !_sealedGateIds.contains(gate.id) &&
      (gate.baselineOpen || _rewiredGateIds.contains(gate.id));

  bool isGateRewired(_HabitGate gate) => _rewiredGateIds.contains(gate.id);

  _HabitRoom? _roomAt(Offset point) {
    for (final room in rooms) {
      if (room.bounds.contains(point)) return room;
    }
    return null;
  }

  void _enterRoom(int fromId, int toId) {
    final gate = _gateBetween(fromId, toId);
    if (gate == null) return;
    final actual = _directionFromTo(fromId, toId);
    final expected = _predictedDirection;
    if (wardenReading) {
      final predicted = _directionLabel(expected);
      final moved = _directionLabel(actual);
      if (EchoHeistRules.breaksRead(
        predicted: predicted,
        actual: moved,
        wardenReading: true,
      )) {
        _breakRead();
      } else {
        heat = math.min(100, heat + 18 + habitConfidence * 12);
        message = 'THE WARDEN WAS RIGHT · $predicted IS NOW A LIABILITY.';
        GameFeedback.mediumImpact();
      }
    }
    _habit[actual] = _habit[actual]! + 1.45;
    _predictedDirection = _habit.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  void _updateWarden(double dt) {
    switch (_wardenMode) {
      case _WardenMode.observing:
        _readTimer -= dt;
        if (_readTimer <= 0) {
          if (habitConfidence >= .43 && _routeTrace.length >= 8) {
            _beginTelegraph();
          } else {
            _readTimer = 2.3;
            message = 'THE WARDEN NEEDS A CLEARER HABIT.';
          }
        }
      case _WardenMode.telegraphing:
        _modeTimer -= dt;
        if (_modeTimer <= 0) _beginFold();
      case _WardenMode.folding:
        _modeTimer -= dt;
        heat = math.min(100, heat + dt * (echo == null ? 5.4 : 2.2));
        if (_modeTimer <= 0) {
          if (!_readBroken) {
            heat = math.min(100, heat + 20);
            message = 'THE FOLD RESOLVED · YOUR HEAT SPIKES.';
            GameFeedback.heavyImpact();
          }
          _endFold();
        }
      case _WardenMode.recovering:
        _modeTimer -= dt;
        if (_modeTimer <= 0) {
          _wardenMode = _WardenMode.observing;
          _readTimer = 2.8;
          message = 'WARDEN RECALIBRATING · BUILD OR BREAK ANOTHER HABIT.';
        }
    }
  }

  void _beginTelegraph() {
    _predictedDirection = _habit.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    _wardenMode = _WardenMode.telegraphing;
    _modeTimer = math.max(.72, 1.22 - _campaignLevel * .018);
    _readBroken = false;
    message = 'WARDEN READ: $predictedDirection · TAKE A DIFFERENT DOOR.';
    GameFeedback.selection();
  }

  void _beginFold() {
    final echoRoom = echo == null ? null : _roomAt(echo!.position)?.id;
    _foldOriginRoomId = echoRoom ?? _lastRoomId;
    final route = _routeToCore(_foldOriginRoomId, _predictedDirection);
    _rewiredGateIds.clear();
    _sealedGateIds.clear();
    if (route.length >= 2) {
      for (var index = 0; index < route.length - 1 && index < 4; index++) {
        final gate = _gateBetween(route[index], route[index + 1]);
        if (gate != null) _rewiredGateIds.add(gate.id);
      }
      _shapeOriginChoice(route);
    }
    _wardenMode = _WardenMode.folding;
    _modeTimer = math.max(3.2, 5.2 - _campaignLevel * .08);
    message = echoRoom == null
        ? 'ARCHIVE FOLDING TOWARD THE WARDEN · BREAK THE READ.'
        : 'ECHO ACCEPTED · THE WARDEN FOLDS A DISTANT DISTRICT.';
    GameFeedback.mediumImpact();
  }

  List<int> _routeToCore(int origin, _HabitDirection preferred) {
    _HabitGate? first;
    for (final gate in gates) {
      if (gate.connects(origin) &&
          _directionFromTo(origin, gate.other(origin)) == preferred) {
        first = gate;
        break;
      }
    }
    if (first != null) {
      final tail = _shortestRoomPath(first.other(origin), _wardenRoomId);
      if (tail.isNotEmpty) return [origin, ...tail];
    }
    return _shortestRoomPath(origin, _wardenRoomId);
  }

  List<int> _shortestRoomPath(int start, int goal) {
    if (start == goal) return [start];
    final queue = <int>[start];
    final cameFrom = <int, int>{};
    final visited = <int>{start};
    while (queue.isNotEmpty) {
      final room = queue.removeAt(0);
      for (final gate in gates.where((gate) => gate.connects(room))) {
        final next = gate.other(room);
        if (!visited.add(next)) continue;
        cameFrom[next] = room;
        if (next == goal) {
          final path = <int>[goal];
          var cursor = goal;
          while (cameFrom.containsKey(cursor)) {
            cursor = cameFrom[cursor]!;
            path.add(cursor);
          }
          return path.reversed.toList(growable: false);
        }
        queue.add(next);
      }
    }
    return const [];
  }

  void _shapeOriginChoice(List<int> route) {
    final originGates = gates
        .where((gate) => gate.connects(_foldOriginRoomId))
        .toList();
    if (originGates.length < 2 || route.length < 2) return;
    final predictedGate = _gateBetween(route[0], route[1]);
    final alternatives =
        originGates.where((gate) => gate != predictedGate).toList()
          ..sort((a, b) {
            final aDistance =
                (rooms[a.other(_foldOriginRoomId)].bounds.center -
                        wardenRoom.bounds.center)
                    .distance;
            final bDistance =
                (rooms[b.other(_foldOriginRoomId)].bounds.center -
                        wardenRoom.bounds.center)
                    .distance;
            return bDistance.compareTo(aDistance);
          });
    final breakGate = alternatives.first;
    _rewiredGateIds.add(breakGate.id);
    for (final gate in originGates) {
      if (gate != predictedGate && gate != breakGate) {
        _sealedGateIds.add(gate.id);
      }
    }
  }

  void _breakRead() {
    _readBroken = true;
    _breakChain = math.min(5, _breakChain + 1);
    final bonus = EchoHeistRules.breakBonus(
      chain: _breakChain,
      campaignLevel: _campaignLevel,
    );
    score += bonus;
    heat = math.max(0, heat - 34 - _breakChain * 4);
    _endFold();
    _wardenMode = _WardenMode.recovering;
    _modeTimer = 1.35;
    message = 'HABIT FRACTURED +$bonus · THE WARDEN LOST THE THREAD.';
    GameFeedback.mediumImpact();
  }

  void _endFold() {
    _rewiredGateIds.clear();
    _sealedGateIds.clear();
    if (_wardenMode == _WardenMode.folding) {
      _wardenMode = _WardenMode.recovering;
      _modeTimer = 1.55;
    }
  }

  void _decayHabit(double dt) {
    for (final direction in _habit.keys.toList(growable: false)) {
      _habit[direction] = 1 + (_habit[direction]! - 1) * math.pow(.965, dt);
    }
  }

  void _updateEcho(double dt) {
    final active = echo;
    if (active == null) return;
    active.advance(dt);
    if (active.life <= 0) {
      echo = null;
      message = 'ECHO FADED · THE ARCHIVE IS LISTENING TO YOU AGAIN.';
    }
  }

  void _collectShards() {
    for (final shard in shards) {
      if (shard.collected || (shard.position - player).distance > 24) continue;
      shard.collected = true;
      _stolen++;
      score += 900 + _breakChain * 100;
      heat = math.min(100, heat + 7);
      message = exitOpen
          ? 'FINAL TRUTH STOLEN · BREACH OPEN. GET OUT.'
          : 'TRUTH FRAGMENT $_stolen/$requiredShards · THE ARCHIVE TIGHTENS.';
      GameFeedback.selection();
    }
    if (exitOpen && (player - exit).distance < 34) {
      phase = _HabitPhase.escaped;
      score += math.max(0, 2800 - time.round() * 12) + _breakChain * 350;
      message = 'ESCAPED WITH A FALSE HABIT.';
      GameFeedback.heavyImpact();
    }
  }

  void _checkForCapture() {
    if (heat < 100) return;
    phase = _HabitPhase.caught;
    message = 'THE WARDEN CLOSED THE MODEL AROUND YOU.';
    GameFeedback.heavyImpact();
  }

  void _updateCamera(double dt) {
    final wanted = Offset(
      (player.dx - width / 2).clamp(0.0, worldWidth - width),
      (player.dy - height / 2).clamp(0.0, worldHeight - height),
    );
    camera += (wanted - camera) * math.min(1, dt * 6.5);
  }

  _HabitGate? _gateBetween(int a, int b) {
    for (final gate in gates) {
      if ((gate.a == a && gate.b == b) || (gate.a == b && gate.b == a)) {
        return gate;
      }
    }
    return null;
  }

  _HabitDirection _directionFromTo(int from, int to) {
    final a = rooms[from];
    final b = rooms[to];
    if (b.col > a.col) return _HabitDirection.east;
    if (b.col < a.col) return _HabitDirection.west;
    return b.row > a.row ? _HabitDirection.south : _HabitDirection.north;
  }

  String _directionLabel(_HabitDirection direction) => switch (direction) {
    _HabitDirection.north => 'NORTH',
    _HabitDirection.east => 'EAST',
    _HabitDirection.south => 'SOUTH',
    _HabitDirection.west => 'WEST',
  };
}

class _HabitRoom {
  const _HabitRoom({
    required this.id,
    required this.row,
    required this.col,
    required this.bounds,
  });

  final int id;
  final int row;
  final int col;
  final Rect bounds;
}

class _HabitGate {
  _HabitGate(this.id, this.a, this.b, this.passage);

  final int id;
  final int a;
  final int b;
  final Rect passage;
  bool baselineOpen = false;

  bool connects(int room) => a == room || b == room;
  int other(int room) => room == a ? b : a;
}

class _HabitShard {
  _HabitShard(this.roomId, this.position);

  final int roomId;
  final Offset position;
  bool collected = false;
}

class _HabitEcho {
  _HabitEcho(this._path) : position = _path.first;

  final List<Offset> _path;
  Offset position;
  double life = 5.5;
  double _playback = 0;

  void advance(double dt) {
    life -= dt;
    _playback += dt;
    final progress = (_playback / 4.6).clamp(0.0, 1.0);
    final exact = progress * (_path.length - 1);
    final index = exact.floor().clamp(0, _path.length - 2);
    final t = exact - index;
    position = Offset.lerp(_path[index], _path[index + 1], t)!;
  }
}
