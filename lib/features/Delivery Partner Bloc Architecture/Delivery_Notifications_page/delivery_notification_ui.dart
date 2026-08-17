import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/delivery_partner_notification_model.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_design_system.dart';
import '../Delivery_Chat_page/Delivery_Chat_page_ui.dart';
import '../Delivery_Earnings Dashboard_page/Delivery_Earnings Dashboard_page_ui.dart';
import '../Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';
import '../Delivery_Orders_page/Delivery_Orders_page_ui.dart';
import '../Delivery_Profile_page/Delivery_Profile_page_ui.dart';
import '../Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';
import 'delivery_notification_bloc.dart';
import 'delivery_notification_event.dart';
import 'delivery_notification_repository.dart';
import 'delivery_notification_service.dart';
import 'delivery_notification_state.dart';
import 'delivery_notification_strings.dart';
import 'widgets/delivery_notification_empty_view.dart';
import 'widgets/delivery_notification_filter_chips.dart';
import 'widgets/delivery_notification_in_app_toast.dart';
import 'widgets/delivery_notification_shimmer.dart';
import 'widgets/delivery_notification_tile_card.dart';

class DeliveryNotificationsPage extends StatelessWidget {
  final DeliveryNotificationRepositoryBase? repository;
  final DeliveryNotificationServiceBase? service;
  final DeliveryNotificationBloc? bloc;
  final String? partnerId;

  const DeliveryNotificationsPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
    this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    String uid = partnerId ?? '';
    if (uid.isEmpty) {
      try {
        uid = FirebaseAuth.instance.currentUser?.uid ?? 'sample_partner_uid';
      } catch (_) {
        uid = 'sample_partner_uid';
      }
    }

    if (bloc != null) {
      return BlocProvider<DeliveryNotificationBloc>.value(
        value: bloc!,
        child: const _DeliveryNotificationsView(),
      );
    }

    return BlocProvider<DeliveryNotificationBloc>(
      create: (context) {
        DeliveryNotificationRepositoryBase effectiveRepo;
        DeliveryNotificationServiceBase effectiveService;
        try {
          effectiveRepo = repository ?? context.read<DeliveryNotificationRepositoryBase>();
        } catch (_) {
          effectiveRepo = repository ?? DeliveryNotificationRepository();
        }
        try {
          effectiveService = service ?? context.read<DeliveryNotificationServiceBase>();
        } catch (_) {
          effectiveService = service ?? DeliveryNotificationService();
        }
        return DeliveryNotificationBloc(
          repository: effectiveRepo,
          service: effectiveService,
        )..add(DeliveryNotificationSubscribeEvent(uid));
      },
      child: const _DeliveryNotificationsView(),
    );
  }
}

class _DeliveryNotificationsView extends StatefulWidget {
  const _DeliveryNotificationsView();

  @override
  State<_DeliveryNotificationsView> createState() =>
      _DeliveryNotificationsViewState();
}

class _DeliveryNotificationsViewState
    extends State<_DeliveryNotificationsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleNotificationTap(
    BuildContext context,
    DeliveryPartnerNotificationModel notif,
  ) {
    // Mark as read immediately on tap
    context
        .read<DeliveryNotificationBloc>()
        .add(DeliveryNotificationMarkAsReadEvent(notif.id));

    // Handle deep navigation based on category & data
    switch (notif.category) {
      case DeliveryNotificationCategory.order:
        final orderId = notif.data['orderId']?.toString();
        if (orderId != null && orderId.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DeliveryOrdersPage(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DeliveryOrdersPage(),
            ),
          );
        }
        break;

      case DeliveryNotificationCategory.earnings:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryWalletPage(),
          ),
        );
        break;

      case DeliveryNotificationCategory.account:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryProfilePage(),
          ),
        );
        break;

      case DeliveryNotificationCategory.chat:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryChatPage(),
          ),
        );
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryNotificationBloc, DeliveryNotificationState>(
      builder: (context, state) {
        final localeCode = state.localeCode;
        final bloc = context.read<DeliveryNotificationBloc>();

        return Scaffold(
          backgroundColor: DeliveryAppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: DeliveryAppColors.surfaceDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryNotificationStrings.of('title', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (state.unreadCount > 0)
                  Text(
                    DeliveryNotificationStrings.of(
                      'unreadBadge',
                      localeCode,
                    ).replaceAll('{count}', state.unreadCount.toString()),
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            actions: [
              if (state.unreadCount > 0)
                TextButton(
                  onPressed: () {
                    bloc.add(const DeliveryNotificationMarkAllAsReadEvent());
                  },
                  child: Text(
                    DeliveryNotificationStrings.of('markAllAsRead', localeCode),
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (state.notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Color(0xFF94A3B8)),
                  tooltip:
                      DeliveryNotificationStrings.of('clearAll', localeCode),
                  onPressed: () {
                    _showClearAllDialog(context, bloc, localeCode);
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Search Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: DeliveryNotificationStrings.of(
                          'searchHint',
                          localeCode,
                        ),
                        hintStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xFF64748B),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  bloc.add(
                                    const DeliveryNotificationSearchChangedEvent(
                                        ''),
                                  );
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: DeliveryAppColors.surfaceMedium,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        bloc.add(
                            DeliveryNotificationSearchChangedEvent(val));
                      },
                    ),
                  ),

                  // Filter Chips
                  DeliveryNotificationFilterChips(
                    selectedFilter: state.selectedFilter,
                    localeCode: localeCode,
                    unreadCount: state.unreadCount,
                    onFilterSelected: (filter) {
                      bloc.add(
                          DeliveryNotificationFilterChangedEvent(filter));
                    },
                  ),

                  const SizedBox(height: 4),

                  // Notification List / States
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.status ==
                            DeliveryNotificationStatus.loading) {
                          return const DeliveryNotificationShimmer();
                        }

                        if (state.status ==
                            DeliveryNotificationStatus.error) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  DeliveryNotificationStrings.of(
                                    'errorTitle',
                                    localeCode,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    final uid = FirebaseAuth
                                            .instance.currentUser?.uid ??
                                        '';
                                    bloc.add(
                                      DeliveryNotificationSubscribeEvent(uid),
                                    );
                                  },
                                  child: Text(
                                    DeliveryNotificationStrings.of(
                                      'retry',
                                      localeCode,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.filteredNotifications.isEmpty) {
                          return DeliveryNotificationEmptyView(
                            localeCode: localeCode,
                            onRefresh: () {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid ?? '';
                              bloc.add(
                                DeliveryNotificationSubscribeEvent(uid),
                              );
                            },
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            final uid =
                                FirebaseAuth.instance.currentUser?.uid ?? '';
                            bloc.add(
                              DeliveryNotificationSubscribeEvent(uid),
                            );
                          },
                          color: DeliveryAppColors.primary,
                          child: ListView.builder(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            itemCount: state.filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notif =
                                  state.filteredNotifications[index];
                              return DeliveryNotificationTileCard(
                                key: ValueKey(notif.id),
                                notification: notif,
                                localeCode: localeCode,
                                service: bloc.service,
                                onTap: () =>
                                    _handleNotificationTap(context, notif),
                                onMarkAsRead: () {
                                  bloc.add(
                                    DeliveryNotificationMarkAsReadEvent(
                                      notif.id,
                                    ),
                                  );
                                },
                                onDelete: () {
                                  bloc.add(
                                    DeliveryNotificationDeleteEvent(
                                      notif.id,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Real-time in-app toast notification popup
              if (state.activeInAppNotification != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: DeliveryNotificationInAppToast(
                    notification: state.activeInAppNotification!,
                    localeCode: localeCode,
                    service: bloc.service,
                    onTap: () {
                      final notif = state.activeInAppNotification!;
                      bloc.add(const DeliveryNotificationDismissInAppEvent());
                      _handleNotificationTap(context, notif);
                    },
                    onDismiss: () {
                      bloc.add(const DeliveryNotificationDismissInAppEvent());
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    DeliveryNotificationBloc bloc,
    String localeCode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DeliveryAppColors.surfaceMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DeliveryNotificationStrings.of('clearAll', localeCode),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          DeliveryNotificationStrings.of('emptySub', localeCode),
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(const DeliveryNotificationClearAllEvent());
            },
            child: Text(
              DeliveryNotificationStrings.of('clearAll', localeCode),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
