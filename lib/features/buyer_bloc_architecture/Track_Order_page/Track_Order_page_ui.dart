import 'dart:math' as math;
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
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_user_profile_repository.dart';
import '../Chat_Page/invoice_generator.dart';
import 'package:printing/printing.dart';

String _tr(BuildContext context, String key) {
  final isTamil = Localizations.localeOf(context).languageCode == 'ta';
  final tamil = _tamilStrings[key];
  return isTamil && tamil != null ? tamil : key;
}

const Map<String, String> _tamilStrings = {
  'Track Order': 'ஆர்டர் கண்காணிப்பு',
  'Tracking Status': 'கண்காணிப்பு நிலை',
  'Delivery Partner': 'டெலிவரி பார்ட்னர்',
  'Restaurant Information': 'உணவக தகவல்',
  'Customer Address': 'வாடிக்கையாளர் முகவரி',
  'Order Details': 'ஆர்டர் விவரங்கள்',
  'Order ID': 'ஆர்டர் ஐடி',
  'Date & Time': 'தேதி & நேரம்',
  'Estimated Delivery': 'மதிப்பிடப்பட்ட டெலிவரி',
  'Cancel Order': 'ஆர்டரை ரத்து செய்',
  'Download Invoice': 'இன்வாய்ஸ் பதிவிறக்கு',
  'Call': 'அழை',
  'Chat': 'அரட்டை',
  'Order Placed': 'ஆர்டர் வைக்கப்பட்டது',
  'Accepted': 'ஏற்கப்பட்டது',
  'Preparing Your Food': 'உணவு தயாராகிறது',
  'Out for Delivery': 'டெலிவரிக்கு புறப்பட்டது',
  'Delivered': 'வழங்கப்பட்டது',
  'Order Cancelled': 'ஆர்டர் ரத்து செய்யப்பட்டது',
  'In progress': 'நடைபெறுகிறது',
  'Upcoming': 'வரவிருக்கிறது',
  'Open in Maps': 'மேப்பில் திற',
  'View on map': 'மேப்பில் பார்',
  'Looking for a delivery partner...': 'டெலிவரி பார்ட்னரை தேடுகிறோம்...',
  'Assigning a delivery partner...': 'டெலிவரி பார்ட்னர் ஒதுக்கப்படுகிறது...',
  'Order Summary': 'ஆர்டர் சுருக்கம்',
  'Order Information': 'ஆர்டர் தகவல்',
  'Bill Details': 'பில் விவரங்கள்',
  'Items': 'பொருட்கள்',
  'Item': 'பொருள்',
  'Item Total': 'பொருட்களின் மொத்தம்',
  'Delivery Fee': 'டெலிவரி கட்டணம்',
  'Taxes & Charges': 'வரிகள் & கட்டணங்கள்',
  'Platform Fee': 'பிளாட்பார்ம் கட்டணம்',
  'Discount': 'தள்ளுபடி',
  'Order ID copied': 'ஆர்டர் ஐடி நகலெடுக்கப்பட்டது',
  'Copy Order ID': 'ஆர்டர் ஐடியை நகலெடுக்கவும்',
};

class TrackOrderPageUI extends StatelessWidget {
  final String orderId;
  final OrderViewModel? order;
  final bool isEmbedded;
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
          create: (context) => TrackOrderBloc(
            repository: TrackOrderRepositoryImpl(
              service: TrackOrderService(firestore: FirebaseFirestore.instance),
            ),
            orderRepository: context.read<IOrderRepository>(),
            trackService: TrackOrderService(firestore: FirebaseFirestore.instance),
          )..add(
              LoadTrackOrderDetails(
                orderId: orderId,
                orderDate: order?.date ?? DateTime.now(),
              ),
            ),
        ),
        BlocProvider(
          create: (context) => UserProfileBloc(
            authService: context.read<IAuthService>(),
            profileRepository: context.read<IUserProfileRepository>(),
          )..add(const LoadProfileStarted()),
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
        centerTitle: false,
        titleSpacing: 0,
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          _tr(context, 'Track Order'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1C1C),
          ),
        ),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildCancelButton(BuildContext context, TrackOrderLoaded state) {
    if (state.isCancelled || state.isDelivered) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showCancelConfirmation(context, state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  foregroundColor: const Color(0xFFE52121),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _tr(context, 'Cancel Order'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, TrackOrderLoaded state) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this order?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Reason for cancellation (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep Order'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52121),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TrackOrderBloc>().add(
                      CancelOrderEvent(state.orderId, reason: reasonController.text.trim()),
                    );
              },
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 96.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderInfoCard(context, state),
                      const SizedBox(height: 20),
                      _buildLiveMapCard(context, state),
                      const SizedBox(height: 20),
                      _buildTimelineCard(context, state),
                      const SizedBox(height: 20),
                      _buildDeliveryPartnerCard(context, state),
                      const SizedBox(height: 20),
                      _buildRestaurantCard(context, state),
                      const SizedBox(height: 20),
                      _buildCustomerAddressCard(context, state),
                      const SizedBox(height: 20),
                      _buildOrderSummaryCard(context, state),
                    ],
                  ),
                ),
              ),
              _buildCancelButton(context, state),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 96.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  Text(
                                    _tr(context, 'Order Details'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C1C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildHeaderInfo(context, state),
                                  const SizedBox(height: 24),
                                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                                  const SizedBox(height: 24),
                                  _buildOrderSummary(context, state, isDesktop: true),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLiveMapCard(context, state),
                                const SizedBox(height: 24),
                                Container(
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
                                      Text(
                                        _tr(context, 'Tracking Status'),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1C1C1C),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildTimeline(context, state.trackingSteps),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDesktopDeliveryPartnerCard(context, state),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildRestaurantCard(context, state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCustomerAddressCard(context, state)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildCancelButton(context, state),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderInfo(BuildContext context, TrackOrderLoaded state) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = order != null ? dateFormat.format(order!.date) : dateFormat.format(state.orderDate);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(context, 'Order ID'),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${state.orderId.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 4),
                _buildCopyOrderIdButton(context, state),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(context, 'Date & Time'),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(context, 'Estimated Delivery'),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              state.estimatedDelivery,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(context, 'Tracking Status'),
              style: const TextStyle(color: Colors.black54, fontSize:14),
            ),
            _buildStatusChip(state),
          ],
        ),
      ],
    );
  }

  Widget _buildCopyOrderIdButton(BuildContext context, TrackOrderLoaded state) {
    return IconButton(
      icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF6B7280)),
      tooltip: _tr(context, 'Copy Order ID'),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: '#${state.orderId.toUpperCase()}'));
        HapticFeedback.mediumImpact();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(_tr(context, 'Order ID copied')),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, TrackOrderLoaded state) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Order Information'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeaderInfo(context, state),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, TrackOrderLoaded state) {
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
      child: _buildOrderSummary(context, state),
    );
  }

  Widget _buildStatusChip(TrackOrderLoaded state) {
    final Color color;
    if (state.isCancelled) {
      color = const Color(0xFFE52121);
    } else if (state.isDelivered) {
      color = const Color(0xFF22C55E);
    } else {
      color = const Color(0xFF2563EB);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        state.orderStatusLabel,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, TrackOrderLoaded state) {
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
          Text(
            _tr(context, 'Tracking Status'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 24),
          _buildTimeline(context, state.trackingSteps),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<TrackingStep> steps) {
    return Column(
      children: [
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          bool isLast = idx == steps.length - 1;
          return _buildTimelineNode(context, step, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineNode(BuildContext context, TrackingStep step, bool isLast) {
    final isCompleted = step.status == TrackingStatus.completed;
    final isCurrent = step.status == TrackingStatus.current;
    final isFuture = step.status == TrackingStatus.future;
    final isCancelled = step.status == TrackingStatus.cancelled;

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
                        _tr(context, step.title),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isFuture
                              ? Colors.grey.shade400
                              : (isCancelled ? const Color(0xFFE52121) : const Color(0xFF1C1C1C)),
                        ),
                      ),
                      if (step.time != null)
                        Text(
                          isFuture ? _tr(context, 'Upcoming') : step.time!,
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
                        _tr(context, 'In progress'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF22C55E),
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
    } else if (status == TrackingStatus.cancelled) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFE52121),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 14),
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

  Widget _buildLiveMapCard(BuildContext context, TrackOrderLoaded state) {
    final hasRoute = (state.sellerLat != null && state.sellerLng != null) ||
        (state.customerLat != null && state.customerLng != null) ||
        (state.driverLat != null && state.driverLng != null);

    return _LiveTrackingMapCard(
      sellerLat: state.sellerLat,
      sellerLng: state.sellerLng,
      customerLat: state.customerLat,
      customerLng: state.customerLng,
      driverLat: state.driverLat,
      driverLng: state.driverLng,
      etaLabel: state.estimatedDelivery,
      distanceLabel: _distanceLabel(state),
      isExpanded: state.isMapExpanded,
      hasRoute: hasRoute,
      onToggleFullscreen: () =>
          context.read<TrackOrderBloc>().add(const ToggleMapFullScreen()),
      onOpenMaps: () => _openMap(context, state.driverLat ?? state.sellerLat, state.driverLng ?? state.sellerLng),
    );
  }

  String _distanceLabel(TrackOrderLoaded state) {
    final lat1 = state.driverLat ?? state.sellerLat;
    final lng1 = state.driverLng ?? state.sellerLng;
    if (lat1 == null || lng1 == null || state.customerLat == null || state.customerLng == null) {
      return '';
    }
    final km = _haversineKm(lat1, lng1, state.customerLat!, state.customerLng!);
    return '${km.toStringAsFixed(1)} km';
  }

  Future<void> _openMap(BuildContext context, double? lat, double? lng) async {
    if (lat == null || lng == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not available yet')),
        );
      }
      return;
    }

    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDeliveryPartnerCard(BuildContext context, TrackOrderLoaded state) {
    final partner = state.deliveryPartner;
    final hasDriver = partner.name.isNotEmpty;

    if (!hasDriver) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _tr(context, 'Looking for a delivery partner...'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final vehicle = [partner.vehicleType, partner.vehicleNumber]
        .where((e) => e.isNotEmpty)
        .join(' • ');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Delivery Partner'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[200],
                backgroundImage: partner.imageUrl.isNotEmpty
                    ? NetworkImage(partner.imageUrl)
                    : null,
                child: partner.imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 26)
                    : null,
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
                            partner.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF1C1C1C),
                            ),
                          ),
                        ),
                        if (partner.rating != null) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 2),
                          Text(
                            partner.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partner.role,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (vehicle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
          Column(
            children: [
              _buildActionSquare(
                Icons.call,
                const Color(0xFF22C55E),
                onTap: partner.phone.isNotEmpty
                    ? () => _handlePhoneCall(context, partner.phone)
                    : null,
              ),
              const SizedBox(height: 10),
              _buildActionSquare(
                Icons.message,
                const Color(0xFF2563EB),
                onTap: () => _navigateToDeliveryChat(context, state),
              ),
            ],
          ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDeliveryChat(BuildContext context, TrackOrderLoaded state) {
    final partner = state.deliveryPartner;
    final riderId = order?.riderId;
    if (riderId == null || riderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery partner not available yet')),
      );
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    CurvedNavigationBarView.supportNavigation.value = SupportNavigationData(
      orderId: state.orderId,
      sellerId: '',
      sellerName: '',
      buyerName: '',
      deliveryPartnerId: riderId,
      deliveryPartnerName: partner.name,
      deliveryPartnerPhone: partner.phone,
      deliveryPartnerImageUrl: partner.imageUrl,
      orderTitle: state.orderItems.isNotEmpty
          ? state.orderItems.first.name
          : null,
      orderTotal: state.totalAmount,
    );
  }

  Widget _buildDesktopDeliveryPartnerCard(BuildContext context, TrackOrderLoaded state) {
    final partner = state.deliveryPartner;
    final hasDriver = partner.name.isNotEmpty;
    final vehicle = [partner.vehicleType, partner.vehicleNumber]
        .where((e) => e.isNotEmpty)
        .join(' • ');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Delivery Partner'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 16),
          if (!hasDriver)
            Row(
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _tr(context, 'Assigning a delivery partner...'),
                    style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: partner.imageUrl.isNotEmpty
                      ? NetworkImage(partner.imageUrl)
                      : null,
                  child: partner.imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 28)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                      Text(
                        partner.role,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (vehicle.isNotEmpty)
                        Text(
                          vehicle,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      if (partner.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                            Text(
                              ' ${partner.rating!.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            if (partner.totalDeliveries != null)
                              Text(
                                '  •  ${partner.totalDeliveries} deliveries',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: _buildDesktopActionButton(
                    icon: Icons.call,
                    label: 'Call',
                    color: const Color(0xFF22C55E),
                    onTap: partner.phone.isNotEmpty
                        ? () => _handlePhoneCall(context, partner.phone)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  height: 60,
                  child: _buildDesktopActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: _tr(context, 'Chat'),
                    color: const Color(0xFF2563EB),
                    onTap: () => _navigateToDeliveryChat(context, state),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openSupportChat(BuildContext context, TrackOrderLoaded state) {
    final seller = state.sellerInfo;
    CurvedNavigationBarView.supportNavigation.value = SupportNavigationData(
      orderId: state.orderId,
      sellerId: seller?.id ?? '',
      sellerName: seller?.name ?? 'Restaurant',
      buyerName: state.customerInfo?.name ?? '',
      shopName: seller?.name ?? '',
      sellerImageUrl: seller?.imageUrl ?? '',
    );
  }

  Widget _buildRestaurantCard(BuildContext context, TrackOrderLoaded state) {
    final profile = state.sellerInfo;
    if (profile == null) return const SizedBox.shrink();
    final isVerified = profile.isVerified;
    final distance = _distanceBetween(state.sellerLat, state.sellerLng, state.customerLat, state.customerLng);
    final openStatus = profile.openStatus?.toString().toLowerCase() == 'closed' ? 'Closed' : 'Open';
    final statusColor = openStatus == 'Closed' ? const Color(0xFFE52121) : const Color(0xFF22C55E);
    final hours = profile.openingHours;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Restaurant Information'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 16),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name : 'Restaurant',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: const Color(0xFF1C1C1C),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 20,
                            color: Color(0xFF22C55E),
                          ),
                        ],
                      ],
                    ),
                    if (profile.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              profile.address,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6B7280),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (distance != null)
                          Text(
                            '${distance.toStringAsFixed(1)} km  •  ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => _openMap(context, profile.lat, profile.lng),
                          child: Text(
                            _tr(context, 'View on map'),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF2563EB),
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
              Column(
                children: [
                  _buildActionSquare(
                    Icons.call,
                    const Color(0xFF22C55E),
                    onTap: profile.phone.isNotEmpty
                        ? () => _handlePhoneCall(context, profile.phone)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _buildActionSquare(
                    Icons.message,
                    const Color(0xFF2563EB),
                    onTap: () => _openSupportChat(context, state),
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
              hours != null ? '$openStatus • $hours' : openStatus,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAddressCard(BuildContext context, TrackOrderLoaded state) {
    final customer = state.customerInfo;
    final name = customer?.name ?? order?.customerName ?? '';
    final phone = customer?.phone ?? order?.customerPhone ?? '';
    final address = customer?.deliveryAddress ?? order?.deliveryAddress ?? '';
    final notes = customer?.deliveryNotes ?? '';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Customer Address'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE52121).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: Color(0xFFE52121), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    const SizedBox(height: 4),
                    if (address.isNotEmpty)
                      Text(
                        address,
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Instructions: $notes',
                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, TrackOrderLoaded state, {bool isDesktop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _tr(context, 'Order Summary'),
              style: TextStyle(
                fontSize: isDesktop ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(width: 10),
            _buildItemCountPill(context, state),
          ],
        ),
        const SizedBox(height: 16),
        _buildOrderItemsList(context, state),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
        const SizedBox(height: 16),
        _buildPaymentSummary(context, state),
        const SizedBox(height: 24),
        _buildDownloadInvoiceButton(context, state),
      ],
    );
  }

  int _totalItemCount(TrackOrderLoaded state) {
    if (state.orderItems.isNotEmpty) {
      return state.orderItems.fold<int>(0, (int sum, item) => sum + item.quantity);
    }
    return order?.items.fold<int>(0, (int sum, item) => sum + item.quantity) ?? 0;
  }

  Widget _buildItemCountPill(BuildContext context, TrackOrderLoaded state) {
    final count = _totalItemCount(state);
    if (count <= 0) return const SizedBox.shrink();
    final label = count == 1 ? '1 ${_tr(context, 'Item')}' : '$count ${_tr(context, 'Items')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildOrderItemsList(BuildContext context, TrackOrderLoaded state) {
    if (state.orderItems.isNotEmpty) {
      return Column(
        children: state.orderItems.map((item) {
          final heroTag = 'track_order_${state.orderId}_item_${item.id}';
          final imageUrl = item.imageUrl ?? '';
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
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood, color: Colors.grey, size: 32),
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

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
                          child: const Icon(Icons.fastfood, color: Colors.grey, size: 32),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl, String heroTag) {
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

  Widget _buildPaymentSummary(BuildContext context, TrackOrderLoaded state) {
    if (order == null && state.totalAmount <= 0 && state.orderItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final paymentMethod = state.paymentMethod.isNotEmpty ? state.paymentMethod : order?.paymentMethod ?? '';
    final paymentStatus = state.paymentStatus.isNotEmpty ? state.paymentStatus : order?.paymentStatus ?? '';
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    final subtotal = state.subtotal ?? order?.subtotal;
    final deliveryFee = state.deliveryFee ?? order?.deliveryFee;
    final taxAmount = state.taxAmount ?? order?.taxAmount;
    final platformFee = state.platformFee ?? order?.platformFee;
    final discountAmount = state.discountAmount ?? order?.discountAmount;
    final couponCode = order?.couponCode;
    final totalAmount = state.totalAmount > 0 ? state.totalAmount : (order?.totalAmount ?? 0.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Method', style: TextStyle(fontSize: 14, color: Colors.black54)),
            Row(
              children: [
                Icon(
                  paymentMethod.toUpperCase() == 'RAZORPAY'
                      ? Icons.credit_card_rounded
                      : (paymentMethod.toUpperCase() == 'WALLET'
                          ? Icons.account_balance_wallet_outlined
                          : Icons.payments_outlined),
                  size: 16,
                  color: const Color(0xFF1C1C1C),
                ),
                const SizedBox(width: 6),
                Text(
                  paymentMethod.isEmpty ? 'COD' : paymentMethod,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Status', style: TextStyle(fontSize: 14, color: Colors.black54)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  width: 0.8,
                ),
              ),
              child: Text(
                paymentStatus.isEmpty ? 'Pending' : paymentStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1),
        ),
        if (subtotal != null) _buildCostRow(context, 'Item Total', '₹${subtotal.toStringAsFixed(2)}'),
        if (deliveryFee != null) _buildCostRow(context, 'Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
        if (taxAmount != null) _buildCostRow(context, 'Taxes & Charges', '₹${taxAmount.toStringAsFixed(2)}'),
        if (platformFee != null) _buildCostRow(context, 'Platform Fee', '₹${platformFee.toStringAsFixed(2)}'),
        if (discountAmount != null && discountAmount > 0)
          _buildCostRow(
            context,
            couponCode != null && couponCode.isNotEmpty
                ? '${_tr(context, 'Discount')} ($couponCode)'
                : _tr(context, 'Discount'),
            '-₹${discountAmount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF15803D),
          ),
        if (subtotal != null || deliveryFee != null || taxAmount != null || platformFee != null || discountAmount != null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE52121)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_tr(context, label), style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1C1C1C)),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadInvoiceButton(BuildContext context, TrackOrderLoaded state) {
    if (order == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            final pdfBytes = await InvoiceGenerator.generateInvoice(
              orderId: order!.id,
              buyerName: state.customerInfo?.name.isNotEmpty == true ? state.customerInfo!.name : 'Customer',
              sellerName: state.sellerInfo?.name ?? 'Restaurant',
              shopName: state.sellerInfo?.name ?? 'Restaurant',
              totalAmount: state.totalAmount > 0 ? state.totalAmount : order!.totalAmount,
              date: order!.date,
              items: order!.items.map((i) => {
                'name': i.name,
                'qty': i.quantity,
                'price': i.price,
              }).toList(),
              subtotal: order!.subtotal,
              deliveryFee: order!.deliveryFee,
              taxAmount: order!.taxAmount,
              discountAmount: order!.discountAmount,
              couponCode: order!.couponCode,
              platformFee: order!.platformFee,
            );

            await Printing.sharePdf(
              bytes: pdfBytes,
              filename: 'invoice_${order!.id.substring(0, 8)}.pdf',
            );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to generate invoice: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.receipt_long_outlined, size: 20),
        label: Text(
          _tr(context, 'Download Invoice'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2563EB),
          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final displayMessage = message.contains('permission-denied')
        ? 'Unable to load live tracking details due to permission limits. Please retry.'
        : message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE52121), size: 48),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFE52121), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F0),
                foregroundColor: const Color(0xFFE52121),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
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

  Future<void> _handlePhoneCall(BuildContext context, String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number provided')));
      return;
    }

    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.phone_android_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Phone: $phone', style: const TextStyle(fontSize: 15)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
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

  Widget _buildDesktopActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
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

  double? _distanceBetween(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) return null;
    return _haversineKm(lat1, lng1, lat2, lng2);
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * math.pi / 180;
}

class _LiveTrackingMapCard extends StatefulWidget {
  final double? sellerLat;
  final double? sellerLng;
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;
  final String etaLabel;
  final String distanceLabel;
  final bool isExpanded;
  final bool hasRoute;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenMaps;

  const _LiveTrackingMapCard({
    required this.sellerLat,
    required this.sellerLng,
    required this.customerLat,
    required this.customerLng,
    required this.driverLat,
    required this.driverLng,
    required this.etaLabel,
    required this.distanceLabel,
    required this.isExpanded,
    required this.hasRoute,
    required this.onToggleFullscreen,
    required this.onOpenMaps,
  });

  @override
  State<_LiveTrackingMapCard> createState() => _LiveTrackingMapCardState();
}

class _LiveTrackingMapCardState extends State<_LiveTrackingMapCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() => setState(() => _zoom = (_zoom + 0.25).clamp(0.5, 3.0));

  void _zoomOut() => setState(() => _zoom = (_zoom - 0.25).clamp(0.5, 3.0));

  void _recenter() => setState(() => _zoom = 1.0);

  @override
  Widget build(BuildContext context) {
    final etaParts = widget.distanceLabel.isNotEmpty
        ? '${widget.etaLabel} • ${widget.distanceLabel}'
        : widget.etaLabel;

    return Container(
      height: widget.isExpanded ? 460 : 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiveTrackingMapPainter(
                    sellerLat: widget.sellerLat,
                    sellerLng: widget.sellerLng,
                    customerLat: widget.customerLat,
                    customerLng: widget.customerLng,
                    driverLat: widget.driverLat,
                    driverLng: widget.driverLng,
                    zoom: _zoom,
                    pulse: _pulseController.value,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          if (!widget.hasRoute)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Live map will appear once a delivery partner is assigned.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delivery_dining, color: Color(0xFFE52121), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    etaParts,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _mapControl(Icons.add, _zoomIn),
                const SizedBox(height: 8),
                _mapControl(Icons.remove, _zoomOut),
                const SizedBox(height: 8),
                _mapControl(Icons.my_location, _recenter),
                const SizedBox(height: 8),
                _mapControl(
                  widget.isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                  widget.onToggleFullscreen,
                ),
                const SizedBox(height: 8),
                _mapControl(Icons.navigation, widget.onOpenMaps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControl(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: const Color(0xFF1C1C1C)),
        ),
      ),
    );
  }
}

class _LiveTrackingMapPainter extends CustomPainter {
  final double? sellerLat;
  final double? sellerLng;
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;
  final double zoom;
  final double pulse;

  _LiveTrackingMapPainter({
    required this.sellerLat,
    required this.sellerLng,
    required this.customerLat,
    required this.customerLng,
    required this.driverLat,
    required this.driverLng,
    required this.zoom,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintRoads(canvas, size);

    Offset? _project(double? lat, double? lng) {
      if (lat == null || lng == null) return null;
      return _projectPoint(lat, lng, size);
    }

    final seller = _project(sellerLat, sellerLng);
    final customer = _project(customerLat, customerLng);
    final driver = _project(driverLat, driverLng);

    // Draw dashed route from seller -> customer (or driver -> customer).
    Offset? start = seller ?? driver;
    Offset? end = customer;
    if (start != null && end != null) {
      _paintDashedRoute(canvas, start, end);
    }

    if (seller != null) _paintSellerMarker(canvas, seller);
    if (customer != null) _paintCustomerMarker(canvas, customer);
    if (driver != null) _paintDriverMarker(canvas, driver);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.7;
    const spacing = 40.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintRoads(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), roadPaint);
    final roadLine = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), roadLine);
  }

  Offset _projectPoint(double lat, double lng, Size size) {
    final lats = <double>[];
    final lngs = <double>[];
    void add(double? la, double? lo) {
      if (la != null) lats.add(la);
      if (lo != null) lngs.add(lo);
    }

    add(sellerLat, sellerLng);
    add(customerLat, customerLng);
    add(driverLat, driverLng);

    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min);
    final maxLng = lngs.reduce(math.max);

    final latRange = ((maxLat - minLat) / zoom).abs() < 1e-6 ? 0.05 : ((maxLat - minLat) / zoom).abs();
    final lngRange = ((maxLng - minLng) / zoom).abs() < 1e-6 ? 0.05 : ((maxLng - minLng) / zoom).abs();
    final midLat = (minLat + maxLat) / 2;
    final midLng = (minLng + maxLng) / 2;
    final effMinLat = midLat - latRange / 2;
    final effMaxLat = midLat + latRange / 2;
    final effMinLng = midLng - lngRange / 2;
    final effMaxLng = midLng + lngRange / 2;

    const padding = 40.0;
    final usableW = size.width - padding * 2;
    final usableH = size.height - padding * 2;
    final x = padding + (lng - effMinLng) / (effMaxLng - effMinLng) * usableW;
    final y = padding + (effMaxLat - lat) / (effMaxLat - effMinLat) * usableH;
    return Offset(x, y);
  }

  void _paintDashedRoute(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    const dash = 10.0;
    const gap = 8.0;
    double covered = 0;
    while (covered < distance) {
      final segEnd = math.min(covered + dash, distance);
      canvas.drawLine(
        start + direction * covered,
        start + direction * segEnd,
        paint,
      );
      covered += dash + gap;
    }
  }

  void _paintSellerMarker(Canvas canvas, Offset pos) {
    final paint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(pos, 12, paint);
    canvas.drawCircle(pos, 16, Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.2));
  }

  void _paintCustomerMarker(Canvas canvas, Offset pos) {
    final paint = Paint()..color = const Color(0xFFE52121);
    canvas.drawCircle(pos, 10, paint);
    canvas.drawCircle(pos, 14, Paint()..color = const Color(0xFFE52121).withValues(alpha: 0.2));
  }

  void _paintDriverMarker(Canvas canvas, Offset pos) {
    final pulseRadius = 12 + pulse * 18;
    canvas.drawCircle(
      pos,
      pulseRadius,
      Paint()..color = const Color(0xFF2563EB).withValues(alpha: (1 - pulse) * 0.4),
    );
    final paint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(pos, 12, paint);
    canvas.drawCircle(
      pos,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) {
    return oldDelegate.sellerLat != sellerLat ||
        oldDelegate.sellerLng != sellerLng ||
        oldDelegate.customerLat != customerLat ||
        oldDelegate.customerLng != customerLng ||
        oldDelegate.driverLat != driverLat ||
        oldDelegate.driverLng != driverLng ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pulse != pulse;
  }
}
