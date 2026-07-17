import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Buyer_chat_support_bloc.dart';
import 'Buyer_chat_support_event.dart';
import 'Buyer_chat_support_state.dart';

class BuyerChatSupportPage extends StatelessWidget {
  const BuyerChatSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerChatSupportBloc()..add(const LoadChatHistory()),
      child: const BuyerChatSupportView(),
    );
  }
}

class BuyerChatSupportView extends StatefulWidget {
  const BuyerChatSupportView({super.key});

  @override
  State<BuyerChatSupportView> createState() => _BuyerChatSupportViewState();
}

class _BuyerChatSupportViewState extends State<BuyerChatSupportView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: BlocConsumer<BuyerChatSupportBloc, BuyerChatSupportState>(
        listener: (context, state) {
          if (state.status == ChatStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildMessageList(state)),
              _buildMessageComposer(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(BuyerChatSupportState state) {
    if (state.status == ChatStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ChatStatus.error) {
      return Center(child: Text(state.errorMessage ?? 'Failed to load chat.'));
    }
    if (state.messages.isEmpty) {
      return const Center(child: Text('No messages yet.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.isTyping && index == state.messages.length) {
          return const _ChatMessage(
            isUser: false,
            message: '...',
            isTyping: true,
          );
        }
        final message = state.messages[index];
        final isUser = message['sender'] == 'user';
        return _ChatMessage(isUser: isUser, message: message['text']!);
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
                onSubmitted: (value) {
                  _sendMessage();
                },
              ),
            ),
            const SizedBox(width: 12.0),
            FloatingActionButton(
              mini: true,
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      context.read<BuyerChatSupportBloc>().add(SendMessage(message));
      _messageController.clear();
    }
  }
}

class _ChatMessage extends StatelessWidget {
  final bool isUser;
  final String message;
  final bool isTyping;

  const _ChatMessage({
    required this.isUser,
    required this.message,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20.0).copyWith(
            bottomRight: isUser ? const Radius.circular(4.0) : null,
            bottomLeft: !isUser ? const Radius.circular(4.0) : null,
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
