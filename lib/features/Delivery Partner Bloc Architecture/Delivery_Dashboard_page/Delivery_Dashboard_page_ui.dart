import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Dashboard_page_bloc.dart';
import 'Delivery_Dashboard_page_event.dart';
import 'Delivery_Dashboard_page_repository.dart';
import 'Delivery_Dashboard_page_service.dart';
import 'Delivery_Dashboard_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_app_spacing.dart';
import '../../../core/widgets/delivery_button.dart';
import '../../../core/widgets/delivery_card.dart';
import '../../../core/widgets/delivery_chip.dart';

class DeliveryDashboardStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'welcome': 'Good Morning',
      'tagline': 'Ready to deliver happiness today?',
      'walletBalance': 'Wallet Balance',
      'youAreOnline': 'You are ONLINE',
      'youAreOffline': 'You are OFFLINE',
      'youAre': 'You are',
      'onlineStatus': 'ONLINE',
      'offlineStatus': 'OFFLINE',
      'onlineSub': 'You are visible to receive new delivery requests',
      'offlineSub': 'You will not receive any new order requests',
      'goOfflineHint': 'Go offline to stop receiving new orders',
      'goOnlineHint': 'Go online to start receiving delivery requests',
      'goOffline': 'Go Offline',
      'goOnline': 'Go Online',
      'todaysEarnings': "Today's Earnings",
      'completedOrders': 'Completed Orders',
      'activeOrders': 'Active Orders',
      'workingHours': 'Working Hours',
      'acceptanceRate': 'Acceptance Rate',
      'performanceScore': 'Performance Score',
      'rating': 'Rating',
      'distanceTravelled': 'Distance Travelled',
      'weeklyEarnings': 'Weekly Earnings',
      'vsYesterday': 'vs Yesterday',
      'vsLastWeek': 'vs Last Week',
      'vsLast7Days': 'vs Last 7 Days',
      'currentlyInProgress': 'Currently in progress',
      'todaysDuration': "Today's duration",
      'excellentPerf': 'Excellent Performance',
      'totalDistance': 'Total Distance Covered',
      'onlineSince': 'Online Since',
      'sinceMorning': 'Since 09:30 AM',
      'onlineDuration': 'Online Duration',
      'durationToday': '5h 45m',
      'recentActivity': 'Recent Activity',
      'viewAll': 'View All',
      'quickActions': 'Quick Actions',
      'mapPreview': 'Active Zone Map',
      'liveBadge': 'LIVE',
      'currentLocation': 'Current Location',
      'weatherNow': 'Weather',
      'nearbyOrders': 'Nearby Orders',
      'highDemandZone': 'Anna Salai High Demand Zone',
      'incentivesTitle': 'Today Incentive Goal',
      'incentiveEarned': 'Earned',
      'incentiveTarget': 'Target',
      'withdraw': 'Withdraw',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading dashboard data.',
      'emptyTitle': 'No Dashboard Metrics Available',
      'emptySub': 'Please check back later or refresh your session.',
      'notifications': 'Notifications',
      'markAllRead': 'Mark all read',
      'notifNewOrder': 'New Order Request',
      'notifNewOrderSub': 'A new delivery request is available nearby',
      'notifBonus': 'Peak Hour Bonus',
      'notifBonusSub': '₹250 bonus credited to your wallet',
      'notifLowRating': 'Low Rating Alert',
      'notifLowRatingSub': 'A customer rated you 2 stars',
      'notifWallet': 'Wallet Credited',
      'notifWalletSub': '₹120.00 added from today\'s deliveries',
      'notifSystem': 'System Update',
      'notifSystemSub': 'A new app version is available',
      'notifNew': 'New',
      'currentDelivery': 'Current Delivery',
      'orderNo': 'Order #ORD12345',
      'inProgress': 'In Progress',
      'pickup': 'Pickup',
      'drop': 'Drop',
      'distance': 'Distance',
      'eta': 'ETA',
      'payment': 'Payment',
      'navigate': 'Navigate',
      'callCustomer': 'Call Customer',
      'noActiveOrder': 'No Active Delivery',
      'noActiveOrderSub': 'Go online to receive and track delivery requests',
      'earningsOverview': 'Earnings Overview',
      'today': 'Today',
      'last7Days': '7 Days',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'totalEarnings': 'Total Earnings',
      'scanQr': 'Scan QR',
      'wallet': 'Wallet',
      'support': 'Support',
      'history': 'History',
      'documents': 'Documents',
      'pickupLocation': 'Green Mart, Anna Salai',
      'dropLocation': 'Kamaraj Avenue, Velachery',
    },
    'ta': {
      'welcome': 'காலை வணக்கம்',
      'tagline': 'இன்று மகிழ்ச்சியை வழங்கத் தயாரா?',
      'walletBalance': 'வாலட் இருப்பு',
      'youAreOnline': 'நீங்கள் ஆன்லைனில் உள்ளீர்கள்',
      'youAreOffline': 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள்',
      'youAre': 'நீங்கள்',
      'onlineStatus': 'ஆன்லைன்',
      'offlineStatus': 'ஆஃப்லைன்',
      'onlineSub': 'புதிய டெலிவரி கோரிக்கைகளைப் பெற நீங்கள் தயாராக உள்ளீர்கள்',
      'offlineSub': 'புதிய ஆர்டர் கோரிக்கைகள் எதுவும் உங்களுக்கு வராது',
      'goOfflineHint': 'புதிய ஆர்டர்களைப் பெறுவதை நிறுத்த ஆஃப்லைனுக்குச் செல்லவும்',
      'goOnlineHint': 'டெலிவரி கோரிக்கைகளைப் பெற ஆன்லைனுக்குச் செல்லவும்',
      'goOffline': 'ஆஃப்லைனுக்குச் செல்',
      'goOnline': 'ஆன்லைனுக்குச் செல்',
      'todaysEarnings': 'இன்றைய வருமானம்',
      'completedOrders': 'நிறைவடைந்த ஆர்டர்கள்',
      'activeOrders': 'செயலில் உள்ள ஆர்டர்கள்',
      'workingHours': 'வேலை நேரம்',
      'acceptanceRate': 'ஏற்பு விகிதம்',
      'performanceScore': 'செயல்திறன் மதிப்பெண்',
      'rating': 'மதிப்பீடு',
      'distanceTravelled': 'பயணித்த தூரம்',
      'weeklyEarnings': 'வாராந்திர வருமானம்',
      'vsYesterday': 'நேற்றைய ஒப்பீடு',
      'vsLastWeek': 'கடந்த வார ஒப்பீடு',
      'vsLast7Days': 'கடந்த 7 நாட்கள் ஒப்பீடு',
      'currentlyInProgress': 'தற்போது நடைபெறுகிறது',
      'todaysDuration': 'இன்றைய காலம்',
      'excellentPerf': 'சிறந்த செயல்திறன்',
      'totalDistance': 'மொத்த தூரம்',
      'onlineSince': 'ஆன்லைன் முதல்',
      'sinceMorning': 'காலை 09:30 முதல்',
      'onlineDuration': 'ஆன்லைன் காலம்',
      'durationToday': '5 மணி 45 நிமி',
      'recentActivity': 'சமீபத்திய நடவடிக்கைகள்',
      'viewAll': 'அனைத்தையும் பார்',
      'quickActions': 'விரைவு செயல்கள்',
      'mapPreview': 'டெலிவரி மண்டல வரைபடம்',
      'liveBadge': 'நேரடி',
      'currentLocation': 'தற்போதைய இடம்',
      'weatherNow': 'வானிலை',
      'nearbyOrders': 'அருகிலுள்ள ஆர்டர்கள்',
      'highDemandZone': 'அண்ணா சாலை அதிக தேவை மண்டலம்',
      'incentivesTitle': 'இன்றைய ஊக்குவிப்பு இலக்கு',
      'incentiveEarned': 'சம்பாதித்தது',
      'incentiveTarget': 'இலக்கு',
      'withdraw': 'பணம் எடுக்க',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'டாஷ்போர்டு தரவை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'emptyTitle': 'டாஷ்போர்டு அளவீடுகள் இல்லை',
      'emptySub': 'பின்னர் சரிபார்க்கவும் அல்லது புதுப்பிக்கவும்.',
      'notifications': 'அறிவிப்புகள்',
      'markAllRead': 'அனைத்தையும் படித்ததாக குறிக்கவும்',
      'notifNewOrder': 'புதிய ஆர்டர் கோரிக்கை',
      'notifNewOrderSub': 'அருகில் புதிய டெலிவரி கோரிக்கை உள்ளது',
      'notifBonus': 'பீக் ஹவர் போனஸ்',
      'notifBonusSub': '₹250 போனஸ் உங்கள் வாலட்டில் வரவு',
      'notifLowRating': 'குறைந்த மதிப்பீடு எச்சரிக்கை',
      'notifLowRatingSub': 'வாடிக்கையாளர் உங்களுக்கு 2 நட்சத்திரம் அளித்தார்',
      'notifWallet': 'வாலட் வரவு',
      'notifWalletSub': "இன்றைய டெலிவரிகளில் இருந்து ₹120.00 சேர்க்கப்பட்டது",
      'notifSystem': 'கணினி புதுப்பிப்பு',
      'notifSystemSub': 'புதிய ஆப் பதிப்பு கிடைக்கிறது',
      'notifNew': 'புதியது',
      'currentDelivery': 'தற்போதைய டெலிவரி',
      'orderNo': 'ஆர்டர் #ORD12345',
      'inProgress': 'நடைபெறுகிறது',
      'pickup': 'எடுப்பு',
      'drop': 'இறக்குமிடம்',
      'distance': 'தூரம்',
      'eta': 'வருகை நேரம்',
      'payment': 'கட்டணம்',
      'navigate': 'வழிசெலுத்து',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'noActiveOrder': 'செயலில் உள்ள டெலிவரி இல்லை',
      'noActiveOrderSub': 'டெலிவரி கோரிக்கைகளைப் பெற ஆன்லைனுக்குச் செல்லவும்',
      'earningsOverview': 'வருமான கண்ணோட்டம்',
      'today': 'இன்று',
      'last7Days': '7 நாட்கள்',
      'weekly': 'வாரம்',
      'monthly': 'மாதம்',
      'totalEarnings': 'மொத்த வருமானம்',
      'scanQr': 'QR ஸ்கேன்',
      'wallet': 'வாலட்',
      'support': 'ஆதரவு',
      'history': 'வரலாறு',
      'documents': 'ஆவணங்கள்',
      'pickupLocation': 'கிரீன் மார்ட், அண்ணா சாலை',
      'dropLocation': 'காமராஜ் அவென்யூ, வேளச்சேரி',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryDashboardPage extends StatelessWidget {
  final DeliveryDashboardRepositoryBase? repository;
  final DeliveryDashboardServiceBase? service;
  final DeliveryDashboardPageBloc? bloc;

  const DeliveryDashboardPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryDashboardPageBloc>.value(
        value: bloc!,
        child: const DeliveryDashboardPageView(),
      );
    }

    return BlocProvider<DeliveryDashboardPageBloc>(
      create: (context) => DeliveryDashboardPageBloc(
        repository: repository ?? DeliveryDashboardRepository(),
        service: service ?? DeliveryDashboardService(),
      )..add(const DeliveryDashboardInitEvent()),
      child: const DeliveryDashboardPageView(),
    );
  }
}

class DeliveryDashboardPageView extends StatefulWidget {
  const DeliveryDashboardPageView({super.key});

  @override
  State<DeliveryDashboardPageView> createState() =>
      _DeliveryDashboardPageViewState();
}

class _DeliveryDashboardPageViewState extends State<DeliveryDashboardPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _pulseController.value = 1.0;
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
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
        if (state.status == DeliveryDashboardStatus.initial ||
            state.status == DeliveryDashboardStatus.loading) {
          return const _DashboardSkeletonShell();
        }

        if (state.status == DeliveryDashboardStatus.error) {
          return _DashboardErrorShell(state: state);
        }

        if (state.status == DeliveryDashboardStatus.empty) {
          return _DashboardEmptyShell(state: state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            return SingleChildScrollView(
              key: const Key('dp_dashboard_page'),
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(state: state, isDesktop: isDesktop),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _OnlineStatusCenterpiece(
                            state: state,
                            pulseAnim: _pulseAnim,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _LiveMapCard(state: state)),
                      ],
                    )
                  else ...[
                    _OnlineStatusCenterpiece(
                      state: state,
                      pulseAnim: _pulseAnim,
                    ),
                    const SizedBox(height: 20),
                    _LiveMapCard(state: state),
                  ],
                  const SizedBox(height: 24),
                  _MetricsGrid(
                    state: state,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _ActiveOrderCard(state: state)),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _EarningsChartCard(state: state),
                        ),
                      ],
                    )
                  else ...[
                    _ActiveOrderCard(state: state),
                    const SizedBox(height: 20),
                    _EarningsChartCard(state: state),
                  ],
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _RecentActivityCard(state: state),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _NotificationPanel(state: state),
                              const SizedBox(height: 24),
                              _IncentivesGoalCard(state: state),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _RecentActivityCard(state: state),
                    const SizedBox(height: 20),
                    _NotificationPanel(state: state),
                    const SizedBox(height: 20),
                    _IncentivesGoalCard(state: state),
                  ],
                  const SizedBox(height: 24),
                  _QuickActionsCard(state: state),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final DeliveryDashboardState state;
  final bool isDesktop;

  const _DashboardHeader({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_dashboard_greeting'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: DeliveryAppColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DeliveryAppColors.surface,
              border: Border.all(color: DeliveryAppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: DeliveryAppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DeliveryDashboardStrings.of('welcome', lang)}, ${state.partnerName} 👋',
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DeliveryDashboardStrings.of('tagline', lang),
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            _HeaderQuickAction(
              icon: Icons.qr_code_scanner,
              tooltip: DeliveryDashboardStrings.of('scanQr', lang),
              onTap: () {},
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: DeliveryAppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: DeliveryAppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DeliveryDashboardStrings.of('walletBalance', lang),
                        style: DeliveryAppTypography.caption.copyWith(
                          color: DeliveryAppColors.textMuted,
                        ),
                      ),
                      Text(
                        '₹${state.walletBalance.toStringAsFixed(2)}',
                        style: DeliveryAppTypography.titleMedium.copyWith(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          _NotificationBell(
            count: 3,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderQuickAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderQuickAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, color: DeliveryAppColors.primary, size: 20),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_dashboard_notification_button'),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 22),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              key: const Key('dp_dashboard_notification_badge'),
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: DeliveryAppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.buttonPrimaryText,
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

class _OnlineStatusCenterpiece extends StatelessWidget {
  final DeliveryDashboardState state;
  final Animation<double> pulseAnim;

  const _OnlineStatusCenterpiece({
    required this.state,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final isOnline = state.isOnline;

    return Container(
      key: const Key('dp_dashboard_online_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [DeliveryAppColors.successBg, const Color(0xFF07140E)]
              : [DeliveryAppColors.errorBg, const Color(0xFF140B0D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
        border: Border.all(
          color: isOnline
              ? DeliveryAppColors.primary.withValues(alpha: 0.3)
              : DeliveryAppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: isOnline ? pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: Container(
              key: const Key('dp_dashboard_glow_ring'),
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? DeliveryAppColors.primary.withValues(alpha: 0.1)
                    : DeliveryAppColors.error.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: isOnline
                        ? DeliveryAppColors.primary.withValues(alpha: 0.25)
                        : DeliveryAppColors.error.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: isOnline
                      ? DeliveryAppColors.primary
                      : DeliveryAppColors.error,
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DeliveryDashboardStrings.of('youAre', lang),
                          style: DeliveryAppTypography.caption.copyWith(
                            color: DeliveryAppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnline
                              ? DeliveryDashboardStrings.of('onlineStatus', lang)
                              : DeliveryDashboardStrings.of('offlineStatus', lang),
                          style: DeliveryAppTypography.h2.copyWith(
                            color: isOnline
                                ? DeliveryAppColors.primary
                                : DeliveryAppColors.error,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    key: const Key('dp_dashboard_toggle_switch'),
                    constraints: const BoxConstraints(
                      minWidth: 56,
                      minHeight: 48,
                    ),
                    child: Switch(
                      value: isOnline,
                      activeThumbColor: DeliveryAppColors.buttonPrimaryText,
                      activeTrackColor: DeliveryAppColors.primary,
                      inactiveThumbColor: DeliveryAppColors.textMuted,
                      inactiveTrackColor: DeliveryAppColors.surfaceLight,
                      onChanged: (val) {
                        context
                            .read<DeliveryDashboardPageBloc>()
                            .add(DeliveryDashboardToggleOnlineEvent(val));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOnline
                ? DeliveryDashboardStrings.of('onlineSub', lang)
                : DeliveryDashboardStrings.of('offlineSub', lang),
            textAlign: TextAlign.center,
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: DeliveryAppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _StatusChip(
                icon: Icons.schedule,
                label: DeliveryDashboardStrings.of('onlineSince', lang),
                value: DeliveryDashboardStrings.of('sinceMorning', lang),
                color: isOnline
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.error,
              ),
              _StatusChip(
                icon: Icons.timer_outlined,
                label: DeliveryDashboardStrings.of('onlineDuration', lang),
                value: DeliveryDashboardStrings.of('durationToday', lang),
                color: isOnline
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DeliveryButton(
              label: isOnline
                  ? DeliveryDashboardStrings.of('goOffline', lang)
                  : DeliveryDashboardStrings.of('goOnline', lang),
              onPressed: () {
                context
                    .read<DeliveryDashboardPageBloc>()
                    .add(DeliveryDashboardToggleOnlineEvent(!isOnline));
              },
              variant: isOnline
                  ? DeliveryButtonVariant.danger
                  : DeliveryButtonVariant.primary,
              icon: isOnline
                  ? Icons.power_settings_new
                  : Icons.wifi_tethering,
              height: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryChip(
      label: '$label $value',
      variant: color == DeliveryAppColors.primary
          ? DeliveryChipVariant.success
          : DeliveryChipVariant.error,
      icon: icon,
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  final DeliveryDashboardState state;

  const _LiveMapCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_dashboard_map_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryDashboardStrings.of('mapPreview', lang),
                style: DeliveryAppTypography.titleLarge.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DeliveryDashboardStrings.of('liveBadge', lang),
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.error,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF071016),
              borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusLg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusLg),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _MapGridPainter()),
                  ),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation,
                        color: DeliveryAppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 28,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 28,
                    bottom: 32,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DeliveryDashboardStrings.of('highDemandZone', lang),
                        style: DeliveryAppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
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

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 36.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

class _MetricsGrid extends StatelessWidget {
  final DeliveryDashboardState state;
  final bool isDesktop;
  final bool isTablet;

  const _MetricsGrid({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final cards = [
      _MetricCard(
        key: const Key('dp_dashboard_metric_earnings'),
        title: DeliveryDashboardStrings.of('todaysEarnings', lang),
        value: '₹${state.todayEarnings.toStringAsFixed(2)}',
        subtext:
            '▲ ${state.earningsGrowth}% ${DeliveryDashboardStrings.of('vsYesterday', lang)}',
        icon: Icons.account_balance_wallet,
        color: DeliveryAppColors.primary,
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('completedOrders', lang),
        value: '${state.todayOrdersCount}',
        subtext: '▲ 12.5% ${DeliveryDashboardStrings.of('vsYesterday', lang)}',
        icon: Icons.assignment_turned_in,
        color: DeliveryAppColors.info,
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('activeOrders', lang),
        value: '${state.activeOrdersCount}',
        subtext: DeliveryDashboardStrings.of('currentlyInProgress', lang),
        icon: Icons.shopping_bag,
        color: DeliveryAppColors.warning,
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('acceptanceRate', lang),
        value: '${state.acceptanceRate}%',
        subtext: '▲ 5% ${DeliveryDashboardStrings.of('vsLast7Days', lang)}',
        icon: Icons.shield,
        color: const Color(0xFF26A69A),
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('workingHours', lang),
        value: state.workingHours,
        subtext: DeliveryDashboardStrings.of('todaysDuration', lang),
        icon: Icons.access_time_filled,
        color: const Color(0xFFAB47BC),
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('rating', lang),
        value: '${state.performanceScore} / 5.0',
        subtext: DeliveryDashboardStrings.of('excellentPerf', lang),
        icon: Icons.star,
        color: const Color(0xFFFFD700),
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('distanceTravelled', lang),
        value: '42.5 km',
        subtext: DeliveryDashboardStrings.of('totalDistance', lang),
        icon: Icons.directions_bike,
        color: const Color(0xFF00E5FF),
      ),
      _MetricCard(
        title: DeliveryDashboardStrings.of('weeklyEarnings', lang),
        value: '₹12,850',
        subtext: '▲ 8.2% ${DeliveryDashboardStrings.of('vsLastWeek', lang)}',
        icon: Icons.trending_up,
        color: const Color(0xFF7C4DFF),
      ),
    ];

    int crossAxisCount = 2;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isDesktop ? 16 : 12,
      mainAxisSpacing: isDesktop ? 16 : 12,
      childAspectRatio: isDesktop ? 1.7 : (isTablet ? 1.6 : 1.25),
      children: cards,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: DeliveryAppTypography.h3.copyWith(
              color: DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtext,
            style: DeliveryAppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final DeliveryDashboardState state;

  const _ActiveOrderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final isOnline = state.isOnline;

return Container(
      key: const Key('dp_dashboard_active_order_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [DeliveryAppColors.successBg, DeliveryAppColors.surface]
              : [DeliveryAppColors.surface, DeliveryAppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
        border: Border.all(
          color: isOnline
              ? DeliveryAppColors.primary.withValues(alpha: 0.2)
              : DeliveryAppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryDashboardStrings.of('currentDelivery', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnline
                      ? DeliveryAppColors.primary.withValues(alpha: 0.12)
                      : DeliveryAppColors.surfaceLight,
                  borderRadius: DeliveryAppSpacing.borderRadiusPill,
                ),
                child: Text(
                  isOnline
                      ? DeliveryDashboardStrings.of('inProgress', lang)
                      : DeliveryDashboardStrings.of('noActiveOrder', lang),
                  style: DeliveryAppTypography.caption.copyWith(
                    color: isOnline
                        ? DeliveryAppColors.primary
                        : DeliveryAppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isOnline) ...[
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    color: DeliveryAppColors.warning, size: 18),
                const SizedBox(width: 8),
                Text(
                  DeliveryDashboardStrings.of('orderNo', lang),
                  style: DeliveryAppTypography.bodyLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RoutePoint(
              icon: Icons.storefront,
              label: DeliveryDashboardStrings.of('pickup', lang),
              address: DeliveryDashboardStrings.of('pickupLocation', lang),
              time: '12:05 PM',
              color: DeliveryAppColors.warning,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Container(
                width: 2,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            _RoutePoint(
              icon: Icons.home_work_outlined,
              label: DeliveryDashboardStrings.of('drop', lang),
              address: DeliveryDashboardStrings.of('dropLocation', lang),
              time: '12:35 PM',
              color: DeliveryAppColors.info,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _OrderInfoChip(
                  icon: Icons.route_outlined,
                  label: DeliveryDashboardStrings.of('distance', lang),
                  value: '4.2 km',
                ),
                _OrderInfoChip(
                  icon: Icons.access_time,
                  label: DeliveryDashboardStrings.of('eta', lang),
                  value: '18 min',
                ),
                _OrderInfoChip(
                  icon: Icons.currency_rupee,
                  label: DeliveryDashboardStrings.of('payment', lang),
                  value: '₹120.00',
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.two_wheeler_outlined,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DeliveryDashboardStrings.of('noActiveOrder', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DeliveryDashboardStrings.of('noActiveOrderSub', lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;
  final String time;
  final Color color;

  const _RoutePoint({
    required this.icon,
    required this.label,
    required this.address,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label • $time',
                style: DeliveryAppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OrderInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryChip(
      label: '$label $value',
      variant: DeliveryChipVariant.neutral,
      icon: icon,
    );
  }
}

class _EarningsChartCard extends StatefulWidget {
  final DeliveryDashboardState state;

  const _EarningsChartCard({required this.state});

  @override
  State<_EarningsChartCard> createState() => _EarningsChartCardState();
}

class _EarningsChartCardState extends State<_EarningsChartCard> {
  String _selected = 'Today';

  static const Map<String, List<double>> _data = {
    'Today': [12, 18, 14, 22, 26, 20, 28, 24, 32, 26, 30, 36],
    '7 Days': [8, 12, 10, 16, 14, 20, 18],
    'Weekly': [5, 8, 12, 10, 15, 13, 18, 22, 20, 26, 24, 28],
    'Monthly': [
      4, 6, 9, 7, 12, 14, 11, 16, 18, 15, 20, 24, 22, 27, 25, 30,
    ],
  };

  static const Map<String, String> _totals = {
    'Today': '₹1,285',
    '7 Days': '₹9,750',
    'Weekly': '₹12,850',
    'Monthly': '₹48,900',
  };

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.localeCode;
    final values = _data[_selected] ?? const [12, 18, 14, 22, 26, 20, 28, 24, 32, 26, 30, 36];

    return Container(
      key: const Key('dp_dashboard_earnings_chart_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryDashboardStrings.of('earningsOverview', lang),
                style: DeliveryAppTypography.titleLarge.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.insert_chart_outlined,
                  color: DeliveryAppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in const ['Today', '7 Days', 'Weekly', 'Monthly'])
                _FilterChip(
                  label: DeliveryDashboardStrings.of(
                    switch (key) {
                      'Today' => 'today',
                      '7 Days' => 'last7Days',
                      'Weekly' => 'weekly',
                      _ => 'monthly',
                    },
                    lang,
                  ),
                  isSelected: _selected == key,
                  onTap: () => setState(() => _selected = key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _totals[_selected] ?? '₹1,285',
                style: DeliveryAppTypography.h2.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DeliveryAppColors.primary.withValues(alpha: 0.12),
                    borderRadius: DeliveryAppSpacing.borderRadiusPill,
                  ),
                  child: Text(
                    '▲ 12.4%',
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DeliveryDashboardStrings.of('totalEarnings', lang),
            style: DeliveryAppTypography.caption.copyWith(
              color: DeliveryAppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: values,
                color: DeliveryAppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: DeliveryAppSpacing.borderRadiusPill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: DeliveryAppSpacing.md,
              vertical: DeliveryAppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                  : DeliveryAppColors.surfaceLight,
              borderRadius: DeliveryAppSpacing.borderRadiusPill,
              border: Border.all(
                color: isSelected
                    ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                    : DeliveryAppColors.borderSubtle,
              ),
            ),
            child: Text(
              label,
              style: DeliveryAppTypography.caption.copyWith(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = math.max(maxV - minV, 1.0);
    final stepX = size.width / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i * stepX,
          size.height - 6 - ((values[i] - minV) / range) * (size.height - 14),
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.quadraticBezierTo(
        prev.dx,
        prev.dy,
        midX,
        (prev.dy + curr.dy) / 2,
      );
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      points.last,
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      points.last,
      9,
      Paint()..color = color.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _RecentActivityCard extends StatelessWidget {
  final DeliveryDashboardState state;

  const _RecentActivityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return DeliveryCard(
      key: const Key('dp_dashboard_activity_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      borderRadius: DeliveryAppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryDashboardStrings.of('recentActivity', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: DeliveryAppColors.primary, size: 18),
                label: Text(
                  DeliveryDashboardStrings.of('viewAll', lang),
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.recentActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  DeliveryDashboardStrings.of('emptyTitle', lang),
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < state.recentActivities.length; i++)
              _TimelineRow(
                item: state.recentActivities[i],
                isLast: i == state.recentActivities.length - 1,
              ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final DeliveryActivityItem item;
  final bool isLast;

  const _TimelineRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (item.statusType) {
      'delivered' => (Icons.check_circle_outline, DeliveryAppColors.primary),
      'picked_up' => (Icons.shopping_bag_outlined, DeliveryAppColors.info),
      'new_order' => (Icons.near_me_outlined, DeliveryAppColors.warning),
      'reached_restaurant' =>
        (Icons.location_on_outlined, const Color(0xFFAB47BC)),
      _ => (Icons.power_settings_new, DeliveryAppColors.warning),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pushNamed('/deliveryOrderDetails');
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.time,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.subtitle} ${item.details.isNotEmpty ? '• ${item.details}' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  final DeliveryDashboardState state;

  const _NotificationPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final items = [
      (
        icon: Icons.notifications_active,
        color: DeliveryAppColors.primary,
        title: DeliveryDashboardStrings.of('notifNewOrder', lang),
        subtitle: DeliveryDashboardStrings.of('notifNewOrderSub', lang),
        time: '2m',
        unread: true,
      ),
      (
        icon: Icons.stars,
        color: DeliveryAppColors.warning,
        title: DeliveryDashboardStrings.of('notifBonus', lang),
        subtitle: DeliveryDashboardStrings.of('notifBonusSub', lang),
        time: '1h',
        unread: true,
      ),
      (
        icon: Icons.star_border,
        color: DeliveryAppColors.error,
        title: DeliveryDashboardStrings.of('notifLowRating', lang),
        subtitle: DeliveryDashboardStrings.of('notifLowRatingSub', lang),
        time: '3h',
        unread: false,
      ),
      (
        icon: Icons.account_balance_wallet,
        color: DeliveryAppColors.info,
        title: DeliveryDashboardStrings.of('notifWallet', lang),
        subtitle: DeliveryDashboardStrings.of('notifWalletSub', lang),
        time: '5h',
        unread: false,
      ),
      (
        icon: Icons.system_update_alt,
        color: const Color(0xFFAB47BC),
        title: DeliveryDashboardStrings.of('notifSystem', lang),
        subtitle: DeliveryDashboardStrings.of('notifSystemSub', lang),
        time: '1d',
        unread: false,
      ),
    ];

    return DeliveryCard(
      key: const Key('dp_dashboard_notifications_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      borderRadius: DeliveryAppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryDashboardStrings.of('notifications', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  DeliveryDashboardStrings.of('markAllRead', lang),
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items) _NotificationRow(item: item),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final ({
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
    bool unread,
  }) item;

  const _NotificationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight:
                              item.unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (item.unread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: DeliveryAppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncentivesGoalCard extends StatelessWidget {
  final DeliveryDashboardState state;

  const _IncentivesGoalCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final progress =
        (state.incentiveEarned / state.incentiveTarget).clamp(0.0, 1.0);

    return DeliveryCard(
      key: const Key('dp_dashboard_earn_banner'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      borderRadius: DeliveryAppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryDashboardStrings.of('incentivesTitle', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.stars, color: DeliveryAppColors.warning, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '₹${state.incentiveEarned.toStringAsFixed(0)} ${DeliveryDashboardStrings.of('incentiveEarned', lang)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeliveryAppTypography.titleLarge.copyWith(
                    color: DeliveryAppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${DeliveryDashboardStrings.of('incentiveTarget', lang)}: ₹${state.incentiveTarget.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(DeliveryAppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final DeliveryDashboardState state;

  const _QuickActionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final actions = [
      (
        icon: Icons.navigation,
        label: DeliveryDashboardStrings.of('navigate', lang),
        color: DeliveryAppColors.primary,
      ),
      (
        icon: Icons.qr_code_scanner,
        label: DeliveryDashboardStrings.of('scanQr', lang),
        color: DeliveryAppColors.info,
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        label: DeliveryDashboardStrings.of('wallet', lang),
        color: DeliveryAppColors.warning,
      ),
      (
        icon: Icons.support_agent,
        label: DeliveryDashboardStrings.of('support', lang),
        color: const Color(0xFFAB47BC),
      ),
      (
        icon: Icons.history,
        label: DeliveryDashboardStrings.of('history', lang),
        color: const Color(0xFF26A69A),
      ),
      (
        icon: Icons.folder_open,
        label: DeliveryDashboardStrings.of('documents', lang),
        color: const Color(0xFF00E5FF),
      ),
    ];

    return DeliveryCard(
      key: const Key('dp_dashboard_quick_actions_card'),
      padding: const EdgeInsets.all(DeliveryAppSpacing.lg),
      borderRadius: DeliveryAppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryDashboardStrings.of('quickActions', lang),
            style: DeliveryAppTypography.titleLarge.copyWith(
              color: DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth / 6).clamp(96.0, 140.0);
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final action in actions)
                    SizedBox(
                      width: itemWidth,
                      child: _QuickActionButton(
                        icon: action.icon,
                        label: action.label,
                        color: action.color,
                        onTap: () {},
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: DeliveryAppTypography.bodySmall.copyWith(
                color: DeliveryAppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeletonShell extends StatelessWidget {
  const _DashboardSkeletonShell();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DeliveryAppSpacing.xl),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.circular(DeliveryAppSpacing.radiusXl),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorShell extends StatelessWidget {
  final DeliveryDashboardState state;

  const _DashboardErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_dashboard_error'),
      child: Padding(
        padding: const EdgeInsets.all(DeliveryAppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: DeliveryAppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryDashboardStrings.of('somethingWentWrong', lang),
              textAlign: TextAlign.center,
              style: DeliveryAppTypography.h3.copyWith(
                color: DeliveryAppColors.textPrimary,
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 24),
            DeliveryButton(
              key: const Key('dp_dashboard_retry'),
              label: DeliveryDashboardStrings.of('retry', lang),
onPressed: () {
                context
                    .read<DeliveryDashboardPageBloc>()
                    .add(const DeliveryDashboardInitEvent());
              },
              variant: DeliveryButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardEmptyShell extends StatelessWidget {
  final DeliveryDashboardState state;

  const _DashboardEmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_dashboard_empty'),
      child: Padding(
        padding: const EdgeInsets.all(DeliveryAppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, color: DeliveryAppColors.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryDashboardStrings.of('emptyTitle', lang),
              style: DeliveryAppTypography.h3.copyWith(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryDashboardStrings.of('emptySub', lang),
              style: DeliveryAppTypography.bodyMedium.copyWith(
                color: DeliveryAppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            DeliveryButton(
              key: const Key('dp_dashboard_refresh'),
              label: DeliveryDashboardStrings.of('retry', lang),
              onPressed: () {
                context
                    .read<DeliveryDashboardPageBloc>()
                    .add(const DeliveryDashboardRefreshEvent());
              },
variant: DeliveryButtonVariant.primary,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
