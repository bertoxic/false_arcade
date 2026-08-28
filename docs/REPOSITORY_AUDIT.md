# Repository audit

This audit records the state found before the overhaul and the architectural
decisions made from it. It is intentionally concise; game-specific tuning and
extension rules live in the other guides.

## Scope found

The active product was a root Flutter application with six games:

| Product title | Original module | Core mechanic |
| --- | --- | --- |
| NOT YET | `main.dart` | defer and LIFO-settle combat outcomes |
| EDGELOAD | `edge_load_game.dart` | cargo physically compresses the arena |
| FALSE HABIT | `echo_heist_game.dart` | train and betray a prediction |
| NUMBERFALL | `numberfall_game.dart` | score digits are platform geometry |
| FALL DUE | `fall_due_game.dart` | borrow/transfer/repay gravity |
| FUTURE DEBT | `future_debt_game.dart` | abilities schedule future lockouts |

All actors, environments, particles, and UI were procedurally rendered. There
were no production texture, sprite, audio, or network dependencies. A second
nested `fluga/` directory was an untouched Flutter counter template, was not
referenced by the active package, and duplicated every platform scaffold. It
was removed from the workspace after those checks.

Baseline verification before changes: `flutter analyze` had no issues and all
five original widget tests passed. Those tests covered launch/navigation and two
control flows, but not simulation rules.

## Cross-cutting findings

- Every game duplicated ticker delta calculation, pause checks, orientation,
  and system-UI restoration.
- Delta time was clamped and discarded, causing slow-motion and divergent debt,
  jump, and collision behavior during dropped frames.
- Input was mostly touch-only. Held input could survive pause, focus loss, or a
  phase transition in several games.
- Exponential damping was generally correct but duplicated; normalization and
  collision checks were inconsistent.
- Each game rebuilt a broad widget subtree every frame. Several also built
  permanently hidden legacy HUD trees.
- Random generators were constructed internally, making rule tests
  nondeterministic.
- Paint/text objects were often allocated per draw. This was secondary to more
  important unbounded entity lists and full-tree rebuilds.
- Shared bitmap/audio assets did not exist, so inventing an asset hierarchy or
  dependency would have increased footprint without player value.
- The launcher and the full NOT YET implementation shared a 2,600-line entry
  file; every other game was also a monolithic vertical slice.

## Game findings that drove the redesign

### NOT YET

The consequence stack was distinctive, but holding had no time pressure, chain
could grow without a clean-play requirement, and levels varied mostly through
enemy rosters. Controlled settlement, interest/margin calls, moving liabilities,
near-miss feedback, and explicit tuning were the highest-value improvements.

### EDGELOAD

The rendered exit and collision zone disagreed; curse growth used stage age
instead of cargo age; initial loot could trivialize every target; arena shrink
could strand or teleport entities; and enemies/pickups were not bounded. Cargo
selection and side arrangement needed to become deliberate.

### FALSE HABIT

The Warden homed toward the current player rather than committing to a learned
prediction, so the advertised fantasy affected score more than threat behavior.
Prediction sampling, lockdown thresholds, and one-action stage economy were also
inconsistent.

### NUMBERFALL

Stage spawn could use an unlit digit segment, a rewrite could materialize
geometry inside actors, stomp rewrites did not revalidate the pickup, and
“reachable” pickup placement only measured distance. Render and collision also
selected different digits above 999.

### FALL DUE

This was the strongest design because one gravity resource already connected
movement, combat, crates, turrets, route construction, and scoring. Its most
important faults were checkpoint soft-locks, optional puzzle gates, a severe
Borrow acceleration discontinuity, reversible score farming, contradictory
campaign/endless completion, and short authored stages.

### FUTURE DEBT

The bankruptcy/Collector control was permanently hidden, stage transitions
forgave every bill, auto-aim changed dash direction, Total Default still allowed
borrowing, charge progress was painted behind an opaque layer, and enemy spawns
could make the displayed kill target dishonest.

## Resulting decisions

- Use a small feature-oriented source tree, not a general-purpose game engine.
- Standardize fixed-step timing, lifecycle, math, input, cooldowns, difficulty,
  and reusable controls.
- Keep simulation/content/painter boundaries inside each independent game.
- Make game geometry authoritative and shared by rendering and collision.
- Add explicit tuning and stage configuration where a value affects strategy.
- Preserve procedural minimalism and document where future assets belong.
- Add deterministic core tests and game-rule regressions before relying on more
  widget smoke tests.
- Treat FALL DUE as the systemic-depth benchmark while preserving all six
  different fantasies.
