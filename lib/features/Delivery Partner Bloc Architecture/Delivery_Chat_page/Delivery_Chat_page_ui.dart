import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/repositories/i_chat_repository.dart';
import 'Delivery_Chat_page_bloc.dart';
import 'Delivery_Chat_page_event.dart';
import 'Delivery_Chat_page_state.dart';
import 'Delivery_Chat_page_repository.dart';
import 'Delivery_Chat_page_service.dart';

class _DeliveryChatTheme {
  _DeliveryChatTheme._();

  static const Color background = DeliveryAppColors.background;
  static const Color surface = DeliveryAppColors.surface;
  static const Color surfaceLight = DeliveryAppColors.surfaceLight;
  static const Color surfaceElevated = DeliveryAppColors.surfaceElevated;
  static const Color primary = DeliveryAppColors.primary;
  static const Color primaryDark = DeliveryAppColors.primaryDark;
  static const Color border = DeliveryAppColors.border;
  static const Color borderSubtle = DeliveryAppColors.borderSubtle;
  static const Color textPrimary = DeliveryAppColors.textPrimary;
  static const Color textSecondary = DeliveryAppColors.textSecondary;
  static const Color textMuted = DeliveryAppColors.textMuted;
  static const Color buttonPrimary = DeliveryAppColors.buttonPrimary;
  static const Color buttonPrimaryText = DeliveryAppColors.buttonPrimaryText;
  static const Color activeSelectedBg = Color(0x1A00E676);
  static const Color activeSelectionBorder = DeliveryAppColors.primary;

  static const double cardRadius = 20.0;
  static const double bubbleRadius = 18.0;
  static const double searchRadius = 16.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: DeliveryAppColors.primary.withValues(alpha: 0.25),
          blurRadius: 18,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
}

class DeliveryChatStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'supportChat': 'Support Chat',
      'conversations': 'conversations',
      'searchHint': 'Search customer or order...',
      'all': 'All',
      'storeSupport': 'Store Support',
      'customer': 'Customer',
      'store': 'Store',
      'rider': 'Rider',
      'callCustomer': 'Call Customer',
      'callStore': 'Call Store',
      'whereAreYou': 'Where are you?',
      'atTheGate': 'I am at the gate',
      'onMyWay': 'On my way 🛵',
      'arrivedRestaurant': 'Arrived at restaurant 🏪',
      'readyForPickup': 'Is order ready? 🛵',
      'rate': 'Rate',
      'invoice': 'Invoice',
      'track': 'Track',
      'buyAgain': 'Buy Again',
      'orderDetails': 'Order Details',
      'totalAmount': 'Total Amount',
      'typeMessage': 'Type a message...',
      'online': 'Online',
      'delivered': 'Delivered',
      'outForDelivery': 'Out for delivery',
      'preparing': 'Preparing food',
      'noConversations': 'No conversations found',
      'selectConversation': 'Select a conversation to start chatting',
      'selectConversationSubtitle': 'Choose an ongoing customer or store order support thread from the list.',
      'typing': 'is typing...',
      'retry': 'Retry',
      'uploadingPhoto': 'Uploading photo...',
      'voiceNote': 'Voice Note',
      'photo': 'Photo',
    },
    'ta': {
      'supportChat': 'ஆதரவு அரட்டை',
      'conversations': 'உரையாடல்கள்',
      'searchHint': 'வாடிக்கையாளர் அல்லது ஆர்டரைத் தேடுங்கள்...',
      'all': 'அனைத்தும்',
      'storeSupport': 'உணவக ஆதரவு',
      'customer': 'வாடிக்கையாளர்',
      'store': 'உணவகம்',
      'rider': 'டெலிவரி பார்ட்னர்',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'callStore': 'உணவகத்தை அழைக்கவும்',
      'whereAreYou': 'எங்கு இருக்கிறீர்கள்?',
      'atTheGate': 'நான் வாசலில் இருக்கிறேன்',
      'onMyWay': 'வருகிறேன் 🛵',
      'arrivedRestaurant': 'உணவகத்தை அடைந்தேன் 🏪',
      'readyForPickup': 'ஆர்டர் தயாரா? 🛵',
      'rate': 'மதிப்பிடவும்',
      'invoice': 'விலைப்பட்டியல்',
      'track': 'கண்காணிக்கவும்',
      'buyAgain': 'மீண்டும் வாங்கவும்',
      'orderDetails': 'ஆர்டர் விவரங்கள்',
      'totalAmount': 'மொத்த தொகை',
      'typeMessage': 'செய்தியை தட்டவும்...',
      'online': 'ஆன்லைன்',
      'delivered': 'டெலிவரி செய்யப்பட்டது',
      'outForDelivery': 'டெலிவரிக்கு புறப்பட்டது',
      'preparing': 'உணவு தயாராகிறது',
      'noConversations': 'உரையாடல்கள் எதுவும் இல்லை',
      'selectConversation': 'அரட்டையைத் தொடங்க உரையாடலைத் தேர்ந்தெடுக்கவும்',
      'selectConversationSubtitle': 'பட்டியலில் இருந்து ஒரு வாடிக்கையாளர் அல்லது உணவகத்தைத் தேர்ந்தெடுக்கவும்.',
      'typing': 'தட்டச்சு செய்கிறார்...',
      'retry': 'மீண்டும் முயற்சி செய்',
      'uploadingPhoto': 'புகைப்படம் பதிவேற்றுகிறது...',
      'voiceNote': 'குரல் பதிவு',
      'photo': 'புகைப்படம்',
    },
  };

  static String of(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

/// Primary Delivery Partner Support Chat Page supporting Dual-Pane Desktop/Web & Mobile Master-Detail.
class DeliveryChatPage extends StatelessWidget {
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String recipientRole; // 'customer' or 'seller' / 'merchant' / 'restaurant'
  final String? recipientName;
  final String? recipientPhone;
  final String? orderTitle;
  final double? orderTotal;
  final String? orderImageUrl;

  const DeliveryChatPage({
    super.key,
    this.orderId = '',
    this.customerId = '',
    this.customerName = '',
    this.customerPhone,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.recipientRole = 'customer',
    this.recipientName,
    this.recipientPhone,
    this.orderTitle,
    this.orderTotal,
    this.orderImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryChatBloc>(
      create: (context) {
        final chatRepo = context.read<IChatRepository>();
        DeliveryChatRepositoryBase deliveryRepo;
        try {
          deliveryRepo = context.read<DeliveryChatRepositoryBase>();
        } catch (_) {
          deliveryRepo = DeliveryChatRepository(chatRepository: chatRepo);
        }
        DeliveryChatServiceBase deliveryServ;
        try {
          deliveryServ = context.read<DeliveryChatServiceBase>();
        } catch (_) {
          deliveryServ = DeliveryChatService(
            chatRepository: chatRepo,
            deliveryChatRepository: deliveryRepo,
          );
        }

        final bloc = DeliveryChatBloc(
          chatRepository: chatRepo,
          deliveryChatRepository: deliveryRepo,
          deliveryChatService: deliveryServ,
        );

        if (orderId.isNotEmpty) {
          bloc.add(InitDeliveryChatEvent(
            orderId: orderId,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            sellerId: sellerId,
            sellerName: sellerName,
            sellerPhone: sellerPhone,
            recipientRole: recipientRole,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            orderTitle: orderTitle,
            orderTotal: orderTotal,
            orderImageUrl: orderImageUrl,
          ));
        }
        bloc.add(const LoadDeliveryConversations());
        return bloc;
      },
      child: const _DeliveryChatResponsiveView(),
    );
  }
}

/// Backward compatibility alias for legacy pages.
typedef DeliveryChatPageUi = DeliveryChatPage;

class _DeliveryChatResponsiveView extends StatelessWidget {
  const _DeliveryChatResponsiveView();

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';

    return BlocConsumer<DeliveryChatBloc, DeliveryChatState>(
      listener: (context, state) {
        if (state is DeliveryChatLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 800;

            if (state is DeliveryChatLoading) {
              return const Scaffold(
                backgroundColor: _DeliveryChatTheme.background,
                body: Center(
                  child: CircularProgressIndicator(color: _DeliveryChatTheme.primary),
                ),
              );
            }

            if (state is DeliveryChatError) {
              return Scaffold(
                backgroundColor: _DeliveryChatTheme.background,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: DeliveryAppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _DeliveryChatTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.read<DeliveryChatBloc>().add(const LoadDeliveryConversations()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _DeliveryChatTheme.primary,
                            foregroundColor: _DeliveryChatTheme.buttonPrimaryText,
                          ),
                          child: Text(DeliveryChatStrings.of('retry', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is! DeliveryChatLoaded) {
              return const Scaffold(backgroundColor: _DeliveryChatTheme.background, body: SizedBox.shrink());
            }

            // Desktop / Tablet Split View (Dark Glassmorphism)
            if (isWideScreen) {
              return Scaffold(
                backgroundColor: _DeliveryChatTheme.background,
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 380,
                        decoration: BoxDecoration(
                          color: _DeliveryChatTheme.surface,
                          borderRadius: BorderRadius.circular(_DeliveryChatTheme.cardRadius),
                          boxShadow: _DeliveryChatTheme.cardShadow,
                          border: Border.all(color: _DeliveryChatTheme.borderSubtle),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_DeliveryChatTheme.cardRadius),
                          child: _SupportChatListView(state: state, lang: lang, isWideScreen: true),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _DeliveryChatTheme.surface,
                            borderRadius: BorderRadius.circular(_DeliveryChatTheme.cardRadius),
                            boxShadow: _DeliveryChatTheme.cardShadow,
                            border: Border.all(color: _DeliveryChatTheme.borderSubtle),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_DeliveryChatTheme.cardRadius),
                            child: (state.selectedConversationId != null && state.selectedConversationId!.isNotEmpty) ||
                                    state.conversationId.isNotEmpty
                                ? _ChatPanel(state: state, lang: lang, isWideScreen: true)
                                : _EmptyChatPlaceholder(lang: lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Mobile Master-Detail View
            if ((state.selectedConversationId != null && state.selectedConversationId!.isNotEmpty) ||
                state.conversationId.isNotEmpty) {
              return Scaffold(
                backgroundColor: _DeliveryChatTheme.background,
                body: _ChatPanel(state: state, lang: lang, isWideScreen: false),
              );
            }

            return Scaffold(
              backgroundColor: _DeliveryChatTheme.background,
              body: SafeArea(
                child: _SupportChatListView(state: state, lang: lang, isWideScreen: false),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// MASTER LIST VIEW (Left Panel / Mobile Main Screen)
// ---------------------------------------------------------------------------
class _SupportChatListView extends StatelessWidget {
  final DeliveryChatLoaded state;
  final String lang;
  final bool isWideScreen;

  const _SupportChatListView({
    required this.state,
    required this.lang,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = state.filteredConversations;

    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context),
        _buildFilterBar(context),
        const Divider(height: 1, color: _DeliveryChatTheme.borderSubtle),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conv = filtered[index];
                    final isSelected = isWideScreen &&
                        (state.selectedConversationId == conv.id ||
                            (state.selectedConversationId == null && state.conversationId == conv.id));
                    return _ConversationTile(
                      conversation: conv,
                      isSelected: isSelected,
                      currentUserId: state.currentUserId,
                      lang: lang,
                      onTap: () {
                        context.read<DeliveryChatBloc>().add(SelectDeliveryConversation(conv.id));
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final totalCount = state.conversations.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _DeliveryChatTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _DeliveryChatTheme.primary.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Icon(Icons.support_agent_rounded, color: _DeliveryChatTheme.primary, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DeliveryChatStrings.of('supportChat', lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _DeliveryChatTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$totalCount ${DeliveryChatStrings.of('conversations', lang)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _DeliveryChatTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!isWideScreen && Navigator.of(context).canPop())
            IconButton(
              icon: const Icon(Icons.close_rounded, color: _DeliveryChatTheme.textMuted),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _DeliveryChatTheme.surfaceLight,
          borderRadius: BorderRadius.circular(_DeliveryChatTheme.searchRadius),
          border: Border.all(color: _DeliveryChatTheme.border),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search_rounded, size: 20, color: _DeliveryChatTheme.textMuted),
            ),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  context.read<DeliveryChatBloc>().add(SearchDeliveryConversations(val));
                },
                style: const TextStyle(fontSize: 13, color: _DeliveryChatTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: DeliveryChatStrings.of('searchHint', lang),
                  hintStyle: const TextStyle(fontSize: 13, color: _DeliveryChatTheme.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _DeliveryChatTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _DeliveryChatTheme.borderSubtle),
                ),
                child: const Text(
                  '⌘K',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _DeliveryChatTheme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final active = state.activeFilter;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          _FilterChip(
            label: DeliveryChatStrings.of('all', lang),
            icon: Icons.forum_outlined,
            selected: active == 'all',
            onTap: () => context.read<DeliveryChatBloc>().add(const SetDeliveryChatFilter('all')),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: DeliveryChatStrings.of('storeSupport', lang),
            icon: Icons.storefront_outlined,
            selected: active == 'seller',
            onTap: () => context.read<DeliveryChatBloc>().add(const SetDeliveryChatFilter('seller')),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: DeliveryChatStrings.of('customer', lang),
            icon: Icons.person_outline_rounded,
            selected: active == 'customer',
            onTap: () => context.read<DeliveryChatBloc>().add(const SetDeliveryChatFilter('customer')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 40, color: _DeliveryChatTheme.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              DeliveryChatStrings.of('noConversations', lang),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _DeliveryChatTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? _DeliveryChatTheme.primary : _DeliveryChatTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _DeliveryChatTheme.primary : _DeliveryChatTheme.borderSubtle,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _DeliveryChatTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: selected ? _DeliveryChatTheme.buttonPrimaryText : _DeliveryChatTheme.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? _DeliveryChatTheme.buttonPrimaryText : _DeliveryChatTheme.textMuted,
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

// ---------------------------------------------------------------------------
// CONVERSATION TILE (Dark Glass Theme)
// ---------------------------------------------------------------------------
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isSelected;
  final String currentUserId;
  final String lang;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.currentUserId,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSeller = conversation.conversationType == 'seller_delivery' ||
        conversation.conversationType == 'seller_support' ||
        conversation.conversationType == 'seller';

    final title = isSeller
        ? (conversation.shopName?.isNotEmpty == true &&
                conversation.shopName != 'Store Support' &&
                conversation.shopName != 'Store'
            ? conversation.shopName!
            : (conversation.sellerName.isNotEmpty &&
                    conversation.sellerName != 'Store Support' &&
                    conversation.sellerName != 'Store'
                ? conversation.sellerName
                : 'Ahbi food restaurants'))
        : (conversation.buyerName.isNotEmpty && conversation.buyerName.toLowerCase() != 'customer'
            ? conversation.buyerName
            : 'Anu');

    final orderId = conversation.orderId ?? '';
    final unread = conversation.unreadCountForUser(currentUserId);
    final lastMsg = conversation.lastMessage ?? 'No messages yet';
    final timeStr = _formatTimestamp(conversation.lastMessageTimestamp ?? conversation.updatedAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _DeliveryChatTheme.activeSelectedBg : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: _DeliveryChatTheme.activeSelectionBorder, width: 3.5))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with Online dot
            Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSeller
                        ? const Color(0xFF1C2A3A)
                        : const Color(0xFF0F2E22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSeller
                          ? const Color(0xFF4FC3F7).withValues(alpha: 0.4)
                          : _DeliveryChatTheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isSeller
                        ? const Icon(Icons.storefront_rounded, color: Color(0xFF4FC3F7), size: 22)
                        : Text(
                            title.isNotEmpty ? title[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: _DeliveryChatTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _DeliveryChatTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: _DeliveryChatTheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _DeliveryChatTheme.primary.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Middle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _DeliveryChatTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildRoleBadge(isSeller),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: _DeliveryChatTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (orderId.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: _DeliveryChatTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _DeliveryChatTheme.borderSubtle),
                          ),
                          child: Text(
                            '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _DeliveryChatTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: unread > 0 ? _DeliveryChatTheme.textPrimary : _DeliveryChatTheme.textMuted,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _DeliveryChatTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _DeliveryChatTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(color: _DeliveryChatTheme.buttonPrimaryText, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isSeller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSeller ? const Color(0x204FC3F7) : const Color(0x20FFB74D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSeller ? const Color(0x404FC3F7) : const Color(0x40FFB74D),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isSeller ? '🏪' : '👤', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            isSeller ? 'Store' : 'Customer',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSeller ? const Color(0xFF4FC3F7) : const Color(0xFFFFB74D),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays == 0) return DateFormat('h:mm a').format(dt);
    if (diff.inDays < 7) return DateFormat('EEEE').format(dt);
    return DateFormat('dd/MM').format(dt);
  }
}

// ---------------------------------------------------------------------------
// DETAIL CHAT PANEL (Right Panel / Mobile Chat View - Dark Glassmorphism)
// ---------------------------------------------------------------------------
class _ChatPanel extends StatefulWidget {
  final DeliveryChatLoaded state;
  final String lang;
  final bool isWideScreen;

  const _ChatPanel({
    required this.state,
    required this.lang,
    required this.isWideScreen,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      children: [
        _buildChatHeader(context),
        Expanded(
          child: Container(
            color: _DeliveryChatTheme.background,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      _buildOrderCard(context),
                      const SizedBox(height: 16),
                      _buildTimestampDivider(),
                      const SizedBox(height: 16),
                      ...widget.state.messages.map((m) => _buildMessageBubble(m)),
                      if (widget.state.isOtherPartyTyping) _buildTypingBubble(),
                    ],
                  ),
                ),
                _buildQuickActionChips(context),
                _buildInputBar(context),
                if (widget.state.showEmojiPicker) _buildEmojiPicker(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Header Bar matching Delivery Partner Theme
  Widget _buildChatHeader(BuildContext context) {
    final isSeller = widget.state.isSellerChat;
    final name = widget.state.recipientName.isNotEmpty
        ? widget.state.recipientName
        : (isSeller ? 'Restaurant' : 'Customer');
    final phone = widget.state.recipientPhone;
    final orderId = widget.state.orderId;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _DeliveryChatTheme.surface,
        border: const Border(bottom: BorderSide(color: _DeliveryChatTheme.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!widget.isWideScreen)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _DeliveryChatTheme.textPrimary),
              onPressed: () {
                context.read<DeliveryChatBloc>().add(const ClearSelectedDeliveryConversation());
              },
            ),
          // Big Avatar with glowing online dot
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSeller ? const Color(0xFF1C2A3A) : const Color(0xFF0F2E22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSeller ? const Color(0xFF4FC3F7).withValues(alpha: 0.5) : _DeliveryChatTheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: isSeller
                      ? const Icon(Icons.storefront_rounded, color: Color(0xFF4FC3F7), size: 22)
                      : Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            color: _DeliveryChatTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _DeliveryChatTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: _DeliveryChatTheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _DeliveryChatTheme.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Name + Badges + Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _DeliveryChatTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSeller ? const Color(0x204FC3F7) : const Color(0x20FFB74D),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSeller ? const Color(0x404FC3F7) : const Color(0x40FFB74D),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isSeller ? '🏪' : '👤', style: const TextStyle(fontSize: 9)),
                          const SizedBox(width: 2),
                          Text(
                            isSeller ? 'Store' : 'Customer',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSeller ? const Color(0xFF4FC3F7) : const Color(0xFFFFB74D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Blue Checkmark Badge
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF4FC3F7), size: 14),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (phone != null && phone.isNotEmpty) ...[
                      const Icon(Icons.phone_outlined, size: 11, color: _DeliveryChatTheme.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 11, color: _DeliveryChatTheme.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (orderId.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _DeliveryChatTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _DeliveryChatTheme.borderSubtle),
                        ),
                        child: Text(
                          'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _DeliveryChatTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _DeliveryChatTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DeliveryChatStrings.of('online', widget.lang),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _DeliveryChatTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: _DeliveryChatTheme.textPrimary, size: 20),
            onPressed: () => _launchCall(phone),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: _DeliveryChatTheme.textPrimary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call available on supported cellular network.')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: _DeliveryChatTheme.textPrimary, size: 20),
            color: _DeliveryChatTheme.surfaceLight,
            onSelected: (val) {
              if (val == 'clear') {
                context.read<DeliveryChatBloc>().add(const ClearSelectedDeliveryConversation());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'details', child: Text('Order Details', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'clear', child: Text('Close Conversation', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  // Embedded Order Card matching Delivery Partner Theme
  Widget _buildOrderCard(BuildContext context) {
    final orderId = widget.state.orderId;
    final title = widget.state.orderTitle;
    final total = widget.state.orderTotal;
    final imgUrl = widget.state.orderImageUrl;

    if (orderId.isEmpty && (title == null || title.isEmpty)) {
      return const SizedBox.shrink();
    }

    final displayTitle = title?.isNotEmpty == true ? title! : 'Order #$orderId';
    final displayTotal = total ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _DeliveryChatTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DeliveryChatTheme.border),
        boxShadow: _DeliveryChatTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery status bullet
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _DeliveryChatTheme.primary, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _DeliveryChatTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.state.orderStatus ?? DeliveryChatStrings.of('delivered', widget.lang),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _DeliveryChatTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Food Thumbnail + Title + Qty + Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imgUrl != null && imgUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _buildBurgerFallback(),
                      )
                    : _buildBurgerFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _DeliveryChatTheme.textPrimary,
                      ),
                    ),
                    if (orderId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '#$orderId',
                        style: const TextStyle(fontSize: 12, color: _DeliveryChatTheme.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (displayTotal > 0)
                Text(
                  '₹${displayTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _DeliveryChatTheme.textPrimary,
                  ),
                ),
            ],
          ),
          if (displayTotal > 0) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: _DeliveryChatTheme.borderSubtle),
            const SizedBox(height: 12),
            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DeliveryChatStrings.of('totalAmount', widget.lang),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _DeliveryChatTheme.textPrimary,
                  ),
                ),
                Text(
                  '₹${displayTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _DeliveryChatTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBurgerFallback() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: _DeliveryChatTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DeliveryChatTheme.borderSubtle),
      ),
      child: const Center(
        child: Icon(Icons.fastfood_rounded, color: _DeliveryChatTheme.primary, size: 24),
      ),
    );
  }

  Widget _buildTimestampDivider() {
    final timeStr = DateFormat('h:mm a').format(DateTime.now());
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _DeliveryChatTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _DeliveryChatTheme.borderSubtle),
        ),
        child: Text(
          timeStr,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _DeliveryChatTheme.textMuted),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isMe = message.senderId == widget.state.currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: isMe ? _DeliveryChatTheme.primary : _DeliveryChatTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(_DeliveryChatTheme.bubbleRadius),
            topRight: const Radius.circular(_DeliveryChatTheme.bubbleRadius),
            bottomLeft: Radius.circular(isMe ? _DeliveryChatTheme.bubbleRadius : 4),
            bottomRight: Radius.circular(isMe ? 4 : _DeliveryChatTheme.bubbleRadius),
          ),
          boxShadow: isMe ? _DeliveryChatTheme.glowShadow : _DeliveryChatTheme.cardShadow,
          border: isMe ? null : Border.all(color: _DeliveryChatTheme.border),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.messageType == 'image' && message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              )
            else if (message.messageType == 'audio')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: isMe ? _DeliveryChatTheme.buttonPrimaryText : _DeliveryChatTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Voice Message (${message.duration ?? 0}s)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isMe ? _DeliveryChatTheme.buttonPrimaryText : _DeliveryChatTheme.textPrimary,
                    ),
                  ),
                ],
              )
            else
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? _DeliveryChatTheme.buttonPrimaryText : _DeliveryChatTheme.textPrimary,
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? _DeliveryChatTheme.buttonPrimaryText.withValues(alpha: 0.7)
                        : _DeliveryChatTheme.textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 12,
                    color: _DeliveryChatTheme.buttonPrimaryText.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _DeliveryChatTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _DeliveryChatTheme.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: _DeliveryChatTheme.primary),
            ),
            const SizedBox(width: 8),
            Text(
              DeliveryChatStrings.of('typing', widget.lang),
              style: const TextStyle(fontSize: 12, color: _DeliveryChatTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Chips Row above input bar
  Widget _buildQuickActionChips(BuildContext context) {
    final isSeller = widget.state.isSellerChat;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionChip(
              icon: Icons.phone_in_talk_rounded,
              label: isSeller
                  ? DeliveryChatStrings.of('callStore', widget.lang)
                  : DeliveryChatStrings.of('callCustomer', widget.lang),
              bgColor: const Color(0xFF0F2E22),
              borderColor: _DeliveryChatTheme.primary.withValues(alpha: 0.5),
              textColor: _DeliveryChatTheme.primary,
              onTap: () => _launchCall(widget.state.recipientPhone),
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.explore_outlined,
              label: DeliveryChatStrings.of('whereAreYou', widget.lang),
              bgColor: const Color(0xFF132838),
              borderColor: const Color(0xFF4FC3F7).withValues(alpha: 0.5),
              textColor: const Color(0xFF4FC3F7),
              onTap: () => _sendQuickReply(DeliveryChatStrings.of('whereAreYou', widget.lang)),
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.meeting_room_outlined,
              label: DeliveryChatStrings.of('atTheGate', widget.lang),
              bgColor: const Color(0xFF2C220E),
              borderColor: const Color(0xFFFFB74D).withValues(alpha: 0.5),
              textColor: const Color(0xFFFFB74D),
              onTap: () => _sendQuickReply(DeliveryChatStrings.of('atTheGate', widget.lang)),
            ),
            const SizedBox(width: 8),
            _QuickActionChip(
              icon: Icons.electric_scooter_rounded,
              label: DeliveryChatStrings.of('onMyWay', widget.lang),
              bgColor: const Color(0xFF241530),
              borderColor: const Color(0xFFC084FC).withValues(alpha: 0.5),
              textColor: const Color(0xFFC084FC),
              onTap: () => _sendQuickReply(DeliveryChatStrings.of('onMyWay', widget.lang)),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Input Bar with Delivery Partner Buttons
  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: _DeliveryChatTheme.surface,
        border: const Border(top: BorderSide(color: _DeliveryChatTheme.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: _DeliveryChatTheme.textMuted, size: 22),
            onPressed: () {
              context.read<DeliveryChatBloc>().add(const ToggleDeliveryEmojiPicker());
            },
          ),
          // Text Input Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _DeliveryChatTheme.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _DeliveryChatTheme.border),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: _DeliveryChatTheme.textPrimary, fontSize: 14),
                onChanged: (val) {
                  setState(() => _isTyping = val.trim().isNotEmpty);
                  context.read<DeliveryChatBloc>().add(SetDeliveryTypingStatusEvent(val.trim().isNotEmpty));
                },
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: DeliveryChatStrings.of('typeMessage', widget.lang),
                  hintStyle: const TextStyle(color: _DeliveryChatTheme.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Attachment (Gallery) Button
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, color: _DeliveryChatTheme.textMuted, size: 22),
            onPressed: () {
              context.read<DeliveryChatBloc>().add(const PickDeliveryAttachmentEvent(fromCamera: false));
            },
          ),
          // Camera Button
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: _DeliveryChatTheme.textMuted, size: 22),
            onPressed: () {
              context.read<DeliveryChatBloc>().add(const PickDeliveryAttachmentEvent(fromCamera: true));
            },
          ),
          // Mic / Voice Button
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: _DeliveryChatTheme.textMuted, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice note recorded and sent.')),
              );
            },
          ),
          // Send Button
          if (_isTyping)
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _DeliveryChatTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: _DeliveryChatTheme.glowShadow,
                ),
                child: const Center(
                  child: Icon(Icons.send_rounded, color: _DeliveryChatTheme.buttonPrimaryText, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _textController.text += emoji.emoji;
          setState(() => _isTyping = true);
        },
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<DeliveryChatBloc>().add(SendDeliveryMessageEvent(text));
    _textController.clear();
    setState(() => _isTyping = false);
    context.read<DeliveryChatBloc>().add(const SetDeliveryTypingStatusEvent(false));
  }

  void _sendQuickReply(String text) {
    context.read<DeliveryChatBloc>().add(SendDeliveryQuickReplyEvent(text));
  }

  void _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _OrderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _OrderActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: _DeliveryChatTheme.surfaceLight,
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: _DeliveryChatTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 14, color: iconColor),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _DeliveryChatTheme.textPrimary),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  final String lang;

  const _EmptyChatPlaceholder({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _DeliveryChatTheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _DeliveryChatTheme.primary.withValues(alpha: 0.3)),
                boxShadow: _DeliveryChatTheme.glowShadow,
              ),
              child: const Center(
                child: Icon(Icons.forum_outlined, size: 44, color: _DeliveryChatTheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              DeliveryChatStrings.of('selectConversation', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _DeliveryChatTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryChatStrings.of('selectConversationSubtitle', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _DeliveryChatTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
