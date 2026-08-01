import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Delivery Completed_page_bloc.dart';
import 'Delivery_Delivery Completed_page_event.dart';
import 'Delivery_Delivery Completed_page_repository.dart';
import 'Delivery_Delivery Completed_page_service.dart';
import 'Delivery_Delivery Completed_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';

class DeliveryCompletedStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'brand': 'DELIVERY PARTNER',
      'orders': 'Orders',
      'orderCompleted': 'Order Completed',
      'orderLabel': 'Order #',
      'walletLabel': 'Wallet Balance',
      'notifications': 'Notifications',
      'dashboard': 'Dashboard',
      'earnings': 'Earnings',
      'incentives': 'Incentives',
      'history': 'History',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'settings': 'Settings',
      'helpSupport': 'Help & Support',
      'promoTitle': 'Great Job!',
      'promoSub':
          "You've completed this order successfully. Keep up the momentum!",
      'deliveredSuccessfully': 'Delivered Successfully! 🎉',
      'deliveredSub': "Great job! You've completed this order successfully.",
      'earningLabel': 'Earnings',
      'orderId': 'Order ID',
      'customer': 'Customer',
      'address': 'Address',
      'timeTaken': 'Time Taken',
      'distanceCovered': 'Distance Covered',
      'paymentStatus': 'Payment Status',
      'paymentMethod': 'Payment Method',
      'paidSuccessfully': 'Paid Successfully',
      'completeOrder': 'Complete Order',
      'returnHome': 'Return Home',
      'uploadProof': 'Upload Proof',
      'uploadProofHint': 'Upload proof of delivery',
      'proofUploaded': 'Proof uploaded',
      'uploadingProof': 'Uploading proof...',
      'rateCustomer': 'Rate this customer',
      'ratingSubmitted': 'Thanks for your feedback!',
      'customerRating': 'Customer Rating',
      'excellentRating': 'Excellent (5.0/5)',
      'deliverySummary': 'Delivery Summary',
      'retry': 'Retry',
      'somethingWentWrong':
          'Something went wrong while loading the completed order.',
      'emptyTitle': 'No completed order data',
      'emptySub':
          'Your completed order details are unavailable. Refresh to reload.',
      'back': 'Back',
      'profileName': 'Ravi Kumar',
      'vehicleNo': 'TN 01 AB 1234',
    },
    'ta': {
      'brand': 'டெலிவரி பார்ட்னர்',
      'orders': 'ஆர்டர்கள்',
      'orderCompleted': 'ஆர்டர் முடிந்தது',
      'orderLabel': 'ஆர்டர் #',
      'walletLabel': 'வாலட் இருப்பு',
      'notifications': 'அறிவிப்புகள்',
      'dashboard': 'டாஷ்போர்டு',
      'earnings': 'வருமானம்',
      'incentives': 'ஊக்கத்தொகை',
      'history': 'வரலாறு',
      'wallet': 'வாலட்',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'helpSupport': 'உதவி & ஆதரவு',
      'promoTitle': 'அருமையான வேலை!',
      'promoSub':
          'நீங்கள் இந்த ஆர்டரை வெற்றிகரமாக முடித்துவிட்டீர்கள். தொடருங்கள்!',
      'deliveredSuccessfully': 'வெற்றிகரமாக டெலிவரி! 🎉',
      'deliveredSub':
          'அருமை! இந்த ஆர்டரை வெற்றிகரமாக முடித்துவிட்டீர்கள்.',
      'earningLabel': 'வருவாய்',
      'orderId': 'ஆர்டர் ஐடி',
      'customer': 'வாடிக்கையாளர்',
      'address': 'முகவரி',
      'timeTaken': 'எடுத்த நேரம்',
      'distanceCovered': 'பயண தூரம்',
      'paymentStatus': 'கட்டண நிலை',
      'paymentMethod': 'கட்டண முறை',
      'paidSuccessfully': 'வெற்றிகரமாக செலுத்தப்பட்டது',
      'completeOrder': 'ஆர்டரை முடிக்கவும்',
      'returnHome': 'முகப்புக்கு திரும்பு',
      'uploadProof': 'சான்று பதிவேற்று',
      'uploadProofHint': 'டெலிவரி சான்றை பதிவேற்றவும்',
      'proofUploaded': 'சான்று பதிவேற்றப்பட்டது',
      'uploadingProof': 'சான்று பதிவேற்றுகிறது...',
      'rateCustomer': 'வாடிக்கையாளரை மதிப்பிடுங்கள்',
      'ratingSubmitted': 'உங்கள் கருத்துக்கு நன்றி!',
      'customerRating': 'வாடிக்கையாளர் மதிப்பீடு',
      'excellentRating': 'சிறப்பு (5.0/5)',
      'deliverySummary': 'டெலிவரி சுருக்கம்',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'முடிக்கப்பட்ட ஆர்டரை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'emptyTitle': 'முடிக்கப்பட்ட ஆர்டர் தரவு இல்லை',
      'emptySub':
          'உங்கள் முடிக்கப்பட்ட ஆர்டர் விவரங்கள் கிடைக்கவில்லை. புதுப்பிக்கவும்.',
      'back': 'பின்',
      'profileName': 'ரவி குமார்',
      'vehicleNo': 'TN 01 AB 1234',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class DeliveryCompletedPage extends StatelessWidget {
  final String orderId;
  final DeliveryCompletedRepositoryBase? repository;
  final DeliveryCompletedServiceBase? service;
  final DeliveryCompletedBloc? bloc;

  const DeliveryCompletedPage({
    super.key,
    required this.orderId,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryCompletedBloc>.value(
        value: bloc!,
        child: const DeliveryCompletedPageView(),
      );
    }

    return BlocProvider<DeliveryCompletedBloc>(
      create: (context) => DeliveryCompletedBloc(
        repository: repository ?? DeliveryCompletedRepository(),
        service: service ?? DeliveryCompletedService(),
      )..add(FetchCompletedOrderDetailsEvent(orderId)),
      child: const DeliveryCompletedPageView(),
    );
  }
}

class DeliveryCompletedPageView extends StatefulWidget {
  const DeliveryCompletedPageView({super.key});

  @override
  State<DeliveryCompletedPageView> createState() =>
      _DeliveryCompletedPageViewState();
}

class _DeliveryCompletedPageViewState extends State<DeliveryCompletedPageView>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  bool get _isTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_isTest) {
      _entranceController.value = 1.0;
      _pulseController.value = 1.0;
    } else {
      _entranceController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onReturnHome() {
    context.read<DeliveryCompletedBloc>().add(const ReturnHomeRequestedEvent());
  }

  void _onCompleteOrder(DeliveryCompletedPageState state) {
    if (state.status == DeliveryCompletedStatus.completed) return;
    if (state.isCompleting) return;
    final orderId = state.model?.orderId ?? '#ORD12345';
    context
        .read<DeliveryCompletedBloc>()
        .add(CompleteOrderSubmittedEvent(orderId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            state.status != DeliveryCompletedStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final locale = state.localeCode;
        final showSkeleton =
            state.status == DeliveryCompletedStatus.initial ||
                (state.status == DeliveryCompletedStatus.loading &&
                    state.model == null);

        return Scaffold(
          backgroundColor: DeliveryAppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
              final isMobile = !isDesktop && !isTablet;

              return Column(
                children: [
                  _CompletedHeaderBar(
                    state: state,
                    isMobile: isMobile,
                    onBack: _onReturnHome,
                  ),
                  if (showSkeleton)
                    const Expanded(child: _SkeletonShell())
                  else if (state.status == DeliveryCompletedStatus.error &&
                      state.model == null)
                    Expanded(child: _ErrorShell(state: state))
                  else if (state.status == DeliveryCompletedStatus.empty)
                    Expanded(child: _EmptyShell(state: state))
                  else
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isMobile)
                            _CompletedSidebar(
                              key: const Key('dp_completed_sidebar'),
                              localeCode: locale,
                              isTablet: isTablet,
                            ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _fadeAnim,
                                    child: SingleChildScrollView(
                                      key: const Key('dp_completed_page'),
                                      padding: EdgeInsets.all(
                                        isDesktop ? 24 : 16,
                                      ),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                isDesktop ? 1400 : 900,
                                          ),
                                          child: isDesktop || isTablet
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: _HeroCard(
                                                        state: state,
                                                        pulseAnim: _pulseAnim,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                    Expanded(
                                                      flex: 4,
                                                      child: _RightColumn(
                                                        state: state,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    _HeroCard(
                                                      state: state,
                                                      pulseAnim: _pulseAnim,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    _RightColumn(state: state),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _BottomActionBar(
                                  state: state,
                                  onCompleteOrder: () =>
                                      _onCompleteOrder(state),
                                  onReturnHome: _onReturnHome,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CompletedHeaderBar extends StatelessWidget {
  final DeliveryCompletedPageState state;
  final bool isMobile;
  final VoidCallback onBack;

  const _CompletedHeaderBar({
    required this.state,
    required this.isMobile,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final orderId = model?.orderId ?? '#ORD12345';

    return Container(
      key: const Key('dp_completed_header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('dp_completed_back'),
            onPressed: onBack,
            tooltip: DeliveryCompletedStrings.of('back', locale),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          const Icon(
            Icons.local_shipping,
            color: DeliveryAppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DeliveryCompletedStrings.of('brand', locale),
                key: const Key('dp_completed_brand'),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            Flexible(
              child: Container(
                key: const Key('dp_completed_breadcrumb'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        DeliveryCompletedStrings.of('orderCompleted', locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: Colors.white38,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        orderId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DeliveryAppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          _WalletChip(
            key: const Key('dp_completed_wallet'),
            localeCode: locale,
            amount: model?.walletBalance ?? 2450.00,
            compact: isMobile,
          ),
          const SizedBox(width: 8),
          _NotificationBell(
            key: const Key('dp_completed_notification'),
            count: 3,
            onTap: () {},
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            _ProfileWidget(
              key: const Key('dp_completed_profile'),
              localeCode: locale,
              model: model,
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  final String localeCode;
  final double amount;
  final bool compact;

  const _WalletChip({
    super.key,
    required this.localeCode,
    required this.amount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: 8),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: DeliveryAppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          if (!compact) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryCompletedStrings.of('walletLabel', localeCode),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            tooltip: DeliveryCompletedStrings.of('notifications', 'en'),
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              key: const Key('dp_completed_notification_badge'),
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: DeliveryAppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileWidget extends StatelessWidget {
  final String localeCode;
  final DeliveryCompletedModel? model;

  const _ProfileWidget({
    super.key,
    required this.localeCode,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final name = model?.partnerName ??
        DeliveryCompletedStrings.of('profileName', localeCode);
    final vehicleNo = model?.partnerVehicleNo ??
        DeliveryCompletedStrings.of('vehicleNo', localeCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DeliveryAppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: DeliveryAppColors.primary, width: 2),
            ),
            child: const Icon(Icons.person, color: DeliveryAppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                vehicleNo,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}

class _CompletedSidebar extends StatelessWidget {
  final String localeCode;
  final bool isTablet;

  const _CompletedSidebar({
    super.key,
    required this.localeCode,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (DeliveryCompletedStrings.of('dashboard', localeCode),
          Icons.dashboard_outlined),
      (DeliveryCompletedStrings.of('orders', localeCode),
          Icons.receipt_long_outlined),
      (DeliveryCompletedStrings.of('earnings', localeCode),
          Icons.trending_up),
      (DeliveryCompletedStrings.of('incentives', localeCode),
          Icons.emoji_events_outlined),
      (DeliveryCompletedStrings.of('history', localeCode), Icons.history),
      (DeliveryCompletedStrings.of('wallet', localeCode),
          Icons.account_balance_wallet_outlined),
      (DeliveryCompletedStrings.of('profile', localeCode),
          Icons.person_outline),
      (DeliveryCompletedStrings.of('settings', localeCode),
          Icons.settings_outlined),
      (DeliveryCompletedStrings.of('helpSupport', localeCode),
          Icons.headset_mic_outlined),
    ];

    return Container(
      width: isTablet ? 220 : 260,
      decoration: BoxDecoration(
        color: DeliveryAppColors.background,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _SidebarMenuItem(
                      label: items[i].$1,
                      icon: items[i].$2,
                      isSelected: items[i].$1 ==
                          DeliveryCompletedStrings.of('orders', localeCode),
                      onTap: () {},
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: _PromoBanner(localeCode: localeCode),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? DeliveryAppColors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? DeliveryAppColors.primary
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? DeliveryAppColors.primary
                        : Colors.white.withValues(alpha: 0.75),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final String localeCode;

  const _PromoBanner({required this.localeCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_completed_promo_banner'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DeliveryAppColors.primary.withValues(alpha: 0.22),
            const Color(0xFF00B0FF).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: DeliveryAppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryCompletedStrings.of('promoTitle', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DeliveryCompletedStrings.of('promoSub', localeCode),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final DeliveryCompletedPageState state;
  final Animation<double> pulseAnim;

  const _HeroCard({required this.state, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final completed = state.status == DeliveryCompletedStatus.completed;

    return Container(
      key: const Key('dp_completed_hero_card'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? [DeliveryAppColors.successBg, const Color(0xFF0A1B12)]
              : [const Color(0xFF123B2B), const Color(0xFF0A1B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: DeliveryAppColors.primary.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: pulseAnim,
                child: Container(
                  key: const Key('dp_completed_hero_icon'),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DeliveryAppColors.primary.withValues(alpha: 0.12),
                    border: Border.all(color: DeliveryAppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Icon(
                          Icons.fastfood,
                          color: DeliveryAppColors.primary,
                          size: 44,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: DeliveryAppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryCompletedStrings.of(
                          'deliveredSuccessfully', locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DeliveryCompletedStrings.of('deliveredSub', locale),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DeliveryAppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: DeliveryAppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${DeliveryCompletedStrings.of('earningLabel', locale)} '
                              '₹${(model?.deliveryEarnings ?? 120.00).toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: DeliveryAppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(
                key: const Key('dp_completed_stat_order_id'),
                icon: Icons.confirmation_number_outlined,
                label: DeliveryCompletedStrings.of('orderId', locale),
                value: model?.orderId ?? '#ORD12345',
              ),
              _StatPill(
                key: const Key('dp_completed_stat_time_taken'),
                icon: Icons.schedule,
                label: DeliveryCompletedStrings.of('timeTaken', locale),
                value: model?.timeTaken ?? '32 min',
              ),
              _StatPill(
                key: const Key('dp_completed_stat_distance'),
                icon: Icons.route_outlined,
                label: DeliveryCompletedStrings.of('distanceCovered', locale),
                value:
                    '${(model?.distanceCovered ?? 5.6).toStringAsFixed(1)} km',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _RatingCard(state: state),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: DeliveryAppColors.primary, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _RatingCard extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _RatingCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final rating = state.model?.customerRating ?? 5.0;

    return Container(
      key: const Key('dp_completed_rating_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DeliveryAppColors.warning.withValues(alpha: 0.18),
              border: Border.all(
                color: DeliveryAppColors.warning.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: DeliveryAppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryCompletedStrings.of('customerRating', locale),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(
                          i <= rating.round() ? Icons.star : Icons.star_border,
                          color: DeliveryAppColors.warning,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        DeliveryCompletedStrings.of('excellentRating', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _RightColumn extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _RightColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DeliverySummaryCard(state: state),
        const SizedBox(height: 20),
        _CustomerActionsCard(state: state),
      ],
    );
  }
}

class _DeliverySummaryCard extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _DeliverySummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;

    return Container(
      key: const Key('dp_completed_summary_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: DeliveryAppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  DeliveryCompletedStrings.of('deliverySummary', locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            key: const Key('dp_completed_summary_order_id'),
            icon: Icons.confirmation_number_outlined,
            label: DeliveryCompletedStrings.of('orderId', locale),
            value: model?.orderId ?? '#ORD12345',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_customer'),
            icon: Icons.person_outline,
            label: DeliveryCompletedStrings.of('customer', locale),
            value: model?.customerName ?? 'Arun Kumar',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_address'),
            icon: Icons.location_on_outlined,
            label: DeliveryCompletedStrings.of('address', locale),
            value: model?.deliveryAddress ?? '12, Beach Road, Chennai - 600001',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_time_taken'),
            icon: Icons.schedule,
            label: DeliveryCompletedStrings.of('timeTaken', locale),
            value: model?.timeTaken ?? '32 min',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_distance'),
            icon: Icons.route_outlined,
            label: DeliveryCompletedStrings.of('distanceCovered', locale),
            value:
                '${(model?.distanceCovered ?? 5.6).toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_payment_status'),
            icon: Icons.verified_outlined,
            label: DeliveryCompletedStrings.of('paymentStatus', locale),
            value: model?.paymentStatus ?? 'Paid Successfully',
            valueColor: DeliveryAppColors.primary,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            key: const Key('dp_completed_summary_payment_method'),
            icon: Icons.payments_outlined,
            label: DeliveryCompletedStrings.of('paymentMethod', locale),
            value: model?.paymentMethod ?? 'UPI • Google Pay',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.45),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerActionsCard extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _CustomerActionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final bloc = context.read<DeliveryCompletedBloc>();

    return Container(
      key: const Key('dp_completed_actions_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryCompletedStrings.of('rateCustomer', locale),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  key: Key('dp_completed_star_$i'),
                  onPressed: () => bloc.add(RateCustomerEvent(i)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 44,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    i <= (state.ratedScore ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: DeliveryAppColors.warning,
                    size: 30,
                  ),
                  tooltip: 'Rate $i',
                ),
              const Spacer(),
              if (state.ratingSubmitted)
                Text(
                  state.ratedScore != null
                      ? '${state.ratedScore}/5'
                      : DeliveryCompletedStrings.of('ratingSubmitted', locale),
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          if (state.ratingSubmitted) ...[
            const SizedBox(height: 4),
            Text(
              DeliveryCompletedStrings.of('ratingSubmitted', locale),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  key: const Key('dp_completed_upload_proof'),
                  icon: Icons.upload_file,
                  label: state.isUploading
                      ? DeliveryCompletedStrings.of('uploadingProof', locale)
                      : state.isProofUploaded
                          ? DeliveryCompletedStrings.of('proofUploaded', locale)
                          : DeliveryCompletedStrings.of('uploadProof', locale),
                  hint: DeliveryCompletedStrings.of('uploadProofHint', locale),
                  enabled: !state.isUploading,
                  onTap: () => bloc
                      .add(const UploadProofMediaEvent('proof_delivery.jpg')),
                ),
              ),
            ],
          ),
          if (state.isUploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.proofUploadProgress,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  DeliveryAppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool enabled;
  final VoidCallback onTap;

  const _QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Material(
        color: DeliveryAppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled
                      ? DeliveryAppColors.primary
                      : Colors.white.withValues(alpha: 0.4),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final DeliveryCompletedPageState state;
  final VoidCallback onCompleteOrder;
  final VoidCallback onReturnHome;

  const _BottomActionBar({
    required this.state,
    required this.onCompleteOrder,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final completed = state.status == DeliveryCompletedStatus.completed;
    final isLoading = state.status == DeliveryCompletedStatus.loading;
    final canComplete = state.status == DeliveryCompletedStatus.success;

    return Container(
      key: const Key('dp_completed_bottom_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: DeliveryAppColors.background,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;

            final Widget completeButton = SizedBox(
              width: wide ? 240 : double.infinity,
              height: 52,
              child: completed
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color:
                            DeliveryAppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color:
                              DeliveryAppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: DeliveryAppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DeliveryCompletedStrings.of('orderCompleted', locale),
                              style: const TextStyle(
                                color: DeliveryAppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _GradientButton(
                      key: const Key('dp_completed_complete_button'),
                      onPressed: isLoading || !canComplete ? null : onCompleteOrder,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.black,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    DeliveryCompletedStrings.of(
                                        'completeOrder', locale),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
            );

            final Widget returnButton = SizedBox(
              height: 52,
              child: OutlinedButton(
                key: const Key('dp_completed_return_home'),
                onPressed: onReturnHome,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DeliveryCompletedStrings.of('returnHome', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  completeButton,
                  const SizedBox(height: 10),
                  returnButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DeliveryAppColors.primary.withValues(alpha: 0.14),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: DeliveryAppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DeliveryCompletedStrings.of(
                                  'orderCompleted', locale),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              model?.orderId ?? '#ORD12345',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                returnButton,
                const SizedBox(width: 12),
                completeButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonShell extends StatelessWidget {
  const _SkeletonShell();

  @override
  Widget build(BuildContext context) {
    Widget box(double height, double width) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return SingleChildScrollView(
      key: const Key('dp_completed_skeleton'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          box(200, double.infinity),
          const SizedBox(height: 16),
          box(140, double.infinity),
          const SizedBox(height: 16),
          box(120, double.infinity),
        ],
      ),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _ErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;

    return Center(
      key: const Key('dp_completed_error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: DeliveryAppColors.error,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryCompletedStrings.of('somethingWentWrong', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_completed_retry'),
              onPressed: () {
                final bloc = context.read<DeliveryCompletedBloc>();
                bloc.add(
                  FetchCompletedOrderDetailsEvent(
                    state.model?.orderId ?? '#ORD12345',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliveryCompletedStrings.of('retry', locale),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShell extends StatelessWidget {
  final DeliveryCompletedPageState state;

  const _EmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;

    return Center(
      key: const Key('dp_completed_empty'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: Color(0xFF94A3B8),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryCompletedStrings.of('emptyTitle', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryCompletedStrings.of('emptySub', locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_completed_empty_refresh'),
              onPressed: () {
                final bloc = context.read<DeliveryCompletedBloc>();
                bloc.add(
                  RefreshCompletedOrderEvent(
                    state.model?.orderId ?? '#ORD12345',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliveryCompletedStrings.of('retry', locale),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
