import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/analytics_data_model.dart';
import '../../../../core/models/order_status.dart';

class SellerAnalyticsRepository {
  final FirebaseFirestore _firestore;

  SellerAnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<AnalyticsDataModel> streamAnalyticsData(
      String sellerId, String timeframe) {
    final now = DateTime.now();

    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    final earliestRequiredDate = startOfLastMonth.isBefore(startOfLastWeek)
        ? startOfLastMonth
        : startOfLastWeek;

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(earliestRequiredDate))
        .snapshots()
        .map((snapshot) {
      double todayRevenue = 0;
      double thisWeekRevenue = 0;
      double thisMonthRevenue = 0;

      Set<String> currentPeriodCustomers = {};
      Set<String> previousPeriodCustomers = {};

      Map<int, int> hourlyOrderCounts = {};
      Map<String, BestSellingProductModel> productStats = {};
      Map<DateTime, double> chartData = {};

      final isWeekly = timeframe == 'Weekly';
      final currentPeriodStart = isWeekly ? startOfThisWeek : startOfThisMonth;
      final previousPeriodStart = isWeekly ? startOfLastWeek : startOfLastMonth;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['status'] != OrderStatus.delivered.value) continue;

        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final customerId = data['customerId'] as String? ?? '';
        final items = data['items'] as List<dynamic>? ?? [];

        if (timestamp.isAfter(startOfToday) || timestamp.isAtSameMomentAs(startOfToday)) {
          todayRevenue += amount;
        }
        if (timestamp.isAfter(startOfThisWeek) || timestamp.isAtSameMomentAs(startOfThisWeek)) {
          thisWeekRevenue += amount;
        }
        if (timestamp.isAfter(startOfThisMonth) || timestamp.isAtSameMomentAs(startOfThisMonth)) {
          thisMonthRevenue += amount;
        }

        if (timestamp.isAfter(currentPeriodStart) || timestamp.isAtSameMomentAs(currentPeriodStart)) {
          currentPeriodCustomers.add(customerId);

          final dayDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
          chartData[dayDate] = (chartData[dayDate] ?? 0) + amount;

          hourlyOrderCounts[timestamp.hour] = (hourlyOrderCounts[timestamp.hour] ?? 0) + 1;

          for (var item in items) {
            final itemMap = item as Map<String, dynamic>;
            final name = itemMap['name'] as String? ?? 'Unknown';
            final qty = (itemMap['quantity'] as num?)?.toInt() ?? 1;
            final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
            final itemRev = price * qty;

            if (productStats.containsKey(name)) {
              final existing = productStats[name]!;
              productStats[name] = BestSellingProductModel(
                productName: name,
                unitsSold: existing.unitsSold + qty,
                revenueGenerated: existing.revenueGenerated + itemRev,
              );
            } else {
              productStats[name] = BestSellingProductModel(
                productName: name,
                unitsSold: qty,
                revenueGenerated: itemRev,
              );
            }
          }
        } else if (timestamp.isAfter(previousPeriodStart) || timestamp.isAtSameMomentAs(previousPeriodStart)) {
          previousPeriodCustomers.add(customerId);
        }
      }

      final currCust = currentPeriodCustomers.length;
      final prevCust = previousPeriodCustomers.length;
      double growth = 0;
      if (prevCust == 0 && currCust > 0) {
        growth = 100.0;
      } else if (prevCust > 0) {
        growth = ((currCust - prevCust) / prevCust) * 100;
      }

      final sortedProducts = productStats.values.toList()
        ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
      final topProducts = sortedProducts.take(5).toList();

      final sortedHours = hourlyOrderCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3Hours = sortedHours.take(3).map((e) {
        final hour = e.key;
        final start = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';
        final endHour = (hour + 1) % 24;
        final end = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
        final endAmPm = endHour >= 12 ? 'PM' : 'AM';
        return '$start $amPm - $end $endAmPm';
      }).toList();

      final chartDataPoints = chartData.entries
          .map((e) => ChartDataPoint(date: e.key, value: e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return AnalyticsDataModel(
        todayRevenue: todayRevenue,
        thisWeekRevenue: thisWeekRevenue,
        thisMonthRevenue: thisMonthRevenue,
        currentPeriodCustomers: currCust,
        previousPeriodCustomers: prevCust,
        customerGrowthPercentage: growth,
        top3PeakTimeSlots: top3Hours,
        bestSellingProducts: topProducts,
        revenueChartData: chartDataPoints,
      );
    });
  }

  Future<AnalyticsDataModel> fetchAnalyticsData(
      String sellerId, String timeframe) async {
    final now = DateTime.now();

    // Today boundaries
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    // Weekly boundaries
    final startOfThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    
    // Monthly boundaries
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    // We need data back to the earliest previous period to calculate growth
    final earliestRequiredDate = startOfLastMonth.isBefore(startOfLastWeek)
        ? startOfLastMonth
        : startOfLastWeek;

    // Fetch orders from earliestRequiredDate to now, filtering by sellerId + timestamp
    // (uses existing 2-field composite index). Status is filtered client-side to avoid
    // requiring a 3-field composite index that may still be building.
    final snapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(earliestRequiredDate))
        .get();

    double todayRevenue = 0;
    double thisWeekRevenue = 0;
    double thisMonthRevenue = 0;

    Set<String> currentPeriodCustomers = {};
    Set<String> previousPeriodCustomers = {};

    Map<int, int> hourlyOrderCounts = {};
    Map<String, BestSellingProductModel> productStats = {};
    Map<DateTime, double> chartData = {};

    final isWeekly = timeframe == 'Weekly';
    final currentPeriodStart = isWeekly ? startOfThisWeek : startOfThisMonth;
    final previousPeriodStart = isWeekly ? startOfLastWeek : startOfLastMonth;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Client-side status filter (replaces Firestore-level filter to use simpler index)
      if (data['status'] != OrderStatus.delivered.value) continue;

      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final customerId = data['customerId'] as String? ?? '';
      final items = data['items'] as List<dynamic>? ?? [];

      // Revenue Calculations
      if (timestamp.isAfter(startOfToday) || timestamp.isAtSameMomentAs(startOfToday)) {
        todayRevenue += amount;
      }
      if (timestamp.isAfter(startOfThisWeek) || timestamp.isAtSameMomentAs(startOfThisWeek)) {
        thisWeekRevenue += amount;
      }
      if (timestamp.isAfter(startOfThisMonth) || timestamp.isAtSameMomentAs(startOfThisMonth)) {
        thisMonthRevenue += amount;
      }

      // Customer Growth & Timeframe Specific Metrics
      if (timestamp.isAfter(currentPeriodStart) || timestamp.isAtSameMomentAs(currentPeriodStart)) {
        currentPeriodCustomers.add(customerId);

        // Chart Data (Daily aggregation)
        final dayDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
        chartData[dayDate] = (chartData[dayDate] ?? 0) + amount;

        // Peak Time (Hour of day)
        hourlyOrderCounts[timestamp.hour] = (hourlyOrderCounts[timestamp.hour] ?? 0) + 1;

        // Best Selling Products
        for (var item in items) {
          final itemMap = item as Map<String, dynamic>;
          final name = itemMap['name'] as String? ?? 'Unknown';
          final qty = (itemMap['quantity'] as num?)?.toInt() ?? 1;
          final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
          final itemRev = price * qty;

          if (productStats.containsKey(name)) {
            final existing = productStats[name]!;
            productStats[name] = BestSellingProductModel(
              productName: name,
              unitsSold: existing.unitsSold + qty,
              revenueGenerated: existing.revenueGenerated + itemRev,
            );
          } else {
            productStats[name] = BestSellingProductModel(
              productName: name,
              unitsSold: qty,
              revenueGenerated: itemRev,
            );
          }
        }
      } else if (timestamp.isAfter(previousPeriodStart) || timestamp.isAtSameMomentAs(previousPeriodStart)) {
        previousPeriodCustomers.add(customerId);
      }
    }

    // Calculate Growth Percentage
    final currCust = currentPeriodCustomers.length;
    final prevCust = previousPeriodCustomers.length;
    double growth = 0;
    if (prevCust == 0 && currCust > 0) {
      growth = 100.0;
    } else if (prevCust > 0) {
      growth = ((currCust - prevCust) / prevCust) * 100;
    }

    // Sort Best Selling Products
    final sortedProducts = productStats.values.toList()
      ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
    final topProducts = sortedProducts.take(5).toList(); // Top 5

    // Sort Peak Times
    final sortedHours = hourlyOrderCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Hours = sortedHours.take(3).map((e) {
      final hour = e.key;
      final start = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final endHour = (hour + 1) % 24;
      final end = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
      final endAmPm = endHour >= 12 ? 'PM' : 'AM';
      return '$start $amPm - $end $endAmPm';
    }).toList();

    // Map Chart Data
    final chartDataPoints = chartData.entries
        .map((e) => ChartDataPoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return AnalyticsDataModel(
      todayRevenue: todayRevenue,
      thisWeekRevenue: thisWeekRevenue,
      thisMonthRevenue: thisMonthRevenue,
      currentPeriodCustomers: currCust,
      previousPeriodCustomers: prevCust,
      customerGrowthPercentage: growth,
      top3PeakTimeSlots: top3Hours,
      bestSellingProducts: topProducts,
      revenueChartData: chartDataPoints,
    );
  }

  Stream<FavoritesAnalytics> streamFavoritesAnalytics(String sellerId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfThisWeek =
        startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfThisMonth = DateTime(now.year, now.month, 1);

    return _firestore
        .collectionGroup('favorites')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final totalFavorites = snapshot.docs.length;

      final Map<String, int> perProduct = {};
      final Map<String, String> productNames = {};
      int todayCount = 0;
      int thisWeekCount = 0;
      int thisMonthCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productId = doc.id;
        perProduct[productId] = (perProduct[productId] ?? 0) + 1;

        final name = data['name'] as String? ?? productId;
        productNames[productId] = name;

        final addedAt = (data['addedAt'] as Timestamp?)?.toDate();
        if (addedAt != null) {
          if (!addedAt.isBefore(startOfToday)) todayCount++;
          if (!addedAt.isBefore(startOfThisWeek)) thisWeekCount++;
          if (!addedAt.isBefore(startOfThisMonth)) thisMonthCount++;
        }
      }

      final sorted = perProduct.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topProducts = sorted.take(10).map((e) => FavoriteProductStats(
            productId: e.key,
            productName: productNames[e.key] ?? e.key,
            favoriteCount: e.value,
          )).toList();

      return FavoritesAnalytics(
        totalFavorites: totalFavorites,
        todayCount: todayCount,
        thisWeekCount: thisWeekCount,
        thisMonthCount: thisMonthCount,
        topProducts: topProducts,
      );
    });
  }

  Stream<RatingAnalytics> streamRatingAnalytics(String sellerId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfThisWeek =
        startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfThisMonth = DateTime(now.year, now.month, 1);

    return _firestore
        .collection('reviews')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final totalReviews = snapshot.docs.length;
      double totalRating = 0;
      int todayCount = 0;
      int thisWeekCount = 0;
      int thisMonthCount = 0;
      final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      final List<RecentReview> recent = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] as num?)?.toDouble() ?? 0;
        totalRating += rating;

        final star = rating.round();
        if (star >= 1 && star <= 5) distribution[star] = (distribution[star] ?? 0) + 1;

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          if (!createdAt.isBefore(startOfToday)) todayCount++;
          if (!createdAt.isBefore(startOfThisWeek)) thisWeekCount++;
          if (!createdAt.isBefore(startOfThisMonth)) thisMonthCount++;
          recent.add(RecentReview(
            customerName: data['customerName'] as String? ?? 'Anonymous',
            customerAvatarUrl: data['customerAvatarUrl'] as String?,
            rating: rating,
            content: data['content'] as String? ?? '',
            createdAt: createdAt,
          ));
        }
      }

      recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return RatingAnalytics(
        averageRating: totalReviews > 0 ? totalRating / totalReviews : 0.0,
        totalReviews: totalReviews,
        todayCount: todayCount,
        thisWeekCount: thisWeekCount,
        thisMonthCount: thisMonthCount,
        ratingDistribution: distribution,
        recentReviews: recent.take(5).toList(),
      );
    });
  }
}
