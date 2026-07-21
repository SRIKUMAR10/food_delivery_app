import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/custom_camera_page.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'audio_widgets.dart';
import 'video_call_page.dart';
import '../Rating_page/Rating_page_ui.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';
import '../Cart Page/cart_page_Bloc.dart';
import '../Order Page/order_view_model.dart';
import '../Cart Page/cart_models.dart';
import '../Cart Page/cart_page_UI.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';

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
    final bool isPushedRoute =
        pendingOrderData != null || (orderId != null && sellerId != null);
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
            backgroundColor: const Color(0xFFFBF5F5),
            body: Center(
              child: CircularProgressIndicator(color: const Color(0xFFE52121)),
            ),
          );
        } else if (state is BuyerChatError) {
          return Scaffold(
            backgroundColor: const Color(0xFFFBF5F5),
            body: Center(
              child: state.message == 'User not logged in'
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE52121,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              size: 40,
                              color: Color(0xFFE52121),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Support Chat',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Please log in to access support',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FoodGoLoginScreenUI(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Log In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE52121),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: const Color(0xFFE52929),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: Color(0xFFE52929),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        } else if (state is BuyerChatLoaded) {
          final screenType = _screenType(context);
          final isDesktop = screenType == _ScreenType.desktop;

          if (isDesktop) {
            return Scaffold(
              backgroundColor: const Color(0xFFFBF5F5),
              body: Row(
                children: [
                  SizedBox(
                    width: 380,
                    child: _BuyerChatListView(
                      conversations: state.filteredConversations,
                      currentUserId: state.currentUserId,
                      searchQuery: state.searchQuery,
                      embedded: true,
                      selectedConversationId: state.selectedConversationId,
                    ),
                  ),
                  Container(width: 1, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child:
                        state.selectedConversationId != null &&
                            state.selectedConversation != null
                        ? _ChatPanel(
                            conversation: state.selectedConversation!,
                            messages: state.messages,
                            isSending: state.isSendingMessage,
                            isPushedRoute: isPushedRoute,
                          )
                        : _EmptyChatPlaceholder(),
                  ),
                ],
              ),
            );
          }

          if (state.selectedConversationId != null &&
              state.selectedConversation != null) {
            return Scaffold(
              backgroundColor: const Color(0xFFFBF5F5),
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
            selectedConversationId: state.selectedConversationId,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBF5F5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE52121).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: Color(0xFFE52121),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a chat from the left panel',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
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

class _BuyerChatListView extends StatefulWidget {
  final List<ConversationModel> conversations;
  final String currentUserId;
  final String searchQuery;
  final bool embedded;
  final String? selectedConversationId;

  const _BuyerChatListView({
    required this.conversations,
    required this.currentUserId,
    required this.searchQuery,
    this.embedded = false,
    this.selectedConversationId,
  });

  @override
  State<_BuyerChatListView> createState() => _BuyerChatListViewState();
}

class _BuyerChatListViewState extends State<_BuyerChatListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(covariant _BuyerChatListView oldWidget) {
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
    Widget bodyContent = Column(
      children: [
        _PremiumSearchBar(controller: _searchController),
        Expanded(
          child: widget.conversations.isEmpty
              ? _EmptyConversationsState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = widget.conversations[index];
                    final isSelected =
                        conversation.id == widget.selectedConversationId;
                    return _ConversationTile(
                      conversation: conversation,
                      currentUserId: widget.currentUserId,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<BuyerChatBloc>().add(
                          SelectBuyerConversation(conversation.id),
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
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE52121).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFFE52121),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support Chat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.conversations.length} conversations',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: bodyContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      appBar: AppBar(title: const Text('Support Chat'), centerTitle: true),
      body: bodyContent,
    );
  }
}

class _PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _PremiumSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: controller,
        onChanged: (query) {
          context.read<BuyerChatBloc>().add(FilterBuyerConversations(query));
        },
        decoration: InputDecoration(
          hintText: 'Search by order ID or restaurant...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F3F5),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFFE52121), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _EmptyConversationsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE52121).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 28,
              color: Color(0xFFE52121),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start chatting with a restaurant',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final unread = conversation.unreadCountForUser(widget.currentUserId);
    final displayName =
        conversation.shopName ??
        conversation.otherParticipantName(widget.currentUserId);
    final hasImage =
        conversation.sellerImageUrl != null &&
        conversation.sellerImageUrl!.isNotEmpty;
    final lastMessageTimestamp = conversation.lastMessageTimestamp;

    String timeText = '';
    if (lastMessageTimestamp != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDate = DateTime(
        lastMessageTimestamp.year,
        lastMessageTimestamp.month,
        lastMessageTimestamp.day,
      );
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
                ? const Color(0xFFE52121).withValues(alpha: 0.08)
                : (_isHovered ? const Color(0xFFF5F5F5) : Colors.transparent),
            border: Border(
              left: BorderSide(
                color: widget.isSelected
                    ? const Color(0xFFE52121)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasImage
                          ? Colors.transparent
                          : const Color(0xFFF1F3F5),
                      border: Border.all(
                        color: widget.isSelected
                            ? const Color(0xFFE52121).withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              conversation.sellerImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _AvatarFallback(name: displayName),
                            ),
                          )
                        : _AvatarFallback(name: displayName),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE52121),
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
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: const Color(0xFF1C1C1C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessageTimestamp != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 11,
                                color: unread > 0
                                    ? const Color(0xFFE52121)
                                    : const Color(0xFF94A3B8),
                                fontWeight: unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
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
                            conversation.lastMessage ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: unread > 0
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF94A3B8),
                              fontWeight: unread > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (conversation.orderId != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
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

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3F5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
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

  @override
  void didUpdateWidget(covariant _ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
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

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMessage(widget.conversation.id, _textController.text),
      );
      _textController.clear();
    }
  }

  List<Widget> _buildChatItems(_ScreenType screenType) {
    final items = <Widget>[];
    String? lastDateKey;

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _PremiumOrderContextCard(conversation: widget.conversation),
      ),
    );

    for (final msg in widget.messages) {
      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      if (dateKey != lastDateKey) {
        items.add(_DateSeparatorChip(dateTime: msg.timestamp));
        lastDateKey = dateKey;
      }
      items.add(
        _AnimatedMessage(
          index: items.length,
          child: _BuyerChatBubble(
            message: msg,
            isMe: msg.senderRole == 'buyer',
          ),
        ),
      );
    }

    return items;
  }

  void _handleAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMediaMessage(
          conversationId: widget.conversation.id,
          file: kIsWeb ? await pickedFile.readAsBytes() : File(pickedFile.path),
          messageType: 'image',
          fileName: pickedFile.name,
        ),
      );
    }
  }

  void _handleEmojiToggle(bool show) {
    context.read<BuyerChatBloc>().add(ToggleEmojiPicker(show));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _PremiumChatHeader(
            conversation: widget.conversation,
            screenType: screenType,
            isPushedRoute: widget.isPushedRoute,
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFFBF5F5),
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.all(
                  screenType == _ScreenType.mobile ? 12 : 20,
                ),
                children: _buildChatItems(screenType),
              ),
            ),
          ),
          _PremiumComposer(
            controller: _textController,
            isSending: widget.isSending,
            screenType: screenType,
            onSend: _sendMessage,
            onAttach: _handleAttachment,
            onEmoji: () {
              final showEmoji =
                  context.read<BuyerChatBloc>().state is BuyerChatLoaded
                  ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                        .showEmojiPicker
                  : false;
              _handleEmojiToggle(!showEmoji);
            },
          ),
          BlocBuilder<BuyerChatBloc, BuyerChatState>(
            builder: (context, state) {
              if (state is BuyerChatLoaded && state.showEmojiPicker) {
                return SizedBox(
                  height: 250,
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
    );
  }
}

class _PremiumChatHeader extends StatelessWidget {
  final ConversationModel conversation;
  final _ScreenType screenType;
  final bool isPushedRoute;

  const _PremiumChatHeader({
    required this.conversation,
    required this.screenType,
    required this.isPushedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.read<BuyerChatBloc>().authService.currentUserId ?? '';
    final otherName = conversation.otherParticipantName(currentUserId);
    final displayName = conversation.shopName ?? otherName;
    final hasImage =
        conversation.sellerImageUrl != null &&
        conversation.sellerImageUrl!.isNotEmpty;
    final orderText = conversation.orderId != null
        ? 'Order #${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        top: screenType != _ScreenType.desktop,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenType == _ScreenType.desktop ? 16 : 4,
            8,
            16,
            8,
          ),
          child: Row(
            children: [
              if (screenType != _ScreenType.desktop)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    if (isPushedRoute && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.read<BuyerChatBloc>().add(
                        SelectBuyerConversation(''),
                      );
                    }
                  },
                ),
              if (screenType == _ScreenType.desktop) const SizedBox(width: 4),
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasImage
                          ? Colors.transparent
                          : const Color(0xFFF1F3F5),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              conversation.sellerImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _AvatarFallback(name: displayName),
                            ),
                          )
                        : _AvatarFallback(name: displayName),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1C),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (orderText != null) ...[
                          Text(
                            orderText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _OrderStatusBadge(conversation: conversation),
                      ],
                    ),
                  ],
                ),
              ),
              _CircularIconButton(
                icon: Icons.phone_outlined,
                onPressed: () {
                  const String dummyPhone = '+1234567890';
                  if (kIsWeb) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Phone: $dummyPhone',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(
                                  const ClipboardData(text: dummyPhone),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard!'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 5),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    final Uri url = Uri(scheme: 'tel', path: dummyPhone);
                    canLaunchUrl(url).then((canLaunch) {
                      if (canLaunch) {
                        launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not launch phone dialer'),
                          ),
                        );
                      }
                    });
                  }
                },
              ),
              const SizedBox(width: 4),
              _CircularIconButton(
                icon: Icons.videocam_outlined,
                onPressed: () {
                  final bloc = context.read<BuyerChatBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoCallPage(
                        callID: conversation.id,
                        userID: bloc.authService.currentUserId ?? 'buyer_123',
                        userName: conversation.buyerName,
                      ),
                    ),
                  );
                },
              ),
              if (screenType != _ScreenType.mobile) ...[
                const SizedBox(width: 4),
                _CircularIconButton(
                  icon: Icons.more_vert_rounded,
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final ConversationModel conversation;
  const _OrderStatusBadge({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 10, color: Color(0xFF22C55E)),
          SizedBox(width: 4),
          Text(
            'Active',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularIconButton({required this.icon, required this.onPressed});

  @override
  State<_CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<_CircularIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered ? const Color(0xFFF1F3F5) : Colors.transparent,
        ),
        child: IconButton(
          icon: Icon(widget.icon, size: 22),
          color: const Color(0xFF64748B),
          onPressed: widget.onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }
}

class _PremiumComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final _ScreenType screenType;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onEmoji;

  const _PremiumComposer({
    required this.controller,
    required this.isSending,
    required this.screenType,
    required this.onSend,
    required this.onAttach,
    required this.onEmoji,
  });

  @override
  State<_PremiumComposer> createState() => _PremiumComposerState();
}

class _PremiumComposerState extends State<_PremiumComposer> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _audioRecorder.dispose();
    super.dispose();
  }

  void _handleCamera() async {
    try {
      // Use the custom camera page for all platforms as requested.
      final XFile? pickedFile = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomCameraPage()),
      );

      if (pickedFile != null && mounted) {
        context.read<BuyerChatBloc>().add(
          SendBuyerMediaMessage(
            conversationId:
                context.read<BuyerChatBloc>().state is BuyerChatLoaded
                ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                      .selectedConversationId!
                : '',
            file: kIsWeb
                ? await pickedFile.readAsBytes()
                : File(pickedFile.path),
            messageType: 'image',
            fileName: pickedFile.name,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to open camera.')));
      }
      print('Camera Error: $e');
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null && mounted) {
        dynamic fileData;
        if (kIsWeb) {
          try {
            print('--- AUDIO RECORDING AUDIT ---');
            print('1. Recorded File Path: $path');

            // Using XFile is the safest way to read blob URLs in Flutter Web
            // to avoid 0-byte/corrupted file uploads.
            final xFile = XFile(path);
            fileData = await xFile.readAsBytes();

            print('1. FileData bytes length: ${fileData.length}');
            if (fileData.isEmpty) {
              print('🚨 ERROR: Recorded audio is 0 bytes!');
            }
          } catch (e) {
            print('🚨 ERROR fetching web audio blob using XFile: $e');
            return;
          }
        } else {
          fileData = File(path);
        }
        context.read<BuyerChatBloc>().add(
          SendBuyerMediaMessage(
            conversationId:
                context.read<BuyerChatBloc>().state is BuyerChatLoaded
                ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                      .selectedConversationId!
                : '',
            file: fileData,
            messageType: 'audio',
            fileName: kIsWeb ? 'audio_message.webm' : 'audio_message.m4a',
          ),
        );
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.opus),
            path: '',
          );
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final path =
              '${dir.path}/audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }
        setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission denied. Please allow microphone access in your browser/device.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _ComposerIconButton(
                icon: Icons.emoji_emotions_outlined,
                onPressed: widget.onEmoji,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(
                        color: Color(0xFF8696A0),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ComposerIconButton(
                icon: Icons.attach_file_outlined,
                onPressed: widget.onAttach,
              ),
              _ComposerIconButton(
                icon: Icons.camera_alt_outlined,
                onPressed: _handleCamera,
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: hasText
                      ? const Color(0xFF00A884)
                      : (_isRecording ? Colors.red : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    hasText
                        ? Icons.send_rounded
                        : (_isRecording
                              ? Icons.stop_circle_outlined
                              : Icons.mic_outlined),
                    color: (hasText || _isRecording)
                        ? Colors.white
                        : const Color(0xFF8696A0),
                    size: 22,
                  ),
                  onPressed: widget.isSending
                      ? null
                      : (hasText ? widget.onSend : _toggleRecording),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ComposerIconButton({required this.icon, required this.onPressed});

  @override
  State<_ComposerIconButton> createState() => _ComposerIconButtonState();
}

class _ComposerIconButtonState extends State<_ComposerIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered ? const Color(0xFFF1F3F5) : Colors.transparent,
        ),
        child: IconButton(
          icon: Icon(widget.icon, size: 22),
          color: const Color(0xFF8696A0),
          onPressed: widget.onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedMessage({required this.index, required this.child});

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
          ),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF00A884) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.messageType == 'image' && message.mediaUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.mediaUrl!,
                        width: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else if (message.messageType == 'audio' &&
                    message.mediaUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: AudioPlayerWidget(
                      key: ValueKey(message.mediaUrl),
                      audioUrl: message.mediaUrl!,
                    ),
                  )
                else if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF111B21),
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : const Color(0xFF667781),
                        fontSize: 10.5,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead
                            ? const Color(0xFF53BDEB)
                            : Colors.white70,
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
      padding: const EdgeInsets.symmetric(vertical: 14),
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
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEF2F7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.10 : 0.05),
              blurRadius: _isHovered ? 28 : 14,
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
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFE52121),
              ),
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
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: item?.imageUrl != null
                          ? Image.network(item!.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFFF1F3F5),
                              child: const Icon(
                                Icons.fastfood_rounded,
                                size: 36,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.name ?? 'Multiple Items',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _VegBadge(),
                            const SizedBox(width: 12),
                            Text(
                              'Qty ${item?.quantity ?? 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${order.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE52121),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOrderStatusChip(order.status.name),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 3.5 : 3.0,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _InfoGridItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Order ID',
                        value: '#${order.id.toUpperCase().substring(0, 8)}',
                      ),
                      _InfoGridItem(
                        icon: Icons.storefront_rounded,
                        label: 'Seller',
                        value: conversation.shopName ?? 'Store',
                      ),
                      _InfoGridItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Payment',
                        value: order.paymentMethod ?? 'Wallet',
                      ),
                      _InfoGridItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Items',
                        value: '${order.items?.length ?? 1} Item',
                      ),
                      _InfoGridItem(
                        icon: Icons.local_shipping_rounded,
                        label: 'Delivery',
                        value: 'Standard',
                      ),
                      _InfoGridItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Date',
                        value: DateFormat(
                          'MMM dd, yyyy',
                        ).format(order.timestamp),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _OrderTimelineWithAnimation(currentStatus: order.status),
              const SizedBox(height: 24),
              _buildOrderSummaryCard(order),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionButton(
                    icon: Icons.star_rounded,
                    label: 'Rate',
                    color: const Color(0xFFF59E0B),
                    isOutlined: true,
                    onTap: () {
                      if (item != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingPageUI(
                              foodId: item.productId,
                              foodName: item.name,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _ActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Invoice',
                    color: const Color(0xFF2563EB),
                    isOutlined: true,
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.local_shipping_rounded,
                    label: 'Track',
                    color: const Color(0xFF2563EB),
                    isOutlined: true,
                    onTap: () {
                      final orderViewModel = OrderViewModel(
                        id: order.id,
                        status: order.status.name,
                        totalAmount: order.amount,
                        date: order.timestamp,
                        items:
                            order.items
                                ?.map(
                                  (i) => CartItem(
                                    id: i.productId,
                                    name: i.name,
                                    price: i.price,
                                    sellerId: order.sellerId,
                                    image: i.imageUrl,
                                    quantity: i.quantity,
                                  ),
                                )
                                .toList() ??
                            [],
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
                  ),
                  _ActionButton(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Buy Again',
                    color: const Color(0xFFE52121),
                    isGradient: true,
                    onTap: () {
                      if (item != null) {
                        context.read<CartBloc>().add(
                          CartItemAdded(
                            CartItem(
                              id: item.productId,
                              name: item.name,
                              price: item.price,
                              sellerId: conversation.sellerId,
                              image: item.imageUrl,
                            ),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPageUI()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color bgColor;
    String label;
    switch (status.toLowerCase()) {
      case 'neworder':
      case 'new_order':
      case 'new':
        bgColor = const Color(0xFF3B82F6);
        label = 'New';
        break;
      case 'delivered':
        bgColor = const Color(0xFF22C55E);
        label = 'Delivered';
        break;
      case 'preparing':
        bgColor = const Color(0xFFF59E0B);
        label = 'Preparing';
        break;
      case 'outfordelivery':
        bgColor = const Color(0xFF2563EB);
        label = 'Out for Delivery';
        break;
      case 'accepted':
        bgColor = const Color(0xFF22C55E);
        label = 'Accepted';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFEF4444);
        label = 'Cancelled';
        break;
      default:
        bgColor = const Color(0xFF6B7280);
        label = status;
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
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    final subtotal =
        order.items?.fold(
          0.0,
          (sum, item) => sum + item.price * item.quantity,
        ) ??
        order.amount;
    final total = order.amount;
    final delivery = total >= subtotal
        ? 0.0
        : (total - subtotal).abs().clamp(0, 50);
    final taxes = (total - subtotal - delivery).abs();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', false),
          const SizedBox(height: 8),
          _summaryRow(
            'Delivery',
            delivery == 0 ? 'FREE' : '₹${delivery.toStringAsFixed(2)}',
            delivery == 0,
          ),
          const SizedBox(height: 8),
          _summaryRow('Taxes', '₹${taxes.toStringAsFixed(2)}', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _summaryRow(
            'Total',
            '₹${total.toStringAsFixed(2)}',
            false,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isFree, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isFree
                ? const Color(0xFF22C55E)
                : (isTotal ? const Color(0xFF1C1C1C) : const Color(0xFF1C1C1C)),
          ),
        ),
      ],
    );
  }
}

class _VegBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _InfoGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoGridItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE52121).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFE52121)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final bool isGradient;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isOutlined = false,
    this.isGradient = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isGradient
              ? null
              : (isOutlined
                    ? Colors.transparent
                    : color.withValues(alpha: 0.1)),
          gradient: isGradient
              ? const LinearGradient(
                  colors: [Color(0xFFE52121), Color(0xFFDC2626)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isOutlined
              ? Border.all(color: const Color(0xFFE5E7EB))
              : null,
          boxShadow: isGradient
              ? [
                  BoxShadow(
                    color: const Color(0xFFE52121).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isGradient
                    ? Colors.white
                    : (isOutlined ? const Color(0xFF475569) : color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTimelineWithAnimation extends StatefulWidget {
  final OrderStatus currentStatus;
  const _OrderTimelineWithAnimation({required this.currentStatus});

  @override
  State<_OrderTimelineWithAnimation> createState() =>
      _OrderTimelineWithAnimationState();
}

class _OrderTimelineWithAnimationState
    extends State<_OrderTimelineWithAnimation>
    with TickerProviderStateMixin {
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
    return _buildTimeline(widget.currentStatus);
  }

  Widget _buildTimeline(OrderStatus currentStatus) {
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
      {'title': 'Order Confirmed', 'index': 0, 'time': '12:30 PM'},
      {'title': 'Preparing Your Food', 'index': 2, 'time': '12:45 PM'},
      {'title': 'Out for Delivery', 'index': 3, 'time': '01:15 PM'},
      {'title': 'Delivered', 'index': 4, 'time': '01:45 PM'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tracking Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const Spacer(),
              if (currentIdx >= 0 && !isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. ${stepsData.last['time']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              return Column(
                children: stepsData.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var step = entry.value;
                  int stepLevel = step['index'] as int;
                  String stepTime = step['time'] as String;
                  bool isLast = idx == stepsData.length - 1;

                  bool isCompleted = !isCancelled && currentIdx > stepLevel;
                  bool isCurrent = !isCancelled && currentIdx == stepLevel;

                  if (currentIdx == 1 && stepLevel == 2) {
                    isCurrent = true;
                  }

                  bool isFuture =
                      !isCancelled &&
                      currentIdx < stepLevel &&
                      !(currentIdx == 1 && stepLevel == 2);
                  if (isCancelled) isFuture = true;

                  final animatedOpacity = isCompleted
                      ? 1.0
                      : (isCurrent
                            ? _progressController.value * 0.8 + 0.2
                            : 0.3);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
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
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: 2.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isCompleted
                                            ? [
                                                const Color(0xFF22C55E),
                                                const Color(0xFF22C55E),
                                              ]
                                            : isCurrent
                                            ? [
                                                const Color(0xFF22C55E),
                                                const Color(0xFFD1D5DB),
                                              ]
                                            : [
                                                const Color(0xFFD1D5DB),
                                                const Color(0xFFD1D5DB),
                                              ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28.0),
                            child: Opacity(
                              opacity: animatedOpacity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isFuture
                                              ? Colors.grey.shade400
                                              : const Color(0xFF1C1C1C),
                                        ),
                                      ),
                                      if (!isFuture)
                                        Text(
                                          stepTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isCompleted
                                                ? const Color(0xFF22C55E)
                                                : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isCurrent)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'In progress',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF22C55E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          _PulsatingDot(
                                            size: 5,
                                            color: const Color(0xFF22C55E),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    } else if (isCurrent) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseAnimation.value,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }
}

class _PulsatingDot extends StatefulWidget {
  final double size;
  final Color color;

  const _PulsatingDot({required this.size, required this.color});

  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
