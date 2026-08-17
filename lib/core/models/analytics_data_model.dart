import 'package:equatable/equatable.dart';

class AnalyticsDataModel extends Equatable {
  // Sales Metrics
  final double todayRevenue;
  final double yesterdayRevenue;
  final double todayGrowthPercentage;

  final double thisWeekRevenue;
  final double lastWeekRevenue;
  final double weekGrowthPercentage;

  final double thisMonthRevenue;
  final double lastMonthRevenue;
  final double monthGrowthPercentage;

  final double thisYearRevenue;
  final double lastYearRevenue;
  final double yearGrowthPercentage;

  // Order Volume & Rate Metrics
  final int totalOrdersCount;
  final int completedOrdersCount;
  final int cancelledOrdersCount;
  final int pendingOrdersCount;
  final double averageOrderValue;
  final double orderCompletionRate;
  final double orderCancellationRate;

  // Customer Metrics
  final int currentPeriodCustomers;
  final int previousPeriodCustomers;
  final double customerGrowthPercentage;
  final int newCustomersCount;
  final int repeatCustomersCount;

  // Peak Time & Hourly Metrics
  final List<String> top3PeakTimeSlots;
  final Map<int, int> hourlyOrderCounts;
  final List<HourlyChartPoint> hourlyChartData;

  // Product Performance Metrics
  final List<BestSellingProductModel> bestSellingProducts;
  final List<ProductPerformanceModel> lowPerformingProducts;
  final List<ProductPerformanceModel> allProductPerformances;

  // Visual Chart Data
  final List<ChartDataPoint> revenueChartData;
  final Map<String, int> orderStatusDistribution;

  const AnalyticsDataModel({
    required this.todayRevenue,
    this.yesterdayRevenue = 0.0,
    this.todayGrowthPercentage = 0.0,
    required this.thisWeekRevenue,
    this.lastWeekRevenue = 0.0,
    this.weekGrowthPercentage = 0.0,
    required this.thisMonthRevenue,
    this.lastMonthRevenue = 0.0,
    this.monthGrowthPercentage = 0.0,
    this.thisYearRevenue = 0.0,
    this.lastYearRevenue = 0.0,
    this.yearGrowthPercentage = 0.0,
    this.totalOrdersCount = 0,
    this.completedOrdersCount = 0,
    this.cancelledOrdersCount = 0,
    this.pendingOrdersCount = 0,
    this.averageOrderValue = 0.0,
    this.orderCompletionRate = 0.0,
    this.orderCancellationRate = 0.0,
    required this.currentPeriodCustomers,
    required this.previousPeriodCustomers,
    required this.customerGrowthPercentage,
    this.newCustomersCount = 0,
    this.repeatCustomersCount = 0,
    required this.top3PeakTimeSlots,
    this.hourlyOrderCounts = const {},
    this.hourlyChartData = const [],
    required this.bestSellingProducts,
    this.lowPerformingProducts = const [],
    this.allProductPerformances = const [],
    required this.revenueChartData,
    this.orderStatusDistribution = const {},
  });

  bool get isEmpty =>
      todayRevenue == 0 &&
      thisWeekRevenue == 0 &&
      thisMonthRevenue == 0 &&
      thisYearRevenue == 0 &&
      totalOrdersCount == 0 &&
      currentPeriodCustomers == 0 &&
      bestSellingProducts.isEmpty &&
      revenueChartData.isEmpty;

  @override
  List<Object?> get props => [
    todayRevenue,
    yesterdayRevenue,
    todayGrowthPercentage,
    thisWeekRevenue,
    lastWeekRevenue,
    weekGrowthPercentage,
    thisMonthRevenue,
    lastMonthRevenue,
    monthGrowthPercentage,
    thisYearRevenue,
    lastYearRevenue,
    yearGrowthPercentage,
    totalOrdersCount,
    completedOrdersCount,
    cancelledOrdersCount,
    pendingOrdersCount,
    averageOrderValue,
    orderCompletionRate,
    orderCancellationRate,
    currentPeriodCustomers,
    previousPeriodCustomers,
    customerGrowthPercentage,
    newCustomersCount,
    repeatCustomersCount,
    top3PeakTimeSlots,
    hourlyOrderCounts,
    hourlyChartData,
    bestSellingProducts,
    lowPerformingProducts,
    allProductPerformances,
    revenueChartData,
    orderStatusDistribution,
  ];
}

class BestSellingProductModel extends Equatable {
  final String productName;
  final int unitsSold;
  final double revenueGenerated;
  final String? productId;
  final double price;
  final double sharePercentage;
  final String? imageUrl;

  const BestSellingProductModel({
    required this.productName,
    required this.unitsSold,
    required this.revenueGenerated,
    this.productId,
    this.price = 0.0,
    this.sharePercentage = 0.0,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    productName,
    unitsSold,
    revenueGenerated,
    productId,
    price,
    sharePercentage,
    imageUrl,
  ];
}

class ProductPerformanceModel extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int unitsSold;
  final double revenueGenerated;
  final double sharePercentage;
  final int availableStock;
  final String category;
  final String? imageUrl;
  final bool isActive;

  const ProductPerformanceModel({
    required this.productId,
    required this.productName,
    this.price = 0.0,
    this.unitsSold = 0,
    this.revenueGenerated = 0.0,
    this.sharePercentage = 0.0,
    this.availableStock = 0,
    this.category = 'General',
    this.imageUrl,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    price,
    unitsSold,
    revenueGenerated,
    sharePercentage,
    availableStock,
    category,
    imageUrl,
    isActive,
  ];
}

class HourlyChartPoint extends Equatable {
  final int hour;
  final int orderCount;
  final double revenue;
  final String label;

  const HourlyChartPoint({
    required this.hour,
    required this.orderCount,
    this.revenue = 0.0,
    required this.label,
  });

  @override
  List<Object?> get props => [hour, orderCount, revenue, label];
}

class ChartDataPoint extends Equatable {
  final DateTime date;
  final double value;
  final String? label;

  const ChartDataPoint({required this.date, required this.value, this.label});

  @override
  List<Object?> get props => [date, value, label];
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

