import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/models/analytics_data_model.dart';
import '../../../../core/models/order_status.dart';

class SellerAnalyticsRepository {
  final FirebaseFirestore _firestore;

  SellerAnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<AnalyticsDataModel> streamAnalyticsData(
      String sellerId, String timeframe) {
    final ordersStream = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();

    final productsStream = _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();

    return Rx.combineLatest2(
      ordersStream,
      productsStream,
      (QuerySnapshot<Map<String, dynamic>> ordersSnap,
          QuerySnapshot<Map<String, dynamic>> productsSnap) {
        return _calculateAnalytics(
          ordersSnap.docs,
          productsSnap.docs,
          timeframe,
        );
      },
    );
  }

  Future<AnalyticsDataModel> fetchAnalyticsData(
      String sellerId, String timeframe) async {
    final ordersSnap = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final productsSnap = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    return _calculateAnalytics(
      ordersSnap.docs,
      productsSnap.docs,
      timeframe,
    );
  }

  AnalyticsDataModel _calculateAnalytics(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orderDocs,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> productDocs,
    String timeframe,
  ) {
    final now = DateTime.now();

    // 1. Time Boundaries
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));
    final endOfYesterday = startOfToday.subtract(const Duration(microseconds: 1));

    final startOfThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(const Duration(microseconds: 1));

    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = startOfThisMonth.subtract(const Duration(microseconds: 1));

    final startOfThisYear = DateTime(now.year, 1, 1);
    final startOfLastYear = DateTime(now.year - 1, 1, 1);
    final endOfLastYear = startOfThisYear.subtract(const Duration(microseconds: 1));

    // Determine current & previous period starts based on timeframe
    DateTime currentPeriodStart;
    DateTime previousPeriodStart;
    DateTime previousPeriodEnd;

    switch (timeframe) {
      case 'Daily':
      case 'Today':
        currentPeriodStart = startOfToday;
        previousPeriodStart = startOfYesterday;
        previousPeriodEnd = endOfYesterday;
        break;
      case 'Monthly':
        currentPeriodStart = startOfThisMonth;
        previousPeriodStart = startOfLastMonth;
        previousPeriodEnd = endOfLastMonth;
        break;
      case 'Yearly':
        currentPeriodStart = startOfThisYear;
        previousPeriodStart = startOfLastYear;
        previousPeriodEnd = endOfLastYear;
        break;
      case 'Weekly':
      default:
        currentPeriodStart = startOfThisWeek;
        previousPeriodStart = startOfLastWeek;
        previousPeriodEnd = endOfLastWeek;
        break;
    }

    // 2. Revenue & Sales Aggregates
    double todayRev = 0.0;
    double yesterdayRev = 0.0;

    double thisWeekRev = 0.0;
    double lastWeekRev = 0.0;

    double thisMonthRev = 0.0;
    double lastMonthRev = 0.0;

    double thisYearRev = 0.0;
    double lastYearRev = 0.0;

    // Timeframe-specific order metrics
    int totalOrders = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;
    int pendingOrders = 0;
    double timeframeDeliveredRev = 0.0;

    Set<String> currentCustomers = {};
    Set<String> previousCustomers = {};
    Set<String> priorCustomers = {};

    Map<int, int> hourlyCounts = {for (var i = 0; i < 24; i++) i: 0};
    Map<int, double> hourlyRevenue = {for (var i = 0; i < 24; i++) i: 0.0};

    // Item stats: Key -> productName or productId
    Map<String, _ProductStatAccumulator> soldItemStats = {};

    for (var doc in orderDocs) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final rawTimestamp = data['timestamp'];
      DateTime? timestamp;
      if (rawTimestamp is Timestamp) {
        timestamp = rawTimestamp.toDate();
      } else if (rawTimestamp is String) {
        timestamp = DateTime.tryParse(rawTimestamp);
      }
      if (timestamp == null) continue;

      final customerId = data['customerId'] as String? ?? '';
      final items = data['items'] as List<dynamic>? ?? [];
      final isDelivered = status == OrderStatus.delivered.value || status.toLowerCase() == 'delivered';
      final isCancelled = status == OrderStatus.cancelled.value ||
          status == OrderStatus.rejected.value ||
          status.toLowerCase() == 'cancelled' ||
          status.toLowerCase() == 'rejected';

      // Global Revenue calculations (Delivered only)
      if (isDelivered) {
        if (!timestamp.isBefore(startOfToday)) {
          todayRev += amount;
        } else if (!timestamp.isBefore(startOfYesterday) && timestamp.isBefore(startOfToday)) {
          yesterdayRev += amount;
        }

        if (!timestamp.isBefore(startOfThisWeek)) {
          thisWeekRev += amount;
        } else if (!timestamp.isBefore(startOfLastWeek) && timestamp.isBefore(startOfThisWeek)) {
          lastWeekRev += amount;
        }

        if (!timestamp.isBefore(startOfThisMonth)) {
          thisMonthRev += amount;
        } else if (!timestamp.isBefore(startOfLastMonth) && timestamp.isBefore(startOfThisMonth)) {
          lastMonthRev += amount;
        }

        if (!timestamp.isBefore(startOfThisYear)) {
          thisYearRev += amount;
        } else if (!timestamp.isBefore(startOfLastYear) && timestamp.isBefore(startOfThisYear)) {
          lastYearRev += amount;
        }
      }

      // Customer history mapping for repeat buyer detection
      if (customerId.isNotEmpty) {
        if (timestamp.isBefore(currentPeriodStart)) {
          priorCustomers.add(customerId);
        }
        if (!timestamp.isBefore(previousPeriodStart) && timestamp.isBefore(currentPeriodStart)) {
          previousCustomers.add(customerId);
        }
      }

      // Timeframe-specific order processing
      if (!timestamp.isBefore(currentPeriodStart)) {
        totalOrders++;
        if (customerId.isNotEmpty) {
          currentCustomers.add(customerId);
        }

        if (isDelivered) {
          completedOrders++;
          timeframeDeliveredRev += amount;

          // Hourly distribution
          hourlyCounts[timestamp.hour] = (hourlyCounts[timestamp.hour] ?? 0) + 1;
          hourlyRevenue[timestamp.hour] = (hourlyRevenue[timestamp.hour] ?? 0.0) + amount;

          // Product sales stats
          for (var item in items) {
            if (item is Map) {
              final name = item['name'] as String? ?? 'Unknown Product';
              final id = (item['id'] ?? item['productId'] ?? name) as String;
              final qty = (item['quantity'] as num?)?.toInt() ?? 1;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              final rev = price * qty;
              final img = item['imageUrl'] as String?;

              if (soldItemStats.containsKey(id)) {
                soldItemStats[id]!.unitsSold += qty;
                soldItemStats[id]!.revenueGenerated += rev;
              } else if (soldItemStats.containsKey(name)) {
                soldItemStats[name]!.unitsSold += qty;
                soldItemStats[name]!.revenueGenerated += rev;
              } else {
                soldItemStats[id] = _ProductStatAccumulator(
                  productId: id,
                  productName: name,
                  price: price,
                  unitsSold: qty,
                  revenueGenerated: rev,
                  imageUrl: img,
                );
              }
            }
          }
        } else if (isCancelled) {
          cancelledOrders++;
        } else {
          pendingOrders++;
        }
      }
    }

    // 3. Growth Percentages
    double calcGrowth(double prev, double curr) {
      if (prev <= 0) return curr > 0 ? 100.0 : 0.0;
      return ((curr - prev) / prev) * 100.0;
    }

    final todayGrowth = calcGrowth(yesterdayRev, todayRev);
    final weekGrowth = calcGrowth(lastWeekRev, thisWeekRev);
    final monthGrowth = calcGrowth(lastMonthRev, thisMonthRev);
    final yearGrowth = calcGrowth(lastYearRev, thisYearRev);

    final currCustCount = currentCustomers.length;
    final prevCustCount = previousCustomers.length;
    final customerGrowth = calcGrowth(prevCustCount.toDouble(), currCustCount.toDouble());

    // Repeat vs New Customers in current timeframe
    int repeatCust = 0;
    for (var c in currentCustomers) {
      if (priorCustomers.contains(c)) {
        repeatCust++;
      }
    }
    final newCust = currCustCount - repeatCust;

    // Rates
    final completionRate = totalOrders > 0 ? (completedOrders / totalOrders) * 100.0 : 0.0;
    final cancellationRate = totalOrders > 0 ? (cancelledOrders / totalOrders) * 100.0 : 0.0;
    final aov = completedOrders > 0 ? (timeframeDeliveredRev / completedOrders) : 0.0;

    // 4. Peak Hours
    final sortedHours = hourlyCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3Hours = sortedHours
        .where((e) => e.value > 0)
        .take(3)
        .map((e) {
          final hour = e.key;
          final start = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final amPm = hour >= 12 ? 'PM' : 'AM';
          final endHour = (hour + 1) % 24;
          final end = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
          final endAmPm = endHour >= 12 ? 'PM' : 'AM';
          return '$start $amPm - $end $endAmPm';
        })
        .toList();

    if (top3Hours.isEmpty && sortedHours.isNotEmpty) {
      top3Hours.add('12 PM - 1 PM');
    }

    final hourlyChartData = List.generate(24, (h) {
      final hour = h;
      final start = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      return HourlyChartPoint(
        hour: h,
        orderCount: hourlyCounts[h] ?? 0,
        revenue: hourlyRevenue[h] ?? 0.0,
        label: '$start$amPm',
      );
    });

    // 5. Product Performance & Top/Low Performing Products
    // Build catalog map
    final Map<String, ProductPerformanceModel> catalogMap = {};

    for (var pDoc in productDocs) {
      final pData = pDoc.data();
      final pId = pDoc.id;
      final pName = pData['name'] as String? ?? 'Product';
      final pPrice = (pData['price'] as num?)?.toDouble() ?? 0.0;
      final pStock = (pData['availableStock'] as num?)?.toInt() ??
          (pData['stock'] as num?)?.toInt() ??
          0;
      final pCategory = pData['category'] as String? ?? 'General';
      final pImages = pData['imageUrls'] as List<dynamic>? ?? [];
      final pImage = pImages.isNotEmpty ? pImages.first as String : null;
      final pActive = pData['isActive'] as bool? ?? true;

      // Check if sold
      int soldUnits = 0;
      double genRev = 0.0;
      if (soldItemStats.containsKey(pId)) {
        soldUnits = soldItemStats[pId]!.unitsSold;
        genRev = soldItemStats[pId]!.revenueGenerated;
      } else if (soldItemStats.containsKey(pName)) {
        soldUnits = soldItemStats[pName]!.unitsSold;
        genRev = soldItemStats[pName]!.revenueGenerated;
      }

      final share = timeframeDeliveredRev > 0
          ? (genRev / timeframeDeliveredRev) * 100.0
          : 0.0;

      catalogMap[pId] = ProductPerformanceModel(
        productId: pId,
        productName: pName,
        price: pPrice,
        unitsSold: soldUnits,
        revenueGenerated: genRev,
        sharePercentage: share,
        availableStock: pStock,
        category: pCategory,
        imageUrl: pImage,
        isActive: pActive,
      );
    }

    // Include sold items that may not be in catalogDocs
    for (var entry in soldItemStats.entries) {
      if (!catalogMap.containsKey(entry.key) &&
          !catalogMap.values.any((p) => p.productName == entry.value.productName)) {
        final share = timeframeDeliveredRev > 0
            ? (entry.value.revenueGenerated / timeframeDeliveredRev) * 100.0
            : 0.0;
        catalogMap[entry.key] = ProductPerformanceModel(
          productId: entry.value.productId,
          productName: entry.value.productName,
          price: entry.value.price,
          unitsSold: entry.value.unitsSold,
          revenueGenerated: entry.value.revenueGenerated,
          sharePercentage: share,
          availableStock: 0,
          category: 'General',
          imageUrl: entry.value.imageUrl,
          isActive: true,
        );
      }
    }

    final allProductPerformances = catalogMap.values.toList()
      ..sort((a, b) {
        final cmp = b.unitsSold.compareTo(a.unitsSold);
        return cmp != 0 ? cmp : b.revenueGenerated.compareTo(a.revenueGenerated);
      });

    final bestSellingProducts = allProductPerformances
        .where((p) => p.unitsSold > 0)
        .take(5)
        .map((p) => BestSellingProductModel(
              productId: p.productId,
              productName: p.productName,
              unitsSold: p.unitsSold,
              revenueGenerated: p.revenueGenerated,
              price: p.price,
              sharePercentage: p.sharePercentage,
              imageUrl: p.imageUrl,
            ))
        .toList();

    final lowPerformingProducts = allProductPerformances
        .where((p) => p.unitsSold == 0 || p.unitsSold <= 2)
        .toList()
      ..sort((a, b) => a.unitsSold.compareTo(b.unitsSold));

    // 6. Dynamic Chart Data based on timeframe
    final List<ChartDataPoint> chartDataPoints = _generateChartData(
      orderDocs,
      timeframe,
      now,
      startOfToday,
      startOfThisWeek,
      startOfThisMonth,
      startOfThisYear,
    );

    // Order status map
    final orderStatusMap = {
      'Delivered': completedOrders,
      'Cancelled': cancelledOrders,
      'In-Progress': pendingOrders,
    };

    return AnalyticsDataModel(
      todayRevenue: todayRev,
      yesterdayRevenue: yesterdayRev,
      todayGrowthPercentage: todayGrowth,
      thisWeekRevenue: thisWeekRev,
      lastWeekRevenue: lastWeekRev,
      weekGrowthPercentage: weekGrowth,
      thisMonthRevenue: thisMonthRev,
      lastMonthRevenue: lastMonthRev,
      monthGrowthPercentage: monthGrowth,
      thisYearRevenue: thisYearRev,
      lastYearRevenue: lastYearRev,
      yearGrowthPercentage: yearGrowth,
      totalOrdersCount: totalOrders,
      completedOrdersCount: completedOrders,
      cancelledOrdersCount: cancelledOrders,
      pendingOrdersCount: pendingOrders,
      averageOrderValue: aov,
      orderCompletionRate: completionRate,
      orderCancellationRate: cancellationRate,
      currentPeriodCustomers: currCustCount,
      previousPeriodCustomers: prevCustCount,
      customerGrowthPercentage: customerGrowth,
      newCustomersCount: newCust,
      repeatCustomersCount: repeatCust,
      top3PeakTimeSlots: top3Hours,
      hourlyOrderCounts: hourlyCounts,
      hourlyChartData: hourlyChartData,
      bestSellingProducts: bestSellingProducts,
      lowPerformingProducts: lowPerformingProducts.take(5).toList(),
      allProductPerformances: allProductPerformances,
      revenueChartData: chartDataPoints,
      orderStatusDistribution: orderStatusMap,
    );
  }

  List<ChartDataPoint> _generateChartData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orderDocs,
    String timeframe,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfThisWeek,
    DateTime startOfThisMonth,
    DateTime startOfThisYear,
  ) {
    if (timeframe == 'Daily' || timeframe == 'Today') {
      // 8 intervals of 3 hours for today
      final Map<int, double> hourlyBuckets = {for (var i = 0; i < 24; i += 3) i: 0.0};
      for (var doc in orderDocs) {
        final data = doc.data();
        if (data['status'] != OrderStatus.delivered.value) continue;
        final rawTs = data['timestamp'];
        DateTime? ts;
        if (rawTs is Timestamp) ts = rawTs.toDate();
        if (ts == null || ts.isBefore(startOfToday)) continue;

        final bucket = (ts.hour ~/ 3) * 3;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        hourlyBuckets[bucket] = (hourlyBuckets[bucket] ?? 0.0) + amount;
      }

      return hourlyBuckets.entries.map((e) {
        final hour = e.key;
        final start = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';
        return ChartDataPoint(
          date: startOfToday.add(Duration(hours: hour)),
          value: e.value,
          label: '$start$amPm',
        );
      }).toList();
    } else if (timeframe == 'Monthly') {
      // Days of the current month
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final Map<int, double> dayBuckets = {for (var i = 1; i <= daysInMonth; i++) i: 0.0};

      for (var doc in orderDocs) {
        final data = doc.data();
        if (data['status'] != OrderStatus.delivered.value) continue;
        final rawTs = data['timestamp'];
        DateTime? ts;
        if (rawTs is Timestamp) ts = rawTs.toDate();
        if (ts == null || ts.isBefore(startOfThisMonth) || ts.year != now.year || ts.month != now.month) continue;

        dayBuckets[ts.day] = (dayBuckets[ts.day] ?? 0.0) + ((data['amount'] as num?)?.toDouble() ?? 0.0);
      }

      return dayBuckets.entries.map((e) {
        return ChartDataPoint(
          date: DateTime(now.year, now.month, e.key),
          value: e.value,
          label: e.key.toString().padLeft(2, '0'),
        );
      }).toList();
    } else if (timeframe == 'Yearly') {
      // 12 months
      final Map<int, double> monthBuckets = {for (var i = 1; i <= 12; i++) i: 0.0};

      for (var doc in orderDocs) {
        final data = doc.data();
        if (data['status'] != OrderStatus.delivered.value) continue;
        final rawTs = data['timestamp'];
        DateTime? ts;
        if (rawTs is Timestamp) ts = rawTs.toDate();
        if (ts == null || ts.isBefore(startOfThisYear) || ts.year != now.year) continue;

        monthBuckets[ts.month] = (monthBuckets[ts.month] ?? 0.0) + ((data['amount'] as num?)?.toDouble() ?? 0.0);
      }

      return monthBuckets.entries.map((e) {
        final monthName = DateFormat('MMM').format(DateTime(now.year, e.key, 1));
        return ChartDataPoint(
          date: DateTime(now.year, e.key, 1),
          value: e.value,
          label: monthName,
        );
      }).toList();
    } else {
      // Weekly: 7 days Mon - Sun
      final Map<int, double> weekdayBuckets = {for (var i = 0; i < 7; i++) i: 0.0};

      for (var doc in orderDocs) {
        final data = doc.data();
        if (data['status'] != OrderStatus.delivered.value) continue;
        final rawTs = data['timestamp'];
        DateTime? ts;
        if (rawTs is Timestamp) ts = rawTs.toDate();
        if (ts == null || ts.isBefore(startOfThisWeek)) continue;

        final dayDiff = ts.difference(startOfThisWeek).inDays;
        if (dayDiff >= 0 && dayDiff < 7) {
          weekdayBuckets[dayDiff] = (weekdayBuckets[dayDiff] ?? 0.0) + ((data['amount'] as num?)?.toDouble() ?? 0.0);
        }
      }

      return weekdayBuckets.entries.map((e) {
        final d = startOfThisWeek.add(Duration(days: e.key));
        return ChartDataPoint(
          date: d,
          value: e.value,
          label: DateFormat('EEE').format(d),
        );
      }).toList();
    }
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

class _ProductStatAccumulator {
  final String productId;
  final String productName;
  final double price;
  int unitsSold;
  double revenueGenerated;
  final String? imageUrl;

  _ProductStatAccumulator({
    required this.productId,
    required this.productName,
    required this.price,
    required this.unitsSold,
    required this.revenueGenerated,
    this.imageUrl,
  });
}

