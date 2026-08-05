import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Incentives Dashboard_page_bloc.dart';
import 'Delivery_Incentives Dashboard_page_event.dart';
import 'Delivery_Incentives Dashboard_page_repository.dart';
import 'Delivery_Incentives Dashboard_page_service.dart';
import 'Delivery_Incentives Dashboard_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_spacing.dart';
import '../../../core/theme/delivery_app_typography.dart';

class DeliveryIncentivesDashboardStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'incentivesDashboard': 'Incentives Dashboard',
      'subtitle': 'Track your bonuses, milestones and rewards in one place.',
      'walletBalance': 'Wallet Balance',
      'todayBonus': "Today's Bonus",
      'weeklyBonus': 'Weekly Bonus',
      'monthlyBonus': 'Monthly Bonus',
      'targetProgress': 'Target Progress',
      'vsYesterday': 'vs Yesterday',
      'vsLastWeek': 'vs Last Week',
      'vsLastMonth': 'vs Last Month',
      'targetEarnedOf': '₹{earned} of ₹{goal}',
      'timeRemaining': '{days}d left',
      'incentivesOverview': 'Incentives Overview',
      'achievements': 'Achievements',
      'bonusBreakdown': 'Bonus Breakdown',
      'milestones': 'Order Milestones',
      'rewardHistory': 'Reward History',
      'export': 'Export',
      'all': 'All',
      'performance': 'Performance',
      'peakHour': 'Peak Hour',
      'incentive': 'Incentive',
      'others': 'Others',
      'completed': 'Completed',
      'inProgress': 'In Progress',
      'pending': 'Pending',
      'processing': 'Processing',
      'locked': 'Locked',
      'ordersCompleted': '{count} orders',
      'noRewards': 'No rewards found for this filter.',
      'reference': 'Reference',
      'reward': 'Reward',
      'type': 'Type',
      'status': 'Status',
      'amount': 'Amount',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading incentives.',
      'emptyTitle': 'No incentives yet',
      'emptySub': 'Complete deliveries to start earning bonuses.',
      'today': 'Today',
      'last7Days': '7 Days',
      'thisWeekRange': 'This Week',
      'thisMonthRange': 'This Month',
      'partnerName': 'Ravi Kumar',
      'partnerVehicle': 'TN 01 AB 1234',
      'menu': 'Menu',
      'dashboard': 'Dashboard',
      'earnings': 'Earnings',
      'incentives': 'Incentives',
      'orders': 'Orders',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'exportFailed': 'Export failed. Please try again.',
      'paginationInfo': '{from} to {to} of {total} rewards',
    },
    'ta': {
      'incentivesDashboard': 'ஊக்கத்தொகை டாஷ்போர்டு',
      'subtitle': 'உங்கள் போனஸ், மைல்கற்கள் மற்றும் வெகுமதிகளை ஒரே இடத்தில் பாருங்கள்.',
      'walletBalance': 'வாலட் இருப்பு',
      'todayBonus': 'இன்றைய போனஸ்',
      'weeklyBonus': 'வாராந்திர போனஸ்',
      'monthlyBonus': 'மாதாந்திர போனஸ்',
      'targetProgress': 'இலக்கு முன்னேற்றம்',
      'vsYesterday': 'நேற்று ஒப்பீடு',
      'vsLastWeek': 'கடந்த வார ஒப்பீடு',
      'vsLastMonth': 'கடந்த மாத ஒப்பீடு',
      'targetEarnedOf': '₹{earned} / ₹{goal}',
      'timeRemaining': '{days} நாட்கள் உள்ளன',
      'incentivesOverview': 'ஊக்கத்தொகை கண்ணோட்டம்',
      'achievements': 'சாதனைகள்',
      'bonusBreakdown': 'போனஸ் பிரிவு',
      'milestones': 'ஆர்டர் மைல்கற்கள்',
      'rewardHistory': 'வெகுமதி வரலாறு',
      'export': 'ஏற்றுமதி',
      'all': 'அனைத்தும்',
      'performance': 'செயல்திறன்',
      'peakHour': 'உச்ச நேரம்',
      'incentive': 'ஊக்கம்',
      'others': 'மற்றவை',
      'completed': 'நிறைவடைந்தது',
      'inProgress': 'நடைபெறுகிறது',
      'pending': 'நிலுவையில்',
      'processing': 'செயலாக்கத்தில்',
      'locked': 'பூட்டப்பட்டது',
      'ordersCompleted': '{count} ஆர்டர்கள்',
      'noRewards': 'இந்த வடிகட்டிக்கு வெகுமதிகள் இல்லை.',
      'reference': 'குறிப்பு',
      'reward': 'வெகுமதி',
      'type': 'வகை',
      'status': 'நிலை',
      'amount': 'தொகை',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'ஊக்கத்தொகை தரவை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'emptyTitle': 'இன்னும் ஊக்கத்தொகை இல்லை',
      'emptySub': 'போனஸ் பெற டெலிவரிகளை முடிக்கவும்.',
      'today': 'இன்று',
      'last7Days': '7 நாட்கள்',
      'thisWeekRange': 'இந்த வாரம்',
      'thisMonthRange': 'இந்த மாதம்',
      'partnerName': 'ரவி குமார்',
      'partnerVehicle': 'TN 01 AB 1234',
      'menu': 'மெனு',
      'dashboard': 'டாஷ்போர்டு',
      'earnings': 'வருமானம்',
      'incentives': 'ஊக்கத்தொகை',
      'orders': 'ஆர்டர்கள்',
      'wallet': 'வாலட்',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'logout': 'வெளியேறு',
      'exportFailed': 'ஏற்றுமதி தோல்வியடைந்தது. மீண்டும் முயற்சிக்கவும்.',
      'paginationInfo': '{from} முதல் {to} வரை {total} வெகுமதிகளில்',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryIncentivesDashboardPage extends StatelessWidget {
  final DeliveryIncentivesDashboardRepositoryBase? repository;
  final DeliveryIncentivesDashboardServiceBase? service;
  final DeliveryIncentivesDashboardPageBloc? bloc;

  const DeliveryIncentivesDashboardPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryIncentivesDashboardPageBloc>.value(
        value: bloc!,
        child: const DeliveryIncentivesDashboardPageView(),
      );
    }

    return BlocProvider<DeliveryIncentivesDashboardPageBloc>(
      create: (context) => DeliveryIncentivesDashboardPageBloc(
        repository: repository ?? DeliveryIncentivesDashboardRepository(),
        service: service ?? DeliveryIncentivesDashboardService(),
      )..add(const FetchIncentivesDataEvent()),
      child: const DeliveryIncentivesDashboardPageView(),
    );
  }
}

class DeliveryIncentivesDashboardPageView extends StatelessWidget {
  const DeliveryIncentivesDashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryIncentivesDashboardPageBloc,
        DeliveryIncentivesDashboardState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType &&
          current is DeliveryIncentivesDashboardErrorState,
      listener: (context, state) {
        if (state is DeliveryIncentivesDashboardErrorState &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DeliveryIncentivesDashboardInitialState ||
            state is DeliveryIncentivesDashboardLoadingState) {
          return const _IncentivesSkeleton();
        }

        if (state is DeliveryIncentivesDashboardErrorState) {
          return _IncentivesErrorShell(state: state);
        }

        if (state is DeliveryIncentivesDashboardEmptyState) {
          return _IncentivesEmptyShell(state: state);
        }

        if (state is DeliveryIncentivesDashboardLoadedState) {
          return _IncentivesDashboardShell(state: state);
        }

        return const _IncentivesSkeleton();
      },
    );
  }
}

class _IncentivesDashboardShell extends StatefulWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _IncentivesDashboardShell({required this.state});

  @override
  State<_IncentivesDashboardShell> createState() =>
      _IncentivesDashboardShellState();
}

class _IncentivesDashboardShellState extends State<_IncentivesDashboardShell> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return SingleChildScrollView(
          key: const Key('dp_incentives_page'),
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IncentivesHeader(
                    state: state,
                    isDesktop: isDesktop,
                    showMenu: false,
                  ),
                  const SizedBox(height: 20),
                  _IncentivesSummaryGrid(
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
                          child: _IncentivesOverviewCard(
                            state: state,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _BonusBreakdownCard(state: state),
                        ),
                      ],
                    )
                  else ...[
                    _IncentivesOverviewCard(state: state),
                    const SizedBox(height: 20),
                    _BonusBreakdownCard(state: state),
                  ],
                  const SizedBox(height: 20),
                  _AchievementsCarousel(
                    state: state,
                    isDesktop: isDesktop,
                  ),
                  const SizedBox(height: 20),
                  _MilestonesStepperCard(state: state),
                  const SizedBox(height: 20),
                  _RewardHistoryCard(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IncentivesHeader extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;
  final bool isDesktop;
  final bool showMenu;

  const _IncentivesHeader({
    required this.state,
    required this.isDesktop,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_incentives_header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          if (showMenu) ...[
            IconButton(
              key: const Key('dp_incentives_menu'),
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 4),
          ],
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
              Icons.emoji_events_outlined,
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
                  DeliveryIncentivesDashboardStrings.of(
                      'incentivesDashboard', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DeliveryIncentivesDashboardStrings.of('subtitle', lang),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                  DeliveryIncentivesDashboardStrings.of('walletBalance', lang),
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
          if (isDesktop) ...[
            const SizedBox(width: 12),
            _NotificationBadge(lang: lang),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: DeliveryAppColors.surfaceLight,
                    child: Text(
                      'RK',
                      style: TextStyle(
                        color: DeliveryAppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DeliveryIncentivesDashboardStrings.of(
                            'partnerName', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DeliveryIncentivesDashboardStrings.of(
                            'partnerVehicle', lang),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
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

class _NotificationBadge extends StatelessWidget {
  final String lang;

  const _NotificationBadge({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Badge(
      key: const Key('dp_incentives_notification'),
      label: const Text('3'),
      backgroundColor: DeliveryAppColors.error,
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined,
            color: Colors.white70),
        onPressed: () {},
      ),
    );
  }
}

class _IncentivesSummaryGrid extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;
  final bool isDesktop;
  final bool isTablet;

  const _IncentivesSummaryGrid({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final cards = <Widget>[
      _IncentivesMetricCard(
        key: const Key('dp_incentives_summary_today'),
        title: DeliveryIncentivesDashboardStrings.of('todayBonus', lang),
        value: '₹${state.todayBonus.toStringAsFixed(2)}',
        growthText:
            '+${state.todayBonusGrowth.toStringAsFixed(1)}% ${DeliveryIncentivesDashboardStrings.of('vsYesterday', lang)}',
        color: DeliveryAppColors.primary,
        points: state.rangePoints[IncentivesDateRange.today] ?? const [],
      ),
      _IncentivesMetricCard(
        key: const Key('dp_incentives_summary_weekly'),
        title: DeliveryIncentivesDashboardStrings.of('weeklyBonus', lang),
        value: '₹${state.weeklyBonus.toStringAsFixed(2)}',
        growthText:
            '+${state.weeklyBonusGrowth.toStringAsFixed(1)}% ${DeliveryIncentivesDashboardStrings.of('vsLastWeek', lang)}',
        color: const Color(0xFF7C4DFF),
        points:
            state.rangePoints[IncentivesDateRange.last7Days] ??
            state.rangePoints[IncentivesDateRange.thisWeek] ??
            const [],
      ),
      _IncentivesMetricCard(
        key: const Key('dp_incentives_summary_monthly'),
        title: DeliveryIncentivesDashboardStrings.of('monthlyBonus', lang),
        value: '₹${state.monthlyBonus.toStringAsFixed(2)}',
        growthText:
            '+${state.monthlyBonusGrowth.toStringAsFixed(1)}% ${DeliveryIncentivesDashboardStrings.of('vsLastMonth', lang)}',
        color: DeliveryAppColors.info,
        points: state.rangePoints[IncentivesDateRange.thisMonth] ?? const [],
      ),
      _TargetProgressCard(state: state),
    ];

    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 2);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.55 : (isTablet ? 1.9 : 1.2),
      children: cards,
    );
  }
}

class _IncentivesMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String growthText;
  final Color color;
  final List<DeliveryIncentivesBonusPoint> points;

  const _IncentivesMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.growthText,
    required this.color,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  growthText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (points.length >= 2)
                SizedBox(
                  width: 64,
                  height: 30,
                  child: CustomPaint(
                    painter: _MiniSparklinePainter(points: points, color: color),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetProgressCard extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _TargetProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final progress = (state.targetProgress / 100.0).clamp(0.0, 1.0);
    final daysLeft = state.targetDeadline.difference(DateTime.now()).inDays;
    final daysText = daysLeft < 0 ? 0 : daysLeft;

    return Container(
      key: const Key('dp_incentives_summary_target'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DeliveryAppColors.surfaceLight, DeliveryAppColors.surface],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  DeliveryIncentivesDashboardStrings.of('targetProgress', lang),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.targetProgress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              key: const Key('dp_incentives_target_progress_bar'),
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor:
                  const AlwaysStoppedAnimation(DeliveryAppColors.primary),
            ),
          ),
          Text(
            DeliveryIncentivesDashboardStrings.of('targetEarnedOf', lang)
                .replaceAll('{earned}', state.targetEarned.toStringAsFixed(0))
                .replaceAll('{goal}', state.targetGoal.toStringAsFixed(0)),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          Text(
            DeliveryIncentivesDashboardStrings.of('timeRemaining', lang)
                .replaceAll('{days}', '$daysText'),
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncentivesOverviewCard extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _IncentivesOverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final ranges = [
      (range: IncentivesDateRange.today, label: 'today'),
      (range: IncentivesDateRange.last7Days, label: 'last7Days'),
      (range: IncentivesDateRange.thisWeek, label: 'thisWeekRange'),
      (range: IncentivesDateRange.thisMonth, label: 'thisMonthRange'),
    ];

    return Container(
      key: const Key('dp_incentives_overview_card'),
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
                  DeliveryIncentivesDashboardStrings.of(
                      'incentivesOverview', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.timeline,
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
                    'dp_incentives_range_${switch (item.range) {
                      IncentivesDateRange.today => 'today',
                      IncentivesDateRange.last7Days => 'last7Days',
                      IncentivesDateRange.thisWeek => 'thisWeek',
                      IncentivesDateRange.thisMonth => 'thisMonth',
                    }}',
                  ),
                  label: DeliveryIncentivesDashboardStrings.of(
                      item.label, lang),
                  isSelected: state.selectedRange == item.range,
                  onTap: () {
                    context
                        .read<DeliveryIncentivesDashboardPageBloc>()
                        .add(UpdateDateRangeEvent(item.range));
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: _IncentivesOverviewChart(state: state),
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
                  ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? DeliveryAppColors.primary.withValues(alpha: 0.4)
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

class _IncentivesOverviewChart extends StatefulWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _IncentivesOverviewChart({required this.state});

  @override
  State<_IncentivesOverviewChart> createState() =>
      _IncentivesOverviewChartState();
}

class _IncentivesOverviewChartState extends State<_IncentivesOverviewChart> {
  int? _tooltipIndex;

  @override
  Widget build(BuildContext context) {
    final points = widget.state.currentRangePoints;
    final lang = widget.state.localeCode;

    if (points.length < 2) {
      return Center(
        child: Text(
          DeliveryIncentivesDashboardStrings.of('noRewards', lang),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    return GestureDetector(
      key: const Key('dp_incentives_overview_chart'),
      onTapUp: (details) {
        final size = context.size!;
        final stepX = size.width / (points.length - 1);
        final index = (details.localPosition.dx / stepX).round().clamp(
              0,
              points.length - 1,
            );
        setState(() => _tooltipIndex = index);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GlowIncentivesPainter(
                points: points,
                color: DeliveryAppColors.primary,
              ),
            ),
          ),
          if (_tooltipIndex != null && _tooltipIndex! < points.length)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                key: const Key('dp_incentives_chart_tooltip'),
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2631),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DeliveryAppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${points[_tooltipIndex!].label}: ₹${points[_tooltipIndex!].value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BonusBreakdownCard extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _BonusBreakdownCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final slices = state.donutSlices;
    final total = slices.fold<double>(0.0, (sum, s) => sum + s.value);

    return Container(
      key: const Key('dp_incentives_donut_card'),
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
                  DeliveryIncentivesDashboardStrings.of('bonusBreakdown', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.donut_large,
                  color: Color(0xFF10B981), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  key: const Key('dp_incentives_donut_chart'),
                  painter: _DonutPainter(
                    slices: slices,
                    centerLabel: '₹${total.toStringAsFixed(2)}',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final slice in slices)
                      _DonutLegendRow(slice: slice, total: total),
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

class _DonutLegendRow extends StatelessWidget {
  final DeliveryIncentivesDonutSlice slice;
  final double total;

  const _DonutLegendRow({required this.slice, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(slice.category);
    final percent = total == 0
        ? 0.0
        : ((slice.value / total) * 100);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _categoryLabel(slice.category),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCarousel extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;
  final bool isDesktop;

  const _AchievementsCarousel({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
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
            DeliveryIncentivesDashboardStrings.of('achievements', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: PageView.builder(
              key: const Key('dp_incentives_achievements_carousel'),
              controller: PageController(
                viewportFraction: isDesktop ? 0.34 : 0.85,
              ),
              itemCount: state.achievements.length,
              itemBuilder: (context, index) {
                final achievement = state.achievements[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AchievementCard(achievement: achievement),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final DeliveryIncentivesAchievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final progress = (achievement.progress / achievement.target).clamp(0.0, 1.0);
    final color = achievement.completed
        ? DeliveryAppColors.primary
        : const Color(0xFF7C4DFF);

    return Container(
      key: Key('dp_incentives_achievement_${achievement.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2631),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  achievement.completed
                      ? Icons.military_tech
                      : Icons.emoji_events_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  achievement.completed ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${achievement.progress.toStringAsFixed(0)}/${achievement.target.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestonesStepperCard extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _MilestonesStepperCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_incentives_milestones_card'),
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
            DeliveryIncentivesDashboardStrings.of('milestones', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = state.milestones.length;
              final nodeWidth = constraints.maxWidth / count;

              return Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: state.milestones[i].status ==
                                  DeliveryIncentivesMilestoneStatus.completed
                              ? DeliveryAppColors.primary
                              : Colors.white12,
                        ),
                      ),
                    SizedBox(
                      width: nodeWidth - 20,
                      child: _MilestoneNode(milestone: state.milestones[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MilestoneNode extends StatelessWidget {
  final DeliveryIncentivesMilestone milestone;

  const _MilestoneNode({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final status = milestone.status;
    final completed = status == DeliveryIncentivesMilestoneStatus.completed;
    final inProgress = status == DeliveryIncentivesMilestoneStatus.inProgress;

    final Color color = completed
        ? DeliveryAppColors.primary
        : inProgress
            ? DeliveryAppColors.primary
            : const Color(0xFF3A4451);

    return Column(
      children: [
        Container(
          key: Key('dp_incentives_milestone_${milestone.target}'),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: inProgress
                ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                : completed
                    ? DeliveryAppColors.primary
                    : const Color(0xFF1E2631),
            shape: BoxShape.circle,
            border: Border.all(
              color: completed
                  ? DeliveryAppColors.primary
                  : color.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: inProgress
                ? [
                    BoxShadow(
                      color: DeliveryAppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check,
                    color: Colors.black, size: 22)
                : Text(
                    '${milestone.target}',
                    style: TextStyle(
                      color: completed
                          ? Colors.black
                          : inProgress
                              ? DeliveryAppColors.primary
                              : Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${milestone.target}',
          style: TextStyle(
            color: completed || inProgress
                ? Colors.white
                : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RewardHistoryCard extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _RewardHistoryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final filters = [
      (filter: RewardFilterType.all, label: 'all'),
      (filter: RewardFilterType.performance, label: 'performance'),
      (filter: RewardFilterType.peakHour, label: 'peakHour'),
      (filter: RewardFilterType.incentive, label: 'incentive'),
      (filter: RewardFilterType.others, label: 'others'),
    ];

    return Container(
      key: const Key('dp_incentives_reward_history_card'),
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
                  DeliveryIncentivesDashboardStrings.of('rewardHistory', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key('dp_incentives_export'),
                onPressed: state.isExporting
                    ? null
                    : () {
                        context
                            .read<DeliveryIncentivesDashboardPageBloc>()
                            .add(const ExportRewardHistoryEvent());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: state.isExporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.download, size: 16),
                label: Text(
                  DeliveryIncentivesDashboardStrings.of('export', lang),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in filters)
                _FilterChip(
                  key: Key(
                    'dp_incentives_filter_${switch (item.filter) {
                      RewardFilterType.all => 'all',
                      RewardFilterType.performance => 'performance',
                      RewardFilterType.peakHour => 'peakhour',
                      RewardFilterType.incentive => 'incentive',
                      RewardFilterType.others => 'others',
                    }}',
                  ),
                  label: DeliveryIncentivesDashboardStrings.of(
                      item.label, lang),
                  isSelected: state.activeFilter == item.filter,
                  onTap: () {
                    context
                        .read<DeliveryIncentivesDashboardPageBloc>()
                        .add(FilterRewardHistoryEvent(item.filter));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.filteredRewards.isEmpty)
            Padding(
              key: const Key('dp_incentives_empty_table'),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  DeliveryIncentivesDashboardStrings.of('noRewards', lang),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else ...[
            _RewardTableHeader(lang: lang),
            const SizedBox(height: 6),
            for (final record in state.paginatedRewards)
              _RewardTableRow(record: record),
            const SizedBox(height: 14),
            _PaginationBar(state: state),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? DeliveryAppColors.primary.withValues(alpha: 0.4)
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

class _RewardTableHeader extends StatelessWidget {
  final String lang;

  const _RewardTableHeader({required this.lang});

  @override
  Widget build(BuildContext context) {
    final s = DeliveryIncentivesDashboardStrings.of;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2631),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              s('reward', lang),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              s('type', lang),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              s('status', lang),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              s('amount', lang),
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardTableRow extends StatelessWidget {
  final DeliveryIncentivesRewardRecord record;

  const _RewardTableRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final typeColor = _categoryColor(record.type.name);

    return Container(
      key: Key('dp_incentives_reward_row_${record.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  record.referenceId,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _categoryLabel(record.type.name),
              style: TextStyle(
                color: typeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: _StatusBadge(status: record.status)),
          Expanded(
            flex: 2,
            child: Text(
              '₹${record.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      'completed' => (
          DeliveryAppColors.primary,
          DeliveryIncentivesDashboardStrings.of('completed', 'en'),
        ),
      'pending' => (
          DeliveryAppColors.warning,
          DeliveryIncentivesDashboardStrings.of('pending', 'en'),
        ),
      _ => (
          DeliveryAppColors.info,
          DeliveryIncentivesDashboardStrings.of('processing', 'en'),
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final DeliveryIncentivesDashboardLoadedState state;

  const _PaginationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final start = state.filteredTotal == 0
        ? 0
        : state.currentPage * state.pageSize + 1;
    final end = (state.currentPage * state.pageSize + state.pageSize).clamp(
          0,
          state.filteredTotal,
        );

    final info = DeliveryIncentivesDashboardStrings.of('paginationInfo', lang)
        .replaceAll('{from}', '$start')
        .replaceAll('{to}', '$end')
        .replaceAll('{total}', '${state.filteredTotal}');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 460;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                info,
                key: const Key('dp_incentives_pagination_info'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isCompact)
              Row(
                children: [
                  IconButton(
                    key: const Key('dp_incentives_page_prev'),
                    onPressed: state.currentPage == 0
                        ? null
                        : () {
                            context
                                .read<DeliveryIncentivesDashboardPageBloc>()
                                .add(ChangePageEvent(state.currentPage - 1));
                          },
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white70, size: 20),
                  ),
                  IconButton(
                    key: const Key('dp_incentives_page_next'),
                    onPressed: state.currentPage >= state.totalPages - 1
                        ? null
                        : () {
                            context
                                .read<DeliveryIncentivesDashboardPageBloc>()
                                .add(ChangePageEvent(state.currentPage + 1));
                          },
                    icon: const Icon(Icons.chevron_right,
                        color: Colors.white70, size: 20),
                  ),
                ],
              )
            else
              Row(
                children: [
                  IconButton(
                    key: const Key('dp_incentives_page_prev'),
                    onPressed: state.currentPage == 0
                        ? null
                        : () {
                            context
                                .read<DeliveryIncentivesDashboardPageBloc>()
                                .add(ChangePageEvent(state.currentPage - 1));
                          },
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white70, size: 20),
                  ),
                  for (var page = 0; page < state.totalPages; page++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        key: Key('dp_incentives_page_$page'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          context
                              .read<DeliveryIncentivesDashboardPageBloc>()
                              .add(ChangePageEvent(page));
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: page == state.currentPage
                                ? DeliveryAppColors.primary
                                    .withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${page + 1}',
                              style: TextStyle(
                                color: page == state.currentPage
                                    ? DeliveryAppColors.primary
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: page == state.currentPage
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    key: const Key('dp_incentives_page_next'),
                    onPressed: state.currentPage >= state.totalPages - 1
                        ? null
                        : () {
                            context
                                .read<DeliveryIncentivesDashboardPageBloc>()
                                .add(ChangePageEvent(state.currentPage + 1));
                          },
                    icon: const Icon(Icons.chevron_right,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

Color _categoryColor(String category) {
  return switch (category) {
    'performance' => DeliveryAppColors.primary,
    'peakHour' => const Color(0xFF7C4DFF),
    'incentive' => DeliveryAppColors.info,
    _ => DeliveryAppColors.warning,
  };
}

String _categoryLabel(String category) {
  return switch (category) {
    'performance' => DeliveryIncentivesDashboardStrings.of('performance', 'en'),
    'peakHour' => DeliveryIncentivesDashboardStrings.of('peakHour', 'en'),
    'incentive' => DeliveryIncentivesDashboardStrings.of('incentive', 'en'),
    _ => DeliveryIncentivesDashboardStrings.of('others', 'en'),
  };
}

class _MiniSparklinePainter extends CustomPainter {
  final List<DeliveryIncentivesBonusPoint> points;
  final Color color;

  _MiniSparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final values = points.map((p) => p.value).toList();
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = math.max(maxV - minV, 1.0);
    final stepX = size.width / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final dx = i * stepX;
      final dy = size.height - 3 - ((points[i].value - minV) / range) * (size.height - 6);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniSparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _GlowIncentivesPainter extends CustomPainter {
  final List<DeliveryIncentivesBonusPoint> points;
  final Color color;

  _GlowIncentivesPainter({required this.points, required this.color});

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
  bool shouldRepaint(_GlowIncentivesPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _DonutPainter extends CustomPainter {
  final List<DeliveryIncentivesDonutSlice> slices;
  final String centerLabel;

  _DonutPainter({required this.slices, required this.centerLabel});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0.0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = _categoryColor(slice.category)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18,
      );
      startAngle += sweep;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: centerLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.centerLabel != centerLabel;
}

class _IncentivesSkeleton extends StatelessWidget {
  const _IncentivesSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_incentives_skeleton'),
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
          const SizedBox(height: 20),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 260,
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

class _IncentivesErrorShell extends StatelessWidget {
  final DeliveryIncentivesDashboardErrorState state;

  const _IncentivesErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_incentives_error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: DeliveryAppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryIncentivesDashboardStrings.of('somethingWentWrong', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('dp_incentives_retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context
                    .read<DeliveryIncentivesDashboardPageBloc>()
                    .add(const FetchIncentivesDataEvent());
              },
              child: Text(
                DeliveryIncentivesDashboardStrings.of('retry', lang),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncentivesEmptyShell extends StatelessWidget {
  final DeliveryIncentivesDashboardEmptyState state;

  const _IncentivesEmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      key: const Key('dp_incentives_empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined,
                color: DeliveryAppColors.primary, size: 64),
            const SizedBox(height: 16),
            Text(
              DeliveryIncentivesDashboardStrings.of('emptyTitle', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryIncentivesDashboardStrings.of('emptySub', lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('dp_incentives_empty_retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context
                    .read<DeliveryIncentivesDashboardPageBloc>()
                    .add(const RefreshIncentivesDataEvent());
              },
              child: Text(
                DeliveryIncentivesDashboardStrings.of('retry', lang),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
