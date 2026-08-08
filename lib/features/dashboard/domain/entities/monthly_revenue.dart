import 'package:equatable/equatable.dart';

class MonthlyRevenue extends Equatable {
  final String month;
  final double revenue;

  const MonthlyRevenue({required this.month, required this.revenue});

  @override
  List<Object?> get props => [month, revenue];
}
