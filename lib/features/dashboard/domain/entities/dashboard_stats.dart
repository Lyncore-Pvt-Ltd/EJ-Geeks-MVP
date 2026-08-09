import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int invoiceCount;
  final int pendingCount;
  final int paidCount;
  final double invoiceTrendPercent;
  final double pendingTrendPercent;
  final double paidTrendPercent;
  final double totalRevenue;
  final double revenueChangePercent;
  final double pendingAmount;
  final double paidAmount;

  const DashboardStats({
    this.invoiceCount = 0,
    this.pendingCount = 0,
    this.paidCount = 0,
    this.invoiceTrendPercent = 0,
    this.pendingTrendPercent = 0,
    this.paidTrendPercent = 0,
    this.totalRevenue = 0,
    this.revenueChangePercent = 0,
    this.pendingAmount = 0,
    this.paidAmount = 0,
  });

  @override
  List<Object?> get props => [
    invoiceCount,
    pendingCount,
    paidCount,
    invoiceTrendPercent,
    pendingTrendPercent,
    paidTrendPercent,
    totalRevenue,
    revenueChangePercent,
    pendingAmount,
    paidAmount,
  ];
}
