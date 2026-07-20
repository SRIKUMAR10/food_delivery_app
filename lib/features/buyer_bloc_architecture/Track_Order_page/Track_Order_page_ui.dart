import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'Track_Order_page_bloc.dart';
import 'Track_Order_page_event.dart';
import 'Track_Order_page_state.dart';
import 'Track_Order_page_repository.dart';
import 'Track_Order_page_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Order Page/order_view_model.dart';
import '../user_profile_image/user_profile_image_Bloc.dart';
import '../Chat_Page/buyer_chat_ui.dart';
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';

class TrackOrderPageUI extends StatelessWidget {
  final String orderId;
  final OrderViewModel? order;
  final bool
  isEmbedded; // If true, hide Scaffold app bar and use simple background

  final bool allowPopOnDesktop;

  const TrackOrderPageUI({
    super.key,
    required this.orderId,
    this.order,
    this.isEmbedded = false,
    this.allowPopOnDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TrackOrderBloc(
                repository: TrackOrderRepositoryImpl(
                  service: TrackOrderService(firestore: FirebaseFirestore.instance),
                ),
              )..add(
                LoadTrackOrderDetails(
                  orderId: orderId,
                  orderDate: order?.date ?? DateTime.now(),
                ),
              ),
        ),
        BlocProvider(
          create: (context) =>
              UserProfileBloc()..add(const LoadProfileStarted()),
        ),
      ],
      child: _TrackOrderView(order: order, isEmbedded: isEmbedded, allowPopOnDesktop: allowPopOnDesktop),
    );
  }
}

class _TrackOrderView extends StatelessWidget {
  final OrderViewModel? order;
  final bool isEmbedded;
  final bool allowPopOnDesktop;

  const _TrackOrderView({this.order, this.isEmbedded = false, this.allowPopOnDesktop = true});

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // If the app is pushed as a mobile view but the window is resized to desktop,
          // pop this route so it doesn't duplicate the master-detail desktop layout.
          if (!isEmbedded && allowPopOnDesktop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            );
          }
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );

    if (isEmbedded) {
      return Container(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Track Order'),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(state),
                const SizedBox(height: 24),
                _buildTimelineCard(state),
                const SizedBox(height: 20),
                _buildUserInfo(context, state),
                if (order != null) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 24),
                  _buildOrderSummaryMobile(),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Order Details & Payment Summary
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildHeaderInfo(state),
                            const SizedBox(height: 24),
                            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                            const SizedBox(height: 24),
                            if (order != null) _buildOrderItemsList(),
                            if (order != null) ...[
                              const SizedBox(height: 24),
                              const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                              const SizedBox(height: 16),
                              _buildPaymentSummary(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right column: Tracking Timeline & Partner
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tracking Status',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1C),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTimeline(state.trackingSteps),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDesktopUserInfo(context, state),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderInfo(TrackOrderLoaded state) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = order != null ? dateFormat.format(order!.date) : null;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Order ID',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              '#${state.orderId.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        if (formattedDate != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date & Time',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated Delivery',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              state.estimatedDelivery,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineCard(TrackOrderLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 24),
          _buildTimeline(state.trackingSteps),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<TrackingStep> steps) {
    return Column(
      children: [
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          bool isLast = idx == steps.length - 1;
          return _buildTimelineNode(step, isLast, idx);
        }),
      ],
    );
  }

  Widget _buildTimelineNode(TrackingStep step, bool isLast, int index) {
    final isCompleted = step.status == TrackingStatus.completed;
    final isCurrent = step.status == TrackingStatus.current;
    final isFuture = step.status == TrackingStatus.future;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStatusIcon(step.status),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isFuture
                              ? Colors.grey.shade400
                              : const Color(0xFF1C1C1C),
                        ),
                      ),
                      if (step.time != null)
                        Text(
                          isFuture ? 'Upcoming' : step.time!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isFuture
                                ? Colors.grey.shade300
                                : Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'In progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStatusIcon(TrackingStatus status) {
    if (status == TrackingStatus.completed) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0xFF22C55E), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    } else if (status == TrackingStatus.current) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 14),
      );
    } else if (status == TrackingStatus.upcoming) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildUserInfo(BuildContext context, TrackOrderLoaded state) {
    if (state.sellerInfo == null) return const SizedBox.shrink();
    final profile = state.sellerInfo!;
    final isVerified = true;
    final distance = '1.2 km';
    final statusText = 'Open • Closes 10:00 PM';
    final statusColor = const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isCompact ? 28 : 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profile.imageUrl.isNotEmpty
                        ? NetworkImage(profile.imageUrl)
                        : null,
                    child: profile.imageUrl.isEmpty
                        ? Icon(Icons.store, color: Colors.grey, size: isCompact ? 28 : 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.name.isNotEmpty ? profile.name : 'Restaurant',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCompact ? 15 : 17,
                                  color: const Color(0xFF1C1C1C),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: isCompact ? 17 : 20,
                                color: const Color(0xFF22C55E),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: isCompact ? 13 : 15,
                              color: const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                profile.address.isNotEmpty
                                    ? profile.address
                                    : 'Store',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6B7280),
                                  fontSize: isCompact ? 11 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              distance,
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 11 : 12,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '  •  ',
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 11 : 12,
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Open map
                              },
                              child: Text(
                                'View on map',
                                style: GoogleFonts.poppins(
                                  fontSize: isCompact ? 11 : 12,
                                  color: const Color(0xFFE53935),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionSquare(
                        Icons.call,
                        const Color(0xFF22C55E),
                        onTap: () => _handlePhoneCall(context, profile.phone),
                      ),
                      const SizedBox(height: 10),
                      _buildActionSquare(
                        Icons.message,
                        const Color(0xFF2563EB),
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          CurvedNavigationBarView.supportNavigation.value = SupportNavigationData(
                            orderId: state.orderId,
                            sellerId: profile.id,
                            sellerName: profile.name,
                            buyerName: '',
                            sellerImageUrl: profile.imageUrl,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 11 : 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopUserInfo(BuildContext context, TrackOrderLoaded state) {
    if (state.sellerInfo == null) return const SizedBox.shrink();
    final profile = state.sellerInfo!;
    final isVerified = true;
    final distance = '2.4 km away';
    final statusColor = const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sold by',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profile.imageUrl.isNotEmpty
                          ? NetworkImage(profile.imageUrl)
                          : null,
                      child: profile.imageUrl.isEmpty
                          ? const Icon(Icons.store, color: Colors.grey, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.name.isNotEmpty ? profile.name : 'Restaurant',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: const Color(0xFF1C1C1C),
                                ),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified,
                                  size: 20,
                                  color: Color(0xFF22C55E),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.storefront_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${profile.name.isNotEmpty ? profile.name : "Restaurant"} Cakes & Desserts',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1C1C1C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  profile.address.isNotEmpty
                                      ? profile.address
                                      : 'Store Address',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Color(0xFF22C55E),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                distance,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '  •  ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFFD1D5DB),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'View on map',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Open',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '  •  Closes 10:00 PM',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4B5563),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildDesktopActionButton(
                    icon: Icons.call,
                    label: 'Call',
                    color: const Color(0xFF22C55E),
                    onTap: () => _handlePhoneCall(context, profile.phone),
                  ),
                  const SizedBox(width: 12),
                  _buildDesktopActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    color: const Color(0xFF2563EB),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      CurvedNavigationBarView.supportNavigation.value = SupportNavigationData(
                        orderId: state.orderId,
                        sellerId: profile.id,
                        sellerName: profile.name,
                        buyerName: '',
                        sellerImageUrl: profile.imageUrl,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePhoneCall(BuildContext context, String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number provided')));
      return;
    }

    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phone: $phone',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Copy to clipboard',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: phone));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    }
  }

  Widget _buildActionSquare(IconData icon, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 16),
        _buildOrderItemsList(),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
        const SizedBox(height: 16),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    if (order == null) return const SizedBox.shrink();
    return Column(
      children: order!.items.map((item) {
        final heroTag = 'track_order_${order!.id}_item_${item.id}';
        final imageUrl =
            item.image ??
            'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => GestureDetector(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  Widget _buildPaymentSummary() {
    if (order == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${order!.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE52121),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TrackOrderBloc>().add(
                RefreshTrackOrder(
                  orderId: order?.id ?? 'FG125678',
                  orderDate: order?.date ?? DateTime.now(),
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
