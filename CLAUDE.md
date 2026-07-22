# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"E&J Geek Invoice" — a Flutter invoicing/accounting app (`name: ej_geek` in `pubspec.yaml`). Early stage: splash screen, a dashboard home screen, and an invoice-creation bottom sheet (Inspection / Invoice tabs) exist. The Inspection tab is the first fully data-backed feature — vehicle details + a category checklist, persisted locally via SQLite — and is the reference implementation for how new features should be built (see "Inspection feature" below). No auth or remote backend exists yet.

## Commands

- `flutter pub get` — install/update dependencies (run after any `pubspec.yaml` change)
- `flutter analyze` — static analysis (uses `package:flutter_lints/flutter.yaml`, see `analysis_options.yaml`)
- `flutter test` — run all tests; `flutter test test/widget_test.dart` for a single file
- `flutter run` — run on a connected device/emulator; `flutter devices` to list targets
- `dart run flutter_native_splash:create` — regenerate native (pre-engine) launch screen files after changing the `flutter_native_splash:` config block in `pubspec.yaml`. Never hand-edit the generated platform files directly (see below).

## Architecture

The codebase follows a clean-architecture, feature-first layout under `lib/`:

- `lib/core/` — app-shell / cross-cutting UI that isn't tied to one feature (splash screen, placeholder home screen). Structured as `core/presentation/pages/` for screens and `core/presentation/widgets/<group>/` for the small stateless widgets that compose them (e.g. `core/presentation/widgets/splash/` holds the individual animated pieces — icon, title, subtitle, dots, progress bar — that `core/presentation/pages/splash_screen.dart` assembles).
- `lib/features/<feature>/` — feature-specific code, split into `data/`, `domain/`, `presentation/` layers (see `features/inspection/` for the reference layout: `domain/entities`, `domain/repositories`, `data/datasources`, `data/repositories`, `data/constants`, `presentation/bloc`, `presentation/widgets`).
- `lib/core/database/`, `lib/core/storage/`, `lib/core/error/`, `lib/core/di/` — cross-cutting infrastructure shared across features (SQLite access, on-device file paths, the exceptions/failures convention, and the `get_it` service locator — all detailed below).

Splash screen animation pattern (`lib/core/presentation/pages/splash_screen.dart`): one `StatefulWidget` with `TickerProviderStateMixin` owns a separate `AnimationController` per animated element (icon, title, subtitle, dots, progress bar) and staggers them via sequential `await Future.delayed(...)` calls before each `.forward()`. Each visual piece is a `StatelessWidget` that only receives `Animation` objects as constructor params (no controller ownership), so they stay independently reusable/testable. Follow this split — controller/timing logic in the page, presentation-only logic in the widget — when adding new animated screens.

### Native splash screen

`flutter_native_splash` is configured via the `flutter_native_splash:` block at the bottom of `pubspec.yaml` (currently solid black, no image). This generates the native Android/iOS/web launch-screen files (`android/app/src/main/res/**/launch_background.xml`, `**/styles.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`, `web/index.html`, etc.) — these are generated output, not hand-maintained. Change the `pubspec.yaml` config and re-run `dart run flutter_native_splash:create` instead of editing them directly.

### State management

Two approaches coexist by design, scoped to where they were introduced:
- `provider` / `ChangeNotifier` — the original, app-wide default (`core/theme/theme_controller.dart`, `features/dashboard/presentation/providers/dashboard_provider.dart`). Use this for simple, single-owner UI state.
- `flutter_bloc` (full `Bloc<Event, State>`, not `Cubit`) — used in `features/inspection/presentation/bloc/` (`InspectionBloc`, `InspectionEvent`, `InspectionState`). Prefer this pattern for new features with multiple distinct user actions (ticking a rating, changing a comment, picking an image, saving) that benefit from being named events rather than ad-hoc method calls.

### Dependency injection

`lib/core/di/service_locator.dart` uses `get_it`. `setupServiceLocator()` is called once in `main.dart` before `runApp` and registers each feature's data sources/repositories as lazy singletons, plus feature Blocs as parameterized factories (e.g. `sl.registerFactoryParam<InspectionBloc, String, void>(...)` keyed by `invoiceId`). Widgets pull dependencies via `sl<T>()` (or `sl<T>(param1: ...)`) instead of constructing repositories/data sources directly — follow this pattern when wiring up a new feature's Bloc.

### Error handling convention

`lib/core/error/exceptions.dart` and `lib/core/error/failures.dart` define the app-wide contract: data sources catch low-level errors and throw a typed `Exception` (`CacheException`, `StorageException`, plus `ServerException`/`NetworkException`/`AuthException`/`UnauthorizedException` reserved for future networked features); repositories catch those and return `Either<Failure, T>` (via `dartz`) with the matching typed `Failure`. Presentation code (a Bloc) folds the `Either` and surfaces `failure.message` to the UI — never let a raw `Exception` reach a widget.

### Local persistence (SQLite + on-device files)

- `lib/core/database/app_database.dart` — a singleton (`AppDatabase.instance`) wrapping `sqflite`. Add new tables in its `_onCreate`; bump `_dbVersion` and add an `onUpgrade` migration if the schema changes after release.
- `lib/core/storage/app_storage_paths.dart` — builds on-device file paths for images/PDFs under a shared `EJ Geek Invoice` app folder (`images/<invoiceId>/...`, `pdf/<invoiceId>/...`), keyed by invoice id and named with a date-time stamp. Uses `path_provider`'s external storage directory on Android (no `MANAGE_EXTERNAL_STORAGE` needed) and the documents directory on iOS. Use this helper rather than constructing file paths inline.
- Every invoice has an id (currently generated client-side via `uuid` in `InvoiceBottomSheet` until a real invoice/backend id system exists) — it's the join key between an invoice's DB rows and its on-disk images/PDFs. Pass it down explicitly rather than re-generating a new id per feature.

### Inspection feature (`lib/features/inspection/`)

Reference implementation for the patterns above: vehicle details + a 5-section pass/fail checklist (Interior, Exterior, Engine Bay, Tyres/Wheels & Brakes, Road Test — labels sourced from `data/constants/inspection_checklist_data.dart`), each item rated Good/Fair/Repair/N/A/N/C, plus a photo picker (camera or gallery, downscaled via `image_picker`'s `imageQuality`/`maxWidth`/`maxHeight` rather than a separate compression package) and a per-section comment. Persistence goes through `InspectionRepository` → `InspectionLocalDataSource` → `sqflite`. PDF generation from a saved inspection is not implemented yet (`AppStoragePaths.newPdfPath` exists in preparation for it).

When wiring a feature's widget tree into a scrollable container, prefer lazy building (`ListView.builder`/`CustomScrollView` + `SliverList.builder`) over an eager `ListView(children: [...])` once the tree has more than a handful of non-trivial children — building everything up front inside a modal (e.g. `InvoiceBottomSheet`) causes visible jank on open. Scope `BlocBuilder`/`BlocSelector` rebuilds as narrowly as possible (e.g. per-list-item via `BlocSelector`) rather than rebuilding a whole section list on every keystroke.
