# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"E&J Geek Invoice" — a Flutter invoicing/accounting app (`name: ej_geek` in `pubspec.yaml`). Splash screen, a dashboard home screen (still driven by placeholder data, see "Dashboard" below), and a full invoice feature (list, create/edit, PDF generation) with an embedded Inspection tab (vehicle details + a category checklist) all exist and are persisted locally via SQLite. Inspection was the original reference implementation (see "Inspection feature" below); Invoice now mirrors the same clean-architecture layering (see "Invoice feature" below) and should be treated as an equally valid reference for new features. `lib/features/auth/` is a scaffolded, empty placeholder — there is no auth or remote backend yet. The app also ships a temporary time-boxed trial lock (see "Trial lock" below).

## Commands

- `flutter pub get` — install/update dependencies (run after any `pubspec.yaml` change)
- `flutter analyze` — static analysis (uses `package:flutter_lints/flutter.yaml`, see `analysis_options.yaml`)
- `flutter test` — run all tests; `flutter test test/widget_test.dart` for a single file
- `flutter run` — run on a connected device/emulator; `flutter devices` to list targets
- `dart run flutter_native_splash:create` — regenerate native (pre-engine) launch screen files after changing the `flutter_native_splash:` config block in `pubspec.yaml`. Never hand-edit the generated platform files directly (see below).

## Architecture

The codebase follows a clean-architecture, feature-first layout under `lib/`:

- `lib/core/` — app-shell / cross-cutting UI that isn't tied to one feature (splash screen, placeholder home screen). Structured as `core/presentation/pages/` for screens and `core/presentation/widgets/<group>/` for the small stateless widgets that compose them (e.g. `core/presentation/widgets/splash/` holds the individual animated pieces — icon, title, subtitle, dots, progress bar — that `core/presentation/pages/splash_screen.dart` assembles).
- `lib/features/<feature>/` — feature-specific code, split into `data/`, `domain/`, `presentation/` layers (see `features/inspection/` for the reference layout: `domain/entities`, `domain/repositories`, `domain/usecases`, `data/datasources`, `data/repositories`, `data/constants`, `presentation/bloc`, `presentation/widgets`).
- `lib/core/database/`, `lib/core/storage/`, `lib/core/error/`, `lib/core/di/`, `lib/core/pdf/` — cross-cutting infrastructure shared across features (SQLite access, on-device file paths, the exceptions/failures convention, the `get_it` service locator, and shared PDF letterhead/theme building blocks — all detailed below).

Splash screen animation pattern (`lib/core/presentation/pages/splash_screen.dart`): one `StatefulWidget` with `TickerProviderStateMixin` owns a separate `AnimationController` per animated element (icon, title, subtitle, dots, progress bar) and staggers them via sequential `await Future.delayed(...)` calls before each `.forward()`. Each visual piece is a `StatelessWidget` that only receives `Animation` objects as constructor params (no controller ownership), so they stay independently reusable/testable. Follow this split — controller/timing logic in the page, presentation-only logic in the widget — when adding new animated screens.

### Native splash screen

`flutter_native_splash` is configured via the `flutter_native_splash:` block at the bottom of `pubspec.yaml` (currently solid black, no image). This generates the native Android/iOS/web launch-screen files (`android/app/src/main/res/**/launch_background.xml`, `**/styles.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`, `web/index.html`, etc.) — these are generated output, not hand-maintained. Change the `pubspec.yaml` config and re-run `dart run flutter_native_splash:create` instead of editing them directly.

### State management

Two approaches coexist by design, scoped to where they were introduced:
- `provider` / `ChangeNotifier` — the original, app-wide default (`core/theme/theme_controller.dart`, `features/dashboard/presentation/providers/dashboard_provider.dart`). Use this for simple, single-owner UI state.
- `flutter_bloc` (full `Bloc<Event, State>`, not `Cubit`) — used in `features/inspection/presentation/bloc/` (`InspectionBloc`, `InspectionEvent`, `InspectionState`). Prefer this pattern for new features with multiple distinct user actions (ticking a rating, changing a comment, picking an image, saving) that benefit from being named events rather than ad-hoc method calls.

### Dependency injection

`lib/core/di/service_locator.dart` uses `get_it`. `setupServiceLocator()` is called once in `main.dart` before `runApp` and registers each feature's data sources/repositories as lazy singletons, plus feature Blocs as parameterized factories (e.g. `sl.registerFactoryParam<InspectionBloc, String, void>(...)` keyed by `invoiceId`). Widgets pull dependencies via `sl<T>()` (or `sl<T>(param1: ...)`) instead of constructing repositories/data sources directly — follow this pattern when wiring up a new feature's Bloc.

### Domain usecases

`lib/core/usecases/usecase.dart` defines a shared `abstract class UseCase<Output, Params> { Future<Either<Failure, Output>> call(Params params); }` — cross-cutting infra, same tier as `core/error`/`core/database`/`core/storage`. Each feature's `domain/usecases/` holds small callable classes (a single public `call(params)` method) that wrap exactly one repository method — e.g. `features/inspection/domain/usecases/save_inspection.dart`'s `SaveInspection`, `get_inspection_by_invoice_id.dart`'s `GetInspectionByInvoiceId`, `pick_inspection_image.dart`'s `PickInspectionImage`. A usecase needing more than one argument takes a dedicated `Params` class (`Equatable`, see `PickInspectionImageParams`) rather than positional/named params on `call`. Blocs depend on usecases, not repositories directly, and usecases are registered in `service_locator.dart` as `registerLazySingleton` (stateless wrappers around a singleton repository). Only add a usecase for a repository method that's actually called — don't wrap unused repository surface just to have a wrapper.

### Error handling convention

`lib/core/error/exceptions.dart` and `lib/core/error/failures.dart` define the app-wide contract: data sources catch low-level errors and throw a typed `Exception` (`CacheException`, `StorageException`, plus `ServerException`/`NetworkException`/`AuthException`/`UnauthorizedException` reserved for future networked features); repositories catch those and return `Either<Failure, T>` (via `dartz`) with the matching typed `Failure`. Usecases pass the repository's `Either` straight through. Presentation code (a Bloc) folds the `Either` and surfaces `failure.message` to the UI — never let a raw `Exception` reach a widget.

### Local persistence (SQLite + on-device files)

- `lib/core/database/app_database.dart` — a singleton (`AppDatabase.instance`) wrapping `sqflite`. Add new tables in its `_onCreate`; bump `_dbVersion` and add an `onUpgrade` migration if the schema changes after release.
- `lib/core/storage/app_storage_paths.dart` — builds on-device file paths for images/PDFs under a shared `EJ Geek Invoice` app folder, keyed by invoice id and dated (`invoiceFolder(invoiceId, createdAt)` → `<base>/<yyyyMMdd>/<invoiceId>/...`), with dedicated `invoicePdfPath(invoiceId, createdAt)` and `inspectionPdfPath(invoiceId, createdAt)` methods (`invoice.pdf` / `inspection.pdf` in that folder). Uses `path_provider`'s external storage directory on Android (no `MANAGE_EXTERNAL_STORAGE` needed) and the documents directory on iOS. Use this helper rather than constructing file paths inline.
- Every invoice has an id (currently generated client-side via `uuid` in `InvoiceBottomSheet` until a real invoice/backend id system exists) — it's the join key between an invoice's DB rows and its on-disk images/PDFs. Pass it down explicitly rather than re-generating a new id per feature. `InvoiceBottomSheet.show()` resolves a `null` `invoiceId`/`createdAt` to concrete values *before* passing them into `showModalBottomSheet`'s `builder` closure, rather than inside the `InvoiceBottomSheet` constructor — that closure can be re-invoked mid-session (e.g. when the keyboard opening/closing changes `MediaQuery`), and resolving a `null` id there would mint a fresh random uuid on every rebuild instead of keeping one stable id for the sheet's lifetime.

### Inspection feature (`lib/features/inspection/`)

Reference implementation for the patterns above: vehicle details + a 5-section pass/fail checklist (Interior, Exterior, Engine Bay, Tyres/Wheels & Brakes, Road Test — labels sourced from `data/constants/inspection_checklist_data.dart`), each item rated Good/Fair/Repair/N/A/N/C, plus a photo picker (camera or gallery, downscaled via `image_picker`'s `imageQuality`/`maxWidth`/`maxHeight` rather than a separate compression package) and a per-section comment.

`InspectionBloc` talks only to usecases, never to a repository directly (see "Domain usecases" above): `SaveInspection` → `InspectionRepository` → `InspectionLocalDataSource` → `sqflite` for persisting a record; `GetInspectionByInvoiceId` → the same repository/data source for loading one back; `PickInspectionImage` → `InspectionImageRepository` → `InspectionImageDataSource` → `image_picker` + `AppStoragePaths` for capturing and storing a photo. The bloc auto-dispatches an `InspectionLoadRequested` event at construction so reopening the Inspection tab for an invoice that already has a saved record restores its vehicle details, checklist ratings/comments, and photos instead of starting blank; loaded checklist sections are merged onto the canonical section/item order from `data/constants/inspection_checklist_data.dart` (matched by name/label) rather than trusted as-is, since the UI indexes `InspectionState.sections` positionally. The bloc keeps the persisted record's id in a private mutable field (not part of `InspectionState`, since it's a persistence detail with no UI purpose) so a save after a successful load overwrites the existing row instead of inserting a duplicate. Inspection report PDF generation is now implemented — see "PDF generation" below.

### Invoice feature (`lib/features/invoice/`)

Mirrors the inspection feature's clean-architecture layering and is the second full reference implementation. `domain/entities` covers `Invoice`, `InvoiceDetails`, `InvoiceDetailsBundle`, `InvoiceLineItem`, `InvoiceSummary`, `InvoiceTotals`, `PaymentStatus`, `ServiceStatus`; `domain/usecases` wraps `InvoiceRepository` one method at a time (`GetAllInvoices`, `DeleteInvoice`, `SaveInvoiceDetails`, `GetInvoiceDetailsByInvoiceId`, `UpdateInvoiceServiceStatus`, `UpdatePdfContentSignature`, `UpsertInvoiceDraft`, `GenerateInvoicePdfs`) per the "Domain usecases" convention above.

Two Blocs split the list and detail concerns rather than one Bloc covering both:
- `InvoiceBloc` (list screen, registered as a lazy singleton) — events `InvoiceListRequested`, `InvoiceServiceCompleted`, `InvoiceServiceReverted`, `InvoiceDeleted(invoiceId, deleteFiles)`; state holds `invoices`/`isLoading`/`errorMessage`.
- `InvoiceDetailsBloc` (create/edit screen, registered as a factory param keyed by invoiceId/createdAt) — events cover date changes, line-item add/edit/remove, GST/discount %, owner address, save, and `InvoiceGenerateRequested(paymentTerms, notes, forceRegenerate)`; state carries items/totals plus `isSaving`/`saveSuccess`/`isSending`/`sendSuccess`/`needsRegenerationConfirmation`/`invoicePdfPath`/`inspectionPdfPath`.

`presentation/pages/invoice_screen.dart` is the list; `presentation/widgets/invoice_bottom_sheet.dart` is the create/edit sheet with the embedded Inspection tab; `presentation/widgets/invoice_screens/` holds the detail-view tabs, line-item dialogs, date picker, and currency formatting helpers.

`invoice_tab.dart`'s App Owner Address and Payment Terms fields use a save/edit lock pattern built on `InspectionTextField`'s `readOnly`/`onEditTap`/`onSaveTap` params (shared with the inspection feature's text field, defaulted off so other usages are unaffected): while editable and non-empty, a trailing save icon calls back into `InvoiceTabState`; while locked, a trailing edit icon does. Both actions go through `_confirmFieldAction` (`ConfirmDialog`, `lib/core/presentation/widget/confirm_dialog.dart`) before running — confirming a save dispatches the existing `save()` (which persists the whole `InvoiceDetails` row, same as "Save invoice draft") and the `saveSuccess`/`sendSuccess` listener locks whichever field now holds non-empty text; confirming an edit just unlocks. `InvoiceDetailsState.appOwnerAddressIsSaved` (set in `InvoiceDetailsBloc._onLoadRequested`) distinguishes a genuinely-persisted address from the `kDefaultAppOwnerAddress` placeholder a brand-new invoice loads with — only the former should start locked, otherwise the placeholder's non-empty text would make a fresh invoice's address field lock (and swallow keystrokes) before the user ever typed into it.

Because `InvoiceTab` lives inside the bottom sheet's `TabBarView` alongside the Inspection tab (index 0, shown first), it mounts *lazily* — by the time a user switches to it, `InvoiceDetailsBloc`'s initial load has often already finished. Don't rely solely on a `BlocListener` keyed off the `isLoading: true → false` *transition* to seed controllers/lock state (that transition can happen before the tab widget exists, so the listener silently never fires); also seed from the bloc's *current* state in `didChangeDependencies` (see `InvoiceTabState`) so a lazily-mounted tab still populates correctly.

### PDF generation (`lib/core/pdf/`, `lib/features/invoice/data/pdf/`)

`lib/core/pdf/` holds shared building blocks reused by both invoice and inspection PDFs: `pdf_document_builder.dart` (`loadCompanyLogo`, `pdfLetterheadHeader`, `pdfSectionHeading`, `pdfDivider`, `invoiceIdQrCode`), `pdf_theme.dart` (fonts/colors), and `pdf_file_writer.dart` (`writePdfBytes(path, bytes)`, wraps I/O errors as `StorageException` per the error-handling convention above). The actual documents are built in `lib/features/invoice/data/pdf/invoice_pdf_builder.dart` (`buildInvoicePdf`) and `.../inspection_report_pdf_builder.dart` (`buildInspectionReportPdf`).

Orchestration lives in the usecase `GenerateInvoicePdfs` (`lib/features/invoice/domain/usecases/generate_invoice_pdfs.dart`): it fetches invoice details plus the optional inspection record, computes a content signature (JSON of dates, line items, GST/discount, inspection sections/images) stored as `InvoiceDetails.pdfContentSignature`, and skips regeneration when the signature is unchanged. If content changed and the caller didn't pass `forceRegenerate`, it returns `PdfRegenerationConfirmationRequired` instead of writing files, so the UI can prompt before overwriting an already-sent PDF; otherwise it writes both PDFs via `AppStoragePaths.invoicePdfPath`/`inspectionPdfPath` and returns `GeneratedInvoicePdfs` with both paths.

### Trial lock (`lib/core/trial/`)

A temporary, time-boxed trial gate — files are marked `// TEMPORARY TRIAL LOCK — remove when no longer needed` and should be deleted wholesale once no longer needed rather than kept "just in case." `TrialController` (a `ChangeNotifier`, created via `TrialController.create()` and provided app-wide in `main.dart` alongside `ThemeController`) tracks a `startDate` persisted through `TrialPreferences` (`SharedPreferences` keys `trial_start_at`/`trial_unlocked`) against a fixed `trialDuration` of 2 days; `isExpired` is true once that window has elapsed and the app hasn't been unlocked. Unlocking compares against a hardcoded code and persists `unlocked = true`. `custom_bottom_nav_bar.dart`, `dashboard_screen.dart`, and `invoice_card.dart` all watch `isExpired` and show the blocking `trial_expired_dialog.dart` when it's true; a long-press `GestureDetector` in `custom_drawer.dart` is the hidden entry point to `unlock_code_dialog.dart` for entering the unlock code.

### Dashboard (`lib/features/dashboard/`)

`DashboardProvider` (`ChangeNotifier`, see "State management" above) currently drives the dashboard entirely from placeholder data in `lib/core/constants/dashboard_dummy_data.dart` — it is not yet wired to real invoice/SQLite data. `presentation/widgets/chart/revenue_chart_card.dart` renders an `fl_chart` `LineChart` (`RevenueChartCard`) from `DashboardProvider.monthlyRevenue`; `presentation/widgets/stats/` holds `TotalRevenueCard`/`PendingPaymentsCard` (`revenue_summary_card.dart`) and the generic `StatCard` (`stat_card.dart`) used for top-line stat tiles. When wiring this up to real data, keep the existing widget contracts and swap the provider's data source rather than restructuring the widgets.

When wiring a feature's widget tree into a scrollable container, prefer lazy building (`ListView.builder`/`CustomScrollView` + `SliverList.builder`) over an eager `ListView(children: [...])` once the tree has more than a handful of non-trivial children — building everything up front inside a modal (e.g. `InvoiceBottomSheet`) causes visible jank on open. Scope `BlocBuilder`/`BlocSelector` rebuilds as narrowly as possible (e.g. per-list-item via `BlocSelector`) rather than rebuilding a whole section list on every keystroke.
