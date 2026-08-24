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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/order_status.dart';
import '../../../core/services/map_marker_service.dart';
import '../../../core/services/arrival_alert_service.dart';
import '../../../core/widgets/app_google_map_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/shimmer_loader.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

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
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );

    return BlocListener<TrackOrderBloc, TrackOrderState>(
      listenWhen: (previous, current) {
        if (current is TrackOrderLoaded) {
          if (previous is! TrackOrderLoaded) return current.isArrivingSoon;
          return !previous.isArrivingSoon && current.isArrivingSoon;
        }
        return false;
      },
      listener: (context, state) {
        if (state is TrackOrderLoaded && state.isArrivingSoon) {
          final isTamil = Localizations.localeOf(context).languageCode == 'ta';
          ArrivalAlertService.instance.triggerArrivalAlert(
            context: context,
            orderId: state.orderId,
            partnerName: state.deliveryPartner.name,
            isTamil: isTamil,
          );
        }
      },
      child: isEmbedded
          ? Container(color: Colors.white, child: content)
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: false,
                titleSpacing: 0,
                leading: Navigator.canPop(context)
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
            ),
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
                  foregroundColor: BuyerAppColors.primaryDeep,
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
    String selectedReason = 'Changed my mind';
    final reasons = ['Changed my mind', 'Ordered by mistake', 'Long delivery time', 'Other'];

    final isPaid = state.paymentMethod.toLowerCase() == 'wallet' ||
        state.paymentMethod.toLowerCase() == 'razorpay' ||
        state.paymentMethod.toLowerCase() == 'online' ||
        state.paymentStatus.toLowerCase() == 'paid';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Are you sure you want to cancel this order?',
                      style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 14),

                    // Refund Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPaid ? const Color(0xFFA7F3D0) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPaid ? Icons.account_balance_wallet_rounded : Icons.info_outline_rounded,
                            color: isPaid ? const Color(0xFF059669) : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isPaid
                                  ? '🎉 100% Instant Refund of ₹${state.totalAmount.toStringAsFixed(0)} will be credited to your Wallet.'
                                  : 'ℹ️ Cash on Delivery: No payment collected, ₹0 deducted.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isPaid ? const Color(0xFF065F46) : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Reason for cancellation:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: reasons.map((reason) {
                        final isSelected = selectedReason == reason;
                        return ChoiceChip(
                          label: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF4B5563),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFDC2626),
                          backgroundColor: const Color(0xFFF3F4F6),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedReason = reason;
                                if (reason != 'Other') {
                                  reasonController.text = reason;
                                } else {
                                  reasonController.clear();
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    if (selectedReason == 'Other') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Please specify your reason...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Keep Order', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    final finalReason = reasonController.text.trim().isNotEmpty
                        ? reasonController.text.trim()
                        : selectedReason;
                    context.read<TrackOrderBloc>().add(
                          CancelOrderEvent(state.orderId, reason: finalReason),
                        );
                  },
                  child: const Text('Confirm Cancellation', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
      color = BuyerAppColors.primaryDeep;
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
                              : (isCancelled ? BuyerAppColors.primaryDeep : const Color(0xFF1C1C1C)),
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
          color: BuyerAppColors.primaryDeep,
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
      sellerName: state.sellerInfo?.name ?? 'Restaurant',
      customerName: state.customerInfo?.name ?? 'Customer',
      vehicleType: state.deliveryPartner.vehicleType,
      isPickedUp: state.status == OrderStatus.outForDelivery || state.status == OrderStatus.delivered,
      etaLabel: state.estimatedDelivery,
      distanceLabel: _distanceLabel(state),
      distanceKm: state.distanceKm,
      driverSpeed: state.driverSpeed,
      expectedDeliveryTime: state.expectedDeliveryTime,
      isRaining: state.isRaining,
      weatherAlert: state.weatherAlert,
      progressRatio: state.progressRatio,
      isArrivingSoon: state.isArrivingSoon,
      isExpanded: state.isMapExpanded,
      hasRoute: hasRoute,
      driverName: state.deliveryPartner.name,
      driverPhone: state.deliveryPartner.phone,
      driverPhotoUrl: state.deliveryPartner.imageUrl,
      driverVehicleNumber: state.deliveryPartner.vehicleNumber,
      driverRating: state.deliveryPartner.rating,
      storePhone: state.sellerInfo?.phone,
      storeAddress: state.sellerInfo?.address,
      customerAddress: state.customerInfo?.deliveryAddress,
      customerNotes: state.customerInfo?.deliveryNotes,
      onCallDriver: () {
        if (state.deliveryPartner.phone.isNotEmpty) {
          _handlePhoneCall(context, state.deliveryPartner.phone);
        }
      },
      onChatDriver: () => _navigateToDeliveryChat(context, state),
      onCallStore: () {
        if (state.sellerInfo?.phone.isNotEmpty == true) {
          _handlePhoneCall(context, state.sellerInfo!.phone);
        }
      },
      onToggleFullscreen: () =>
          context.read<TrackOrderBloc>().add(const ToggleMapFullScreen()),
      onOpenMaps: () => _openMap(context, state),
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

  Future<void> _openMap(BuildContext context, dynamic target, [double? maybeLng]) async {
    if (target is TrackOrderLoaded) {
      final state = target;
      final destLat = state.customerLat ?? 11.4555052;
      final destLng = state.customerLng ?? 77.6873137;
      final originLat = (state.driverLat != null && (state.driverLat != destLat || state.driverLng != destLng))
          ? state.driverLat!
          : (state.sellerLat ?? 11.4299713);
      final originLng = (state.driverLng != null && (state.driverLat != destLat || state.driverLng != destLng))
          ? state.driverLng!
          : (state.sellerLng ?? 77.6759418);

      final dirUri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving');
      try {
        await launchUrl(dirUri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}

      final lat = state.driverLat ?? state.customerLat ?? state.sellerLat;
      final lng = state.driverLng ?? state.customerLng ?? state.sellerLng;

      if (lat != null && lng != null) {
        final searchUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        try {
          await launchUrl(searchUri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
      }

      final address = state.customerInfo?.deliveryAddress ?? state.sellerInfo?.address ?? '189A, Kamaraj Nagar, Kuruppanaickenpalayam, Tamil Nadu 638301';
      final addressUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
      try {
        await launchUrl(addressUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return;
    }

    final double? lat = (target is num) ? target.toDouble() : null;
    final double? lng = maybeLng;

    if (lat != null && lng != null) {
      final coordUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      try {
        await launchUrl(coordUri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }

    final defaultUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=189A,+Kamaraj+Nagar,+Kuruppanaickenpalayam,+Tamil+Nadu+638301');
    try {
      await launchUrl(defaultUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
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
              _buildActionButton(
                icon: Icons.phone_rounded,
                label: _tr(context, 'Call'),
                color: const Color(0xFF16A34A),
                onTap: partner.phone.isNotEmpty
                    ? () => _handlePhoneCall(context, partner.phone)
                    : null,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                label: _tr(context, 'Chat'),
                color: const Color(0xFF2563EB),
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
                _buildActionButton(
                  icon: Icons.phone_rounded,
                  label: _tr(context, 'Call'),
                  color: const Color(0xFF16A34A),
                  onTap: partner.phone.isNotEmpty
                      ? () => _handlePhoneCall(context, partner.phone)
                      : null,
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: _tr(context, 'Chat'),
                  color: const Color(0xFF2563EB),
                  onTap: () => _navigateToDeliveryChat(context, state),
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
      sellerPhone: seller?.phone,
      orderImageUrl: state.orderItems.isNotEmpty ? state.orderItems.first.imageUrl : null,
      orderTitle: state.orderItems.isNotEmpty ? state.orderItems.first.name : null,
      orderTotal: state.totalAmount,
    );
  }

  Widget _buildRestaurantCard(BuildContext context, TrackOrderLoaded state) {
    final profile = state.sellerInfo;
    if (profile == null) return const SizedBox.shrink();
    final isVerified = profile.isVerified;
    final distance = _distanceBetween(state.sellerLat, state.sellerLng, state.customerLat, state.customerLng);
    final openStatus = profile.openStatus?.toString().toLowerCase() == 'closed' ? 'Closed' : 'Open';
    final statusColor = openStatus == 'Closed' ? BuyerAppColors.primaryDeep : const Color(0xFF22C55E);
    final hours = profile.openingHours;
    final isValidHours = hours != null &&
        hours.trim().isNotEmpty &&
        hours.trim() != '{}' &&
        hours.trim() != 'null';

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
                  _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: _tr(context, 'Call'),
                    color: const Color(0xFF16A34A),
                    onTap: profile.phone.isNotEmpty
                        ? () => _handlePhoneCall(context, profile.phone)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    icon: Icons.chat_bubble_rounded,
                    label: _tr(context, 'Chat'),
                    color: const Color(0xFF2563EB),
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
              isValidHours ? '$openStatus • $hours' : openStatus,
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
                  color: BuyerAppColors.primaryDeep.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: BuyerAppColors.primaryDeep, size: 22),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BuyerAppColors.primaryDeep),
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
    return EmptyStateView(
      icon: Icons.error_outline,
      iconColor: BuyerAppColors.primaryDeep,
      title: displayMessage,
      action: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF0F0),
          foregroundColor: BuyerAppColors.primaryDeep,
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
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: SkeletonBox(height: 60, borderRadius: 12),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    String? label,
    VoidCallback? onTap,
    bool compact = false,
  }) {
    final isEnabled = onTap != null;
    final effectiveColor = isEnabled ? color : const Color(0xFF9CA3AF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: label != null && !compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              : const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: label != null && !compact
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: effectiveColor, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: effectiveColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Icon(icon, color: effectiveColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildActionSquare(IconData icon, Color color, {VoidCallback? onTap}) {
    return _buildActionButton(
      icon: icon,
      color: color,
      onTap: onTap,
      compact: true,
    );
  }

  Widget _buildDesktopActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return _buildActionButton(
      icon: icon,
      color: color,
      label: label,
      onTap: onTap,
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

class _LiveTrackingMapCard extends StatelessWidget {
  final double? sellerLat;
  final double? sellerLng;
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;
  final String sellerName;
  final String customerName;
  final String vehicleType;
  final bool isPickedUp;
  final String etaLabel;
  final String distanceLabel;
  final double? distanceKm;
  final double? driverSpeed;
  final String? expectedDeliveryTime;
  final bool isRaining;
  final String? weatherAlert;
  final double progressRatio;
  final bool isArrivingSoon;
  final bool isExpanded;
  final bool hasRoute;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhotoUrl;
  final String? driverVehicleNumber;
  final double? driverRating;
  final String? storePhone;
  final String? storeAddress;
  final String? customerAddress;
  final String? customerNotes;
  final VoidCallback? onCallDriver;
  final VoidCallback? onChatDriver;
  final VoidCallback? onCallStore;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenMaps;

  const _LiveTrackingMapCard({
    super.key,
    required this.sellerLat,
    required this.sellerLng,
    required this.customerLat,
    required this.customerLng,
    required this.driverLat,
    required this.driverLng,
    this.sellerName = 'Restaurant',
    this.customerName = 'Customer',
    this.vehicleType = 'two_wheeler',
    this.isPickedUp = false,
    required this.etaLabel,
    required this.distanceLabel,
    this.distanceKm,
    this.driverSpeed,
    this.expectedDeliveryTime,
    this.isRaining = false,
    this.weatherAlert,
    this.progressRatio = 0.0,
    this.isArrivingSoon = false,
    required this.isExpanded,
    required this.hasRoute,
    this.driverName,
    this.driverPhone,
    this.driverPhotoUrl,
    this.driverVehicleNumber,
    this.driverRating,
    this.storePhone,
    this.storeAddress,
    this.customerAddress,
    this.customerNotes,
    this.onCallDriver,
    this.onChatDriver,
    this.onCallStore,
    required this.onToggleFullscreen,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final etaParts = distanceLabel.isNotEmpty
        ? '$etaLabel • $distanceLabel'
        : etaLabel;

    final storeLoc = (sellerLat != null && sellerLng != null) ? LatLng(sellerLat!, sellerLng!) : null;
    final driverLoc = (driverLat != null && driverLng != null) ? LatLng(driverLat!, driverLng!) : null;
    final customerLoc = (customerLat != null && customerLng != null) ? LatLng(customerLat!, customerLng!) : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final double cardHeight = isExpanded
        ? (isDesktop ? 540.0 : 480.0)
        : (isDesktop ? 390.0 : 370.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppGoogleMapView(
              storeLocation: storeLoc,
              storeName: sellerName,
              driverLocation: driverLoc,
              customerLocation: customerLoc,
              customerName: customerName,
              vehicleType: vehicleType,
              isPickedUp: isPickedUp,
              isFullScreen: isExpanded,
              onToggleFullScreen: onToggleFullscreen,
              showControls: true,
              autoFollowDriver: true,
              bottomBadgeOffset: driverLoc == null ? 72.0 : 12.0,
              progressRatio: progressRatio,
              etaText: etaLabel,
              distanceKm: distanceKm,
              driverSpeed: driverSpeed,
              expectedDeliveryTime: expectedDeliveryTime,
              isArrivingSoon: isArrivingSoon,
              isRaining: isRaining,
              weatherAlert: weatherAlert,
              onOpenExternalNavigation: onOpenMaps,
              driverName: driverName,
              driverPhone: driverPhone,
              driverPhotoUrl: driverPhotoUrl,
              driverVehicleNumber: driverVehicleNumber,
              driverRating: driverRating,
              storePhone: storePhone,
              storeAddress: storeAddress,
              customerAddress: customerAddress,
              customerNotes: customerNotes,
              onCallDriver: onCallDriver,
              onChatDriver: onChatDriver,
              onCallStore: onCallStore,
            ),
          ),
          if (driverLoc == null)
            Positioned(
              bottom: 12,
              left: 12,
              right: 64,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: BuyerAppColors.primaryDeep,
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
                            sellerName.isNotEmpty ? sellerName : 'Restaurant',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            'Order placed · Live partner will be tracked once assigned',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
            right: 68,
            child: Align(
              alignment: Alignment.topLeft,
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
                    Icon(
                      MapMarkerService.isTwoWheeler(vehicleType)
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_filled_rounded,
                      color: BuyerAppColors.primaryDeep,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        etaParts,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
