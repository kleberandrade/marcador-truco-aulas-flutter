# Modernization log — 2026-11-17

- Cloned the repository; clean original checkout, no local instructions or existing user changes. Read manifests and all original Dart source before choosing migration.
- Confirmed Flutter 3.41.9 / Dart 3.11.5; no global SDK installation or upgrade. Android doctor reports unaccepted licenses; did not accept them.
- Followed test-first domain work: observed test compilation failure before implementing Match, then passing boundary/winner/reset tests.
- Replaced nullable mutable Player with immutable validated Match. Kept manual scoring to twelve, confirmation/cancel-to-eleven and cumulative victories. No regional game engine inferred.
- Added versioned local persistence; original implementation had none. Corrupt records remain intact until explicit user action. Added persistence/widget tests.
- Rebuilt screen hierarchy, spacing, typography, cards, team editing, confirmation dialogs, responsive layout, loading and error feedback. Real Chrome preview exposed progress semantics swallowing controls; excluded decorative progress semantics and rebuilt.
- Regenerated platform configuration from installed Flutter templates, preserving identifiers and launcher assets. Web is the verified build target; native releases/signing remain unverified.
- Added reproducible CI workflow and local example snapshot. Rewrote README in English, kept tutorial attribution and MIT license.
- Opened/read original Medium article. Chrome shows Sign in/Sign up; no editorial session. Prepared a complete Portuguese technical revision at medium-update.pt-BR.md; nothing published to Medium.
- Updated GitHub About in English and verified five existing useful topics: card-game, dart, education, flutter, scoreboard.
- Inspected crapper/dryer/mutator help: Dart unsupported. No fabricated metric or mutation score.

- Final local checks: analyzer clean; seven tests passed including 390px layout with 150% text. Chrome scoring + reload recovery verified; desktop screenshot recorded. Browser viewport override did not resize the preview, so narrow layout validation is widget-based only.
- Web release build passed with --no-wasm-dry-run. The experimental Wasm probe stalled amid concurrent local builds; only this project's probe was stopped, then the JavaScript build completed. No Wasm support claimed.
- iOS simulator attempt first exposed minimum target 13 incompatibility with Xcode 27.2; raised app/pods minimum to 15. Retry failed in Flutter debug_unpack_ios architecture checking (expected arm64 x86_64 although lipo lists both). Native build remains unverified.

- Published ordered commits f444734 (toolchain/platform), efca5d2 (domain/persistence/visual/tests), 689d04a (docs/CI) to origin/master after explicit push authorization. Checked remote default branch, no protection enabled, no force push.
- Final extracted-widget source: analyzer clean, seven tests passed, release Web build passed (213.7s). First GitHub run 44083367197 passed dependency/format/analyze/test stages; build status tracked separately.

## iOS follow-up and Medium lesson revision

- Reproduced the architecture failure: upstream Flutter issue https://github.com/flutter/flutter/issues/188461 identifies Xcode 27 lipo rejecting multi-arch verify. Added project-scoped simulator Debug arm64, with no shared Flutter SDK edits. Using NATIVE_ARCH_ACTUAL first built generically but failed a concrete destination because Xcode host can report arm64e; explicit simulator-supported arm64 fixed that root cause. Intel simulator Debug needs x86_64 and remains unverified.
- Built Runner.app successfully, installed/launched on iPhone 17 Pro / iOS 26.4.1 with simctl. This Xcode installation contains no Simulator.app GUI; native integration tests drive the real simulator app, and simctl screenshots provide visual evidence.
- Added integration_test from the Flutter SDK and a native end-to-end test using real SharedPreferences, covering rename, 12-point win cancel/confirm, reset preserving wins and reconstructed-screen recovery. Native integration passed; analyzer clean; seven local tests passed.
- Checked pub outdated and pub upgrade --major-versions. Direct dependencies already latest compatible; raised shared_preferences manifest minimum to resolved 2.5.6. No incompatible overrides or global SDK changes.
- The project's IAB Medium tab now has an authenticated author session and Edit story access. Read original content and preserved a temporary reference before replacing outdated sections with a step-by-step Portuguese lesson, real images and new cover. Publication verification recorded below when complete.
