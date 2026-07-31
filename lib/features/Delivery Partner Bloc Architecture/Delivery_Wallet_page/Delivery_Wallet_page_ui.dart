import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Wallet_page_bloc.dart';
import 'Delivery_Wallet_page_event.dart';
import 'Delivery_Wallet_page_repository.dart';
import 'Delivery_Wallet_page_service.dart';
import 'Delivery_Wallet_page_state.dart';

class DeliveryWalletStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'walletTitle': 'My Wallet',
      'tagline':
          'Track your balance, withdrawals and payment methods in one place.',
      'walletBalance': 'Wallet Balance',
      'totalEarnings': 'Total Earnings',
      'totalWithdrawn': 'Total Withdrawn',
      'bonusesEarned': 'Bonuses Earned',
      'withdraw': 'Withdraw',
      'withdrawDialogTitle': 'Withdraw Funds',
      'withdrawDialogSub':
          'Enter the amount you want to transfer to your bank account.',
      'withdrawAmountLabel': 'Amount',
      'availableBalance': 'Available Balance',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'enterValidAmount': 'Please enter a valid amount.',
      'earningsOverview': 'Earnings Overview',
      'earningsBreakdown': 'Earnings Breakdown',
      'transactionHistory': 'Transaction History',
      'searchPlaceholder': 'Search transactions...',
      'all': 'All',
      'income': 'Income',
      'withdrawals': 'Withdrawals',
      'bonuses': 'Bonuses',
      'transaction': 'Transaction',
      'date': 'Date',
      'type': 'Type',
      'status': 'Status',
      'amount': 'Amount',
      'noTransactions': 'No transactions found',
      'showing': 'Showing {start}-{end} of {total}',
      'previous': 'Previous',
      'next': 'Next',
      'paymentMethods': 'Payment Methods',
      'addPaymentMethod': 'Add Method',
      'bankAccount': 'Bank Account',
      'verified': 'Verified',
      'settlementSchedule': 'Settlement Schedule',
      'quickActions': 'Quick Actions',
      'withdrawFunds': 'Withdraw Funds',
      'downloadStatement': 'Download Statement',
      'viewIncentives': 'View Incentives',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'lastMonth': 'Last Month',
      'last3Months': 'Last 3 Months',
      'dashboard': 'Dashboard',
      'orders': 'Orders',
      'earnings': 'Earnings',
      'incentives': 'Incentives',
      'wallet': 'Wallet',
      'history': 'History',
      'profile': 'Profile',
      'vehicle': 'Vehicle',
      'documents': 'Documents',
      'settings': 'Settings',
      'help': 'Help',
      'defaultLabel': 'Default',
      'statusCompleted': 'Completed',
      'statusPending': 'Pending',
      'statusProcessing': 'Processing',
      'statusScheduled': 'Scheduled',
      'statusSettled': 'Settled',
      'notifications': 'Notifications',
      'partnerProfile': 'Partner Profile',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading your wallet.',
    },
    'ta': {
      'walletTitle': 'என் வாலட்',
      'tagline':
          'உங்கள் இருப்பு, எடுப்புகள் மற்றும் கட்டண முறைகளை ஒரே இடத்தில் பாருங்கள்.',
      'walletBalance': 'வாலட் இருப்பு',
      'totalEarnings': 'மொத்த வருமானம்',
      'totalWithdrawn': 'மொத்தம் எடுத்தவை',
      'bonusesEarned': 'போனஸ் வருவாய்',
      'withdraw': 'பணம் எடுக்க',
      'withdrawDialogTitle': 'பணம் எடுக்க',
      'withdrawDialogSub':
          'உங்கள் வங்கி கணக்கிற்கு மாற்ற விரும்பும் தொகையை உள்ளிடவும்.',
      'withdrawAmountLabel': 'தொகை',
      'availableBalance': 'கிடைக்கும் இருப்பு',
      'confirm': 'உறுதிப்படுத்து',
      'cancel': 'ரத்து செய்',
      'enterValidAmount': 'சரியான தொகையை உள்ளிடவும்.',
      'earningsOverview': 'வருமான கண்ணோட்டம்',
      'earningsBreakdown': 'வருமான விவரம்',
      'transactionHistory': 'பரிவர்த்தனை வரலாறு',
      'searchPlaceholder': 'பரிவர்த்தனைகளைத் தேடு...',
      'all': 'அனைத்தும்',
      'income': 'வருமானம்',
      'withdrawals': 'எடுப்புகள்',
      'bonuses': 'போனஸ்கள்',
      'transaction': 'பரிவர்த்தனை',
      'date': 'தேதி',
      'type': 'வகை',
      'status': 'நிலை',
      'amount': 'தொகை',
      'noTransactions': 'பரிவர்த்தனைகள் இல்லை',
      'showing': '{start}-{end} / {total} காட்டுகிறது',
      'previous': 'முந்தையது',
      'next': 'அடுத்தது',
      'paymentMethods': 'கட்டண முறைகள்',
      'addPaymentMethod': 'முறையைச் சேர்',
      'bankAccount': 'வங்கி கணக்கு',
      'verified': 'சரிபார்க்கப்பட்டது',
      'settlementSchedule': 'தீர்வு அட்டவணை',
      'quickActions': 'விரைவு செயல்கள்',
      'withdrawFunds': 'பணம் எடுக்க',
      'downloadStatement': 'அறிக்கையை பதிவிறக்கு',
      'viewIncentives': 'ஊக்கத்தொகையை பார்',
      'thisWeek': 'இந்த வாரம்',
      'thisMonth': 'இந்த மாதம்',
      'lastMonth': 'கடந்த மாதம்',
      'last3Months': 'கடந்த 3 மாதங்கள்',
      'dashboard': 'டாஷ்போர்டு',
      'orders': 'ஆர்டர்கள்',
      'earnings': 'வருமானம்',
      'incentives': 'ஊக்கத்தொகை',
      'wallet': 'வாலட்',
      'history': 'வரலாறு',
      'profile': 'சுயவிவரம்',
      'vehicle': 'வாகனம்',
      'documents': 'ஆவணங்கள்',
      'settings': 'அமைப்புகள்',
      'help': 'உதவி',
      'defaultLabel': 'இயல்பு',
      'statusCompleted': 'நிறைவடைந்தது',
      'statusPending': 'நிலுவையில்',
      'statusProcessing': 'செயலாக்கத்தில்',
      'statusScheduled': 'திட்டமிடப்பட்டது',
      'statusSettled': 'தீர்க்கப்பட்டது',
      'notifications': 'அறிவிப்புகள்',
      'partnerProfile': 'பார்ட்னர் சுயவிவரம்',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'வாலட்டை ஏற்றுவதில் பிழை ஏற்பட்டது.',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryWalletPage extends StatelessWidget {
  final DeliveryWalletPageRepositoryBase? repository;
  final DeliveryWalletPageServiceBase? service;
  final DeliveryWalletPageBloc? bloc;

  const DeliveryWalletPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryWalletPageBloc>.value(
        value: bloc!,
        child: const DeliveryWalletPageView(),
      );
    }

    return BlocProvider<DeliveryWalletPageBloc>(
      create: (context) => DeliveryWalletPageBloc(
        repository: repository ?? DeliveryWalletPageRepository(),
        service: service ?? DeliveryWalletPageService(),
      )..add(const DeliveryWalletInitEvent()),
      child: const DeliveryWalletPageView(),
    );
  }
}

class DeliveryWalletPageView extends StatelessWidget {
  const DeliveryWalletPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryWalletPageBloc, DeliveryWalletPageState>(
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
        if (state.status == DeliveryWalletStatus.initial ||
            state.status == DeliveryWalletStatus.loading) {
          return const _WalletSkeleton();
        }

        if (state.status == DeliveryWalletStatus.error) {
          return _WalletErrorShell(state: state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            final content = _WalletContent(
              state: state,
              isDesktop: isDesktop,
              isTablet: isTablet,
            );

            return SingleChildScrollView(
              key: const Key('dp_wallet_page'),
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: content,
            );
          },
        );
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;
  final bool isTablet;

  const _WalletContent({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WalletHeader(state: state, isDesktop: isDesktop),
        const SizedBox(height: 20),
        _WalletSummaryGrid(
          state: state,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        const SizedBox(height: 20),
        if (state.status == DeliveryWalletStatus.refreshing) ...[
          const LinearProgressIndicator(
            minHeight: 2,
            color: Color(0xFF00E676),
            backgroundColor: Colors.white10,
          ),
          const SizedBox(height: 16),
        ],
        _WalletPeriodSelector(state: state),
        const SizedBox(height: 20),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _WalletChartCard(state: state)),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _WalletBreakdownCard(state: state),
                    const SizedBox(height: 20),
                    _WalletQuickActionsCard(state: state),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _WalletChartCard(state: state),
          const SizedBox(height: 20),
          _WalletBreakdownCard(state: state),
          const SizedBox(height: 20),
          _WalletQuickActionsCard(state: state),
        ],
        const SizedBox(height: 20),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _WalletTransactionsPanel(state: state)),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _WalletPaymentMethodsCard(state: state),
                    const SizedBox(height: 20),
                    _WalletBankAccountCard(state: state),
                    const SizedBox(height: 20),
                    _WalletSettlementCard(state: state),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _WalletTransactionsPanel(state: state),
          const SizedBox(height: 20),
          _WalletPaymentMethodsCard(state: state),
          const SizedBox(height: 20),
          _WalletBankAccountCard(state: state),
          const SizedBox(height: 20),
          _WalletSettlementCard(state: state),
        ],
      ],
    );
  }
}

class _WalletHeader extends StatelessWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;

  const _WalletHeader({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_wallet_header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B22), Color(0xFF0F1E26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryWalletStrings.of('walletTitle', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DeliveryWalletStrings.of('tagline', lang),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DeliveryWalletStrings.of('walletBalance', lang),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '₹${state.walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(width: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              key: const Key('dp_wallet_withdraw_button'),
              onPressed: state.isWithdrawing
                  ? null
                  : () => _showWalletWithdrawDialog(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: state.isWithdrawing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.currency_rupee, size: 18),
              label: Text(
                state.isWithdrawing
                    ? '...'
                    : DeliveryWalletStrings.of('withdraw', lang),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final int badge;

  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 20)),
            if (badge > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WalletSidebar extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletSidebar({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final items = [
      ('dashboard', Icons.dashboard_outlined, Icons.dashboard),
      ('orders', Icons.receipt_long_outlined, Icons.receipt_long),
      ('earnings', Icons.trending_up, Icons.trending_up),
      ('incentives', Icons.emoji_events_outlined, Icons.emoji_events),
      ('wallet', Icons.account_balance_wallet, Icons.account_balance_wallet),
      ('history', Icons.history, Icons.history),
      ('profile', Icons.person_outline, Icons.person),
      ('vehicle', Icons.two_wheeler_outlined, Icons.two_wheeler),
      ('documents', Icons.folder_outlined, Icons.folder),
      ('settings', Icons.settings_outlined, Icons.settings),
      ('help', Icons.help_outline, Icons.help),
    ];

    return Container(
      key: const Key('dp_wallet_sidebar'),
      width: 230,
      height: 1000,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              _SidebarItem(
                key: Key('dp_wallet_sidebar_${item.$1}'),
                label: DeliveryWalletStrings.of(item.$1, lang),
                isActive: item.$1 == 'wallet',
                icon: item.$1 == 'wallet' ? item.$3 : item.$2,
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;

  const _SidebarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Semantics(
        selected: isActive,
        button: true,
        label: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF00E676).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF00E676).withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFF00E676)
                    : Colors.white.withValues(alpha: 0.55),
                size: 19,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF00E676)
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletSummaryGrid extends StatelessWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;
  final bool isTablet;

  const _WalletSummaryGrid({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final cards = [
      _WalletMetricCard(
        key: const Key('dp_wallet_summary_balance'),
        title: DeliveryWalletStrings.of('walletBalance', lang),
        value: '₹${state.walletBalance.toStringAsFixed(2)}',
        subtext: DeliveryWalletStrings.of('withdrawFunds', lang),
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF00E676),
      ),
      _WalletMetricCard(
        key: const Key('dp_wallet_summary_earnings'),
        title: DeliveryWalletStrings.of('totalEarnings', lang),
        value: '₹${state.totalEarnings.toStringAsFixed(2)}',
        subtext: DeliveryWalletStrings.of('earningsOverview', lang),
        icon: Icons.trending_up,
        color: const Color(0xFF29B6F6),
      ),
      _WalletMetricCard(
        key: const Key('dp_wallet_summary_withdrawn'),
        title: DeliveryWalletStrings.of('totalWithdrawn', lang),
        value: '₹${state.totalWithdrawn.toStringAsFixed(2)}',
        subtext: DeliveryWalletStrings.of('withdrawals', lang),
        icon: Icons.outbox_outlined,
        color: const Color(0xFF10B981),
      ),
      _WalletMetricCard(
        key: const Key('dp_wallet_summary_bonus'),
        title: DeliveryWalletStrings.of('bonusesEarned', lang),
        value: '₹${state.bonusEarnings.toStringAsFixed(2)}',
        subtext: DeliveryWalletStrings.of('bonuses', lang),
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFFFB74D),
      ),
    ];

    final crossAxisCount = isDesktop
        ? 4
        : isTablet
        ? 2
        : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.7 : (isTablet ? 1.9 : 1.3),
      children: cards,
    );
  }
}

class _WalletMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _WalletMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
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
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WalletPeriodSelector extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletPeriodSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final periods = [
      (DeliveryWalletPeriod.thisWeek, 'thisWeek'),
      (DeliveryWalletPeriod.thisMonth, 'thisMonth'),
      (DeliveryWalletPeriod.lastMonth, 'lastMonth'),
      (DeliveryWalletPeriod.last3Months, 'last3Months'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in periods)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _WalletPeriodChip(
                key: Key(
                  'dp_wallet_period_${switch (item.$1) {
                    DeliveryWalletPeriod.thisWeek => 'thisWeek',
                    DeliveryWalletPeriod.thisMonth => 'thisMonth',
                    DeliveryWalletPeriod.lastMonth => 'lastMonth',
                    DeliveryWalletPeriod.last3Months => 'last3Months',
                  }}',
                ),
                label: DeliveryWalletStrings.of(item.$2, lang),
                isSelected: state.selectedPeriod == item.$1,
                onTap: () {
                  context.read<DeliveryWalletPageBloc>().add(
                    DeliveryWalletFilterPeriodChangedEvent(item.$1),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletPeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletPeriodChip({
    super.key,
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
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00E676).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E676).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00E676)
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletChartCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletChartCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final points = state.currentPeriodPoints;

    return Container(
      key: const Key('dp_wallet_chart_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryWalletStrings.of('earningsOverview', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.insert_chart_outlined,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            key: const Key('dp_wallet_chart'),
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GlowWalletPainter(
                points: points,
                color: const Color(0xFF00E676),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBreakdownCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletBreakdownCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final slices = state.earningsBreakdown;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    return Container(
      key: const Key('dp_wallet_breakdown_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryWalletStrings.of('earningsBreakdown', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                key: const Key('dp_wallet_pie_chart'),
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _BreakdownPiePainter(slices: slices),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (final slice in slices)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorFromHex(slice.colorHex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                slice.label,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              total == 0
                                  ? '0%'
                                  : '${((slice.value / total) * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: _colorFromHex(slice.colorHex),
                                fontSize: 11,
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
        ],
      ),
    );
  }
}

class _WalletQuickActionsCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletQuickActionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final actions = [
      (
        key: 'dp_wallet_quick_withdraw',
        label: 'withdrawFunds',
        icon: Icons.currency_rupee,
        color: const Color(0xFF00E676),
      ),
      (
        key: 'dp_wallet_quick_add_payment',
        label: 'addPaymentMethod',
        icon: Icons.add_card,
        color: const Color(0xFF29B6F6),
      ),
      (
        key: 'dp_wallet_quick_statement',
        label: 'downloadStatement',
        icon: Icons.download_outlined,
        color: const Color(0xFF7C4DFF),
      ),
      (
        key: 'dp_wallet_quick_incentives',
        label: 'viewIncentives',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFFFB74D),
      ),
    ];

    return Container(
      key: const Key('dp_wallet_quick_actions'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryWalletStrings.of('quickActions', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                key: Key(action.key),
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (action.key == 'dp_wallet_quick_withdraw') {
                    _showWalletWithdrawDialog(context, state);
                  } else if (action.key == 'dp_wallet_quick_add_payment') {
                    _dispatchAddPaymentMethod(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${DeliveryWalletStrings.of(action.label, lang)}...',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(action.icon, color: action.color, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DeliveryWalletStrings.of(action.label, lang),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 18,
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

class _WalletTransactionsPanel extends StatefulWidget {
  final DeliveryWalletPageState state;

  const _WalletTransactionsPanel({required this.state});

  @override
  State<_WalletTransactionsPanel> createState() =>
      _WalletTransactionsPanelState();
}

class _WalletTransactionsPanelState extends State<_WalletTransactionsPanel> {
  static const int _pageSize = 5;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DeliveryWalletTransaction> get _visibleTransactions {
    final all = widget.state.filteredTransactions;
    if (_query.isEmpty) return all;
    return all
        .where(
          (t) =>
              t.title.toLowerCase().contains(_query.toLowerCase()) ||
              t.status.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  void _applyFilter(DeliveryWalletTransactionFilter filter) {
    setState(() => _currentPage = 0);
    context.read<DeliveryWalletPageBloc>().add(
      DeliveryWalletFilterTransactionsEvent(filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.localeCode;
    final state = widget.state;

    final all = _visibleTransactions;
    final totalPages = math.max(1, (all.length / _pageSize).ceil());
    final safePage = _currentPage.clamp(0, totalPages - 1);
    final pageItems = all.isEmpty
        ? <DeliveryWalletTransaction>[]
        : all.sublist(
            safePage * _pageSize,
            math.min((safePage + 1) * _pageSize, all.length),
          );

    final filters = [
      (
        DeliveryWalletTransactionFilter.all,
        'all',
        'dp_wallet_transaction_filter_all',
      ),
      (
        DeliveryWalletTransactionFilter.income,
        'income',
        'dp_wallet_transaction_filter_income',
      ),
      (
        DeliveryWalletTransactionFilter.withdrawals,
        'withdrawals',
        'dp_wallet_transaction_filter_withdrawals',
      ),
      (
        DeliveryWalletTransactionFilter.bonuses,
        'bonuses',
        'dp_wallet_transaction_filter_bonuses',
      ),
    ];

    return Container(
      key: const Key('dp_wallet_transactions_panel'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryWalletStrings.of('transactionHistory', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 38,
                child: TextField(
                  key: const Key('dp_wallet_transaction_search'),
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  onChanged: (value) => setState(() {
                    _query = value.trim();
                    _currentPage = 0;
                  }),
                  decoration: InputDecoration(
                    hintText: DeliveryWalletStrings.of(
                      'searchPlaceholder',
                      lang,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in filters)
                _WalletTransactionFilterChip(
                  key: Key(filter.$3),
                  label: DeliveryWalletStrings.of(filter.$2, lang),
                  isSelected: state.activeFilter == filter.$1,
                  onTap: () => _applyFilter(filter.$1),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (pageItems.isEmpty)
            _WalletEmptyHint(
              text: DeliveryWalletStrings.of('noTransactions', lang),
            )
          else ...[
            _WalletTransactionTableHeader(isDesktop: true),
            for (final tx in pageItems) _WalletTransactionRow(transaction: tx),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final summary = Text(
                all.isEmpty
                    ? DeliveryWalletStrings.of('noTransactions', lang)
                    : DeliveryWalletStrings.of('showing', lang)
                          .replaceAll('{start}', '${safePage * _pageSize + 1}')
                          .replaceAll(
                            '{end}',
                            '${math.min((safePage + 1) * _pageSize, all.length)}',
                          )
                          .replaceAll('{total}', '${all.length}'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              );
              final buttons = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WalletPaginationButton(
                    key: const Key('dp_wallet_pagination_prev'),
                    label: DeliveryWalletStrings.of('previous', lang),
                    enabled: safePage > 0,
                    onTap: () => setState(() => _currentPage--),
                  ),
                  const SizedBox(width: 8),
                  _WalletPaginationButton(
                    key: const Key('dp_wallet_pagination_next'),
                    label: DeliveryWalletStrings.of('next', lang),
                    enabled: safePage < totalPages - 1,
                    onTap: () => setState(() => _currentPage++),
                  ),
                ],
              );
              if (constraints.maxWidth < 420) {
                return Column(
                  key: const Key('dp_wallet_transactions_pagination'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: buttons),
                  ],
                );
              }
              return Row(
                key: const Key('dp_wallet_transactions_pagination'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [summary, buttons],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WalletTransactionFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletTransactionFilterChip({
    super.key,
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
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00E676).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E676).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00E676)
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletTransactionTableHeader extends StatelessWidget {
  final bool isDesktop;

  const _WalletTransactionTableHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Expanded(flex: 3, child: _WalletTableHeaderCell('Transaction')),
          const Expanded(flex: 2, child: _WalletTableHeaderCell('Date')),
          const Expanded(flex: 2, child: _WalletTableHeaderCell('Status')),
          const Expanded(flex: 2, child: _WalletTableHeaderCell('Amount')),
        ],
      ),
    );
  }
}

class _WalletTableHeaderCell extends StatelessWidget {
  final String label;

  const _WalletTableHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _WalletTransactionRow extends StatelessWidget {
  final DeliveryWalletTransaction transaction;

  const _WalletTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (transaction.type) {
      'withdrawal' => (Icons.account_balance_outlined, const Color(0xFFFFB74D)),
      'bonus' => (Icons.emoji_events_outlined, const Color(0xFF7C4DFF)),
      _ => (Icons.add_circle_outline, const Color(0xFF00E676)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _walletStatusLabel(transaction.status),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatWalletDate(transaction.date),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _WalletStatusChip(status: transaction.status),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${transaction.type == 'withdrawal' ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStatusChip extends StatelessWidget {
  final String status;

  const _WalletStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      'completed' => (const Color(0xFF00E676), 'statusCompleted'),
      'pending' => (const Color(0xFFFFB74D), 'statusPending'),
      'scheduled' => (const Color(0xFF29B6F6), 'statusScheduled'),
      _ => (const Color(0xFF7C4DFF), 'statusProcessing'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        DeliveryWalletStrings.of(label, 'en'),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WalletPaginationButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _WalletPaginationButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00E676),
          disabledForegroundColor: Colors.white24,
          side: BorderSide(
            color: enabled
                ? const Color(0xFF00E676).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _WalletPaymentMethodsCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletPaymentMethodsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_wallet_payment_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryWalletStrings.of('paymentMethods', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  key: const Key('dp_wallet_add_payment_button'),
                  onPressed: () => _dispatchAddPaymentMethod(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF29B6F6),
                    side: const BorderSide(color: Color(0xFF29B6F6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    DeliveryWalletStrings.of('addPaymentMethod', lang),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.paymentMethods.isEmpty)
            _WalletEmptyHint(
              text: DeliveryWalletStrings.of('noTransactions', lang),
            )
          else
            for (final method in state.paymentMethods)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF29B6F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        switch (method.type) {
                          'UPI' => Icons.qr_code,
                          'Card' => Icons.credit_card,
                          _ => Icons.account_balance_outlined,
                        },
                        color: const Color(0xFF29B6F6),
                        size: 19,
                      ),
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
                                  method.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (method.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00E676,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    DeliveryWalletStrings.of(
                                      'defaultLabel',
                                      lang,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            method.maskedIdentifier,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00E676),
                      size: 16,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _WalletBankAccountCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletBankAccountCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final account = state.bankAccount;

    return Container(
      key: const Key('dp_wallet_bank_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryWalletStrings.of('bankAccount', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (account?.isVerified ?? false)
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF00E676),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DeliveryWalletStrings.of('verified', lang),
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (account == null)
            _WalletEmptyHint(text: '—')
          else ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.bankName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.accountHolder,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A/C',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.maskedAccountNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'IFSC',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.ifscCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletSettlementCard extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletSettlementCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_wallet_settlement_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DeliveryWalletStrings.of('settlementSchedule', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.event_note_outlined,
                color: Color(0xFF29B6F6),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.settlementSchedule.isEmpty)
            _WalletEmptyHint(text: '—')
          else
            for (final item in state.settlementSchedule)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.status == 'settled'
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFFB74D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.period,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatWalletDate(item.date),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DeliveryWalletStrings.of(
                            item.status == 'settled'
                                ? 'statusSettled'
                                : 'statusScheduled',
                            lang,
                          ),
                          style: TextStyle(
                            color: item.status == 'settled'
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFFB74D),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

void _showWalletWithdrawDialog(
  BuildContext context,
  DeliveryWalletPageState state,
) {
  final lang = state.localeCode;
  final bloc = context.read<DeliveryWalletPageBloc>();

  showDialog<void>(
    context: context,
    builder: (dialogContext) => _WalletWithdrawDialog(
      walletBalance: state.walletBalance,
      title: DeliveryWalletStrings.of('withdrawDialogTitle', lang),
      subtitle: DeliveryWalletStrings.of('withdrawDialogSub', lang),
      amountLabel: DeliveryWalletStrings.of('withdrawAmountLabel', lang),
      availableBalance: DeliveryWalletStrings.of('availableBalance', lang),
      confirmText: DeliveryWalletStrings.of('confirm', lang),
      cancelText: DeliveryWalletStrings.of('cancel', lang),
      errorText: DeliveryWalletStrings.of('enterValidAmount', lang),
      onConfirm: (amount) =>
          bloc.add(DeliveryWalletWithdrawRequestedEvent(amount)),
    ),
  );
}

class _WalletWithdrawDialog extends StatefulWidget {
  final double walletBalance;
  final String title;
  final String subtitle;
  final String amountLabel;
  final String availableBalance;
  final String confirmText;
  final String cancelText;
  final String errorText;
  final ValueChanged<double> onConfirm;

  const _WalletWithdrawDialog({
    required this.walletBalance,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.availableBalance,
    required this.confirmText,
    required this.cancelText,
    required this.errorText,
    required this.onConfirm,
  });

  @override
  State<_WalletWithdrawDialog> createState() => _WalletWithdrawDialogState();
}

class _WalletWithdrawDialogState extends State<_WalletWithdrawDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = widget.errorText);
      return;
    }
    widget.onConfirm(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F1E26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('dp_wallet_withdraw_amount'),
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.amountLabel,
              prefixText: '₹ ',
              errorText: _error,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.availableBalance}: ₹${widget.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(color: Color(0xFF00E676), fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('dp_wallet_withdraw_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelText,
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          key: const Key('dp_wallet_withdraw_confirm'),
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E676),
            foregroundColor: Colors.black,
          ),
          child: Text(
            widget.confirmText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

void _dispatchAddPaymentMethod(BuildContext context) {
  final now = DateTime.now();
  context.read<DeliveryWalletPageBloc>().add(
    DeliveryWalletAddPaymentMethodEvent(
      DeliveryPaymentMethod(
        id: 'pm_${now.millisecondsSinceEpoch}',
        type: 'UPI',
        label: 'PhonePe',
        maskedIdentifier: 'partner@okicici',
        isDefault: false,
      ),
    ),
  );
}

class _WalletEmptyHint extends StatelessWidget {
  final String text;

  const _WalletEmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

String _walletStatusLabel(String status) {
  return switch (status) {
    'completed' => 'Completed',
    'pending' => 'Pending',
    'scheduled' => 'Scheduled',
    _ => 'Processing',
  };
}

String _formatWalletDate(DateTime date) {
  final local = date.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} · $hh:$mm';
}

Color _colorFromHex(String hex) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return const Color(0xFF00E676);
  return Color(parsed);
}

class _GlowWalletPainter extends CustomPainter {
  final List<DeliveryWalletEarningsPoint> points;
  final Color color;

  _GlowWalletPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final values = points.map((p) => p.value).toList();
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = math.max(maxV - minV, 1.0);
    final stepX = size.width / (points.length - 1);

    final offsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          i * stepX,
          size.height -
              8 -
              ((points[i].value - minV) / range) * (size.height - 16),
        ),
    ];

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.quadraticBezierTo(
        prev.dx,
        prev.dy,
        midX,
        (prev.dy + curr.dy) / 2,
      );
    }
    linePath.lineTo(offsets.last.dx, offsets.last.dy);

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
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

    for (final offset in offsets) {
      canvas.drawCircle(offset, 3, Paint()..color = color);
    }
    canvas.drawCircle(offsets.last, 5, Paint()..color = color);
    canvas.drawCircle(
      offsets.last,
      10,
      Paint()..color = color.withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(_GlowWalletPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _BreakdownPiePainter extends CustomPainter {
  final List<DeliveryWalletBreakdownSlice> slices;

  _BreakdownPiePainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.stroke;

    double startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;
      paint
        ..color = _colorFromHex(slice.colorHex)
        ..strokeWidth = 16;
      canvas.drawArc(rect.deflate(8), startAngle, sweep - 0.02, false, paint);
      startAngle += sweep;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: '₹${(total / 1000).toStringAsFixed(0)}k',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_BreakdownPiePainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _WalletSkeleton extends StatelessWidget {
  const _WalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_wallet_skeleton'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletErrorShell extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _WalletErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_wallet_error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF5252), size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryWalletStrings.of('somethingWentWrong', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('dp_wallet_retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context.read<DeliveryWalletPageBloc>().add(
                  const DeliveryWalletInitEvent(),
                );
              },
              child: Text(DeliveryWalletStrings.of('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }
}
