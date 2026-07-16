import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'chat_support_page_bloc.dart';
import 'chat_support_page_event.dart';
import 'chat_support_page_state.dart';
import 'chat_support_page_repository.dart';
import 'chat_support_page_service.dart';
import 'chat_support_page_model.dart';

class ChatSupportPage extends StatelessWidget {
  final String sellerId;
  const ChatSupportPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatSupportBloc(
        repository: ChatSupportRepository(service: ChatSupportService()),
      )..add(LoadChatSessionsEvent(sellerId)),
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
            SnackBar(content: Text(state.errorMessage!), backgroundColor: const Color(0xFFE52929)),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatSupportLoading || state is ChatSupportInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
          );
        } else if (state is ChatSupportError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929)))),
          );
        } else if (state is ChatSupportLoaded) {
          // If a session is selected, show the chat details. Otherwise, show the list.
          if (state.selectedSessionId != null && state.selectedSession != null) {
            return _ChatDetailsView(session: state.selectedSession!, isSending: state.isSendingMessage);
          }
          return _ChatListView(sessions: state.activeSessions);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ChatListView extends StatelessWidget {
  final List<ChatSessionModel> sessions;
  const _ChatListView({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Customer Support',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Contact admin support or customers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                            color: const Color(0xFF111827),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: sessions.isEmpty
                          ? const Center(
                              child: Text(
                                'No active customer chats.',
                                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: sessions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final session = sessions[index];
                                final lastMessage = session.messages.isNotEmpty ? session.messages.last : null;
                                
                                return InkWell(
                                  onTap: () {
                                    context.read<ChatSupportBloc>().add(SelectChatSessionEvent(session.sessionId));
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(0xFFDBEAFE),
                                          child: Text(
                                            session.customerName.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    session.customerName,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  if (lastMessage != null)
                                                    Text(
                                                      DateFormat('hh:mm a').format(lastMessage.timestamp),
                                                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      lastMessage?.text ?? 'No messages yet.',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: session.unreadCount > 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                                        fontWeight: session.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  if (session.unreadCount > 0)
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEF4444),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        '${session.unreadCount}',
                                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
}

class _ChatDetailsView extends StatefulWidget {
  final ChatSessionModel session;
  final bool isSending;

  const _ChatDetailsView({required this.session, required this.isSending});

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
  void didUpdateWidget(covariant _ChatDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.messages.length > oldWidget.session.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.session.customerName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order ${widget.session.orderId}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<ChatSupportBloc>().add(SelectChatSessionEvent(''));
                            },
                            color: const Color(0xFF111827),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: widget.session.messages.length,
                        itemBuilder: (context, index) {
                          final msg = widget.session.messages[index];
                          final isMe = msg.senderId == 'seller';
                          return _ChatBubble(message: msg, isMe: isMe);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FloatingActionButton(
                              mini: true,
                              elevation: 0,
                              backgroundColor: const Color(0xFF3B82F6),
                              onPressed: widget.isSending
                                  ? null
                                  : () {
                                      if (_textController.text.trim().isNotEmpty) {
                                        context.read<ChatSupportBloc>().add(
                                              SendMessageEvent(widget.session.sessionId, _textController.text),
                                            );
                                        _textController.clear();
                                      }
                                    },
                              child: widget.isSending
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
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
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
