part of 'edge_load_game.dart';

enum _MansionPhase { intro, playing, caught, extracted }

enum _GuardState { patrol, suspicious, alert, search }

class _MansionGame {
  /// The logical screen stays fixed while the mansion is deliberately much larger.
  /// This is what makes the camera follow the runner instead of showing the full map.
  static const width = 960.0;
  // Match the device's landscape play area. The mansion remains larger than
  // this viewport, so the camera keeps the surrounding map off-screen.
  static const height = 540.0;
  static const disguiseDuration = 4.0;
  static const mansionWidth = 1760.0;
  static const mansionHeight = 1160.0;
  final int _layoutSeed;
  final int campaignLevel;
  late final math.Random _random;
  late _Runner player;
  late List<_MansionRoom> rooms;
  late List<_MansionCorridor> corridors;
  late List<_Wall> walls;
  late List<_Cover> covers;
  late List<_Guard> guards;
  late List<_Loot> loot;
  late List<_DisguiseKit> kits;
  late Offset exit;
  late Offset vault;
  late Offset camera;
  final List<_Coin> coins = [];
  final List<_Noise> noises = [];
  _MansionPhase phase = _MansionPhase.intro;
  double time = 0;
  double messageTimer = 0;
  String message = 'INFILTRATE · STEAL THE DIAMOND · GET OUT';
  bool vaultTaken = false;
  bool _interactQueued = false;
  bool _disguiseQueued = false;
  bool _coinQueued = false;
  bool sprinting = false;

  _MansionGame({int? layoutSeed, this.campaignLevel = 1})
    : _layoutSeed = layoutSeed ?? math.Random().nextInt(0x7fffffff) {
    _random = math.Random(_layoutSeed ^ 0x2C1B3C6D);
    _reset();
  }

  String get layoutName =>
      _layoutNames[(_layoutSeed >>> 4) % _layoutNames.length];

  int get cargoCount => player.lootCount + (vaultTaken ? 1 : 0);
  int get requiredLootCount => 3 + campaignLevel ~/ 4;
  bool get extractionReady =>
      vaultTaken && player.lootCount >= requiredLootCount;
  String get objectiveReadout {
    if (!vaultTaken) {
      return 'DIAMOND 0/1 · LOOT ${player.lootCount}/$requiredLootCount';
    }
    if (player.lootCount < requiredLootCount) {
      return 'DIAMOND SECURED · LOOT ${player.lootCount}/$requiredLootCount';
    }
    return 'EXTRACTION READY · RETURN TO ENTRY';
  }

  double get cargoInset =>
      12 + math.min(92, player.lootCount * 9 + (vaultTaken ? 10 : 0));
  Rect get world => const Rect.fromLTWH(0, 0, mansionWidth, mansionHeight);

  Rect get viewRect => Rect.fromLTRB(
    cargoInset,
    cargoInset,
    width - cargoInset,
    height - cargoInset,
  );

  void start() {
    _reset();
    phase = _MansionPhase.playing;
    message = 'INFILTRATE · STEAL THE DIAMOND · GET OUT';
    messageTimer = 4;
  }

  void restart() => start();
  void queueInteract() => _interactQueued = true;
  void queueDisguise() => _disguiseQueued = true;
  void queueCoin() => _coinQueued = true;

  void _reset() {
    final layoutRandom = math.Random(_layoutSeed);
    final layout = _generateLayout(layoutRandom);
    rooms = layout.rooms;
    corridors = layout.corridors;
    covers = _makeCovers(layout, layoutRandom);
    walls = [..._makeWalls(), for (final cover in covers) ...cover.walls];
    player = _Runner(_roomPoint(layout.entryRoom, layoutRandom));
    exit = player.position;
    vault = _roomPoint(layout.vaultRoom, layoutRandom);
    camera = Offset.zero;
    loot = _makeLoot(layout, layoutRandom);
    kits = _makeKits(layout, layoutRandom);
    guards = _makeGuards(layout, layoutRandom);
    coins.clear();
    noises.clear();
    vaultTaken = false;
    time = 0;
    sprinting = false;
    _interactQueued = _disguiseQueued = _coinQueued = false;
  }

  _MansionLayout _generateLayout(math.Random random) {
    final rowCount = campaignLevel >= 7 || random.nextInt(3) == 0 ? 4 : 3;
    final rowStarts = rowCount == 4
        ? const [42.0, 305.0, 570.0, 835.0]
        : const [55.0, 405.0, 755.0];
    final rows = <List<_MansionRoom>>[];
    final generatedRooms = <_MansionRoom>[];

    for (var row = 0; row < rowCount; row++) {
      final rowRooms = <_MansionRoom>[];
      final roomCount = 3 + random.nextInt(3);
      var x = 42.0 + random.nextDouble() * 70;
      for (var index = 0; index < roomCount; index++) {
        final remaining = roomCount - index - 1;
        final desired = _roomSize(random);
        final roomWidth = math
            .min(desired.width, mansionWidth - 46 - x - remaining * (124 + 54))
            .clamp(124.0, 355.0)
            .toDouble();
        final roomHeight = desired.height;
        final y = rowStarts[row] + random.nextDouble() * 30;
        final room = _MansionRoom(Rect.fromLTWH(x, y, roomWidth, roomHeight));
        rowRooms.add(room);
        generatedRooms.add(room);
        if (remaining > 0) {
          final availableGap =
              mansionWidth -
              46 -
              (x + roomWidth) -
              (remaining * 124 + (remaining - 1) * 54);
          x +=
              roomWidth +
              math.min(54 + random.nextDouble() * 122, availableGap);
        }
      }
      rows.add(rowRooms);
    }

    final generatedCorridors = <_MansionCorridor>[];
    for (final row in rows) {
      for (var index = 0; index < row.length - 1; index++) {
        final left = row[index].rect;
        final right = row[index + 1].rect;
        generatedCorridors.add(
          _MansionCorridor(
            Rect.fromLTWH(
              left.right,
              (left.center.dy + right.center.dy) / 2 - 19,
              right.left - left.right,
              38,
            ),
          ),
        );
      }
    }
    for (var row = 0; row < rows.length - 1; row++) {
      final top = rows[row][random.nextInt(rows[row].length)].rect;
      final bottom = rows[row + 1]
          .reduce(
            (closest, room) =>
                (room.rect.center.dx - top.center.dx).abs() <
                    (closest.rect.center.dx - top.center.dx).abs()
                ? room
                : closest,
          )
          .rect;
      final corridorHeight = bottom.top - top.bottom;
      if (corridorHeight > 0) {
        generatedCorridors.add(
          _MansionCorridor(
            Rect.fromLTWH(
              (top.center.dx + bottom.center.dx) / 2 - 19,
              top.bottom,
              38,
              corridorHeight,
            ),
          ),
        );
      }
    }

    final entryRoom = generatedRooms.reduce(
      (left, right) =>
          left.rect.center.dx < right.rect.center.dx ? left : right,
    );
    final farRooms = List<_MansionRoom>.from(generatedRooms)
      ..sort(
        (left, right) => (right.rect.center - entryRoom.rect.center).distance
            .compareTo((left.rect.center - entryRoom.rect.center).distance),
      );
    return _MansionLayout(
      rooms: generatedRooms,
      corridors: generatedCorridors,
      entryRoom: entryRoom,
      vaultRoom: farRooms[random.nextInt(math.min(3, farRooms.length))],
    );
  }

  Size _roomSize(math.Random random) {
    final roll = random.nextInt(100);
    if (roll < 32) {
      return Size(
        126 + random.nextDouble() * 54,
        104 + random.nextDouble() * 38,
      );
    }
    if (roll < 78) {
      return Size(
        188 + random.nextDouble() * 82,
        132 + random.nextDouble() * 56,
      );
    }
    return Size(276 + random.nextDouble() * 74, 170 + random.nextDouble() * 42);
  }

  Offset _roomPoint(_MansionRoom room, math.Random random) {
    final rect = room.rect;
    final inset = math.min(
      44.0,
      math.max(24.0, math.min(rect.width, rect.height) / 2 - 18),
    );
    for (var attempt = 0; attempt < 24; attempt++) {
      final point = Offset(
        rect.left + inset + random.nextDouble() * (rect.width - inset * 2),
        rect.top + inset + random.nextDouble() * (rect.height - inset * 2),
      );
      if (!covers.any((cover) => cover.bounds.inflate(28).contains(point))) {
        return point;
      }
    }
    return Offset(rect.left + inset, rect.top + inset);
  }

  List<_Cover> _makeCovers(_MansionLayout layout, math.Random random) {
    final covers = <_Cover>[];
    for (var roomIndex = 0; roomIndex < layout.rooms.length; roomIndex++) {
      final room = layout.rooms[roomIndex];
      final r = room.rect;
      // Tiny rooms stay clear so their doorway remains a reliable escape route.
      if (r.width < 154 || r.height < 126) continue;

      final coverCount = r.width >= 236 && r.height >= 158 && random.nextBool()
          ? 2
          : 1;
      for (var index = 0; index < coverCount; index++) {
        final shape = (roomIndex + index).isEven
            ? _CoverShape.partition
            : _CoverShape.pillar;
        final horizontal = random.nextBool();
        final size = shape == _CoverShape.pillar
            ? const Size(30, 30)
            : horizontal
            ? const Size(72, 18)
            : const Size(18, 72);
        final candidate = _coverInRoom(r, size, shape, random, covers);
        if (candidate != null) covers.add(candidate);
      }
    }
    return covers;
  }

  _Cover? _coverInRoom(
    Rect room,
    Size size,
    _CoverShape shape,
    math.Random random,
    List<_Cover> existing,
  ) {
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    const edgeInset = 30.0;
    final minX = room.left + halfWidth + edgeInset;
    final maxX = room.right - halfWidth - edgeInset;
    final minY = room.top + halfHeight + edgeInset;
    final maxY = room.bottom - halfHeight - edgeInset;
    if (minX > maxX || minY > maxY) return null;

    for (var attempt = 0; attempt < 20; attempt++) {
      final center = Offset(
        minX + random.nextDouble() * (maxX - minX),
        minY + random.nextDouble() * (maxY - minY),
      );
      final cover = _Cover(center, size, shape);
      if (!existing.any(
        (other) => other.bounds.inflate(38).overlaps(cover.bounds),
      )) {
        return cover;
      }
    }
    return null;
  }

  List<_Loot> _makeLoot(_MansionLayout layout, math.Random random) {
    final lootRooms = List<_MansionRoom>.from(layout.rooms)
      ..remove(layout.entryRoom)
      ..remove(layout.vaultRoom)
      ..shuffle(random);
    final count = math.min(9, lootRooms.length);
    return [
      for (var index = 0; index < count; index++)
        _Loot(_roomPoint(lootRooms[index], random), 55 + random.nextInt(80)),
    ];
  }

  List<_DisguiseKit> _makeKits(_MansionLayout layout, math.Random random) {
    final kitRooms = List<_MansionRoom>.from(layout.rooms)
      ..remove(layout.entryRoom)
      ..remove(layout.vaultRoom)
      ..shuffle(random);
    return [
      for (var index = 0; index < math.min(3, kitRooms.length); index++)
        _DisguiseKit(_roomPoint(kitRooms[index], random)),
    ];
  }

  List<_Guard> _makeGuards(_MansionLayout layout, math.Random random) {
    final patrolRooms = List<_MansionRoom>.from(layout.rooms)
      ..remove(layout.entryRoom)
      ..shuffle(random);
    final guardCount = math.min(
      patrolRooms.length,
      6 + ((campaignLevel - 1) / 4).floor(),
    );
    return [
      for (var index = 0; index < guardCount; index++)
        _Guard(
          _roomPoint(patrolRooms[index], random),
          index >= 3 && (index.isEven || campaignLevel >= 12)
              ? _GuardType.advanced
              : _GuardType.normal,
          [
            for (var point = 0; point < 3; point++)
              _roomPoint(patrolRooms[index], random),
          ],
        ),
    ];
  }

  List<_Wall> _makeWalls() {
    final out = <_Wall>[];
    for (final room in rooms) {
      final r = room.rect;
      void side(
        bool horizontal,
        double fixed,
        double a,
        double b,
        double door,
      ) {
        final d0 = (a + b) / 2 - door / 2, d1 = (a + b) / 2 + door / 2;
        out.add(
          horizontal
              ? _Wall(Offset(a, fixed), Offset(d0, fixed))
              : _Wall(Offset(fixed, a), Offset(fixed, d0)),
        );
        out.add(
          horizontal
              ? _Wall(Offset(d1, fixed), Offset(b, fixed))
              : _Wall(Offset(fixed, d1), Offset(fixed, b)),
        );
      }

      side(true, r.top, r.left, r.right, 58);
      side(true, r.bottom, r.left, r.right, 58);
      side(false, r.left, r.top, r.bottom, 58);
      side(false, r.right, r.top, r.bottom, 58);
    }
    return out;
  }

  void update(double dt, Offset input, bool sprintHeld) {
    if (phase != _MansionPhase.playing) return;
    time += dt;
    messageTimer = math.max(0, messageTimer - dt);
    player.disguise = math.max(0, player.disguise - dt);
    player.hitFlash = math.max(0, player.hitFlash - dt);
    _updatePlayer(dt, input, sprintHeld);
    _autoCollectNearby();
    if (_interactQueued) _interact();
    if (_disguiseQueued) _activateDisguise();
    if (_coinQueued) _throwCoin();
    _interactQueued = _disguiseQueued = _coinQueued = false;
    for (final coin in coins) {
      coin.timer -= dt;
      if (coin.timer <= 0 && !coin.popped) {
        coin.popped = true;
        noises.add(_Noise(coin.position, 280, 1));
      }
    }
    coins.removeWhere((coin) => coin.timer < -1.2);
    for (final n in noises) {
      n.life -= dt;
    }
    noises.removeWhere((n) => n.life <= 0);
    for (final guard in guards) {
      _updateGuard(guard, dt);
    }
    _updateCamera(dt);
  }

  void _updatePlayer(double dt, Offset input, bool sprintHeld) {
    var direction = input;
    if (direction.distance > 1) direction /= direction.distance;
    final moving = direction.distanceSquared > .01;
    sprinting = moving && sprintHeld && player.stamina > 1;
    if (moving) player.face = math.atan2(direction.dy, direction.dx);
    final speed = sprinting ? 225.0 : 145.0;
    final old = player.position;
    _moveRunner(player, direction * speed * dt, 10);
    final moved = (player.position - old).distance;
    player.moveAmount +=
        ((moved > .02 ? 1 : 0) - player.moveAmount) * math.min(1, dt * 14);
    if (moved > .02) player.walkTime += moved * (sprinting ? .13 : .1);
    if (sprinting) {
      player.stamina = math.max(0, player.stamina - dt * 28);
      player.noise += dt;
      if (player.noise > .2) {
        _noise(player.position, 210);
        player.noise = 0;
      }
    } else {
      player.stamina = math.min(100, player.stamina + dt * 18);
      if (moving) {
        player.noise += dt;
        if (player.noise > .58) {
          _noise(player.position, 105);
          player.noise = 0;
        }
      } else {
        player.noise = 0;
      }
    }
  }

  void _moveRunner(_Runner actor, Offset delta, double radius) {
    final x = Offset(actor.position.dx + delta.dx, actor.position.dy);
    if (_walkable(x, radius)) actor.position = x;
    final y = Offset(actor.position.dx, actor.position.dy + delta.dy);
    if (_walkable(y, radius)) actor.position = y;
  }

  bool _walkable(Offset p, double r) {
    if (p.dx < r ||
        p.dy < r ||
        p.dx > mansionWidth - r ||
        p.dy > mansionHeight - r) {
      return false;
    }
    return !covers.any((cover) => cover.bounds.inflate(r + 1).contains(p)) &&
        !walls.any((wall) => _pointSegmentDistance(p, wall) < r + 1);
  }

  double _pointSegmentDistance(Offset p, _Wall wall) {
    final d = wall.b - wall.a;
    final len = d.distanceSquared;
    final t = len == 0
        ? 0.0
        : (((p - wall.a).dx * d.dx + (p - wall.a).dy * d.dy) / len)
              .clamp(0, 1)
              .toDouble();
    return (p - (wall.a + d * t)).distance;
  }

  /// Uses the same ray cast as the rendered guard fan. A wall blocks vision
  /// whether the guard is indoors looking out or outdoors looking into a room.
  bool _clearSight(Offset a, Offset b) {
    final delta = b - a;
    return _rayWallDistance(
          a,
          math.atan2(delta.dy, delta.dx),
          delta.distance,
        ) >=
        delta.distance - .5;
  }

  double _rayWallDistance(Offset origin, double angle, double maxDistance) {
    final ray = Offset(math.cos(angle), math.sin(angle));
    var nearest = maxDistance;
    double cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;
    for (final wall in walls) {
      final segment = wall.b - wall.a;
      final denominator = cross(ray, segment);
      if (denominator.abs() < .00001) continue;
      final start = wall.a - origin;
      final rayDistance = cross(start, segment) / denominator;
      final segmentDistance = cross(start, ray) / denominator;
      if (rayDistance >= 0 &&
          segmentDistance >= 0 &&
          segmentDistance <= 1 &&
          rayDistance < nearest) {
        nearest = rayDistance;
      }
    }
    return nearest;
  }

  void _updateGuard(_Guard g, double dt) {
    g.pulse += dt;
    final distance = (player.position - g.position).distance;
    final toPlayer = player.position - g.position;
    final angle = math.atan2(toPlayer.dy, toPlayer.dx);
    final vision = g.advanced ? 255.0 : 210.0;
    final seesPlayer =
        player.disguise <= 0 || (g.advanced && (distance < 115 || sprinting));
    final inCone =
        (angle - g.face + math.pi * 3).remainder(math.pi * 2) - math.pi;
    if (seesPlayer &&
        distance < vision &&
        inCone.abs() < (g.advanced ? .8 : .95) &&
        _clearSight(g.position, player.position)) {
      if (g.state != _GuardState.alert) {
        GameFeedback.alarm();
      }
      g.state = _GuardState.alert;
      g.target = player.position;
      g.alert = 2.5;
    } else if (g.state == _GuardState.alert) {
      g.alert -= dt;
      if (g.alert <= 0) {
        g.state = _GuardState.search;
        g.search = 3;
      }
    }
    if (g.state != _GuardState.alert) {
      for (final n in noises.reversed) {
        if ((n.position - g.position).distance < n.radius &&
            _clearSight(g.position, n.position)) {
          g.state = _GuardState.suspicious;
          g.target = n.position;
          g.search = 2;
          break;
        }
      }
    }
    if (g.state == _GuardState.alert) {
      _guardMove(g, player.position, (g.advanced ? 135 : 150) * dt);
      if (distance < 22) {
        phase = _MansionPhase.caught;
        message = 'A GUARD REACHED YOU DURING PURSUIT.';
        GameFeedback.defeat();
        ArcadeShake.shake(0.7);
        ArcadeFlash.flash(const Color(0xFFFF2244), 0.28);
      }

    } else if (g.state == _GuardState.suspicious ||
        g.state == _GuardState.search) {
      _guardMove(g, g.target, 95 * dt);
      g.search -= dt;
      if ((g.position - g.target).distance < 12 || g.search <= 0) {
        if (g.state == _GuardState.search) {
          _beginAreaPatrol(g);
        } else {
          g.state = _GuardState.patrol;
        }
      }
    } else {
      final target = g.route[g.routeIndex];
      _guardMove(g, target, 72 * dt);
      if ((g.position - target).distance < 12) {
        g.routeIndex = (g.routeIndex + 1) % g.route.length;
      }
    }
  }

  void _beginAreaPatrol(_Guard g) {
    final center = g.target;
    g.route = [
      center,
      _nearbyPatrolPoint(center),
      _nearbyPatrolPoint(center),
      _nearbyPatrolPoint(center),
    ];
    g.routeIndex = 0;
    g.state = _GuardState.patrol;
  }

  Offset _nearbyPatrolPoint(Offset center) {
    for (var attempt = 0; attempt < 20; attempt++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final distance = 36 + _random.nextDouble() * 94;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (_walkable(point, 12) && _clearSight(center, point)) return point;
    }
    return center;
  }

  void _guardMove(_Guard g, Offset target, double amount) {
    final d = target - g.position;
    if (d.distance < 1) return;
    final wanted = math.atan2(d.dy, d.dx);
    // Direct movement is preferred. If a wall or world edge is in the way,
    // test increasingly wider steering angles. This lets guards slide along
    // walls to a doorway instead of repeatedly colliding and freezing.
    const turns = [
      0.0,
      .38,
      -.38,
      .78,
      -.78,
      1.18,
      -1.18,
      math.pi / 2,
      -math.pi / 2,
    ];
    for (final turn in turns) {
      final angle = wanted + turn;
      final step = Offset(math.cos(angle), math.sin(angle)) * amount;
      final candidate = g.position + step;
      if (!_walkable(candidate, 12)) continue;
      g.position = candidate;
      g.face = angle;
      g.walkTime += amount * .11;
      g.moveAmount += (1 - g.moveAmount) * .35;
      return;
    }
    g.face += (_random.nextBool() ? 1 : -1) * .55;
    g.moveAmount *= .6;
  }

  void _interact() {
    for (final k in kits.where((e) => !e.taken)) {
      if ((k.position - player.position).distance < 48) {
        k.taken = true;
        player.kits++;
        _message('DISGUISE KIT ACQUIRED · TAP MASK TO USE');
        GameFeedback.pickup();
        return;
      }
    }
    if (!vaultTaken && (vault - player.position).distance < 52) {
      vaultTaken = true;
      player.loot += 300;
      player.lootCount++;
      _message('VAULT DIAMOND SECURED · REACH EXTRACTION');
      GameFeedback.pickup();
      GameFeedback.combo();
      ArcadeShake.shake(0.35);
      ArcadeHitStop.freeze(0.06);
      ArcadeFlash.flash(const Color(0xFF72D6FF), 0.22);
      ArcadeFever.charge(0.35, currentMusicTheme: 'stealth_theme');
      return;
    }
    for (final l in loot.where((e) => !e.taken)) {
      if ((l.position - player.position).distance < 44) {
        l.taken = true;
        player.loot += l.value;
        player.lootCount++;
        _message('LOOT SECURED · YOUR VIEWPORT SHRINKS');
        GameFeedback.pickup();
        ArcadeFever.charge(0.12, currentMusicTheme: 'stealth_theme');
        return;
      }
    }
    if ((exit - player.position).distance < 58) {
      if (extractionReady) {
        phase = _MansionPhase.extracted;
        _message('EXTRACTION COMPLETE');
        GameFeedback.victory();
        ArcadeAchievements.unlock('phantom_heist');
        if (player.lootCount >= loot.length) {
          ArcadeAchievements.unlock('max_capacity');
        }
      } else if (vaultTaken) {
        _message(
          'EXTRACTION NEEDS ${requiredLootCount - player.lootCount} MORE LOOT ITEM${requiredLootCount - player.lootCount == 1 ? '' : 'S'}',
        );
      } else {
        _message('EXTRACTION LOCKED · STEAL THE DIAMOND');
      }
    }

  }

  void _autoCollectNearby() {
    final closeToCollectible =
        kits.any(
          (kit) => !kit.taken && (kit.position - player.position).distance < 48,
        ) ||
        (!vaultTaken && (vault - player.position).distance < 52) ||
        loot.any(
          (item) =>
              !item.taken && (item.position - player.position).distance < 44,
        ) ||
        (vaultTaken && (exit - player.position).distance < 58);
    if (closeToCollectible) _interact();
  }

  void _activateDisguise() {
    if (player.kits <= 0) {
      _message('NO DISGUISE KITS');
      return;
    }
    if (player.disguise > 0) return;
    player.kits--;
    player.disguise = disguiseDuration;
    _message('DISGUISED FOR 4 SECONDS');
    GameFeedback.selection();
  }

  void _throwCoin() {
    if (player.coins <= 0) {
      _message('NO COINS LEFT');
      return;
    }
    player.coins--;
    coins.add(
      _Coin(
        player.position +
            Offset(math.cos(player.face) * 72, math.sin(player.face) * 72),
      ),
    );
    _message('COIN THROWN');
    GameFeedback.selection();
  }

  void _noise(Offset at, double radius) => noises.add(_Noise(at, radius, .55));
  void _message(String text) {
    message = text;
    messageTimer = 2.4;
  }

  void _updateCamera(double dt) {
    final v = viewRect.size;
    final wanted = Offset(
      (player.position.dx - v.width / 2).clamp(0.0, mansionWidth - v.width),
      (player.position.dy - v.height / 2).clamp(0.0, mansionHeight - v.height),
    );
    camera += (wanted - camera) * math.min(1, dt * 7);
  }
}

class _Runner {
  _Runner(this.position);
  Offset position;
  double face = 0,
      stamina = 100,
      noise = 0,
      walkTime = 0,
      moveAmount = 0,
      disguise = 0,
      hitFlash = 0;
  int coins = 3, kits = 0, loot = 0, lootCount = 0;
}

enum _GuardType { normal, advanced }

class _Guard {
  _Guard(this.position, this.type, this.route) : target = route.first;
  Offset position, target;
  final _GuardType type;
  List<Offset> route;
  int routeIndex = 0;
  double face = 0,
      pulse = 0,
      walkTime = 0,
      moveAmount = 0,
      alert = 0,
      search = 0;
  _GuardState state = _GuardState.patrol;
  bool get advanced => type == _GuardType.advanced;
}

class _MansionRoom {
  const _MansionRoom(this.rect);
  final Rect rect;
}

class _MansionCorridor {
  const _MansionCorridor(this.rect);
  final Rect rect;
}

class _MansionLayout {
  const _MansionLayout({
    required this.rooms,
    required this.corridors,
    required this.entryRoom,
    required this.vaultRoom,
  });

  final List<_MansionRoom> rooms;
  final List<_MansionCorridor> corridors;
  final _MansionRoom entryRoom;
  final _MansionRoom vaultRoom;
}

const _layoutNames = [
  'COMPACT SUITES',
  'LONG GALLERY',
  'CROSS-CORRIDOR ESTATE',
  'GRAND SALON NETWORK',
  'SERVICE WING MAZE',
  'PRIVATE ROOM CIRCUIT',
  'SPLIT-LEVEL RESIDENCE',
];

class _Wall {
  const _Wall(this.a, this.b);
  final Offset a, b;
}

enum _CoverShape { partition, pillar }

class _Cover {
  const _Cover(this.center, this.size, this.shape);

  final Offset center;
  final Size size;
  final _CoverShape shape;

  Rect get bounds =>
      Rect.fromCenter(center: center, width: size.width, height: size.height);

  List<_Wall> get walls {
    final r = bounds;
    return [
      _Wall(r.topLeft, r.topRight),
      _Wall(r.topRight, r.bottomRight),
      _Wall(r.bottomRight, r.bottomLeft),
      _Wall(r.bottomLeft, r.topLeft),
    ];
  }
}

class _Loot {
  _Loot(this.position, this.value);
  final Offset position;
  final int value;
  bool taken = false;
}

class _DisguiseKit {
  _DisguiseKit(this.position);
  final Offset position;
  bool taken = false;
}

class _Coin {
  _Coin(this.position);
  final Offset position;
  double timer = .55;
  bool popped = false;
}

class _Noise {
  _Noise(this.position, this.radius, this.life);
  final Offset position;
  final double radius;
  double life;
}
