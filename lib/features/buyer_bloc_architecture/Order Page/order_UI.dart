import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import 'order_view_model.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_cart_repository.dart';
import '../Cart Page/cart_models.dart';
import 'package:intl/intl.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';
import '../Rating_page/Rating_page_ui.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

class OrderPageUI extends StatelessWidget {
  final IOrderRepository? orderRepository;
  final OrderBloc? orderBloc;
  final IAuthService? authService;
  final ICartRepository? cartRepository;
  final VoidCallback? onNavigateToCart;
  final VoidCallback? onNavigateToHome;

  const OrderPageUI({
    super.key,
    this.orderRepository,
    this.orderBloc,
    this.authService,
    this.cartRepository,
    this.onNavigateToCart,
    this.onNavigateToHome,
  });

  @override
  Widget build(BuildContext context) {
    if (orderBloc != null) {
      return BlocProvider.value(
        value: orderBloc!,
        child: _OrderPageContent(
          onNavigateToCart: onNavigateToCart,
          onNavigateToHome: onNavigateToHome,
        ),
      );
    }

    return BlocProvider(
      create: (_) => OrderBloc(
        repository: orderRepository ?? context.read<IOrderRepository>(),
        authService: authService ?? context.read<IAuthService>(),
        cartRepository: cartRepository,
      )..add(const LoadOrdersRequested()),
      child: _OrderPageContent(
        onNavigateToCart: onNavigateToCart,
        onNavigateToHome: onNavigateToHome,
      ),
    );
  }
}

class _OrderPageContent extends StatefulWidget {
  final VoidCallback? onNavigateToCart;
  final VoidCallback? onNavigateToHome;

  const _OrderPageContent({
    this.onNavigateToCart,
    this.onNavigateToHome,
  });

  @override
  State<_OrderPageContent> createState() => _OrderPageContentState();
}

class _OrderPageContentState extends State<_OrderPageContent> {
  String _selectedTab = 'All';
  OrderViewModel? _selectedOrder; // For Desktop Master-Detail view

  final List<String> _tabs = ['All', 'Ongoing', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          if (state.actionSuccessMessage != null && state.actionSuccessMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.actionSuccessMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF15803D),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                action: widget.onNavigateToCart != null
                    ? SnackBarAction(
                        label: 'VIEW CART',
                        textColor: Colors.white,
                        onPressed: widget.onNavigateToCart!,
                      )
                    : null,
              ),
            );
            context.read<OrderBloc>().add(const ClearOrderMessage());
          } else if (state.actionErrorMessage != null && state.actionErrorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.actionErrorMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: BuyerAppColors.primaryDeep,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.read<OrderBloc>().add(const ClearOrderMessage());
          }
        } else if (state is ReorderSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF15803D),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              action: widget.onNavigateToCart != null
                  ? SnackBarAction(
                      label: 'VIEW CART',
                      textColor: Colors.white,
                      onPressed: widget.onNavigateToCart!,
                    )
                  : null,
            ),
          );
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFBF5F5), // App background color
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildDesktopLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildHeader(),
        const SizedBox(height: 20),
        _buildTabs(),
        const SizedBox(height: 16),
        Expanded(child: _buildOrdersList(isDesktop: false)),
      ],
    );
  }

  // ── Desktop Layout (Master-Detail) ─────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master View (List of Orders)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTabs(),
              const SizedBox(height: 16),
              Expanded(child: _buildOrdersList(isDesktop: true)),
            ],
          ),
        ),
        // Detail View (Track Order Component)
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: _selectedOrder == null
                ? const Center(
                    child: Text(
                      'Select an order to view live details',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                : TrackOrderPageUI(
                    key: ValueKey(_selectedOrder!.id),
                    orderId: _selectedOrder!.id,
                    order: _selectedOrder,
                    isEmbedded: true, // Hide app bar inside TrackOrderPageUI
                  ),
          ),
        ),
      ],
    );
  }

  // ── Shared UI Components ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            tooltip: 'Refresh orders',
            icon: const Icon(Icons.refresh_rounded, color: BuyerAppColors.primaryDeep),
            onPressed: () {
              context.read<OrderBloc>().add(const LoadOrdersRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        int allCount = 0;
        int ongoingCount = 0;
        int completedCount = 0;
        int cancelledCount = 0;

        if (state is OrderLoaded) {
          allCount = state.orders.length;
          ongoingCount = state.orders.where((o) => o.isOngoing).length;
          completedCount = state.orders.where((o) => o.isDelivered).length;
          cancelledCount = state.orders.where((o) => o.isCancelled).length;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = _selectedTab == tab;

              int count = allCount;
              if (tab == 'Ongoing') count = ongoingCount;
              if (tab == 'Completed') count = completedCount;
              if (tab == 'Cancelled') count = cancelledCount;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = tab;
                    _selectedOrder = null; // Reset selection on tab change
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? BuyerAppColors.primaryDeep : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: BuyerAppColors.primaryDeep.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList({required bool isDesktop}) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is OrderInitial || state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(color: BuyerAppColors.primaryDeep),
          );
        } else if (state is OrderError) {
          return EmptyStateView(
            icon: Icons.error_outline_rounded,
            iconColor: BuyerAppColors.primaryDeep,
            title: 'Error: ${state.message}',
            action: ElevatedButton(
              onPressed: () {
                context.read<OrderBloc>().add(const LoadOrdersRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyerAppColors.primaryDeep,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          );
        } else if (state is OrderLoaded) {
          List<OrderViewModel> orders = state.orders;

          // Filter orders based on tab
          if (_selectedTab == 'Ongoing') {
            orders = orders.where((o) => o.isOngoing).toList();
          } else if (_selectedTab == 'Completed') {
            orders = orders.where((o) => o.isDelivered).toList();
          } else if (_selectedTab == 'Cancelled') {
            orders = orders.where((o) => o.isCancelled).toList();
          }

          if (orders.isEmpty) {
            return _buildEmptyState(_selectedTab);
          }

          // Auto-select first order on desktop if none selected
          if (isDesktop && _selectedOrder == null && orders.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedOrder = orders.first;
                });
              }
            });
          }

          return RefreshIndicator(
            color: BuyerAppColors.primaryDeep,
            onRefresh: () async {
              context.read<OrderBloc>().add(const LoadOrdersRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              itemCount: orders.length,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemBuilder: (context, index) {
                return _buildOrderCard(
                  context,
                  orders[index],
                  isDesktop: isDesktop,
                  isActionLoading: state.isActionLoading,
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(String currentTab) {
    String title = 'Your order list is empty';
    String subtitle = 'Looks like you haven\'t placed any orders yet.';

    if (currentTab == 'Ongoing') {
      title = 'No ongoing orders';
      subtitle = 'You have no orders currently being prepared or delivered.';
    } else if (currentTab == 'Completed') {
      title = 'No past orders';
      subtitle = 'Your delivered orders will appear here.';
    } else if (currentTab == 'Cancelled') {
      title = 'No cancelled orders';
      subtitle = 'You have no cancelled or rejected orders.';
    }

    return EmptyStateView(
      icon: Icons.receipt_long_outlined,
      iconContainerColor: BuyerAppColors.primary.withValues(alpha: 0.08),
      iconContainerSize: 110,
      iconColor: BuyerAppColors.primary.withValues(alpha: 0.6),
      iconSize: 52,
      title: title,
      subtitle: subtitle,
      action: widget.onNavigateToHome != null
          ? ElevatedButton.icon(
              onPressed: widget.onNavigateToHome!,
              icon: const Icon(Icons.restaurant_menu, size: 18),
              label: const Text('Explore Food'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyerAppColors.primaryDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            )
          : null,
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderViewModel order, {
    required bool isDesktop,
    required bool isActionLoading,
  }) {
    // Determine status UI properties
    Color statusTextColor;
    Color statusBgColor;
    Color statusBorderColor;
    String statusText;

    if (order.isDelivered) {
      statusTextColor = const Color(0xFF15803D);
      statusBgColor = const Color(0xFFF0FDF4);
      statusBorderColor = const Color(0xFFBBF7D0);
      statusText = 'Delivered';
    } else if (order.isCancelled) {
      statusTextColor = const Color(0xFFB91C1C);
      statusBgColor = const Color(0xFFFEF2F2);
      statusBorderColor = const Color(0xFFFECACA);
      statusText = order.status;
    } else {
      statusTextColor = BuyerAppColors.primaryDeep;
      statusBgColor = const Color(0xFFFFF0F0);
      statusBorderColor = const Color(0xFFFECDD3);
      statusText = order.status == 'New' ? 'Placed' : order.status;
    }

    final isSelected = isDesktop && _selectedOrder?.id == order.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrder = order;
        });

        if (!isDesktop) {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TrackOrderPageUI(orderId: order.id, order: order),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var slideAnimation = animation.drive(tween);
                var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: curve),
                );

                return FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: BuyerAppColors.primaryDeep, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isDesktop) ...[
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? BuyerAppColors.primaryDeep
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            color: isSelected ? BuyerAppColors.primaryDeep : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.circle, size: 8, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        'Order #${order.shortId}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.formattedDate,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 8),

            // Item rows
            ...order.items
                .take(2)
                .map((item) => _buildOrderItemRow(context, item, order.id)),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '+ ${order.items.length - 2} more items',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            // Badges & Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentBadge(order.paymentMethod, order.paymentStatus),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusBorderColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
            const SizedBox(height: 10),

            // Interactive Bottom Actions (Reorder / Track / Cancel)
            Row(
              children: [
                if (order.isDelivered || order.isCancelled) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isActionLoading
                          ? null
                          : () {
                              context.read<OrderBloc>().add(ReorderRequested(order));
                            },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: BuyerAppColors.primaryDeep),
                      label: const Text(
                        'Reorder',
                        style: TextStyle(
                          color: BuyerAppColors.primaryDeep,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BuyerAppColors.primaryDeep, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (order.isOngoing) ...[
                  if (order.canCancel) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isActionLoading
                            ? null
                            : () {
                                _showCancelConfirmationDialog(context, order.id);
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: order.canCancel ? 2 : 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!isDesktop) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackOrderPageUI(orderId: order.id, order: order),
                            ),
                          );
                        } else {
                          setState(() {
                            _selectedOrder = order;
                          });
                        }
                      },
                      icon: const Icon(Icons.location_on_outlined, size: 16),
                      label: const Text(
                        'Track Order',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BuyerAppColors.primaryDeep,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
                if (order.isDelivered) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingPageUI(
                              orderId: order.id,
                              foodId: order.items.isNotEmpty ? order.items.first.id : (order.sellerId.isNotEmpty ? order.sellerId : 'Food'),
                              foodName: order.items.isNotEmpty ? order.items.first.name : (order.sellerName ?? 'Food Order'),
                              partnerId: order.riderId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_rate_rounded, size: 16, color: Color(0xFFF59E0B)),
                      label: const Text(
                        'Rate Order',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        if (!isDesktop) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackOrderPageUI(orderId: order.id, order: order),
                            ),
                          );
                        } else {
                          setState(() {
                            _selectedOrder = order;
                          });
                        }
                      },
                      icon: const Icon(Icons.receipt_outlined, size: 16, color: Colors.black54),
                      label: const Text(
                        'Receipt',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, String orderId) {
    String selectedReason = 'Placed by mistake';
    final List<String> reasons = [
      'Placed by mistake',
      'Delivery time is too long',
      'Need to change items',
      'Changed my mind',
      'Other reason',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please select a reason for cancelling this order:',
                    style: TextStyle(fontSize: 13.5, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((reason) {
                    final isChecked = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isChecked ? BuyerAppColors.primaryDeep : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                color: isChecked ? const Color(0xFF1C1C1C) : Colors.black87,
                                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Keep Order'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            this.context.read<OrderBloc>().add(
                                  CancelOrderRequested(orderId, reason: selectedReason),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BuyerAppColors.primaryDeep,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm Cancel',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentBadge(String method, String paymentStatus) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    final isPaid = paymentStatus.toLowerCase() == 'paid';

    if (method.toUpperCase() == 'RAZORPAY') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      icon = Icons.credit_card_rounded;
      label = isPaid ? 'Paid Online' : 'Razorpay ($paymentStatus)';
    } else if (method.toUpperCase() == 'WALLET') {
      bg = const Color(0xFFFAF5FF);
      fg = const Color(0xFF7E22CE);
      icon = Icons.account_balance_wallet_outlined;
      label = isPaid ? 'Paid via Wallet' : 'Wallet ($paymentStatus)';
    } else {
      bg = isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB);
      fg = isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309);
      icon = Icons.payments_outlined;
      label = isPaid ? 'COD (Paid)' : 'Cash on Delivery';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(
    BuildContext context,
    CartItem item,
    String orderId,
  ) {
    final imageUrl =
        item.image ??
        'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';
    final heroTag = 'order_${orderId}_item_${item.id}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showImagePreview(context, imageUrl, heroTag),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedAddons.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.selectedAddons.join(', '),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
