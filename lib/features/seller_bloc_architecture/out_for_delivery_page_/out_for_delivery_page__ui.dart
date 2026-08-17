import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'out_for_delivery_page__bloc.dart';
import 'out_for_delivery_page__event.dart';
import 'out_for_delivery_page__state.dart';
import '../chat_support_page_/chat_support_page_ui.dart';

class OutForDeliveryPageUI extends StatelessWidget {
  final String orderId;

  const OutForDeliveryPageUI({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OutForDeliveryPageBloc(
        repository: OutForDeliveryRepository(),
      )..add(FetchDeliveryDetails(orderId: orderId)),
      child: const _OutForDeliveryView(),
    );
  }
}

class _OutForDeliveryView extends StatelessWidget {
  const _OutForDeliveryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<OutForDeliveryPageBloc, OutForDeliveryPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            String title = 'Order';
            if (state is OutForDeliveryPageLoaded) {
              title = 'Order #${state.orderId}';
            }
            return Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Out for Delivery',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<OutForDeliveryPageBloc, OutForDeliveryPageState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
          if (state is OutForDeliveryPageLoading || state is OutForDeliveryPageInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OutForDeliveryPageError) {
            return Center(child: Text(state.message));
          } else if (state is OutForDeliveryPageLoaded) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDriverProfile(context, state.rider, state.orderId),
                    const SizedBox(height: 24),
                    _buildMapPlaceholder(),
                    const SizedBox(height: 24),
                    _buildLiveTrackingHeader(state),
                    const SizedBox(height: 16),
                    _buildTimeline(state.currentStatus),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDriverProfile(BuildContext context, RiderDetails rider, String orderId) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: CachedNetworkImageProvider(rider.imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rider.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rider.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        _buildActionButton(
          icon: Icons.phone,
          onTap: () => context.read<OutForDeliveryPageBloc>().add(CallRider(phoneNumber: rider.phone)),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          onTap: () {
            final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatSupportPage(
                  sellerId: sellerId,
                  initialOrderId: orderId,
                  targetRole: 'delivery_partner',
                  partnerId: rider.id,
                  partnerName: rider.name,
                  partnerPhone: rider.phone,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue.shade600, size: 20),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Dynamic Grid Map Background Visualizer
            Positioned.fill(
              child: Container(
                color: const Color(0xFFEDF2F7),
                child: CustomPaint(
                  painter: _MapGridPainter(),
                ),
              ),
            ),
            // Dynamic Live Route Indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE52121),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.store, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Store', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Icon(Icons.directions_bike, color: Color(0xFF10B981), size: 24),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Customer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildLiveTrackingHeader(OutForDeliveryPageLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Tracking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  state.distance,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          ],
        ),
        Text(
          'Ext. time ${state.estimatedTime}',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(DeliveryStatus currentStatus) {
    final statuses = [
      {'title': 'Order accepted', 'status': DeliveryStatus.orderAccepted},
      {'title': 'Payment received', 'status': DeliveryStatus.paymentReceived},
      {'title': 'Preparing', 'status': DeliveryStatus.preparing},
      {'title': 'Ready for pickup', 'status': DeliveryStatus.readyForPickup},
      {'title': 'Out for delivery', 'status': DeliveryStatus.outForDelivery},
      {'title': 'Delivered', 'status': DeliveryStatus.delivered},
    ];

    return Column(
      children: List.generate(statuses.length, (index) {
        final statusItem = statuses[index];
        final status = statusItem['status'] as DeliveryStatus;
        final isCompleted = status.index <= currentStatus.index;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                statusItem['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
