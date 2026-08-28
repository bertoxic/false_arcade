# False Arcade

False Arcade is a Flutter collection of six minimalist, systemic skill games.
Each game has its own rules and visual identity while sharing a small runtime
foundation for timing, input, math, presentation, and reusable controls.

## Games

- **NOT YET** — defer combat consequences, then settle the stack.
- **EDGELOAD** — trade arena space for increasingly valuable cargo.
- **FALSE HABIT** — train a predictive Warden, then break its commitment.
- **NUMBERFALL** — platform across a seven-segment number that rewrites itself.
- **FALL DUE** — borrow gravity, transfer it, and repay it through movement.
- **FUTURE DEBT** — borrow abilities now and survive their scheduled lockouts.

The app is designed for landscape touch play and also supports desktop input in
the games where keyboard bindings are shown on the start overlay.

## Run and verify

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

For a production Android artifact:

```sh
flutter build apk --release
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Repository audit](docs/REPOSITORY_AUDIT.md)
- [Gameplay and tuning](docs/GAMEPLAY.md)
- [Adding games, levels, obstacles, abilities, and assets](docs/CONTENT_GUIDE.md)
# false_arcade
