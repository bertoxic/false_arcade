# Architecture

## Design goals

The project deliberately uses a compact feature-oriented layout. A solo
developer should be able to find an entire game without traversing a deep
framework hierarchy. Infrastructure is shared; game rules are not.

```text
lib/
  main.dart                    application entry point
  app/                         launcher, theme, and game catalogue
  core/                        timing, math, input, difficulty, lifecycle
  ui/                          reusable controls and run overlays
  games/
    not_yet/                   one independent feature module per game
    edge_load/
    false_habit/
    numberfall/
    fall_due/
    future_debt/
test/
  core/                        deterministic foundation tests
  games/                       game-rule regression tests
  widget_test.dart             launcher and navigation smoke tests
assets/
  README.md                    asset policy and naming
docs/
```

The dependency direction is one-way:

```text
main → app → games → core/ui
                   ↘ Flutter SDK
```

`core` never imports a game. Games do not import one another. A game may use
shared controls and primitives, but its stage definitions, abilities, scoring,
actors, and rendering remain local to that feature.

## Runtime foundation

### Fixed simulation

`GameLoopController` owns the Flutter ticker and advances a `FixedStepClock` at
120 Hz. A wall-clock frame can perform multiple bounded simulation steps. This
keeps acceleration, collision, cooldowns, and debt schedules consistent across
display refresh rates. The clock caps catch-up work and drops only excess time
beyond that safety budget, preventing an unrecoverable update spiral.

The controller resets its accumulator on manual pause and app lifecycle
changes. Input must also be cleared whenever a page pauses, loses focus,
restarts, or transitions to a non-playing phase.

### Coordinate and physics conventions

- World distance is expressed in logical pixels.
- Time is expressed in seconds.
- Velocity is logical pixels per second.
- Acceleration and gravity are logical pixels per second squared.
- Positive X points right; positive Y points down.
- Positions represent either an entity centre or an AABB top-left, as declared
  by that game's model. A single model must not mix both conventions.
- Damping uses `v(t + dt) = v(t) × retention^dt`, so it is frame-rate
  independent.
- Deliberately arcade-like gravity is valid; discontinuous or unexplained
  gravity is not.

`game_math.dart` contains safe normalization, vector rotation, magnitude caps,
exponential damping, overlap helpers, inverse interpolation, and smooth-step
curves. Shared formulas live here only when at least two games benefit.

### Input

`DirectionalInput` merges normalized analog input with WASD/arrow keys. The
simulation receives an action or axis, never a raw pointer. Edge-triggered
actions must ignore keyboard repeat; held actions must have matching release
and cancellation paths.

### Gameplay utilities

`Cooldown`, `DifficultyCurve`, and `ComboMeter` are intentionally small value
objects. They standardise common timer and progression semantics without
forcing unrelated games into a common entity or ability hierarchy.

### Presentation

`GamePresentation` owns landscape and immersive system-UI policy. Shared UI in
`ui/` provides touch controls, pause/restart/exit behavior, and consistent
minimum hit targets. Game-specific HUDs remain with their game because their
information hierarchy is part of the game design.

## Game module contract

Each feature module owns four conceptual layers, even when a small game keeps
them in one file:

1. Page/host — lifecycle, input adapters, and overlays.
2. Simulation — authoritative state and update rules.
3. Content — tuning, stages, waves, abilities, and entity definitions.
4. Painter — a read-only view of simulation state.

The painter must never mutate gameplay. Collision and rendering should consume
the same authoritative geometry—for example, an extraction gate has one `Rect`
used by both the model and painter.

## Randomness and repeatability

Random generators are injected or created from a run seed by game simulations.
Randomness may vary encounter composition, but must not determine whether a
required route or objective is possible. Procedural content should be assembled
from validated challenge chunks with safe entrances, exits, and recovery paths.

## State transitions

Every game distinguishes at least intro, playing, stage clear, dead, and won or
endless states. Only the playing simulation advances gameplay clocks. Paused,
backgrounded, and result overlays freeze the model. Stage transitions explicitly
declare which run resources persist; debt or risk may never disappear merely as
an accidental side effect of clearing a list.

## Performance policy

- Entity populations have explicit caps or lifetimes.
- Per-frame lists are mutated or reused rather than allowed to grow forever.
- Static painter work should be cached when profiling shows it is material.
- Broad-phase spatial indexing is added only when population sizes justify it.
- Long worlds cull rendering against the camera viewport.
- Particle pooling is unnecessary at the current restrained effect counts.

Correctness, population bounds, and avoiding full-tree rebuilds are higher
priority than micro-optimising individual arithmetic operations.
