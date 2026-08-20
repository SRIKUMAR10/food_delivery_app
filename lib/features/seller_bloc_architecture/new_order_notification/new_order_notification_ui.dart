import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/order_model.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'new_order_notification_bloc.dart';
import 'new_order_notification_event.dart';
import 'new_order_notification_state.dart';
import 'new_order_notification_repository.dart';
import 'new_order_notification_service.dart';

class NewOrderNotificationPage extends StatelessWidget {
  const NewOrderNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (context) => NewOrderNotificationBloc(
        repository: NewOrderNotificationRepository(
          service: NewOrderNotificationService(),
        ),
      )..add(StartListening(sellerId: sellerId)),
      child: const NewOrderNotificationView(),
    );
  }
}

class NewOrderNotificationView extends StatefulWidget {
  const NewOrderNotificationView({super.key});

  @override
  State<NewOrderNotificationView> createState() =>
      _NewOrderNotificationViewState();
}

class _NewOrderNotificationViewState extends State<NewOrderNotificationView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isAccepting = false;
  bool _isRejecting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth;
            if (constraints.maxWidth > 1024) {
              cardWidth = 720;
            } else if (constraints.maxWidth > 600) {
              cardWidth = 600;
            } else {
              cardWidth = constraints.maxWidth;
            }

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: constraints.maxWidth < 600 ? 16 : 0,
                ),
                child: BlocConsumer<NewOrderNotificationBloc, NewOrderNotificationState>(
                  listener: (context, state) {
                    if (state is NewOrderLoaded) {
                      _animationController.forward();
                      setState(() {
                        _isAccepting = false;
                        _isRejecting = false;
                      });
                    } else if (state is OrderAcceptedState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order Accepted Successfully!')),
                      );
                      Navigator.pop(context, true);
                    } else if (state is OrderRejectedState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order Rejected.')),
                      );
                    } else if (state is NewOrderNotificationError) {
                      setState(() {
                        _isAccepting = false;
                        _isRejecting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is NewOrderNotificationError) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () {
                          setState(() {
                            _isAccepting = false;
                            _isRejecting = false;
                          });
                        },
                      );
                    }

                    if (state is NewOrderNotificationInitial ||
                        state is NewOrderNotificationLoading) {
                      return const _LoadingView();
                    }

                    if (state is NewOrderLoaded) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: cardWidth),
                            child: _OrderDetailsCard(
                              order: state.order,
                              pendingCount: state.pendingCount,
                              pulseAnimation: _pulseAnimation,
                              isAccepting: _isAccepting,
                              isRejecting: _isRejecting,
                              onAccept: () {
                                setState(() => _isAccepting = true);
                                context.read<NewOrderNotificationBloc>().add(
                                  AcceptOrderEvent(state.order.id),
                                );
                              },
                              onReject: () {
                                setState(() => _isRejecting = true);
                                context.read<NewOrderNotificationBloc>().add(
                                  RejectOrderEvent(state.order.id),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is NoNewOrders) {
                      return const EmptyStateView(
                        icon: Icons.inbox_rounded,
                        title: 'No New Orders',
                        subtitle:
                            'You will be notified when a new order arrives.',
                      );
                    }

                    return const EmptyStateView(
                      icon: Icons.inbox_rounded,
                      title: 'No New Orders',
                      subtitle:
                          'You will be notified when a new order arrives.',
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final int pendingCount;

  const _NotificationHeader({required this.pulseAnimation, this.pendingCount = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFE5E5), Color(0xFFFEE2E2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE52929).withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFE52929),
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            if (pendingCount > 1)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE52929),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'NEW ORDER RECEIVED',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          pendingCount > 1
              ? 'You have $pendingCount new orders waiting.'
              : 'You have received a new customer order.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


class _ActionButtons extends StatelessWidget {
  final bool isAccepting;
  final bool isRejecting;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ActionButtons({
    required this.isAccepting,
    required this.isRejecting,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isAccepting || isRejecting;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFE52929), Color(0xFFD01B1B)],
                    ),
              borderRadius: BorderRadius.circular(14),
              color: isDisabled ? const Color(0xFFE5E7EB) : null,
            ),
            child: ElevatedButton(
              onPressed: isDisabled ? null : onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isAccepting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Accept Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onReject,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDisabled
                    ? Colors.transparent
                    : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
              backgroundColor: isDisabled
                  ? const Color(0xFFF3F4F6)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isRejecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B7280),
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, color: Color(0xFF374151)),
                      SizedBox(width: 8),
                      Text(
                        'Reject Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final OrderModel order;
  final int pendingCount;
  final Animation<double> pulseAnimation;
  final bool isAccepting;
  final bool isRejecting;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _OrderDetailsCard({
    required this.order,
    required this.pendingCount,
    required this.pulseAnimation,
    required this.isAccepting,
    required this.isRejecting,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NotificationHeader(pulseAnimation: pulseAnimation, pendingCount: pendingCount),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                if (order.items != null)
                  ...order.items!.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                            NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: '₹',
                            ).format(item.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const SizedBox(height: 40),
          _ActionButtons(
            isAccepting: isAccepting,
            isRejecting: isRejecting,
            onAccept: onAccept,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFE52929)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFE52929),
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52929),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


