import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import 'order_view_model.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../Cart Page/cart_models.dart';
import 'package:intl/intl.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';

class OrderPageUI extends StatelessWidget {
  final IOrderRepository? orderRepository;
  final OrderBloc? orderBloc;
  final IAuthService? authService;

  const OrderPageUI({super.key, this.orderRepository, this.orderBloc, this.authService});

  @override
  Widget build(BuildContext context) {
    if (orderBloc != null) {
      return BlocProvider.value(
        value: orderBloc!,
        child: const _OrderPageContent(),
      );
    }

    return BlocProvider(
      create: (_) =>
          OrderBloc(
            repository: orderRepository ?? context.read<IOrderRepository>(),
            authService: authService ?? context.read<IAuthService>(),
          )..add(LoadOrdersRequested()),
      child: const _OrderPageContent(),
    );
  }
}

class _OrderPageContent extends StatefulWidget {
  const _OrderPageContent();

  @override
  State<_OrderPageContent> createState() => _OrderPageContentState();
}

class _OrderPageContentState extends State<_OrderPageContent> {
  String _selectedTab = 'All';
  OrderViewModel? _selectedOrder; // For Desktop Master-Detail view

  final List<String> _tabs = ['All', 'Ongoing', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
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
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTabs(),
        const SizedBox(height: 20),
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
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 20),
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
                      'Select an order to view details',
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
        children: [
          const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tab;
                _selectedOrder = null; // Reset selection on tab change
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE52121)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersList({required bool isDesktop}) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderInitial || state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE52121)),
          );
        } else if (state is OrderError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is OrderLoaded) {
          List<OrderViewModel> orders = state.orders;

          // Filter orders based on tab
          if (_selectedTab == 'Ongoing') {
            orders = orders
                .where(
                  (o) => o.status != 'Delivered' && o.status != 'Cancelled',
                )
                .toList();
          } else if (_selectedTab == 'Completed') {
            orders = orders.where((o) => o.status == 'Delivered').toList();
          } else if (_selectedTab == 'Cancelled') {
            orders = orders.where((o) => o.status == 'Cancelled').toList();
          }

          if (orders.isEmpty) {
            return _buildEmptyState();
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: orders.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildOrderCard(
                context,
                orders[index],
                isDesktop: isDesktop,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEF2A39).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: const Color(0xFFEF2A39).withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your order list is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderViewModel order, {
    required bool isDesktop,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    // Determine status UI properties
    Color statusTextColor;
    Color statusBgColor;
    Color statusBorderColor;
    String statusText;

    if (order.status.toLowerCase() == 'delivered') {
      statusTextColor = const Color(0xFF4CAF50);
      statusBgColor = const Color(0xFF4CAF50).withValues(alpha: 0.05);
      statusBorderColor = const Color(0xFF4CAF50).withValues(alpha: 0.2);
      statusText = 'Delivered';
    } else if (order.status.toLowerCase() == 'cancelled') {
      statusTextColor = const Color(0xFFE52121);
      statusBgColor = const Color(0xFFE52121).withValues(alpha: 0.05);
      statusBorderColor = const Color(0xFFE52121).withValues(alpha: 0.2);
      statusText = 'Cancelled';
    } else {
      statusTextColor = const Color(0xFFE52121);
      statusBgColor = const Color(0xFFE52121).withValues(alpha: 0.05);
      statusBorderColor = const Color(0xFFE52121).withValues(alpha: 0.2);
      statusText = 'Track Order';
    }

    final isSelected = isDesktop && _selectedOrder?.id == order.id;

    return GestureDetector(
      onTap: () {
        // Always set the selected order so that if the window is resized to desktop,
        // the master-detail view will have the correct order selected.
        setState(() {
          _selectedOrder = order;
        });

        if (!isDesktop) {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TrackOrderPageUI(orderId: order.id, order: order),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var slideAnimation = animation.drive(tween);

                    var fadeAnimation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(parent: animation, curve: curve));

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
              ? Border.all(color: const Color(0xFFE52121), width: 1.5)
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
                                  ? const Color(0xFFE52121)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            color: isSelected
                                ? const Color(0xFFE52121)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        'Order #${(order.id.length <= 8 ? order.id : order.id.substring(0, 8)).toUpperCase()}',
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
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(order.date),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 8),
            ...order.items
                .take(2)
                .map((item) => _buildOrderItemRow(context, item, order.id))
                .toList(),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '+ ${order.items.length - 2} more items',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusBorderColor, width: 1),
                ),
                child: Text(
                  isDesktop
                      ? (order.status.toLowerCase() == 'delivered'
                            ? 'Delivered'
                            : (order.status.toLowerCase() == 'cancelled'
                                  ? 'Cancelled'
                                  : 'Tracking'))
                      : statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showImagePreview(context, imageUrl, heroTag),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                      size: 32,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
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
