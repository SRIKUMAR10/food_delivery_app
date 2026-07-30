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

  const ChartDataPoint({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}

class FavoriteProductStats extends Equatable {
  final String productId;
  final String productName;
  final int favoriteCount;

  const FavoriteProductStats({
    required this.productId,
    required this.productName,
    required this.favoriteCount,
  });

  @override
  List<Object?> get props => [productId, productName, favoriteCount];
}

class FavoritesAnalytics extends Equatable {
  final int totalFavorites;
  final int todayCount;
  final int thisWeekCount;
  final int thisMonthCount;
  final List<FavoriteProductStats> topProducts;

  const FavoritesAnalytics({
    required this.totalFavorites,
    required this.todayCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
    required this.topProducts,
  });

  @override
  List<Object?> get props =>
      [totalFavorites, todayCount, thisWeekCount, thisMonthCount, topProducts];
}

class RecentReview extends Equatable {
  final String customerName;
  final String? customerAvatarUrl;
  final double rating;
  final String content;
  final DateTime createdAt;

  const RecentReview({
    required this.customerName,
    this.customerAvatarUrl,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [customerName, customerAvatarUrl, rating, content, createdAt];
}

class RatingAnalytics extends Equatable {
  final double averageRating;
  final int totalReviews;
  final int todayCount;
  final int thisWeekCount;
  final int thisMonthCount;
  final Map<int, int> ratingDistribution;
  final List<RecentReview> recentReviews;

  const RatingAnalytics({
    required this.averageRating,
    required this.totalReviews,
    required this.todayCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  @override
  List<Object?> get props => [
    averageRating,
    totalReviews,
    todayCount,
    thisWeekCount,
    thisMonthCount,
    ratingDistribution,
    recentReviews,
  ];
}
