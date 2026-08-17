import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/repositories/i_chat_repository.dart';
import 'Delivery_Chat_page_bloc.dart';
import 'Delivery_Chat_page_event.dart';
import 'Delivery_Chat_page_state.dart';
import 'Delivery_Chat_page_repository.dart';
import 'Delivery_Chat_page_service.dart';

class DeliveryChatStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'customerTitle': 'Customer Chat',
      'sellerTitle': 'Restaurant Chat',
      'send': 'Send',
      'typeMessage': 'Type a message...',
      'quickReplyOnMyWay': 'On my way 🛵',
      'quickReplyArrived': "I've arrived at your address 📍",
      'quickReplyCollectPackage': 'Please collect your package 📦',
      'quickReplyNeedClarification': 'Need address clarification 🗺️',
      'quickReplyPickupInstructions': 'Pickup instructions 📦',
      'quickReplyOrderClarification': 'Order clarification 🧾',
      'quickReplyArrivedRestaurant': "I've arrived at restaurant 🏪",
      'quickReplyOrderDelay': 'Order taking longer than expected ⏳',
      'quickReplyReadyPickup': 'Is order ready for pickup? 🛵',
      'callCustomer': 'Call Customer',
      'callRestaurant': 'Call Restaurant',
      'orderSummary': 'Order Summary',
      'loadingConversation': 'Loading conversation...',
      'noMessages': 'No messages yet. Send a message to get started.',
      'errorLoadingConversation': 'Failed to load conversation.',
      'messageSendFailed': 'Failed to send message.',
      'photoAttachment': 'Photo',
      'takePhoto': 'Take Photo',
      'chooseGallery': 'Choose from Gallery',
      'cancel': 'Cancel',
      'online': 'Online',
      'offline': 'Offline',
      'typing': 'is typing...',
      'retry': 'Retry',
      'viewImage': 'View Photo',
      'uploadingPhoto': 'Uploading photo...',
    },
    'ta': {
      'customerTitle': 'வாடிக்கையாளர் அரட்டை',
      'sellerTitle': 'உணவக அரட்டை',
      'send': 'அனுப்பு',
      'typeMessage': 'செய்தியை தட்டவும்...',
      'quickReplyOnMyWay': 'வருகிறேன் 🛵',
      'quickReplyArrived': 'உங்கள் முகவரியை அடைந்தேன் 📍',
      'quickReplyCollectPackage': 'தயவுசெய்து பார்சலைப் பெறவும் 📦',
      'quickReplyNeedClarification': 'முகவரி விளக்கம் தேவை 🗺️',
      'quickReplyPickupInstructions': 'பிக்அப் வழிமுறைகள் 📦',
      'quickReplyOrderClarification': 'ஆர்டர் விளக்கம் 🧾',
      'quickReplyArrivedRestaurant': 'உணவகத்தை அடைந்தேன் 🏪',
      'quickReplyOrderDelay': 'ஆர்டர் தாமதமாகிறது ⏳',
      'quickReplyReadyPickup': 'ஆர்டர் தயாரா? 🛵',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'callRestaurant': 'உணவகத்தை அழைக்கவும்',
      'orderSummary': 'ஆர்டர் சுருக்கம்',
      'loadingConversation': 'உரையாடல் ஏற்றுகிறது...',
      'noMessages': 'இதுவரை செய்திகள் இல்லை. விரைவான பதிலை அனுப்பவும்.',
      'errorLoadingConversation': 'உரையாடல் ஏற்ற தோல்வியுற்றது.',
      'messageSendFailed': 'செய்தி அனுப்ப தோல்வியுற்றது.',
      'photoAttachment': 'புகைப்படம்',
      'takePhoto': 'புகைப்படம் எடுக்கவும்',
      'chooseGallery': 'கேலரியில் இருந்து தேர்வு செய்',
      'cancel': 'ரத்துசெய்',
      'online': 'ஆன்லைன்',
      'offline': 'ஆஃப்லைன்',
      'typing': 'தட்டச்சு செய்கிறார்...',
      'retry': 'மீண்டும் முயற்சி செய்',
      'viewImage': 'படத்தைக் காண்க',
      'uploadingPhoto': 'புகைப்படம் பதிவேற்றுகிறது...',
    },
  };

  static String of(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

class DeliveryQuickReply {
  final String key;
  final String text;

  const DeliveryQuickReply(this.key, this.text);
}

const List<DeliveryQuickReply> _customerQuickReplies = [
  DeliveryQuickReply('quickReplyOnMyWay', 'On my way 🛵'),
  DeliveryQuickReply('quickReplyArrived', "I've arrived at your address 📍"),
  DeliveryQuickReply('quickReplyCollectPackage', 'Please collect your package 📦'),
  DeliveryQuickReply('quickReplyNeedClarification', 'Need address clarification 🗺️'),
];

const List<DeliveryQuickReply> _sellerQuickReplies = [
  DeliveryQuickReply('quickReplyPickupInstructions', 'Pickup instructions 📦'),
  DeliveryQuickReply('quickReplyOrderClarification', 'Order clarification 🧾'),
  DeliveryQuickReply('quickReplyArrivedRestaurant', "I've arrived at restaurant 🏪"),
  DeliveryQuickReply('quickReplyReadyPickup', 'Is order ready for pickup? 🛵'),
  DeliveryQuickReply('quickReplyOrderDelay', 'Order taking longer than expected ⏳'),
];

/// Primary Delivery Partner Chat Page supporting Customer & Seller chats.
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
        ));
        return bloc;
      },
      child: const _DeliveryChatView(),
    );
  }

}

/// Backward compatibility alias for legacy pages.
typedef DeliveryChatPageUi = DeliveryChatPage;

class _DeliveryChatView extends StatefulWidget {
  const _DeliveryChatView();

  @override
  State<_DeliveryChatView> createState() => _DeliveryChatViewState();
}

class _DeliveryChatViewState extends State<_DeliveryChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';

    return BlocConsumer<DeliveryChatBloc, DeliveryChatState>(
      listener: (context, state) {
        if (state is DeliveryChatLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DeliveryAppColors.background,
          appBar: _buildAppBar(context, state, lang),
          body: _buildBody(context, state, lang),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DeliveryChatState state,
    String lang,
  ) {
    final isLoaded = state is DeliveryChatLoaded;
    final isSeller = isLoaded && state.isSellerChat;
    final name = isLoaded
        ? state.recipientName
        : (isSeller ? 'Restaurant' : 'Customer');
    final phone = isLoaded ? state.recipientPhone : null;
    final isTyping = isLoaded && state.isOtherPartyTyping;

    return AppBar(
      backgroundColor: DeliveryAppColors.surface,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DeliveryAppColors.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isSeller
                    ? [const Color(0xFFFF7A00), const Color(0xFFFF5200)]
                    : [const Color(0xFF10B981), const Color(0xFF059669)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSeller ? Colors.orange : DeliveryAppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isSeller
                  ? const Icon(Icons.storefront_rounded, color: Colors.white, size: 22)
                  : Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isTyping
                      ? DeliveryChatStrings.of('typing', lang)
                      : (isSeller
                          ? DeliveryChatStrings.of('sellerTitle', lang)
                          : DeliveryChatStrings.of('online', lang)),
                  style: TextStyle(
                    color: isTyping ? DeliveryAppColors.warning : DeliveryAppColors.primary,
                    fontSize: 12,
                    fontWeight: isTyping ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.infoBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DeliveryAppColors.infoBorder),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: DeliveryAppColors.info,
                  size: 20,
                ),
              ),
              tooltip: isSeller
                  ? DeliveryChatStrings.of('callRestaurant', lang)
                  : DeliveryChatStrings.of('callCustomer', lang),
              onPressed: () => _launchPhoneCall(phone),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeliveryChatState state,
    String lang,
  ) {
    if (state is DeliveryChatLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: DeliveryAppColors.primary,
        ),
      );
    }

    if (state is DeliveryChatError) {
      return _buildErrorBody(context, state, lang);
    }

    if (state is DeliveryChatLoaded) {
      return _buildChatBody(context, state, lang);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorBody(
    BuildContext context,
    DeliveryChatError state,
    String lang,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DeliveryAppColors.error.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.error_outline,
                color: DeliveryAppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DeliveryAppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: DeliveryAppColors.buttonPrimaryText,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(DeliveryChatStrings.of('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBody(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Column(
      children: [
        _buildOrderContextBar(context, state, lang),
        if (state.isUploadingAttachment)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: DeliveryAppColors.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: DeliveryAppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  DeliveryChatStrings.of('uploadingPhoto', lang),
                  style: const TextStyle(color: DeliveryAppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyChat(context, lang, state.isSellerChat)
              : _buildMessageList(context, state, lang),
        ),
        _buildQuickReplies(context, state, lang),
        if (state.errorMessage != null) _buildErrorBanner(context, state, lang),
        if (state.infoMessage != null) _buildInfoBanner(context, state, lang),
        _buildComposer(context, state, lang),
      ],
    );
  }

  Widget _buildOrderContextBar(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (state.isSellerChat ? Colors.orange : DeliveryAppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              state.isSellerChat ? Icons.store_mall_directory_rounded : Icons.receipt_long_rounded,
              color: state.isSellerChat ? Colors.orange.shade800 : DeliveryAppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.orderTitle ??
                      '${DeliveryChatStrings.of('orderSummary', lang)} #${state.orderId.length > 8 ? state.orderId.substring(0, 8) : state.orderId}',
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.orderTotal != null)
                  Text(
                    '₹${state.orderTotal!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: state.isSellerChat ? Colors.orange.shade800 : DeliveryAppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DeliveryAppColors.border),
            ),
            child: Text(
              state.isSellerChat ? 'Merchant' : 'Customer',
              style: const TextStyle(
                color: DeliveryAppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context, String lang, bool isSeller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isSeller ? Colors.orange : DeliveryAppColors.primary).withValues(alpha: 0.1),
              ),
              child: Icon(
                isSeller ? Icons.restaurant_menu_rounded : Icons.chat_bubble_outline_rounded,
                color: isSeller ? Colors.orange.shade800 : DeliveryAppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryChatStrings.of('noMessages', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DeliveryAppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMine = message.senderId == state.currentUserId;
        return _DeliveryChatBubble(
          message: message,
          isMine: isMine,
          lang: lang,
        );
      },
    );
  }

  Widget _buildQuickReplies(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    final replies = state.isSellerChat ? _sellerQuickReplies : _customerQuickReplies;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = replies[index];
          final label = DeliveryChatStrings.of(reply.key, lang);
          return GestureDetector(
            onTap: () {
              context.read<DeliveryChatBloc>().add(
                    SendDeliveryQuickReplyEvent(reply.text),
                  );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: DeliveryAppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DeliveryAppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: state.isSellerChat ? Colors.orange.shade900 : DeliveryAppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: DeliveryAppColors.errorBg,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: DeliveryAppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(
                color: DeliveryAppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: DeliveryAppColors.infoBg,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: DeliveryAppColors.info, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.infoMessage!,
              style: const TextStyle(
                color: DeliveryAppColors.info,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        border: Border(
          top: BorderSide(color: DeliveryAppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_photo_alternate_rounded,
                color: DeliveryAppColors.primary,
                size: 24,
              ),
              tooltip: DeliveryChatStrings.of('photoAttachment', lang),
              onPressed: () => _showMediaPickerSheet(context, lang),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: DeliveryAppColors.border),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onChanged: (val) {
                    context.read<DeliveryChatBloc>().add(
                          SetDeliveryTypingStatusEvent(val.trim().isNotEmpty),
                        );
                  },
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      context.read<DeliveryChatBloc>().add(
                            SendDeliveryMessageEvent(text.trim()),
                          );
                      _textController.clear();
                      context.read<DeliveryChatBloc>().add(
                            const SetDeliveryTypingStatusEvent(false),
                          );
                    }
                  },
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: DeliveryChatStrings.of('typeMessage', lang),
                    hintStyle: const TextStyle(
                      color: DeliveryAppColors.textDisabled,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.isSendingMessage
                    ? DeliveryAppColors.textDisabled
                    : (state.isSellerChat ? Colors.orange.shade700 : DeliveryAppColors.primary),
              ),
              child: IconButton(
                icon: state.isSendingMessage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                onPressed: state.isSendingMessage
                    ? null
                    : () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          context.read<DeliveryChatBloc>().add(
                                SendDeliveryMessageEvent(text),
                              );
                          _textController.clear();
                          context.read<DeliveryChatBloc>().add(
                                const SetDeliveryTypingStatusEvent(false),
                              );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerSheet(BuildContext context, String lang) {
    final bloc = context.read<DeliveryChatBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: DeliveryAppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DeliveryAppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: DeliveryAppColors.primary),
                ),
                title: Text(
                  DeliveryChatStrings.of('takePhoto', lang),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  bloc.add(const PickDeliveryAttachmentEvent(fromCamera: true));
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Colors.purple),
                ),
                title: Text(
                  DeliveryChatStrings.of('chooseGallery', lang),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  bloc.add(const PickDeliveryAttachmentEvent(fromCamera: false));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  final String lang;

  const _DeliveryChatBubble({
    required this.message,
    required this.isMine,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeletedForEveryone) {
      return _buildDeletedBubble();
    }

    final isImage = message.messageType == 'image' && message.mediaUrl != null && message.mediaUrl!.isNotEmpty;
    final isAudio = message.messageType == 'audio' && message.mediaUrl != null && message.mediaUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.all(isImage ? 6 : 12),
            decoration: BoxDecoration(
              color: isMine
                  ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                  : DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: Border.all(
                color: isMine
                    ? DeliveryAppColors.primary.withValues(alpha: 0.3)
                    : DeliveryAppColors.border,

              ),
            ),
            child: isImage
                ? _buildImageAttachment(context)
                : isAudio
                    ? _buildAudioAttachment()
                    : Text(
                        message.text,
                        style: const TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isMine ? 0 : 8,
              right: isMine ? 8 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    color: DeliveryAppColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: message.isRead ? Colors.blue : DeliveryAppColors.textDisabled,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAttachment(BuildContext context) {
    return GestureDetector(
      onTap: () => _viewFullScreenImage(context, message.mediaUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              message.mediaUrl!,
              fit: BoxFit.cover,
              width: 220,
              height: 220,
              errorBuilder: (_, __, ___) => Container(
                width: 220,
                height: 140,
                color: DeliveryAppColors.surface,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, color: DeliveryAppColors.textDisabled, size: 36),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 220,
                  height: 180,
                  color: DeliveryAppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: DeliveryAppColors.primary),
                  ),
                );
              },
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioAttachment() {
    final duration = message.duration ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DeliveryAppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow_rounded, color: DeliveryAppColors.primary, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          duration > 0 ? '0:${duration.toString().padLeft(2, '0')}' : 'Voice note',
          style: const TextStyle(color: DeliveryAppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _viewFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: DeliveryAppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block_rounded,
                color: DeliveryAppColors.textDisabled,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: DeliveryAppColors.textDisabled,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

Future<void> _launchPhoneCall(String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri.parse('tel:$cleanNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
