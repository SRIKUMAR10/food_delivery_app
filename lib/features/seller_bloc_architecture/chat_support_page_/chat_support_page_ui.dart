import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'chat_support_page_bloc.dart';
import 'chat_support_page_event.dart';
import 'chat_support_page_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';

class ChatSupportPage extends StatelessWidget {
  final String sellerId;
  const ChatSupportPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatSupportBloc(repository: context.read<IChatRepository>())
            ..add(LoadChatSessionsEvent(sellerId)),
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
              backgroundColor: const Color(0xFFE52929),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatSupportLoading || state is ChatSupportInitial) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            ),
          );
        } else if (state is ChatSupportError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Color(0xFFE52929)),
              ),
            ),
          );
        } else if (state is ChatSupportLoaded) {
          if (state.selectedConversationId != null &&
              state.selectedConversation != null) {
            return _ChatDetailsView(
              conversation: state.selectedConversation!,
              messages: state.messages,
              isSending: state.isSendingMessage,
            );
          }
          return _ChatListView(
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

class _ChatListView extends StatefulWidget {
  final List<ConversationModel> conversations;
  final String currentUserId;
  final String searchQuery;

  const _ChatListView({
    required this.conversations,
    required this.currentUserId,
    required this.searchQuery,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Support Chat',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1C1C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.conversations.length} conversations',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () => Navigator.pop(context),
                                color: const Color(0xFF1C1C1C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSearchBar(context),
                        ],
                      ),
                    ),
                    Expanded(
                      child: widget.conversations.isEmpty
                          ? _EmptySellerConversations()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: widget.conversations.length,
                              itemBuilder: (context, index) {
                                final conversation = widget.conversations[index];
                                return _SellerConversationTile(
                                  conversation: conversation,
                                  currentUserId: widget.currentUserId,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        context.read<ChatSupportBloc>().add(FilterChatSessions(query));
      },
      decoration: InputDecoration(
        hintText: 'Search by order ID or customer name...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
        ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 28, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No active customer chats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          const Text(
            'New conversations will appear here',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _SellerConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _SellerConversationTile({
    required this.conversation,
    required this.currentUserId,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFFF5F5F5)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: _isHovered ? const Color(0xFFE52121) : Colors.transparent,
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
                      color: const Color(0xFFF1F3F5),
                    ),
                    child: Center(
                      child: Text(
                        conversation.buyerName
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
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
                            conversation.buyerName,
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
                            conversation.lastMessage ?? 'No messages yet.',
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
                            horizontal: 8, vertical: 2),
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

class _ChatDetailsView extends StatefulWidget {
  final ConversationModel conversation;
  final List<ChatMessageModel> messages;
  final bool isSending;

  const _ChatDetailsView({
    required this.conversation,
    required this.messages,
    required this.isSending,
  });

  @override
  State<_ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends State<_ChatDetailsView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant _ChatDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _SellerChatHeader(
                  conversation: widget.conversation,
                  isDesktop: isDesktop,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF0F2F5),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      children: _buildChatItems(),
                    ),
                  ),
                ),
                _SellerComposer(
                  controller: _textController,
                  isSending: widget.isSending,
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
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
      final isMe = msg.senderRole == 'seller';
      items.add(_SellerChatBubble(message: msg, isMe: isMe));
    }

    return items;
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      context.read<ChatSupportBloc>().add(
        SendMessageEvent(
          widget.conversation.id,
          _textController.text,
        ),
      );
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _SellerChatHeader extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDesktop;

  const _SellerChatHeader({
    required this.conversation,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = conversation.sellerImageUrl != null &&
        conversation.sellerImageUrl!.isNotEmpty;

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
      child: Padding(
        padding: EdgeInsets.fromLTRB(isDesktop ? 20 : 4, 12, 20, 12),
        child: Row(
          children: [
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  context
                      .read<ChatSupportBloc>()
                      .add(SelectChatSessionEvent(''));
                },
                color: const Color(0xFF1C1C1C),
              ),
            if (isDesktop) const SizedBox(width: 8),
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
                        color: const Color(0xFFE5E7EB), width: 1.5),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            conversation.sellerImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _SellerAvatarFallback(
                                    name: conversation.buyerName),
                          ),
                        )
                      : _SellerAvatarFallback(
                          name: conversation.buyerName),
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
                          conversation.buyerName,
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
                  if (conversation.orderId != null)
                    Text(
                      'Order #${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            _SellerCircularIconButton(
                icon: Icons.phone_outlined, onPressed: () {}),
            const SizedBox(width: 4),
            _SellerCircularIconButton(
                icon: Icons.videocam_outlined, onPressed: () {}),
            if (isDesktop) ...[
              const SizedBox(width: 4),
              _SellerCircularIconButton(
                  icon: Icons.more_vert_rounded, onPressed: () {}),
            ],
          ],
        ),
      ),
    );
  }
}

class _SellerAvatarFallback extends StatelessWidget {
  final String name;
  const _SellerAvatarFallback({required this.name});

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

class _SellerCircularIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SellerCircularIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_SellerCircularIconButton> createState() =>
      _SellerCircularIconButtonState();
}

class _SellerCircularIconButtonState extends State<_SellerCircularIconButton> {
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
          color: _isHovered
              ? const Color(0xFFF1F3F5)
              : Colors.transparent,
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

class _SellerComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _SellerComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
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
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      color: const Color(0xFFF0F2F5),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isFocused ? 0.08 : 0.04),
                blurRadius: _isFocused ? 12 : 4,
                offset: Offset(0, _isFocused ? 3 : 1),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),
              _SellerComposerIconButton(
                  icon: Icons.emoji_emotions_outlined, onPressed: () {}),
              Expanded(
                child: Focus(
                  onFocusChange: (focused) =>
                      setState(() => _isFocused = focused),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      hintStyle:
                          TextStyle(color: Color(0xFF8696A0), fontSize: 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
              ),
              _SellerComposerIconButton(
                  icon: Icons.attach_file_outlined, onPressed: () {}),
              Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: hasText
                      ? const Color(0xFF00A884)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    hasText ? Icons.send_rounded : Icons.mic_outlined,
                    color: hasText
                        ? Colors.white
                        : const Color(0xFF8696A0),
                    size: 22,
                  ),
                  onPressed: widget.isSending
                      ? null
                      : (hasText ? widget.onSend : () {}),
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

class _SellerComposerIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SellerComposerIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_SellerComposerIconButton> createState() =>
      _SellerComposerIconButtonState();
}

class _SellerComposerIconButtonState
    extends State<_SellerComposerIconButton> {
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
          color: _isHovered
              ? const Color(0xFFF1F3F5)
              : Colors.transparent,
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

class _SellerChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _SellerChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF00A884)
                : Colors.white,
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
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : const Color(0xFF111B21),
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
                        color: isMe
                            ? Colors.white70
                            : const Color(0xFF667781),
                        fontSize: 10.5,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all
                            : Icons.done,
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
