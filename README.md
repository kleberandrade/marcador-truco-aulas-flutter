# Mesa de Truco · Truco Scoreboard

![Flutter 3.41.9](https://img.shields.io/badge/Flutter-3.41.9-02569B)
![Dart 3.11.5](https://img.shields.io/badge/Dart-3.11.5-0175C2)
[![MIT](https://img.shields.io/badge/license-MIT-555555)](LICENSE)

An offline two-team scoreboard, originally created by Kleber de Oliveira Andrade for mobile programming classes. Portuguese interface, modern Flutter, no account or backend required.

## Run

Verified with Flutter **3.41.9**, bundled Dart **3.11.5**, and Chrome on macOS. Do not use the original Dart 2 toolchain.

```sh
flutter pub get
flutter run -d chrome
```

## Play

- Tap a team name to rename it (1–24 trimmed characters).
- Use +1 / −1 for manual scoring, bounded to 0–12.
- At 12, confirm the victory: the winner gains one victory and both scores reset. Cancel returns the winner to 11. The confirmation cannot be dismissed by tapping outside or pressing Back.
- New match resets points while keeping names and victories. Reset session clears points and victories after confirmation.
- Names, points, victories and pending winner confirmation resume from this browser/device. Save errors are visible and offer retry. Browser storage can be cleared by the browser and is not a backup.
- At 11–11 the interface reminds players to agree on iron-hand rules.

This preserves the original tutorial's manual twelve-point game. It does **not** enforce Paulista, Mineiro or other regional card rules, bidding, hands, or online play. Add the agreed hand value by tapping +1 repeatedly. Always-on screen behavior remains an exercise.

Try a match locally: rename teams to Amigos/Visitantes, give them points, reload and check recovery. `docs/example-match.json` is a versioned fixture (11–8, 2–1 victories), usable with `Match.decode`; there is no import UI.

## Architecture and migration

`lib/domain/match.dart` owns immutable validated state and pure transitions. `lib/data/match_store.dart` isolates local storage. `TeamBoard` renders reusable team cards. `HomePage` owns interaction and serializes saves by disabling controls during writes; Material controls support keyboard focus and accessible semantics. Layout stacks cards on narrow screens and uses two columns from 650 logical pixels. Loading, invalid-save and save-error states are explicit.

Original code stored everything in memory, so there are no persisted legacy records to migrate. New records use `truco.match.v1`, a single JSON snapshot with schema version 1. Unknown versions and malformed values are rejected without overwriting until a user explicitly saves/starts playing. Future schema changes must migrate this key and retain compatibility tests.

Android and iOS scaffolds were regenerated from Flutter 3.41.9 templates, preserving the original `com.example.marcador_truco` application identity and launcher assets. These are classroom development identifiers; release signing is not configured. The MIT license and original authorship remain unchanged.

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web --no-wasm-dry-run
```

Seven local tests cover score boundaries, winner lock/cancel/confirm, resets, name validation, serialized round trips, persistence recovery, corrupt-save preservation and widget interactions. The GitHub workflow in `.github/workflows/flutter.yml` runs analysis/tests/Web builds after it is pushed; no remote passing status is claimed.

Web build and Chrome preview were exercised locally. Android licenses are incomplete; no licenses were accepted. Android builds and physical devices were not validated. iOS simulator compilation was attempted: after correcting the minimum target to iOS 15 for Xcode 27.2, Flutter failed to package its simulator engine with an architecture check despite lipo listing both architectures. This is an unresolved local toolchain limitation, not a successful native build. Xcode 27.2 and Android SDK 36.1.0 were detected. `crapper`, `dryer`, and `mutator` are installed but their supported language lists exclude Dart; no CRAP, duplication or mutation score is claimed.

## Original lesson

[Creating a Truco scoreboard in Flutter (Portuguese)](https://medium.com/flutter-comunidade-br/criando-um-marcador-de-truco-em-flutter-e50669f21f03), by Kleber Andrade (2019), originally linked via http://bit.ly/2MDO6ww. The modernized code implements the lesson's boundary, restart, modal confirmation and rename exercises. See [prepared article revision](docs/medium-update.pt-BR.md) and [work log](docs/WORK_LOG.md).

## License

[MIT](LICENSE), Copyright 2019 Kleber de Oliveira Andrade. Flutter and platform-generated resources retain their respective licenses. No third-party article text or artwork is bundled.
