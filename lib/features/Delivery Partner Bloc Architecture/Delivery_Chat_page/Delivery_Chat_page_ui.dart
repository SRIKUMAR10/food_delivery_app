import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/models/chat_message_model.dart';
import 'Delivery_Chat_page_bloc.dart';
import 'Delivery_Chat_page_event.dart';
import 'Delivery_Chat_page_state.dart';
import 'Delivery_Chat_page_repository.dart';
import 'Delivery_Chat_page_service.dart';

class DeliveryChatStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Customer Chat',
      'send': 'Send',
      'typeMessage': 'Type a message...',
      'quickReplyOnMyWay': 'On my way \uD83D\uDEF5',
      'quickReplyArrived': "I've arrived at your address \uD83D\uDCCD",
      'quickReplyCollectPackage': 'Please collect your package \uD83D\uDCE6',
      'quickReplyNeedClarification': 'Need address clarification \uD83D\uDDFA\uFE0F',
      'callCustomer': 'Call Customer',
      'orderSummary': 'Order Summary',
      'loadingConversation': 'Loading conversation...',
      'noMessages': 'No messages yet. Send a quick reply to get started.',
      'errorLoadingConversation': 'Failed to load conversation.',
      'messageSendFailed': 'Failed to send message.',
      'attachmentHint': 'Attachment upload coming soon',
      'online': 'Online',
      'offline': 'Offline',
      'retry': 'Retry',
    },
    'ta': {
      'title': '\u0BB5\u0BBE\u0B9F\u0BBF\u0B95\u0BCD\u0B95\u0BC8\u0BAF\u0BBE\u0BB3\u0BB0\u0BCD \u0B85\u0BB0\u0B9F\u0BCD\u0B9F\u0BC8',
      'send': '\u0B85\u0BA9\u0BC1\u0BAA\u0BCD\u0BAA\u0BC1',
      'typeMessage': '\u0B9A\u0BC6\u0BAF\u0BCD\u0BA4\u0BBF\u0BAF\u0BC8 \u0BA4\u0B9F\u0BCD\u0B9F\u0BB5\u0BC1\u0BAE\u0BCD...',
      'quickReplyOnMyWay': '\u0BB5\u0BB0\u0BC1\u0B95\u0BBF\u0BB1\u0BC7\u0BA9\u0BCD \uD83D\uDEF5',
      'quickReplyArrived': '\u0B89\u0B99\u0BCD\u0B95\u0BB3\u0BCD \u0BAE\u0BC1\u0B95\u0BB5\u0BB0\u0BBF\u0BAF\u0BC8 \u0BB5\u0BB0\u0BC1\u0B95\u0BBF\u0BB1\u0BC7\u0BA9\u0BCD \uD83D\uDCCD',
      'quickReplyCollectPackage': '\u0BA4\u0BAF\u0BB5\u0BC1 \u0B9A\u0BC6\u0BAF\u0BCD\u0BAF \u0BAA\u0BCA\u0BA4\u0BBF\u0BA4\u0BCD \u0BA4\u0BB0\u0BB5\u0BC1\u0BAE\u0BCD \uD83D\uDCE6',
      'quickReplyNeedClarification': '\u0BAE\u0BC1\u0B95\u0BB5\u0BB0\u0BBF \u0BB5\u0BBF\u0BB3\u0B95\u0BCD\u0B95\u0BAE\u0BCD \u0BA4\u0BC7\u0BB5\u0BC8 \uD83D\uDDFA\uFE0F',
      'callCustomer': '\u0BB5\u0BBE\u0B9F\u0BBF\u0B95\u0BCD\u0B95\u0BC8\u0BAF\u0BBE\u0BB3\u0BB0\u0BC8 \u0B85\u0BB4\u0BC8\u0B95\u0BCD\u0B95\u0BB5\u0BC1\u0BAE\u0BCD',
      'orderSummary': '\u0B86\u0BB0\u0BCD\u0B9F\u0BB0\u0BCD \u0B9A\u0BC1\u0BB0\u0BC1\u0B95\u0BCD\u0B95\u0BAE\u0BCD',
      'loadingConversation': '\u0B89\u0BB0\u0BC8\u0BAF\u0BBE\u0B9F\u0BB2\u0BCD \u0B8F\u0BB1\u0BCD\u0BB1\u0BA4\u0BCD\u0BA4\u0BC1...',
      'noMessages': '\u0B87\u0BA4\u0BC1\u0BB5\u0BB0\u0BC8 \u0B9A\u0BC6\u0BAF\u0BCD\u0BA4\u0BBF\u0B95\u0BB3\u0BCD \u0B87\u0BB2\u0BCD\u0BB2\u0BC8. \u0BA4\u0BCA\u0B9F\u0B99\u0BCD\u0B95 \u0BB5\u0BBF\u0BB0\u0BC8\u0BB5\u0BBE\u0BA9 \u0BAA\u0BA4\u0BBF\u0BB2\u0BC8 \u0B85\u0BA9\u0BC1\u0BAA\u0BCD\u0BAA\u0BB5\u0BC1\u0BAE\u0BCD.',
      'errorLoadingConversation': '\u0B89\u0BB0\u0BC8\u0BAF\u0BBE\u0B9F\u0BB2\u0BCD \u0B8F\u0BB1\u0BCD\u0BB1 \u0BA4\u0BCB\u0BB2\u0BCD\u0BB5\u0BBF\u0BAF\u0BC1\u0BB1\u0BCD\u0BB1\u0BA4\u0BC1.',
      'messageSendFailed': '\u0B9A\u0BC6\u0BAF\u0BCD\u0BA4\u0BBF \u0B85\u0BA9\u0BC1\u0BAA\u0BCD\u0BAA \u0BA4\u0BCB\u0BB2\u0BCD\u0BB5\u0BBF\u0BAF\u0BC1\u0BB1\u0BCD\u0BB1\u0BA4\u0BC1.',
      'attachmentHint': '\u0B87\u0BA3\u0BC8\u0BAA\u0BCD\u0BAA\u0BC1 \u0BAA\u0BA4\u0BBF\u0BB5\u0BC7\u0BB1\u0BCD\u0BB1\u0BAE\u0BCD \u0BB5\u0BBF\u0BB0\u0BC8\u0BB5\u0BBF\u0BB2\u0BCD',
      'online': '\u0B86\u0BA9\u0BCD\u0BB2\u0BC8\u0BA9\u0BCD',
      'offline': '\u0B86\u0B83\u0BAA\u0BCD\u0BB2\u0BC8\u0BA9\u0BCD',
      'retry': '\u0BAE\u0BC0\u0BA3\u0BCD\u0B9F\u0BC1\u0BAE\u0BCD \u0BAE\u0BC1\u0BAF\u0BB1\u0BCD\u0B9A\u0BBF \u0B9A\u0BC6\u0BAF\u0BCD',
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

const List<DeliveryQuickReply> _quickReplies = [
  DeliveryQuickReply('quickReplyOnMyWay', 'On my way \uD83D\uDEF5'),
  DeliveryQuickReply('quickReplyArrived', "I've arrived at your address \uD83D\uDCCD"),
  DeliveryQuickReply('quickReplyCollectPackage', 'Please collect your package \uD83D\uDCE6'),
  DeliveryQuickReply('quickReplyNeedClarification', 'Need address clarification \uD83D\uDDFA\uFE0F'),
];

class DeliveryChatPage extends StatelessWidget {
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? orderTitle;
  final double? orderTotal;

  const DeliveryChatPage({
    super.key,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.orderTitle,
    this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryChatBloc>(
      create: (context) {
        final bloc = DeliveryChatBloc(
          chatRepository: context.read(),
          deliveryChatRepository: DeliveryChatRepository(
            chatRepository: context.read(),
          ),
          deliveryChatService: DeliveryChatService(
            chatRepository: context.read(),
            deliveryChatRepository: DeliveryChatRepository(
              chatRepository: context.read(),
            ),
          ),
        );
        bloc.add(InitDeliveryChatEvent(
          orderId: orderId,
          customerId: customerId,
          customerName: customerName,
          customerPhone: customerPhone,
          orderTitle: orderTitle,
          orderTotal: orderTotal,
        ));
        return bloc;
      },
      child: const _DeliveryChatView(),
    );
  }
}

class _DeliveryChatView extends StatelessWidget {
  const _DeliveryChatView();

  @override
  Widget build(BuildContext context) {
    final lang = 'en';

    return BlocConsumer<DeliveryChatBloc, DeliveryChatState>(
      listener: (context, state) {},
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
    final customerName = state is DeliveryChatLoaded
        ? state.customerName
        : 'Customer';
    final customerPhone = state is DeliveryChatLoaded ? state.customerPhone : null;

    return AppBar(
      backgroundColor: DeliveryAppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DeliveryAppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              boxShadow: [
                BoxShadow(
                  color: DeliveryAppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                  customerName,
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DeliveryChatStrings.of('online', lang),
                  style: TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (customerPhone != null && customerPhone.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.infoBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DeliveryAppColors.infoBorder,
                  ),
                ),
                child: const Icon(
                  Icons.call,
                  color: DeliveryAppColors.info,
                  size: 20,
                ),
              ),
              onPressed: () => _launchPhoneCall(customerPhone),
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
                color: DeliveryAppColors.error.withOpacity(0.15),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyChat(context, lang)
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
              color: DeliveryAppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: DeliveryAppColors.primary,
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
                  state.orderTitle ?? '${DeliveryChatStrings.of('orderSummary', lang)} #${state.orderId.substring(0, state.orderId.length < 8 ? state.orderId.length : 8)}',
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.orderTotal != null)
                  Text(
                    '\u20B9${state.orderTotal!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context, String lang) {
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
                color: DeliveryAppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: DeliveryAppColors.primary,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMine = message.senderId == state.currentUserId;
        return _DeliveryChatBubble(
          message: message,
          isMine: isMine,
        );
      },
    );
  }

  Widget _buildQuickReplies(
    BuildContext context,
    DeliveryChatLoaded state,
    String lang,
  ) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          final label = DeliveryChatStrings.of(reply.key, lang);
          final displayLabel = label.length > 30 ? '${label.substring(0, 28)}...' : label;
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
                displayLabel,
                style: TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
    final controller = TextEditingController();
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
                Icons.attach_file,
                color: DeliveryAppColors.textMuted,
                size: 22,
              ),
              onPressed: () {
                context
                    .read<DeliveryChatBloc>()
                    .add(const PickDeliveryAttachmentEvent());
              },
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
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      context.read<DeliveryChatBloc>().add(
                            SendDeliveryMessageEvent(text.trim()),
                          );
                      controller.clear();
                    }
                  },
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: DeliveryChatStrings.of('typeMessage', lang),
                    hintStyle: TextStyle(
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
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.isSendingMessage
                    ? DeliveryAppColors.textDisabled
                    : DeliveryAppColors.primary,
              ),
              child: IconButton(
                icon: state.isSendingMessage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DeliveryAppColors.textPrimary,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: DeliveryAppColors.buttonPrimaryText,
                        size: 20,
                      ),
                onPressed: state.isSendingMessage
                    ? null
                    : () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          context.read<DeliveryChatBloc>().add(
                                SendDeliveryMessageEvent(text),
                              );
                          controller.clear();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;

  const _DeliveryChatBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeletedForEveryone) {
      return _buildDeletedBubble();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? DeliveryAppColors.primary.withOpacity(0.15)
                  : DeliveryAppColors.surfaceLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: Border.all(
                color: isMine
                    ? DeliveryAppColors.primary.withOpacity(0.3)
                    : DeliveryAppColors.border,
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isMine
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isMine ? 0 : 12,
              right: isMine ? 12 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                color: DeliveryAppColors.textDisabled,
                fontSize: 10,
              ),
            ),
          ),
        ],
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
            color: DeliveryAppColors.surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.block,
            color: DeliveryAppColors.textDisabled,
            size: 16,
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
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
