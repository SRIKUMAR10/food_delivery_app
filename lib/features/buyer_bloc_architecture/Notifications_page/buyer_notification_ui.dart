import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/buyer_notification_model.dart';
import '../../../core/repositories/i_buyer_notification_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../repositories/firebase_buyer_notification_repository.dart';

import '../Cart Page/cart_page_UI.dart';
import '../Chat_Page/buyer_chat_ui.dart';
import '../Order Page/order_UI.dart';
import '../Rating_page/Rating_page_ui.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';
import '../WalletScreen/WalletScreen_UI.dart';

import 'buyer_notification_bloc.dart';
import 'buyer_notification_event.dart';
import 'buyer_notification_service.dart';
import 'buyer_notification_state.dart';
import 'buyer_notification_strings.dart';
import 'widgets/notification_category_chips.dart';
import 'widgets/notification_empty_view.dart';
import 'widgets/notification_in_app_toast.dart';
import 'widgets/notification_shimmer.dart';
import 'widgets/notification_tile_card.dart';

/// Buyer Notification Center entry point. Creates its own
/// [BuyerNotificationBloc] and starts listening to the buyer's real-time feed.
class BuyerNotificationPageUI extends StatelessWidget {
  final IBuyerNotificationRepository? repository;
  final BuyerNotificationService? service;
  final IAuthService? authService;
  final String? userId;

  const BuyerNotificationPageUI({
    super.key,
    this.repository,
    this.service,
    this.authService,
    this.userId,
  });

  IAuthService _resolveAuth(BuildContext context) {
    try {
      return context.read<IAuthService>();
    } catch (_) {
      return FirebaseAuthService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? FirebaseBuyerNotificationRepository();
    final svc = service ?? BuyerNotificationService();

    String? uid = userId;
    if (uid == null) {
      final auth = authService ?? _resolveAuth(context);
      uid = auth.currentUserId;
    }

    return BlocProvider(
      create: (_) => BuyerNotificationBloc(repository: repo, service: svc),
      child: _NotificationCenterView(userId: uid),
    );
  }
}

class _NotificationCenterView extends StatefulWidget {
  final String? userId;

  const _NotificationCenterView({this.userId});

  @override
  State<_NotificationCenterView> createState() =>
      _NotificationCenterViewState();
}

class _NotificationCenterViewState extends State<_NotificationCenterView> {
  String _languageCode = 'en';
  final TextEditingController _searchController = TextEditingController();
  Timer? _toastTimer;
  BuyerNotificationModel? _toastNotification;
  bool _localeInitialized = false;

  BuyerNotificationStrings get _strings =>
      BuyerNotificationStrings(languageCode: _languageCode);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = widget.userId;
      if (uid != null && uid.isNotEmpty) {
        context
            .read<BuyerNotificationBloc>()
            .add(StartListeningNotifications(uid));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_localeInitialized) {
      _localeInitialized = true;
      final locale = Localizations.maybeLocaleOf(context)?.languageCode;
      if (locale == 'ta') {
        _languageCode = 'ta';
      }
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showToast(BuyerNotificationModel notification) {
    _toastTimer?.cancel();
    setState(() => _toastNotification = notification);
    _toastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastNotification = null);
    });
  }

  void _dismissToast() {
    _toastTimer?.cancel();
    if (mounted) setState(() => _toastNotification = null);
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    return BlocListener<BuyerNotificationBloc, BuyerNotificationState>(
      listenWhen: (previous, current) =>
          current is BuyerNotificationLoaded &&
          current.latestInAppNotification != null,
      listener: (context, state) {
        final loaded = state as BuyerNotificationLoaded;
        final latest = loaded.latestInAppNotification;
        if (latest != null && latest != _toastNotification) {
          _showToast(latest);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final body = Stack(
            children: [
              Column(
                children: [
                  _Header(
                    strings: strings,
                    languageCode: _languageCode,
                    onToggleLanguage: () {
                      setState(() {
                        _languageCode = _languageCode == 'ta' ? 'en' : 'ta';
                      });
                    },
                    onMarkAllRead: () => _markAllRead(context),
                    onClearAll: () => _clearAll(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _SearchField(
                      controller: _searchController,
                      strings: strings,
                      onChanged: (value) {
                        context
                            .read<BuyerNotificationBloc>()
                            .add(NotificationSearchChanged(value));
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<BuyerNotificationBloc,
                        BuyerNotificationState>(
                      builder: (context, state) {
                        return _buildBody(context, state, strings);
                      },
                    ),
                  ),
                ],
              ),
              if (_toastNotification != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: NotificationInAppToast(
                    notification: _toastNotification!,
                    strings: strings,
                    onTap: () => _handleAction(context, _toastNotification!),
                    onDismiss: _dismissToast,
                  ),
                ),
            ],
          );

          if (isWide) {
            return Scaffold(
              backgroundColor: const Color(0xFFF3F4F6),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: const Color(0xFFFBF5F5),
                      child: body,
                    ),
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFBF5F5),
            body: body,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BuyerNotificationState state,
    BuyerNotificationStrings strings,
  ) {
    if (state is BuyerNotificationLoading) {
      return const NotificationShimmer();
    }
    if (state is BuyerNotificationError) {
      return NotificationEmptyView(
        strings: strings,
        isError: true,
        onRetry: () {
          final uid = widget.userId;
          if (uid != null && uid.isNotEmpty) {
            context
                .read<BuyerNotificationBloc>()
                .add(StartListeningNotifications(uid));
          }
        },
      );
    }
    if (state is BuyerNotificationLoaded) {
      if (state.notifications.isEmpty) {
        return NotificationEmptyView(strings: strings);
      }
      return _NotificationList(
        state: state,
        strings: strings,
        onSelectFilter: (filter) {
          context
              .read<BuyerNotificationBloc>()
              .add(CategoryFilterSelected(filter));
        },
        onTap: (notification) {
          if (notification.isUnread) {
            context
                .read<BuyerNotificationBloc>()
                .add(MarkNotificationAsRead(notification.id));
          }
          _handleAction(context, notification);
        },
        onActionTap: (notification) => _handleAction(context, notification),
        onDismissed: (notification) => _delete(context, notification),
      );
    }
    return const SizedBox.shrink();
  }

  void _markAllRead(BuildContext context) {
    context.read<BuyerNotificationBloc>().add(const MarkAllNotificationsAsRead());
    _snack(context, _strings.markedAllRead);
  }

  void _clearAll(BuildContext context) {
    context.read<BuyerNotificationBloc>().add(const ClearAllNotifications());
    _snack(context, _strings.allCleared);
  }

  void _delete(BuildContext context, BuyerNotificationModel notification) {
    context
        .read<BuyerNotificationBloc>()
        .add(DeleteNotification(notification.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_strings.notificationDeleted),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: _strings.undo,
            onPressed: () {
              context
                  .read<BuyerNotificationBloc>()
                  .add(RestoreNotification(notification));
            },
          ),
        ),
      );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _handleAction(
      BuildContext context, BuyerNotificationModel notification) async {
    final payload = notification.actionPayload;
    final action = notification.effectiveActionType;
    final orderId = payload['orderId'] as String? ?? notification.orderId;

    try {
      switch (action) {
        case BuyerNotificationActionType.navigateTrackOrder:
          if (orderId != null && orderId.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackOrderPageUI(orderId: orderId),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderPageUI(),
              ),
            );
          }
          break;

        case BuyerNotificationActionType.navigateOrder:
          if (orderId != null && orderId.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackOrderPageUI(orderId: orderId),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderPageUI(),
              ),
            );
          }
          break;

        case BuyerNotificationActionType.navigateChat:
          final sellerName = payload['sellerName'] as String? ??
              payload['senderName'] as String? ??
              (notification.title.toLowerCase() == 'store' ? 'Store' : notification.title);
          final shopName = payload['shopName'] as String? ?? payload['storeName'] as String?;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BuyerChatPage(
                orderId: orderId,
                sellerId: payload['sellerId'] as String? ?? notification.conversationId,
                sellerName: sellerName,
                shopName: shopName,
                buyerName: payload['buyerName'] as String?,
              ),
            ),
          );
          break;

        case BuyerNotificationActionType.navigateWallet:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletScreen_UI()),
          );
          break;

        case BuyerNotificationActionType.navigateCart:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPageUI()),
          );
          break;

        case BuyerNotificationActionType.applyCoupon:
          final code = notification.couponCode ?? payload['couponCode'] as String?;
          if (code != null && code.isNotEmpty) {
            await Clipboard.setData(ClipboardData(text: code));
            _snack(context, '$code — ${_strings.actionApplyCoupon}');
          }
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPageUI()),
          );
          break;

        case BuyerNotificationActionType.openRating:
          final productId =
              payload['productId'] as String? ?? notification.productId;
          final productName = payload['productName'] as String? ?? payload['foodName'] as String? ?? '';
          if (productId != null && productId.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RatingPageUI(
                  foodId: productId,
                  foodName: productName,
                ),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderPageUI(),
              ),
            );
          }
          break;

        case BuyerNotificationActionType.navigateDetails:
        case BuyerNotificationActionType.none:
          // Fallback navigation based on payload/category keywords
          final text = '${notification.title} ${notification.body}'.toLowerCase();
          if (text.contains('chat') || text.contains('store') || text.contains('message') || text.contains('seller')) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerChatPage(
                  orderId: orderId,
                  sellerName: notification.title,
                ),
              ),
            );
          } else if (text.contains('wallet') || text.contains('pay') || text.contains('refund') || text.contains('cashback')) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen_UI()),
            );
          } else if (text.contains('cart') || text.contains('coupon') || text.contains('offer')) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPageUI()),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderPageUI()),
            );
          }
          break;
      }
    } catch (_) {
      _snack(context, _strings.actionViewDetails);
    }
  }
}

class _Header extends StatelessWidget {
  final BuyerNotificationStrings strings;
  final String languageCode;
  final VoidCallback onToggleLanguage;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const _Header({
    required this.strings,
    required this.languageCode,
    required this.onToggleLanguage,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              strings.pageTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ),
          _RoundAction(
            icon: languageCode == 'ta'
                ? Icons.translate_rounded
                : Icons.language_rounded,
            tooltip: languageCode == 'ta' ? 'English' : 'தமிழ்',
            onTap: onToggleLanguage,
            label: languageCode == 'ta' ? 'EN' : 'த',
          ),
          const SizedBox(width: 8),
          _RoundAction(
            icon: Icons.done_all_rounded,
            tooltip: strings.markAllRead,
            onTap: onMarkAllRead,
          ),
          const SizedBox(width: 8),
          _RoundAction(
            icon: Icons.delete_sweep_rounded,
            tooltip: strings.clearAll,
            onTap: onClearAll,
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String? label;

  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BuyerAppColors.primaryDeep,
                  ),
                )
              : Icon(icon, size: 20, color: const Color(0xFF1C1C1C)),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final BuyerNotificationStrings strings;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.strings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: strings.searchHint,
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final BuyerNotificationLoaded state;
  final BuyerNotificationStrings strings;
  final ValueChanged<NotificationFilter> onSelectFilter;
  final ValueChanged<BuyerNotificationModel> onTap;
  final ValueChanged<BuyerNotificationModel> onActionTap;
  final ValueChanged<BuyerNotificationModel> onDismissed;

  const _NotificationList({
    required this.state,
    required this.strings,
    required this.onSelectFilter,
    required this.onTap,
    required this.onActionTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <NotificationFilter, int>{};
    for (final filter in NotificationFilter.values) {
      counts[filter] = state.notifications
          .where((n) => n.isUnread && _matchesFilter(n, filter))
          .length;
    }

    final filtered = state.filteredNotifications;
    if (filtered.isEmpty) {
      return NotificationEmptyView(strings: strings);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: NotificationCategoryChips(
              activeFilter: state.activeFilter,
              unreadCounts: counts,
              strings: strings,
              onSelected: onSelectFilter,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = filtered[index];
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  HapticFeedback.mediumImpact();
                  onDismissed(notification);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: BuyerAppColors.primaryDeep,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                child: NotificationTileCard(
                  notification: notification,
                  strings: strings,
                  onTap: () => onTap(notification),
                  onActionTap: () => onActionTap(notification),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _matchesFilter(
    BuyerNotificationModel n,
    NotificationFilter filter,
  ) {
    switch (filter) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.orders:
        return n.category == BuyerNotificationCategory.orderUpdate ||
            n.category == BuyerNotificationCategory.driverTracking;
      case NotificationFilter.payments:
        return n.category == BuyerNotificationCategory.paymentStatus;
      case NotificationFilter.offers:
        return n.category == BuyerNotificationCategory.offerPromo;
      case NotificationFilter.chats:
        return n.category == BuyerNotificationCategory.chatMessage;
      case NotificationFilter.alerts:
        return n.category == BuyerNotificationCategory.securityAlert ||
            n.category == BuyerNotificationCategory.system ||
            n.category == BuyerNotificationCategory.reviewReminder ||
            n.category == BuyerNotificationCategory.unknown;
    }
  }
}
