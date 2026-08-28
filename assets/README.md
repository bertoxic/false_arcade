# Asset policy

False Arcade currently renders its minimalist environments, actors, particles,
and indicators procedurally with Flutter canvas primitives. This is intentional:
it keeps silhouettes consistent, scales cleanly, and avoids duplicate assets.

If external assets are introduced, place reusable files under `shared/` and
game-owned files under `games/<game_id>/`. Use lowercase snake_case filenames
and separate `textures/`, `sprites/`, `audio/`, and `effects/` only when those
categories exist. Register only required directories in `pubspec.yaml`.
