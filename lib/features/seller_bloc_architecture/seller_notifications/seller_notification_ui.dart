import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/seller_notification_model.dart';
import '../../../core/repositories/i_seller_notification_repository.dart';
import '../../../repositories/firebase_seller_notification_repository.dart';
import 'seller_notification_bloc.dart';
import 'seller_notification_event.dart';
import 'seller_notification_service.dart';
import 'seller_notification_state.dart';
import 'seller_notification_strings.dart';
import 'widgets/seller_notification_category_chips.dart';
import 'widgets/seller_notification_empty_view.dart';
import 'widgets/seller_notification_shimmer.dart';
import 'widgets/seller_notification_tile_card.dart';
import 'widgets/seller_notification_toast.dart';

// Feature route imports for seamless action navigation
import '../orders_list/orders_list_page_ui.dart';
import '../chat_support_page_/chat_support_page_ui.dart';
import '../overall_rating_page/overall_rating_page__ui.dart';
import '../inventory_low_stock/inventory_low_stock_page_ui.dart';
import '../seller_wallet_page/seller_wallet_page__ui.dart';
import '../promotions_coupons_page_/promotions_coupons_page_ui.dart';
import '../new_order_notification/new_order_notification_ui.dart';

/// Top-level Seller Notifications Screen supporting responsive desktop/tablet/mobile layouts,
/// real-time Firestore stream, search, filtering, audio alerts, and bilingual translations.
class SellerNotificationPageUI extends StatelessWidget {
  final ISellerNotificationRepository? repository;
  final SellerNotificationBloc? bloc;
  final String? sellerId;
  final bool isTamil;

  const SellerNotificationPageUI({
    super.key,
    this.repository,
    this.bloc,
    this.sellerId,
    this.isTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<SellerNotificationBloc>.value(
        value: bloc!,
        child: _SellerNotificationContentView(isTamil: isTamil),
      );
    }

    final effectiveSellerId =
        sellerId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveRepo = repository ??
        _tryGetRepo(context) ??
        FirebaseSellerNotificationRepository();

    return BlocProvider<SellerNotificationBloc>(
      create: (context) => SellerNotificationBloc(
        repository: effectiveRepo,
        service: SellerNotificationService(),
      )..add(StartListeningSellerNotifications(effectiveSellerId)),
      child: _SellerNotificationContentView(isTamil: isTamil),
    );
  }

  ISellerNotificationRepository? _tryGetRepo(BuildContext context) {
    try {
      return context.read<ISellerNotificationRepository>();
    } catch (_) {
      return null;
    }
  }
}

class _SellerNotificationContentView extends StatefulWidget {
  final bool isTamil;

  const _SellerNotificationContentView({required this.isTamil});

  @override
  State<_SellerNotificationContentView> createState() =>
      _SellerNotificationContentViewState();
}

class _SellerNotificationContentViewState
    extends State<_SellerNotificationContentView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1024;
                final isTablet =
                    constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                final double horizontalPadding =
                    isDesktop ? 64.0 : (isTablet ? 32.0 : 0.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: BlocConsumer<SellerNotificationBloc,
                          SellerNotificationState>(
                        listener: (context, state) {
                          if (state is SellerNotificationError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is SellerNotificationLoading ||
                              state is SellerNotificationInitial) {
                            return const SellerNotificationShimmer();
                          } else if (state is SellerNotificationLoaded) {
                            return _buildLoadedContent(context, state);
                          } else if (state is SellerNotificationError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(state.message),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      final uid = FirebaseAuth
                                              .instance.currentUser?.uid ??
                                          '';
                                      context
                                          .read<SellerNotificationBloc>()
                                          .add(
                                              StartListeningSellerNotifications(
                                                  uid));
                                    },
                                    child: Text(widget.isTamil
                                        ? SellerNotificationStrings.refreshTa
                                        : SellerNotificationStrings.refreshEn),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // In-App Real-Time Toast Overlay
          BlocBuilder<SellerNotificationBloc, SellerNotificationState>(
            buildWhen: (prev, curr) {
              if (curr is SellerNotificationLoaded) {
                return curr.latestArrivedToast != null;
              }
              return false;
            },
            builder: (context, state) {
              if (state is SellerNotificationLoaded &&
                  state.latestArrivedToast != null) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SellerNotificationToast(
                    notification: state.latestArrivedToast!,
                    isTamil: widget.isTamil,
                    onDismiss: () {
                      context
                          .read<SellerNotificationBloc>()
                          .add(const DismissSellerInAppToast());
                    },
                    onTap: () {
                      context
                          .read<SellerNotificationBloc>()
                          .add(const DismissSellerInAppToast());
                      _handleNotificationAction(
                          context, state.latestArrivedToast!);
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F172A),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.isTamil
                    ? SellerNotificationStrings.searchPlaceholderTa
                    : SellerNotificationStrings.searchPlaceholderEn,
                hintStyle:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
              onChanged: (query) {
                context
                    .read<SellerNotificationBloc>()
                    .add(SellerNotificationSearchChanged(query));
              },
            )
          : Row(
              children: [
                Text(
                  widget.isTamil
                      ? SellerNotificationStrings.appTitleTa
                      : SellerNotificationStrings.appTitleEn,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<SellerNotificationBloc, SellerNotificationState>(
                  builder: (context, state) {
                    if (state is SellerNotificationLoaded &&
                        state.unreadCount > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4B3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.unreadCount > 99
                              ? '99+'
                              : state.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            color: const Color(0xFF475569),
          ),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchController.clear();
                context
                    .read<SellerNotificationBloc>()
                    .add(const SellerNotificationSearchChanged(''));
              } else {
                _isSearching = true;
              }
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF475569)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'mark_all_read') {
              context
                  .read<SellerNotificationBloc>()
                  .add(const MarkAllSellerNotificationsAsRead());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.isTamil
                      ? SellerNotificationStrings.allMarkedAsReadTa
                      : SellerNotificationStrings.allMarkedAsReadEn),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (value == 'clear_all') {
              _showClearAllDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  const Icon(Icons.done_all_rounded,
                      size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Text(widget.isTamil
                      ? SellerNotificationStrings.markAllReadTa
                      : SellerNotificationStrings.markAllReadEn),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep_rounded,
                      size: 18, color: Color(0xFFEF4444)),
                  const SizedBox(width: 10),
                  Text(
                    widget.isTamil
                        ? SellerNotificationStrings.clearAllTa
                        : SellerNotificationStrings.clearAllEn,
                    style: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadedContent(
      BuildContext context, SellerNotificationLoaded state) {
    final counts = _calculateFilterCounts(state.allNotifications);

    return Column(
      children: [
        const SizedBox(height: 12),
        // Filter Chips Bar
        SellerNotificationCategoryChips(
          selectedFilter: state.activeFilter,
          counts: counts,
          isTamil: widget.isTamil,
          onFilterSelected: (filter) {
            context
                .read<SellerNotificationBloc>()
                .add(SellerCategoryFilterSelected(filter));
          },
        ),
        const SizedBox(height: 12),

        // Notification List or Empty View
        Expanded(
          child: state.isEmpty
              ? SellerNotificationEmptyView(
                  isTamil: widget.isTamil,
                  onRefresh: () {
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    context.read<SellerNotificationBloc>().add(
                        StartListeningSellerNotifications(uid));
                  },
                )
              : RefreshIndicator(
                  color: const Color(0xFFFF4B3A),
                  onRefresh: () async {
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    context.read<SellerNotificationBloc>().add(
                        StartListeningSellerNotifications(uid));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.notifications[index];
                      return SellerNotificationTileCard(
                        notification: item,
                        isTamil: widget.isTamil,
                        onTap: () {
                          if (item.isUnread) {
                            context
                                .read<SellerNotificationBloc>()
                                .add(MarkSellerNotificationAsRead(item.id));
                          }
                          _handleNotificationAction(context, item);
                        },
                        onDismiss: () {
                          context
                              .read<SellerNotificationBloc>()
                              .add(DeleteSellerNotification(item.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.isTamil
                                  ? SellerNotificationStrings
                                      .notificationDeletedTa
                                  : SellerNotificationStrings
                                      .notificationDeletedEn),
                              action: SnackBarAction(
                                label: widget.isTamil
                                    ? SellerNotificationStrings.undoTa
                                    : SellerNotificationStrings.undoEn,
                                onPressed: () {
                                  context
                                      .read<SellerNotificationBloc>()
                                      .add(RestoreSellerNotification(item));
                                },
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        onActionTap: () {
                          if (item.isUnread) {
                            context
                                .read<SellerNotificationBloc>()
                                .add(MarkSellerNotificationAsRead(item.id));
                          }
                          _handleNotificationAction(context, item);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _handleNotificationAction(
      BuildContext context, SellerNotificationModel item) {
    final action = item.effectiveActionType;
    final currentSellerId =
        FirebaseAuth.instance.currentUser?.uid ?? (item.sellerId.isNotEmpty ? item.sellerId : 'sample_seller_id');

    switch (action) {
      case SellerNotificationActionType.navigateNewOrders:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NewOrderNotificationPage(),
          ),
        );
        break;
      case SellerNotificationActionType.navigateOrder:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OrdersListPage(),
          ),
        );
        break;
      case SellerNotificationActionType.navigateChat:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatSupportPage(sellerId: currentSellerId),
          ),
        );
        break;
      case SellerNotificationActionType.navigateReviews:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OverallRatingPage(),
          ),
        );
        break;
      case SellerNotificationActionType.navigateInventory:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const InventoryLowStockPage(),
          ),
        );
        break;
      case SellerNotificationActionType.navigateWallet:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SellerWalletPage(),
          ),
        );
        break;
      case SellerNotificationActionType.navigatePromotions:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PromotionsCouponsPage(sellerId: currentSellerId),
          ),
        );
        break;
      case SellerNotificationActionType.none:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OrdersListPage(),
          ),
        );
        break;
    }
  }

  Map<SellerNotificationFilter, int> _calculateFilterCounts(
      List<SellerNotificationModel> items) {
    final counts = <SellerNotificationFilter, int>{
      SellerNotificationFilter.all: items.length,
      SellerNotificationFilter.orders: 0,
      SellerNotificationFilter.payments: 0,
      SellerNotificationFilter.deliveries: 0,
      SellerNotificationFilter.messages: 0,
      SellerNotificationFilter.reviews: 0,
      SellerNotificationFilter.inventory: 0,
      SellerNotificationFilter.payouts: 0,
      SellerNotificationFilter.promos: 0,
    };

    for (final item in items) {
      switch (item.category) {
        case SellerNotificationCategory.newOrder:
        case SellerNotificationCategory.orderAccepted:
        case SellerNotificationCategory.orderCancelled:
          counts[SellerNotificationFilter.orders] =
              (counts[SellerNotificationFilter.orders] ?? 0) + 1;
          break;
        case SellerNotificationCategory.paymentUpdate:
          counts[SellerNotificationFilter.payments] =
              (counts[SellerNotificationFilter.payments] ?? 0) + 1;
          break;
        case SellerNotificationCategory.deliveryPartnerAssigned:
        case SellerNotificationCategory.pickupNotification:
          counts[SellerNotificationFilter.deliveries] =
              (counts[SellerNotificationFilter.deliveries] ?? 0) + 1;
          break;
        case SellerNotificationCategory.customerMessage:
          counts[SellerNotificationFilter.messages] =
              (counts[SellerNotificationFilter.messages] ?? 0) + 1;
          break;
        case SellerNotificationCategory.newReview:
          counts[SellerNotificationFilter.reviews] =
              (counts[SellerNotificationFilter.reviews] ?? 0) + 1;
          break;
        case SellerNotificationCategory.lowStock:
        case SellerNotificationCategory.outOfStock:
          counts[SellerNotificationFilter.inventory] =
              (counts[SellerNotificationFilter.inventory] ?? 0) + 1;
          break;
        case SellerNotificationCategory.payoutCompleted:
          counts[SellerNotificationFilter.payouts] =
              (counts[SellerNotificationFilter.payouts] ?? 0) + 1;
          break;
        case SellerNotificationCategory.promotional:
          counts[SellerNotificationFilter.promos] =
              (counts[SellerNotificationFilter.promos] ?? 0) + 1;
          break;
        case SellerNotificationCategory.system:
        case SellerNotificationCategory.unknown:
          break;
      }
    }

    return counts;
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.isTamil
              ? SellerNotificationStrings.clearConfirmTitleTa
              : SellerNotificationStrings.clearConfirmTitleEn,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          widget.isTamil
              ? SellerNotificationStrings.clearConfirmBodyTa
              : SellerNotificationStrings.clearConfirmBodyEn,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              widget.isTamil
                  ? SellerNotificationStrings.cancelTa
                  : SellerNotificationStrings.cancelEn,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<SellerNotificationBloc>()
                  .add(const ClearAllSellerNotifications());
            },
            child: Text(widget.isTamil
                ? SellerNotificationStrings.deleteTa
                : SellerNotificationStrings.deleteEn),
          ),
        ],
      ),
    );
  }
}
