import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_dashboard_page_bloc.dart';
import 'seller_dashboard_page_event.dart';
import 'seller_dashboard_page_state.dart';

import '../seller_app_bar_page/seller_app_bar_page_ui.dart';
import '../new_order_notification/new_order_notification_ui.dart';
import '../seller_analytics_page/seller_analytics_page__ui.dart';
import '../overall_rating_page/overall_rating_page__ui.dart';
import '../seller_customer_page/seller_customer_page__ui.dart';
import '../inventory_low_stock/inventory_low_stock_page_ui.dart';
import '../seller_analytics_page/seller_analytics_page__bloc.dart';
import '../seller_analytics_page/seller_analytics_repository.dart';
import '../overall_rating_page/overall_rating_page__bloc.dart';

class SellerDashboardPageUI extends StatefulWidget {
  const SellerDashboardPageUI({Key? key}) : super(key: key);

  @override
  State<SellerDashboardPageUI> createState() => _SellerDashboardPageUIState();
}

class _SellerDashboardPageUIState extends State<SellerDashboardPageUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerDashboardPageBloc()..add(LoadDashboardData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: _ResponsiveContainer(
          child: SafeArea(
            child:
                BlocConsumer<SellerDashboardPageBloc, SellerDashboardPageState>(
                  listener: (context, state) {
                    if (state is SellerDashboardLoaded) {
                      _animationController.forward();
                    } else if (state is SellerDashboardError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    if (state is SellerDashboardLoading ||
                        state is SellerDashboardInitial) {
                      return const _DashboardSkeletonLoader();
                    } else if (state is SellerDashboardLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<SellerDashboardPageBloc>().add(
                            RefreshDashboardData(),
                          );
                        },
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildDashboardContent(context, state.data),
                          ),
                        ),
                      );
                    } else if (state is SellerDashboardError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SellerDashboardPageBloc>().add(
                                  LoadDashboardData(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isDesktop = screenWidth >= 1024;
        final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
        final double horizontalPadding = isDesktop
            ? 32.0
            : (isTablet ? 24.0 : 16.0);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    SellerAppBarPageUI(
                      title: 'Good Morning, Picarhub 👋',
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NewOrderNotificationPage(orderId: '1025'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Total Revenue Card
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE52929), Color(0xFFD61F1F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE52929,
                            ).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Revenue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${data.totalRevenue.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+ ${data.revenueChangePercentage}% vs yesterday',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Mocking the trend line graph
                          Positioned(
                            right: 0,
                            top: 20,
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  width: double.infinity,
                                  title: 'Pending Orders',
                                  value: data.pendingOrdersCount.toString(),
                                  icon: Icons.pending_actions,
                                  iconColor: const Color(0xFFF59E0B),
                                  bgColor: const Color(0xFFFFFBEB),
                                  subtitle: 'Awaiting processing',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SellerCustomerPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  width: double.infinity,
                                  title: 'Today\'s Orders',
                                  value: data.todaysOrdersCount.toString(),
                                  icon: Icons.shopping_bag_outlined,
                                  iconColor: const Color(0xFF3B82F6),
                                  bgColor: const Color(0xFFEFF6FF),
                                  subtitle: 'Total for today',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (context) =>
                                              SellerAnalyticsBloc(
                                                repository:
                                                    SellerAnalyticsRepository(),
                                              ),
                                          child: const SellerAnalyticsPageUI(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  width: double.infinity,
                                  title: 'Low Stock',
                                  value: data.lowStockCount.toString(),
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: const Color(0xFFEF4444),
                                  bgColor: const Color(0xFFFEF2F2),
                                  subtitle: 'Needs restock',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InventoryLowStockPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  width: double.infinity,
                                  title: 'Rating',
                                  value: '${data.rating}',
                                  icon: Icons.star_border,
                                  iconColor: const Color(0xFF8B5CF6),
                                  bgColor: const Color(0xFFF5F3FF),
                                  subtitle: 'From customers',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (context) => OverallRatingBloc(
                                            repository:
                                                OverallRatingRepositoryImpl(
                                                  MockOverallRatingService(),
                                                ),
                                          ),
                                          child: const OverallRatingPage(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildStatCard(
                                    width: constraints.maxWidth / 2 - 8,
                                    title: 'Pending Orders',
                                    value: data.pendingOrdersCount.toString(),
                                    icon: Icons.pending_actions,
                                    iconColor: const Color(0xFFF59E0B),
                                    bgColor: const Color(0xFFFFFBEB),
                                    subtitle: 'Awaiting',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SellerCustomerPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildStatCard(
                                    width: constraints.maxWidth / 2 - 8,
                                    title: 'Today\'s Orders',
                                    value: data.todaysOrdersCount.toString(),
                                    icon: Icons.shopping_bag_outlined,
                                    iconColor: const Color(0xFF3B82F6),
                                    bgColor: const Color(0xFFEFF6FF),
                                    subtitle: 'Total today',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) =>
                                                SellerAnalyticsBloc(
                                                  repository:
                                                      SellerAnalyticsRepository(),
                                                ),
                                            child:
                                                const SellerAnalyticsPageUI(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildStatCard(
                                    width: constraints.maxWidth / 2 - 8,
                                    title: 'Low Stock',
                                    value: data.lowStockCount.toString(),
                                    icon: Icons.inventory_2_outlined,
                                    iconColor: const Color(0xFFEF4444),
                                    bgColor: const Color(0xFFFEF2F2),
                                    subtitle: 'Restock',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InventoryLowStockPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildStatCard(
                                    width: constraints.maxWidth / 2 - 8,
                                    title: 'Rating',
                                    value: '${data.rating}',
                                    icon: Icons.star_border,
                                    iconColor: const Color(0xFF8B5CF6),
                                    bgColor: const Color(0xFFF5F3FF),
                                    subtitle: 'Customers',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) => OverallRatingBloc(
                                              repository:
                                                  OverallRatingRepositoryImpl(
                                                    MockOverallRatingService(),
                                                  ),
                                            ),
                                            child: const OverallRatingPage(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    // Today's Orders Title
                    const Text(
                      'Today\'s Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Order Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Amount / Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Orders List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: data.todaysOrders.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "இன்றைய ஆடர்கள் இல்லை", // "No orders today" in Tamil as requested
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Your new orders will appear here.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final order = data.todaysOrders[index];
                        return _buildOrderItem(order, isDesktop);
                      }, childCount: data.todaysOrders.length),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(DashboardOrder order, [bool isDesktop = false]) {
    Color statusColor;
    Color statusBgColor;

    if (order.status == 'New') {
      statusColor = const Color(0xFF3B82F6);
      statusBgColor = const Color(0xFFEFF6FF);
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBgColor = const Color(0xFFFFFBEB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.price.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${order.price.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _DashboardSkeletonLoader extends StatelessWidget {
  const _DashboardSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics:
          const NeverScrollableScrollPhysics(), // Prevent user scrolling while loading if desired, or allow it
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSkeletonBox(width: 200, height: 24),
                _buildSkeletonBox(
                  width: 32,
                  height: 32,
                  shape: BoxShape.circle,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSkeletonBox(width: double.infinity, height: 120),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSkeletonBox(width: double.infinity, height: 100),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSkeletonBox(width: double.infinity, height: 100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSkeletonBox(width: double.infinity, height: 100),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSkeletonBox(width: double.infinity, height: 100),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSkeletonBox(width: 150, height: 24),
            const SizedBox(height: 16),
            _buildSkeletonBox(width: double.infinity, height: 80),
            const SizedBox(height: 12),
            _buildSkeletonBox(width: double.infinity, height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(12)
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const _ResponsiveContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}
