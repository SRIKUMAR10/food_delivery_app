import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order History_page_bloc.dart';
import 'Delivery_Order History_page_event.dart';
import 'Delivery_Order History_page_repository.dart';
import 'Delivery_Order History_page_service.dart';
import 'Delivery_Order History_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_design_system.dart';

class DeliveryOrderHistoryStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Order History',
      'subtitle': 'Track and manage all your delivery orders',
      'walletBalance': 'Wallet Balance',
      'notifications': 'Notifications',
      'profileName': 'Ravi Kumar',
      'vehicleNumber': 'TN 01 AB 1234',
      'brand': 'DELIVERY PARTNER',
      'navDashboard': 'Dashboard',
      'navOrders': 'Orders',
      'navEarnings': 'Earnings',
      'navIncentives': 'Incentives',
      'navHistory': 'History',
      'navWallet': 'Wallet',
      'navProfile': 'Profile',
      'navVehicle': 'Vehicle',
      'navDocuments': 'Documents',
      'navSettings': 'Settings',
      'navHelp': 'Help & Support',
      'promoTitle': 'Deliver More Earn More',
      'promoSub': 'Complete 50 orders this week for extra rewards',
      'viewIncentives': 'View Incentives',
      'statTotal': 'Total Orders',
      'statCompleted': 'Completed',
      'statCancelled': 'Cancelled',
      'statPending': 'Pending',
      'statEarnings': 'Total Earnings',
      'vsLastMonth': 'vs Last Month',
      'searchHint': 'Search by Order ID, Customer or Location...',
      'statusAll': 'All Status',
      'statusCompleted': 'Completed',
      'statusPending': 'Pending',
      'statusCancelled': 'Cancelled',
      'dateAll': 'All Time',
      'paymentAll': 'All Payment',
      'paymentCod': 'COD',
      'paymentOnline': 'Online',
      'filters': 'Filters',
      'colOrderId': 'Order ID',
      'colCustomer': 'Customer',
      'colLocation': 'Pickup & Drop',
      'colDate': 'Date & Time',
      'colStatus': 'Status',
      'colAmount': 'Amount',
      'colPayment': 'Payment',
      'colAction': 'Action',
      'viewDetails': 'View Details',
      'showing': 'Showing {start} to {end} of {total} orders',
      'perPage': 'per page',
      'noResultsTitle': 'No orders found',
      'noResultsSub': 'Try adjusting your search or filters to find orders.',
      'somethingWentWrong': 'Something went wrong while loading your order history.',
      'retry': 'Retry',
      'emptyTitle': 'No order history available',
      'emptySub': 'Your completed, pending and cancelled orders will appear here.',
      'refresh': 'Refresh',
      'detailsHint': 'Opening details for',
      'filtersApplied': 'Filters applied',
    },
    'ta': {
      'title': 'ஆர்டர் வரலாறு',
      'subtitle': 'உங்கள் அனைத்து டெலிவரி ஆர்டர்களையும் கண்காணித்து நிர்வகிக்கவும்',
      'walletBalance': 'வாலட் இருப்பு',
      'notifications': 'அறிவிப்புகள்',
      'profileName': 'ரவி குமார்',
      'vehicleNumber': 'TN 01 AB 1234',
      'brand': 'டெலிவரி பார்ட்னர்',
      'navDashboard': 'டாஷ்போர்டு',
      'navOrders': 'ஆர்டர்கள்',
      'navEarnings': 'வருவாய்',
      'navIncentives': 'ஊக்கத்தொகை',
      'navHistory': 'வரலாறு',
      'navWallet': 'வாலட்',
      'navProfile': 'சுயவிவரம்',
      'navVehicle': 'வாகனம்',
      'navDocuments': 'ஆவணங்கள்',
      'navSettings': 'அமைப்புகள்',
      'navHelp': 'உதவி & ஆதரவு',
      'promoTitle': 'அதிகம் டெலிவரி செய்யுங்கள் அதிகம் சம்பாதியுங்கள்',
      'promoSub': 'இந்த வாரம் 50 ஆர்டர்களை முடித்தால் கூடுதல் வெகுமதி',
      'viewIncentives': 'ஊக்கத்தொகைகளை பார்க்க',
      'statTotal': 'மொத்த ஆர்டர்கள்',
      'statCompleted': 'நிறைவு',
      'statCancelled': 'ரத்து',
      'statPending': 'நிலுவையில்',
      'statEarnings': 'மொத்த வருவாய்',
      'vsLastMonth': 'கடந்த மாதத்துடன்',
      'searchHint': 'ஆர்டர் ஐடி, வாடிக்கையாளர் அல்லது இடம் மூலம் தேடுங்கள்...',
      'statusAll': 'அனைத்து நிலைகள்',
      'statusCompleted': 'நிறைவு',
      'statusPending': 'நிலுவையில்',
      'statusCancelled': 'ரத்து',
      'dateAll': 'அனைத்து நேரம்',
      'paymentAll': 'அனைத்து கட்டணம்',
      'paymentCod': 'COD',
      'paymentOnline': 'ஆன்லைன்',
      'filters': 'வடிகட்டிகள்',
      'colOrderId': 'ஆர்டர் ஐடி',
      'colCustomer': 'வாடிக்கையாளர்',
      'colLocation': 'பிக்கப் & டிராப்',
      'colDate': 'தேதி & நேரம்',
      'colStatus': 'நிலை',
      'colAmount': 'தொகை',
      'colPayment': 'கட்டணம்',
      'colAction': 'செயல்',
      'viewDetails': 'விவரங்களை பார்க்க',
      'showing': 'மொத்தம் {total} ஆர்டர்களில் {start} முதல் {end} வரை காட்டப்படுகிறது',
      'perPage': 'ஒரு பக்கத்திற்கு',
      'noResultsTitle': 'ஆர்டர்கள் எதுவும் இல்லை',
      'noResultsSub': 'மேலும் ஆர்டர்களைக் காண உங்கள் தேடல் அல்லது வடிகட்டிகளை மாற்றவும்.',
      'somethingWentWrong': 'உங்கள் ஆர்டர் வரலாற்றை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'emptyTitle': 'ஆர்டர் வரலாறு இல்லை',
      'emptySub': 'உங்கள் நிறைவு, நிலுவை மற்றும் ரத்து ஆர்டர்கள் இங்கே தோன்றும்.',
      'refresh': 'புதுப்பிக்க',
      'detailsHint': 'விவரங்களைத் திறக்கிறது',
      'filtersApplied': 'வடிகட்டிகள் பயன்படுத்தப்பட்டன',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

const _kBackground = Color(0xFF060B11); // Dark background
const _kPanel = Color(0xFF0B1219);      // Dark panel background
const _kCard = DeliveryAppColors.surface;       // Card background matching other pages
const _kPrimary = DeliveryAppColors.primary;    // Accent green matching other pages
const _kTextSecondary = Color(0xFF94A3B8);
const _kPending = DeliveryAppColors.warning;    // Warm orange/amber matching other pages
const _kCancelled = Color(0xFFEF4444);
const _kPurple = Color(0xFF7C4DFF);     // Purple accent matching other pages

String _formatMoney(double amount) {
  final fixed = amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
  }
  return '$buffer.${parts[1]}';
}

class DeliveryOrderHistoryPage extends StatelessWidget {
  final DeliveryOrderHistoryRepositoryBase? repository;
  final DeliveryOrderHistoryServiceBase? service;
  final DeliveryOrderHistoryPageBloc? bloc;

  const DeliveryOrderHistoryPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryOrderHistoryPageBloc>.value(
        value: bloc!,
        child: const DeliveryOrderHistoryPageView(),
      );
    }
    return BlocProvider<DeliveryOrderHistoryPageBloc>(
      create: (context) => DeliveryOrderHistoryPageBloc(
        repository: repository ?? DeliveryOrderHistoryRepository(),
        service: service ?? DeliveryOrderHistoryService(),
      )..add(const DeliveryOrderHistoryInitEvent()),
      child: const DeliveryOrderHistoryPageView(),
    );
  }
}

class DeliveryOrderHistoryPageView extends StatelessWidget {
  const DeliveryOrderHistoryPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryOrderHistoryPageBloc,
        DeliveryOrderHistoryPageState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: _kCancelled,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == DeliveryOrderHistoryPageStatus.initial ||
            state.status == DeliveryOrderHistoryPageStatus.loading) {
          return const _LoadingShell();
        }
        if (state.status == DeliveryOrderHistoryPageStatus.error) {
          return _ErrorShell(state: state);
        }
        if (state.status == DeliveryOrderHistoryPageStatus.empty) {
          return _EmptyShell(state: state);
        }
        return _LoadedView(state: state);
      },
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_oh_loading'),
      color: _kBackground,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _kPrimary),
          SizedBox(height: 16),
          Text(
            'Loading order history...',
            style: TextStyle(color: _kTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _ErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_oh_error'),
      color: _kBackground,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: _kCancelled, size: 48),
          const SizedBox(height: 12),
          Text(
            DeliveryOrderHistoryStrings.of('somethingWentWrong', lang),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: _kTextSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('dp_oh_retry'),
            onPressed: () => context
                .read<DeliveryOrderHistoryPageBloc>()
                .add(const DeliveryOrderHistoryInitEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(DeliveryOrderHistoryStrings.of('retry', lang)),
          ),
        ],
      ),
    );
  }
}

class _EmptyShell extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _EmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_oh_empty'),
      color: _kBackground,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: _kTextSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            DeliveryOrderHistoryStrings.of('emptyTitle', lang),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              DeliveryOrderHistoryStrings.of('emptySub', lang),
              style: const TextStyle(color: _kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('dp_oh_refresh'),
            onPressed: () => context
                .read<DeliveryOrderHistoryPageBloc>()
                .add(const DeliveryOrderHistoryRefreshEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(DeliveryOrderHistoryStrings.of('refresh', lang)),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1024;
        return Container(
          key: const Key('dp_oh_page'),
          color: _kBackground,
          child: _ContentColumn(
            state: state,
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }
}

class _ContentColumn extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;
  final bool isDesktop;

  const _ContentColumn({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(state: state, isDesktop: isDesktop),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatsRow(state: state),
                  const SizedBox(height: 16),
                  _FilterBar(state: state),
                  const SizedBox(height: 16),
                  if (state.isEmpty)
                    _NoResults(state: state)
                  else if (isDesktop)
                    _OrdersTable(state: state)
                  else
                    _OrdersCards(state: state),
                  const SizedBox(height: 16),
                  _PaginationFooter(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;
  final bool isDesktop;

  const _TopBar({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final Widget title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliveryOrderHistoryStrings.of('title', lang),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DeliveryOrderHistoryStrings.of('subtitle', lang),
          style: const TextStyle(color: _kTextSecondary, fontSize: 13),
        ),
      ],
    );

    return Container(
      key: const Key('dp_oh_topbar'),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        16,
        isDesktop ? 24 : 16,
        12,
      ),
      decoration: const BoxDecoration(
        color: _kPanel,
        border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: title,
    );
  }
}

class _WalletBadge extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _WalletBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_oh_wallet'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: _kPrimary, size: 20),
          const SizedBox(width: 8),
          const Text(
            '₹2,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('dp_oh_notifications'),
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _kCard,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _kCancelled,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _ProfileChip({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_oh_profile'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: _kPrimary,
            child: Text(
              'RK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DeliveryOrderHistoryStrings.of('profileName', state.localeCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DeliveryOrderHistoryStrings.of(
                  'vehicleNumber',
                  state.localeCode,
                ),
                style: const TextStyle(color: _kTextSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_drop_down, color: _kTextSecondary),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _Sidebar({required this.state});

  static const List<Map<String, String>> _navItems = [
    {'icon': 'dashboard', 'key': 'navDashboard'},
    {'icon': 'orders', 'key': 'navOrders'},
    {'icon': 'earnings', 'key': 'navEarnings'},
    {'icon': 'incentives', 'key': 'navIncentives'},
    {'icon': 'history', 'key': 'navHistory'},
    {'icon': 'wallet', 'key': 'navWallet'},
    {'icon': 'profile', 'key': 'navProfile'},
    {'icon': 'vehicle', 'key': 'navVehicle'},
    {'icon': 'documents', 'key': 'navDocuments'},
    {'icon': 'settings', 'key': 'navSettings'},
    {'icon': 'help', 'key': 'navHelp'},
  ];

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'dashboard':
        return Icons.dashboard_outlined;
      case 'orders':
        return Icons.receipt_long_outlined;
      case 'earnings':
        return Icons.payments_outlined;
      case 'incentives':
        return Icons.emoji_events_outlined;
      case 'history':
        return Icons.history;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'profile':
        return Icons.person_outline;
      case 'vehicle':
        return Icons.two_wheeler_outlined;
      case 'documents':
        return Icons.folder_open_outlined;
      case 'settings':
        return Icons.settings_outlined;
      default:
        return Icons.headset_mic_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_oh_sidebar'),
      color: _kPanel,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.two_wheeler,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DeliveryOrderHistoryStrings.of('brand', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x14FFFFFF), height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in _navItems)
                    _SidebarItem(
                      icon: _iconFor(item['icon']!),
                      label: DeliveryOrderHistoryStrings.of(
                        item['key']!,
                        lang,
                      ),
                      active: item['key'] == 'navHistory',
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0x14FFFFFF), height: 1),
            _PromoCard(state: state),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: active ? _kPrimary.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: active
            ? Border.all(color: _kPrimary.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: active ? _kPrimary : _kTextSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _kTextSecondary,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _kPrimary, size: 18),
          ],
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _PromoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF123524), Color(0xFF1C2533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.two_wheeler, color: _kPrimary, size: 28),
            const SizedBox(height: 10),
            Text(
              DeliveryOrderHistoryStrings.of('promoTitle', lang),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DeliveryOrderHistoryStrings.of('promoSub', lang),
              style: const TextStyle(color: _kTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  DeliveryOrderHistoryStrings.of('viewIncentives', lang),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Dot(active: true),
                SizedBox(width: 6),
                _Dot(active: false),
                SizedBox(width: 6),
                _Dot(active: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? _kPrimary : _kTextSecondary.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double cardWidth = width >= 1200
            ? (width - 4 * 16) / 5
            : width >= 700
                ? (width - 2 * 16) / 3
                : width;
        final lang = state.localeCode;
        final stats = state.stats;

        final List<Widget> cards = [
          _StatCard(
            cardKey: const Key('dp_oh_stat_total'),
            label: DeliveryOrderHistoryStrings.of('statTotal', lang),
            value: '${stats.totalOrders}',
            delta: '+${stats.totalOrdersDelta}%',
            deltaLabel: DeliveryOrderHistoryStrings.of('vsLastMonth', lang),
            color: _kPrimary,
            sparkline: const [2.0, 3.0, 4.0, 3.0, 5.0, 4.0, 6.0],
          ),
          _StatCard(
            cardKey: const Key('dp_oh_stat_completed'),
            label: DeliveryOrderHistoryStrings.of('statCompleted', lang),
            value: '${stats.completedCount}',
            subValue: '${stats.completedPercent.toStringAsFixed(1)}% of Total',
            color: _kPrimary,
            sparkline: const [1.0, 2.0, 3.0, 3.0, 4.0, 5.0, 6.0],
          ),
          _StatCard(
            cardKey: const Key('dp_oh_stat_cancelled'),
            label: DeliveryOrderHistoryStrings.of('statCancelled', lang),
            value: '${stats.cancelledCount}',
            subValue: '${stats.cancelledPercent.toStringAsFixed(1)}% of Total',
            color: _kCancelled,
            sparkline: const [3.0, 2.0, 1.0, 2.0, 1.0, 0.0, 1.0],
          ),
          _StatCard(
            cardKey: const Key('dp_oh_stat_pending'),
            label: DeliveryOrderHistoryStrings.of('statPending', lang),
            value: '${stats.pendingCount}',
            subValue: '${stats.pendingPercent.toStringAsFixed(1)}% of Total',
            color: _kPending,
            sparkline: const [1.0, 2.0, 1.0, 3.0, 2.0, 4.0, 3.0],
          ),
          _StatCard(
            cardKey: const Key('dp_oh_stat_earnings'),
            label: DeliveryOrderHistoryStrings.of('statEarnings', lang),
            value: '₹${_formatMoney(stats.totalEarnings)}',
            delta: '+${stats.earningsDelta}%',
            deltaLabel: DeliveryOrderHistoryStrings.of('vsLastMonth', lang),
            color: _kPurple,
            sparkline: const [10.0, 14.0, 12.0, 18.0, 16.0, 22.0, 26.0],
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final card in cards)
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final Key cardKey;
  final String label;
  final String value;
  final String? subValue;
  final String? delta;
  final String? deltaLabel;
  final Color color;
  final List<double> sparkline;

  const _StatCard({
    required this.cardKey,
    required this.label,
    required this.value,
    this.subValue,
    this.delta,
    this.deltaLabel,
    required this.color,
    required this.sparkline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: _kTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (delta != null)
            Row(
              children: [
                Icon(Icons.trending_up, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  delta!,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    deltaLabel ?? '',
                    style: const TextStyle(
                      color: _kTextSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else if (subValue != null)
            Text(
              subValue!,
              style: const TextStyle(color: _kTextSecondary, fontSize: 12),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(data: sparkline, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final double minValue = data.reduce(math.min);
    final double maxValue = data.reduce(math.max);
    final double range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    final Path line = Path();
    for (var i = 0; i < data.length; i++) {
      final double x = i / (data.length - 1) * size.width;
      final double y = size.height - (data[i] - minValue) / range * size.height;
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, stroke);

    final Path fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
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
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

class _FilterBar extends StatefulWidget {
  final DeliveryOrderHistoryPageState state;

  const _FilterBar({required this.state});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.state.searchQuery);
  }

  @override
  void didUpdateWidget(_FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.searchQuery != widget.state.searchQuery &&
        _searchController.text != widget.state.searchQuery) {
      _searchController.value = TextEditingValue(
        text: widget.state.searchQuery,
        selection: TextSelection.collapsed(
          offset: widget.state.searchQuery.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final lang = state.localeCode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool narrow = constraints.maxWidth < 700;
          final Widget search = SizedBox(
            width: narrow ? double.infinity : 260,
            child: DeliveryTextField(
              key: const Key('dp_oh_search_field'),
              controller: _searchController,
              hintText: DeliveryOrderHistoryStrings.of('searchHint', lang),
              prefixIcon: const Icon(Icons.search, color: _kTextSecondary),
              onChanged: (value) => context
                  .read<DeliveryOrderHistoryPageBloc>()
                  .add(DeliveryOrderHistorySearchChangedEvent(value)),
            ),
          );

          final Widget status = _FilterDropdown<DeliveryOrderHistoryStatusFilter>(
            dropdownKey: const Key('dp_oh_status_filter'),
            expanded: narrow,
            value: state.statusFilter,
            items: const [
              DropdownMenuItem(
                value: DeliveryOrderHistoryStatusFilter.all,
                child: Text('All Status'),
              ),
              DropdownMenuItem(
                value: DeliveryOrderHistoryStatusFilter.completed,
                child: Text('Completed'),
              ),
              DropdownMenuItem(
                value: DeliveryOrderHistoryStatusFilter.pending,
                child: Text('Pending'),
              ),
              DropdownMenuItem(
                value: DeliveryOrderHistoryStatusFilter.cancelled,
                child: Text('Cancelled'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                context
                    .read<DeliveryOrderHistoryPageBloc>()
                    .add(DeliveryOrderHistoryStatusFilterChangedEvent(value));
              }
            },
          );

          final Widget date = _FilterDropdown<String>(
            dropdownKey: const Key('dp_oh_date_filter'),
            expanded: narrow,
            value: state.dateLabel,
            items: [
              DropdownMenuItem(
                value: DeliveryOrderHistoryStrings.of('dateAll', lang),
                child: Text(DeliveryOrderHistoryStrings.of('dateAll', lang)),
              ),
              const DropdownMenuItem(
                value: 'May 18, 2025 - May 24, 2025',
                child: Text('May 18, 2025 - May 24, 2025'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              final int? startEpoch;
              final int? endEpoch;
              if (value == DeliveryOrderHistoryStrings.of('dateAll', lang)) {
                startEpoch = null;
                endEpoch = null;
              } else {
                startEpoch =
                    DateTime.utc(2025, 5, 18).millisecondsSinceEpoch ~/ 1000;
                endEpoch = DateTime.utc(2025, 5, 24, 23, 59)
                    .millisecondsSinceEpoch ~/ 1000;
              }
              context
                  .read<DeliveryOrderHistoryPageBloc>()
                  .add(DeliveryOrderHistoryDateRangeChangedEvent(
                    startEpoch: startEpoch,
                    endEpoch: endEpoch,
                    dateLabel: value,
                  ));
            },
          );

          final Widget payment = _FilterDropdown<DeliveryOrderHistoryPaymentFilter>(
            dropdownKey: const Key('dp_oh_payment_filter'),
            expanded: narrow,
            value: state.paymentFilter,
            items: const [
              DropdownMenuItem(
                value: DeliveryOrderHistoryPaymentFilter.all,
                child: Text('All Payment'),
              ),
              DropdownMenuItem(
                value: DeliveryOrderHistoryPaymentFilter.cod,
                child: Text('COD'),
              ),
              DropdownMenuItem(
                value: DeliveryOrderHistoryPaymentFilter.online,
                child: Text('Online'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                context
                    .read<DeliveryOrderHistoryPageBloc>()
                    .add(DeliveryOrderHistoryPaymentFilterChangedEvent(value));
              }
            },
          );

          final Widget filtersButton = ElevatedButton.icon(
            key: const Key('dp_oh_filters_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    DeliveryOrderHistoryStrings.of('filtersApplied', lang),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            icon: const Icon(Icons.tune, size: 18),
            label: Text(DeliveryOrderHistoryStrings.of('filters', lang)),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: status),
                    const SizedBox(width: 12),
                    Expanded(child: payment),
                  ],
                ),
                const SizedBox(height: 12),
                date,
                const SizedBox(height: 12),
                filtersButton,
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              search,
              status,
              date,
              payment,
              filtersButton,
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final Key? dropdownKey;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool expanded;

  const _FilterDropdown({
    this.dropdownKey,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: dropdownKey,
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: expanded,
          dropdownColor: _kCard,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: _kTextSecondary),
        ),
      ),
    );
  }
}

class _OrdersTable extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _OrdersTable({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_oh_table'),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(130),
            1: FixedColumnWidth(180),
            2: FixedColumnWidth(220),
            3: FixedColumnWidth(150),
            4: FixedColumnWidth(150),
            5: FixedColumnWidth(110),
            6: FixedColumnWidth(90),
            7: FixedColumnWidth(140),
          },
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _kBackground),
              children: [
                _HeaderCell(DeliveryOrderHistoryStrings.of('colOrderId', lang)),
                _HeaderCell(
                    DeliveryOrderHistoryStrings.of('colCustomer', lang)),
                _HeaderCell(
                    DeliveryOrderHistoryStrings.of('colLocation', lang)),
                _HeaderCell(DeliveryOrderHistoryStrings.of('colDate', lang)),
                _HeaderCell(DeliveryOrderHistoryStrings.of('colStatus', lang)),
                _HeaderCell(DeliveryOrderHistoryStrings.of('colAmount', lang)),
                _HeaderCell(DeliveryOrderHistoryStrings.of('colPayment', lang)),
                _HeaderCell(DeliveryOrderHistoryStrings.of('colAction', lang)),
              ],
            ),
            for (final order in state.pageOrders)
              TableRow(
                key: ValueKey('dp_oh_row_${order.orderId}'),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: _kTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.phoneNumber,
                          style: const TextStyle(
                            color: _kTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LocationLine(icon: Icons.storefront_outlined,
                            text: order.pickupAddress),
                        const SizedBox(height: 4),
                        _LocationLine(
                            icon: Icons.place_outlined, text: order.dropAddress),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      order.dateLabel,
                      style: const TextStyle(color: _kTextSecondary, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _StatusBadge(status: order.status),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '₹${order.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      order.paymentType,
                      style: const TextStyle(color: _kTextSecondary, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton(
                      key: Key('dp_oh_view_details_${order.orderId}'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/deliveryOrderDetails',
                          arguments: {'orderId': order.orderId},
                        );
                      },
                      child: const Text(
                        'View Details',
                        style: TextStyle(color: _kPrimary),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          color: _kTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LocationLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _kTextSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryOrderHistoryStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      DeliveryOrderHistoryStatus.completed => _kPrimary,
      DeliveryOrderHistoryStatus.pending => _kPending,
      DeliveryOrderHistoryStatus.cancelled => _kCancelled,
    };
    final String label = switch (status) {
      DeliveryOrderHistoryStatus.completed => 'Completed',
      DeliveryOrderHistoryStatus.pending => 'Pending',
      DeliveryOrderHistoryStatus.cancelled => 'Cancelled',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersCards extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _OrdersCards({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Column(
      children: [
        for (final order in state.pageOrders)
          Container(
            key: Key('dp_oh_card_${order.orderId}'),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.phoneNumber,
                  style: const TextStyle(
                    color: _kTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 14, color: _kTextSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.pickupAddress,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: _kTextSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.dropAddress,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  order.dateLabel,
                  style: const TextStyle(color: _kTextSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '₹${order.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.paymentType,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${order.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: _kTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: Key('dp_oh_view_details_${order.orderId}'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${DeliveryOrderHistoryStrings.of('detailsHint', lang)} ${order.orderId}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _kPrimary,
                      backgroundColor: _kPrimary.withValues(alpha: 0.1),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _NoResults({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_oh_no_results'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: _kTextSecondary, size: 40),
          const SizedBox(height: 10),
          Text(
            DeliveryOrderHistoryStrings.of('noResultsTitle', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DeliveryOrderHistoryStrings.of('noResultsSub', lang),
            style: const TextStyle(color: _kTextSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final DeliveryOrderHistoryPageState state;

  const _PaginationFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final int totalPages = state.totalPages;
    final String summary = DeliveryOrderHistoryStrings.of('showing', lang)
        .replaceAll('{start}', '${state.visibleStart}')
        .replaceAll('{end}', '${state.visibleEnd}')
        .replaceAll('{total}', '${state.totalFiltered}');

    final List<int> pages = _visiblePages(state.page, totalPages);

    return Container(
      key: const Key('dp_oh_pagination'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool narrow = constraints.maxWidth < 700;
          final Widget summaryText = Text(
            summary,
            key: const Key('dp_oh_summary'),
            style: const TextStyle(color: _kTextSecondary, fontSize: 13),
          );

          final Widget rowsSelector = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FilterDropdown<int>(
                dropdownKey: const Key('dp_oh_rows_selector'),
                value: state.pageSize,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<DeliveryOrderHistoryPageBloc>()
                        .add(DeliveryOrderHistoryPageSizeChangedEvent(value));
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                DeliveryOrderHistoryStrings.of('perPage', lang),
                style: const TextStyle(color: _kTextSecondary, fontSize: 12),
              ),
            ],
          );

          final Widget controls = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _PageButton(
                buttonKey: const Key('dp_oh_prev'),
                label: '<',
                onTap: state.page <= 1
                    ? null
                    : () => context
                        .read<DeliveryOrderHistoryPageBloc>()
                        .add(
                          DeliveryOrderHistoryPageChangedEvent(state.page - 1),
                        ),
              ),
              for (final page in pages)
                  _PageButton(
                    buttonKey: Key('dp_oh_page_$page'),
                  label: '$page',
                  selected: page == state.page,
                  onTap: page == state.page
                      ? null
                      : () => context
                          .read<DeliveryOrderHistoryPageBloc>()
                          .add(DeliveryOrderHistoryPageChangedEvent(page)),
                ),
              _PageButton(
                buttonKey: const Key('dp_oh_next'),
                label: '>',
                onTap: state.page >= totalPages
                    ? null
                    : () => context
                        .read<DeliveryOrderHistoryPageBloc>()
                        .add(
                          DeliveryOrderHistoryPageChangedEvent(state.page + 1),
                        ),
              ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summaryText,
                const SizedBox(height: 12),
                rowsSelector,
                const SizedBox(height: 12),
                controls,
              ],
            );
          }

          return Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              summaryText,
              rowsSelector,
              controls,
            ],
          );
        },
      ),
    );
  }

  List<int> _visiblePages(int current, int total) {
    if (total <= 7) {
      return List<int>.generate(total, (i) => i + 1);
    }
    final int start = current <= 4 ? 1 : current - 2;
    final int end = start + 4 > total ? total : start + 4;
    return List<int>.generate(end - start + 1, (i) => start + i);
  }
}

class _PageButton extends StatelessWidget {
  final Key buttonKey;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _PageButton({
    required this.buttonKey,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: buttonKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kPrimary : _kBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _kPrimary : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _kTextSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
