import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'seller_dashboard_page_bloc.dart';
import 'seller_dashboard_page_event.dart';
import 'seller_dashboard_page_state.dart';
import 'seller_dashboard_repository.dart';
import '../seller_NavigationBarView_page/seller_NavigationBarView_page_bloc.dart';
import '../seller_NavigationBarView_page/seller_NavigationBarView_page_event.dart';
import '../orders_list/orders_list_page_bloc.dart';
import '../orders_list/orders_list_page_event.dart';
import '../orders_list/orders_list_page_ui.dart';

import '../seller_app_bar_page/seller_app_bar_page_ui.dart';
import '../seller_analytics_page/seller_analytics_page__ui.dart';
import '../inventory_low_stock/inventory_low_stock_page_ui.dart';
import '../seller_analytics_page/seller_analytics_page__bloc.dart';
import '../seller_analytics_page/seller_analytics_repository.dart';
import '../product_list_page_/product_list_page__ui.dart';
import '../seller_payment_page/seller_payment_page_ui.dart';
import '../seller_notifications/seller_notification_ui.dart';
import '../../../core/widgets/hoverable_widgets.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../../core/services/notification_service.dart';

class SellerDashboardPageUI extends StatefulWidget {
  final SellerDashboardRepository? repository;
  final SellerDashboardPageBloc? bloc;

  const SellerDashboardPageUI({
    Key? key,
    this.repository,
    this.bloc,
  }) : super(key: key);

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
    try {
      NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService initialization note: $e');
    }
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

  SellerDashboardPageBloc? _tryGetBloc(BuildContext context) {
    try {
      return BlocProvider.of<SellerDashboardPageBloc>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc != null) {
      return BlocProvider<SellerDashboardPageBloc>.value(
        value: widget.bloc!,
        child: _buildScaffold(context),
      );
    }

    final existingBloc = _tryGetBloc(context);
    if (existingBloc != null) {
      return _buildScaffold(context);
    }

    SellerDashboardRepository repo;
    if (widget.repository != null) {
      repo = widget.repository!;
    } else {
      try {
        repo = context.read<SellerDashboardRepository>();
      } catch (_) {
        repo = FirebaseSellerDashboardRepository();
      }
    }

    return BlocProvider<SellerDashboardPageBloc>(
      create: (context) => SellerDashboardPageBloc(
        repository: repo,
      )..add(LoadDashboardData()),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _ResponsiveContainer(
        child: SafeArea(
          child:
              BlocConsumer<SellerDashboardPageBloc, SellerDashboardPageState>(
                listener: (context, state) {
                  if (state is SellerDashboardLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _animationController.forward();
                      }
                    });
                  } else if (state is SellerDashboardError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is SellerDashboardLoading ||
                      state is SellerDashboardInitial) {
                    return _buildDashboardSkeleton();
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
                      title: 'Good Morning, ${data.storeName} 👋',
                      notificationCount: data.newOrdersCount,
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SellerNotificationPageUI(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats: Active Products
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.inventory, color: Color(0xFF10B981), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Products',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data.activeProductsCount}',
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductListPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                              foregroundColor: const Color(0xFF374151),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Manage'),
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
                                  onTap: () {},
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
                                  title: 'Revenue Today',
                                  value: NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(data.revenueToday),
                                  icon: Icons.account_balance_wallet_outlined,
                                  iconColor: const Color(0xFF10B981),
                                  bgColor: const Color(0xFFECFDF5),
                                  subtitle: 'Earned today',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SellerPaymentPage(),
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
                                    onTap: () {},
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
                                    title: 'Revenue Today',
                                    value: NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(data.revenueToday),
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconColor: const Color(0xFF10B981),
                                    bgColor: const Color(0xFFECFDF5),
                                    subtitle: 'Earned today',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SellerPaymentPage(),
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
                              "No orders today",
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
    return HoverableCard(
      onTap: onTap,
      hoverScale: 1.02,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        child: Container(
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

    return HoverableCard(
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                        RealtimeOrderCustomerNameText(
                          fallbackName: order.customerName,
                          customerId: order.customerId,
                          orderId: order.fullOrderId ?? order.id.replaceAll('#', ''),
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
                        RealtimeOrderCustomerNameText(
                          fallbackName: order.customerName,
                          customerId: order.customerId,
                          orderId: order.fullOrderId ?? order.id.replaceAll('#', ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
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
      ),
    );
  }

  Widget _buildDashboardSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 200, height: 24),
                const SkeletonBox(width: 32, height: 32, borderRadius: 32),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonBox(width: double.infinity, height: 120),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
                SizedBox(width: 16),
                Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
                SizedBox(width: 16),
                Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
              ],
            ),
            const SizedBox(height: 32),
            const SkeletonBox(width: 150, height: 24),
            const SizedBox(height: 16),
            const SkeletonBox(width: double.infinity, height: 80),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 80),
          ],
        ),
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



