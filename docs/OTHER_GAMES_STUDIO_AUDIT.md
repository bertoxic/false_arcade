# False Arcade: non-Future-Debt studio audit

This is the current-state Phase 1 audit and the tailored Phase 2 direction for
NOT YET, EDGELOAD, FALSE HABIT, NUMBERFALL, and FALL DUE. FUTURE DEBT remains a
sibling game in the same six-game product and is intentionally out of scope.

## Portfolio findings

The collection has five genuinely marketable mechanical hooks rather than five
skins over one template. The strongest shared problem is communication: several
games contain deeper rules than their first-minute UI explains. The code also
has good shared foundations (`core/game_loop.dart`, `core/game_input.dart`, and
`ui/game_controls.dart`) but page-level input and lifecycle handling had drifted
between games.

Feedback is functional but not yet a production audio layer. Across these five
games there are 45 `GameFeedback` calls, but `core/game_feedback.dart` only
provides haptics and a throttled platform click. Its music preference does not
drive an actual soundtrack. Each game has coherent procedural vector art, but
character animation, bespoke sound, and authored environmental storytelling
remain below a premium commercial bar.

## NOT YET

### Phase 1 — candid audit

- **Core loop:** The best part is the LIFO consequence stack in
  `not_yet_simulation.dart`: holding NOT YET lets the world continue while
  damage, heals, bounties, defeats, and blasts wait, then resolves the newest
  consequence first. Interest and the 120% margin call make this a real timing
  decision. Shooting and circle-strafing are competent but conventional; the
  settlement choice is the product.
- **Levels and obstacles:** Six authored rosters plus deterministic campaign
  expansion vary enemy composition, spawn caps, moving drums, and interest.
  They still reuse one rectangular arena, so later sectors increase systemic
  pressure more than spatial problem-solving.
- **UI/UX:** Health, purge target, chain, debt, and settlement state are visible.
  Keyboard and touch are both supported. Before this pass, campaign timing used
  the global `time` field, which advances even on the title screen, rather than
  `_levelTime`; waiting at the briefing could damage the recorded clear time.
- **Narrative:** “Defer a consequence, then settle it” is mechanically expressed
  and has a consistent financial/reality voice. Character, place, and long-form
  stakes remain mostly campaign copy rather than events inside play.
- **Art:** The arena, stack effects, enemies, drums, and projectiles share a
  readable neon-vector language. Enemy families need more silhouette and motion
  distinction for a premium release.
- **Architecture:** The 1,165-line simulation is separated from page and painter,
  deterministic, and tunable. Particle and floating-label populations were not
  explicitly capped before this pass.

### Phase 2 — direction

Position it as a compact arena action roguelite calibrated against *Nuclear
Throne*, *Hades*, and *Nova Drift*. Its signature is not “another twin-stick
shooter”; it is tactical batching: create a dangerous consequence stack, move
to a settlement position, and cash it out in reverse order. Future level work
should add arena topologies that change settlement value—conductive lanes,
blast chambers, moving safe pockets—and narrative creditors whose rules are
encounter modifiers rather than cutscenes. Keep the graphic reality-breach art,
but give each liability family a distinct material and locomotion language.

This pass fixes authoritative run timing, caps transient effects, and makes
backgrounding enter a real paused state.

## EDGELOAD

### Phase 1 — candid audit

- **Core loop:** `edge_load_simulation.dart` has a commercially legible stealth
  extraction loop: scout, steal, distract, disguise, and return to the entry.
  Cargo physically shrinks `viewRect`, so greed directly reduces information.
  That is the distinctive mechanic. Automatic pickup prevents interaction
  friction, but it also means route commitment can happen by brushing loot.
- **Levels and obstacles:** Seeded room graphs vary rows, room sizes, corridors,
  cover, guards, loot, kits, and vault position. Campaign escalation adds only a
  small guard-count/type curve after layout generation, so late missions need
  more rule families—not merely denser patrols.
- **UI/UX:** Vision cones, guard states, prompts, fog, camera, and minimap are
  strong. The HUD previously showed money, coins, sprint, and disguise but not
  the actual extraction contract: diamond state and required cargo count.
  Desktop movement/actions were also missing.
- **Narrative:** “A mansion that closes around what you steal” is coherent and
  emerges from the shrinking viewport. The individual mansions currently have
  generated names but no owners, security doctrines, or consequences.
- **Art:** The architectural plan-view style is cohesive and suits stealth.
  Rooms remain materially similar, so generated layouts can feel like shuffled
  diagrams rather than different estates.
- **Architecture:** The 837-line simulation has authoritative walls shared by
  movement and sight rays, deterministic layout seeds, and bounded guards. Page
  input had drifted away from the shared `DirectionalInput` adapter.

### Phase 2 — direction

Calibrate against *Monaco*, *Invisible, Inc.*, and *The Swindle*. Build around
“greed edits perception”: optional valuables should close particular edges,
occlude map intelligence, or increase guard certainty in predictable ways.
Security doctrines should escalate from patrols to cameras, locked service
routes, sweep teams, and evidence recovery. Use restrained architectural
illustration—warm estate materials under cold security overlays—rather than
turning the mansions into another cyber arena.

This pass adds keyboard controls, focus-safe/background-safe pausing, and a
persistent diamond/loot/extraction objective readout.

## FALSE HABIT

### Phase 1 — candid audit

- **Core loop:** The original `echo_heist_simulation.dart` had a promising Warden
  prediction mechanic, but it happened in a bounded open field. The result was
  a score-chase where a correct answer was often movement away from a blob rather
  than a considered route decision.
- **Levels and obstacles:** Parameter changes altered Warden timing without
  changing the player's geography. There were no rooms, corridors, commitments,
  or return journey to make a learned habit emotionally legible.
- **UI/UX:** The earlier HUD described many internal values while hiding the
  immediate player question: which door does the Warden expect, which door breaks
  the read, and what must be stolen before extraction.
- **Narrative and art:** “An institution learns your habits” was worth retaining,
  but a generic arena could not sell an archive that rearranges itself. The visual
  system needed place, scale, and a tangible spatial consequence for the Warden's
  inference.
- **Architecture:** The old simulation was deterministic, but its world model
  could not express connected spaces or local topology changes. A replacement
  needed the room graph and the Warden's temporary rewrites to be authoritative
  in simulation rather than only painter effects.

### Phase 2 — implemented direction

Calibrated against *Heat Signature*, *Mark of the Ninja*, and *Invisible, Inc.*,
False Habit is now a compact route-infiltration game. Each run inhabits a seeded
24-room archive that exceeds the camera, with connected corridors, remote Truth
Fragments, and a return-to-Breach extraction objective. Repeating a doorway
direction trains the Warden. At sufficient confidence it telegraphs a read and
folds the current district into two viable doors: the predicted option gains
Heat; the surprising option fractures the model and creates score/combo relief.
An Echo repeats a real recent route and redirects the next fold around another
room, so it supports a deliberate escape plan.

The new visual language is a dark institutional archive—paper mineral, brass
cartography, rose inference lines, and a single watchful Warden core—rather than
an abstract neon arena. Difficulty increases through more required fragments,
tighter prediction confidence, longer return routes, and increasingly valuable
but exposed rooms, without removing the readable two-door counterplay.

## NUMBERFALL

### Phase 1 — candid audit

- **Core loop:** `numberfall_simulation.dart` makes the displayed three-digit
  score the actual collision geometry. Taking +1 or risky +2 rewrites the floor;
  preview outlines, support grace, reachability checks, coyote time, jump
  buffering, and catch dashes make the rule playable rather than arbitrary.
- **Levels and obstacles:** Five configurations escalate pickup goals, patrol
  speed/respawns, rewrite lead time, alternate routes, and risky choices.
  Because every stage uses the same three seven-segment cells, the game needs
  additional arithmetic verbs before raw speed can carry a full campaign.
- **UI/UX:** Rewrite preview and changed-segment outlines are excellent. The HUD
  explains current number and collection goal. Before this pass it was touch
  only and app focus loss did not leave a visible paused state.
- **Narrative:** “Your score is the level” is a strong premise and fully embedded
  in play. Story is otherwise abstract; that can work if each arithmetic rule
  develops a voice and consequence.
- **Art:** The seven-segment display is coherent, readable, and inseparable from
  the mechanic. Player/enemy rectangles are serviceable prototypes and the
  weakest character art in the collection.
- **Architecture:** The 867-line simulation keeps geometry authoritative and
  contains useful reachability and depenetration safeguards. The page had no
  desktop input adapter despite the platforming precision required.

### Phase 2 — direction

Calibrate against *N++*, *VVVVVV*, and *Baba Is You*. Preserve precision and
instant readability. Escalate through arithmetic operations with predictable
geometry consequences: +1 as the tutorial verb, controlled digit carry, risky
subtraction, and temporary segment locks. Never generate an unreadable or
unrecoverable rewrite. Visually, keep the monumental display but give actors a
distinct analogue-instrument character language rather than generic blocks.

This pass adds keyboard platforming, focus-safe input, true lifecycle pausing,
and clearer control onboarding.

## FALL DUE

### Phase 1 — candid audit

- **Core loop:** This remains the systemic benchmark. In
  `fall_due_simulation.dart`, one gravity ledger powers air movement, landing
  payback, crate bridges/lifts, enemy displacement, turret sabotage, levers, and
  clean-exit scoring. Give/Take makes debt spatial rather than a cooldown.
- **Levels and obstacles:** Six authored stages teach bridges, lifts, guards,
  debt dives, crossfire, and final integration; seeded contract families extend
  mastery play. This has the strongest real escalation in the arcade.
- **UI/UX:** Keyboard, touch, focus handling, checkpoint recovery, target cycling,
  and a loop guide already exist. Six simultaneous verbs create a high first-run
  comprehension cost. The top HUD showed stage and message but not a concise,
  persistent seal/lock/exit contract.
- **Narrative:** The physical weight of debt is consistently expressed. Stage
  names and messages carry tone, but no recurring collector or debtor develops
  across the route.
- **Art:** Gravity channels, debt meters, mechanisms, and long scrolling stages
  are cohesive and readable. Repeated platform materials limit location identity.
- **Architecture:** The simulation is 2,705 lines and owns authored stages,
  procedural contract generation, physics, objectives, entities, and feedback.
  Public `FallDueRules` tests protect key invariants, but the file is now the
  clearest maintenance hotspot in the project.

### Phase 2 — direction

Calibrate against *Celeste*, *Gravity Rush 2*, and *Portal 2*: precise movement,
a readable gravity fantasy, and mechanics taught through spatial problems.
Keep Give/Take, but stage new interactions one at a time and reserve target
cycling for multi-object puzzles. Split future content data and contract
generation out of the simulation before adding more stage families. Art should
feel like a monumental civic debt machine—concrete, brass, counterweights, and
paper seals—rather than borrowing Future Debt's biological enemy language.

This pass adds a persistent objective readout that reports seals, locks, or the
open exit. The next architecture increment should split stage content from the
physics runtime without changing behavior.

## Recommended production order

1. Finish input, focus, objective, and lifecycle parity across the collection.
2. Add per-game assist/difficulty profiles and remappable bindings.
3. Add one new content family per game, validated by deterministic rule tests.
4. Replace system clicks with a real licensed/original SFX and adaptive-music
   layer while retaining the existing feedback preferences.
5. Profile on target mobile hardware, then optimize measured painter/UI costs.
