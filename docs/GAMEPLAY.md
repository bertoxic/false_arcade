# Gameplay and tuning

## Product principles

- Reuse infrastructure, not game identity.
- Skill-based pressure must be readable before it becomes punishing.
- A risky choice needs both a visible upside and a recoverable downside.
- Scores reward mastery events, not reversible-action farming.
- Minimal effects should clarify state, timing, and impact.

## Game identities

### NOT YET

The skill loop is positioning while consequences are deferred, choosing a
deliberate release point, and surviving last-in-first-out settlement. Debt
raises payout, clean controlled releases build chain, and a full credit line
causes a lower-value margin call. Moving volatile drums make release position a
tactical choice in advanced sectors.

### EDGELOAD

Cargo is simultaneously score, obstacle, and arena compression. The player
evaluates value versus footprint, arranges selected cargo around the border,
survives the topology they created, and extracts through a concrete side gate.
Late districts add enemy behaviors and topology pressure rather than only more
health or speed.

### FALSE HABIT

False Habit is a return heist through a 24-room living archive, not an arena
score chase. The Warden learns a repeated doorway direction, then folds the
nearby map into a predicted route and an unexpected route. Taking the unexpected
door fractures the read, cools Heat, and keeps the extraction run alive. Echoes
replay a recent route and pull the next fold into another district, creating a
planned deception rather than a generic distraction. A run ends only after the
player steals enough Truth Fragments and returns to the original Breach.

### NUMBERFALL

The displayed three-digit number is authoritative collision geometry. Rewrites
preview before committing so the player can read changed segments. Pickups are
placed on reachable routes, and actors are reconciled after every geometry
transaction. Later stages vary enemy and rewrite pressure while preserving the
legibility of seven-segment shapes.

### FALL DUE

Borrow provides immediate lift and creates a gravity liability. Give transfers
weight into enemies, crates, turrets, and route mechanisms; Take creates lifts
and launches. Payback turns landing into force. Authored stages teach one
interaction, combine it, then demand routing, timing, and resource control.
Endless contracts follow the completed campaign as an explicit mastery mode.

### FUTURE DEBT

Borrowed actions schedule visible future lockouts. The ten-second ledger is a
planning surface, not decoration: simultaneous bills aggregate, sector changes
do not erase obligations, and Total Default consistently restricts borrowing.
Bankruptcy is an intentional Collector encounter, while risk multipliers reward
performing under a heavy but readable ledger.

## Tuning rules

Important values belong in a game tuning object or immutable stage definition:

- movement acceleration, maximum speed, air control, and damping;
- gravity, jump impulse, coyote time, and jump buffer;
- spawn intervals, caps, telegraph duration, and wave composition;
- ability duration, cooldown, charge rules, and resource costs;
- stage targets, par times, objective rewards, and multiplier limits.

Use a named value when changing it affects player strategy or when the value is
repeated. Tiny one-off drawing measurements may remain local to a painter.

## Difficulty

Difficulty should grow through a budget of understandable pressures:

1. Teach one verb in a safe space.
2. Ask the player to repeat it under light time pressure.
3. Combine it with one previously learned verb.
4. Offer a safe route and an optional mastery route.
5. Shorten telegraphs or add simultaneous pressures without hiding information.

`DifficultyCurve` is suitable for monotonic intervals and multipliers. Authored
stage data remains preferable when geometry or objective order carries meaning.

## Ability checklist

Every ability or borrowed action defines:

- purpose and player decision;
- activation and cancellation rules;
- duration, cooldown, cost, and capacity;
- valid and invalid states;
- interaction with hazards, enemies, and objectives;
- failure or counterplay;
- visual, textual, haptic, and optional audio feedback;
- a regression test for its most important invariant.

If two abilities solve the same problem in the same way, merge or redesign one.
