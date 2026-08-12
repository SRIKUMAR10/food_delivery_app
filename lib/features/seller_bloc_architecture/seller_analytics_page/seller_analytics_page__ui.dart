import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/analytics_data_model.dart';
import 'seller_analytics_page__bloc.dart';
import 'seller_analytics_page__event.dart';
import 'seller_analytics_page__state.dart';

class SellerAnalyticsPageUI extends StatelessWidget {
  const SellerAnalyticsPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Store Performance & Growth',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SellerAnalyticsBloc, SellerAnalyticsState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            if (state is AnalyticsInitial) {
              final String sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<SellerAnalyticsBloc>().add(LoadSellerAnalytics(sellerId: sellerId, timeRange: 'Weekly'));
              return const _SkeletonLoader();
            } else if (state is AnalyticsLoading) {
              return const _SkeletonLoader();
            } else if (state is AnalyticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading analytics',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (state is AnalyticsEmpty) {
              return _AnalyticsContent(
                data: AnalyticsDataModel(
                  todayRevenue: 0,
                  thisWeekRevenue: 0,
                  thisMonthRevenue: 0,
                  currentPeriodCustomers: 0,
                  previousPeriodCustomers: 0,
                  customerGrowthPercentage: 0,
                  top3PeakTimeSlots: const [],
                  bestSellingProducts: const [],
                  revenueChartData: const [],
                ),
                selectedTimeRange: state.selectedTimeRange,
                isEmpty: true,
              );
            } else if (state is AnalyticsLoaded) {
              return _AnalyticsContent(
                data: state.data,
                selectedTimeRange: state.selectedTimeRange,
                isEmpty: false,
                favorites: state.favorites,
                ratingAnalytics: state.ratingAnalytics,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final AnalyticsDataModel data;
  final String selectedTimeRange;
  final bool isEmpty;
  final FavoritesAnalytics? favorites;
  final RatingAnalytics? ratingAnalytics;

  const _AnalyticsContent({
    required this.data,
    required this.selectedTimeRange,
    this.isEmpty = false,
    this.favorites,
    this.ratingAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Summary Cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _RevenueSummaryCard(title: 'Today', amount: data.todayRevenue, isPrimary: true),
                        const SizedBox(width: 12),
                        _RevenueSummaryCard(title: 'This Week', amount: data.thisWeekRevenue),
                        const SizedBox(width: 12),
                        _RevenueSummaryCard(title: 'This Month', amount: data.thisMonthRevenue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header (Time Range Dropdown)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Insights',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTimeRange,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF1E293B)),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            items: ['Weekly', 'Monthly'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                final currentSellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                                context.read<SellerAnalyticsBloc>().add(
                                      LoadSellerAnalytics(sellerId: currentSellerId, timeRange: newValue),
                                    );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No completed orders yet.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data will appear here once orders are delivered.',
                              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Customer Growth & Peak Time Row
                    Row(
                      children: [
                        Expanded(
                          child: _InsightCard(
                            title: 'Customer Growth',
                            value: '${data.currentPeriodCustomers}',
                            subtitle: 'Unique Customers',
                            growth: data.customerGrowthPercentage,
                            icon: Icons.people_alt,
                            iconColor: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _InsightCard(
                            title: 'Peak Time',
                            value: data.top3PeakTimeSlots.isNotEmpty ? data.top3PeakTimeSlots.first : '--',
                            subtitle: 'Busiest Hour',
                            growth: null,
                            icon: Icons.access_time_filled,
                            iconColor: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Chart
                    _RevenueChart(data: data, timeframe: selectedTimeRange),
                    const SizedBox(height: 32),

                    // Best Selling Products
                    Text(
                      'Best Selling Products',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.bestSellingProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = data.bestSellingProducts[index];
                        return _BestSellerTile(product: product, index: index);
                      },
                    ),
                    if (favorites != null) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Favorites Analytics',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FavoritesStatCard(
                              title: 'Today',
                              count: favorites!.todayCount,
                              icon: Icons.today,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 12),
                            _FavoritesStatCard(
                              title: 'This Week',
                              count: favorites!.thisWeekCount,
                              icon: Icons.date_range,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 12),
                            _FavoritesStatCard(
                              title: 'This Month',
                              count: favorites!.thisMonthCount,
                              icon: Icons.calendar_month,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 12),
                            _FavoritesStatCard(
                              title: 'Total',
                              count: favorites!.totalFavorites,
                              icon: Icons.favorite,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (favorites!.topProducts.isNotEmpty) ...[
                        Text(
                          'Top Favorited Products',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favorites!.topProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final product = favorites!.topProducts[index];
                            return _FavoriteProductTile(
                              product: product,
                              index: index,
                            );
                          },
                        ),
                    ],
                      ],
                      if (ratingAnalytics != null) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Ratings & Reviews',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _RatingAvgCard(rating: ratingAnalytics!.averageRating, total: ratingAnalytics!.totalReviews),
                              const SizedBox(width: 12),
                              _FavoritesStatCard(
                                title: 'Today',
                                count: ratingAnalytics!.todayCount,
                                icon: Icons.today,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 12),
                              _FavoritesStatCard(
                                title: 'This Week',
                                count: ratingAnalytics!.thisWeekCount,
                                icon: Icons.date_range,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              _FavoritesStatCard(
                                title: 'Total',
                                count: ratingAnalytics!.totalReviews,
                                icon: Icons.star,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Rating Distribution
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rating Distribution',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(5, (i) {
                                final star = 5 - i;
                                final count = ratingAnalytics!.ratingDistribution[star] ?? 0;
                                final pct = ratingAnalytics!.totalReviews > 0
                                    ? count / ratingAnalytics!.totalReviews
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          '$star ${star == 1 ? 'star' : 'stars'}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            color: star >= 4
                                                ? Colors.green
                                                : star >= 3
                                                    ? Colors.orange
                                                    : Colors.red,
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        if (ratingAnalytics!.recentReviews.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Recent Reviews',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ratingAnalytics!.recentReviews.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final review = ratingAnalytics!.recentReviews[index];
                              return _RecentReviewTile(review: review);
                            },
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}

class _RatingAvgCard extends StatelessWidget {
  final double rating;
  final int total;

  const _RatingAvgCard({required this.rating, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.amber, size: 18),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/ 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Average Rating',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReviewTile extends StatelessWidget {
  final RecentReview review;

  const _RecentReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: review.customerAvatarUrl != null && review.customerAvatarUrl!.isNotEmpty
                    ? NetworkImage(review.customerAvatarUrl!)
                    : null,
                child: review.customerAvatarUrl == null || review.customerAvatarUrl!.isEmpty
                    ? Text(
                        review.customerName.isNotEmpty
                            ? review.customerName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.customerName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          if (review.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.content,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _RevenueSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isPrimary;

  const _RevenueSummaryCard({
    required this.title,
    required this.amount,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF6366F1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary
            ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        border: isPrimary ? null : Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: isPrimary ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount),
            style: GoogleFonts.plusJakartaSans(
              color: isPrimary ? Colors.white : const Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double? growth;
  final IconData icon;
  final Color iconColor;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.growth,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth != null && growth! >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12, color: isPositive ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '${growth!.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final AnalyticsDataModel data;
  final String timeframe;

  const _RevenueChart({required this.data, required this.timeframe});

  @override
  Widget build(BuildContext context) {
    if (data.revenueChartData.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Text('Not enough data to draw chart'),
      );
    }

    final chartHeight = 160.0;
    final maxValue = data.revenueChartData.fold<double>(0, (prev, e) => e.value > prev ? e.value : prev);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Trend',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight + 30,
            child: Row(
              children: [
                // Y-Axis
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${maxValue.toInt()}', style: _axisStyle()),
                      Text('₹${(maxValue * 0.75).toInt()}', style: _axisStyle()),
                      Text('₹${(maxValue * 0.5).toInt()}', style: _axisStyle()),
                      Text('₹${(maxValue * 0.25).toInt()}', style: _axisStyle()),
                      Text('₹0', style: _axisStyle()),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chart Area
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (_) => Container(height: 1, color: const Color(0xFFE5E7EB))),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.revenueChartData.map((point) {
                          final normalizedHeight = maxValue > 0 ? (point.value / maxValue) * chartHeight : 0.0;
                          final dateLabel = timeframe == 'Weekly' 
                              ? DateFormat('EEE').format(point.date) // Mon, Tue
                              : DateFormat('dd').format(point.date); // 01, 02
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: normalizedHeight),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Tooltip(
                                    message: '₹${point.value.toInt()}',
                                    child: Container(
                                      width: timeframe == 'Weekly' ? 24 : (MediaQuery.of(context).size.width > 400 ? 12 : 8),
                                      height: value,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 20,
                                child: Text(dateLabel, style: _axisStyle()),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _axisStyle() => GoogleFonts.plusJakartaSans(
    color: const Color(0xFF9CA3AF),
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}

class _BestSellerTile extends StatelessWidget {
  final BestSellingProductModel product;
  final int index;

  const _BestSellerTile({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '#${index + 1}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.unitsSold} units sold',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(product.revenueGenerated),
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2ECA69),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmer(width: 120, height: 80, borderRadius: 16),
              const SizedBox(width: 12),
              _buildShimmer(width: 120, height: 80, borderRadius: 16),
              const SizedBox(width: 12),
              _buildShimmer(width: 120, height: 80, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmer(width: 100, height: 24),
              _buildShimmer(width: 100, height: 32, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildShimmer(width: double.infinity, height: 120, borderRadius: 16)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmer(width: double.infinity, height: 120, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _buildShimmer(width: double.infinity, height: 200, borderRadius: 20),
        ],
      ),
    );
  }

  Widget _buildShimmer({required double width, required double height, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _FavoritesStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _FavoritesStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteProductTile extends StatelessWidget {
  final FavoriteProductStats product;
  final int index;

  const _FavoriteProductTile({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '#${index + 1}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                product.productName,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${product.favoriteCount}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
