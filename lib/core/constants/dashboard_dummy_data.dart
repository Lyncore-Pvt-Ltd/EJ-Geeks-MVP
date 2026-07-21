class MonthlyRevenue {
  final String month;
  final double revenue;

  const MonthlyRevenue({required this.month, required this.revenue});
}

const int dummyInvoiceCount = 125;
const int dummyPendingCount = 18;
const int dummyPaidCount = 107;
const String dummyRevenueLabel = 'A\$2.4M';
const String dummyRevenueChangeLabel = '12.8% than last month';
const String dummyPendingAmountLabel = 'A\$185K';

const List<MonthlyRevenue> dummyMonthlyRevenue = [
  MonthlyRevenue(month: 'Jan', revenue: 150000),
  MonthlyRevenue(month: 'Feb', revenue: 180000),
  MonthlyRevenue(month: 'Mar', revenue: 165000),
  MonthlyRevenue(month: 'Apr', revenue: 210000),
  MonthlyRevenue(month: 'May', revenue: 195000),
  MonthlyRevenue(month: 'Jun', revenue: 230000),
  MonthlyRevenue(month: 'Jul', revenue: 205000),
  MonthlyRevenue(month: 'Aug', revenue: 220000),
  MonthlyRevenue(month: 'Sep', revenue: 190000),
  MonthlyRevenue(month: 'Oct', revenue: 240000),
  MonthlyRevenue(month: 'Nov', revenue: 215000),
  MonthlyRevenue(month: 'Dec', revenue: 260000),
];
