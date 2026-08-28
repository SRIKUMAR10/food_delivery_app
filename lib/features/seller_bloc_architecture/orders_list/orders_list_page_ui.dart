import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/delivery_partner_model.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/filter_chips_bar.dart';
import 'orders_list_page_bloc.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import '../../../../core/repositories/i_order_repository.dart';
import '../../../../core/repositories/i_chat_repository.dart';
import '../assign_delivery_page_/assign_delivery_page__ui.dart';
import '../assign_delivery_page_/assign_delivery_page__bloc.dart';
import '../assign_delivery_page_/assign_delivery_page__repository.dart';
import '../assign_delivery_page_/assign_delivery_page__service.dart';
import '../assign_delivery_page_/assign_delivery_page__event.dart';
import '../out_for_delivery_page_/out_for_delivery_page__ui.dart';
import '../chat_support_page_/chat_support_page_ui.dart';
import '../seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (context) => OrdersListBloc(
        repository: context.read<IOrderRepository>(),
        chatRepository: context.read<IChatRepository>(),
      )..add(LoadOrdersStream(sellerId)),
      child: const OrdersListView(),
    );
  }
}

class OrdersListView extends StatelessWidget {
  const OrdersListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<OrdersListBloc, OrdersListState>(
        listener: (context, state) {
          if (state is OrdersListLoaded) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.errorMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFE52929),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              context.read<OrdersListBloc>().add(ClearMessages());
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.successMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              context.read<OrdersListBloc>().add(ClearMessages());
            }
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double containerWidth = constraints.maxWidth;
              if (constraints.maxWidth > 1200) {
                containerWidth = 1100;
              } else if (constraints.maxWidth > 800) {
                containerWidth = 850;
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: containerWidth),
                  child: RefreshIndicator(
                    color: const Color(0xFFE52929),
                    onRefresh: () async {
                      final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      context.read<OrdersListBloc>().add(LoadOrdersStream(sellerId));
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (Navigator.canPop(context)) ...[
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => Navigator.of(context).pop(),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.arrow_back_ios_new_rounded,
                                                color: Color(0xFF1E293B),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ] else if (SellerDrawerProvider.of(context) != null) ...[
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: SellerDrawerProvider.of(context),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.menu_rounded,
                                                color: Color(0xFF1E293B),
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Order Management',
                                              style: TextStyle(
                                                fontSize: constraints.maxWidth < 600 ? 22 : 26,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0F172A),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            BlocBuilder<OrdersListBloc, OrdersListState>(
                                              builder: (context, state) {
                                                if (state is OrdersListLoaded) {
                                                  final total = state.allOrders.length;
                                                  final pending = state.getCount('New');
                                                  return Text(
                                                    '$total Orders total · $pending New orders pending',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  );
                                                }
                                                return const Text(
                                                  'Real-time order updates',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFBBF7D0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 4,
                                        backgroundColor: Color(0xFF16A34A),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Live Stream',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Search Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  context.read<OrdersListBloc>().add(SearchOrders(value));
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search by Order ID, Customer, Phone, or Items...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Horizontal Segmented Status Filter Bar
                        SliverToBoxAdapter(
                          child: BlocBuilder<OrdersListBloc, OrdersListState>(
                            builder: (context, state) {
                              if (state is OrdersListLoaded) {
                                final selected = state.activeFilter == 'Placed'
                                    ? 'New'
                                    : state.activeFilter;
                                return FilterChipsBar(
                                  items: const [
                                    FilterChipItem(label: 'All', value: 'All'),
                                    FilterChipItem(label: 'Placed (New)', value: 'New'),
                                    FilterChipItem(label: 'Accepted', value: 'Accepted'),
                                    FilterChipItem(label: 'Preparing', value: 'Preparing'),
                                    FilterChipItem(label: 'Ready for Pickup', value: 'Ready'),
                                    FilterChipItem(label: 'Picked Up', value: 'PickedUp'),
                                    FilterChipItem(label: 'Out for Delivery', value: 'OutForDelivery'),
                                    FilterChipItem(label: 'Delivered', value: 'Delivered'),
                                    FilterChipItem(label: 'Cancelled / Rejected', value: 'Cancelled'),
                                  ],
                                  selected: selected,
                                  onSelected: (value) {
                                    context.read<OrdersListBloc>().add(FilterOrders(value));
                                  },
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: SkeletonBox(height: 44, borderRadius: 22),
                              );
                            },
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // Orders List Content
                        BlocBuilder<OrdersListBloc, OrdersListState>(
                          builder: (context, state) {
                            if (state is OrdersListLoading || state is OrdersListInitial) {
                              return SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: SkeletonBox(height: 200, borderRadius: 16),
                                    ),
                                    childCount: 4,
                                  ),
                                ),
                              );
                            } else if (state is OrdersListError) {
                              return SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        size: 48,
                                        color: Color(0xFFEF4444),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error: ${state.message}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                          context.read<OrdersListBloc>().add(LoadOrdersStream(uid));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE52929),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (state is OrdersListLoaded) {
                              if (state.filteredOrders.isEmpty) {
                                return SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: EmptyStateView(
                                    icon: Icons.inbox_rounded,
                                    title: 'No ${state.activeFilter} Orders',
                                    subtitle: 'New customer orders will appear here automatically in real time.',
                                  ),
                                );
                              }

                              final screenWidth = MediaQuery.of(context).size.width;
                              final isDesktop = screenWidth >= 1024;

                              return SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                sliver: isDesktop
                                    ? SliverGrid(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: 310,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                        ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return _OrderListCard(
                                              order: state.filteredOrders[index],
                                              index: index,
                                            );
                                          },
                                          childCount: state.filteredOrders.length,
                                        ),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: _OrderListCard(
                                                order: state.filteredOrders[index],
                                                index: index,
                                              ),
                                            );
                                          },
                                          childCount: state.filteredOrders.length,
                                        ),
                                      ),
                              );
                            }
                            return const SliverToBoxAdapter(child: SizedBox.shrink());
                          },
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderListCard extends StatefulWidget {
  final OrderModel order;
  final int index;
  const _OrderListCard({required this.order, required this.index});

  @override
  State<_OrderListCard> createState() => _OrderListCardState();
}

class _OrderListCardState extends State<_OrderListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersListBloc, OrdersListState>(
      builder: (context, state) {
        final isUpdating = state is OrdersListLoaded && state.updatingOrderIds.contains(widget.order.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scaleByVector3(Vector3(
              _isHovered ? 1.01 : 1.0,
              _isHovered ? 1.01 : 1.0,
              1.0,
            )),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? const Color(0xFFE52929).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: _isHovered ? 0.08 : 0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onHover: (val) => setState(() => _isHovered = val),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<OrdersListBloc>(),
                      child: OrderDetailsScreen(order: widget.order),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Order ID + Status Badge + Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#${widget.order.id}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildOrderStatusBadge(widget.order.status),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.order.amount),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Customer Details
                    RealtimeOrderCustomerDetails(
                      fallbackName: widget.order.customerName,
                      fallbackPhone: widget.order.customerPhone,
                      fallbackAddress: widget.order.deliveryAddress,
                      customerId: widget.order.customerId,
                      orderId: widget.order.id,
                      builder: (context, profile) {
                        final displayName = profile.name.isNotEmpty ? profile.name : widget.order.customerName;
                        final displayPhone = profile.phone.isNotEmpty ? profile.phone : (widget.order.customerPhone ?? '');
                        final displayAddress = profile.address.isNotEmpty ? profile.address : (widget.order.deliveryAddress ?? '');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    displayName.isNotEmpty ? displayName : 'Customer',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (displayPhone.isNotEmpty) ...[
                                  InkWell(
                                    onTap: () => _launchPhoneCall(displayPhone),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF2563EB)),
                                          const SizedBox(width: 4),
                                          Text(
                                            displayPhone,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (displayAddress.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      displayAddress,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Order Items Summary
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 15, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getItemSummary(widget.order),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Payment & Delivery Partner Tags
                    Row(
                      children: [
                        _PaymentMethodChip(order: widget.order),
                        const SizedBox(width: 8),
                        if (widget.order.riderId != null && widget.order.riderId!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delivery_dining_rounded, size: 13, color: Color(0xFF2563EB)),
                                SizedBox(width: 4),
                                Text(
                                  'Partner Assigned',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (widget.order.status == OrderStatus.ready)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Assign Partner Needed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          widget.order.timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),

                    // Quick Actions Row
                    _CardActionButtons(order: widget.order, isUpdating: isUpdating),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getItemSummary(OrderModel order) {
    final items = order.items;
    if (items == null || items.isEmpty) return 'No items recorded';
    final count = items.length;
    final firstItem = items.first.name;
    if (count == 1) return '1x $firstItem';
    return '${items[0].quantity}x $firstItem + ${count - 1} more item${count > 2 ? 's' : ''}';
  }
}

class _CardActionButtons extends StatelessWidget {
  final OrderModel order;
  final bool isUpdating;

  const _CardActionButtons({required this.order, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE52929)),
        ),
      );
    }

    switch (order.status) {
      case OrderStatus.newOrder:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectModal(context, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.accepted),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.preparing),
                      );
                },
                icon: const Icon(Icons.soup_kitchen_rounded, size: 14),
                label: const Text('Start Preparing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.preparing:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.ready),
                      );
                },
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Mark Ready for Pickup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.ready:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<OrdersListBloc>(),
                        child: BlocProvider(
                          create: (context) => AssignDeliveryBloc(
                            repository: AssignDeliveryRepository(service: AssignDeliveryService()),
                            orderId: order.id,
                          )..add(LoadRidersEvent(orderId: order.id)),
                          child: AssignDeliveryPage(orderId: order.id),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded, size: 14),
                label: const Text('Assign Delivery Partner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutForDeliveryPageUI(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded, size: 14),
                label: const Text('Track Live Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.delivered:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
            SizedBox(width: 6),
            Text(
              'Order Completed',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
            ),
          ],
        );

      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 16),
            const SizedBox(width: 6),
            Text(
              order.status == OrderStatus.rejected ? 'Order Rejected' : 'Order Cancelled',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
        );
    }
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final OrderModel order;
  const _PaymentMethodChip({required this.order});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String text;

    if (order.isCOD) {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
      text = 'COD';
    } else if (order.isRazorpay) {
      bg = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF2563EB);
      text = 'Razorpay (Paid)';
    } else if ((order.paymentMethod ?? '').toLowerCase() == 'wallet') {
      bg = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF16A34A);
      text = 'Wallet';
    } else {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF475569);
      text = order.paymentMethod ?? 'Paid';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

Widget _buildOrderStatusBadge(OrderStatus status) {
  Color color;
  IconData icon;

  switch (status) {
    case OrderStatus.newOrder:
      color = const Color(0xFF2563EB);
      icon = Icons.fiber_new_rounded;
      break;
    case OrderStatus.accepted:
      color = const Color(0xFF16A34A);
      icon = Icons.thumb_up_rounded;
      break;
    case OrderStatus.preparing:
      color = const Color(0xFFF97316);
      icon = Icons.soup_kitchen_rounded;
      break;
    case OrderStatus.ready:
      color = const Color(0xFFA16207);
      icon = Icons.checklist_rounded;
      break;
    case OrderStatus.pickedUp:
      color = const Color(0xFF7C3AED);
      icon = Icons.takeout_dining_rounded;
      break;
    case OrderStatus.outForDelivery:
      color = const Color(0xFF0369A1);
      icon = Icons.delivery_dining_rounded;
      break;
    case OrderStatus.delivered:
      color = const Color(0xFF15803D);
      icon = Icons.check_circle_rounded;
      break;
    case OrderStatus.rejected:
    case OrderStatus.cancelled:
      color = const Color(0xFFDC2626);
      icon = Icons.cancel_rounded;
      break;
  }

  return StatusBadge(label: status.displayName, color: color, icon: icon);
}

// -------------------------------------------------------------
// ORDER DETAILS SCREEN (COMPREHENSIVE VIEW)
// -------------------------------------------------------------
class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersListBloc, OrdersListState>(
      listener: (context, state) {
        if (state is OrdersListLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFE52929),
            ),
          );
        }
      },
      builder: (context, state) {
        OrderModel order = widget.order;
        bool isUpdating = false;
        if (state is OrdersListLoaded) {
          order = state.allOrders.firstWhere(
            (o) => o.id == widget.order.id,
            orElse: () => widget.order,
          );
          isUpdating = state.updatingOrderIds.contains(widget.order.id);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Order #${order.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildOrderStatusBadge(order.status),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 7-Stage Interactive Order Tracker Timeline
                            _Order7StageTimeline(order: order),
                            const SizedBox(height: 20),

                            // Customer Details Section
                            _CustomerDetailsCard(order: order),
                            const SizedBox(height: 20),

                            // Delivery Address Section
                            _DeliveryAddressCard(order: order),
                            const SizedBox(height: 20),

                            // Order Items Section
                            _OrderItemsCard(order: order),
                            const SizedBox(height: 20),

                            // Price Breakdown Section
                            _PriceBreakdownCard(order: order),
                            const SizedBox(height: 20),

                            // Payment Status Section
                            _PaymentStatusCard(order: order),
                            const SizedBox(height: 20),

                            // Delivery Partner Section
                            _DeliveryPartnerCard(order: order),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Sticky Bottom Action Bar
                    _OrderDetailsBottomBar(order: order, isUpdating: isUpdating),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 7-STAGE TIMELINE COMPONENT
// -------------------------------------------------------------
class _Order7StageTimeline extends StatelessWidget {
  final OrderModel order;
  const _Order7StageTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status.isCancelledOrRejected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: 8),
                Text(
                  order.status == OrderStatus.rejected ? 'Order Rejected' : 'Order Cancelled',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            if (order.cancellationReason != null && order.cancellationReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${order.cancellationReason}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final currentStep = order.status.stepIndex;

    final stages = [
      {'title': 'Placed', 'desc': 'Order received'},
      {'title': 'Accepted', 'desc': 'Store confirmed'},
      {'title': 'Preparing', 'desc': 'In the kitchen'},
      {'title': 'Ready for Pickup', 'desc': 'Food packed'},
      {'title': 'Picked Up', 'desc': 'Rider picked up'},
      {'title': 'Out for Delivery', 'desc': 'On the way'},
      {'title': 'Delivered', 'desc': 'Handed to buyer'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(stages.length, (index) {
              final isCompleted = index < currentStep;
              final isActive = index == currentStep;
              final isLast = index == stages.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF16A34A)
                                : isActive
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : isActive
                                    ? const Icon(Icons.circle, size: 8, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stages[index]['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
                                color: isActive
                                    ? const Color(0xFF2563EB)
                                    : isCompleted
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              stages[index]['desc']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// CUSTOMER DETAILS CARD
// -------------------------------------------------------------
class _CustomerDetailsCard extends StatelessWidget {
  final OrderModel order;
  const _CustomerDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RealtimeOrderCustomerDetails(
        fallbackName: order.customerName,
        fallbackPhone: order.customerPhone,
        fallbackAddress: order.deliveryAddress,
        customerId: order.customerId,
        orderId: order.id,
        builder: (context, profile) {
          final displayName = profile.name.isNotEmpty ? profile.name : order.customerName;
          final displayPhone = profile.phone.isNotEmpty ? profile.phone : (order.customerPhone ?? '');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_rounded, color: Color(0xFF3B82F6), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Customer Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : 'Customer',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (displayPhone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            displayPhone,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (displayPhone.isNotEmpty)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhoneCall(displayPhone),
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Call Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (displayPhone.isNotEmpty) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatSupportPage(
                              sellerId: sellerId,
                              initialOrderId: order.id,
                              targetRole: 'buyer',
                              partnerId: order.customerId,
                              partnerName: displayName,
                              partnerPhone: displayPhone,
                              orderTitle: order.items?.isNotEmpty == true
                                  ? order.items!.first.name
                                  : null,
                              orderTotal: order.amount,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Chat with Customer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// DELIVERY ADDRESS CARD
// -------------------------------------------------------------
class _DeliveryAddressCard extends StatelessWidget {
  final OrderModel order;
  const _DeliveryAddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RealtimeOrderCustomerDetails(
        fallbackName: order.customerName,
        fallbackPhone: order.customerPhone,
        fallbackAddress: order.deliveryAddress,
        customerId: order.customerId,
        orderId: order.id,
        builder: (context, profile) {
          final displayAddress = profile.address.isNotEmpty
              ? profile.address
              : (order.deliveryAddress ?? 'Address not specified');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                displayAddress,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: displayAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _openMaps(displayAddress),
                    icon: const Icon(Icons.map_rounded, size: 14),
                    label: const Text('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

// -------------------------------------------------------------
// ORDER ITEMS CARD
// -------------------------------------------------------------
class _OrderItemsCard extends StatelessWidget {
  final OrderModel order;
  const _OrderItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order.items ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.restaurant_rounded, color: Color(0xFF8B5CF6), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Order Items',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length} Item${items.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'No items recorded for this order.',
              style: TextStyle(color: Color(0xFF94A3B8)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
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
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (item.selectedAddons.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: item.selectedAddons.map((addon) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    '+ $addon',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(item.price * item.quantity),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PRICE BREAKDOWN CARD
// -------------------------------------------------------------
class _PriceBreakdownCard extends StatelessWidget {
  final OrderModel order;
  const _PriceBreakdownCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final subtotal = order.subtotal ?? order.amount;
    final deliveryFee = order.deliveryFee ?? 0.0;
    final taxAmount = order.taxAmount ?? 0.0;
    final discount = order.discountAmount ?? 0.0;
    final platformFee = order.platformFee ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Color(0xFF0D9488), size: 18),
              SizedBox(width: 8),
              Text(
                'Bill Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _billRow('Item Subtotal', subtotal),
          if (deliveryFee > 0) _billRow('Delivery Fee', deliveryFee),
          if (taxAmount > 0) _billRow('Taxes & GST', taxAmount),
          if (platformFee > 0) _billRow('Platform Fee', platformFee),
          if (discount > 0)
            _billRow('Discount', -discount, isDiscount: true, extraNote: order.couponCode),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(order.amount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE52929),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String title, double amount, {bool isDiscount = false, String? extraNote}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              if (extraNote != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($extraNote)',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          Text(
            '${isDiscount ? "-" : ""}${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount.abs())}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PAYMENT STATUS CARD
// -------------------------------------------------------------
class _PaymentStatusCard extends StatelessWidget {
  final OrderModel order;
  const _PaymentStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.payment_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Payment Status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              _PaymentMethodChip(order: order),
            ],
          ),
          const SizedBox(height: 12),
          if (order.isCOD) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Collect ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(order.codAmount ?? order.amount)} in cash upon delivery/handover.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (order.isRazorpay) ...[
            if (order.razorpayPaymentId != null) ...[
              Text(
                'Payment ID: ${order.razorpayPaymentId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
            if (order.razorpayOrderId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Razorpay Order ID: ${order.razorpayOrderId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ] else ...[
            Text(
              order.paymentDisplayString,
              style: const TextStyle(fontSize: 13, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// DELIVERY PARTNER CARD (REAL-TIME STREAM)
// -------------------------------------------------------------
class _DeliveryPartnerCard extends StatelessWidget {
  final OrderModel order;
  const _DeliveryPartnerCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final riderId = order.riderId;

    if (riderId == null || riderId.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.delivery_dining_rounded, color: Color(0xFF64748B), size: 18),
                SizedBox(width: 8),
                Text(
                  'Delivery Partner',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No delivery partner assigned yet.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ),
                  if (order.status == OrderStatus.ready || order.status == OrderStatus.preparing)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<OrdersListBloc>(),
                              child: BlocProvider(
                                create: (context) => AssignDeliveryBloc(
                                  repository: AssignDeliveryRepository(service: AssignDeliveryService()),
                                  orderId: order.id,
                                )..add(LoadRidersEvent(orderId: order.id)),
                                child: AssignDeliveryPage(orderId: order.id),
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52929),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Assign Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('delivery_partners').doc(riderId).snapshots(),
      builder: (context, snapshot) {
        DeliveryPartnerModel? partner;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          partner = DeliveryPartnerModel.fromFirestore(snapshot.data!);
        }

        final partnerName = partner?.displayName.isNotEmpty == true ? partner!.displayName : 'Delivery Partner';
        final partnerPhone = partner?.phoneNumber ?? '';
        final vehicle = partner?.vehicleNumber != null ? '${partner?.vehicleType ?? "Vehicle"} (${partner?.vehicleNumber})' : (partner?.vehicleType ?? 'Bike');
        final rating = partner?.rating != null && partner!.rating > 0 ? partner.rating.toStringAsFixed(1) : '5.0';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.delivery_dining_rounded, color: Color(0xFF2563EB), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Assigned Delivery Partner',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: Color(0xFF16A34A)),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.sports_motorsports_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partnerName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          vehicle,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (partnerPhone.isNotEmpty)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhoneCall(partnerPhone),
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Call Partner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (partnerPhone.isNotEmpty) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OutForDeliveryPageUI(orderId: order.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_searching_rounded, size: 16),
                      label: const Text('Live Tracking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatSupportPage(
                          sellerId: sellerId,
                          initialOrderId: order.id,
                          targetRole: 'delivery_partner',
                          partnerId: riderId,
                          partnerName: partnerName,
                          partnerPhone: partnerPhone,
                          orderTitle: order.items?.isNotEmpty == true
                              ? order.items!.first.name
                              : null,
                          orderTotal: order.amount,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Chat with Delivery Partner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// STICKY BOTTOM ACTION BAR (ORDER DETAILS)
// -------------------------------------------------------------
class _OrderDetailsBottomBar extends StatelessWidget {
  final OrderModel order;
  final bool isUpdating;

  const _OrderDetailsBottomBar({required this.order, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    if (order.status.isTerminal) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Center(
          child: Text(
            order.status == OrderStatus.delivered
                ? 'This order has been successfully completed.'
                : 'This order was cancelled / rejected.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: isUpdating
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52929)),
            )
          : _buildActionRow(context),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    switch (order.status) {
      case OrderStatus.newOrder:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectModal(context, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reject Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.accepted),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelModal(context, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.preparing),
                      );
                },
                icon: const Icon(Icons.soup_kitchen_rounded),
                label: const Text('Start Preparing', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.preparing:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrdersListBloc>().add(
                        UpdateOrderStatusEvent(order.id, OrderStatus.ready),
                      );
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Mark Ready for Pickup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.ready:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<OrdersListBloc>(),
                        child: BlocProvider(
                          create: (context) => AssignDeliveryBloc(
                            repository: AssignDeliveryRepository(service: AssignDeliveryService()),
                            orderId: order.id,
                          )..add(LoadRidersEvent(orderId: order.id)),
                          child: AssignDeliveryPage(orderId: order.id),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Assign Delivery Partner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );

      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutForDeliveryPageUI(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('Track Live Delivery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// -------------------------------------------------------------
// REJECTION AND CANCELLATION MODALS
// -------------------------------------------------------------
Future<void> _showRejectModal(BuildContext context, OrderModel order) async {
  final reasons = [
    'Items out of stock',
    'Kitchen too busy',
    'Store closing soon',
    'Unable to deliver to location',
    'Other reason',
  ];
  String selectedReason = reasons.first;
  final customController = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Order', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please select a reason for rejecting this order:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            ...reasons.map((r) => RadioListTile<String>(
                  title: Text(r, style: const TextStyle(fontSize: 14)),
                  value: r,
                  groupValue: selectedReason,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedReason = val);
                  },
                )),
            if (selectedReason == 'Other reason') ...[
              const SizedBox(height: 8),
              TextField(
                controller: customController,
                decoration: const InputDecoration(
                  hintText: 'Enter specific reason...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final finalReason = selectedReason == 'Other reason' && customController.text.trim().isNotEmpty
                  ? customController.text.trim()
                  : selectedReason;
              Navigator.pop(ctx, finalReason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    ),
  );

  if (result != null && context.mounted) {
    context.read<OrdersListBloc>().add(
          RejectOrderEvent(order.id, reason: result),
        );
  }
}

Future<void> _showCancelModal(BuildContext context, OrderModel order) async {
  final controller = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to cancel this order? Please provide a cancellation reason:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Customer requested cancellation / Kitchen equipment issue',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = controller.text.trim().isNotEmpty ? controller.text.trim() : 'Cancelled by store';
            Navigator.pop(ctx, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Cancel'),
        ),
      ],
    ),
  );

  if (result != null && context.mounted) {
    context.read<OrdersListBloc>().add(
          CancelOrderEvent(order.id, reason: result),
        );
  }
}

Future<void> _launchPhoneCall(String phoneNumber) async {
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

// -------------------------------------------------------------
// REAL-TIME BUYER PROFILE UTILITIES
// -------------------------------------------------------------
class BuyerProfile {
  final String name;
  final String phone;
  final String address;

  const BuyerProfile({
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ phone.hashCode ^ address.hashCode;
}

class RealtimeOrderCustomerDetails extends StatelessWidget {
  final String fallbackName;
  final String? fallbackPhone;
  final String? fallbackAddress;
  final String? customerId;
  final String? orderId;
  final Widget Function(BuildContext context, BuyerProfile profile) builder;

  const RealtimeOrderCustomerDetails({
    Key? key,
    required this.fallbackName,
    this.fallbackPhone,
    this.fallbackAddress,
    this.customerId,
    this.orderId,
    required this.builder,
  }) : super(key: key);

  static final Map<String, BuyerProfile> _profileCache = {};

  static bool _isValidName(String? name) {
    if (name == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'customer' &&
        lower != 'buyer' &&
        lower != 'unknown customer' &&
        lower != 'unknown' &&
        lower != '?' &&
        lower != 'null';
  }

  static bool _isValidPhone(String? phone) {
    if (phone == null) return false;
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'n/a' && lower != 'none' && lower != 'null' && trimmed.length >= 3;
  }

  static bool _isValidAddress(String? address) {
    if (address == null) return false;
    final trimmed = address.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'primary address' &&
        lower != 'n/a' &&
        lower != 'null' &&
        lower != 'no address' &&
        lower != 'none' &&
        lower != 'select address' &&
        lower != 'not set' &&
        trimmed.isNotEmpty;
  }

  static String _extractName(Map<String, dynamic>? data) {
    if (data == null) return '';
    for (final key in [
      'name',
      'customerName',
      'buyerName',
      'userName',
      'displayName',
      'fullName',
      'customer_name',
      'buyer_name',
      'user_name',
      'firstName',
      'first_name',
    ]) {
      final val = data[key];
      if (val is String && _isValidName(val)) return val.trim();
    }
    final first = data['firstName'] ?? data['first_name'];
    final last = data['lastName'] ?? data['last_name'];
    if (first is String && first.trim().isNotEmpty) {
      final combined = '$first ${last ?? ''}'.trim();
      if (_isValidName(combined)) return combined;
    }
    for (final key in ['customer', 'user', 'buyer', 'profile']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final nested = _extractName(val);
        if (_isValidName(nested)) return nested;
      }
    }
    return '';
  }

  static String _extractPhone(Map<String, dynamic>? data) {
    if (data == null) return '';
    for (final key in [
      'phone',
      'phoneNumber',
      'mobile',
      'userPhone',
      'customerPhone',
      'buyerPhone',
      'contactNumber',
      'contact',
      'contactPhone',
      'phone_number',
    ]) {
      final val = data[key];
      if (val is String && _isValidPhone(val)) return val.trim();
    }
    for (final key in ['customer', 'user', 'buyer', 'profile']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final nested = _extractPhone(val);
        if (_isValidPhone(nested)) return nested;
      }
    }
    return '';
  }

  static String _extractAddress(Map<String, dynamic>? data) {
    if (data == null) return '';
    for (final key in [
      'deliveryAddress',
      'address',
      'primaryAddress',
      'homeAddress',
      'workAddress',
      'otherAddress',
      'shippingAddress',
      'userAddress',
      'fullAddress',
      'displayAddress',
      'dropOffAddress',
      'delivery_address',
    ]) {
      final val = data[key];
      if (val is String && _isValidAddress(val)) {
        return val.trim();
      } else if (val is Map) {
        final sub = val['address'] ?? val['fullAddress'] ?? val['street'] ?? val['formattedAddress'] ?? val['displayAddress'];
        if (sub != null && _isValidAddress(sub.toString())) {
          return sub.toString().trim();
        }
      }
    }
    for (final key in ['customer', 'user', 'buyer', 'profile']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final nested = _extractAddress(val);
        if (_isValidAddress(nested)) return nested;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cacheKey = '${customerId ?? ""}_${orderId ?? ""}';
    final cached = _profileCache[cacheKey];
    final initialProfile = cached ??
        BuyerProfile(
          name: _isValidName(fallbackName) ? fallbackName : '',
          phone: _isValidPhone(fallbackPhone) ? fallbackPhone! : '',
          address: _isValidAddress(fallbackAddress) ? fallbackAddress! : '',
        );

    final hasValidSnapshot = _isValidName(fallbackName) &&
        _isValidPhone(fallbackPhone) &&
        _isValidAddress(fallbackAddress);

    if (hasValidSnapshot) {
      final snapshotProfile = BuyerProfile(
        name: fallbackName,
        phone: fallbackPhone!,
        address: fallbackAddress!,
      );
      _profileCache[cacheKey] = snapshotProfile;
      return builder(context, snapshotProfile);
    }

    if (customerId != null && customerId!.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('buyer_user').doc(customerId).snapshots(),
        builder: (context, userSnap) {
          Map<String, dynamic>? uData;
          if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
            uData = userSnap.data!.data();
          }

          final uName = _extractName(uData);
          final uPhone = _extractPhone(uData);
          final uAddress = _extractAddress(uData);

          final resolvedName = _isValidName(uName) ? uName : initialProfile.name;
          final resolvedPhone = _isValidPhone(uPhone) ? uPhone : initialProfile.phone;
          final resolvedAddress = _isValidAddress(uAddress) ? uAddress : initialProfile.address;

          final profile = BuyerProfile(
            name: resolvedName,
            phone: resolvedPhone,
            address: resolvedAddress,
          );
          _profileCache[cacheKey] = profile;
          return builder(context, profile);
        },
      );
    }

    return builder(context, initialProfile);
  }
}

class RealtimeOrderCustomerNameText extends StatelessWidget {
  final String fallbackName;
  final String? customerId;
  final String? orderId;
  final TextStyle? style;

  const RealtimeOrderCustomerNameText({
    Key? key,
    required this.fallbackName,
    this.customerId,
    this.orderId,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RealtimeOrderCustomerDetails(
      fallbackName: fallbackName,
      customerId: customerId,
      orderId: orderId,
      builder: (context, profile) {
        return Text(
          profile.name.isEmpty ? fallbackName : profile.name,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
