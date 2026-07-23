# E&J Geek Invoice

A Flutter invoicing/accounting app (`ej_geek`). Early stage: a splash screen, a dashboard home screen, and an invoice-creation bottom sheet with Inspection and Invoice tabs.

## Features

- **Dashboard** — home screen shell with quick-action chats/widgets and a floating action button that opens the invoice-creation bottom sheet.
- **Invoice bottom sheet** — a segmented Inspection / Invoice tab flow for creating an invoice. Each invoice-creation session is tied together by a client-generated `invoiceId` (no backend id system yet).
- **Inspection** — the app's first fully data-backed feature and the reference implementation for how new features are built:
  - Vehicle details (make, model, rego, year, odometer, VIN, engine no.)
  - A 5-section pass/fail checklist (Interior, Exterior, Engine Bay, Tyres/Wheels & Brakes, Road Test), each item rated Good / Fair / Repair / N/A / N/C, plus a per-section comment
  - A photo picker (camera or gallery), images downscaled on capture
  - Saved locally via SQLite; reopening the tab for an invoice that already has a saved inspection restores its vehicle details, checklist, and photos instead of starting blank
  - PDF export is not implemented yet

No authentication or remote backend exists yet — everything is local to the device.

## Architecture

Feature-first, clean-architecture layout under `lib/`:

- `lib/core/` — cross-cutting app-shell UI (splash screen, dashboard shell) and infrastructure shared across features:
  - `core/database/` — SQLite access (`sqflite`) via a single `AppDatabase` singleton
  - `core/storage/` — on-device file paths for images/PDFs
  - `core/error/` — the app-wide exceptions/failures convention
  - `core/usecases/` — the shared `UseCase<Output, Params>` base class
  - `core/di/` — `get_it` service locator wiring
- `lib/features/<feature>/` — each feature split into `domain/` (entities, repositories, usecases), `data/` (datasources, repository implementations), and `presentation/` (bloc or provider state, widgets). See `lib/features/inspection/` for the reference layout.

State management is a deliberate mix: `provider`/`ChangeNotifier` for simple, single-owner UI state (theme, dashboard), and `flutter_bloc` for features with multiple distinct user actions (Inspection).

## Commands

- `flutter pub get` — install/update dependencies (run after any `pubspec.yaml` change)
- `flutter analyze` — static analysis
- `flutter test` — run all tests; `flutter test test/widget_test.dart` for a single file
- `flutter run` — run on a connected device/emulator; `flutter devices` to list targets
- `dart run flutter_native_splash:create` — regenerate native launch-screen files after changing the `flutter_native_splash:` config in `pubspec.yaml`

See `CLAUDE.md` for the full architecture reference (DI conventions, error handling contract, usecase pattern, persistence details, etc.).

## Getting started with Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
