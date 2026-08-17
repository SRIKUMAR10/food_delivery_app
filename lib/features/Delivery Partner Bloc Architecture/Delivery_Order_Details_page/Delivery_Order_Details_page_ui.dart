import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order_Details_page_bloc.dart';
import 'Delivery_Order_Details_page_event.dart';
import 'Delivery_Order_Details_page_state.dart';
import '../auto_hide_app_bar_wrapper.dart';
import '../Delivery_Chat_page/Delivery_Chat_page_ui.dart';
import '../Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_app_spacing.dart';
import '../../../core/widgets/delivery_button.dart';
import '../../../core/widgets/delivery_card.dart';
import '../../../core/widgets/delivery_chip.dart';

class DeliveryOrderDetailsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'ORDER DETAILS & PICKUP',
      'orderInfo': 'ORDER INFORMATION',
      'orderId': 'Order ID',
      'orderDate': 'Order Date',
      'orderTime': 'Order Time',
      'numItems': 'Number of Items',
      'totalAmount': 'Total Amount',
      'paymentMethod': 'Payment Method',
      'paymentStatus': 'Payment Status',
      'earnings': 'Your Earnings',
      'distance': 'Estimated Distance',
      'restaurantInfo': 'RESTAURANT INFORMATION',
      'restaurantName': 'Restaurant Name',
      'restaurantAddress': 'Address',
      'restaurantPhone': 'Phone',
      'restaurantLocation': 'Location',
      'pickupInstructions': 'Pickup Instructions',
      'customerInfo': 'CUSTOMER INFORMATION',
      'customerName': 'Customer Name',
      'customerAddress': 'Delivery Address',
      'customerPhone': 'Phone',
      'customerLocation': 'Location',
      'deliveryInstructions': 'Delivery Instructions',
      'pickupProgress': 'RESTAURANT PICKUP LIFECYCLE',
      'assigned': 'Assigned',
      'goingToRestaurant': 'Going to Store',
      'arrivedAtRestaurant': 'Arrived at Store',
      'pickedUp': 'Picked Up',
      'orderVerification': 'ORDER ITEMS VERIFICATION',
      'verifyAll': 'Verify All Items',
      'verified': 'Verified',
      'unverified': 'Unverified',
      'itemsVerified': 'Items Verified',
      'pickupOtp': 'PICKUP OTP VERIFICATION',
      'enterOtpHint': 'Enter 4-digit pickup code from Seller',
      'verifyOtpBtn': 'VERIFY OTP',
      'otpVerified': 'OTP Verified Successfully',
      'invalidOtp': 'Invalid OTP. Please check with the seller.',
      'navigateBtn': 'NAVIGATE TO STORE',
      'navigateCustomerBtn': 'NAVIGATE TO CUSTOMER',
      'callRestaurant': 'Call Store',
      'chatSeller': 'Chat with Seller',
      'callCustomer': 'Call Customer',
      'startJourney': 'START GOING TO RESTAURANT',
      'markArrived': 'I HAVE ARRIVED AT RESTAURANT',
      'confirmPickup': 'CONFIRM PICKUP & START DELIVERY',
      'orderCompleted': 'ORDER PICKED UP & IN TRANSIT',
      'copied': 'Order ID copied to clipboard',
      'scanQr': 'Scan Seller QR Code',
      'codCashCollection': 'COD CASH COLLECTION',
      'codAmountToCollect': 'COD Amount to Collect',
      'collectCash': 'Collect Cash',
      'cashReceivedTitle': 'Cash Received',
      'receivedAmountLabel': 'Amount Received',
      'changeToReturn': 'Change to return',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'invalidAmount': 'Enter a valid amount',
      'codCollectedSuccess': 'COD cash collected successfully.',
      'codCollectedStatus': 'Cash Collected',
      'amountLessThanCod': 'Amount is less than COD',
      'collectingCod': 'Collecting cash...',
    },
    'ta': {
      'title': 'ஆர்டர் விவரங்கள் மற்றும் எடுப்பு',
      'orderInfo': 'ஆர்டர் தகவல்',
      'orderId': 'ஆர்டர் ஐடி',
      'orderDate': 'ஆர்டர் தேதி',
      'orderTime': 'ஆர்டர் நேரம்',
      'numItems': 'பொருட்களின் எண்ணிக்கை',
      'totalAmount': 'மொத்த தொகை',
      'paymentMethod': 'கட்டண முறை',
      'paymentStatus': 'கட்டண நிலை',
      'earnings': 'உங்கள் வருமானம்',
      'distance': 'மதிப்பிடப்பட்ட தூரம்',
      'restaurantInfo': 'உணவக தகவல்',
      'restaurantName': 'உணவகத்தின் பெயர்',
      'restaurantAddress': 'முகவரி',
      'restaurantPhone': 'தொலைபேசி',
      'restaurantLocation': 'இடம்',
      'pickupInstructions': 'எடுக்கும் வழிமுறைகள்',
      'customerInfo': 'வாடிக்கையாளர் தகவல்',
      'customerName': 'வாடிக்கையாளர் பெயர்',
      'customerAddress': 'டெலிவரி முகவரி',
      'customerPhone': 'தொலைபேசி',
      'customerLocation': 'இடம்',
      'deliveryInstructions': 'டெலிவரி வழிமுறைகள்',
      'pickupProgress': 'உணவக எடுப்பு நிலை',
      'assigned': 'ஒதுக்கப்பட்டது',
      'goingToRestaurant': 'கடைக்கு செல்கிறார்',
      'arrivedAtRestaurant': 'கடைக்கு வந்துவிட்டார்',
      'pickedUp': 'பொருள் எடுக்கப்பட்டது',
      'orderVerification': 'பொருட்கள் சரிபார்ப்பு',
      'verifyAll': 'அனைத்தையும் சரிபார்க்கவும்',
      'verified': 'சரிபார்க்கப்பட்டது',
      'unverified': 'சரிபார்க்கப்படவில்லை',
      'itemsVerified': 'பொருட்கள் சரிபார்க்கப்பட்டது',
      'pickupOtp': 'எடுப்பு OTP சரிபார்ப்பு',
      'enterOtpHint': 'விற்பனையாளரிடமிருந்து 4-இலக்க OTP உள்ளிடவும்',
      'verifyOtpBtn': 'OTP சரிபார்க்கவும்',
      'otpVerified': 'OTP வெற்றிகரமாக சரிபார்க்கப்பட்டது',
      'invalidOtp': 'தவறான OTP. விற்பனையாளரிடம் கேட்கவும்.',
      'navigateBtn': 'கடைக்கு செல்ல வழிகாட்டல்',
      'navigateCustomerBtn': 'வாடிக்கையாளருக்கு வழிகாட்டல்',
      'callRestaurant': 'கடையை அழைக்கவும்',
      'chatSeller': 'விற்பனையாளருடன் அரட்டையடிக்கவும்',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'startJourney': 'கடைக்கு புறப்படுங்கள்',
      'markArrived': 'நான் கடைக்கு வந்துவிட்டேன்',
      'confirmPickup': 'எடுப்பை உறுதி செய்து டெலிவரி தொடங்கவும்',
      'orderCompleted': 'பொருள் எடுக்கப்பட்டு பயணத்தில் உள்ளது',
      'copied': 'ஆர்டர் ஐடி நகலெடுக்கப்பட்டது',
      'scanQr': 'விற்பனையாளர் QR ஸ்கேன் செய்',
      'codCashCollection': 'COD பண வசூல்',
      'codAmountToCollect': 'வசூலிக்க வேண்டிய COD தொகை',
      'collectCash': 'பணம் வசூலிக்கவும்',
      'cashReceivedTitle': 'பணம் பெறப்பட்டது',
      'receivedAmountLabel': 'பெற்ற தொகை',
      'changeToReturn': 'திருப்பித் தர வேண்டிய மீதம்',
      'confirm': 'உறுதிப்படுத்து',
      'cancel': 'ரத்து செய்',
      'invalidAmount': 'சரியான தொகையை உள்ளிடவும்',
      'codCollectedSuccess': 'COD பணம் வெற்றிகரமாக வசூலிக்கப்பட்டது.',
      'codCollectedStatus': 'பணம் வசூலிக்கப்பட்டது',
      'amountLessThanCod': 'தொகை COD தொகையை விட குறைவு',
      'collectingCod': 'பணம் வசூலிக்கப்படுகிறது...',
    },
  };

  static String get(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

class DeliveryOrderDetailsPageUi extends StatefulWidget {
  final String orderId;
  final DeliveryOrderDetailsPageBloc? bloc;

  const DeliveryOrderDetailsPageUi({
    super.key,
    required this.orderId,
    this.bloc,
  });

  @override
  State<DeliveryOrderDetailsPageUi> createState() => _DeliveryOrderDetailsPageUiState();
}

class _DeliveryOrderDetailsPageUiState extends State<DeliveryOrderDetailsPageUi> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    if (widget.bloc != null) {
      return BlocProvider<DeliveryOrderDetailsPageBloc>.value(
        value: widget.bloc!,
        child: _buildScaffold(context, widget.bloc!, isMobile),
      );
    }

    return BlocProvider<DeliveryOrderDetailsPageBloc>(
      create: (context) => DeliveryOrderDetailsPageBloc()
        ..add(FetchOrderDetailsEvent(widget.orderId)),
      child: Builder(
        builder: (context) => _buildScaffold(
          context,
          context.read<DeliveryOrderDetailsPageBloc>(),
          isMobile,
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    bool isMobile,
  ) {
    return BlocBuilder<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      bloc: bloc,
      builder: (context, state) {
        final lang = state.selectedLanguage;
        final appBar = AppBar(
          backgroundColor: DeliveryAppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: DeliveryAppColors.textPrimary),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            },
          ),
          title: Text(
            DeliveryOrderDetailsStrings.get('title', lang),
            style: DeliveryAppTypography.titleMedium.copyWith(
              color: DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          centerTitle: true,
          actions: [
            // Language switch action
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ActionChip(
                backgroundColor: DeliveryAppColors.surfaceLight,
                label: Text(
                  lang == 'en' ? 'தமிழ்' : 'English',
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  final nextLang = lang == 'en' ? 'ta' : 'en';
                  bloc.add(ToggleLanguageEvent(nextLang));
                },
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: DeliveryAppColors.background,
          appBar: isMobile ? null : appBar,
          body: isMobile
              ? AutoHideAppBarWrapper(
                  appBar: appBar,
                  body: _buildBody(context, bloc, state, isMobile),
                  appBarHeight: kToolbarHeight,
                  isMobile: true,
                )
              : _buildBody(context, bloc, state, isMobile),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    DeliveryOrderDetailsPageState state,
    bool isMobile,
  ) {
    if (state.status == OrderDetailsStatus.loading && state.order == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
        ),
      );
    }

    if (state.status == OrderDetailsStatus.error && state.order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: DeliveryAppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred while loading order details.',
                textAlign: TextAlign.center,
                style: DeliveryAppTypography.bodyLarge.copyWith(color: DeliveryAppColors.error),
              ),
              const SizedBox(height: 20),
              DeliveryButton(
                label: 'RETRY',
                onPressed: () {
                  bloc.add(FetchOrderDetailsEvent(widget.orderId));
                },
                variant: DeliveryButtonVariant.primary,
              ),
            ],
          ),
        ),
      );
    }

    final order = state.order ?? OrderModel(id: widget.orderId);
    final lang = state.selectedLanguage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        return SingleChildScrollView(
          padding: EdgeInsets.all(DeliveryAppSpacing.md),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 1200 : 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 8. 🏪 Restaurant Pickup Flow Progress Stepper
                  _buildPickupLifecycleCard(context, bloc, order, lang),
                  const SizedBox(height: 16),

                  if (order.isCOD) ...[
                    _buildCodCollectionCard(context, bloc, order, state, lang),
                    const SizedBox(height: 16),
                  ],

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderInfoCard(context, order, lang),
                              const SizedBox(height: 16),
                              _buildItemsVerificationCard(context, bloc, order, state, lang),
                              const SizedBox(height: 16),
                              if (order.currentPickupStep == PickupFlowStep.arrivedAtRestaurant)
                                _buildPickupOtpCard(context, bloc, order, state, lang),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRestaurantInfoCard(context, bloc, order, lang),
                              const SizedBox(height: 16),
                              _buildCustomerInfoCard(context, bloc, order, lang),
                              const SizedBox(height: 20),
                              _buildDynamicActionBar(context, bloc, order, state, lang),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderInfoCard(context, order, lang),
                        const SizedBox(height: 16),
                        _buildRestaurantInfoCard(context, bloc, order, lang),
                        const SizedBox(height: 16),
                        _buildCustomerInfoCard(context, bloc, order, lang),
                        const SizedBox(height: 16),
                        _buildItemsVerificationCard(context, bloc, order, state, lang),
                        const SizedBox(height: 16),
                        if (order.currentPickupStep == PickupFlowStep.arrivedAtRestaurant) ...[
                          _buildPickupOtpCard(context, bloc, order, state, lang),
                          const SizedBox(height: 16),
                        ],
                        _buildDynamicActionBar(context, bloc, order, state, lang),
                        const SizedBox(height: 32),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 8. 🏪 Restaurant Pickup Flow Progress Stepper
  // -------------------------------------------------------------
  Widget _buildPickupLifecycleCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    String lang,
  ) {
    final currentStep = order.currentPickupStep;

    final steps = [
      {'label': DeliveryOrderDetailsStrings.get('assigned', lang), 'step': PickupFlowStep.assigned, 'icon': Icons.assignment_turned_in},
      {'label': DeliveryOrderDetailsStrings.get('goingToRestaurant', lang), 'step': PickupFlowStep.goingToRestaurant, 'icon': Icons.directions_bike},
      {'label': DeliveryOrderDetailsStrings.get('arrivedAtRestaurant', lang), 'step': PickupFlowStep.arrivedAtRestaurant, 'icon': Icons.storefront},
      {'label': DeliveryOrderDetailsStrings.get('pickedUp', lang), 'step': PickupFlowStep.pickedUp, 'icon': Icons.inventory},
    ];

    int getStepIndex(PickupFlowStep step) {
      switch (step) {
        case PickupFlowStep.assigned:
          return 0;
        case PickupFlowStep.goingToRestaurant:
          return 1;
        case PickupFlowStep.arrivedAtRestaurant:
          return 2;
        case PickupFlowStep.pickedUp:
          return 3;
      }
    }

    final activeIndex = getStepIndex(currentStep);

    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, color: DeliveryAppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    DeliveryOrderDetailsStrings.get('pickupProgress', lang),
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              DeliveryChip(
                variant: currentStep == PickupFlowStep.pickedUp
                    ? DeliveryChipVariant.success
                    : DeliveryChipVariant.info,
                label: order.status.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length, (index) {
              final stepData = steps[index];
              final isPassed = index <= activeIndex;
              final isCurrent = index == activeIndex;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index <= activeIndex
                                  ? DeliveryAppColors.primary
                                  : DeliveryAppColors.border,
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPassed
                                ? DeliveryAppColors.primary
                                : DeliveryAppColors.surfaceLight,
                            border: Border.all(
                              color: isCurrent
                                  ? DeliveryAppColors.primary
                                  : (isPassed ? DeliveryAppColors.primary : DeliveryAppColors.border),
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: DeliveryAppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isPassed && !isCurrent ? Icons.check : (stepData['icon'] as IconData),
                            color: isPassed ? Colors.white : DeliveryAppColors.textMuted,
                            size: 18,
                          ),
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index < activeIndex
                                  ? DeliveryAppColors.primary
                                  : DeliveryAppColors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stepData['label'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DeliveryAppTypography.caption.copyWith(
                        color: isCurrent
                            ? DeliveryAppColors.primary
                            : (isPassed ? DeliveryAppColors.textPrimary : DeliveryAppColors.textMuted),
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. Order Information Card
  // -------------------------------------------------------------
  Widget _buildOrderInfoCard(
    BuildContext context,
    OrderModel order,
    String lang,
  ) {
    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryOrderDetailsStrings.get('orderInfo', lang),
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: order.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(DeliveryOrderDetailsStrings.get('copied', lang)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      '#${order.id}',
                      style: DeliveryAppTypography.bodyMedium.copyWith(
                        color: DeliveryAppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 14, color: DeliveryAppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: DeliveryAppColors.border, height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: DeliveryOrderDetailsStrings.get('orderDate', lang),
            value: order.orderDate.isNotEmpty ? order.orderDate : 'Today',
            icon: Icons.calendar_today,
          ),
          _buildInfoRow(
            label: DeliveryOrderDetailsStrings.get('orderTime', lang),
            value: order.orderTime.isNotEmpty ? order.orderTime : 'Just now',
            icon: Icons.access_time,
          ),
          _buildInfoRow(
            label: DeliveryOrderDetailsStrings.get('numItems', lang),
            value: '${order.itemsCount > 0 ? order.itemsCount : order.items.length} items',
            icon: Icons.fastfood_outlined,
          ),
          _buildInfoRow(
            label: DeliveryOrderDetailsStrings.get('paymentMethod', lang),
            value: order.paymentMethod,
            icon: Icons.payment,
          ),
          _buildInfoRow(
            label: DeliveryOrderDetailsStrings.get('paymentStatus', lang),
            value: order.paymentStatus.toUpperCase(),
            icon: Icons.verified_user_outlined,
            isStatusChip: true,
          ),
          const SizedBox(height: 8),
          const Divider(color: DeliveryAppColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryOrderDetailsStrings.get('totalAmount', lang),
                style: DeliveryAppTypography.bodyLarge.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: DeliveryAppTypography.titleMedium.copyWith(
                  color: DeliveryAppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (order.earnings > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DeliveryOrderDetailsStrings.get('earnings', lang),
                  style: DeliveryAppTypography.bodyMedium.copyWith(
                    color: DeliveryAppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${order.earnings.toStringAsFixed(2)}',
                  style: DeliveryAppTypography.bodyLarge.copyWith(
                    color: DeliveryAppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. Restaurant Information Card (With Navigate, Call, Chat)
  // -------------------------------------------------------------
  Widget _buildRestaurantInfoCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    String lang,
  ) {
    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: DeliveryAppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.storefront, color: DeliveryAppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryOrderDetailsStrings.get('restaurantInfo', lang),
                      style: DeliveryAppTypography.caption.copyWith(
                        color: DeliveryAppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.restaurantName.isNotEmpty ? order.restaurantName : 'Partner Restaurant',
                      style: DeliveryAppTypography.titleMedium.copyWith(
                        color: DeliveryAppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: DeliveryAppColors.border, height: 1),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            title: DeliveryOrderDetailsStrings.get('restaurantAddress', lang),
            subtitle: order.pickupAddress.isNotEmpty ? order.pickupAddress : 'Store Location Address',
          ),
          if (order.merchantPhone.isNotEmpty)
            _buildDetailRow(
              icon: Icons.phone_outlined,
              title: DeliveryOrderDetailsStrings.get('restaurantPhone', lang),
              subtitle: order.merchantPhone,
            ),
          _buildDetailRow(
            icon: Icons.info_outline,
            title: DeliveryOrderDetailsStrings.get('pickupInstructions', lang),
            subtitle: order.pickupInstructions,
            isHighlightBox: true,
          ),
          const SizedBox(height: 16),
          // Action Buttons: Navigate, Call, Chat
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.navigation, size: 16),
                  label: Text(
                    'NAVIGATE',
                    style: DeliveryAppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.primary,
                    side: const BorderSide(color: DeliveryAppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeliveryNavigationScreenPageUi(
                          orderId: order.id,
                          pickupAddress: order.pickupAddress,
                          dropoffAddress: order.dropoffAddress,
                          restaurantName: order.restaurantName,
                          customerName: order.customerName,
                          destinationLatitude: order.restaurantLatitude,
                          destinationLongitude: order.restaurantLongitude,
                          isStoreRoute: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (order.merchantPhone.isNotEmpty)
                IconButton.filledTonal(
                  icon: const Icon(Icons.call, color: DeliveryAppColors.success),
                  tooltip: DeliveryOrderDetailsStrings.get('callRestaurant', lang),
                  onPressed: () {
                    bloc.add(CallMerchantEvent(order.merchantPhone));
                  },
                ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.chat_bubble_outline, color: DeliveryAppColors.primary),
                tooltip: DeliveryOrderDetailsStrings.get('chatSeller', lang),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeliveryChatPageUi(
                        orderId: order.id,
                        recipientName: order.restaurantName,
                        recipientRole: 'Merchant',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. Customer Information Card
  // -------------------------------------------------------------
  Widget _buildCustomerInfoCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    String lang,
  ) {
    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: DeliveryAppColors.info.withValues(alpha: 0.15),
                child: const Icon(Icons.person_pin_circle_outlined, color: DeliveryAppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryOrderDetailsStrings.get('customerInfo', lang),
                      style: DeliveryAppTypography.caption.copyWith(
                        color: DeliveryAppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.customerName.isNotEmpty ? order.customerName : 'Customer',
                      style: DeliveryAppTypography.titleMedium.copyWith(
                        color: DeliveryAppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.customerPhone.isNotEmpty)
                IconButton.filledTonal(
                  icon: const Icon(Icons.phone, color: DeliveryAppColors.success),
                  tooltip: DeliveryOrderDetailsStrings.get('callCustomer', lang),
                  onPressed: () {
                    bloc.add(CallCustomerEvent(order.customerPhone));
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: DeliveryAppColors.border, height: 1),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.home_outlined,
            title: DeliveryOrderDetailsStrings.get('customerAddress', lang),
            subtitle: order.dropoffAddress.isNotEmpty ? order.dropoffAddress : 'Customer Delivery Address',
          ),
          if (order.customerPhone.isNotEmpty)
            _buildDetailRow(
              icon: Icons.phone_android_outlined,
              title: DeliveryOrderDetailsStrings.get('customerPhone', lang),
              subtitle: order.customerPhone,
            ),
          _buildDetailRow(
            icon: Icons.notes_outlined,
            title: DeliveryOrderDetailsStrings.get('deliveryInstructions', lang),
            subtitle: order.deliveryInstructions,
            isHighlightBox: true,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. Order Verification Checklist Card
  // -------------------------------------------------------------
  Widget _buildItemsVerificationCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    DeliveryOrderDetailsPageState state,
    String lang,
  ) {
    final verifiedCount = order.verifiedItemsCount;
    final totalCount = order.items.length;
    final progress = totalCount > 0 ? (verifiedCount / totalCount) : 1.0;

    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DeliveryOrderDetailsStrings.get('orderVerification', lang),
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DeliveryOrderDetailsStrings.get('itemsVerified', lang)}: $verifiedCount / $totalCount',
                    style: DeliveryAppTypography.caption.copyWith(
                      color: verifiedCount == totalCount && totalCount > 0
                          ? DeliveryAppColors.success
                          : DeliveryAppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.done_all, size: 16),
                label: Text(
                  DeliveryOrderDetailsStrings.get('verifyAll', lang),
                  style: DeliveryAppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  for (int i = 0; i < order.items.length; i++) {
                    if (!order.items[i].isVerified) {
                      bloc.add(ToggleItemVerificationEvent(i));
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: DeliveryAppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? DeliveryAppColors.success : DeliveryAppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          if (order.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No item details available for verification.',
                style: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(color: DeliveryAppColors.border, height: 1),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: item.isVerified,
                  activeColor: DeliveryAppColors.success,
                  onChanged: (_) {
                    bloc.add(ToggleItemVerificationEvent(index));
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: DeliveryAppTypography.bodyMedium.copyWith(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            decoration: item.isVerified ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: DeliveryAppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: DeliveryAppTypography.caption.copyWith(
                            color: DeliveryAppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: DeliveryAppTypography.bodyMedium.copyWith(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: item.notes.isNotEmpty
                      ? Text(
                          item.notes,
                          style: DeliveryAppTypography.caption.copyWith(color: DeliveryAppColors.textMuted),
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. Pickup OTP / QR Verification Card
  // -------------------------------------------------------------
  Widget _buildPickupOtpCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    DeliveryOrderDetailsPageState state,
    String lang,
  ) {
    final isOtpVerified = order.isOtpVerified || state.otpStatus == OtpVerificationStatus.success;

    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: DeliveryAppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                DeliveryOrderDetailsStrings.get('pickupOtp', lang),
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              if (isOtpVerified)
                DeliveryChip(
                  variant: DeliveryChipVariant.success,
                  label: DeliveryOrderDetailsStrings.get('verified', lang).toUpperCase(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isOtpVerified)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DeliveryAppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DeliveryAppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: DeliveryAppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DeliveryOrderDetailsStrings.get('otpVerified', lang),
                      style: DeliveryAppTypography.bodyMedium.copyWith(
                        color: DeliveryAppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              DeliveryOrderDetailsStrings.get('enterOtpHint', lang),
              style: DeliveryAppTypography.caption.copyWith(color: DeliveryAppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'e.g. 1234',
                      hintStyle: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textMuted),
                      prefixIcon: const Icon(Icons.lock_outline, color: DeliveryAppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (val) {
                      bloc.add(OtpInputChangedEvent(val));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DeliveryButton(
                  label: DeliveryOrderDetailsStrings.get('verifyOtpBtn', lang),
                  onPressed: () {
                    final otp = _otpController.text.trim();
                    if (otp.isNotEmpty) {
                      bloc.add(VerifyPickupOtpEvent(order.id, otp));
                    }
                  },
                  variant: DeliveryButtonVariant.primary,
                  height: 48,
                ),
              ],
            ),
            if (state.otpStatus == OtpVerificationStatus.invalid)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DeliveryOrderDetailsStrings.get('invalidOtp', lang),
                  style: DeliveryAppTypography.caption.copyWith(color: DeliveryAppColors.error),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. Dynamic Action Bar
  // -------------------------------------------------------------
  Widget _buildDynamicActionBar(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    DeliveryOrderDetailsPageState state,
    String lang,
  ) {
    final step = order.currentPickupStep;

    String primaryButtonLabel;
    VoidCallback? onPrimaryPressed;
    IconData primaryIcon;

    switch (step) {
      case PickupFlowStep.assigned:
        primaryButtonLabel = DeliveryOrderDetailsStrings.get('startJourney', lang);
        primaryIcon = Icons.directions_bike;
        onPrimaryPressed = () {
          bloc.add(MarkGoingToRestaurantEvent(order.id));
        };
        break;
      case PickupFlowStep.goingToRestaurant:
        primaryButtonLabel = DeliveryOrderDetailsStrings.get('markArrived', lang);
        primaryIcon = Icons.storefront;
        onPrimaryPressed = () {
          bloc.add(MarkArrivedAtRestaurantEvent(order.id));
        };
        break;
      case PickupFlowStep.arrivedAtRestaurant:
        primaryButtonLabel = DeliveryOrderDetailsStrings.get('confirmPickup', lang);
        primaryIcon = Icons.check_circle_outline;
        onPrimaryPressed = () {
          bloc.add(ConfirmPickupEvent(order.id));
        };
        break;
      case PickupFlowStep.pickedUp:
        primaryButtonLabel = DeliveryOrderDetailsStrings.get('navigateCustomerBtn', lang);
        primaryIcon = Icons.navigation;
        onPrimaryPressed = () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DeliveryNavigationScreenPageUi(
                orderId: order.id,
                pickupAddress: order.pickupAddress,
                dropoffAddress: order.dropoffAddress,
                restaurantName: order.restaurantName,
                customerName: order.customerName,
                destinationLatitude: order.customerLatitude,
                destinationLongitude: order.customerLongitude,
                isStoreRoute: false,
              ),
            ),
          );
        };
        break;
    }

    return DeliveryButton(
      label: primaryButtonLabel,
      icon: primaryIcon,
      onPressed: onPrimaryPressed,
      variant: DeliveryButtonVariant.primary,
      height: 52,
    );
  }

  // -------------------------------------------------------------
  // COD Cash Collection Card
  // -------------------------------------------------------------
  Widget _buildCodCollectionCard(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    DeliveryOrderDetailsPageState state,
    String lang,
  ) {
    final codAmount = order.codAmountToCollect;

    if (order.isCodCollected) {
      final collectedValue =
          order.collectedAmount > 0 ? order.collectedAmount : codAmount;
      return DeliveryCard(
        padding: EdgeInsets.all(DeliveryAppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DeliveryAppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DeliveryAppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: DeliveryAppColors.success, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryOrderDetailsStrings.get('codCollectedStatus', lang),
                      style: DeliveryAppTypography.bodyMedium.copyWith(
                        color: DeliveryAppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${DeliveryOrderDetailsStrings.get('codAmountToCollect', lang)}: \u{20B9}${collectedValue.toStringAsFixed(2)}',
                      style: DeliveryAppTypography.caption.copyWith(
                        color: DeliveryAppColors.success,
                      ),
                    ),
                    if (state.codChangeAmount > 0)
                      Text(
                        '${DeliveryOrderDetailsStrings.get('changeToReturn', lang)}: \u{20B9}${state.codChangeAmount.toStringAsFixed(2)}',
                        style: DeliveryAppTypography.caption.copyWith(
                          color: DeliveryAppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isCollecting = state.codCollectionStatus == CodCollectionStatus.collecting;

    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: DeliveryAppColors.warning, size: 22),
              const SizedBox(width: 8),
              Text(
                DeliveryOrderDetailsStrings.get('codCashCollection', lang),
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.warning,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryOrderDetailsStrings.get('codAmountToCollect', lang),
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textSecondary,
                ),
              ),
              Text(
                '\u{20B9}${codAmount.toStringAsFixed(2)}',
                style: DeliveryAppTypography.titleMedium.copyWith(
                  color: DeliveryAppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isCollecting)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DeliveryAppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  DeliveryOrderDetailsStrings.get('collectingCod', lang),
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ],
            )
          else ...[
            DeliveryButton(
              label:
                  '${DeliveryOrderDetailsStrings.get('collectCash', lang)} \u{20B9}${codAmount.toStringAsFixed(0)}',
              icon: Icons.payments_outlined,
              onPressed: () {
                _showCodCollectionDialog(context, bloc, order, lang);
              },
              variant: DeliveryButtonVariant.primary,
              height: 48,
            ),
            if (state.codCollectionStatus == CodCollectionStatus.failed &&
                state.codCollectionMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.codCollectionMessage!,
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.error,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCodCollectionDialog(
    BuildContext context,
    DeliveryOrderDetailsPageBloc bloc,
    OrderModel order,
    String lang,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _CodCollectionDialog(
          bloc: bloc,
          order: order,
          lang: lang,
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Helper Component Rows
  // -------------------------------------------------------------
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool isStatusChip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DeliveryAppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textSecondary),
          ),
          const Spacer(),
          if (isStatusChip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: value.contains('PAID')
                    ? DeliveryAppColors.success.withValues(alpha: 0.15)
                    : DeliveryAppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: DeliveryAppTypography.caption.copyWith(
                  color: value.contains('PAID') ? DeliveryAppColors.success : DeliveryAppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              value,
              style: DeliveryAppTypography.bodyMedium.copyWith(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlightBox = false,
  }) {
    if (isHighlightBox) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DeliveryAppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DeliveryAppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: DeliveryAppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DeliveryAppTypography.bodyMedium.copyWith(
                      color: DeliveryAppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: DeliveryAppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
                Text(
                  subtitle,
                  style: DeliveryAppTypography.bodyMedium.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodCollectionDialog extends StatefulWidget {
  final DeliveryOrderDetailsPageBloc bloc;
  final OrderModel order;
  final String lang;

  const _CodCollectionDialog({
    required this.bloc,
    required this.order,
    required this.lang,
  });

  @override
  State<_CodCollectionDialog> createState() => _CodCollectionDialogState();
}

class _CodCollectionDialogState extends State<_CodCollectionDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final codAmount = widget.order.codAmountToCollect;
    final received = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final isValid = received >= codAmount;

    return AlertDialog(
      backgroundColor: DeliveryAppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        DeliveryOrderDetailsStrings.get('cashReceivedTitle', lang),
        style: DeliveryAppTypography.titleMedium.copyWith(
          color: DeliveryAppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DeliveryOrderDetailsStrings.get('codAmountToCollect', lang)}: \u{20B9}${codAmount.toStringAsFixed(2)}',
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: DeliveryAppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: DeliveryOrderDetailsStrings.get(
                'receivedAmountLabel',
                lang,
              ),
              labelStyle: DeliveryAppTypography.bodyMedium.copyWith(
                color: DeliveryAppColors.textMuted,
              ),
              prefixText: '\u{20B9} ',
              prefixStyle: DeliveryAppTypography.bodyMedium.copyWith(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: DeliveryAppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            isValid
                ? '${DeliveryOrderDetailsStrings.get('changeToReturn', lang)}: \u{20B9}${(received - codAmount).toStringAsFixed(2)}'
                : DeliveryOrderDetailsStrings.get('amountLessThanCod', lang),
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: isValid
                  ? DeliveryAppColors.success
                  : DeliveryAppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            DeliveryOrderDetailsStrings.get('cancel', lang),
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: DeliveryAppColors.textMuted,
            ),
          ),
        ),
        FilledButton(
          onPressed: isValid
              ? () {
                  Navigator.of(context).pop();
                  widget.bloc.add(
                    CollectCodCashEvent(widget.order.id, received),
                  );
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: DeliveryAppColors.primary,
            foregroundColor: DeliveryAppColors.background,
          ),
          child: Text(
            DeliveryOrderDetailsStrings.get('confirm', lang),
            style: DeliveryAppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
