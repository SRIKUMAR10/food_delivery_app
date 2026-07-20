  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'buyer_chat_bloc.dart';
import 'buyer_chat_event.dart';
import 'buyer_chat_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/order_status.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../Rating_page/Rating_page_ui.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';
import '../Cart Page/cart_page_Bloc.dart';
import '../Order Page/order_view_model.dart';

import '../Cart Page/cart_models.dart';
import '../Cart Page/cart_page_UI.dart';

class SupportNavigationData {
  final String orderId;
  final String sellerId;
  final String sellerName;
  final String buyerName;
  final String shopName;
  final String sellerImageUrl;
  final String? orderImageUrl;
  final String? orderTitle;
  final double? orderTotal;

  const SupportNavigationData({
    required this.orderId,
    required this.sellerId,
    required this.sellerName,
    required this.buyerName,
    this.shopName = '',
    this.sellerImageUrl = '',
    this.orderImageUrl,
    this.orderTitle,
    this.orderTotal,
  });
}

class BuyerChatPage extends StatelessWidget {
  final String? orderId;
  final String? sellerId;
  final String? sellerName;
  final String? shopName;
  final String? sellerImageUrl;
  final String? buyerName;
  final SupportNavigationData? pendingOrderData;

  const BuyerChatPage({
    Key? key,
    this.orderId,
    this.sellerId,
    this.sellerName,
    this.shopName,
    this.sellerImageUrl,
    this.buyerName,
    this.pendingOrderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPushedRoute = pendingOrderData != null || (orderId != null && sellerId != null);
    return BlocProvider(
      create: (context) {
        final bloc = BuyerChatBloc(
          repository: context.read<IChatRepository>(),
          authService: context.read<IAuthService>(),
        );
        final data = pendingOrderData;
        if (data != null) {
          bloc.openOrderConversation(
            orderId: data.orderId,
            sellerId: data.sellerId,
            sellerName: data.sellerName,
            shopName: data.shopName,
            sellerImageUrl: data.sellerImageUrl,
            buyerName: data.buyerName,
            orderImageUrl: data.orderImageUrl,
            orderTitle: data.orderTitle,
            orderTotal: data.orderTotal,
          );
        } else if (orderId != null &&
            sellerId != null &&
            sellerName != null &&
            buyerName != null) {
          bloc.openOrderConversation(
            orderId: orderId!,
            sellerId: sellerId!,
            sellerName: sellerName!,
            shopName: shopName,
            sellerImageUrl: sellerImageUrl,
            buyerName: buyerName!,
          );
        } else {
          bloc.add(LoadBuyerConversations());
        }
        return bloc;
      },
      child: BuyerChatView(isPushedRoute: isPushedRoute),
    );
  }
}

class BuyerChatView extends StatelessWidget {
  final bool isPushedRoute;
  const BuyerChatView({Key? key, this.isPushedRoute = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuyerChatBloc, BuyerChatState>(
      listener: (context, state) {
        if (state is BuyerChatLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFE52929),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BuyerChatLoading || state is BuyerChatInitial) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            ),
          );
        } else if (state is BuyerChatError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Color(0xFFE52929)),
              ),
            ),
          );
        } else if (state is BuyerChatLoaded) {
          final screenType = _screenType(context);
          final isDesktop = screenType == _ScreenType.desktop;

          if (isDesktop) {
            return Scaffold(
              backgroundColor: const Color(0xFFFAFAFA),
              body: Row(
                children: [
                  SizedBox(
                    width: 350,
                    child: _BuyerChatListView(
                      conversations: state.filteredConversations,
                      currentUserId: state.currentUserId,
                      searchQuery: state.searchQuery,
                      embedded: true,
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                  Expanded(
                    child: state.selectedConversationId != null && state.selectedConversation != null
                          ? _ChatPanel(
                              conversation: state.selectedConversation!,
                              messages: state.messages,
                              isSending: state.isSendingMessage,
                              isPushedRoute: isPushedRoute,
                            )
                        : const Scaffold(
                            backgroundColor: Color(0xFFEFEAE2),
                            body: Center(
                              child: Text(
                                'Select a conversation to start chatting',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          }

          if (state.selectedConversationId != null && state.selectedConversation != null) {
            return Scaffold(
              backgroundColor: const Color(0xFFEFEAE2),
              body: _ChatPanel(
                conversation: state.selectedConversation!,
                messages: state.messages,
                isSending: state.isSendingMessage,
                isPushedRoute: isPushedRoute,
              ),
            );
          }

          return _BuyerChatListView(
            conversations: state.filteredConversations,
            currentUserId: state.currentUserId,
            searchQuery: state.searchQuery,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

enum _ScreenType { mobile, tablet, desktop }

_ScreenType _screenType(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 600) return _ScreenType.mobile;
  if (w < 1024) return _ScreenType.tablet;
  return _ScreenType.desktop;
}

class _BuyerChatListView extends StatelessWidget {
  final List<ConversationModel> conversations;
  final String currentUserId;
  final String searchQuery;
  final bool embedded;

  const _BuyerChatListView({
    required this.conversations,
    required this.currentUserId,
    required this.searchQuery,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);
    final isWide = screenType != _ScreenType.mobile;
    final hp = isWide ? 24.0 : 16.0;
    final vp = isWide ? 16.0 : 8.0;

    Widget bodyContent = _buildBody(context, hp, vp);

    if (isWide) {
      bodyContent = Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: bodyContent,
        ),
      );
    }

    if (embedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text('Support Chat'), centerTitle: true),
      body: bodyContent,
    );
  }

  Widget _buildBody(BuildContext context, double hp, double vp) {
    return Column(
      children: [
        _buildSearchBar(context, hp),
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: const Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text(
                        'No conversations yet.',
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: hp,
                    vertical: vp,
                  ),
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final unread = conversation.unreadCountForUser(
                      currentUserId,
                    );
                    final displayName =
                        conversation.shopName ??
                        conversation.otherParticipantName(currentUserId);

                    return InkWell(
                      onTap: () {
                        context.read<BuyerChatBloc>().add(
                          SelectBuyerConversation(conversation.id),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFDBEAFE),
                              backgroundImage:
                                  conversation.sellerImageUrl != null &&
                                      conversation.sellerImageUrl!.isNotEmpty
                                  ? NetworkImage(conversation.sellerImageUrl!)
                                  : null,
                              child:
                                  conversation.sellerImageUrl == null ||
                                      conversation.sellerImageUrl!.isEmpty
                                  ? Text(
                                      displayName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (conversation.lastMessageTimestamp !=
                                          null)
                                        Text(
                                          DateFormat('hh:mm a').format(
                                            conversation
                                                .lastMessageTimestamp!,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversation.lastMessage ??
                                              'No messages yet.',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: unread > 0
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFF64748B),
                                            fontWeight: unread > 0
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (unread > 0)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (conversation.orderId != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Order #${conversation.orderId}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 4),
      color: const Color(0xFFFAFAFA),
      child: TextField(
        onChanged: (query) {
          context.read<BuyerChatBloc>().add(FilterBuyerConversations(query));
        },
        decoration: InputDecoration(
          hintText: 'Search by order ID or restaurant...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  final ConversationModel conversation;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isPushedRoute;

  const _ChatPanel({
    required this.conversation,
    required this.messages,
    required this.isSending,
    this.isPushedRoute = false,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

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
  void didUpdateWidget(covariant _ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMessage(
          widget.conversation.id,
          _textController.text,
        ),
      );
      _textController.clear();
    }
  }

  List<Widget> _buildChatItems(_ScreenType screenType) {
    final items = <Widget>[];
    String? lastDateKey;

    items.add(Padding(
      padding: EdgeInsets.only(bottom: screenType == _ScreenType.mobile ? 12 : 16),
      child: _PremiumOrderContextCard(conversation: widget.conversation),
    ));

    for (final msg in widget.messages) {
      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      if (dateKey != lastDateKey) {
        items.add(_DateSeparatorChip(dateTime: msg.timestamp));
        lastDateKey = dateKey;
      }
      items.add(_BuyerChatBubble(
        message: msg,
        isMe: msg.senderRole == 'buyer',
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(screenType),
          Expanded(
            child: Container(
              color: const Color(0xFFEFEAE2),
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.all(screenType == _ScreenType.mobile ? 12 : 20),
                children: _buildChatItems(screenType),
              ),
            ),
          ),
          _buildInputArea(screenType),
        ],
      ),
    );
  }

  Widget _buildHeader(_ScreenType screenType) {
    final currentUserId = context.read<BuyerChatBloc>().authService.currentUserId ?? '';
    final otherName = widget.conversation.otherParticipantName(currentUserId);
    final displayName = widget.conversation.shopName ?? otherName;
    final orderText = widget.conversation.orderId != null
        ? 'Order #${widget.conversation.orderId}'
        : 'Online';
    final avatarRadius = screenType == _ScreenType.mobile ? 18.0 : 20.0;
    const callIconSize = 24.0;

    return Container(
      padding: EdgeInsets.fromLTRB(screenType != _ScreenType.desktop ? 4 : 16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        top: screenType != _ScreenType.desktop,
        child: Row(
          children: [
            if (screenType != _ScreenType.desktop)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (widget.isPushedRoute && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.read<BuyerChatBloc>().add(SelectBuyerConversation(''));
                  }
                },
              ),
            if (screenType == _ScreenType.desktop)
              const SizedBox(width: 8),
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: const Color(0xFFDBEAFE),
              backgroundImage: widget.conversation.sellerImageUrl != null &&
                      widget.conversation.sellerImageUrl!.isNotEmpty
                  ? NetworkImage(widget.conversation.sellerImageUrl!)
                  : null,
              child: widget.conversation.sellerImageUrl == null ||
                      widget.conversation.sellerImageUrl!.isEmpty
                  ? Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: avatarRadius * 0.8,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orderText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone_outlined, size: callIconSize),
              color: const Color(0xFF64748B),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.videocam_outlined, size: callIconSize),
              color: const Color(0xFF64748B),
              onPressed: () {},
            ),
            if (screenType != _ScreenType.mobile)
              IconButton(
                icon: const Icon(Icons.more_vert, size: callIconSize),
                color: const Color(0xFF64748B),
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(_ScreenType screenType) {
    final isMobile = screenType == _ScreenType.mobile;

    return Container(
      color: const Color(0xFFF0F2F5),
      // Increased bottom padding on mobile to clear the CurvedNavigationBar bump
      padding: EdgeInsets.fromLTRB(16, 8, 16, isMobile ? 20 : 16),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                color: const Color(0xFF8696A0),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: Color(0xFF8696A0), fontSize: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file_outlined),
                color: const Color(0xFF8696A0),
                onPressed: () {},
              ),
              if (!isMobile)
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  color: const Color(0xFF8696A0),
                  onPressed: () {},
                ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: hasText ? const Color(0xFF00A884) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        hasText ? Icons.send : Icons.mic_outlined,
                        color: hasText ? Colors.white : const Color(0xFF8696A0),
                        size: 22,
                      ),
                      onPressed: widget.isSending ? null : (hasText ? _sendMessage : () {}),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _BuyerChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _BuyerChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);
    final maxWidthFactor = switch (screenType) {
      _ScreenType.mobile => 0.85,
      _ScreenType.tablet => 0.75,
      _ScreenType.desktop => 0.65,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
          ),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 0),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFF111B21),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: const TextStyle(
                        color: Color(0xFF667781),
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all,
                        size: 16,
                        color: Color(0xFF53BDEB),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSeparatorChip extends StatelessWidget {
  final DateTime dateTime;

  const _DateSeparatorChip({required this.dateTime});

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dateTime);
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECF0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _formatDate(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});
  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEF2F7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.10 : 0.05),
              blurRadius: _isHovered ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _PremiumOrderContextCard extends StatelessWidget {
  final ConversationModel conversation;
  const _PremiumOrderContextCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    if (conversation.orderId == null) return const SizedBox.shrink();
    final orderRepo = context.read<IOrderRepository>();

    return FutureBuilder<OrderModel?>(
      future: orderRepo.getOrderById(conversation.orderId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final order = snapshot.data;
        if (order == null) return const SizedBox.shrink();

        final item = order.items?.isNotEmpty == true
            ? order.items!.first
            : null;

        return _HoverCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: item?.imageUrl != null
                          ? Image.network(item!.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.fastfood, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.name ?? 'Multiple Items',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text('4.8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B))),
                            const SizedBox(width: 8),
                            const Text('🌱', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            const Text('Veg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF22C55E))),
                            const SizedBox(width: 8),
                            Text('Qty ${item?.quantity ?? 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${order.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEF2A39)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOrderStatusChip(order.status.name),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 3.2 : 2.8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildMiniCard(Icons.receipt_long, 'Order ID', '#${order.id.toUpperCase().substring(0, 8)}'),
                      _buildMiniCard(Icons.account_balance_wallet, 'Payment', order.paymentMethod ?? 'Wallet'),
                      _buildMiniCard(Icons.local_shipping, 'Delivery', 'Standard'),
                      _buildMiniCard(Icons.calendar_today, 'Date', DateFormat('MMM dd').format(order.timestamp)),
                      _buildMiniCard(Icons.storefront, 'Seller', conversation.shopName ?? 'Store'),
                      _buildMiniCard(Icons.inventory_2, 'Items', '${order.items?.length ?? 1} Item'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildOrderTimeline(order.status),
              const SizedBox(height: 20),
              _buildOrderSummaryCard(order),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionChip(Icons.star_rounded, 'Rate', const Color(0xFFF59E0B), isOutlined: true, onTap: () {
                    if (item != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RatingPageUI(foodId: item.productId, foodName: item.name)));
                    }
                  }),
                  _buildActionChip(Icons.receipt_long_outlined, 'Invoice', const Color(0xFF2563EB), isOutlined: true, onTap: () {}),
                  _buildActionChip(Icons.local_shipping_rounded, 'Track', const Color(0xFF2563EB), isOutlined: true, onTap: () {
                    if (order == null) return;
                    final orderViewModel = OrderViewModel(
                      id: order.id, status: order.status.name, totalAmount: order.amount, date: order.timestamp,
                      items: order.items?.map((i) => CartItem(id: i.productId, name: i.name, price: i.price,
                          sellerId: order.sellerId, image: i.imageUrl, quantity: i.quantity)).toList() ?? [],
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderPageUI(orderId: order.id, order: orderViewModel, isEmbedded: false, allowPopOnDesktop: false)));
                  }),
                  _buildActionChip(Icons.shopping_cart_rounded, 'Buy Again', const Color(0xFFEF2A39), isGradient: true, onTap: () {
                    if (item != null) {
                      context.read<CartBloc>().add(CartItemAdded(CartItem(id: item.productId, name: item.name, price: item.price,
                          sellerId: conversation.sellerId, image: item.imageUrl)));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPageUI()));
                    }
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniCard(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F6FC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color bgColor;
    String label;
    switch (status.toLowerCase()) {
      case 'neworder':
      case 'new_order':
      case 'new':
        bgColor = const Color(0xFF3B82F6); label = 'New'; break;
      case 'delivered':
        bgColor = const Color(0xFF22C55E); label = 'Delivered'; break;
      case 'preparing':
        bgColor = const Color(0xFFF59E0B); label = 'Preparing'; break;
      case 'outfordelivery':
        bgColor = const Color(0xFF2563EB); label = 'Out for Delivery'; break;
      case 'accepted':
        bgColor = const Color(0xFF22C55E); label = 'Accepted'; break;
      case 'cancelled':
        bgColor = const Color(0xFFEF4444); label = 'Cancelled'; break;
      default:
        bgColor = const Color(0xFF6B7280); label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: bgColor)),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(OrderStatus currentStatus) {
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

    final stepsData = [
      {'title': 'Order Confirmed', 'index': 0},
      {'title': 'Preparing Your Food', 'index': 2},
      {'title': 'Out for Delivery', 'index': 3},
      {'title': 'Delivered', 'index': 4},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 24),
          ...stepsData.asMap().entries.map((entry) {
            int idx = entry.key;
            var step = entry.value;
            int stepLevel = step['index'] as int;
            bool isLast = idx == stepsData.length - 1;

            bool isCompleted = !isCancelled && currentIdx > stepLevel;
            bool isCurrent = !isCancelled && currentIdx == stepLevel;
            
            // If order is Accepted (1), show Preparing (2) as current to indicate progress
            if (currentIdx == 1 && stepLevel == 2) {
              isCurrent = true;
            }
            
            bool isFuture = !isCancelled && currentIdx < stepLevel && !(currentIdx == 1 && stepLevel == 2);
            if (isCancelled) isFuture = true;

            return _buildVerticalTimelineNode(
              title: step['title'] as String,
              isLast: isLast,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isFuture: isFuture,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVerticalTimelineNode({
    required String title,
    required bool isLast,
    required bool isCompleted,
    required bool isCurrent,
    required bool isFuture,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildVerticalStatusIcon(isCompleted, isCurrent, isFuture),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isFuture
                          ? Colors.grey.shade400
                          : const Color(0xFF1C1C1C),
                    ),
                  ),
                  if (isCurrent)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'In progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalStatusIcon(bool isCompleted, bool isCurrent, bool isFuture) {
    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0xFF22C55E), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    } else if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 14),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    final subtotal = order.items?.fold(0.0, (sum, item) => sum + item.price * item.quantity) ?? order.amount;
    final total = order.amount;
    final delivery = total >= subtotal ? 0.0 : (total - subtotal).abs().clamp(0, 50);
    final taxes = (total - subtotal - delivery).abs();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', false),
          const SizedBox(height: 6),
          _summaryRow('Delivery', delivery == 0 ? 'FREE' : '₹${delivery.toStringAsFixed(2)}', delivery == 0),
          const SizedBox(height: 6),
          _summaryRow('Taxes', '₹${taxes.toStringAsFixed(2)}', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _summaryRow('Total', '₹${total.toStringAsFixed(2)}', false, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isFree, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF64748B))),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 18 : 13,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          color: isFree ? const Color(0xFF22C55E) : (isTotal ? const Color(0xFF1C1C1C) : const Color(0xFF1C1C1C)),
        )),
      ],
    );
  }

  Widget _buildActionChip(
    IconData icon,
    String label,
    Color color, {
    bool isOutlined = false,
    bool isFilled = false,
    bool isGradient = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isGradient ? null : (isFilled ? color.withOpacity(0.1) : Colors.transparent),
          gradient: isGradient
              ? const LinearGradient(colors: [Color(0xFFEF2A39), Color(0xFFDC2626)])
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isOutlined ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          boxShadow: isGradient
              ? [BoxShadow(color: const Color(0xFFEF2A39).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isGradient ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isGradient ? Colors.white : (isFilled || !isOutlined ? color : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
