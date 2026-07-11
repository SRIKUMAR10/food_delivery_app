import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_analytics_page__bloc.dart';
import 'seller_analytics_page__event.dart';
import 'seller_analytics_page__state.dart';
import 'seller_analytics_repository.dart';

class SellerAnalyticsPageUI extends StatelessWidget {
  const SellerAnalyticsPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium light background
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
              'Today\'s Orders',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Analytics & Revenue',
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
          builder: (context, state) {
            if (state is AnalyticsInitial) {
              context.read<SellerAnalyticsBloc>().add(const LoadSellerAnalytics());
              return const _SkeletonLoader();
            } else if (state is AnalyticsLoading) {
              return const _SkeletonLoader();
            } else if (state is AnalyticsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is AnalyticsLoaded) {
              return _AnalyticsContent(
                data: state.data,
                selectedTimeRange: state.selectedTimeRange,
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
  final SellerAnalyticsData data;
  final String selectedTimeRange;

  const _AnalyticsContent({
    required this.data,
    required this.selectedTimeRange,
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
                  // Header (Time Range Dropdown)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTimeRange,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF1E1E2C)),
                            style: const TextStyle(
                              color: Color(0xFF1E1E2C),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            items: ['This Week', 'This Month', 'This Year']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                context
                                    .read<SellerAnalyticsBloc>()
                                    .add(LoadSellerAnalytics(timeRange: newValue));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Revenue Card
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Revenue',
                            style: TextStyle(
                              color: Color(0xFF1E1E2C),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
                                .format(data.totalRevenue),
                            style: const TextStyle(
                              color: Color(0xFF1E1E2C),
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '+${data.percentageChange}% ',
                                style: const TextStyle(
                                  color: Color(0xFF2ECA69),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'vs last week',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Advanced Custom Bar Chart
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              final double chartHeight = 180;
                              final maxValue = data.weeklyChartData
                                  .fold<double>(0.0, (double prev, double e) => e > prev ? e : prev);
                              final yAxisLabels = ['100%', '75%', '50%', '25%', '0%'];

                              return SizedBox(
                                height: chartHeight + 30, // 180 for chart + 30 for labels below
                                child: Row(
                                  children: [
                                    // Y-Axis
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 30), // Align with chart body
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(yAxisLabels.length, (index) {
                                          return Text(
                                            yAxisLabels[index],
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Chart Area
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          // Background Grid Lines
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 30),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(yAxisLabels.length, (index) {
                                                return Container(
                                                  height: 1,
                                                  color: const Color(0xFFE5E7EB).withValues(alpha: 0.8),
                                                );
                                              }),
                                            ),
                                          ),
                                          // Bars and X-Axis
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: List.generate(data.weeklyChartData.length, (index) {
                                              final double rawValue = data.weeklyChartData[index];
                                              final normalizedHeight = maxValue > 0
                                                  ? (rawValue / maxValue) * chartHeight
                                                  : 0.0;
                                              
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TweenAnimationBuilder<double>(
                                                    tween: Tween<double>(begin: 0, end: normalizedHeight),
                                                    duration: const Duration(milliseconds: 1200),
                                                    curve: Curves.easeOutCubic,
                                                    builder: (context, value, child) {
                                                      return Tooltip(
                                                        message: '₹${rawValue.toInt()}',
                                                        preferBelow: false,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF1E293B),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Container(
                                                          width: constraints.maxWidth > 400 ? 28 : 20,
                                                          height: value,
                                                          decoration: BoxDecoration(
                                                            gradient: const LinearGradient(
                                                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                                              begin: Alignment.topCenter,
                                                              end: Alignment.bottomCenter,
                                                            ),
                                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                                                blurRadius: 6,
                                                                offset: const Offset(0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                    height: 20,
                                                    child: Text(
                                                      labels[index],
                                                      style: const TextStyle(
                                                        color: Color(0xFF6B7280),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Top Products',
                    style: TextStyle(
                      color: Color(0xFF1E1E2C),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Top Products List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.topProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = data.topProducts[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  color: Color(0xFF1E1E2C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '${product.count}',
                              style: const TextStyle(
                                color: Color(0xFF1E1E2C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmer(width: 100, height: 24),
              _buildShimmer(width: 100, height: 32, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 24),
          _buildShimmer(width: double.infinity, height: 240, borderRadius: 20),
          const SizedBox(height: 32),
          _buildShimmer(width: 120, height: 24),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  _buildShimmer(width: 50, height: 50, borderRadius: 12),
                  const SizedBox(width: 16),
                  Expanded(child: _buildShimmer(width: double.infinity, height: 16)),
                  const SizedBox(width: 16),
                  _buildShimmer(width: 30, height: 20),
                ],
              );
            },
          ),
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
