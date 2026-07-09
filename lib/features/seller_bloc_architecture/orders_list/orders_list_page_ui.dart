import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_list_page_bloc.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import 'orders_list_page_repository.dart';
import 'orders_list_page_service.dart';
import '../assign_delivery_page_/assign_delivery_page__ui.dart';
import '../assign_delivery_page_/assign_delivery_page__bloc.dart';
import '../assign_delivery_page_/assign_delivery_page__repository.dart';
import '../assign_delivery_page_/assign_delivery_page__service.dart';
import '../assign_delivery_page_/assign_delivery_page__event.dart';
import '../out_for_delivery_page_/out_for_delivery_page__ui.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersListBloc(
        repository: OrdersListRepository(service: OrdersListService()),
      )..add(LoadOrders()),
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
      body: SafeArea(
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
                    context.read<OrdersListBloc>().add(LoadOrders());
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
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 20,
                          ),
                          child: Text(
                            'Track and manage customer orders',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
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
                                          .add(LoadOrders()),
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
                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _OrderListCard(
                                      order: state.filteredOrders[index],
                                    ),
                                  );
                                }, childCount: state.filteredOrders.length),
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

class _OrderListCard extends StatelessWidget {
  final OrderModel order;
  const _OrderListCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(order: order),
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
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '#${order.id}',
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
                    Text(
                      '₹${order.amount.toInt()}',
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
                        order.customerName.substring(0, 1).toUpperCase(),
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
                            order.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '2 Items • 2.1 km away',
                            style: TextStyle(
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
                    _StatusBadge(status: order.status),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.timeAgo,
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
  // Mock data to match the design
  final String _mockPhone = '+91 98765 43210';
  final String _mockAddress = '221B Baker Street, London\n2.1 km away';
  final List<Map<String, dynamic>> _mockItems = [
    {'qty': 1, 'name': 'Red Pizza', 'price': 400},
    {'qty': 1, 'name': 'Chicken Pizza', 'price': 300},
  ];

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isNew = order.status == 'New';
    final isPreparing = order.status == 'Preparing';
    final isReady =
        order.status == 'Completed'; // 'Completed' maps to 'Ready for pickup'
    final isOutForDelivery = order.status == 'Out for delivery';

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
                        _StatusBadge(status: order.status),
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
                                      _mockPhone,
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
                              _mockAddress,
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
                                ..._mockItems
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${item['qty']}x',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '₹${item['price']}',
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
                                      '₹${order.amount.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order Type',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontSize: 15,
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
                          _OrderTimeline(currentStatus: order.status),
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
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionButton(
                              label: 'Accept Order',
                              isPrimary: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                        if (isPreparing) ...[
                          Expanded(
                            child: _ActionButton(
                              label: 'Mark as Ready',
                              isPrimary: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                        if (isReady) ...[
                          Expanded(
                            child: _ActionButton(
                              label: 'Assign Delivery',
                              isPrimary: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
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
                                );
                              },
                            ),
                          ),
                        ],
                        if (isOutForDelivery) ...[
                          Expanded(
                            child: _ActionButton(
                              label: 'Out for Delivery',
                              isPrimary: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OutForDeliveryPageUI(orderId: order.id),
                                  ),
                                );
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE52929) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFFE52929), width: 1.5),
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
            onPressed: () => context.read<OrdersListBloc>().add(LoadOrders()),
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
                _controller.value - 0.2,
                _controller.value,
                _controller.value + 0.2,
              ],
            ),
          ),
        );
      },
    );
  }
}
