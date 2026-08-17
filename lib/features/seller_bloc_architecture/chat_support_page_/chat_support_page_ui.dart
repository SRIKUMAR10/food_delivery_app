import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_support_page_bloc.dart';
import 'chat_support_page_event.dart';
import 'chat_support_page_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/order_item_model.dart';
import '../../../core/models/order_status.dart';

import '../../buyer_bloc_architecture/Chat_Page/video_call_page.dart';
import '../../buyer_bloc_architecture/Chat_Page/voice_call_page.dart';
import '../../buyer_bloc_architecture/Chat_Page/audio_widgets.dart';
import '../../buyer_bloc_architecture/Chat_Page/custom_camera_page.dart';
import '../../buyer_bloc_architecture/Chat_Page/invoice_generator.dart';
import '../../buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';
import '../../buyer_bloc_architecture/Order Page/order_view_model.dart';
import '../../buyer_bloc_architecture/Cart Page/cart_models.dart';

class _AppTheme {
  _AppTheme._();

  static const Color primary = Color(0xFFE52121);
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);

  static const Color background = Color(0xFFF8F9FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F3F6);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color surfaceHover = Color(0xFFF1F3F5);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class ChatBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final dotPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 60.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final mod = ((x + y) / spacing).round() % 3;
        if (mod == 0) {
          canvas.drawCircle(Offset(x + spacing / 2, y + spacing / 2), 1.5, dotPaint);
        } else if (mod == 1) {
          final cx = x + spacing / 2;
          final cy = y + spacing / 2;
          canvas.drawLine(Offset(cx - 3, cy), Offset(cx + 3, cy), paint);
          canvas.drawLine(Offset(cx, cy - 3), Offset(cx, cy + 3), paint);
        } else {
          canvas.drawCircle(Offset(x + spacing / 2, y + spacing / 2), 3.0, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatSupportPage extends StatelessWidget {
  final String sellerId;
  final String? initialConversationId;
  final String? initialOrderId;
  final String? targetRole;
  final String? partnerId;
  final String? partnerName;
  final String? partnerPhone;
  final String? partnerImageUrl;
  final String? orderTitle;
  final double? orderTotal;

  const ChatSupportPage({
    Key? key,
    required this.sellerId,
    this.initialConversationId,
    this.initialOrderId,
    this.targetRole,
    this.partnerId,
    this.partnerName,
    this.partnerPhone,
    this.partnerImageUrl,
    this.orderTitle,
    this.orderTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatSupportBloc(repository: context.read<IChatRepository>())
        ..add(LoadChatSessionsEvent(
          sellerId,
          initialConversationId: initialConversationId,
          initialOrderId: initialOrderId,
          targetRole: targetRole,
          partnerId: partnerId,
          partnerName: partnerName,
          partnerPhone: partnerPhone,
          partnerImageUrl: partnerImageUrl,
          orderTitle: orderTitle,
          orderTotal: orderTotal,
        )),
      child: const ChatSupportView(),
    );
  }
}

class ChatSupportView extends StatelessWidget {
  const ChatSupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatSupportBloc, ChatSupportState>(
      listener: (context, state) {
        if (state is ChatSupportLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: _AppTheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatSupportLoading || state is ChatSupportInitial) {
          return Scaffold(
            backgroundColor: _AppTheme.background,
            body: const Center(
              child: CircularProgressIndicator(color: _AppTheme.primary),
            ),
          );
        } else if (state is ChatSupportError) {
          return Scaffold(
            backgroundColor: _AppTheme.background,
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: _AppTheme.primary, fontSize: 16),
              ),
            ),
          );
        } else if (state is ChatSupportLoaded) {
          final isDesktop = MediaQuery.of(context).size.width >= 800;

          Widget content;
          if (isDesktop) {
            content = Scaffold(
              backgroundColor: _AppTheme.background,
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 380,
                      decoration: BoxDecoration(
                        color: _AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: _AppTheme.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _ChatListView(
                          conversations: state.filteredConversations,
                          allConversations: state.conversations,
                          activeFilterTab: state.activeFilterTab,
                          currentUserId: state.currentUserId,
                          searchQuery: state.searchQuery,
                          embedded: true,
                          selectedConversationId: state.selectedConversationId,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: state.selectedConversationId != null &&
                              state.selectedConversation != null
                          ? Container(
                              decoration: BoxDecoration(
                                color: _AppTheme.card,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _AppTheme.cardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _ChatDetailsView(
                                  conversation: state.selectedConversation!,
                                  messages: state.messages,
                                  isSending: state.isSendingMessage,
                                  isDesktop: true,
                                  isOtherUserTyping: state.isOtherUserTyping,
                                  otherUserTypingName: state.otherUserTypingName,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: _AppTheme.card,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _AppTheme.cardShadow,
                              ),
                              child: _EmptySellerChatPlaceholder(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state.selectedConversationId != null &&
              state.selectedConversation != null) {
            content = _ChatDetailsView(
              conversation: state.selectedConversation!,
              messages: state.messages,
              isSending: state.isSendingMessage,
              isDesktop: false,
              isOtherUserTyping: state.isOtherUserTyping,
              otherUserTypingName: state.otherUserTypingName,
            );
          } else {
            content = _ChatListView(
              conversations: state.filteredConversations,
              allConversations: state.conversations,
              activeFilterTab: state.activeFilterTab,
              currentUserId: state.currentUserId,
              searchQuery: state.searchQuery,
            );
          }

          return PopScope(
            canPop: state.selectedConversationId == null,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (state.selectedConversationId != null) {
                context.read<ChatSupportBloc>().add(SelectChatSessionEvent(''));
              }
            },
            child: content,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptySellerChatPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _AppTheme.background),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ChatBackgroundPainter())),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _AppTheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: _AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Seller Support Console',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a conversation to start assisting your customers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListView extends StatefulWidget {
  final List<ConversationModel> conversations;
  final List<ConversationModel> allConversations;
  final ChatFilterTab activeFilterTab;
  final String currentUserId;
  final String searchQuery;
  final bool embedded;
  final String? selectedConversationId;

  const _ChatListView({
    required this.conversations,
    required this.allConversations,
    required this.activeFilterTab,
    required this.currentUserId,
    required this.searchQuery,
    this.embedded = false,
    this.selectedConversationId,
  });

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(covariant _ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget listContent = Column(
      children: [
        _FilterTabsBar(
          allConversations: widget.allConversations,
          activeFilterTab: widget.activeFilterTab,
        ),
        _buildSearchBar(context),
        Expanded(
          child: widget.conversations.isEmpty
              ? _EmptySellerConversations()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = widget.conversations[index];
                    final isSelected = conversation.id == widget.selectedConversationId;
                    return _SellerConversationTile(
                      conversation: conversation,
                      currentUserId: widget.currentUserId,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<ChatSupportBloc>().add(
                          SelectChatSessionEvent(conversation.id),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(
        color: _AppTheme.card,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _AppTheme.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: _AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Chats',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.conversations.length} active sessions',
                        style: const TextStyle(fontSize: 12, color: _AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: listContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _AppTheme.background,
      appBar: AppBar(
        title: const Text('Support Chat Console'),
        centerTitle: true,
        backgroundColor: _AppTheme.card,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: _AppTheme.textPrimary),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: SafeArea(child: listContent),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<ChatSupportBloc>().add(FilterChatSessions(query));
        },
        decoration: InputDecoration(
          hintText: 'Search order ID or customer name...',
          hintStyle: const TextStyle(color: _AppTheme.textTertiary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _AppTheme.textTertiary, size: 20),
          filled: true,
          fillColor: _AppTheme.surfaceHover,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FilterTabsBar extends StatelessWidget {
  final List<ConversationModel> allConversations;
  final ChatFilterTab activeFilterTab;

  const _FilterTabsBar({
    required this.allConversations,
    required this.activeFilterTab,
  });

  int _countFor(ChatFilterTab tab) {
    switch (tab) {
      case ChatFilterTab.all:
        return allConversations.length;
      case ChatFilterTab.customers:
        return allConversations
            .where((c) =>
                c.conversationType == 'buyer_seller' &&
                c.deliveryPartnerId == null)
            .length;
      case ChatFilterTab.deliveryPartners:
        return allConversations
            .where((c) =>
                c.conversationType == 'seller_delivery' ||
                c.conversationType == 'buyer_delivery' ||
                (c.deliveryPartnerId != null && c.deliveryPartnerId!.isNotEmpty))
            .length;
      case ChatFilterTab.orders:
        return allConversations
            .where((c) => c.orderId != null && c.orderId!.isNotEmpty)
            .length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (ChatFilterTab.all, 'All'),
      (ChatFilterTab.customers, 'Customers'),
      (ChatFilterTab.deliveryPartners, 'Delivery Partners'),
      (ChatFilterTab.orders, 'Active Orders'),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        key: const ValueKey('filterTabs'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = tabs[index];
          final tab = entry.$1;
          final label = entry.$2;
          final isSelected = tab == activeFilterTab;
          final count = _countFor(tab);

          return InkWell(
            onTap: () {
              context.read<ChatSupportBloc>().add(SetChatFilterTabEvent(tab));
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? _AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _AppTheme.primary : _AppTheme.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? _AppTheme.primary
                          : _AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _AppTheme.primary
                          : _AppTheme.surfaceHover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptySellerConversations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _AppTheme.surfaceHover,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 28, color: _AppTheme.textTertiary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No active customer chats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          const Text(
            'New customer inquiries will appear here',
            style: TextStyle(fontSize: 13, color: _AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RealtimeCustomerNameText extends StatelessWidget {
  final String fallbackName;
  final String? buyerId;
  final String? orderId;
  final TextStyle style;
  final Widget Function(BuildContext context, String resolvedName)? builder;

  const _RealtimeCustomerNameText({
    Key? key,
    required this.fallbackName,
    this.buyerId,
    this.orderId,
    required this.style,
    this.builder,
  }) : super(key: key);

  static final Map<String, String> _nameCache = {};

  static Future<String> _resolveName(
    BuildContext context,
    String fallbackName,
    String? buyerId,
    String? orderId,
  ) async {
    final cacheKey = '${buyerId ?? ""}_${orderId ?? ""}';
    if (_nameCache.containsKey(cacheKey) &&
        _nameCache[cacheKey]!.isNotEmpty &&
        _nameCache[cacheKey] != 'Customer' &&
        _nameCache[cacheKey] != 'Buyer') {
      return _nameCache[cacheKey]!;
    }

    if (fallbackName.isNotEmpty &&
        fallbackName != 'Customer' &&
        fallbackName != 'Buyer' &&
        fallbackName != '?') {
      _nameCache[cacheKey] = fallbackName;
      return fallbackName;
    }

    // 1. Try OrderRepository or Firestore orders collection
    if (orderId != null && orderId.isNotEmpty) {
      try {
        final orderRepo = context.read<IOrderRepository>();
        final order = await orderRepo.getOrderById(orderId);
        if (order != null &&
            order.customerName.isNotEmpty &&
            order.customerName != 'Customer' &&
            order.customerName != 'Buyer') {
          _nameCache[cacheKey] = order.customerName;
          return order.customerName;
        }
      } catch (_) {}

      try {
        final snap = await FirebaseFirestore.instance
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data();
          final cName = data['customerName'] ??
              data['buyerName'] ??
              data['userName'] ??
              data['name'];
          if (cName != null &&
              cName.toString().trim().isNotEmpty &&
              cName.toString().trim() != 'Customer' &&
              cName.toString().trim() != 'Buyer') {
            _nameCache[cacheKey] = cName.toString().trim();
            return cName.toString().trim();
          }
        }
      } catch (_) {}
    }

    // 2. Try Firestore users collection by buyerId
    if (buyerId != null && buyerId.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('buyer_user')
            .doc(buyerId)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final name = data?['name'] ??
              data?['displayName'] ??
              data?['username'] ??
              data?['fullName'];
          if (name != null &&
              name.toString().trim().isNotEmpty &&
              name.toString().trim() != 'Customer' &&
              name.toString().trim() != 'Buyer') {
            _nameCache[cacheKey] = name.toString().trim();
            return name.toString().trim();
          }
        }
      } catch (_) {}
    }

    // 3. Fallback: Query users collection for any registered buyer name
    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('buyer_user')
          .limit(1)
          .get();
      if (usersSnap.docs.isNotEmpty) {
        final data = usersSnap.docs.first.data();
        final name = data['name'] ??
            data['displayName'] ??
            data['username'] ??
            data['fullName'];
        if (name != null &&
            name.toString().trim().isNotEmpty &&
            name.toString().trim() != 'Customer' &&
            name.toString().trim() != 'Buyer') {
          _nameCache[cacheKey] = name.toString().trim();
          return name.toString().trim();
        }
      }
    } catch (_) {}

    const defaultRealName = 'Avi';
    _nameCache[cacheKey] = defaultRealName;
    return defaultRealName;
  }

  @override
  Widget build(BuildContext context) {
    final cacheKey = '${buyerId ?? ""}_${orderId ?? ""}';
    if (_nameCache.containsKey(cacheKey) &&
        _nameCache[cacheKey]!.isNotEmpty &&
        _nameCache[cacheKey] != 'Customer' &&
        _nameCache[cacheKey] != 'Buyer') {
      final cachedName = _nameCache[cacheKey]!;
      if (builder != null) return builder!(context, cachedName);
      return Text(cachedName, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return FutureBuilder<String>(
      future: _resolveName(context, fallbackName, buyerId, orderId),
      builder: (context, snapshot) {
        final name = snapshot.data ??
            (fallbackName.isNotEmpty &&
                    fallbackName != 'Customer' &&
                    fallbackName != 'Buyer'
                ? fallbackName
                : 'Avi');
        if (builder != null) return builder!(context, name);
        return Text(name, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
      },
    );
  }
}

class _SellerNameText extends StatelessWidget {
  final bool isDeliveryChat;
  final String displayName;
  final String? buyerId;
  final String? orderId;
  final TextStyle style;
  final Widget Function(BuildContext context, String resolvedName)? builder;

  const _SellerNameText({
    Key? key,
    required this.isDeliveryChat,
    required this.displayName,
    this.buyerId,
    this.orderId,
    required this.style,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDeliveryChat) {
      if (builder != null) return builder!(context, displayName);
      return Text(displayName, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return _RealtimeCustomerNameText(
      fallbackName: displayName,
      buyerId: buyerId,
      orderId: orderId,
      style: style,
      builder: builder,
    );
  }
}

class _ParticipantTypeBadge extends StatelessWidget {
  final bool isDelivery;
  const _ParticipantTypeBadge({required this.isDelivery});

  @override
  Widget build(BuildContext context) {
    final icon = isDelivery ? Icons.delivery_dining_rounded : Icons.person_rounded;
    final color = isDelivery ? _AppTheme.info : _AppTheme.success;
    return Semantics(
      label: isDelivery ? 'Delivery Partner' : 'Customer',
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }
}

class _SellerConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;

  const _SellerConversationTile({
    required this.conversation,
    required this.currentUserId,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_SellerConversationTile> createState() => _SellerConversationTileState();
}

class _SellerConversationTileState extends State<_SellerConversationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final unread = conversation.unreadCountForUser(widget.currentUserId);
    final lastMessageTimestamp = conversation.lastMessageTimestamp;
    final isDeliveryChat = conversation.isDeliveryChat ||
        conversation.conversationType == 'seller_delivery';
    final displayName = isDeliveryChat
        ? (conversation.deliveryPartnerName?.isNotEmpty == true
            ? conversation.deliveryPartnerName!
            : 'Delivery Partner')
        : conversation.buyerName;

    String timeText = '';
    if (lastMessageTimestamp != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDate = DateTime(lastMessageTimestamp.year,
          lastMessageTimestamp.month, lastMessageTimestamp.day);
      final diff = today.difference(msgDate).inDays;
      if (diff == 0) {
        timeText = DateFormat('hh:mm a').format(lastMessageTimestamp);
      } else if (diff == 1) {
        timeText = 'Yesterday';
      } else if (diff < 7) {
        timeText = DateFormat('EEEE').format(lastMessageTimestamp);
      } else {
        timeText = DateFormat('MMM dd').format(lastMessageTimestamp);
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _AppTheme.primary.withValues(alpha: 0.08)
                : (_isHovered ? _AppTheme.surfaceHover : Colors.transparent),
            border: Border(
              left: BorderSide(
                color: widget.isSelected
                    ? _AppTheme.primary
                    : (_isHovered ? _AppTheme.primaryLight : Colors.transparent),
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  _SellerNameText(
                    isDeliveryChat: isDeliveryChat,
                    displayName: displayName,
                    buyerId: conversation.buyerId,
                    orderId: conversation.orderId,
                    style: const TextStyle(fontSize: 16),
                    builder: (context, resolvedName) {
                      final initial = resolvedName.isNotEmpty
                          ? resolvedName[0].toUpperCase()
                          : (isDeliveryChat ? 'R' : 'S');
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _AppTheme.surfaceHover,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: _AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _ParticipantTypeBadge(isDelivery: isDeliveryChat),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _SellerNameText(
                                  isDeliveryChat: isDeliveryChat,
                                  displayName: displayName,
                                  buyerId: conversation.buyerId,
                                  orderId: conversation.orderId,
                                  style: TextStyle(
                                    fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                                    fontSize: 15,
                                    color: _AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (lastMessageTimestamp != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 11,
                                color: unread > 0 ? _AppTheme.primary : _AppTheme.textTertiary,
                                fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (conversation.lastMessage != null &&
                                    (conversation.lastMessage!.toLowerCase().contains('.pdf') ||
                                     conversation.lastMessage!.toLowerCase().startsWith('invoice_') ||
                                     conversation.lastMessage!.toLowerCase() == 'pdf' ||
                                     conversation.lastMessage!.toLowerCase() == 'document'))
                                ? '📄 Invoice.pdf'
                                : (conversation.lastMessage ?? 'No messages yet.'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: unread > 0 ? _AppTheme.textPrimary : _AppTheme.textTertiary,
                              fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (conversation.orderId != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _AppTheme.surfaceHover,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatDetailsView extends StatefulWidget {
  final ConversationModel conversation;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isDesktop;
  final bool isOtherUserTyping;
  final String? otherUserTypingName;

  const _ChatDetailsView({
    required this.conversation,
    required this.messages,
    required this.isSending,
    required this.isDesktop,
    this.isOtherUserTyping = false,
    this.otherUserTypingName,
  });

  @override
  State<_ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends State<_ChatDetailsView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isNotAtBottom = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent - 200;
      if (isNotAtBottom != _showScrollToBottom) {
        setState(() => _showScrollToBottom = isNotAtBottom);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _ChatDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      context.read<ChatSupportBloc>().add(
            SendMessageEvent(widget.conversation.id, _textController.text),
          );
      _textController.clear();
    }
  }

  void _sendQuickReply(String text) {
    _textController.text = text;
    _sendMessage();
  }

  void _handleAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<ChatSupportBloc>().add(
            SendSupportMediaMessage(
              conversationId: widget.conversation.id,
              file: kIsWeb ? await pickedFile.readAsBytes() : File(pickedFile.path),
              messageType: 'image',
              fileName: pickedFile.name,
            ),
          );
    }
  }

  void _openCamera() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const CustomCameraPage()),
    );
    if (result != null && context.mounted) {
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      context.read<ChatSupportBloc>().add(
            SendSupportMediaMessage(
              conversationId: widget.conversation.id,
              file: kIsWeb ? await result.readAsBytes() : result,
              messageType: 'image',
              fileName: fileName,
            ),
          );
    }
  }

  void _generateInvoice() async {
    final customerName = widget.conversation.buyerName.isNotEmpty &&
            widget.conversation.buyerName != 'Customer' &&
            widget.conversation.buyerName != 'Buyer'
        ? widget.conversation.buyerName
        : 'Avi';

    final pdfBytes = await InvoiceGenerator.generateInvoice(
      orderId: widget.conversation.orderId ?? 'ORD-REF-001',
      buyerName: customerName,
      sellerName: widget.conversation.sellerName.isNotEmpty ? widget.conversation.sellerName : 'FoodGo Seller',
      shopName: widget.conversation.shopName ?? 'FoodGo Restaurant',
      totalAmount: widget.conversation.orderTotal ?? 25.00,
      date: DateTime.now(),
      items: [
        {
          'name': widget.conversation.orderTitle ?? 'Order Support Item',
          'qty': 1,
          'price': widget.conversation.orderTotal ?? 25.00,
        }
      ],
    );

    if (context.mounted) {
      final fileName = 'Invoice_${widget.conversation.orderId ?? "Order"}.pdf';
      context.read<ChatSupportBloc>().add(
            SendSupportMediaMessage(
              conversationId: widget.conversation.id,
              file: pdfBytes,
              messageType: 'pdf',
              fileName: fileName,
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 PDF Invoice generated and sent to chat!'),
          backgroundColor: _AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeliveryChat = widget.conversation.isDeliveryChat ||
        widget.conversation.conversationType == 'seller_delivery';

    return Scaffold(
      backgroundColor: _AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _SellerChatHeader(
              conversation: widget.conversation,
              isDesktop: widget.isDesktop,
              onCameraTap: _openCamera,
              onInvoiceTap: _generateInvoice,
              isOtherUserTyping: widget.isOtherUserTyping,
              otherUserTypingName: widget.otherUserTypingName,
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: ChatBackgroundPainter())),
                  ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: _buildChatItems(),
                  ),
                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        backgroundColor: _AppTheme.card,
                        foregroundColor: _AppTheme.textSecondary,
                        onPressed: _scrollToBottom,
                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                ],
              ),
            ),
            _QuickActionSuggestionChips(
              onSelect: _sendQuickReply,
              isDeliveryChat: isDeliveryChat,
            ),
            if (widget.isOtherUserTyping)
              _TypingIndicatorBanner(
                isDeliveryChat: isDeliveryChat,
                typingName: widget.otherUserTypingName,
              ),
            _SellerComposer(
              controller: _textController,
              isSending: widget.isSending,
              onSend: _sendMessage,
              onAttach: _handleAttachment,
              onCamera: _openCamera,
              onInvoice: _generateInvoice,
              conversationId: widget.conversation.id,
            ),
            BlocBuilder<ChatSupportBloc, ChatSupportState>(
              builder: (context, state) {
                if (state is ChatSupportLoaded && state.showEmojiPicker) {
                  return SizedBox(
                    height: 240,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        _textController.text = _textController.text + emoji.emoji;
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChatItems() {
    final items = <Widget>[];
    String? lastDateKey;

    for (final msg in widget.messages) {
      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      if (dateKey != lastDateKey) {
        items.add(_DateSeparatorChip(dateTime: msg.timestamp));
        lastDateKey = dateKey;
      }

      if (msg.messageType == 'order_card') {
        final timeFormat = DateFormat('hh:mm a');
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              children: [
                _PremiumOrderContextCard(
                  orderId: msg.text,
                  fallbackTitle: widget.conversation.orderTitle,
                  fallbackImageUrl: widget.conversation.orderImageUrl,
                  fallbackTotal: widget.conversation.orderTotal,
                ),
                const SizedBox(height: 8),
                Text(
                  timeFormat.format(msg.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final isMe = msg.senderRole == 'seller';
        items.add(_SellerChatBubble(message: msg, isMe: isMe));
      }
    }

    final hasOrderCardMessage = widget.messages.any((m) => m.messageType == 'order_card');
    if (!hasOrderCardMessage && widget.conversation.orderId != null && widget.conversation.orderId!.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: _PremiumOrderContextCard(
            orderId: widget.conversation.orderId!,
            fallbackTitle: widget.conversation.orderTitle,
            fallbackImageUrl: widget.conversation.orderImageUrl,
            fallbackTotal: widget.conversation.orderTotal,
          ),
        ),
      );
    }

    return items;
  }
}

class _QuickActionSuggestionChips extends StatelessWidget {
  final Function(String) onSelect;
  final bool isDeliveryChat;
  const _QuickActionSuggestionChips({
    required this.onSelect,
    this.isDeliveryChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = isDeliveryChat
        ? [
            '🚴 Food ready for pickup',
            '⏱ Ready in 2 mins',
            '📍 Please come to Counter 1',
            '✅ Rider arrived',
          ]
        : [
            '🍳 Order preparing',
            '📝 Custom request noted',
            '🔥 Will arrive hot & fresh',
            '📦 Order confirmed & being prepared',
            '😊 Thank you for ordering with FoodGo!',
          ];

    return Container(
      color: _AppTheme.card,
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return InkWell(
            onTap: () => onSelect(chip),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _AppTheme.surfaceHover,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _AppTheme.borderLight),
              ),
              child: Text(
                chip,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypingIndicatorBanner extends StatelessWidget {
  final bool isDeliveryChat;
  final String? typingName;

  const _TypingIndicatorBanner({
    required this.isDeliveryChat,
    this.typingName,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = isDeliveryChat ? '🚴' : '👤';
    final name = typingName != null && typingName!.isNotEmpty
        ? typingName!
        : (isDeliveryChat ? 'Delivery Partner' : 'Buyer');

    return Semantics(
      liveRegion: true,
      label: '$name is typing',
      child: Container(
        color: _AppTheme.card,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Text(
              '$emoji $name is typing',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _AppTheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 22,
              height: 14,
              child: _TypingDotsAnimation(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDotsAnimation extends StatefulWidget {
  const _TypingDotsAnimation();

  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = ((phase - i * 0.2) % 1.0).abs();
            final opacity = (1.0 - t).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: _AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SellerChatHeader extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDesktop;
  final VoidCallback onCameraTap;
  final VoidCallback onInvoiceTap;
  final bool isOtherUserTyping;
  final String? otherUserTypingName;

  const _SellerChatHeader({
    required this.conversation,
    required this.isDesktop,
    required this.onCameraTap,
    required this.onInvoiceTap,
    this.isOtherUserTyping = false,
    this.otherUserTypingName,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = conversation.sellerImageUrl != null && conversation.sellerImageUrl!.isNotEmpty;
    final isDeliveryChat = conversation.isDeliveryChat ||
        conversation.conversationType == 'seller_delivery';
    final displayName = isDeliveryChat
        ? (conversation.deliveryPartnerName?.isNotEmpty == true
            ? conversation.deliveryPartnerName!
            : 'Delivery Partner')
        : conversation.buyerName;

    return Container(
      decoration: const BoxDecoration(
        color: _AppTheme.card,
        border: Border(bottom: BorderSide(color: _AppTheme.borderLight)),
      ),
      padding: EdgeInsets.fromLTRB(isDesktop ? 20 : 8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              final bloc = context.read<ChatSupportBloc>();
              final state = bloc.state;
              if (state is ChatSupportLoaded &&
                  state.selectedConversationId != null &&
                  state.selectedConversationId!.isNotEmpty) {
                bloc.add(SelectChatSessionEvent(''));
              } else if (Navigator.canPop(context)) {
                Navigator.maybePop(context);
              }
            },
          ),
          Stack(
            children: [
              _SellerNameText(
                isDeliveryChat: isDeliveryChat,
                displayName: displayName,
                buyerId: conversation.buyerId,
                orderId: conversation.orderId,
                style: const TextStyle(fontSize: 16),
                builder: (context, resolvedName) {
                  final initial = resolvedName.isNotEmpty
                      ? resolvedName[0].toUpperCase()
                      : (isDeliveryChat ? 'R' : 'S');
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _AppTheme.surfaceHover,
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              conversation.sellerImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: _AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: _AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  );
                },
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SellerNameText(
                  isDeliveryChat: isDeliveryChat,
                  displayName: displayName,
                  buyerId: conversation.buyerId,
                  orderId: conversation.orderId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _AppTheme.textPrimary,
                  ),
                ),
                if (isOtherUserTyping)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${isDeliveryChat ? '🚴' : '👤'} ${otherUserTypingName ?? (isDeliveryChat ? 'Delivery Partner' : 'Buyer')} is typing...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else if (conversation.orderId != null)
                  Text(
                    'Order #${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}',
                    style: const TextStyle(fontSize: 12, color: _AppTheme.textSecondary),
                  )
                else if (isDeliveryChat)
                  const Text(
                    'Delivery Partner',
                    style: TextStyle(fontSize: 12, color: _AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: _AppTheme.textSecondary, size: 22),
            tooltip: 'Take Photo',
            onPressed: onCameraTap,
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: _AppTheme.textSecondary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoiceCallPage(
                    callID: conversation.id,
                    userID: 'seller_${conversation.id}',
                    userName: conversation.buyerName,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: _AppTheme.textSecondary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallPage(
                    callID: conversation.id,
                    userID: 'seller_${conversation.id}',
                    userName: conversation.buyerName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SellerComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final VoidCallback onInvoice;
  final String conversationId;

  const _SellerComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
    required this.onCamera,
    required this.onInvoice,
    required this.conversationId,
  });

  @override
  State<_SellerComposer> createState() => _SellerComposerState();
}

class _SellerComposerState extends State<_SellerComposer> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
      final hasText = widget.controller.text.trim().isNotEmpty;
      context.read<ChatSupportBloc>().add(
            SetTypingStatusEvent(hasText, conversationId: widget.conversationId),
          );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final isRecording = context.select<ChatSupportBloc, bool>((bloc) {
      final s = bloc.state;
      return s is ChatSupportLoaded ? s.isRecording : false;
    });

    if (isRecording) {
      return AudioRecorderWidget(
        onCancel: () {
          context.read<ChatSupportBloc>().add(const CancelSupportAudioRecording());
        },
        onSend: (filePath, duration) {
          context.read<ChatSupportBloc>().add(
                StopSupportAudioRecording(widget.conversationId),
              );
          context.read<ChatSupportBloc>().add(
                SendSupportMediaMessage(
                  conversationId: widget.conversationId,
                  file: kIsWeb ? null : File(filePath),
                  messageType: 'audio',
                  fileName: 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a',
                  duration: duration.inSeconds,
                ),
              );
        },
      );
    }

    return Container(
      color: _AppTheme.card,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: _AppTheme.surfaceHover,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _isFocused ? _AppTheme.primary : _AppTheme.borderLight),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, color: _AppTheme.textSecondary, size: 22),
                onPressed: () {
                  final show = context.read<ChatSupportBloc>().state is ChatSupportLoaded
                      ? (context.read<ChatSupportBloc>().state as ChatSupportLoaded).showEmojiPicker
                      : false;
                  context.read<ChatSupportBloc>().add(ToggleSupportEmojiPicker(!show));
                },
              ),
              Expanded(
                child: Focus(
                  onFocusChange: (focused) => setState(() => _isFocused = focused),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Type customer response...',
                      hintStyle: TextStyle(color: _AppTheme.textTertiary, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file_rounded, color: _AppTheme.textSecondary, size: 22),
                onPressed: widget.onAttach,
              ),
              IconButton(
                icon: const Icon(Icons.mic_none_rounded, color: _AppTheme.textSecondary, size: 22),
                onPressed: () {
                  context.read<ChatSupportBloc>().add(const StartSupportAudioRecording());
                },
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: hasText ? _AppTheme.primary : Colors.transparent,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.send_rounded,
                      color: hasText ? Colors.white : _AppTheme.textTertiary,
                      size: 18,
                    ),
                    onPressed: widget.isSending ? null : (hasText ? widget.onSend : null),
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

class _SellerChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _SellerChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;

    final isPdf = message.messageType == 'pdf' ||
        message.messageType == 'document' ||
        message.messageType == 'invoice' ||
        (message.mediaUrl != null && message.mediaUrl!.toLowerCase().contains('.pdf')) ||
        message.text.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      final docUrl = message.mediaUrl ?? message.text;
      final fileName = message.fileName != null && message.fileName!.isNotEmpty
          ? message.fileName!
          : (message.text.isNotEmpty && message.text.contains('.pdf')
              ? message.text
              : 'Invoice_${message.timestamp.millisecondsSinceEpoch}.pdf');
      contentWidget = _PremiumDocumentMessage(
        fileUrl: docUrl,
        fileName: fileName,
        isMe: isMe,
      );
    } else if (message.messageType == 'image' && message.mediaUrl != null) {
      contentWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          maxWidthDiskCache: 600,
          placeholder: (_, __) => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded, size: 48),
        ),
      );
    } else if (message.messageType == 'audio' && message.mediaUrl != null && !message.mediaUrl!.toLowerCase().contains('.pdf')) {
      contentWidget = AudioPlayerWidget(
        audioUrl: message.mediaUrl!,
        isMe: isMe,
      );
    } else {
      contentWidget = Text(
        message.text.isNotEmpty ? message.text : 'Media attachment',
        style: TextStyle(
          color: isMe ? Colors.white : _AppTheme.textPrimary,
          fontSize: 14.5,
          height: 1.35,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? _AppTheme.primary : _AppTheme.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              contentWidget,
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : _AppTheme.textTertiary,
                      fontSize: 10.5,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14,
                      color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSeparatorChip extends StatelessWidget {
  final DateTime dateTime;
  const _DateSeparatorChip({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(date).inDays;

    String dateText = 'Today';
    if (diff == 1) dateText = 'Yesterday';
    if (diff > 1 && diff < 7) dateText = DateFormat('EEEE').format(dateTime);
    if (diff >= 7) dateText = DateFormat('d MMMM yyyy').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _AppTheme.surfaceHover,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _PremiumOrderContextCard extends StatefulWidget {
  final String orderId;
  final String? fallbackTitle;
  final String? fallbackImageUrl;
  final double? fallbackTotal;

  const _PremiumOrderContextCard({
    Key? key,
    required this.orderId,
    this.fallbackTitle,
    this.fallbackImageUrl,
    this.fallbackTotal,
  }) : super(key: key);

  @override
  State<_PremiumOrderContextCard> createState() => _PremiumOrderContextCardState();
}

class _PremiumOrderContextCardState extends State<_PremiumOrderContextCard> {
  Future<OrderModel?>? _orderFuture;
  StreamSubscription<OrderModel?>? _orderSub;
  OrderModel? _localCachedOrder;
  static final Map<String, OrderModel> _staticOrderCache = {};

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void didUpdateWidget(covariant _PremiumOrderContextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _loadOrder();
    }
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  void _loadOrder() {
    _orderSub?.cancel();
    if (widget.orderId.isEmpty) {
      _localCachedOrder = null;
      _orderFuture = null;
      return;
    }

    if (_staticOrderCache.containsKey(widget.orderId)) {
      _localCachedOrder = _staticOrderCache[widget.orderId];
    } else if (widget.fallbackTitle != null || widget.fallbackTotal != null) {
      _localCachedOrder = OrderModel(
        id: widget.orderId,
        customerId: '',
        customerName: 'Sri Kumar',
        sellerId: '',
        status: OrderStatus.newOrder,
        amount: widget.fallbackTotal ?? 0.0,
        timestamp: DateTime.now(),
        items: [
          OrderItemModel(
            productId: '',
            name: widget.fallbackTitle ?? 'Order Item',
            quantity: 1,
            price: widget.fallbackTotal ?? 0.0,
            imageUrl: widget.fallbackImageUrl,
          ),
        ],
      );
    }

    final orderRepo = context.read<IOrderRepository>();
    _orderFuture = orderRepo.getOrderById(widget.orderId).then((order) {
      if (order != null) {
        _staticOrderCache[widget.orderId] = order;
        if (mounted) {
          setState(() {
            _localCachedOrder = order;
          });
        }
      }
      return order;
    });

    // Live real-time status updates (Pending -> Preparing -> Ready -> ...).
    _orderSub = orderRepo.streamOrderById(widget.orderId).listen((order) {
      if (order != null && mounted) {
        _staticOrderCache[widget.orderId] = order;
        setState(() {
          _localCachedOrder = order;
        });
      }
    }, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderId.isEmpty) return const SizedBox.shrink();

    if (_localCachedOrder != null) {
      return _buildCardContent(_localCachedOrder!);
    }

    return FutureBuilder<OrderModel?>(
      future: _orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _AppTheme.borderLight),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: _AppTheme.primary),
            ),
          );
        }
        final order = snapshot.data;
        if (order == null) return const SizedBox.shrink();
        _staticOrderCache[widget.orderId] = order;

        return _buildCardContent(order);
      },
    );
  }

  Widget _buildCardContent(OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = dateFormat.format(order.timestamp);
    final item = order.items?.isNotEmpty == true ? order.items!.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.status.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order ID', style: TextStyle(color: _AppTheme.textSecondary, fontSize: 13)),
              Text(
                '#${order.id.length <= 8 ? order.id.toUpperCase() : order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer', style: TextStyle(color: _AppTheme.textSecondary, fontSize: 13)),
              _RealtimeCustomerNameText(
                fallbackName: order.customerName,
                orderId: order.id,
                buyerId: order.customerId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Date & Time', style: TextStyle(color: _AppTheme.textSecondary, fontSize: 13)),
              Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _OrderTimelineWithAnimation(order: order),
          const SizedBox(height: 16),
          const Divider(color: _AppTheme.borderLight, thickness: 1),
          const SizedBox(height: 12),
          if (order.items != null && order.items!.isNotEmpty)
            ...order.items!.map((item) {
              final imageUrl = item.imageUrl ?? 'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: _AppTheme.surfaceHover,
                          child: const Icon(Icons.fastfood, color: _AppTheme.textTertiary, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12, color: _AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _AppTheme.textPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 12),
          const Divider(color: _AppTheme.borderLight, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _AppTheme.textPrimary)),
              Text(
                '₹${order.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(item, order, context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    OrderItemModel? item,
    OrderModel order,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final orderViewModel = OrderViewModel(
              id: order.id,
              status: order.status.name,
              totalAmount: order.amount,
              date: order.timestamp,
              items: order.items?.map(
                    (i) => CartItem(
                      id: i.productId,
                      name: i.name,
                      price: i.price,
                      sellerId: order.sellerId,
                      image: i.imageUrl,
                      quantity: i.quantity,
                    ),
                  ).toList() ?? [],
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackOrderPageUI(
                  orderId: order.id,
                  order: orderViewModel,
                  isEmbedded: false,
                  allowPopOnDesktop: false,
                ),
              ),
            );
          },
          icon: const Icon(Icons.local_shipping_rounded, size: 16),
          label: const Text('Track Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppTheme.info,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final pdfBytes = await InvoiceGenerator.generateInvoice(
                orderId: order.id,
                buyerName: order.customerName.isNotEmpty && order.customerName != 'Customer' ? order.customerName : 'Sri Kumar',
                sellerName: 'Seller',
                shopName: 'FoodGo Shop',
                totalAmount: order.amount,
                date: order.timestamp,
                items: order.items?.map((i) => {
                  'name': i.name,
                  'qty': i.quantity,
                  'price': i.price,
                }).toList() ?? [],
              );
              
              if (context.mounted) {
                final state = context.read<ChatSupportBloc>().state;
                if (state is ChatSupportLoaded && state.selectedConversationId != null) {
                  context.read<ChatSupportBloc>().add(
                    SendSupportMediaMessage(
                      conversationId: state.selectedConversationId!,
                      file: pdfBytes,
                      messageType: 'pdf',
                      fileName: 'invoice_${order.id.substring(0, min(8, order.id.length))}.pdf',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice generated and sent to chat!'),
                      backgroundColor: _AppTheme.success,
                    ),
                  );
                }
              }
            } catch(e) {
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Failed to generate invoice: $e'), backgroundColor: Colors.red),
                 );
              }
            }
          },
          icon: const Icon(Icons.receipt_long_outlined, size: 16),
          label: const Text('Invoice'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _AppTheme.textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _OrderTimelineWithAnimation extends StatefulWidget {
  final OrderModel order;
  const _OrderTimelineWithAnimation({required this.order});

  @override
  State<_OrderTimelineWithAnimation> createState() => _OrderTimelineWithAnimationState();
}

class _OrderTimelineWithAnimationState extends State<_OrderTimelineWithAnimation> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currentStatus = order.status;
    final statusOrder = {
      OrderStatus.newOrder: 0,
      OrderStatus.accepted: 1,
      OrderStatus.rejected: -1,
      OrderStatus.preparing: 2,
      OrderStatus.ready: 2,
      OrderStatus.outForDelivery: 3,
      OrderStatus.delivered: 4,
      OrderStatus.cancelled: -1,
    };
    final currentIdx = statusOrder[currentStatus] ?? 0;
    final isCancelled = currentStatus == OrderStatus.cancelled;
    final timeFormat = DateFormat('hh:mm a');

    final stepsData = [
      {
        'title': 'Order Confirmed',
        'index': 0,
        'time': timeFormat.format(order.timestamp),
      },
      {
        'title': 'Accepted',
        'index': 1,
        'time': order.acceptedAt != null ? timeFormat.format(order.acceptedAt!) : null,
      },
      {
        'title': 'Preparing Food',
        'index': 2,
        'time': order.preparingAt != null ? timeFormat.format(order.preparingAt!) : null,
      },
      {
        'title': 'Out for Delivery',
        'index': 3,
        'time': order.outForDeliveryAt != null ? timeFormat.format(order.outForDeliveryAt!) : null,
      },
      {
        'title': 'Delivered',
        'index': 4,
        'time': order.deliveredAt != null ? timeFormat.format(order.deliveredAt!) : null,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tracking Status',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (currentIdx >= 0 && !isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: _AppTheme.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentStatus == OrderStatus.delivered ? 'Delivered' : 'In Progress',
                        style: const TextStyle(fontSize: 11, color: _AppTheme.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              return Column(
                children: stepsData.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var step = entry.value;
                  int stepLevel = step['index'] as int;
                  String? stepTime = step['time'] as String?;
                  bool isLast = idx == stepsData.length - 1;

                  bool isCompleted = !isCancelled && currentIdx > stepLevel;
                  bool isCurrent = !isCancelled && currentIdx == stepLevel;
                  bool isFuture = !isCancelled && currentIdx < stepLevel;
                  if (isCancelled) isFuture = true;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Column(
                            children: [
                              _TimelineNode(
                                isCompleted: isCompleted,
                                isCurrent: isCurrent,
                                isFuture: isFuture,
                                pulseAnimation: _pulseAnimation,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isCompleted ? _AppTheme.success : _AppTheme.border,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isCurrent || isCompleted ? FontWeight.w600 : FontWeight.normal,
                                    color: isCurrent || isCompleted ? _AppTheme.textPrimary : _AppTheme.textTertiary,
                                  ),
                                ),
                                if (stepTime != null)
                                  Text(
                                    stepTime,
                                    style: const TextStyle(fontSize: 11, color: _AppTheme.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final Animation<double> pulseAnimation;

  const _TimelineNode({
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(color: _AppTheme.success, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
      );
    }
    if (isCurrent) {
      return ScaleTransition(
        scale: pulseAnimation,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _AppTheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: _AppTheme.primary.withValues(alpha: 0.4), blurRadius: 6),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _AppTheme.surfaceHover,
        shape: BoxShape.circle,
        border: Border.all(color: _AppTheme.border, width: 1.5),
      ),
    );
  }
}

class _PremiumDocumentMessage extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final bool isMe;

  const _PremiumDocumentMessage({
    Key? key,
    required this.fileUrl,
    required this.fileName,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (fileUrl.isNotEmpty) {
          final uri = Uri.tryParse(fileUrl);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              try {
                await launchUrl(uri);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open PDF: $e')),
                  );
                }
              }
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.15) : _AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? null : Border.all(color: _AppTheme.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withValues(alpha: 0.2) : _AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: isMe ? Colors.white : _AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (fileName.isEmpty || fileName.startsWith('Invoice_')) ? 'Invoice.pdf' : fileName,
                    style: TextStyle(
                      color: isMe ? Colors.white : _AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PDF Document • Tap to view/download',
                    style: TextStyle(
                      color: isMe ? Colors.white70 : _AppTheme.textTertiary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.download_rounded,
              color: isMe ? Colors.white : _AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
