# Adding content

## Add a game

1. Create `lib/games/<game_id>/<game_id>_game.dart`.
2. Keep the simulation independent from every other game.
3. Drive it with `GameLoopController` and `GamePresentation`.
4. Consume normalized actions/axes; reset them on pause, focus loss, restart,
   death, and route exit.
5. Put tunable rules in an immutable game tuning or stage configuration type.
6. Render in a stable logical viewport and use the same geometry for drawing
   and collisions.
7. Add the page and player-facing description to the app catalogue.
8. Add navigation, phase-transition, and defining-mechanic tests.

## Add a level

1. Decide what the level teaches, combines, and tests.
2. Declare geometry, objective requirements, spawn/wave budget, checkpoints,
   rewards, par time, and available abilities in game-local immutable data.
3. Ensure the spawn is supported and clear, every mandatory objective is
   reachable, and every required movable object can be recovered.
4. Use alternate routes for risk/reward; do not make random placement decide
   whether the level is completable.
5. Verify the level from a clean start and every checkpoint.

For procedural levels, use seeded challenge chunks with compatible entrances
and exits. Validate bounds and mandatory resources before accepting the result.

## Add an obstacle

1. Define one authoritative geometry/state model.
2. State whether it is solid, one-way, hazardous, destructible, moving, or a
   trigger, and which entity categories it affects.
3. Add telegraph and recovery timing before damage where appropriate.
4. Make the painter consume that same model geometry.
5. Test high-speed contact, corners, state changes, and checkpoint restoration.

## Add an ability

Keep abilities local to their game unless two games genuinely share the same
contract. Add the tuning and state transition first, then input, feedback, HUD,
and tests. A generic inheritance tree is not required.

Cooldowns use seconds and may use the shared `Cooldown` type. Held abilities
must handle pointer cancel, focus loss, pause, death, and stage transitions.

## Add assets

The current art is procedural and intentionally has no bitmap dependency. If a
file asset becomes necessary, use:

```text
assets/
  shared/<type>/<descriptive_name>.<ext>
  games/<game_id>/<type>/<descriptive_name>.<ext>
```

Put an asset in `shared` only when multiple games actually use it. Use lowercase
snake_case names, avoid duplicate variants, register the narrowest directory in
`pubspec.yaml`, and add a loading/fallback test. Audio names should describe the
event (`player_land_soft.wav`) rather than an implementation (`sound_07.wav`).

## Verification checklist

After a gameplay or content change:

```sh
dart format lib test
flutter analyze
flutter test
```

Before release, also build the intended production target and manually verify
touch cancellation, keyboard focus, background/resume, pause/restart/exit, all
stage transitions, and compact landscape layout.
