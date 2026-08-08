# SQL Aggregate Loading

Performance pattern for screens/providers that show counts, sums, or date-series data (dashboards, summary cards, charts) backed by `sqflite`. Goal: keep the app light — no extra frame jank, no redundant DB round trips — while still showing real data instead of dummy constants.

## Rules

1. **Aggregate in SQL, not Dart.** Compute counts/sums/percentages with `COUNT`, `SUM`, `GROUP BY`, `CASE WHEN` directly in the query. Never fetch full rows into Dart just to `.length`/`.fold`/loop-sum them client-side — the database engine is faster at this than Dart iterating a `List<Map>`, and it avoids holding a large row set in memory.

2. **Batch the round trips.** When a screen/provider needs several independent aggregates:
   - Prefer **one query with multiple `CASE WHEN`-guarded `SUM`/`COUNT` columns** over several separate queries, when the aggregates share the same base table/filter shape (see `getDashboardStats()` below — one query computes 12 numbers).
   - When separate queries are unavoidable (different tables/shapes), fire them **concurrently** with `Future.wait([...])` rather than sequential `await`s.
   - Do this loading **once** — on construction / first load of the provider/bloc — never on every rebuild or per-widget-instance.

3. **Zero-fill in the data layer, not the widget.** When the UI needs a fixed-length series (7 days of a week, 12 months of a chart), have the data source produce the complete, gap-filled list itself — query only returns rows for buckets that have data, then the data source loops over the full expected range and defaults missing buckets to `0`. Never let a widget infer/guess missing days or months positionally.

4. **Reuse existing formula/formatting helpers.** Don't re-derive business math (e.g. gst/discount total calculations) or currency formatting in a new SQL string or Dart function if a canonical one already exists elsewhere in the codebase — mirror it in SQL instead.

## Worked example: `lib/features/dashboard/`

- `DashboardLocalDataSource.getDashboardStats()` (`lib/features/dashboard/data/datasources/dashboard_local_data_source.dart`) — a single `rawQuery` with 12 `CASE WHEN`/`SUM`/`COUNT` columns computing invoice counts, month-over-month trend percentages, and revenue totals in one round trip, instead of 8+ separate queries or loading every invoice row into Dart.
- `DashboardLocalDataSource.getDailyRevenue()` / `getMonthlyRevenue()` — each queries only the rows that exist, then zero-fills a fixed-length `List<DailyRevenue>` (7 entries, Mon–Sun) / `List<MonthlyRevenue>` (12 entries) in Dart so the chart/bar widgets never have to guess about gaps.
- `DashboardProvider._loadDashboardData()` (`lib/features/dashboard/presentation/providers/dashboard_provider.dart`) — fires all four usecases concurrently via `Future.wait`, once, in the constructor (mirrors `InspectionBloc`'s auto-load-on-construction pattern) rather than reloading on every widget rebuild.
- The `total_amount` SQL expression in `dashboard_local_data_source.dart` mirrors `computeInvoiceTotals` (`lib/features/invoice/domain/entities/invoice_totals.dart`)'s `net + net*gst/100 - net*discount/100` formula instead of re-deriving it, and `DashboardProvider`'s label getters reuse `formatAud`/`trimmedAmount` (`lib/features/invoice/presentation/widgets/invoice_screens/currency_format.dart`) instead of a new formatter.

Pull this skill whenever adding a new stat card, chart, or summary view backed by SQLite in this app.
