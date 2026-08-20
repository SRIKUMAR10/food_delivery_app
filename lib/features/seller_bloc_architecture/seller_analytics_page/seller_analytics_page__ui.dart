import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/shimmer_loader.dart';
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
        shadowColor: Colors.black.withValues(alpha: 0.08),
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
            Row(
              children: [
                Text(
                  'Analytics',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live Sync',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Real-Time Store Performance & Insights',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SellerAnalyticsBloc, SellerAnalyticsState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType || previous != current,
          builder: (context, state) {
            if (state is AnalyticsInitial) {
              final String sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<SellerAnalyticsBloc>().add(
                    LoadSellerAnalytics(sellerId: sellerId, timeRange: 'Weekly'),
                  );
              return SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: double.infinity, height: 48, borderRadius: 14),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: SkeletonBox(width: double.infinity, height: 110, borderRadius: 16)),
                        const SizedBox(width: 12),
                        const Expanded(child: SkeletonBox(width: double.infinity, height: 110, borderRadius: 16)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const SkeletonBox(width: double.infinity, height: 180, borderRadius: 16),
                    const SizedBox(height: 18),
                    const SkeletonBox(width: double.infinity, height: 240, borderRadius: 20),
                  ],
                ),
              );
            } else if (state is AnalyticsLoading) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: double.infinity, height: 48, borderRadius: 14),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: SkeletonBox(width: double.infinity, height: 110, borderRadius: 16)),
                        const SizedBox(width: 12),
                        const Expanded(child: SkeletonBox(width: double.infinity, height: 110, borderRadius: 16)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const SkeletonBox(width: double.infinity, height: 180, borderRadius: 16),
                    const SizedBox(height: 18),
                    const SkeletonBox(width: double.infinity, height: 240, borderRadius: 20),
                  ],
                ),
              );
            } else if (state is AnalyticsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 54),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to Load Analytics',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          final sellerId =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          context.read<SellerAnalyticsBloc>().add(
                                LoadSellerAnalytics(
                                    sellerId: sellerId, timeRange: 'Weekly'),
                              );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is AnalyticsEmpty) {
              return _AnalyticsContent(
                data: const AnalyticsDataModel(
                  todayRevenue: 0,
                  thisWeekRevenue: 0,
                  thisMonthRevenue: 0,
                  thisYearRevenue: 0,
                  currentPeriodCustomers: 0,
                  previousPeriodCustomers: 0,
                  customerGrowthPercentage: 0,
                  top3PeakTimeSlots: [],
                  bestSellingProducts: [],
                  revenueChartData: [],
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

class _AnalyticsContent extends StatefulWidget {
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
  State<_AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<_AnalyticsContent> {
  int _productTab = 0; // 0: Best Sellers, 1: Low Performing, 2: All Matrix
  String _productSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final selectedTimeRange = widget.selectedTimeRange;
    final isEmpty = widget.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : (isTablet ? 800 : double.infinity),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeframe Filter Bar (Daily, Weekly, Monthly, Yearly)
                  _buildTimeframeSelector(context, selectedTimeRange),
                  const SizedBox(height: 18),

                  // 1. Executive Sales KPI Cards (Daily, Weekly, Monthly, Yearly)
                  _buildSalesSummaryCards(data, isDesktop, isTablet),
                  const SizedBox(height: 20),

                  // 2. Operational & Business Health KPIs Grid
                  _buildOperationalMetricsGrid(data, isDesktop, isTablet),
                  const SizedBox(height: 24),

                  if (isEmpty)
                    _buildEmptyState()
                  else ...[
                    // 3. Dynamic Charts Section
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _RevenueChartCard(
                              data: data,
                              timeframe: selectedTimeRange,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 2,
                            child: _OrderStatusDonutCard(data: data),
                          ),
                        ],
                      )
                    else ...[
                      _RevenueChartCard(
                        data: data,
                        timeframe: selectedTimeRange,
                      ),
                      const SizedBox(height: 18),
                      _OrderStatusDonutCard(data: data),
                    ],
                    const SizedBox(height: 20),

                    // 4. Peak Order Time & 24-Hour Distribution Chart
                    _HourlyPeakChartCard(data: data),
                    const SizedBox(height: 24),

                    // 5. Product Intelligence (Best Sellers, Low Performing, Matrix)
                    _buildProductIntelligenceSection(data),
                    const SizedBox(height: 24),

                    // 6. Real-Time Customer Ratings & Reviews
                    if (widget.ratingAnalytics != null) ...[
                      _buildRatingsSection(widget.ratingAnalytics!),
                      const SizedBox(height: 24),
                    ],

                    // 7. Product Favorites Analytics
                    if (widget.favorites != null) ...[
                      _buildFavoritesSection(widget.favorites!),
                      const SizedBox(height: 24),
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

  Widget _buildTimeframeSelector(BuildContext context, String selected) {
    final List<String> timeframes = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: timeframes.map((tf) {
          final isSelected = selected == tf ||
              (selected == 'Today' && tf == 'Daily');
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                context.read<SellerAnalyticsBloc>().add(
                      LoadSellerAnalytics(sellerId: sellerId, timeRange: tf),
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tf,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSalesSummaryCards(
      AnalyticsDataModel data, bool isDesktop, bool isTablet) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final cards = [
      _SalesMetricCard(
        title: 'Daily Sales',
        amount: currencyFmt.format(data.todayRevenue),
        growth: data.todayGrowthPercentage,
        growthLabel: 'vs Yesterday',
        icon: Icons.today_rounded,
        gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        isPrimary: true,
      ),
      _SalesMetricCard(
        title: 'Weekly Sales',
        amount: currencyFmt.format(data.thisWeekRevenue),
        growth: data.weekGrowthPercentage,
        growthLabel: 'vs Last Week',
        icon: Icons.date_range_rounded,
        gradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      ),
      _SalesMetricCard(
        title: 'Monthly Sales',
        amount: currencyFmt.format(data.thisMonthRevenue),
        growth: data.monthGrowthPercentage,
        growthLabel: 'vs Last Month',
        icon: Icons.calendar_month_rounded,
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      ),
      _SalesMetricCard(
        title: 'Yearly Sales',
        amount: currencyFmt.format(data.thisYearRevenue),
        growth: data.yearGrowthPercentage,
        growthLabel: 'vs Last Year',
        icon: Icons.auto_graph_rounded,
        gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      ),
    ];

    if (isDesktop || isTablet) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isDesktop ? 1.6 : 1.8,
        children: cards,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: cards.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(width: 165, child: c),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperationalMetricsGrid(
      AnalyticsDataModel data, bool isDesktop, bool isTablet) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final items = [
      _OperationalMetricTile(
        title: 'Total Orders',
        value: '${data.totalOrdersCount}',
        subtitle: 'All order requests',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF6366F1),
      ),
      _OperationalMetricTile(
        title: 'Completed Orders',
        value: '${data.completedOrdersCount}',
        subtitle:
            '${data.orderCompletionRate.toStringAsFixed(0)}% completion rate',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
      ),
      _OperationalMetricTile(
        title: 'Cancelled Orders',
        value: '${data.cancelledOrdersCount}',
        subtitle:
            '${data.orderCancellationRate.toStringAsFixed(0)}% cancel rate',
        icon: Icons.cancel_outlined,
        color: const Color(0xFFEF4444),
      ),
      _OperationalMetricTile(
        title: 'Avg Order Value',
        value: currencyFmt.format(data.averageOrderValue),
        subtitle: 'AOV per delivery',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _OperationalMetricTile(
        title: 'Customer Growth',
        value: '${data.currentPeriodCustomers}',
        growth: data.customerGrowthPercentage,
        subtitle: '${data.repeatCustomersCount} repeat buyers',
        icon: Icons.people_alt_outlined,
        color: const Color(0xFF3B82F6),
      ),
      _OperationalMetricTile(
        title: 'Peak Order Time',
        value: data.top3PeakTimeSlots.isNotEmpty
            ? data.top3PeakTimeSlots.first
            : '12 PM - 1 PM',
        subtitle: 'Busiest rush window',
        icon: Icons.access_time_rounded,
        color: const Color(0xFFEC4899),
      ),
    ];

    final crossAxisCount = isDesktop ? 6 : (isTablet ? 3 : 2);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isDesktop ? 1.3 : (isTablet ? 1.4 : 1.3),
      children: items,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 54,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Delivered Orders Yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time business analytics will automatically populate here as soon as incoming orders are fulfilled and delivered.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductIntelligenceSection(AnalyticsDataModel data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Intelligence',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Real-time demand & product profitability',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              // Filter Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildSubTab('Top Best Sellers', 0),
                    _buildSubTab('Low Performing', 1),
                    _buildSubTab('Full Catalog Matrix', 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (_productTab == 0)
            _buildTopBestSellersList(data.bestSellingProducts)
          else if (_productTab == 1)
            _buildLowPerformingList(data.lowPerformingProducts)
          else
            _buildFullProductMatrix(data.allProductPerformances),
        ],
      ),
    );
  }

  Widget _buildSubTab(String title, int index) {
    final isSelected = _productTab == index;
    return GestureDetector(
      onTap: () => setState(() => _productTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBestSellersList(List<BestSellingProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No sales recorded in this timeframe yet.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = products[index];
        final rank = index + 1;
        Color badgeColor;
        Color badgeTextColor;
        if (rank == 1) {
          badgeColor = const Color(0xFFFEF3C7);
          badgeTextColor = const Color(0xFFD97706);
        } else if (rank == 2) {
          badgeColor = const Color(0xFFF1F5F9);
          badgeTextColor = const Color(0xFF64748B);
        } else if (rank == 3) {
          badgeColor = const Color(0xFFFFEDD5);
          badgeTextColor = const Color(0xFFC2410C);
        } else {
          badgeColor = const Color(0xFFF8FAFC);
          badgeTextColor = const Color(0xFF94A3B8);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: badgeTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.productName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${p.unitsSold} units sold',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        if (p.sharePercentage > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${p.sharePercentage.toStringAsFixed(1)}% of sales',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                NumberFormat.currency(
                        locale: 'en_IN', symbol: '₹', decimalDigits: 0)
                    .format(p.revenueGenerated),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLowPerformingList(List<ProductPerformanceModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'All products are performing well!',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = products[index];
        final isZero = p.unitsSold == 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isZero
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isZero
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFFEF3C7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isZero
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isZero ? Icons.warning_amber_rounded : Icons.trending_down,
                  color: isZero ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.productName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isZero
                          ? 'Zero units sold • Stock: ${p.availableStock}'
                          : '${p.unitsSold} units sold • Stock: ${p.availableStock}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isZero
                        ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isZero ? 'Review Price / Promo' : 'Boost Visibility',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isZero
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullProductMatrix(List<ProductPerformanceModel> allProducts) {
    final filtered = allProducts.where((p) {
      if (_productSearchQuery.isEmpty) return true;
      return p.productName
              .toLowerCase()
              .contains(_productSearchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_productSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _productSearchQuery = val),
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search products in catalog...',
            hintStyle: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'No products found matching query',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = filtered[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.productName,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${p.category} • ₹${p.price.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${p.unitsSold} Sold',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${p.availableStock} in stock',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: p.availableStock > 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '₹',
                                decimalDigits: 0)
                            .format(p.revenueGenerated),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRatingsSection(RatingAnalytics ratings) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Satisfaction & Reviews',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Rating Score Badge
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Column(
                  children: [
                    Text(
                      ratings.averageRating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        return Icon(
                          i < ratings.averageRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ratings.totalReviews} Total Reviews',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              // Distribution Progress Bars
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = ratings.ratingDistribution[star] ?? 0;
                    final pct = ratings.totalReviews > 0
                        ? count / ratings.totalReviews
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 45,
                            child: Text(
                              '$star Star',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: const Color(0xFFF1F5F9),
                                color: star >= 4
                                    ? const Color(0xFF10B981)
                                    : star == 3
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 25,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(FavoritesAnalytics favorites) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Favorites & Wishlists',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite,
                        size: 14, color: Color(0xFFEC4899)),
                    const SizedBox(width: 4),
                    Text(
                      '${favorites.totalFavorites} Total',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFBE185D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (favorites.topProducts.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...favorites.topProducts.take(4).map((fp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 18, color: Color(0xFFEC4899)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fp.productName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Text(
                        '${fp.favoriteCount} saves',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

class _SalesMetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final double growth;
  final String growthLabel;
  final IconData icon;
  final List<Color> gradient;
  final bool isPrimary;

  const _SalesMetricCard({
    required this.title,
    required this.amount,
    required this.growth,
    required this.growthLabel,
    required this.icon,
    required this.gradient,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${growth.abs().toStringAsFixed(1)}% $growthLabel',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationalMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double? growth;
  final IconData icon;
  final Color color;

  const _OperationalMetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    this.growth,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth != null && growth! >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (growth != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${growth!.toStringAsFixed(1)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPositive
                          ? const Color(0xFF047857)
                          : const Color(0xFFB91C1C),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  final AnalyticsDataModel data;
  final String timeframe;

  const _RevenueChartCard({required this.data, required this.timeframe});

  @override
  Widget build(BuildContext context) {
    if (data.revenueChartData.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'No chart data for $timeframe period',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
        ),
      );
    }

    const chartHeight = 160.0;
    final maxValue = data.revenueChartData.fold<double>(
        0, (prev, e) => e.value > prev ? e.value : prev);
    final safeMax = maxValue > 0 ? maxValue : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trend ($timeframe)',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Dynamic real-time sales progression',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Max: ₹${maxValue.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF4338CA),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight + 36,
            child: Row(
              children: [
                // Y-Axis scale
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
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
                const SizedBox(width: 10),
                // Chart Bars Area
                Expanded(
                  child: Stack(
                    children: [
                      // Grid lines
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (_) => Container(
                                height: 1, color: const Color(0xFFF1F5F9)),
                          ),
                        ),
                      ),
                      // Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.revenueChartData.map((point) {
                          final normalizedHeight =
                              (point.value / safeMax) * chartHeight;
                          final label = point.label ??
                              DateFormat('dd').format(point.date);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0, end: normalizedHeight),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Tooltip(
                                    message:
                                        '$label: ₹${point.value.toStringAsFixed(0)}',
                                    child: Container(
                                      width: timeframe == 'Weekly'
                                          ? 22
                                          : (timeframe == 'Yearly' ? 16 : 8),
                                      height: value.clamp(4.0, chartHeight),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: point.value > 0
                                              ? [
                                                  const Color(0xFF818CF8),
                                                  const Color(0xFF4F46E5),
                                                ]
                                              : [
                                                  const Color(0xFFE2E8F0),
                                                  const Color(0xFFCBD5E1),
                                                ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 18,
                                child: Text(label, style: _axisStyle()),
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
        color: const Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );
}

class _OrderStatusDonutCard extends StatelessWidget {
  final AnalyticsDataModel data;

  const _OrderStatusDonutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.totalOrdersCount > 0 ? data.totalOrdersCount : 1;
    final deliveredPct = (data.completedOrdersCount / total) * 100;
    final cancelledPct = (data.cancelledOrdersCount / total) * 100;
    final pendingPct = (data.pendingOrdersCount / total) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status Distribution',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Fulfillment reliability breakdown',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),

          // Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (data.completedOrdersCount > 0)
                    Expanded(
                      flex: data.completedOrdersCount,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (data.pendingOrdersCount > 0)
                    Expanded(
                      flex: data.pendingOrdersCount,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (data.cancelledOrdersCount > 0)
                    Expanded(
                      flex: data.cancelledOrdersCount,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (data.totalOrdersCount == 0)
                    Expanded(
                      child: Container(color: const Color(0xFFE2E8F0)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Legend Items
          _buildStatusRow(
            'Delivered',
            data.completedOrdersCount,
            deliveredPct,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'In Progress / Pending',
            data.pendingOrdersCount,
            pendingPct,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Cancelled / Rejected',
            data.cancelledOrdersCount,
            cancelledPct,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, double pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ),
        Text(
          '$count (${pct.toStringAsFixed(0)}%)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _HourlyPeakChartCard extends StatelessWidget {
  final AnalyticsDataModel data;

  const _HourlyPeakChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final points = data.hourlyChartData;
    final maxOrders = points.fold<int>(
        0, (prev, e) => e.orderCount > prev ? e.orderCount : prev);
    final safeMax = maxOrders > 0 ? maxOrders.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peak Order Times (24-Hour Distribution)',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Order density throughout the day',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (data.top3PeakTimeSlots.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on,
                          size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'Peak: ${data.top3PeakTimeSlots.first}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final height = (p.orderCount / safeMax) * 80;
                final isPeak = p.orderCount == maxOrders && maxOrders > 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: '${p.label}: ${p.orderCount} orders',
                          child: Container(
                            height: height.clamp(4.0, 80.0),
                            decoration: BoxDecoration(
                              color: isPeak
                                  ? const Color(0xFFF59E0B)
                                  : (p.orderCount > 0
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFE2E8F0)),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (p.hour % 4 == 0)
                          Text(
                            p.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          const SizedBox(height: 11),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}



