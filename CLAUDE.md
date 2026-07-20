# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"E&J Geek Invoice" — a Flutter invoicing/accounting app (`name: ej_geek` in `pubspec.yaml`). Very early stage: currently only a splash screen and a placeholder home screen exist; no auth, no data layer, no state management library is wired up yet.

## Commands

- `flutter pub get` — install/update dependencies (run after any `pubspec.yaml` change)
- `flutter analyze` — static analysis (uses `package:flutter_lints/flutter.yaml`, see `analysis_options.yaml`)
- `flutter test` — run all tests; `flutter test test/widget_test.dart` for a single file
- `flutter run` — run on a connected device/emulator; `flutter devices` to list targets
- `dart run flutter_native_splash:create` — regenerate native (pre-engine) launch screen files after changing the `flutter_native_splash:` config block in `pubspec.yaml`. Never hand-edit the generated platform files directly (see below).

## Architecture

The codebase follows a clean-architecture, feature-first layout under `lib/`:

- `lib/core/` — app-shell / cross-cutting UI that isn't tied to one feature (splash screen, placeholder home screen). Structured as `core/presentation/pages/` for screens and `core/presentation/widgets/<group>/` for the small stateless widgets that compose them (e.g. `core/presentation/widgets/splash/` holds the individual animated pieces — icon, title, subtitle, dots, progress bar — that `core/presentation/pages/splash_screen.dart` assembles).
- `lib/features/<feature>/` — feature-specific code, intended to split into `data/`, `domain/`, `presentation/` layers per feature as they're built out (e.g. an eventual `features/auth/` for login). Nothing beyond the folder convention exists here yet.

Splash screen animation pattern (`lib/core/presentation/pages/splash_screen.dart`): one `StatefulWidget` with `TickerProviderStateMixin` owns a separate `AnimationController` per animated element (icon, title, subtitle, dots, progress bar) and staggers them via sequential `await Future.delayed(...)` calls before each `.forward()`. Each visual piece is a `StatelessWidget` that only receives `Animation` objects as constructor params (no controller ownership), so they stay independently reusable/testable. Follow this split — controller/timing logic in the page, presentation-only logic in the widget — when adding new animated screens.

### Native splash screen

`flutter_native_splash` is configured via the `flutter_native_splash:` block at the bottom of `pubspec.yaml` (currently solid black, no image). This generates the native Android/iOS/web launch-screen files (`android/app/src/main/res/**/launch_background.xml`, `**/styles.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`, `web/index.html`, etc.) — these are generated output, not hand-maintained. Change the `pubspec.yaml` config and re-run `dart run flutter_native_splash:create` instead of editing them directly.
