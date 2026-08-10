import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/daily_revenue.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/monthly_revenue.dart';

const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Same net + net*gst/100 - net*discount/100 formula as InvoiceTotals.computeInvoiceTotals,
// computed in SQL so aggregation happens in SQLite instead of loading rows into Dart.
const _totalAmountExpression = '''
  COALESCE((SELECT SUM(quantity * unit_price) FROM invoice_items
             WHERE invoice_items.invoice_id = invoices.id), 0)
  * (1 + COALESCE(gst_percent, 0) / 100 - COALESCE(discount_percent, 0) / 100)
''';

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _yearMonth(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';

DateTime _mondayOfWeek(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

double _percentChange(num current, num previous) {
  if (previous == 0) return current == 0 ? 0 : 100;
  return (current - previous) / previous * 100;
}

class DashboardLocalDataSource {
  final AppDatabase _appDatabase;

  DashboardLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now();
      final thisMonthKey = _yearMonth(DateTime(now.year, now.month, 1));
      final lastMonthKey = _yearMonth(DateTime(now.year, now.month - 1, 1));

      final rows = await db.rawQuery(
        '''
        SELECT
          COUNT(*) AS invoice_count,
          SUM(CASE WHEN payment_status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
          SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) AS paid_count,
          SUM(CASE WHEN strftime('%Y-%m', created_at) = ? THEN 1 ELSE 0 END) AS invoices_this_month,
          SUM(CASE WHEN strftime('%Y-%m', created_at) = ? THEN 1 ELSE 0 END) AS invoices_last_month,
          SUM(CASE WHEN payment_status = 'pending' AND strftime('%Y-%m', created_at) = ? THEN 1 ELSE 0 END) AS pending_this_month,
          SUM(CASE WHEN payment_status = 'pending' AND strftime('%Y-%m', created_at) = ? THEN 1 ELSE 0 END) AS pending_last_month,
          SUM(CASE WHEN payment_status = 'paid' AND strftime('%Y-%m', paid_at) = ? THEN 1 ELSE 0 END) AS paid_this_month,
          SUM(CASE WHEN payment_status = 'paid' AND strftime('%Y-%m', paid_at) = ? THEN 1 ELSE 0 END) AS paid_last_month,
          SUM(total_amount) AS total_revenue,
          SUM(CASE WHEN strftime('%Y-%m', created_at) = ? THEN total_amount ELSE 0 END) AS revenue_this_month,
          SUM(CASE WHEN strftime('%Y-%m', created_at) = ? THEN total_amount ELSE 0 END) AS revenue_last_month,
          SUM(CASE WHEN payment_status = 'pending' THEN total_amount ELSE 0 END) AS pending_amount,
          SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) AS paid_amount
        FROM (
          SELECT invoices.*, $_totalAmountExpression AS total_amount
          FROM invoices
        )
        ''',
        [
          thisMonthKey, lastMonthKey,
          thisMonthKey, lastMonthKey,
          thisMonthKey, lastMonthKey,
          thisMonthKey, lastMonthKey,
        ],
      );

      final row = rows.first;
      int intOf(String key) => (row[key] as num?)?.toInt() ?? 0;
      double doubleOf(String key) => (row[key] as num?)?.toDouble() ?? 0;

      return DashboardStats(
        invoiceCount: intOf('invoice_count'),
        pendingCount: intOf('pending_count'),
        paidCount: intOf('paid_count'),
        invoiceTrendPercent: _percentChange(
          intOf('invoices_this_month'),
          intOf('invoices_last_month'),
        ),
        pendingTrendPercent: _percentChange(
          intOf('pending_this_month'),
          intOf('pending_last_month'),
        ),
        paidTrendPercent: _percentChange(
          intOf('paid_this_month'),
          intOf('paid_last_month'),
        ),
        totalRevenue: doubleOf('total_revenue'),
        revenueChangePercent: _percentChange(
          doubleOf('revenue_this_month'),
          doubleOf('revenue_last_month'),
        ),
        pendingAmount: doubleOf('pending_amount'),
        paidAmount: doubleOf('paid_amount'),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load dashboard stats: $e');
    }
  }

  Future<List<DailyRevenue>> getDailyRevenue() async {
    try {
      final db = await _appDatabase.database;
      final monday = _mondayOfWeek(DateTime.now());
      final sunday = monday.add(const Duration(days: 6));

      final rows = await db.rawQuery(
        '''
        SELECT date(created_at) AS day, SUM($_totalAmountExpression) AS revenue
        FROM invoices
        WHERE date(created_at) BETWEEN ? AND ?
        GROUP BY day
        ''',
        [_dateOnly(monday), _dateOnly(sunday)],
      );

      final revenueByDay = <String, double>{
        for (final row in rows)
          row['day'] as String: (row['revenue'] as num?)?.toDouble() ?? 0,
      };

      return [
        for (var i = 0; i < 7; i++)
          DailyRevenue(
            date: monday.add(Duration(days: i)),
            revenue:
                revenueByDay[_dateOnly(monday.add(Duration(days: i)))] ?? 0,
          ),
      ];
    } catch (e) {
      throw CacheException(message: 'Failed to load daily revenue: $e');
    }
  }

  Future<List<DateTime>> getPendingPaymentDates() async {
    try {
      final db = await _appDatabase.database;
      final yearMonth = _yearMonth(DateTime.now());

      final rows = await db.rawQuery(
        '''
        SELECT DISTINCT date(due_date) AS day
        FROM invoices
        WHERE payment_status = 'pending'
          AND due_date IS NOT NULL
          AND strftime('%Y-%m', due_date) = ?
        ''',
        [yearMonth],
      );

      return rows.map((row) => DateTime.parse(row['day'] as String)).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to load pending payment dates: $e',
      );
    }
  }

  Future<List<MonthlyRevenue>> getMonthlyRevenue() async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now();
      final startMonth = DateTime(now.year, now.month - 11, 1);

      final rows = await db.rawQuery(
        '''
        SELECT strftime('%Y-%m', created_at) AS month, SUM($_totalAmountExpression) AS revenue
        FROM invoices
        WHERE created_at >= ?
        GROUP BY month
        ''',
        [startMonth.toIso8601String()],
      );

      final revenueByMonth = <String, double>{
        for (final row in rows)
          row['month'] as String: (row['revenue'] as num?)?.toDouble() ?? 0,
      };

      return [
        for (var i = 0; i < 12; i++)
          () {
            final month = DateTime(startMonth.year, startMonth.month + i, 1);
            return MonthlyRevenue(
              month: _monthAbbreviations[month.month - 1],
              revenue: revenueByMonth[_yearMonth(month)] ?? 0,
            );
          }(),
      ];
    } catch (e) {
      throw CacheException(message: 'Failed to load monthly revenue: $e');
    }
  }
}
