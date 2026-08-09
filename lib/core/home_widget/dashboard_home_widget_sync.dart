import 'package:ej_geek/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:home_widget/home_widget.dart';

const String dashboardWidgetAndroidProviderName = 'DashboardWidgetProvider';

Future<void> syncDashboardHomeWidget(DashboardStats stats) async {
  await HomeWidget.saveWidgetData<String>('revenue', formatAud(stats.totalRevenue));
  await HomeWidget.saveWidgetData<String>('pendingAmount', formatAud(stats.pendingAmount));
  await HomeWidget.saveWidgetData<String>('paidAmount', formatAud(stats.paidAmount));
  await HomeWidget.saveWidgetData<int>('invoiceCount', stats.invoiceCount);
  await HomeWidget.saveWidgetData<int>('pendingCount', stats.pendingCount);
  await HomeWidget.saveWidgetData<int>('paidCount', stats.paidCount);
  await HomeWidget.updateWidget(androidName: dashboardWidgetAndroidProviderName);
}
