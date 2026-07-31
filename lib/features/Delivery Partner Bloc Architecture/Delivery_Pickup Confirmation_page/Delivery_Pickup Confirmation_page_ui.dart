import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Pickup Confirmation_page_bloc.dart';
import 'Delivery_Pickup Confirmation_page_event.dart';
import 'Delivery_Pickup Confirmation_page_repository.dart';
import 'Delivery_Pickup Confirmation_page_service.dart';
import 'Delivery_Pickup Confirmation_page_state.dart';

class DeliveryPickupConfirmationStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'brand': 'DELIVERY PARTNER',
      'orders': 'Orders',
      'walletLabel': 'Wallet Balance',
      'notifications': 'Notifications',
      'dashboard': 'Dashboard',
      'earnings': 'Earnings',
      'incentives': 'Incentives',
      'history': 'History',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'promoTitle': 'Deliver More Earn More',
      'promoSub': 'Complete 20 deliveries this week to unlock a ₹500 bonus',
      'pickupConfirmed': 'Pickup Confirmed!',
      'pickupSub':
          'Package verified and sealed. You are cleared to start the delivery.',
      'startDelivery': 'Start Delivery',
      'deliveryStarted': 'Delivery Started',
      'deliveryStartedSub':
          'You are on your way. Navigate to the drop-off location.',
      'orderId': 'Order ID',
      'pickupTime': 'Pickup Time',
      'paymentType': 'Payment Type',
      'pickupInformation': 'Pickup Information',
      'location': 'Location',
      'contact': 'Contact',
      'instructions': 'Instructions',
      'customerDetails': 'Customer Details',
      'customer': 'Customer',
      'address': 'Address',
      'phone': 'Phone',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'callCustomerHint': 'Call customer',
      'whatsappHint': 'Open WhatsApp chat',
      'callStoreHint': 'Call pickup store',
      'safeDelivery': 'Safe Delivery',
      'safeDeliverySub': 'Handle the package with care and follow safety protocols.',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading pickup confirmation.',
      'profileName': 'Ravi Kumar',
      'checkOrder': 'Check the order',
    },
    'ta': {
      'brand': 'டெலிவரி பார்ட்னர்',
      'orders': 'ஆர்டர்கள்',
      'walletLabel': 'வாலட் இருப்பு',
      'notifications': 'அறிவிப்புகள்',
      'dashboard': 'டாஷ்போர்டு',
      'earnings': 'வருமானம்',
      'incentives': 'ஊக்கத்தொகை',
      'history': 'வரலாறு',
      'wallet': 'வாலட்',
      'profile': 'சுயவிவரம்',
      'promoTitle': 'அதிகம் டெலிவரி செய் அதிகம் சம்பாதி',
      'promoSub': 'இந்த வாரம் 20 டெலிவரிகள் முடித்து ₹500 போனஸ் பெறுங்கள்',
      'pickupConfirmed': 'எடுப்பு உறுதி செய்யப்பட்டது!',
      'pickupSub':
          'பேக்கேஜ் சரிபார்க்கப்பட்டு சீல் வைக்கப்பட்டது. டெலிவரியைத் தொடங்கலாம்.',
      'startDelivery': 'டெலிவரியைத் தொடங்கு',
      'deliveryStarted': 'டெலிவரி தொடங்கியது',
      'deliveryStartedSub':
          'நீங்கள் பயணத்தில் உள்ளீர்கள். இறக்குமிடத்திற்கு செல்லவும்.',
      'orderId': 'ஆர்டர் ஐடி',
      'pickupTime': 'எடுக்கும் நேரம்',
      'paymentType': 'கட்டண முறை',
      'pickupInformation': 'எடுப்பு தகவல்',
      'location': 'இடம்',
      'contact': 'தொடர்பு',
      'instructions': 'வழிமுறைகள்',
      'customerDetails': 'வாடிக்கையாளர் விவரங்கள்',
      'customer': 'வாடிக்கையாளர்',
      'address': 'முகவரி',
      'phone': 'தொலைபேசி',
      'call': 'அழைக்கவும்',
      'whatsapp': 'வாட்ஸ்அப்',
      'callCustomerHint': 'வாடிக்கையாளரை அழைக்கவும்',
      'whatsappHint': 'வாட்ஸ்அப் அரட்டையைத் திறக்கவும்',
      'callStoreHint': 'கடையை அழைக்கவும்',
      'safeDelivery': 'பாதுகாப்பான டெலிவரி',
      'safeDeliverySub': 'பேக்கேஜை கவனமாக கையாளவும்.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'எடுப்பு உறுதிப்படுத்தலை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'profileName': 'ரவி குமார்',
      'checkOrder': 'ஆர்டரை சரிபார்க்கவும்',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class DeliveryPickupConfirmationPage extends StatelessWidget {
  final String orderId;
  final DeliveryPickupConfirmationRepositoryBase? repository;
  final DeliveryPickupConfirmationServiceBase? service;
  final DeliveryPickupConfirmationPageBloc? bloc;

  const DeliveryPickupConfirmationPage({
    super.key,
    required this.orderId,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryPickupConfirmationPageBloc>.value(
        value: bloc!,
        child: const DeliveryPickupConfirmationPageView(),
      );
    }

    return BlocProvider<DeliveryPickupConfirmationPageBloc>(
      create: (context) => DeliveryPickupConfirmationPageBloc(
        repository: repository ?? DeliveryPickupConfirmationRepository(),
        service: service ?? DeliveryPickupConfirmationService(),
      )..add(FetchPickupConfirmationDetailsEvent(orderId)),
      child: const DeliveryPickupConfirmationPageView(),
    );
  }
}

class DeliveryPickupConfirmationPageView extends StatefulWidget {
  const DeliveryPickupConfirmationPageView({super.key});

  @override
  State<DeliveryPickupConfirmationPageView> createState() =>
      _DeliveryPickupConfirmationPageViewState();
}

class _DeliveryPickupConfirmationPageViewState
    extends State<DeliveryPickupConfirmationPageView>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
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
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
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

  void _onStartDelivery(DeliveryPickupConfirmationPageState state) {
    if (state.status == PickupConfirmationStatus.deliveryStarted) return;
    context
        .read<DeliveryPickupConfirmationPageBloc>()
        .add(StartDeliveryEvent(state.model!.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryPickupConfirmationPageBloc,
        DeliveryPickupConfirmationPageState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFB3261E),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final locale = state.localeCode;
        final showSkeleton =
            state.status == PickupConfirmationStatus.initial ||
                (state.status == PickupConfirmationStatus.loading &&
                    state.model == null);

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1D),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
              final isMobile = !isDesktop && !isTablet;

              return Column(
                children: [
                  _HeaderBar(state: state, isMobile: isMobile),
                  if (showSkeleton)
                    const Expanded(child: _SkeletonShell())
                  else if (state.status ==
                          PickupConfirmationStatus.error &&
                      state.model == null)
                    Expanded(child: _ErrorShell(state: state))
                  else
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isMobile)
                            _Sidebar(
                              key: const Key('dp_pickup_sidebar'),
                              localeCode: locale,
                              isTablet: isTablet,
                            ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _fadeAnim,
                                    child: ScaleTransition(
                                      scale: _scaleAnim,
                                      child: SingleChildScrollView(
                                        key: const Key('dp_pickup_page'),
                                        padding: EdgeInsets.all(
                                          isDesktop ? 24 : 16,
                                        ),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: isDesktop ? 1400 : 900,
                                            ),
                                            child: isDesktop || isTablet
                                                ? Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: _HeroCard(
                                                          state: state,
                                                          pulseAnim:
                                                              _pulseAnim,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 20),
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
                                                        pulseAnim:
                                                            _pulseAnim,
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      _RightColumn(
                                                        state: state,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _BottomActionBar(
                                  state: state,
                                  onStartDelivery: () =>
                                      _onStartDelivery(state),
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

class _HeaderBar extends StatelessWidget {
  final DeliveryPickupConfirmationPageState state;
  final bool isMobile;

  const _HeaderBar({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final orderId = model?.orderId ?? '#ORD12345';

    return Container(
      key: const Key('dp_pickup_header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2D),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping,
            color: const Color(0xFF00E676),
            size: 24,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DeliveryPickupConfirmationStrings.of('brand', locale),
                key: const Key('dp_pickup_brand'),
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
            Container(
              key: const Key('dp_pickup_breadcrumb'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DeliveryPickupConfirmationStrings.of('orders', locale),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
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
                  Text(
                    orderId,
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _WalletChip(
            key: const Key('dp_pickup_wallet'),
            localeCode: locale,
            amount: model?.walletBalance ?? 2450.00,
            compact: isMobile,
          ),
          const SizedBox(width: 8),
          _NotificationBell(
            key: const Key('dp_pickup_notification'),
            count: 3,
            onTap: () {},
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            _ProfileWidget(
              key: const Key('dp_pickup_profile'),
              localeCode: locale,
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
        color: const Color(0xFF1B2533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF00E676),
            size: 18,
          ),
          const SizedBox(width: 8),
          if (!compact) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryPickupConfirmationStrings.of(
                      'walletLabel', localeCode),
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
        color: const Color(0xFF1B2533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
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
              key: const Key('dp_pickup_notification_badge'),
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF00E676),
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

  const _ProfileWidget({super.key, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2533),
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
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF00E676), width: 2),
            ),
            child: const Icon(Icons.person, color: Color(0xFF00E676), size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            DeliveryPickupConfirmationStrings.of('profileName', localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String localeCode;
  final bool isTablet;

  const _Sidebar({
    super.key,
    required this.localeCode,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (DeliveryPickupConfirmationStrings.of('dashboard', localeCode),
          Icons.dashboard_outlined),
      (DeliveryPickupConfirmationStrings.of('orders', localeCode),
          Icons.receipt_long_outlined),
      (DeliveryPickupConfirmationStrings.of('earnings', localeCode),
          Icons.trending_up),
      (DeliveryPickupConfirmationStrings.of('incentives', localeCode),
          Icons.emoji_events_outlined),
      (DeliveryPickupConfirmationStrings.of('history', localeCode),
          Icons.history),
      (DeliveryPickupConfirmationStrings.of('wallet', localeCode),
          Icons.account_balance_wallet_outlined),
      (DeliveryPickupConfirmationStrings.of('profile', localeCode),
          Icons.person_outline),
    ];

    return Container(
      width: isTablet ? 220 : 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
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
                          DeliveryPickupConfirmationStrings.of(
                              'orders', localeCode),
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
          ? const Color(0xFF00E676).withValues(alpha: 0.12)
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
                    ? const Color(0xFF00E676)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF00E676)
                      : Colors.white.withValues(alpha: 0.75),
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
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
      key: const Key('dp_pickup_promo_banner'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E676).withValues(alpha: 0.22),
            const Color(0xFF00B0FF).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch,
                color: Color(0xFF00E676),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryPickupConfirmationStrings.of('promoTitle', localeCode),
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
            DeliveryPickupConfirmationStrings.of('promoSub', localeCode),
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
  final DeliveryPickupConfirmationPageState state;
  final Animation<double> pulseAnim;

  const _HeroCard({required this.state, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final isStarted =
        state.status == PickupConfirmationStatus.deliveryStarted;

    return Container(
      key: const Key('dp_pickup_hero_card'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isStarted
              ? [const Color(0xFF0D251A), const Color(0xFF0A1B12)]
              : [const Color(0xFF123B2B), const Color(0xFF0A1B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.18),
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
                  key: const Key('dp_pickup_hero_icon'),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFF00E676),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.3),
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
                          Icons.inventory_2_outlined,
                          color: const Color(0xFF00E676),
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
                            color: Color(0xFF00E676),
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
                      isStarted
                          ? DeliveryPickupConfirmationStrings.of(
                              'deliveryStarted', locale)
                          : DeliveryPickupConfirmationStrings.of(
                              'pickupConfirmed', locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isStarted
                          ? DeliveryPickupConfirmationStrings.of(
                              'deliveryStartedSub', locale)
                          : DeliveryPickupConfirmationStrings.of(
                              'pickupSub', locale),
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
                        color: const Color(0xFF00E676).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isStarted
                                ? Icons.check_circle
                                : Icons.play_arrow,
                            color: const Color(0xFF00E676),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isStarted
                                  ? DeliveryPickupConfirmationStrings.of(
                                      'deliveryStarted', locale)
                                  : DeliveryPickupConfirmationStrings.of(
                                      'startDelivery', locale),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF00E676),
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
                key: const Key('dp_pickup_stat_order_id'),
                icon: Icons.confirmation_number_outlined,
                label: DeliveryPickupConfirmationStrings.of('orderId', locale),
                value: model?.orderId ?? '#ORD12345',
              ),
              _StatPill(
                key: const Key('dp_pickup_stat_pickup_time'),
                icon: Icons.schedule,
                label: DeliveryPickupConfirmationStrings.of(
                    'pickupTime', locale),
                value: model?.pickupTime ?? '12:05 PM',
              ),
              _StatPill(
                key: const Key('dp_pickup_stat_payment_type'),
                icon: Icons.payments_outlined,
                label:
                    DeliveryPickupConfirmationStrings.of('paymentType', locale),
                value: model?.paymentType ?? 'Cash on Delivery',
              ),
            ],
          ),
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
          Icon(icon, color: const Color(0xFF00E676), size: 16),
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

class _RightColumn extends StatelessWidget {
  final DeliveryPickupConfirmationPageState state;

  const _RightColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PickupInfoCard(state: state),
        const SizedBox(height: 20),
        _CustomerDetailsCard(state: state),
      ],
    );
  }
}

class _PickupInfoCard extends StatelessWidget {
  final DeliveryPickupConfirmationPageState state;

  const _PickupInfoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;

    return _buildGlassCard(
      key: const Key('dp_pickup_info_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryPickupConfirmationStrings.of('pickupInformation', locale),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _StepRow(
            key: const Key('dp_pickup_info_step_location'),
            icon: Icons.location_on,
            title: DeliveryPickupConfirmationStrings.of('location', locale),
            lines: [
              model?.pickupLocationName ?? 'Green Mart',
              model?.pickupAddress ?? '24, Anna Salai, Chennai',
            ],
            isFirst: true,
          ),
          _StepRow(
            key: const Key('dp_pickup_info_step_contact'),
            icon: Icons.person_outline,
            title: DeliveryPickupConfirmationStrings.of('contact', locale),
            lines: [
              model?.pickupContactName ?? 'Priya Sharma',
              model?.pickupContactPhone ?? '+919876543210',
            ],
          ),
          _StepRow(
            key: const Key('dp_pickup_info_step_instructions'),
            icon: Icons.info_outline,
            title: DeliveryPickupConfirmationStrings.of('instructions', locale),
            lines: [
              model?.pickupInstructions ??
                  'Show the order code at the counter.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Key key, required Widget child}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121A2D).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  final bool isFirst;

  const _StepRow({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withValues(alpha: 0.14),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF00E676),
                    size: 17,
                  ),
                ),
                if (!isFirst) ...[
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF00E676).withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isFirst ? 4 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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
}

class _CustomerDetailsCard extends StatelessWidget {
  final DeliveryPickupConfirmationPageState state;

  const _CustomerDetailsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final model = state.model;
    final customerPhone = model?.customerPhone ?? '+919876543211';

    return Container(
      key: const Key('dp_pickup_customer_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle,
                color: Color(0xFF00E676),
                size: 26,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  DeliveryPickupConfirmationStrings.of(
                      'customerDetails', locale),
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
          const SizedBox(height: 14),
          _CustomerInfoRow(
            icon: Icons.person_outline,
            label: DeliveryPickupConfirmationStrings.of('customer', locale),
            value: model?.customerName ?? 'Mike Johnson',
          ),
          const SizedBox(height: 10),
          _CustomerInfoRow(
            icon: Icons.location_on_outlined,
            label: DeliveryPickupConfirmationStrings.of('address', locale),
            value: model?.customerAddress ?? '12, Beach Road, Chennai',
          ),
          const SizedBox(height: 10),
          _CustomerInfoRow(
            icon: Icons.phone_outlined,
            label: DeliveryPickupConfirmationStrings.of('phone', locale),
            value: customerPhone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  key: const Key('dp_pickup_call_customer'),
                  icon: Icons.phone,
                  label: DeliveryPickupConfirmationStrings.of('call', locale),
                  hint:
                      DeliveryPickupConfirmationStrings.of(
                          'callCustomerHint', locale),
                  onTap: () => context
                      .read<DeliveryPickupConfirmationPageBloc>()
                      .add(CallCustomerEvent(customerPhone)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  key: const Key('dp_pickup_whatsapp'),
                  icon: Icons.chat,
                  label: DeliveryPickupConfirmationStrings.of(
                      'whatsapp', locale),
                  hint:
                      DeliveryPickupConfirmationStrings.of(
                          'whatsappHint', locale),
                  onTap: () => context
                      .read<DeliveryPickupConfirmationPageBloc>()
                      .add(OpenWhatsAppEvent(customerPhone)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CustomerInfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Material(
        color: const Color(0xFF1B2533),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF00E676), size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
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
  final DeliveryPickupConfirmationPageState state;
  final VoidCallback onStartDelivery;

  const _BottomActionBar({
    required this.state,
    required this.onStartDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;
    final isStarted =
        state.status == PickupConfirmationStatus.deliveryStarted;
    final isLoading = state.status == PickupConfirmationStatus.loading;

    return Container(
      key: const Key('dp_pickup_bottom_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            final badge = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF00E676),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DeliveryPickupConfirmationStrings.of(
                            'safeDelivery', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        DeliveryPickupConfirmationStrings.of(
                            'safeDeliverySub', locale),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final button = SizedBox(
              height: 52,
              child: isStarted
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00E676),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DeliveryPickupConfirmationStrings.of(
                                'deliveryStarted', locale),
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      key: const Key('dp_pickup_start_delivery'),
                      onPressed: isLoading ? null : onStartDelivery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF00E676)
                            .withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  DeliveryPickupConfirmationStrings.of(
                                      'startDelivery', locale),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  badge,
                  const SizedBox(height: 12),
                  button,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: badge),
                const SizedBox(width: 16),
                button,
              ],
            );
          },
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
      key: const Key('dp_pickup_skeleton'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          box(180, double.infinity),
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
  final DeliveryPickupConfirmationPageState state;

  const _ErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final locale = state.localeCode;

    return Center(
      key: const Key('dp_pickup_error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFFF5252),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryPickupConfirmationStrings.of(
                  'somethingWentWrong', locale),
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
              key: const Key('dp_pickup_retry'),
              onPressed: () {
                final bloc = context
                    .read<DeliveryPickupConfirmationPageBloc>();
                bloc.add(
                  FetchPickupConfirmationDetailsEvent(
                    state.model?.orderId ?? '#ORD12345',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliveryPickupConfirmationStrings.of('retry', locale),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
