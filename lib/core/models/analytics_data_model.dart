import 'package:equatable/equatable.dart';

class AnalyticsDataModel extends Equatable {
  final double todayRevenue;
  final double thisWeekRevenue;
  final double thisMonthRevenue;
  
  final int currentPeriodCustomers;
  final int previousPeriodCustomers;
  final double customerGrowthPercentage;

  final List<String> top3PeakTimeSlots;
  final List<BestSellingProductModel> bestSellingProducts;
  final List<ChartDataPoint> revenueChartData;

  const AnalyticsDataModel({
    required this.todayRevenue,
    required this.thisWeekRevenue,
    required this.thisMonthRevenue,
    required this.currentPeriodCustomers,
    required this.previousPeriodCustomers,
    required this.customerGrowthPercentage,
    required this.top3PeakTimeSlots,
    required this.bestSellingProducts,
    required this.revenueChartData,
  });

  bool get isEmpty => 
      todayRevenue == 0 && 
      thisWeekRevenue == 0 && 
      thisMonthRevenue == 0 && 
      currentPeriodCustomers == 0 && 
      bestSellingProducts.isEmpty &&
      revenueChartData.isEmpty;

  @override
  List<Object?> get props => [
        todayRevenue,
        thisWeekRevenue,
        thisMonthRevenue,
        currentPeriodCustomers,
        previousPeriodCustomers,
        customerGrowthPercentage,
        top3PeakTimeSlots,
        bestSellingProducts,
        revenueChartData,
      ];
}

class BestSellingProductModel extends Equatable {
  final String productName;
  final int unitsSold;
  final double revenueGenerated;

  const BestSellingProductModel({
    required this.productName,
    required this.unitsSold,
    required this.revenueGenerated,
  });

  @override
  List<Object?> get props => [productName, unitsSold, revenueGenerated];
}

class ChartDataPoint extends Equatable {
  final DateTime date;
  final double value;

  const ChartDataPoint({
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [date, value];
}
