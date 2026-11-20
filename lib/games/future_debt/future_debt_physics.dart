part of 'future_debt_game.dart';

double? _rayRectDistance(Offset origin, Offset direction, Rect rect) {
  var enter = 0.0;
  var exit = double.infinity;

  bool clip(double position, double velocity, double low, double high) {
    if (velocity.abs() < .000001) return position >= low && position <= high;
    final near = (low - position) / velocity;
    final far = (high - position) / velocity;
    enter = math.max(enter, math.min(near, far));
    exit = math.min(exit, math.max(near, far));
    return enter <= exit;
  }

  if (!clip(origin.dx, direction.dx, rect.left, rect.right) ||
      !clip(origin.dy, direction.dy, rect.top, rect.bottom)) {
    return null;
  }
  return enter;
}

extension on _FutureDebtGame {
  void _advancePlayer(double dt, Offset input) {
    if (isLocked(_DebtKind.move)) {
      cancelTransientInput();
      movementTrailTimer = 0;
      return;
    }
    final inputLength = input.distance;
    moveDirection = inputLength > .1 ? input / inputLength : Offset.zero;
    if (moveDirection != Offset.zero) dashDirection = moveDirection;
    final speed = 205 * (moveBoost > 0 ? 2 : 1) * _anchorSlowdown;
    final goal = moveDirection * speed * inputLength.clamp(0.0, 1.0);
    final acceleration = moveDirection == Offset.zero ? 3400.0 : 2700.0;
    velocity += cappedMagnitude(goal - velocity, acceleration * dt);

    final previous = player;
    final step = velocity * dt;
    player = moveBoost > 0
        ? _clampWorld(player + step, _FutureDebtGame.playerRadius)
        : _moveCircle(player, _FutureDebtGame.playerRadius, step.dx, step.dy);
    final actual = player - previous;
    velocity = actual / dt;
    final distance = actual.distance;
    if (distance > .08) {
      stride += distance * .15;
      _emitMovementTrail(dt);
    } else {
      movementTrailTimer = 0;
    }
  }

  void _advanceDash(double dt) {
    final stepTime = math.min(dt, dashRemaining);
    const duration = _FutureDebtGame._dashDuration;
    final from = FutureDebtRules.dashTravelFraction(
      1 - dashRemaining / duration,
    );
    final to = FutureDebtRules.dashTravelFraction(
      1 - (dashRemaining - stepTime) / duration,
    );
    final step =
        _dashTravelDirection * ((_borrowedDash ? 120 : 96) * (to - from));
    final previous = player;
    if (_borrowedDash) {
      player = _clampWorld(player + step, _FutureDebtGame.playerRadius);
      final wall = _wallAtCircle(player, _FutureDebtGame.playerRadius);
      if (wall != null) {
        _damageWall(wall, 220 * stepTime, player);
      }
    } else if (moveBoost > 0) {
      player = _clampWorld(player + step, _FutureDebtGame.playerRadius);
    } else {
      player = _moveCircle(
        player,
        _FutureDebtGame.playerRadius,
        step.dx,
        step.dy,
      );
    }
    dashRemaining = math.max(0, dashRemaining - stepTime);
    if (dashRemaining > .000001 && (player - previous).distanceSquared > .001) {
      return;
    }
    dashRemaining = 0;
    if (_borrowedDash && moveBoost <= 0) _reconcileAfterPhase();
    screenShake = math.max(screenShake, 6);
    _powerPulse(player, _futureGold, 67);
    _burst(player, 16, _FutureParticleType.dash);
    enemyShots.removeWhere((shot) {
      final hit =
          (shot.position - player).distanceSquared < 64 * 64 &&
          _hasClearShot(player, shot.position);
      if (hit) _burst(shot.position, 4, _FutureParticleType.spark);
      return hit;
    });
    for (final enemy in enemies) {
      if (enemy.dead) continue;
      final delta = enemy.position - player;
      final distance = delta.distance;
      if (distance >= 75 || !_hasClearShot(player, enemy.position)) continue;
      final force = 1 - .75 * distance / 75;
      enemy.impulse +=
          normalizedOr(delta, fallback: _dashTravelDirection) * (650 * force);
      enemy.lastHitAt = time;
      enemy.health -= .6 * force;
      if (enemy.health <= 0) _killEnemy(enemy);
      _burst(enemy.position, 8, _FutureParticleType.hit);
    }
    ArcadeShake.shake(.3);
  }

  /// Resolve large impulses in bounded steps and keep the free axis sliding.
  Offset _moveCircle(Offset position, double radius, double dx, double dy) {
    final count = math.max(
      1,
      (math.max(dx.abs(), dy.abs()) / (radius * .4)).ceil(),
    );
    final stepX = dx / count;
    final stepY = dy / count;
    var result = position;
    for (var i = 0; i < count; i++) {
      result = _moveCircleAxis(result, radius, Offset(stepX, 0));
      result = _moveCircleAxis(result, radius, Offset(0, stepY));
    }
    return result;
  }

  Offset _moveCircleAxis(Offset origin, double radius, Offset step) {
    if (step == Offset.zero) return origin;
    final end = _clampWorld(origin + step, radius);
    if (!_blocked(end, radius)) return end;
    var free = 0.0;
    var blocked = 1.0;
    for (var i = 0; i < 5; i++) {
      final midpoint = (free + blocked) / 2;
      if (_blocked(Offset.lerp(origin, end, midpoint)!, radius)) {
        blocked = midpoint;
      } else {
        free = midpoint;
      }
    }
    return Offset.lerp(origin, end, free)!;
  }

  void _updateShots(double dt) {
    for (final shot in shots) {
      _advanceShot(shot, dt, friendly: true);
    }
    shots.removeWhere((shot) => shot.dead);
    for (final shot in enemyShots) {
      _advanceShot(shot, dt, friendly: false);
    }
    enemyShots.removeWhere((shot) => shot.dead);
    enemies.removeWhere((enemy) => enemy.dead);
  }

  void _advanceShot(_FutureShot shot, double dt, {required bool friendly}) {
    final origin = shot.position;
    final step = shot.velocity * math.min(dt, shot.life);
    final broad = Rect.fromPoints(origin, origin + step).inflate(shot.radius);
    var earliest = double.infinity;
    Object? impact;
    for (final wall in walls) {
      if (wall.health <= 0 || !wall.bounds.overlaps(broad)) continue;
      final fraction = FutureDebtRules.sweptCoverImpact(
        origin,
        step,
        wall.bounds,
        shot.radius,
      );
      if (fraction == null || fraction >= earliest) continue;
      earliest = fraction;
      impact = wall;
    }

    void checkActor(Object actor, Offset position, double radius) {
      final fraction = FutureDebtRules.sweptCircleImpact(
        origin,
        step,
        position,
        radius + shot.radius,
      );
      if (fraction == null || fraction >= earliest) return;
      earliest = fraction;
      impact = actor;
    }

    if (friendly) {
      for (final enemy in enemies) {
        if (!enemy.dead) checkActor(enemy, enemy.position, enemy.radius);
      }
      for (final echo in echoes) {
        if (!echo.dead && echo.type != _FutureEchoType.anchor) {
          checkActor(echo, echo.position, echo.radius);
        }
      }
      if (collector case final boss?) {
        checkActor(boss, boss.position, boss.radius);
      }
    } else if (moveBoost <= 0) {
      checkActor(this, player, _FutureDebtGame.playerRadius);
    }

    shot.position = origin + step * math.min(earliest, 1);
    shot.life -= dt;
    shot.dead = impact != null || shot.life <= 0;
    switch (impact) {
      case _FutureWall wall:
        if (friendly && wall.destructible) {
          _damageWall(wall, shot.damage, shot.position);
        } else {
          _burst(shot.position, 3, _FutureParticleType.spark);
        }
      case _FutureEnemy enemy:
        enemy.health -= shot.damage;
        enemy.lastHitAt = time;
        enemy.impulse +=
            normalizedOr(shot.velocity) * (shot.charged ? 170 : 100);
        _burst(shot.position, 5, _FutureParticleType.spark);
        if (enemy.health <= 0) _killEnemy(enemy);
      case _FutureEcho echo:
        _hitEcho(shot, echo);
      case _FutureCollector boss:
        boss.health -= shot.damage * .35;
        boss.lastHitAt = time;
        _burst(shot.position, 3, _FutureParticleType.repay);
      case _FutureDebtGame _:
        if (reversalBoost > 0 && shot.life > 0) {
          _reverseShot(shot);
        } else if (reversalBoost <= 0) {
          _hitPlayer(2.6, source: origin);
        }
      case _:
        break;
    }
  }
}
