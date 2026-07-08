import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'seller_analytics_page__bloc.dart';
import 'seller_analytics_page__event.dart';
import 'seller_analytics_page__state.dart';

class SellerAnalyticsPageUI extends StatelessWidget {
  const SellerAnalyticsPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
  final dynamic data; // Replace with proper type if imported properly
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Analytics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1E2C),
                            ),
                      ),
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
                          // Custom Bar Chart
                          SizedBox(
                            height: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(data.weeklyChartData.length, (index) {
                                final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                final height = data.weeklyChartData[index] as double;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: height),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 20,
                                          height: value,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5D35DB),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      labels[index],
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
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
