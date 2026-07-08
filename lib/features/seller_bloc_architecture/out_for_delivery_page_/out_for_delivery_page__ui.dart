import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'out_for_delivery_page__bloc.dart';
import 'out_for_delivery_page__event.dart';
import 'out_for_delivery_page__state.dart';

class OutForDeliveryPageUI extends StatelessWidget {
  final String orderId;

  const OutForDeliveryPageUI({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OutForDeliveryPageBloc()..add(FetchDeliveryDetails(orderId: orderId)),
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
                    _buildDriverProfile(context, state.rider),
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

  Widget _buildDriverProfile(BuildContext context, RiderDetails rider) {
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
          onTap: () => context.read<OutForDeliveryPageBloc>().add(MessageRider(riderId: rider.id)),
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
        color: Colors.grey.shade100,
        child: Stack(
          children: [
            // Mock map background
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.network(
                  'https://www.mapquestapi.com/staticmap/v5/map?key=dummy&center=Boston,MA&zoom=13&size=600,400@2x',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.map, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            // Mock route
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 30),
                  Container(width: 100, height: 4, color: Colors.blue),
                  const Icon(Icons.location_on, color: Colors.red, size: 30),
                ],
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
