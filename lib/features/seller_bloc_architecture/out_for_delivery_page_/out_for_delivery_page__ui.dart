import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/map_marker_service.dart';
import '../../../core/widgets/app_google_map_view.dart';
import '../../../core/widgets/status_badge.dart';
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
      child: const OutForDeliveryView(),
    );
  }
}

class OutForDeliveryView extends StatelessWidget {
  const OutForDeliveryView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<OutForDeliveryPageBloc, OutForDeliveryPageState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            String orderNumber = '';
            if (state is OutForDeliveryPageLoaded) {
              orderNumber = state.orderId.length > 8
                  ? state.orderId.substring(0, 8).toUpperCase()
                  : state.orderId.toUpperCase();
            }
            return Row(
              children: [
                Text(
                  orderNumber.isNotEmpty ? 'Order #$orderNumber' : 'Order Tracking',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (state is OutForDeliveryPageLoaded)
                  const _PulsingLiveDot(size: 8),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<OutForDeliveryPageBloc, OutForDeliveryPageState>(
            buildWhen: (prev, curr) => prev != curr,
            builder: (context, state) {
              if (state is! OutForDeliveryPageLoaded) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildStatusBadge(state.currentStatus),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: BlocBuilder<OutForDeliveryPageBloc, OutForDeliveryPageState>(
              buildWhen: (prev, curr) => prev != curr,
              builder: (context, state) {
                if (state is OutForDeliveryPageLoading ||
                    state is OutForDeliveryPageInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEF4444),
                    ),
                  );
                } else if (state is OutForDeliveryPageError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is OutForDeliveryPageLoaded) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDriverProfileCard(context, state),
                        const SizedBox(height: 16),
                        _buildMapSection(context, state),
                        const SizedBox(height: 16),
                        _buildLiveMetricsBar(state),
                        const SizedBox(height: 16),
                        _buildTimelineCard(state.currentStatus),
                        const SizedBox(height: 16),
                        _buildCustomerInfoCard(context, state),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DeliveryStatus status) {
    Color color;
    String label;

    switch (status) {
      case DeliveryStatus.orderAccepted:
        color = const Color(0xFF1D4ED8);
        label = 'Order Accepted';
        break;
      case DeliveryStatus.paymentReceived:
        color = const Color(0xFF047857);
        label = 'Payment Verified';
        break;
      case DeliveryStatus.preparing:
        color = const Color(0xFFB45309);
        label = 'Preparing Food';
        break;
      case DeliveryStatus.readyForPickup:
        color = const Color(0xFF92400E);
        label = 'Ready for Pickup';
        break;
      case DeliveryStatus.outForDelivery:
        color = const Color(0xFF7E22CE);
        label = 'Out for Delivery';
        break;
      case DeliveryStatus.delivered:
        color = const Color(0xFF15803D);
        label = 'Delivered';
        break;
    }

    return StatusBadge(label: label, color: color);
  }

  Widget _buildDriverProfileCard(
      BuildContext context, OutForDeliveryPageLoaded state) {
    final rider = state.rider;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF1F5F9),
                  child: rider.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: rider.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildInitials(rider.name),
                        )
                      : _buildInitials(rider.name),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        rider.name.isNotEmpty ? rider.name : 'Delivery Partner',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rider.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            rider.vehicleType.toLowerCase().contains('car')
                                ? Icons.directions_car_rounded
                                : Icons.two_wheeler_rounded,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rider.vehicleType.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildActionButton(
            icon: Icons.phone_in_talk_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            tooltip: 'Call Driver',
            onTap: () {
              if (rider.phone.isNotEmpty) {
                context
                    .read<OutForDeliveryPageBloc>()
                    .add(CallRider(phoneNumber: rider.phone));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number not available')),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            tooltip: 'Chat with Driver',
            onTap: () {
              final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatSupportPage(
                    sellerId: sellerId,
                    initialOrderId: state.orderId,
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
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'DP';
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(
      BuildContext context, OutForDeliveryPageLoaded state) {
    final storeLoc = (state.sellerLat != null && state.sellerLng != null)
        ? LatLng(state.sellerLat!, state.sellerLng!)
        : null;
    final driverLoc = (state.riderLat != null && state.riderLng != null)
        ? LatLng(state.riderLat!, state.riderLng!)
        : null;
    final customerLoc = (state.customerLat != null && state.customerLng != null)
        ? LatLng(state.customerLat!, state.customerLng!)
        : null;

    final isPickedUp = state.currentStatus == DeliveryStatus.outForDelivery ||
        state.currentStatus == DeliveryStatus.delivered;

    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final double cardHeight = state.isMapExpanded
        ? (isDesktop ? 540.0 : 480.0)
        : (isDesktop ? 390.0 : 370.0);

    final isBike = MapMarkerService.isTwoWheeler(state.rider.vehicleType);
    final shortDistance = _shortDistanceLabel(state.distanceKm);
    final etaParts = shortDistance.isNotEmpty
        ? '${state.estimatedTime} • $shortDistance'
        : state.estimatedTime;

    final isIdle = state.driverSpeed != null && state.driverSpeed! <= 0.5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppGoogleMapView(
              storeLocation: storeLoc,
              storeName: state.sellerName,
              driverLocation: driverLoc,
              driverHeading: state.riderHeading,
              customerLocation: customerLoc,
              customerName: state.customerName,
              vehicleType: state.rider.vehicleType,
              isPickedUp: isPickedUp,
              isFullScreen: state.isMapExpanded,
              onToggleFullScreen: () => context
                  .read<OutForDeliveryPageBloc>()
                  .add(const ToggleMapFullScreen()),
              showControls: true,
              autoFollowDriver: true,
              bottomBadgeOffset: driverLoc == null ? 72.0 : 12.0,
              progressRatio: state.progressRatio,
              etaText: state.estimatedTime,
              distanceKm: state.distanceKm,
              driverSpeed: state.driverSpeed,
              expectedDeliveryTime: state.expectedDeliveryTime,
              isArrivingSoon: state.isArrivingSoon,
              isRaining: state.isRaining,
              weatherAlert: state.weatherAlert,
              onOpenExternalNavigation: () => _openExternalNavigation(context, state),
              driverName: state.rider.name,
              driverPhone: state.rider.phone,
              driverPhotoUrl: state.rider.imageUrl,
              driverVehicleNumber: state.rider.vehicleNumber,
              driverRating: state.rider.rating,
              storePhone: state.sellerPhone,
              storeAddress: state.sellerAddress,
              customerAddress: state.deliveryAddress.isNotEmpty
                  ? state.deliveryAddress
                  : null,
              customerNotes: state.customerNotes,
              onCallDriver: () => _callDriver(context, state),
              onChatDriver: () => _chatWithDriver(context, state),
              onCallStore: () => _callStore(context, state),
            ),
          ),
          if (driverLoc == null || isIdle)
            Positioned(
              bottom: 12,
              left: 12,
              right: 64,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: driverLoc == null
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        driverLoc == null
                            ? Icons.storefront_rounded
                            : Icons.pause_circle_filled_rounded,
                        color: driverLoc == null
                            ? const Color(0xFFE52121)
                            : const Color(0xFFD97706),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.sellerName.isNotEmpty
                                ? state.sellerName
                                : 'Restaurant',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            driverLoc == null
                                ? 'Order placed · Live partner will be tracked once assigned'
                                : 'Partner is waiting · No movement detected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBike
                        ? Icons.two_wheeler_rounded
                        : Icons.directions_car_filled_rounded,
                    color: const Color(0xFFE52121),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    etaParts,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDistanceLabel(double? distanceKm) {
    if (distanceKm == null || distanceKm <= 0) return '';
    if (distanceKm < 1.0) return '${(distanceKm * 1000).round()}m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  void _callDriver(BuildContext context, OutForDeliveryPageLoaded state) {
    if (state.rider.phone.isNotEmpty) {
      context
          .read<OutForDeliveryPageBloc>()
          .add(CallRider(phoneNumber: state.rider.phone));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  }

  void _chatWithDriver(BuildContext context, OutForDeliveryPageLoaded state) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatSupportPage(
          sellerId: sellerId,
          initialOrderId: state.orderId,
          targetRole: 'delivery_partner',
          partnerId: state.rider.id,
          partnerName: state.rider.name,
          partnerPhone: state.rider.phone,
        ),
      ),
    );
  }

  void _callStore(BuildContext context, OutForDeliveryPageLoaded state) {
    final phone = state.sellerPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store phone number not available')),
      );
      return;
    }
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isNotEmpty) {
      try {
        launchUrl(Uri.parse('tel:$cleaned'));
      } catch (_) {}
    }
  }

  void _openExternalNavigation(
      BuildContext context, OutForDeliveryPageLoaded state) {
    // Origin is Zolo Family Restaurant (or Rider if between store and customer)
    final originLat = state.sellerLat ?? 11.4299713;
    final originLng = state.sellerLng ?? 77.6759418;

    // Destination is Customer at 189A, Kamaraj Nagar, Kuruppanaickenpalayam
    final destLat = state.customerLat ?? 11.4555052;
    final destLng = state.customerLng ?? 77.6873137;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving',
    );
    try {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildLiveMetricsBar(OutForDeliveryPageLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const _PulsingLiveDot(size: 10),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LIVE TRACKING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF93C5FD),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  state.estimatedTime,
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(DeliveryStatus currentStatus) {
    final statuses = [
      {
        'title': 'Order Accepted',
        'subtitle': 'Order verified by restaurant',
        'status': DeliveryStatus.orderAccepted,
        'icon': Icons.receipt_long_rounded,
      },
      {
        'title': 'Payment Received',
        'subtitle': 'Secure transaction completed',
        'status': DeliveryStatus.paymentReceived,
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'title': 'Preparing Food',
        'subtitle': 'Chef is preparing your meal',
        'status': DeliveryStatus.preparing,
        'icon': Icons.soup_kitchen_outlined,
      },
      {
        'title': 'Ready for Pickup',
        'subtitle': 'Order packaged and waiting for partner',
        'status': DeliveryStatus.readyForPickup,
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Delivery partner is on the way',
        'status': DeliveryStatus.outForDelivery,
        'icon': Icons.delivery_dining_rounded,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Food successfully delivered to customer',
        'status': DeliveryStatus.delivered,
        'icon': Icons.check_circle_outline_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(statuses.length, (index) {
            final statusItem = statuses[index];
            final status = statusItem['status'] as DeliveryStatus;
            final isCompleted = status.index <= currentStatus.index;
            final isCurrent = status.index == currentStatus.index;
            final isLast = index == statuses.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : (isCurrent
                                ? const Color(0xFFEFF6FF)
                                : Colors.transparent),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : (isCurrent
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : Icon(
                                statusItem['icon'] as IconData,
                                size: 14,
                                color: isCurrent
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF94A3B8),
                              ),
                      ),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 2,
                        height: 36,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusItem['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : (isCompleted
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                            color: isCompleted
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusItem['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrent
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (!isLast) const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(
      BuildContext context, OutForDeliveryPageLoaded state) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text(
                'Customer & Destination',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (state.totalAmount != null && state.totalAmount! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currencyFormatter.format(state.totalAmount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.customerName.isNotEmpty
                          ? state.customerName
                          : 'Valued Customer',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (state.deliveryAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        state.deliveryAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              _buildActionButton(
                icon: Icons.phone_in_talk_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                tooltip: 'Call Customer',
                onTap: () => _callCustomer(context, state),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                tooltip: 'Chat with Customer',
                onTap: () => _chatWithCustomer(context, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer(
      BuildContext context, OutForDeliveryPageLoaded state) async {
    final phone = state.customerPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer phone number not available')),
      );
      return;
    }
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    try {
      final uri = Uri.parse('tel:$cleaned');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  void _chatWithCustomer(
      BuildContext context, OutForDeliveryPageLoaded state) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatSupportPage(
          sellerId: sellerId,
          initialOrderId: state.orderId,
          targetRole: 'buyer',
          partnerId: state.customerId ?? '',
          partnerName: state.customerName,
          partnerPhone: state.customerPhone,
        ),
      ),
    );
  }
}

class _PulsingLiveDot extends StatefulWidget {
  final double size;

  const _PulsingLiveDot({this.size = 10});

  @override
  State<_PulsingLiveDot> createState() => _PulsingLiveDotState();
}

class _PulsingLiveDotState extends State<_PulsingLiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF22C55E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: _animation.value * 0.7),
                blurRadius: 6 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
