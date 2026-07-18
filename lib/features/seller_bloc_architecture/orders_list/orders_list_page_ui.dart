import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/models/order_model.dart';
import 'orders_list_page_bloc.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import '../../../../core/repositories/i_order_repository.dart';
import '../assign_delivery_page_/assign_delivery_page__ui.dart';
import '../assign_delivery_page_/assign_delivery_page__bloc.dart';
import '../assign_delivery_page_/assign_delivery_page__repository.dart';
import '../assign_delivery_page_/assign_delivery_page__service.dart';
import '../assign_delivery_page_/assign_delivery_page__event.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersListBloc(
        repository: context.read<IOrderRepository>(),
      )..add(LoadOrdersStream(FirebaseAuth.instance.currentUser?.uid ?? '')),
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
                  content: Text(state.errorMessage!),
                  backgroundColor: const Color(0xFFE52929),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<OrdersListBloc>().add(ClearMessages());
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: const Color(0xFF22C55E),
                  behavior: SnackBarBehavior.floating,
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
            if (constraints.maxWidth > 1024) {
              containerWidth = 800;
            } else if (constraints.maxWidth > 600) {
              containerWidth = 600;
            }

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: containerWidth),
                child: RefreshIndicator(
                  color: const Color(0xFFE52929),
                  onRefresh: () async {
                    context.read<OrdersListBloc>().add(LoadOrdersStream(FirebaseAuth.instance.currentUser?.uid ?? ''));
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: const Color(0xFFF8FAFC),
                        surfaceTintColor: Colors.transparent,
                        pinned: true,
                        expandedHeight: 120,
                        collapsedHeight: 60,
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          title: const Text(
                            'Orders',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF475569),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF475569),
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 20,
                          ),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                context.read<OrdersListBloc>().add(SearchOrders(value));
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search by Order ID or Name...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF94A3B8),
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
                      SliverToBoxAdapter(
                        child: BlocBuilder<OrdersListBloc, OrdersListState>(
                          builder: (context, state) {
                            if (state is OrdersListLoaded) {
                              return _SegmentedFilter(state: state);
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: _SkeletonLoader(
                                height: 52,
                                borderRadius: 26,
                              ),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      BlocBuilder<OrdersListBloc, OrdersListState>(
                        builder: (context, state) {
                          if (state is OrdersListLoading ||
                              state is OrdersListInitial) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: _SkeletonLoader(
                                    height: 160,
                                    borderRadius: 20,
                                  ),
                                );
                              }, childCount: 4),
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
                                      onPressed: () => context
                                          .read<OrdersListBloc>()
                                          .add(LoadOrdersStream(FirebaseAuth.instance.currentUser?.uid ?? '')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE52929,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                              return const SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyState(),
                              );
                            }
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final isDesktop = screenWidth >= 1024;
                            final crossAxisCount = isDesktop ? 2 : 1;

                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              sliver: isDesktop
                                  ? SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            mainAxisExtent: 210,
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
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: _OrderListCard(
                                              order:
                                                  state.filteredOrders[index],
                                              index: index,
                                            ),
                                          );
                                        },
                                        childCount: state.filteredOrders.length,
                                      ),
                                    ),
                            );
                          }
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

class _SegmentedFilter extends StatelessWidget {
  final OrdersListLoaded state;
  const _SegmentedFilter({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Lighter background for premium feel
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            _SegmentButton(
              label: 'New',
              count: state.getCount('New'),
              state: state,
              activeColor: const Color(0xFF3B82F6), // Blue for new
            ),
            _SegmentButton(
              label: 'Preparing',
              count: state.getCount('Preparing'),
              state: state,
              activeColor: const Color(0xFFF97316), // Orange for preparing
            ),
            _SegmentButton(
              label: 'Ready',
              count: state.getCount('Completed'),
              state: state,
              activeColor: const Color(0xFF22C55E), // Green for ready
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final int count;
  final OrdersListLoaded state;
  final Color activeColor;

  const _SegmentButton({
    required this.label,
    required this.count,
    required this.state,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Map the UI label 'Ready' back to 'Completed' for bloc logic if needed
    final filterKey = label == 'Ready' ? 'Completed' : label;
    final isActive = state.activeFilter == filterKey;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<OrdersListBloc>().add(FilterOrders(filterKey)),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? activeColor : const Color(0xFF64748B),
                    letterSpacing: -0.2,
                  ),
                  child: Text(label),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? activeColor : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
  bool _startAnimation = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 + (widget.index * 50)), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _startAnimation ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _startAnimation ? Offset.zero : const Offset(0, 0.1),
        child: BlocBuilder<OrdersListBloc, OrdersListState>(
          builder: (context, state) {
            final isUpdating = state is OrdersListLoaded && 
                               state.updatingOrderIds.contains(widget.order.id);
            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? const Color(0xFFE52929).withValues(alpha: 0.3)
                        : const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF0F172A,
                      ).withValues(alpha: _isHovered ? 0.08 : 0.03),
                      blurRadius: _isHovered ? 30 : 20,
                      offset: Offset(0, _isHovered ? 12 : 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: isUpdating ? null : () {
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      '#${widget.order.id}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.delivery_dining_rounded,
                                    size: 20,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Delivery',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              if (isUpdating)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE52929),
                                  ),
                                )
                              else
                                Text(
                                  NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.order.amount),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Text(
                                  widget.order.customerName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.order.customerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.order.items?.length ?? 0} Items • ${widget.order.paymentMethod ?? "Cash"}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatusBadge(status: widget.order.status.value),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.order.timeAgo,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersListBloc, OrdersListState>(
      listener: (context, state) {
        if (state is OrdersListError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<OrdersListBloc, OrdersListState>(
        builder: (context, state) {
          // Find the most up to date order object from state
          OrderModel order = widget.order;
          bool isUpdating = false;
          if (state is OrdersListLoaded) {
            order = state.allOrders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);
            isUpdating = state.updatingOrderIds.contains(widget.order.id);
          }

          final isNew = order.status == OrderStatus.newOrder;
          final isPreparing = order.status == OrderStatus.preparing;
          final isReady = order.status == OrderStatus.ready || order.status == OrderStatus.delivered; // 'Completed' mapped to 'Ready for pickup' / Delivered
          final isOutForDelivery = order.status == OrderStatus.outForDelivery;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 20,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Order #${order.id}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                              _StatusBadge(status: order.status.value),
                            ],
                          ),
                        ),

                        // Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer Info
                                const _SectionTitle(title: 'Customer Info'),
                                _InfoContainer(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            order.customerPhone ?? 'No Phone Provided',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEFF6FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Color(0xFF3B82F6),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Delivery Address
                                const _SectionTitle(title: 'Delivery Address'),
                                _InfoContainer(
                                  child: Text(
                                    order.deliveryAddress ?? 'No Address Provided',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF475569),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Items
                                const _SectionTitle(title: 'Items'),
                                _InfoContainer(
                                  child: Column(
                                    children: [
                                      if (order.items != null)
                                        ...order.items!
                                            .map(
                                              (item) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${item.quantity}x',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF334155),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF1E293B),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(item.price),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF1E293B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: Divider(color: Color(0xFFE2E8F0)),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Amount',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(order.amount),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Timeline
                                _OrderTimeline(currentStatus: order.status.value),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              if (isNew) ...[
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Reject',
                                    isPrimary: false,
                                    isLoading: isUpdating,
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Reject Order'),
                                          content: const Text('Are you sure you want to reject this order? This action cannot be undone.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<OrdersListBloc>().add(UpdateOrderStatusEvent(order.id, OrderStatus.rejected));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Accept Order',
                                    isPrimary: true,
                                    isLoading: isUpdating,
                                    onTap: () {
                                      context.read<OrdersListBloc>().add(UpdateOrderStatusEvent(order.id, OrderStatus.preparing));
                                    },
                                  ),
                                ),
                              ],
                              if (isPreparing) ...[
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Mark as Ready',
                                    isPrimary: true,
                                    isLoading: isUpdating,
                                    onTap: () {
                                      context.read<OrdersListBloc>().add(UpdateOrderStatusEvent(order.id, OrderStatus.ready));
                                    },
                                  ),
                                ),
                              ],
                              if (isReady && order.status != OrderStatus.delivered) ...[
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Assign Delivery',
                                    isPrimary: true,
                                    isLoading: isUpdating,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<OrdersListBloc>(),
                                            child: BlocProvider(
                                              create: (context) =>
                                                  AssignDeliveryBloc(
                                                    repository:
                                                        AssignDeliveryRepository(
                                                          service:
                                                              AssignDeliveryService(),
                                                        ),
                                                    orderId: order.id,
                                                  )..add(
                                                    LoadRidersEvent(orderId: order.id),
                                                  ),
                                              child: AssignDeliveryPage(
                                                orderId: order.id,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              if (isOutForDelivery) ...[
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Mark Delivered',
                                    isPrimary: true,
                                    isLoading: isUpdating,
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Mark as Delivered'),
                                          content: const Text('Are you sure the order has been delivered?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<OrdersListBloc>().add(UpdateOrderStatusEvent(order.id, OrderStatus.delivered));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  final Widget child;
  const _InfoContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: child,
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String currentStatus;
  const _OrderTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    int activeStep = 0; // default for 'New'
    if (currentStatus == 'Preparing') activeStep = 2;
    if (currentStatus == 'Completed') activeStep = 3;

    final steps = [
      {'title': 'Order accepted', 'subtitle': ''},
      {'title': 'Payment received', 'subtitle': ''},
      {'title': 'Preparing', 'subtitle': 'Kitchen is preparing your order'},
      {
        'title': 'Ready for pickup',
        'subtitle': 'Order is ready to be picked up',
      },
      {'title': 'Out for delivery', 'subtitle': 'On the way'},
      {'title': 'Delivered', 'subtitle': 'Order delivered to customer'},
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < activeStep;
        final isActive = index == activeStep;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF22C55E) // Green for completed
                          : isActive
                          ? const Color(0xFFF97316) // Orange for active
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? Colors.transparent
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: isCompleted || isActive
                        ? Icon(
                            isCompleted ? Icons.check : Icons.circle,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFF1F5F9),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isActive || isCompleted
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive || isCompleted
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      if (steps[index]['subtitle']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          steps[index]['subtitle']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFFE52929) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF64748B),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.white : const Color(0xFFE52929),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData iconData;
    String label;

    switch (status) {
      case 'New':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF3B82F6);
        iconData = Icons.auto_awesome_rounded;
        label = 'New';
        break;
      case 'Preparing':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF97316);
        iconData = Icons.soup_kitchen_rounded;
        label = 'Preparing';
        break;
      case 'Completed':
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF22C55E);
        iconData = Icons.check_circle_rounded;
        label = 'Ready';
        break;
      default:
        bgColor = const Color(0xFFF8FAFC);
        textColor = const Color(0xFF64748B);
        iconData = Icons.info_outline_rounded;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'New customer orders will appear here.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<OrdersListBloc>().add(LoadOrdersStream(FirebaseAuth.instance.currentUser?.uid ?? '')),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF334155),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  final double height;
  final double borderRadius;

  const _SkeletonLoader({required this.height, required this.borderRadius});

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
