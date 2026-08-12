import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/models/order_model.dart';
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

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersListBloc(
        repository: context.read<IOrderRepository>(),
        chatRepository: context.read<IChatRepository>(),
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
                      context.read<OrdersListBloc>().add(
                        LoadOrdersStream(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                      );
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
                          actions: [],
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
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  context.read<OrdersListBloc>().add(
                                    SearchOrders(value),
                                  );
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
                            buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
                          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
                                      height: 220,
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
                                        onPressed: () =>
                                            context.read<OrdersListBloc>().add(
                                              LoadOrdersStream(
                                                FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.uid ??
                                                    '',
                                              ),
                                            ),
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

                              return SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                sliver: isDesktop
                                    ? SliverGrid(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisExtent: 290,
                                              mainAxisSpacing: 16,
                                              crossAxisSpacing: 16,
                                            ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return _OrderListCard(
                                              order:
                                                  state.filteredOrders[index],
                                              index: index,
                                            );
                                          },
                                          childCount:
                                              state.filteredOrders.length,
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
                                          childCount:
                                              state.filteredOrders.length,
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
              count: state.getCount('Ready'),
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
    final filterKey = label;
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
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            final isUpdating =
                state is OrdersListLoaded &&
                state.updatingOrderIds.contains(widget.order.id);
            return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..scaleByVector3(Vector3(
                    _isHovered ? 1.02 : 1.0,
                    _isHovered ? 1.02 : 1.0,
                    1.0,
                  )),
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
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onHover: (value) => setState(() => _isHovered = value),
                    onTap: isUpdating
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<OrdersListBloc>(),
                                  child: OrderDetailsScreen(
                                    order: widget.order,
                                  ),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
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
                                          overflow: TextOverflow.ellipsis,
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
                                  NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                  ).format(widget.order.amount),
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
                          RealtimeOrderCustomerDetails(
                            fallbackName: widget.order.customerName,
                            fallbackPhone: widget.order.customerPhone,
                            fallbackAddress: widget.order.deliveryAddress,
                            customerId: widget.order.customerId,
                            orderId: widget.order.id,
                            builder: (context, buyerProfile) {
                              final itemCount =
                                  widget.order.items?.length ?? 0;
                              String itemSummary = '';
                              final items = widget.order.items;
                              if (items != null && items.isNotEmpty) {
                                final names = items
                                    .where((item) =>
                                        item.name.isNotEmpty &&
                                        item.name != 'Unknown Item')
                                    .map((item) => item.name)
                                    .toList();
                                if (names.length == 1) {
                                  itemSummary = names.first;
                                } else if (names.length == 2) {
                                  itemSummary = '${names[0]} + ${names[1]}';
                                } else if (names.length > 2) {
                                  itemSummary =
                                      '${names[0]}, ${names[1]}...';
                                } else {
                                  itemSummary = '$itemCount items';
                                }
                              }
                              if (itemSummary.isEmpty) {
                                itemSummary = '$itemCount items';
                              }

                              final displayName = buyerProfile.name.isNotEmpty
                                  ? buyerProfile.name
                                  : (widget.order.customerName.isNotEmpty && widget.order.customerName != 'Customer'
                                      ? widget.order.customerName
                                      : 'Customer');

                              final displayPhone = buyerProfile.phone.isNotEmpty
                                  ? buyerProfile.phone
                                  : (widget.order.customerPhone ?? '');

                              final displayAddress = buyerProfile.address.isNotEmpty
                                  ? buyerProfile.address
                                  : (widget.order.deliveryAddress ?? '');

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                                letterSpacing: -0.3,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone_outlined,
                                                  size: 13,
                                                  color: Color(0xFF3B82F6),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    displayPhone.isNotEmpty
                                                        ? displayPhone
                                                        : 'Phone not provided',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: displayPhone.isNotEmpty
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                      color: displayPhone.isNotEmpty
                                                          ? const Color(0xFF3B82F6)
                                                          : const Color(0xFF94A3B8),
                                                      fontStyle: displayPhone.isNotEmpty
                                                          ? FontStyle.normal
                                                          : FontStyle.italic,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (displayPhone.isNotEmpty)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            onTap: () => _launchPhoneCall(
                                                displayPhone),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                    const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.call_rounded,
                                                size: 18,
                                                color: Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          displayAddress.isNotEmpty
                                              ? displayAddress
                                              : 'Address not specified',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: displayAddress.isNotEmpty
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            color: displayAddress.isNotEmpty
                                                ? const Color(0xFF475569)
                                                : const Color(0xFF94A3B8),
                                            fontStyle: displayAddress.isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$itemCount Item${itemCount != 1 ? 's' : ''} · $itemSummary',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF334155),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${widget.order.paymentMethod ?? "Wallet"} · ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.order.amount)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatusBadge(
                                  status: widget.order.status.value),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<OrdersListBloc, OrdersListState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
          // Find the most up to date order object from state
          OrderModel order = widget.order;
          bool isUpdating = false;
          if (state is OrdersListLoaded) {
            order = state.allOrders.firstWhere(
              (o) => o.id == widget.order.id,
              orElse: () => widget.order,
            );
            isUpdating = state.updatingOrderIds.contains(widget.order.id);
          }

          final isNew = order.status == OrderStatus.newOrder;
          final isPreparing = order.status == OrderStatus.preparing || order.status == OrderStatus.accepted;
          final isReady =
              order.status == OrderStatus.ready ||
              order.status ==
                  OrderStatus
                      .delivered; // 'Completed' mapped to 'Ready for pickup' / Delivered
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
                                // Customer & Delivery Details
                                const _SectionTitle(title: 'Customer & Delivery Info'),
                                RealtimeOrderCustomerDetails(
                                  fallbackName: order.customerName,
                                  fallbackPhone: order.customerPhone,
                                  fallbackAddress: order.deliveryAddress,
                                  customerId: order.customerId,
                                  orderId: order.id,
                                  builder: (context, buyerProfile) {
                                    if (buyerProfile.name.isEmpty && buyerProfile.address.isEmpty && buyerProfile.phone.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return _InfoContainer(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (buyerProfile.name.isNotEmpty) ...[
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: const Color(0xFFEFF6FF),
                                                  child: const Icon(
                                                    Icons.person_outline_rounded,
                                                    color: Color(0xFF2563EB),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        buyerProfile.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF0F172A),
                                                        ),
                                                      ),
                                                      if (buyerProfile.phone.isNotEmpty) ...[
                                                        const SizedBox(height: 2),
                                                        SelectableText(
                                                          buyerProfile.phone,
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                            color: Color(0xFF3B82F6),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (buyerProfile.address.isNotEmpty) ...[
                                            if (buyerProfile.name.isNotEmpty)
                                              const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                child: Divider(color: Color(0xFFE2E8F0)),
                                              ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Color(0xFFEF4444),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: SelectableText(
                                                    buyerProfile.address,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF334155),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF334155,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF1E293B,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      NumberFormat.currency(
                                                        locale: 'en_IN',
                                                        symbol: '₹',
                                                      ).format(item.price),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF1E293B,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(
                                          color: Color(0xFFE2E8F0),
                                        ),
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
                                            NumberFormat.currency(
                                              locale: 'en_IN',
                                              symbol: '₹',
                                            ).format(order.amount),
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
                                _OrderTimeline(
                                  currentStatus: order.status.value,
                                ),
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
                                          content: const Text(
                                            'Are you sure you want to reject this order? This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<OrdersListBloc>().add(
                                          UpdateOrderStatusEvent(
                                            order.id,
                                            OrderStatus.rejected,
                                          ),
                                        );
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
                                      context.read<OrdersListBloc>().add(
                                        UpdateOrderStatusEvent(
                                          order.id,
                                          OrderStatus.preparing,
                                        ),
                                      );
                                      Navigator.pop(context);
                                      context.read<OrdersListBloc>().add(
                                        FilterOrders('Preparing'),
                                      );
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
                                      context.read<OrdersListBloc>().add(
                                        UpdateOrderStatusEvent(
                                          order.id,
                                          OrderStatus.ready,
                                        ),
                                      );
                                      Navigator.pop(context);
                                      context.read<OrdersListBloc>().add(
                                        FilterOrders('Ready'),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              if (isReady &&
                                  order.status != OrderStatus.delivered) ...[
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
                                            value: context
                                                .read<OrdersListBloc>(),
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
                                                    LoadRidersEvent(
                                                      orderId: order.id,
                                                    ),
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
                                          title: const Text(
                                            'Mark as Delivered',
                                          ),
                                          content: const Text(
                                            'Are you sure the order has been delivered?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<OrdersListBloc>().add(
                                          UpdateOrderStatusEvent(
                                            order.id,
                                            OrderStatus.delivered,
                                          ),
                                        );
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
    int activeStep = 0;
    switch (currentStatus) {
      case 'New':
      case 'Accepted':
        activeStep = 0;
        break;
      case 'Rejected':
      case 'Cancelled':
        activeStep = -1;
        break;
      case 'Preparing':
        activeStep = 2;
        break;
      case 'Ready':
        activeStep = 3;
        break;
      case 'OutForDelivery':
        activeStep = 4;
        break;
      case 'Delivered':
        activeStep = 5;
        break;
    }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          width: 2,
                          child: CustomPaint(
                            size: Size.zero,
                            painter: _DashedLinePainter(
                              color: isCompleted
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      case 'Accepted':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF3B82F6);
        iconData = Icons.thumb_up_rounded;
        label = 'Accepted';
        break;
      case 'Preparing':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF97316);
        iconData = Icons.soup_kitchen_rounded;
        label = 'Preparing';
        break;
      case 'Ready':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFFA16207);
        iconData = Icons.checklist_rounded;
        label = 'Ready';
        break;
      case 'OutForDelivery':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0369A1);
        iconData = Icons.delivery_dining_rounded;
        label = 'Out for Delivery';
        break;
      case 'Delivered':
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF22C55E);
        iconData = Icons.check_circle_rounded;
        label = 'Delivered';
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        iconData = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      case 'Cancelled':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        iconData = Icons.cancel_rounded;
        label = 'Cancelled';
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
            onPressed: () => context.read<OrdersListBloc>().add(
              LoadOrdersStream(FirebaseAuth.instance.currentUser?.uid ?? ''),
            ),
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

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0.0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

Future<void> _launchPhoneCall(String phoneNumber) async {
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

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
    if (lower == 'primary address' ||
        lower == 'n/a' ||
        lower == 'null' ||
        lower == 'no address' ||
        lower == 'none' ||
        lower == 'select address' ||
        lower == 'not set') {
      return false;
    }
    return trimmed.length >= 1;
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
      if (val is String && _isValidName(val)) {
        return val.trim();
      }
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
        final nestedName = _extractName(val);
        if (_isValidName(nestedName)) return nestedName;
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
      if (val is String && _isValidPhone(val)) {
        return val.trim();
      }
    }
    for (final key in ['customer', 'user', 'buyer', 'profile']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final nestedPhone = _extractPhone(val);
        if (_isValidPhone(nestedPhone)) return nestedPhone;
      }
    }
    return '';
  }

  static String _extractAddress(Map<String, dynamic>? data) {
    if (data == null) return '';

    final selectedType =
        (data['selectedAddressType'] as String? ?? '').toLowerCase().trim();
    final typeFieldMap = {
      'home': 'homeAddress',
      'work': 'workAddress',
      'other': 'otherAddress',
    };
    final selectedKey = typeFieldMap[selectedType] ?? '';
    if (selectedKey.isNotEmpty) {
      final val = data[selectedKey];
      if (val is String && _isValidAddress(val)) return val.trim();
    }

    final primaryAddr = data['address'];
    if (primaryAddr is String && _isValidAddress(primaryAddr)) {
      return primaryAddr.trim();
    }

    for (final key in [
      'deliveryAddress',
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
        final sub = val['address'] ??
            val['fullAddress'] ??
            val['street'] ??
            val['formattedAddress'] ??
            val['displayAddress'];
        if (sub != null && _isValidAddress(sub.toString())) {
          return sub.toString().trim();
        }
      }
    }
    if (data['addresses'] is List && (data['addresses'] as List).isNotEmpty) {
      final first = (data['addresses'] as List).first;
      if (first is Map) {
        final sub = first['address'] ??
            first['fullAddress'] ??
            first['street'] ??
            first['formattedAddress'];
        if (sub != null && _isValidAddress(sub.toString())) {
          return sub.toString().trim();
        }
      } else if (first is String && _isValidAddress(first)) {
        return first.trim();
      }
    }
    for (final key in ['customer', 'user', 'buyer', 'profile']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final nestedAddress = _extractAddress(val);
        if (_isValidAddress(nestedAddress)) return nestedAddress;
      }
    }
    return '';
  }

  static String _extractCustomerId(Map<String, dynamic>? data) {
    if (data == null) return '';
    for (final key in ['customerId', 'buyerId', 'userId', 'customer_id', 'buyer_id', 'user_id', 'uid']) {
      final val = data[key];
      if (val is String && val.trim().isNotEmpty) return val.trim();
    }
    for (final key in ['customer', 'user', 'buyer']) {
      final val = data[key];
      if (val is Map<String, dynamic>) {
        final id = _extractCustomerId(val);
        if (id.isNotEmpty) return id;
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

          if (orderId != null && orderId!.isNotEmpty) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
              builder: (context, orderSnap) {
                Map<String, dynamic>? oData;
                if (orderSnap.hasData && orderSnap.data != null && orderSnap.data!.exists) {
                  oData = orderSnap.data!.data();
                }

                final oName = _extractName(oData);
                final oPhone = _extractPhone(oData);
                final oAddress = _extractAddress(oData);

                final resolvedName = _isValidName(uName) ? uName : (_isValidName(oName) ? oName : initialProfile.name);
                final resolvedPhone = _isValidPhone(uPhone) ? uPhone : (_isValidPhone(oPhone) ? oPhone : initialProfile.phone);
                final resolvedAddress = _isValidAddress(uAddress) ? uAddress : (_isValidAddress(oAddress) ? oAddress : initialProfile.address);

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

    if (orderId != null && orderId!.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, orderSnap) {
          Map<String, dynamic>? oData;
          if (orderSnap.hasData && orderSnap.data != null && orderSnap.data!.exists) {
            oData = orderSnap.data!.data();
          }

          final oName = _extractName(oData);
          final oPhone = _extractPhone(oData);
          final oAddress = _extractAddress(oData);
          final foundCustomerId = _extractCustomerId(oData);

          if (foundCustomerId.isNotEmpty) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('buyer_user').doc(foundCustomerId).snapshots(),
              builder: (context, userSnap) {
                Map<String, dynamic>? uData;
                if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
                  uData = userSnap.data!.data();
                }

                final uName = _extractName(uData);
                final uPhone = _extractPhone(uData);
                final uAddress = _extractAddress(uData);

                final resolvedName = _isValidName(uName) ? uName : (_isValidName(oName) ? oName : initialProfile.name);
                final resolvedPhone = _isValidPhone(uPhone) ? uPhone : (_isValidPhone(oPhone) ? oPhone : initialProfile.phone);
                final resolvedAddress = _isValidAddress(uAddress) ? uAddress : (_isValidAddress(oAddress) ? oAddress : initialProfile.address);

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

          final resolvedName = _isValidName(oName) ? oName : initialProfile.name;
          final resolvedPhone = _isValidPhone(oPhone) ? oPhone : initialProfile.phone;
          final resolvedAddress = _isValidAddress(oAddress) ? oAddress : initialProfile.address;

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
  final TextStyle style;
  final Widget Function(BuildContext context, String resolvedName)? builder;

  const RealtimeOrderCustomerNameText({
    Key? key,
    required this.fallbackName,
    this.customerId,
    this.orderId,
    required this.style,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RealtimeOrderCustomerDetails(
      fallbackName: fallbackName,
      customerId: customerId,
      orderId: orderId,
      builder: (context, profile) {
        if (builder != null) return builder!(context, profile.name);
        return Text(profile.name, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
      },
    );
  }
}
