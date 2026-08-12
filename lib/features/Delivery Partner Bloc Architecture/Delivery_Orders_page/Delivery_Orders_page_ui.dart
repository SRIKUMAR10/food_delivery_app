import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Delivery_Orders_page_bloc.dart';
import 'Delivery_Orders_page_event.dart';
import 'Delivery_Orders_page_repository.dart';
import 'Delivery_Orders_page_service.dart';
import 'Delivery_Orders_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_app_spacing.dart';
import '../../../core/widgets/delivery_button.dart';
import '../../../core/widgets/delivery_card.dart';
import '../../../core/widgets/delivery_chip.dart';
import '../../../core/widgets/delivery_text_field.dart';

class DeliveryOrdersStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Orders Overview',
      'subtitle': 'Manage your deliveries and keep customers updated',
      'searchHint': 'Search order ID, customer, restaurant or phone',
      'total': 'Total',
      'today': 'Today',
      'active': 'Active',
      'pending': 'Pending',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'acceptance': 'Acceptance',
      'avgTime': 'Avg Time',
      'rating': 'Rating',
      'earningsTotal': 'Total Earnings',
      'tabAll': 'All',
      'tabActive': 'Active',
      'tabPending': 'Pending',
      'tabCompleted': 'Completed',
      'pickup': 'Pickup',
      'delivery': 'Delivery',
      'items': 'items',
      'earnings': 'Your Earnings',
      'distance': 'Distance',
      'payment': 'Payment',
      'navigate': 'Navigate',
      'call': 'Call',
      'chat': 'Chat',
      'viewDetails': 'View Details',
      'acceptOrder': 'Accept Order',
      'completeDelivery': 'Complete Delivery',
      'orderCompleted': 'Completed',
      'sort': 'Sort',
      'filter': 'Filter',
      'export': 'Export',
      'autoRefresh': 'Auto Refresh',
      'notifications': 'Notifications',
      'noNewNotifications': 'No new notifications',
      'sortTime': 'Soonest First',
      'sortDistance': 'Nearest First',
      'sortAmount': 'Highest Amount',
      'paymentAll': 'All Payments',
      'paymentCash': 'Cash',
      'paymentCard': 'Card',
      'paymentOnline': 'Online',
      'exportHint': 'Orders report exported as CSV',
      'currentDelivery': 'Current Delivery',
      'eta': 'ETA',
      'onTime': 'On Time',
      'urgent': 'Urgent',
      'lateBy': 'Late by',
      'min': 'min',
      'priority': 'Priority',
      'normal': 'Normal',
      'high': 'High',
      'prep': 'Prep',
      'tip': 'Tip',
      'bonus': 'Bonus',
      'acceptNext': 'Accept Next Order',
      'goOffline': 'Go Offline',
      'accepted': 'Accepted',
      'noPending': 'No pending orders right now',
      'offlineHint': 'You are now offline. New orders will pause.',
      'stayOnline': 'Stay Online',
      'stayOnlineHint': 'You are online. New orders will appear automatically.',
      'calling': 'Calling',
      'callCustomer': 'Call Customer',
      'noPhone': 'No phone number available for ',
      'chatHint': 'Opening chat with',
      'detailsHint': 'Opening details for',
      'tlPickup': 'Pickup',
      'tlReached': 'Reached',
      'tlPicked': 'Picked Up',
      'tlEnRoute': 'En Route',
      'tlDelivered': 'Delivered',
      'noResultsTitle': 'No orders found',
      'noResultsSub': 'Try adjusting your search or filter to see more orders.',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'emptyTitle': 'No orders available',
      'emptySub':
          "We'll notify you when new orders arrive. Stay online and relax.",
      'somethingWentWrong':
          'Something went wrong while loading your orders.',
      'statusPending': 'Pending',
      'statusActive': 'In Progress',
      'statusCompleted': 'Delivered',
      'statusCancelled': 'Cancelled',
      'directionsHint': 'Opening directions to',
      'updateFailed': 'Failed to update order status. Please try again.',
      'liveMap': 'Live Map',
      'liveTrackingSoon': 'Live tracking coming soon',
    },
    'ta': {
      'title': 'ஆர்டர்கள் கண்ணோட்டம்',
      'subtitle': 'உங்கள் டெலிவரிகளை நிர்வகித்து வாடிக்கையாளர்களை புதுப்பித்த நிலையில் வைத்திருங்கள்',
      'searchHint': 'ஆர்டர் ஐடி, வாடிக்கையாளர், உணவகம் அல்லது தொலைபேசியைத் தேடுங்கள்',
      'total': 'மொத்தம்',
      'today': 'இன்று',
      'active': 'செயலில்',
      'pending': 'நிலுவையில்',
      'completed': 'நிறைவு',
      'cancelled': 'ரத்து',
      'acceptance': 'ஏற்பு விகிதம்',
      'avgTime': 'சராசரி நேரம்',
      'rating': 'மதிப்பீடு',
      'earningsTotal': 'மொத்த வருவாய்',
      'tabAll': 'அனைத்தும்',
      'tabActive': 'செயலில்',
      'tabPending': 'நிலுவையில்',
      'tabCompleted': 'நிறைவு',
      'pickup': 'எடுக்கும் இடம்',
      'delivery': 'டெலிவரி',
      'items': 'பொருட்கள்',
      'earnings': 'உங்கள் வருவாய்',
      'distance': 'தூரம்',
      'payment': 'கட்டணம்',
      'navigate': 'வழிகாட்டுதல்',
      'call': 'அழைப்பு',
      'chat': 'அரட்டை',
      'viewDetails': 'விவரங்கள்',
      'acceptOrder': 'ஆர்டரை ஏற்க',
      'completeDelivery': 'டெலிவரியை முடிக்க',
      'orderCompleted': 'முடிந்தது',
      'sort': 'வரிசை',
      'filter': 'வடிகட்டு',
      'export': 'ஏற்றுமதி',
      'autoRefresh': 'தானியங்கி புதுப்பிப்பு',
      'notifications': 'அறிவிப்புகள்',
      'noNewNotifications': 'புதிய அறிவிப்புகள் இல்லை',
      'sortTime': 'முதலில் குறைந்த நேரம்',
      'sortDistance': 'அருகில் முதலில்',
      'sortAmount': 'அதிக தொகை முதலில்',
      'paymentAll': 'அனைத்து கட்டணங்கள்',
      'paymentCash': 'பணம்',
      'paymentCard': 'கார்டு',
      'paymentOnline': 'ஆன்லைன்',
      'exportHint': 'ஆர்டர் அறிக்கை ஏற்றுமதி செய்யப்பட்டது',
      'currentDelivery': 'தற்போதைய டெலிவரி',
      'eta': 'ETA',
      'onTime': 'சரியான நேரத்தில்',
      'urgent': 'அவசரம்',
      'lateBy': 'தாமதம்',
      'min': 'நிமிடம்',
      'priority': 'முன்னுரிமை',
      'normal': 'சாதாரணம்',
      'high': 'அதிகம்',
      'prep': 'தயாரிப்பு',
      'tip': 'டிப்',
      'bonus': 'போனஸ்',
      'acceptNext': 'அடுத்த ஆர்டரை ஏற்க',
      'goOffline': 'ஆஃப்லைன்',
      'accepted': 'ஏற்கப்பட்டது',
      'noPending': 'தற்போது நிலுவையில் உள்ள ஆர்டர்கள் இல்லை',
      'offlineHint': 'நீங்கள் இப்போது ஆஃப்லைனில் உள்ளீர்கள். புதிய ஆர்டர்கள் நிறுத்தப்படும்.',
      'stayOnline': 'ஆன்லைனில் இருங்கள்',
      'stayOnlineHint': 'நீங்கள் ஆன்லைனில் உள்ளீர்கள். புதிய ஆர்டர்கள் தானாகத் தோன்றும்.',
      'calling': 'அழைக்கிறது',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'noPhone': 'எந்த தொலைபேசி எண்ணும் கிடைக்கவில்லை ',
      'chatHint': 'அரட்டையைத் திறக்கிறது',
      'detailsHint': 'விவரங்களைத் திறக்கிறது',
      'tlPickup': 'பிக்கப்',
      'tlReached': 'சேர்ந்தது',
      'tlPicked': 'எடுக்கப்பட்டது',
      'tlEnRoute': 'வழியில்',
      'tlDelivered': 'டெலிவரி ஆனது',
      'noResultsTitle': 'ஆர்டர்கள் எதுவும் இல்லை',
      'noResultsSub': 'மேலும் ஆர்டர்களைக் காண உங்கள் தேடல் அல்லது வடிகட்டியை மாற்றவும்.',
      'refresh': 'புதுப்பிக்க',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'emptyTitle': 'ஆர்டர்கள் எதுவும் இல்லை',
      'emptySub': 'புதிய ஆர்டர்கள் வரும்போது அறிவிப்போம். ஆன்லைனில் இருந்து ஓய்வெடுங்கள்.',
      'somethingWentWrong': 'உங்கள் ஆர்டர்களை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'statusPending': 'நிலுவையில்',
      'statusActive': 'நடைபெறுகிறது',
      'statusCompleted': 'டெலிவரி ஆனது',
      'statusCancelled': 'ரத்து செய்யப்பட்டது',
      'directionsHint': 'வழிகாட்டுதலைத் திறக்கிறது',
      'updateFailed': 'ஆர்டர் நிலையை புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
      'liveMap': 'லைவ் வரைபடம்',
      'liveTrackingSoon': 'லைவ் டிராக்கிங் விரைவில் வருகிறது',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryOrdersPage extends StatelessWidget {
  final DeliveryOrdersRepositoryBase? repository;
  final DeliveryOrdersServiceBase? service;
  final DeliveryOrdersPageBloc? bloc;

  const DeliveryOrdersPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryOrdersPageBloc>.value(
        value: bloc!,
        child: const DeliveryOrdersPageView(),
      );
    }

    return BlocProvider<DeliveryOrdersPageBloc>(
      create: (context) => DeliveryOrdersPageBloc(
        repository: repository ?? DeliveryOrdersRepository(),
        service: service ?? DeliveryOrdersService(),
      )..add(const DeliveryOrdersInitEvent()),
      child: const DeliveryOrdersPageView(),
    );
  }
}

class DeliveryOrdersPageView extends StatelessWidget {
  const DeliveryOrdersPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          current.errorMessage!.isNotEmpty,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ==
                        'Failed to update order status. Please try again.'
                    ? DeliveryOrdersStrings.of(
                        'updateFailed',
                        state.localeCode,
                      )
                    : state.errorMessage!,
              ),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == DeliveryOrdersPageStatus.initial ||
            state.status == DeliveryOrdersPageStatus.loading) {
          return const _OrdersLoadingShell();
        }

        if (state.status == DeliveryOrdersPageStatus.error) {
          return _OrdersErrorShell(state: state);
        }

        if (state.status == DeliveryOrdersPageStatus.empty) {
          return _OrdersEmptyShell(state: state);
        }

        return _OrdersLoadedView(state: state);
      },
    );
  }
}

class _OrdersLoadedView extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersLoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isWide = constraints.maxWidth >= 1200;
        final activeOrder = state.activeOrder;

        Widget mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrdersHeader(state: state, isDesktop: isDesktop),
            const SizedBox(height: 16),
            _OrdersStatsRow(state: state),
            const SizedBox(height: 16),
            if (activeOrder != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                ),
                child: _ActiveOrderBanner(
                  order: activeOrder,
                  state: state,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _OrdersTabBar(state: state),
            const SizedBox(height: 8),
            state.isEmpty
                ? _OrdersNoResults(state: state)
                : ListView.separated(
                    key: const Key('dp_orders_list'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(
                      isDesktop ? 24 : 16,
                    ),
                    itemCount: state.filteredOrders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        _OrderCard(
                          order: state.filteredOrders[index],
                          state: state,
                        ),
                  ),
          ],
        );

        Widget bodyWidget;
        if (isWide) {
          bodyWidget = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: mainContent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: _LiveMapPanel(state: state),
              ),
            ],
          );
        } else {
          bodyWidget = SingleChildScrollView(
            child: mainContent,
          );
        }

        return Stack(
          children: [
            Container(
              key: const Key('dp_orders_page'),
              color: DeliveryAppColors.background,
              child: bodyWidget,
            ),
            Positioned(
              right: DeliveryAppSpacing.xl,
              bottom: DeliveryAppSpacing.xl,
              child: _OrdersFab(state: state),
            ),
          ],
        );
      },
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final DeliveryOrdersPageState state;
  final bool isDesktop;

  const _OrdersHeader({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_orders_header'),
      margin: EdgeInsets.fromLTRB(
        isDesktop ? DeliveryAppSpacing.xl : DeliveryAppSpacing.md,
        DeliveryAppSpacing.md,
        isDesktop ? DeliveryAppSpacing.xl : DeliveryAppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(
        isDesktop ? DeliveryAppSpacing.lg : DeliveryAppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: DeliveryAppSpacing.borderRadiusLg,
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  Icons.receipt_long,
                  color: DeliveryAppColors.buttonPrimaryText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryOrdersStrings.of('title', lang),
                      style: DeliveryAppTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryOrdersStrings.of('subtitle', lang),
                      style: DeliveryAppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                key: const Key('dp_orders_autorefresh'),
                icon: Icons.autorenew,
                active: state.autoRefresh,
                tooltip: DeliveryOrdersStrings.of('autoRefresh', lang),
                onTap: () => context
                    .read<DeliveryOrdersPageBloc>()
                    .add(
                      DeliveryOrdersAutoRefreshToggledEvent(
                        !state.autoRefresh,
                      ),
                    ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                key: const Key('dp_orders_notification'),
                icon: Icons.notifications_none,
                badgeCount: state.pendingCount,
                tooltip: DeliveryOrdersStrings.of('notifications', lang),
                onTap: () => _showOrdersNotificationSheet(context, state),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DeliveryTextField(
                  key: const Key('dp_orders_search_field'),
                  onChanged: (value) => context
                      .read<DeliveryOrdersPageBloc>()
                      .add(DeliveryOrdersSearchQueryChangedEvent(value)),
                  hintText: DeliveryOrdersStrings.of('searchHint', lang),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _SearchActionButton.sort(
                key: const Key('dp_orders_sort'),
                state: state,
                showLabel: isDesktop,
              ),
              const SizedBox(width: 8),
              _SearchActionButton.filter(
                key: const Key('dp_orders_filter'),
                state: state,
                showLabel: isDesktop,
              ),
              const SizedBox(width: 8),
              _SearchActionButton.export(
                key: const Key('dp_orders_export'),
                state: state,
                showLabel: isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final DeliveryOrdersPageState state;
  final bool showLabel;
  final void Function(BuildContext context, DeliveryOrdersPageState state)
      onPressed;

  _SearchActionButton.sort({
    super.key,
    required DeliveryOrdersPageState state,
    this.showLabel = true,
  })  : state = state,
        label = DeliveryOrdersStrings.of('sort', state.localeCode),
        icon = Icons.swap_vert,
        onPressed = _openSortMenu;

  _SearchActionButton.filter({
    super.key,
    required DeliveryOrdersPageState state,
    this.showLabel = true,
  })  : state = state,
        label = DeliveryOrdersStrings.of('filter', state.localeCode),
        icon = Icons.filter_list,
        onPressed = _openFilterMenu;

  _SearchActionButton.export({
    super.key,
    required DeliveryOrdersPageState state,
    this.showLabel = true,
  })  : state = state,
        label = DeliveryOrdersStrings.of('export', state.localeCode),
        icon = Icons.file_download_outlined,
        onPressed = _exportOrders;

  static void _openSortMenu(BuildContext context, DeliveryOrdersPageState state) {
    showMenu<DeliveryOrdersSort>(
      context: context,
      position: RelativeRect.fromLTRB(1000, 180, 0, 0),
      items: [
        for (final entry in const [
          (DeliveryOrdersSort.time, 'sortTime'),
          (DeliveryOrdersSort.distance, 'sortDistance'),
          (DeliveryOrdersSort.amountHigh, 'sortAmount'),
        ])
          PopupMenuItem<DeliveryOrdersSort>(
            key: Key('dp_orders_sort_${entry.$1.name}'),
            value: entry.$1,
            child: Row(
              children: [
                Icon(
                  entry.$1 == state.sortBy
                      ? Icons.check
                      : Icons.arrow_right_alt,
                  color: DeliveryAppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(DeliveryOrdersStrings.of(entry.$2, state.localeCode)),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null) {
        context
            .read<DeliveryOrdersPageBloc>()
            .add(DeliveryOrdersSortChangedEvent(value));
      }
    });
  }

  static void _openFilterMenu(
    BuildContext context,
    DeliveryOrdersPageState state,
  ) {
    showMenu<DeliveryOrdersPaymentFilter>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 220, 0, 0),
      items: [
        for (final entry in const [
          (DeliveryOrdersPaymentFilter.all, 'paymentAll'),
          (DeliveryOrdersPaymentFilter.cash, 'paymentCash'),
          (DeliveryOrdersPaymentFilter.card, 'paymentCard'),
          (DeliveryOrdersPaymentFilter.online, 'paymentOnline'),
        ])
          PopupMenuItem<DeliveryOrdersPaymentFilter>(
            key: Key('dp_orders_filter_${entry.$1.name}'),
            value: entry.$1,
            child: Row(
              children: [
                Icon(
                  entry.$1 == state.paymentFilter
                      ? Icons.check
                      : Icons.payments_outlined,
                  color: DeliveryAppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(DeliveryOrdersStrings.of(entry.$2, state.localeCode)),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null) {
        context
            .read<DeliveryOrdersPageBloc>()
            .add(DeliveryOrdersPaymentFilterChangedEvent(value));
      }
    });
  }

  static void _exportOrders(BuildContext context, DeliveryOrdersPageState state) {
    _showSnack(
      context,
      DeliveryOrdersStrings.of('exportHint', state.localeCode),
      DeliveryAppColors.primaryDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DeliveryAppColors.background,
      borderRadius: DeliveryAppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: () => onPressed(context, state),
        borderRadius: DeliveryAppSpacing.borderRadiusMd,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? DeliveryAppSpacing.sm : DeliveryAppSpacing.xs,
            vertical: DeliveryAppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: DeliveryAppSpacing.borderRadiusMd,
            border: Border.all(color: DeliveryAppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: DeliveryAppColors.textMuted, size: 17),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final int badgeCount;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    super.key,
    required this.icon,
    this.active = false,
    this.badgeCount = 0,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? DeliveryAppColors.primary
        : DeliveryAppColors.textMuted;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? DeliveryAppColors.primaryDark.withValues(alpha: 0.16)
            : DeliveryAppColors.background,
        borderRadius: DeliveryAppSpacing.borderRadiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: DeliveryAppSpacing.borderRadiusMd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: DeliveryAppSpacing.borderRadiusMd,
                  border: Border.all(
                    color: active
                        ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                        : DeliveryAppColors.border,
                  ),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    key: const Key('dp_orders_notification_badge'),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: DeliveryAppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: DeliveryAppTypography.caption.copyWith(
                          color: DeliveryAppColors.buttonPrimaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: badgeCount > 99 ? 8 : 10,
                          height: 1,
                        ),
                      ),
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

class _OrdersStatsRow extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersStatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final service = DeliveryOrdersService();
    final stats = [
      _StatData(
        key: 'dp_orders_stat_total',
        labelKey: 'total',
        value: '${state.totalCount}',
        color: DeliveryAppColors.primary,
        icon: Icons.receipt_long,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_today',
        labelKey: 'today',
        value: '${state.todayCount}',
        color: const Color(0xFF26A69A),
        icon: Icons.today_outlined,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_active',
        labelKey: 'active',
        value: '${state.activeCount}',
        color: DeliveryAppColors.info,
        icon: Icons.local_shipping,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_pending',
        labelKey: 'pending',
        value: '${state.pendingCount}',
        color: DeliveryAppColors.warning,
        icon: Icons.schedule,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_completed',
        labelKey: 'completed',
        value: '${state.completedCount}',
        color: DeliveryAppColors.primaryDark,
        icon: Icons.check_circle_outline,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_cancelled',
        labelKey: 'cancelled',
        value: '${state.cancelledCount}',
        color: DeliveryAppColors.error,
        icon: Icons.cancel_outlined,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_acceptance',
        labelKey: 'acceptance',
        value: '${state.acceptanceRate}%',
        color: const Color(0xFFBA68C8),
        icon: Icons.thumb_up_outlined,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_avg_time',
        labelKey: 'avgTime',
        value: '${state.averageDeliveryTimeMins} min',
        color: const Color(0xFF4DD0E1),
        icon: Icons.timer_outlined,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_rating',
        labelKey: 'rating',
        value: state.averageRating.toStringAsFixed(1),
        color: DeliveryAppColors.warning,
        icon: Icons.star_outline,
        lang: lang,
      ),
      _StatData(
        key: 'dp_orders_stat_earnings',
        labelKey: 'earningsTotal',
        value: service.formatCurrency(state.totalEarnings, lang),
        color: DeliveryAppColors.primary,
        icon: Icons.account_balance_wallet_outlined,
        lang: lang,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        const spacing = 12.0;

        if (!isDesktop) {
          return SizedBox(
            height: 64,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final stat in stats) ...[
                    SizedBox(
                      width: 140,
                      child: _StatChip(stat: stat),
                    ),
                    if (stat != stats.last) const SizedBox(width: spacing),
                  ],
                ],
              ),
            ),
          );
        }

        final columns = constraints.maxWidth >= 1000 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final stat in stats)
                SizedBox(
                  width: itemWidth,
                  child: _StatChip(stat: stat),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatData {
  final String key;
  final String labelKey;
  final String value;
  final Color color;
  final IconData icon;
  final String lang;

  const _StatData({
    required this.key,
    required this.labelKey,
    required this.value,
    required this.color,
    required this.icon,
    required this.lang,
  });
}

class _StatChip extends StatelessWidget {
  final _StatData stat;

  const _StatChip({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${DeliveryOrdersStrings.of(stat.labelKey, stat.lang)} ${stat.value}',
      child: DeliveryCard(
        key: Key(stat.key),
        padding: const EdgeInsets.symmetric(
          horizontal: DeliveryAppSpacing.sm,
          vertical: DeliveryAppSpacing.sm,
        ),
        borderRadius: DeliveryAppSpacing.radiusMd,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.12),
                borderRadius: DeliveryAppSpacing.borderRadiusSm,
              ),
              child: Icon(stat.icon, color: stat.color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DeliveryOrdersStrings.of(stat.labelKey, stat.lang),
                    style: DeliveryAppTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    stat.value,
                    style: DeliveryAppTypography.titleMedium.copyWith(
                      color: DeliveryAppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTabBar extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersTabBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final tabs = [
      _TabData(
        key: 'dp_orders_tab_all',
        tab: DeliveryOrdersTab.all,
        label: DeliveryOrdersStrings.of('tabAll', lang),
        count: state.totalCount,
      ),
      _TabData(
        key: 'dp_orders_tab_active',
        tab: DeliveryOrdersTab.active,
        label: DeliveryOrdersStrings.of('tabActive', lang),
        count: state.activeCount,
      ),
      _TabData(
        key: 'dp_orders_tab_pending',
        tab: DeliveryOrdersTab.pending,
        label: DeliveryOrdersStrings.of('tabPending', lang),
        count: state.pendingCount,
      ),
      _TabData(
        key: 'dp_orders_tab_completed',
        tab: DeliveryOrdersTab.completed,
        label: DeliveryOrdersStrings.of('tabCompleted', lang),
        count: state.completedCount,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DeliveryAppSpacing.md),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _TabPill(
                tab: tab,
                isSelected: state.activeTab == tab.tab,
              ),
            ),
        ],
      ),
    );
  }
}

class _TabData {
  final String key;
  final DeliveryOrdersTab tab;
  final String label;
  final int count;

  const _TabData({
    required this.key,
    required this.tab,
    required this.label,
    required this.count,
  });
}

class _TabPill extends StatelessWidget {
  final _TabData tab;
  final bool isSelected;

  const _TabPill({required this.tab, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: tab.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context
                .read<DeliveryOrdersPageBloc>()
                .add(DeliveryOrdersTabChangedEvent(tab.tab)),
            borderRadius: DeliveryAppSpacing.borderRadiusMd,
            child: AnimatedContainer(
              key: Key(tab.key),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: DeliveryAppSpacing.borderRadiusMd,
                border: Border.all(
                  color: isSelected
                      ? DeliveryAppColors.primary.withValues(alpha: 0.4)
                      : DeliveryAppColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      tab.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DeliveryAppTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? DeliveryAppColors.textPrimary
                            : DeliveryAppColors.textMuted,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DeliveryAppColors.primaryDark
                          : DeliveryAppColors.surface,
                      borderRadius: DeliveryAppSpacing.borderRadiusPill,
                    ),
                    child: Text(
                      '${tab.count}',
                      style: DeliveryAppTypography.caption.copyWith(
                        color: isSelected
                            ? DeliveryAppColors.buttonPrimaryText
                            : DeliveryAppColors.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  final DeliveryOrderCardModel order;
  final DeliveryOrdersPageState state;

  const _ActiveOrderBanner({required this.order, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_orders_banner'),
      margin: EdgeInsets.symmetric(horizontal: DeliveryAppSpacing.xl),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DeliveryAppColors.successBg, Color(0xFF0D141C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: DeliveryAppSpacing.borderRadiusLg,
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          return Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.16),
                  borderRadius: DeliveryAppSpacing.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: DeliveryAppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryOrdersStrings.of('currentDelivery', lang),
                      style: DeliveryAppTypography.caption.copyWith(
                        color: DeliveryAppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.restaurantName,
                      style: DeliveryAppTypography.titleMedium.copyWith(
                        color: DeliveryAppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DeliveryOrdersStrings.of('eta', lang)} '
                      '${order.etaMins > 0 ? '${order.etaMins} ${DeliveryOrdersStrings.of('min', lang)}' : '--'}',
                      style: DeliveryAppTypography.caption.copyWith(
                        color: DeliveryAppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (compact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('dp_orders_banner_navigate'),
                      onPressed: () => _showSnack(
                        context,
                        '${DeliveryOrdersStrings.of('directionsHint', lang)} '
                        '${order.deliveryAddress}',
                        DeliveryAppColors.primaryDark,
                      ),
                      icon: const Icon(
                        Icons.navigation,
                        color: DeliveryAppColors.primary,
                        size: 18,
                      ),
                      tooltip: DeliveryOrdersStrings.of('navigate', lang),
                    ),
                    IconButton(
                      key: const Key('dp_orders_banner_call'),
                      onPressed: () => _showCallBottomSheet(context, order, lang),
                      icon: const Icon(
                        Icons.call,
                        color: DeliveryAppColors.info,
                        size: 18,
                      ),
                      tooltip: DeliveryOrdersStrings.of('call', lang),
                    ),
                  ],
                )
              else ...[
                OutlinedButton.icon(
                  key: const Key('dp_orders_banner_navigate'),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/deliveryNavigationScreen',
                  ),
                  icon: const Icon(Icons.navigation, size: 15),
                  label: Text(
                    DeliveryOrdersStrings.of('navigate', lang),
                    style: DeliveryAppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.primary,
                    side: const BorderSide(color: DeliveryAppColors.primary),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: DeliveryAppSpacing.borderRadiusMd,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const Key('dp_orders_banner_call'),
                  onPressed: () => _showCallBottomSheet(context, order, lang),
                  icon: const Icon(Icons.call, size: 15),
                  label: Text(
                    DeliveryOrdersStrings.of('call', lang),
                    style: DeliveryAppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.info,
                    side: const BorderSide(color: DeliveryAppColors.info),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: DeliveryAppSpacing.borderRadiusMd,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LiveMapPanel extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _LiveMapPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Padding(
      padding: const EdgeInsets.only(
        right: DeliveryAppSpacing.xl,
        bottom: DeliveryAppSpacing.xl,
      ),
      child: Container(
        key: const Key('dp_orders_map_panel'),
        width: 360,
        decoration: BoxDecoration(
          color: const Color(0xFF0D141C),
          borderRadius: DeliveryAppSpacing.borderRadiusLg,
          border: Border.all(color: DeliveryAppColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _MapGridPainter()),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DeliveryAppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DeliveryOrdersStrings.of('liveMap', lang),
                    style: DeliveryAppTypography.titleMedium.copyWith(
                      color: DeliveryAppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Center(
                child: DeliveryChip(
                  variant: DeliveryChipVariant.success,
                  label: DeliveryOrdersStrings.of('liveTrackingSoon', lang),
                ),
              ),
            ),
          ],
        ),
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

    final routePaint = Paint()
      ..color = DeliveryAppColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.82)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.72,
        size.width * 0.30,
        size.height * 0.40,
        size.width * 0.52,
        size.height * 0.34,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.28,
        size.width * 0.70,
        size.height * 0.16,
        size.width * 0.84,
        size.height * 0.12,
      );
    canvas.drawPath(path, routePaint);

    final pickupPaint = Paint()..color = DeliveryAppColors.primary;
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.82),
      7,
      pickupPaint,
    );
    final deliveryPaint = Paint()..color = DeliveryAppColors.error;
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.12),
      7,
      deliveryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrderCardModel order;
  final DeliveryOrdersPageState state;

  const _OrderCard({required this.order, required this.state});

  DeliveryChipVariant _statusVariant() {
    switch (order.status) {
      case DeliveryOrderStatus.pending:
        return DeliveryChipVariant.warning;
      case DeliveryOrderStatus.active:
        return DeliveryChipVariant.info;
      case DeliveryOrderStatus.completed:
        return DeliveryChipVariant.success;
      case DeliveryOrderStatus.cancelled:
        return DeliveryChipVariant.error;
    }
  }

  String _statusLabel(String lang) {
    switch (order.status) {
      case DeliveryOrderStatus.pending:
        return DeliveryOrdersStrings.of('statusPending', lang);
      case DeliveryOrderStatus.active:
        return DeliveryOrdersStrings.of('statusActive', lang);
      case DeliveryOrderStatus.completed:
        return DeliveryOrdersStrings.of('statusCompleted', lang);
      case DeliveryOrderStatus.cancelled:
        return DeliveryOrdersStrings.of('statusCancelled', lang);
    }
  }

  String _updateLabel(String lang) {
    switch (order.status) {
      case DeliveryOrderStatus.pending:
        return DeliveryOrdersStrings.of('acceptOrder', lang);
      case DeliveryOrderStatus.active:
        return DeliveryOrdersStrings.of('completeDelivery', lang);
      default:
        return DeliveryOrdersStrings.of('orderCompleted', lang);
    }
  }

  DeliveryOrderStatus? _nextStatus() {
    return DeliveryOrdersService().getNextStatus(order.status);
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final service = DeliveryOrdersService();
    final canUpdate = _nextStatus() != null;
    final earnings = service.calculateEarnings(order.amount);
    final priorityLabel = order.priority
        ? DeliveryOrdersStrings.of('high', lang)
        : DeliveryOrdersStrings.of('normal', lang);

    return _HoverCard(
      orderId: order.orderId,
      onTap: () => Navigator.of(context).pushNamed(
        '/deliveryOrderDetails',
        arguments: {'orderId': order.orderId},
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DeliveryChip(
                  variant: _statusVariant(),
                  icon: Icons.circle,
                  label: _statusLabel(lang),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.orderId.startsWith('#')
                        ? order.orderId
                        : (order.orderId.length > 10 && !order.orderId.contains(' ')
                            ? '#${order.orderId.substring(0, 10).toUpperCase()}'
                            : '#${order.orderId}'),
                    style: DeliveryAppTypography.titleMedium.copyWith(
                      color: DeliveryAppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (order.priority) ...[
                  const SizedBox(width: 8),
                  DeliveryChip(
                    variant: DeliveryChipVariant.warning,
                    label: DeliveryOrdersStrings.of('priority', lang),
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  order.time,
                  style: DeliveryAppTypography.bodySmall.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AddressRow(
              icon: Icons.store,
              color: DeliveryAppColors.primary,
              label: DeliveryOrdersStrings.of('pickup', lang),
              value: order.restaurantName,
              address: order.pickupAddress,
            ),
            const SizedBox(height: 12),
            _AddressRow(
              icon: Icons.location_on,
              color: DeliveryAppColors.error,
              label: DeliveryOrdersStrings.of('delivery', lang),
              value: order.customerName,
              address: order.deliveryAddress,
            ),
            const SizedBox(height: 14),
            _OrderTimeline(status: order.status, lang: lang),
            const SizedBox(height: 12),
            Row(
              children: [
                _EtaChip(order: order, lang: lang),
                const SizedBox(width: 10),
                _EtaStatusChip(order: order, lang: lang),
                const Spacer(),
                _OrderMeta(
                  icon: Icons.star,
                  value: order.restaurantRating > 0
                      ? order.restaurantRating.toStringAsFixed(1)
                      : 'New',
                  iconColor: DeliveryAppColors.warning,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: DeliveryAppColors.border, height: 1),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _OrderMeta(
                  icon: Icons.shopping_bag_outlined,
                  value:
                      '${order.itemsCount} ${DeliveryOrdersStrings.of('items', lang)}',
                ),
                _OrderMeta(
                  icon: Icons.near_me_outlined,
                  value: service.formatDistance(order.distance),
                ),
                Text(
                  service.formatCurrency(order.amount, lang),
                  style: DeliveryAppTypography.h3.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (order.preparationTimeMins > 0 ||
                order.expectedTip > 0 ||
                order.deliveryBonus > 0) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (order.preparationTimeMins > 0)
                    DeliveryChip(
                      variant: DeliveryChipVariant.info,
                      icon: Icons.restaurant_outlined,
                      label:
                          '${DeliveryOrdersStrings.of('prep', lang)} ${order.preparationTimeMins} ${DeliveryOrdersStrings.of('min', lang)}',
                    ),
                  DeliveryChip(
                    variant: order.priority
                        ? DeliveryChipVariant.warning
                        : DeliveryChipVariant.neutral,
                    icon: order.priority
                        ? Icons.flag
                        : Icons.flag_outlined,
                    label:
                        '${DeliveryOrdersStrings.of('priority', lang)}: $priorityLabel',
                  ),
                  if (order.expectedTip > 0)
                    DeliveryChip(
                      variant: DeliveryChipVariant.warning,
                      icon: Icons.volunteer_activism_outlined,
                      label:
                          '${DeliveryOrdersStrings.of('tip', lang)} ${service.formatCurrency(order.expectedTip, lang)}',
                    ),
                  if (order.deliveryBonus > 0)
                    DeliveryChip(
                      variant: DeliveryChipVariant.success,
                      icon: Icons.card_giftcard,
                      label:
                          '${DeliveryOrdersStrings.of('bonus', lang)} ${service.formatCurrency(order.deliveryBonus, lang)}',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DeliveryAppSpacing.sm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: DeliveryAppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: DeliveryAppSpacing.borderRadiusMd,
                border: Border.all(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.2),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: DeliveryAppColors.primary,
                    size: 18,
                  ),
                  Text(
                    '${DeliveryOrdersStrings.of('earnings', lang)}: '
                    '${service.formatCurrency(earnings, lang)}',
                    style: DeliveryAppTypography.titleMedium.copyWith(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${DeliveryOrdersStrings.of('payment', lang)}: ${order.paymentType}',
                    style: DeliveryAppTypography.caption.copyWith(
                      color: DeliveryAppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CardActionButton(
                  buttonKey: Key('dp_orders_navigate_${order.orderId}'),
                  outlined: true,
                  foregroundColor: DeliveryAppColors.primary,
                  icon: Icons.navigation,
                  label: DeliveryOrdersStrings.of('navigate', lang),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/deliveryNavigationScreen',
                  ),
                ),
                _CardActionButton(
                  buttonKey: Key('dp_orders_call_${order.orderId}'),
                  outlined: true,
                  foregroundColor: DeliveryAppColors.info,
                  icon: Icons.call,
                  label: DeliveryOrdersStrings.of('call', lang),
                  onTap: () => _showCallBottomSheet(context, order, lang),
                ),
                _CardActionButton(
                  buttonKey: Key('dp_orders_chat_${order.orderId}'),
                  outlined: true,
                  foregroundColor: const Color(0xFFBA68C8),
                  icon: Icons.chat_outlined,
                  label: DeliveryOrdersStrings.of('chat', lang),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/deliveryChat',
                    arguments: {
                      'orderId': order.orderId,
                      'customerId': order.orderId,
                      'customerName': order.customerName,
                      'customerPhone': order.phoneNumber,
                      'orderTitle': order.restaurantName,
                      'orderTotal': order.amount,
                    },
                  ),
                ),
                _CardActionButton(
                  buttonKey: Key('dp_orders_details_${order.orderId}'),
                  outlined: true,
                  foregroundColor: DeliveryAppColors.textMuted,
                  icon: Icons.info_outline,
                  label: DeliveryOrdersStrings.of('viewDetails', lang),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/deliveryOrderDetails',
                    arguments: {'orderId': order.orderId},
                  ),
                ),
                _CardActionButton(
                  buttonKey: Key('dp_orders_update_${order.orderId}'),
                  outlined: false,
                  foregroundColor: DeliveryAppColors.buttonPrimaryText,
                  icon: canUpdate ? Icons.arrow_forward : Icons.check,
                  label: _updateLabel(lang),
                  enabled: canUpdate,
                  onTap: canUpdate
                      ? () => context
                          .read<DeliveryOrdersPageBloc>()
                          .add(
                            DeliveryOrdersUpdateStatusEvent(
                              orderId: order.orderId,
                              status: _nextStatus()!,
                            ),
                          )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EtaChip extends StatelessWidget {
  final DeliveryOrderCardModel order;
  final String lang;

  const _EtaChip({required this.order, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DeliveryChip(
      key: Key('dp_orders_eta_${order.orderId}'),
      variant: DeliveryChipVariant.info,
      icon: Icons.timer_outlined,
      label: '${DeliveryOrdersStrings.of('eta', lang)} '
          '${order.etaMins > 0 ? '${order.etaMins} ${DeliveryOrdersStrings.of('min', lang)}' : '--'}',
    );
  }
}

class _EtaStatusChip extends StatelessWidget {
  final DeliveryOrderCardModel order;
  final String lang;

  const _EtaStatusChip({required this.order, required this.lang});

  @override
  Widget build(BuildContext context) {
    final DeliveryChipVariant variant;
    final String text;
    if (order.lateMins > 0) {
      variant = DeliveryChipVariant.error;
      text = '${DeliveryOrdersStrings.of('lateBy', lang)} '
          '${order.lateMins} ${DeliveryOrdersStrings.of('min', lang)}';
    } else if (order.priority) {
      variant = DeliveryChipVariant.warning;
      text = DeliveryOrdersStrings.of('urgent', lang);
    } else {
      variant = DeliveryChipVariant.success;
      text = DeliveryOrdersStrings.of('onTime', lang);
    }
    return DeliveryChip(
      key: Key('dp_orders_eta_status_${order.orderId}'),
      variant: variant,
      icon: Icons.circle,
      label: text,
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final DeliveryOrderStatus status;
  final String lang;

  const _OrderTimeline({required this.status, required this.lang});

  int get _progress {
    switch (status) {
      case DeliveryOrderStatus.cancelled:
        return 0;
      case DeliveryOrderStatus.pending:
        return 1;
      case DeliveryOrderStatus.active:
        return 3;
      case DeliveryOrderStatus.completed:
        return 5;
    }
  }

  List<String> get _labels => [
        DeliveryOrdersStrings.of('tlPickup', lang),
        DeliveryOrdersStrings.of('tlReached', lang),
        DeliveryOrdersStrings.of('tlPicked', lang),
        DeliveryOrdersStrings.of('tlEnRoute', lang),
        DeliveryOrdersStrings.of('tlDelivered', lang),
      ];

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final labels = _labels;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 430,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: 3.5),
                    color: i <= progress
                        ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                        : DeliveryAppColors.border,
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < progress
                          ? DeliveryAppColors.primary
                          : DeliveryAppColors.surface,
                      border: Border.all(
                        color: i <= progress
                            ? DeliveryAppColors.primary
                            : DeliveryAppColors.textDisabled,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 76,
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DeliveryAppTypography.caption.copyWith(
                        color: i < progress
                            ? DeliveryAppColors.textSecondary
                            : DeliveryAppColors.textMuted,
                        fontWeight: i == progress - 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final Key buttonKey;
  final bool outlined;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _CardActionButton({
    required this.buttonKey,
    required this.outlined,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: DeliveryAppSpacing.minTouchTargetSize,
      child: outlined
          ? OutlinedButton.icon(
              key: buttonKey,
              onPressed: enabled ? onTap : null,
              icon: Icon(icon, size: 15),
              label: Text(
                label,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: BorderSide(color: foregroundColor),
                shape: RoundedRectangleBorder(
                  borderRadius: DeliveryAppSpacing.borderRadiusMd,
                ),
              ),
            )
          : ElevatedButton.icon(
              key: buttonKey,
              onPressed: enabled ? onTap : null,
              icon: Icon(icon, size: 15),
              label: Text(
                label,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: DeliveryAppColors.buttonPrimaryText,
                disabledBackgroundColor: DeliveryAppColors.surfaceElevated,
                disabledForegroundColor: DeliveryAppColors.textDisabled,
                shape: RoundedRectangleBorder(
                  borderRadius: DeliveryAppSpacing.borderRadiusMd,
                ),
              ),
            ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final String orderId;
  final Widget child;
  final VoidCallback? onTap;

  const _HoverCard({required this.orderId, required this.child, this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
        scale: _hovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          key: Key('dp_orders_card_${widget.orderId}'),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? DeliveryAppColors.primary.withValues(alpha: 0.55)
                  : DeliveryAppColors.borderSubtle,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? DeliveryAppColors.primaryDark.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: _hovered ? 28 : 16,
                offset: Offset(0, _hovered ? 10 : 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
      ),
    );
  }
}

class _OrdersFab extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersFab({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _FabMiniButton(
          fabKey: const Key('dp_orders_fab_accept'),
          icon: Icons.add_circle_outline,
          label: DeliveryOrdersStrings.of('acceptNext', lang),
          onTap: () {
            final pending = state.orders
                .where((o) => o.status == DeliveryOrderStatus.pending)
                .firstOrNull;
            if (pending == null) {
              _showSnack(
                context,
                DeliveryOrdersStrings.of('noPending', lang),
                DeliveryAppColors.warning,
              );
              return;
            }
            context.read<DeliveryOrdersPageBloc>().add(
                  DeliveryOrdersUpdateStatusEvent(
                    orderId: pending.orderId,
                    status: DeliveryOrderStatus.active,
                  ),
                );
            _showSnack(
              context,
              '${DeliveryOrdersStrings.of('accepted', lang)} #${pending.orderId}',
              DeliveryAppColors.primaryDark,
            );
          },
        ),
        const SizedBox(height: 10),
        _FabMiniButton(
          fabKey: const Key('dp_orders_fab_offline'),
          icon: Icons.power_settings_new,
          label: DeliveryOrdersStrings.of('goOffline', lang),
          onTap: () => _showSnack(
            context,
            DeliveryOrdersStrings.of('offlineHint', lang),
            DeliveryAppColors.error,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: DeliveryAppColors.primaryDark,
          shape: const CircleBorder(),
          elevation: 8,
          shadowColor: DeliveryAppColors.primaryDark.withValues(alpha: 0.5),
          child: InkWell(
            key: const Key('dp_orders_fab_refresh'),
            customBorder: const CircleBorder(),
            onTap: () => context
                .read<DeliveryOrdersPageBloc>()
                .add(const DeliveryOrdersRefreshEvent()),
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.refresh,
                color: DeliveryAppColors.buttonPrimaryText,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabMiniButton extends StatelessWidget {
  final Key fabKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FabMiniButton({
    required this.fabKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DeliveryAppColors.surface,
      borderRadius: BorderRadius.circular(999),
      elevation: 4,
      child: InkWell(
        key: fabKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: DeliveryAppColors.primary, size: 16),
              const SizedBox(width: 7),
              Text(
                label,
                style: DeliveryAppTypography.bodySmall.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: DeliveryAppSpacing.borderRadiusSm,
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                address,
                style: DeliveryAppTypography.bodySmall.copyWith(
                  color: DeliveryAppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderMeta extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;

  const _OrderMeta({
    required this.icon,
    required this.value,
    this.iconColor = DeliveryAppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 15),
        const SizedBox(width: 5),
        Text(
          value,
          style: DeliveryAppTypography.bodySmall.copyWith(
            color: DeliveryAppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _OrdersNoResults extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersNoResults({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Center(
      child: SingleChildScrollView(
        padding: DeliveryAppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('dp_orders_no_results'),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DeliveryAppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                color: DeliveryAppColors.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryOrdersStrings.of('noResultsTitle', lang),
              style: DeliveryAppTypography.titleLarge.copyWith(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                DeliveryOrdersStrings.of('noResultsSub', lang),
                textAlign: TextAlign.center,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _RefreshButton(state: state),
          ],
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _RefreshButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return DeliveryButton(
      key: const Key('dp_orders_refresh'),
      label: DeliveryOrdersStrings.of('refresh', lang),
      onPressed: () => context
          .read<DeliveryOrdersPageBloc>()
          .add(const DeliveryOrdersRefreshEvent()),
      variant: DeliveryButtonVariant.primary,
      icon: Icons.refresh,
      isFullWidth: false,
    );
  }
}

class _OrdersLoadingShell extends StatelessWidget {
  const _OrdersLoadingShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_orders_loading'),
      color: DeliveryAppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(DeliveryAppSpacing.md),
        children: [
          _skeletonBox(height: 130),
          const SizedBox(height: 16),
          _skeletonBox(height: 76),
          const SizedBox(height: 16),
          _skeletonBox(height: 56),
          const SizedBox(height: 20),
          for (var i = 0; i < 3; i++) ...[
            _skeletonBox(height: 300),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: DeliveryAppSpacing.borderRadiusLg,
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
    );
  }
}

class _OrdersErrorShell extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_orders_error'),
      color: DeliveryAppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: DeliveryAppSpacing.paddingXl,
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
                DeliveryOrdersStrings.of('somethingWentWrong', lang),
                textAlign: TextAlign.center,
                style: DeliveryAppTypography.titleLarge.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: DeliveryAppTypography.bodyMedium.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              DeliveryButton(
                key: const Key('dp_orders_retry'),
                label: DeliveryOrdersStrings.of('retry', lang),
                onPressed: () => context
                    .read<DeliveryOrdersPageBloc>()
                    .add(const DeliveryOrdersInitEvent()),
                variant: DeliveryButtonVariant.primary,
                icon: Icons.refresh,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersEmptyShell extends StatelessWidget {
  final DeliveryOrdersPageState state;

  const _OrdersEmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_orders_empty'),
      color: DeliveryAppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: DeliveryAppSpacing.paddingXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  color: DeliveryAppColors.textMuted,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DeliveryOrdersStrings.of('emptyTitle', lang),
                style: DeliveryAppTypography.titleLarge.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  DeliveryOrdersStrings.of('emptySub', lang),
                  textAlign: TextAlign.center,
                  style: DeliveryAppTypography.bodyMedium.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DeliveryButton(
                key: const Key('dp_orders_stay_online'),
                label: DeliveryOrdersStrings.of('stayOnline', lang),
                onPressed: () => _showSnack(
                  context,
                  DeliveryOrdersStrings.of('stayOnlineHint', lang),
                  DeliveryAppColors.primaryDark,
                ),
                variant: DeliveryButtonVariant.primary,
                icon: Icons.wifi,
                isFullWidth: false,
              ),
              const SizedBox(height: 10),
              _RefreshButton(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showOrdersNotificationSheet(
  BuildContext context,
  DeliveryOrdersPageState state,
) {
  final lang = state.localeCode;
  final pendingOrders =
      state.orders.where((o) => o.status == DeliveryOrderStatus.pending).toList();

  showModalBottomSheet(
    context: context,
    backgroundColor: DeliveryAppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DeliveryAppColors.primaryDark.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: DeliveryAppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DeliveryOrdersStrings.of('notifications', lang),
                        style: DeliveryAppTypography.h4.copyWith(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pendingOrders.isNotEmpty
                            ? '${pendingOrders.length} pending order requests available'
                            : DeliveryOrdersStrings.of('noNewNotifications', lang),
                        style: DeliveryAppTypography.bodySmall.copyWith(
                          color: DeliveryAppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: DeliveryAppColors.border),
            const SizedBox(height: 8),
            if (pendingOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_off_outlined,
                        color: DeliveryAppColors.textMuted,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DeliveryOrdersStrings.of('noNewNotifications', lang),
                        style: DeliveryAppTypography.bodyMedium.copyWith(
                          color: DeliveryAppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: pendingOrders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderId,
                                style: DeliveryAppTypography.titleSmall.copyWith(
                                  color: DeliveryAppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: DeliveryAppColors.warningBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '₹${order.amount.toStringAsFixed(2)}',
                                  style: DeliveryAppTypography.caption.copyWith(
                                    color: DeliveryAppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${order.restaurantName} → ${order.customerName}',
                            style: DeliveryAppTypography.bodySmall.copyWith(
                              color: DeliveryAppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.pickupAddress} (${order.distance} km)',
                            style: DeliveryAppTypography.caption.copyWith(
                              color: DeliveryAppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DeliveryAppColors.primary,
                                  foregroundColor:
                                      DeliveryAppColors.buttonPrimaryText,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context.read<DeliveryOrdersPageBloc>().add(
                                        DeliveryOrdersUpdateStatusEvent(
                                          orderId: order.orderId,
                                          status: DeliveryOrderStatus.active,
                                        ),
                                      );
                                },
                                child: Text(
                                  DeliveryOrdersStrings.of('acceptOrder', lang),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

void _showCallBottomSheet(
  BuildContext context,
  DeliveryOrderCardModel order,
  String lang,
) {
  final hasPhone = order.phoneNumber.isNotEmpty;
  showModalBottomSheet(
    context: context,
    backgroundColor: DeliveryAppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DeliveryAppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasPhone
                    ? DeliveryAppColors.infoBg
                    : DeliveryAppColors.warningBg,
                border: Border.all(
                  color: hasPhone
                      ? DeliveryAppColors.infoBorder
                      : DeliveryAppColors.warning,
                ),
              ),
              child: Icon(
                hasPhone ? Icons.person : Icons.phone_disabled,
                color: hasPhone
                    ? DeliveryAppColors.info
                    : DeliveryAppColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              order.customerName,
              style: const TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasPhone) ...[
              const SizedBox(height: 6),
              Text(
                order.phoneNumber,
                style: const TextStyle(
                  color: DeliveryAppColors.textMuted,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DeliveryAppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_disabled,
                      color: DeliveryAppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${DeliveryOrdersStrings.of('noPhone', lang)}${order.customerName}',
                        style: const TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasPhone
                    ? () {
                        Navigator.of(ctx).pop();
                        _launchDialer(order.phoneNumber);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryAppColors.info,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      DeliveryAppColors.info.withValues(alpha: 0.25),
                  disabledForegroundColor: DeliveryAppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.call, size: 20),
                label: Text(
                  hasPhone
                      ? DeliveryOrdersStrings.of('callCustomer', lang)
                      : '${DeliveryOrdersStrings.of('noPhone', lang)}${order.customerName}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DeliveryAppColors.textMuted,
                  side: const BorderSide(color: DeliveryAppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _launchDialer(String phoneNumber) async {
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
