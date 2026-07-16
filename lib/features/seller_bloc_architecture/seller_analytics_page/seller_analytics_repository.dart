import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/analytics_data_model.dart';
import '../../../../core/models/order_status.dart';

class SellerAnalyticsRepository {
  final FirebaseFirestore _firestore;

  SellerAnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
}
