import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Earnings Dashboard_page_bloc.dart';
import 'Delivery_Earnings Dashboard_page_event.dart';
import 'Delivery_Earnings Dashboard_page_repository.dart';
import 'Delivery_Earnings Dashboard_page_service.dart';
import 'Delivery_Earnings Dashboard_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_design_system.dart';

class DeliveryEarningsDashboardStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'earningsOverview': 'Earnings Overview',
      'welcomeBack': 'Welcome back',
      'tagline':
          'Track your earnings, incentives and withdrawals in one place.',
      'totalEarnings': 'Total Earnings',
      'todayEarnings': "Today's Earnings",
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'vsLastWeek': 'vs Last Week',
      'walletBalance': 'Wallet Balance',
      'pendingWithdrawal': 'Pending Withdrawal',
      'totalWithdrawn': 'Total Withdrawn',
      'withdraw': 'Withdraw',
      'withdrawDialogTitle': 'Withdraw Funds',
      'withdrawDialogSub':
          'Enter the amount you want to transfer to your bank account.',
      'withdrawAmountLabel': 'Amount',
      'availableBalance': 'Available Balance',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'enterValidAmount': 'Please enter a valid amount.',
      'overview': 'Overview',
      'transactions': 'Transactions',
      'withdrawals': 'Withdrawals',
      'today': 'Today',
      'last7Days': '7 Days',
      'thisWeekRange': 'This Week',
      'thisMonthRange': 'This Month',
      'mediaUploadTitle': 'Upload Delivery Proof',
      'mediaUploadSub': 'Attach photos or videos to complete your records.',
      'uploadMedia': 'Upload Media',
      'uploading': 'Uploading...',
      'uploadComplete': 'Upload complete',
      'recentTransactions': 'Recent Transactions',
      'withdrawalHistory': 'Withdrawal History',
      'noTransactions': 'No transactions found',
      'noWithdrawals': 'No withdrawals yet',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading earnings data.',
      'bankTransfer': 'Bank Transfer',
      'statusCompleted': 'Completed',
      'statusPending': 'Pending',
      'statusProcessing': 'Processing',
      'growthLabel': '▲ {growth}% {vs}',
    },
    'ta': {
      'earningsOverview': 'வருமான கண்ணோட்டம்',
      'welcomeBack': 'மீண்டும் வரவேற்கிறோம்',
      'tagline':
          'உங்கள் வருமானம், ஊக்கத்தொகை மற்றும் எடுப்புகளை ஒரே இடத்தில் பாருங்கள்.',
      'totalEarnings': 'மொத்த வருமானம்',
      'todayEarnings': 'இன்றைய வருமானம்',
      'thisWeek': 'இந்த வாரம்',
      'thisMonth': 'இந்த மாதம்',
      'vsLastWeek': 'கடந்த வார ஒப்பீடு',
      'walletBalance': 'வாலட் இருப்பு',
      'pendingWithdrawal': 'நிலுவை பணம் எடுப்பு',
      'totalWithdrawn': 'மொத்தம் எடுத்தவை',
      'withdraw': 'பணம் எடுக்க',
      'withdrawDialogTitle': 'பணம் எடுக்க',
      'withdrawDialogSub':
          'உங்கள் வங்கி கணக்கிற்கு மாற்ற விரும்பும் தொகையை உள்ளிடவும்.',
      'withdrawAmountLabel': 'தொகை',
      'availableBalance': 'கிடைக்கும் இருப்பு',
      'confirm': 'உறுதிப்படுத்து',
      'cancel': 'ரத்து செய்',
      'enterValidAmount': 'சரியான தொகையை உள்ளிடவும்.',
      'overview': 'கண்ணோட்டம்',
      'transactions': 'பரிவர்த்தனைகள்',
      'withdrawals': 'எடுப்புகள்',
      'today': 'இன்று',
      'last7Days': '7 நாட்கள்',
      'thisWeekRange': 'இந்த வாரம்',
      'thisMonthRange': 'இந்த மாதம்',
      'mediaUploadTitle': 'டெலிவரி ஆதாரத்தை பதிவேற்றவும்',
      'mediaUploadSub': 'பதிவுகளை முடிக்க புகைப்படங்கள் அல்லது வீடியோக்களை இணைக்கவும்.',
      'uploadMedia': 'மீடியாவை பதிவேற்று',
      'uploading': 'பதிவேற்றுகிறது...',
      'uploadComplete': 'பதிவேற்றம் முடிந்தது',
      'recentTransactions': 'சமீபத்திய பரிவர்த்தனைகள்',
      'withdrawalHistory': 'எடுப்பு வரலாறு',
      'noTransactions': 'பரிவர்த்தனைகள் இல்லை',
      'noWithdrawals': 'எந்த எடுப்பும் இல்லை',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'வருமானத் தரவை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'bankTransfer': 'வங்கி பரிமாற்றம்',
      'statusCompleted': 'நிறைவடைந்தது',
      'statusPending': 'நிலுவையில்',
      'statusProcessing': 'செயலாக்கத்தில்',
      'growthLabel': '▲ {growth}% {vs}',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryEarningsDashboardPage extends StatelessWidget {
  final DeliveryEarningsDashboardRepositoryBase? repository;
  final DeliveryEarningsDashboardServiceBase? service;
  final DeliveryEarningsDashboardPageBloc? bloc;

  const DeliveryEarningsDashboardPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryEarningsDashboardPageBloc>.value(
        value: bloc!,
        child: const DeliveryEarningsDashboardPageView(),
      );
    }

    return BlocProvider<DeliveryEarningsDashboardPageBloc>(
      create: (context) => DeliveryEarningsDashboardPageBloc(
        repository: repository ?? DeliveryEarningsDashboardRepository(),
        service: service ?? DeliveryEarningsDashboardService(),
      )..add(const DeliveryEarningsInitEvent()),
      child: const DeliveryEarningsDashboardPageView(),
    );
  }
}

class DeliveryEarningsDashboardPageView extends StatelessWidget {
  const DeliveryEarningsDashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryEarningsDashboardPageBloc,
        DeliveryEarningsDashboardState>(
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
        if (state.status == DeliveryEarningsStatus.initial ||
            state.status == DeliveryEarningsStatus.loading) {
          return const _EarningsSkeleton();
        }

        if (state.status == DeliveryEarningsStatus.error) {
          return _EarningsErrorShell(state: state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            return SingleChildScrollView(
              key: const Key('dp_earnings_page'),
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EarningsHeader(state: state, isDesktop: isDesktop),
                  const SizedBox(height: 20),
                  _EarningsTabSelector(state: state),
                  const SizedBox(height: 20),
                  if (state.status == DeliveryEarningsStatus.refreshing) ...[
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: DeliveryAppColors.primary,
                      backgroundColor: Colors.white10,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.selectedTab == EarningsTab.overview) ...[
                    _EarningsSummaryGrid(
                      state: state,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 20),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _EarningsChartCard(state: state),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _EarningsWalletCard(state: state),
                                const SizedBox(height: 20),
                                _EarningsMediaUploadCard(state: state),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _EarningsChartCard(state: state),
                      const SizedBox(height: 20),
                      _EarningsWalletCard(state: state),
                      const SizedBox(height: 20),
                      _EarningsMediaUploadCard(state: state),
                    ],
                  ] else if (state.selectedTab == EarningsTab.transactions) ...[
                    _EarningsTransactionsPanel(state: state),
                  ] else ...[
                    _EarningsWithdrawalsPanel(state: state),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EarningsHeader extends StatelessWidget {
  final DeliveryEarningsDashboardState state;
  final bool isDesktop;

  const _EarningsHeader({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_earnings_greeting'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.background.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: DeliveryAppColors.buttonPrimaryText,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryEarningsDashboardStrings.of(
                    'earningsOverview',
                    lang,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DeliveryEarningsDashboardStrings.of('tagline', lang),
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
                color: DeliveryAppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DeliveryEarningsDashboardStrings.of('walletBalance', lang),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '₹${state.walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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

class _EarningsTabSelector extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsTabSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final tabs = [
      (tab: EarningsTab.overview, label: 'overview'),
      (tab: EarningsTab.transactions, label: 'transactions'),
      (tab: EarningsTab.withdrawals, label: 'withdrawals'),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          for (final item in tabs)
            Expanded(
              child: _EarningsTabChip(
                key: Key(
                  'dp_earnings_tab_${switch (item.tab) {
                    EarningsTab.overview => 'overview',
                    EarningsTab.transactions => 'transactions',
                    EarningsTab.withdrawals => 'withdrawals',
                  }}',
                ),
                label: DeliveryEarningsDashboardStrings.of(
                  item.label,
                  lang,
                ),
                isSelected: state.selectedTab == item.tab,
                onTap: () {
                  context
                      .read<DeliveryEarningsDashboardPageBloc>()
                      .add(DeliveryEarningsTabChangedEvent(item.tab));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EarningsTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EarningsTabChip({
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
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? DeliveryAppColors.primary.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EarningsSummaryGrid extends StatelessWidget {
  final DeliveryEarningsDashboardState state;
  final bool isDesktop;
  final bool isTablet;

  const _EarningsSummaryGrid({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final cards = [
      _EarningsMetricCard(
        key: const Key('dp_earnings_summary_total'),
        title: DeliveryEarningsDashboardStrings.of('totalEarnings', lang),
        value: '₹${state.totalEarnings.toStringAsFixed(2)}',
        subtext:
            '${DeliveryEarningsDashboardStrings.of('growthLabel', lang).replaceAll('{growth}', state.earningsGrowth.toStringAsFixed(1)).replaceAll('{vs}', DeliveryEarningsDashboardStrings.of('vsLastWeek', lang))}',
        icon: Icons.trending_up,
        color: DeliveryAppColors.primary,
      ),
      _EarningsMetricCard(
        key: const Key('dp_earnings_summary_today'),
        title: DeliveryEarningsDashboardStrings.of('todayEarnings', lang),
        value: '₹${state.todayEarnings.toStringAsFixed(2)}',
        subtext: DeliveryEarningsDashboardStrings.of('today', lang),
        icon: Icons.account_balance_wallet,
        color: DeliveryAppColors.info,
      ),
      _EarningsMetricCard(
        key: const Key('dp_earnings_summary_week'),
        title: DeliveryEarningsDashboardStrings.of('thisWeek', lang),
        value: '₹${state.weeklyEarnings.toStringAsFixed(2)}',
        subtext: DeliveryEarningsDashboardStrings.of('last7Days', lang),
        icon: Icons.calendar_view_week,
        color: const Color(0xFF10B981),
      ),
      _EarningsMetricCard(
        key: const Key('dp_earnings_summary_month'),
        title: DeliveryEarningsDashboardStrings.of('thisMonth', lang),
        value: '₹${state.monthlyEarnings.toStringAsFixed(2)}',
        subtext: DeliveryEarningsDashboardStrings.of('thisMonthRange', lang),
        icon: Icons.calendar_month,
        color: const Color(0xFF7C4DFF),
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

class _EarningsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _EarningsMetricCard({
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
        color: DeliveryAppColors.surface,
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

class _EarningsChartCard extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsChartCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final points = state.currentRangePoints;

    final ranges = [
      (range: EarningsDateRange.today, label: 'today'),
      (range: EarningsDateRange.last7Days, label: 'last7Days'),
      (range: EarningsDateRange.thisWeek, label: 'thisWeekRange'),
      (range: EarningsDateRange.thisMonth, label: 'thisMonthRange'),
    ];

    return Container(
      key: const Key('dp_earnings_chart_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
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
                  DeliveryEarningsDashboardStrings.of(
                    'totalEarnings',
                    lang,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
              for (final item in ranges)
                _RangeChip(
                  key: Key(
                    'dp_earnings_range_${switch (item.range) {
                      EarningsDateRange.today => 'today',
                      EarningsDateRange.last7Days => 'last7Days',
                      EarningsDateRange.thisWeek => 'thisWeek',
                      EarningsDateRange.thisMonth => 'thisMonth',
                    }}',
                  ),
                  label: DeliveryEarningsDashboardStrings.of(
                    item.label,
                    lang,
                  ),
                  isSelected: state.selectedRange == item.range,
                  onTap: () {
                    context
                        .read<DeliveryEarningsDashboardPageBloc>()
                        .add(DeliveryEarningsRangeChangedEvent(item.range));
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            key: const Key('dp_earnings_chart'),
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GlowEarningsPainter(
                points: points,
                color: DeliveryAppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeChip({
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
                  ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? DeliveryAppColors.primary
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

class _EarningsWalletCard extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsWalletCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_earnings_wallet_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DeliveryAppColors.background, DeliveryAppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DeliveryEarningsDashboardStrings.of('walletBalance', lang),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.account_balance_wallet,
                  color: DeliveryAppColors.primary, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${state.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WalletStat(
                  label: DeliveryEarningsDashboardStrings.of(
                    'pendingWithdrawal',
                    lang,
                  ),
                  value: '₹${state.pendingWithdrawal.toStringAsFixed(2)}',
                  color: DeliveryAppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletStat(
                  label: DeliveryEarningsDashboardStrings.of(
                    'totalWithdrawn',
                    lang,
                  ),
                  value: '₹${state.totalWithdrawn.toStringAsFixed(2)}',
                  color: DeliveryAppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              key: const Key('dp_earnings_withdraw_button'),
              onPressed: state.isWithdrawing
                  ? null
                  : () => _showWithdrawDialog(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                    : DeliveryEarningsDashboardStrings.of('withdraw', lang),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _WalletStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

void _showWithdrawDialog(
  BuildContext context,
  DeliveryEarningsDashboardState state,
) {
  final lang = state.localeCode;
  final bloc = context.read<DeliveryEarningsDashboardPageBloc>();

  DeliveryWithdrawDialog.show(
    context,
    walletBalance: state.walletBalance,
    title: DeliveryEarningsDashboardStrings.of('withdrawDialogTitle', lang),
    subtitle: DeliveryEarningsDashboardStrings.of('withdrawDialogSub', lang),
    amountLabel: DeliveryEarningsDashboardStrings.of('withdrawAmountLabel', lang),
    availableBalanceText: DeliveryEarningsDashboardStrings.of('availableBalance', lang),
    confirmText: DeliveryEarningsDashboardStrings.of('confirm', lang),
    cancelText: DeliveryEarningsDashboardStrings.of('cancel', lang),
    errorText: DeliveryEarningsDashboardStrings.of('enterValidAmount', lang),
    onConfirm: (amount) => bloc.add(DeliveryEarningsWithdrawEvent(amount)),
  );
}

class _EarningsMediaUploadCard extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsMediaUploadCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_earnings_media_upload_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
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
                  DeliveryEarningsDashboardStrings.of(
                    'mediaUploadTitle',
                    lang,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.video_library_outlined,
                  color: Color(0xFF10B981), size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DeliveryEarningsDashboardStrings.of('mediaUploadSub', lang),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (state.isMediaUploading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                key: const Key('dp_earnings_media_upload_progress'),
                value: state.mediaUploadProgress,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(DeliveryAppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DeliveryEarningsDashboardStrings.of('uploading', lang),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(state.mediaUploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ] else if (state.mediaUploadProgress >= 1.0) ...[
            const Icon(Icons.check_circle, color: DeliveryAppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              DeliveryEarningsDashboardStrings.of('uploadComplete', lang),
              style: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                key: const Key('dp_earnings_media_upload_button'),
                onPressed: () {
                  context
                      .read<DeliveryEarningsDashboardPageBloc>()
                      .add(const DeliveryEarningsMediaUploadStartedEvent());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(
                  DeliveryEarningsDashboardStrings.of('uploadMedia', lang),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarningsTransactionsPanel extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsTransactionsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_earnings_transactions_list'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryEarningsDashboardStrings.of('recentTransactions', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (state.transactions.isEmpty)
            _EmptyHint(
              text: DeliveryEarningsDashboardStrings.of(
                'noTransactions',
                lang,
              ),
            )
          else
            for (final tx in state.transactions)
              _TransactionRow(transaction: tx),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final DeliveryEarningsTransaction transaction;

  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (transaction.type) {
      EarningsTransactionType.credit => (
        Icons.add_circle_outline,
        DeliveryAppColors.primary,
      ),
      EarningsTransactionType.debit => (
        Icons.remove_circle_outline,
        DeliveryAppColors.error,
      ),
      EarningsTransactionType.withdrawal => (
        Icons.account_balance_outlined,
        DeliveryAppColors.warning,
      ),
    };

    final String statusLabel = switch (transaction.status) {
      'completed' => 'Completed',
      'pending' => 'Pending',
      _ => 'Processing',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                  '$statusLabel · ${_formatDate(transaction.date)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${transaction.type == EarningsTransactionType.debit ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsWithdrawalsPanel extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsWithdrawalsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_earnings_withdrawals_list'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryEarningsDashboardStrings.of('withdrawalHistory', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (state.withdrawalHistory.isEmpty)
            _EmptyHint(
              text: DeliveryEarningsDashboardStrings.of(
                'noWithdrawals',
                lang,
              ),
            )
          else
            for (final record in state.withdrawalHistory)
              _WithdrawalRow(record: record),
        ],
      ),
    );
  }
}

class _WithdrawalRow extends StatelessWidget {
  final DeliveryWithdrawalRecord record;

  const _WithdrawalRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = record.status == 'completed'
        ? DeliveryAppColors.primary
        : DeliveryAppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record.status == 'completed'
                  ? Icons.check_circle_outline
                  : Icons.schedule,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.method,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_statusLabel(record.status)} · ${_formatDate(record.date)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${record.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

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

String _statusLabel(String status) {
  return switch (status) {
    'completed' => 'Completed',
    'pending' => 'Pending',
    _ => 'Processing',
  };
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} · $hh:$mm';
}

class _GlowEarningsPainter extends CustomPainter {
  final List<DeliveryEarningsPoint> points;
  final Color color;

  _GlowEarningsPainter({required this.points, required this.color});

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
  bool shouldRepaint(_GlowEarningsPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _EarningsSkeleton extends StatelessWidget {
  const _EarningsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_earnings_skeleton'),
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
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
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

class _EarningsErrorShell extends StatelessWidget {
  final DeliveryEarningsDashboardState state;

  const _EarningsErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_earnings_error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: DeliveryAppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryEarningsDashboardStrings.of(
                'somethingWentWrong',
                lang,
              ),
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
              key: const Key('dp_earnings_retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context
                    .read<DeliveryEarningsDashboardPageBloc>()
                    .add(const DeliveryEarningsInitEvent());
              },
              child: Text(
                DeliveryEarningsDashboardStrings.of('retry', lang),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
