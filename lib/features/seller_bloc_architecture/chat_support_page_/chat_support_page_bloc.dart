import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_support_page_event.dart';
import 'chat_support_page_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';

class _ConversationsUpdated extends ChatSupportEvent {
  final List<ConversationModel> conversations;
  _ConversationsUpdated(this.conversations);
}

class _MessagesUpdated extends ChatSupportEvent {
  final String conversationId;
  final List<ChatMessageModel> messages;
  _MessagesUpdated(this.conversationId, this.messages);
}

class _ConversationsError extends ChatSupportEvent {
  final String error;
  _ConversationsError(this.error);
}

class _MessagesError extends ChatSupportEvent {
  final String error;
  _MessagesError(this.error);
}

class ChatSupportBloc extends Bloc<ChatSupportEvent, ChatSupportState> {
  final IChatRepository repository;
  String? _sellerId;
  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;

  ChatSupportBloc({required this.repository}) : super(ChatSupportInitial()) {
    on<LoadChatSessionsEvent>(_onLoadChatSessions);
    on<SelectChatSessionEvent>(_onSelectChatSession);
    on<SendMessageEvent>(_onSendMessage);
    on<FilterChatSessions>(_onFilterChatSessions);
    on<_ConversationsUpdated>(_onConversationsUpdated);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<_ConversationsError>(_onConversationsError);
    on<_MessagesError>(_onMessagesError);
  }

  void _onLoadChatSessions(
      LoadChatSessionsEvent event, Emitter<ChatSupportState> emit) {
    _sellerId = event.sellerId;
    _messagesSub?.cancel();
    emit(ChatSupportLoading());

    _conversationsSub?.cancel();
    _conversationsSub = repository
        .getConversationsForUser(event.sellerId, isSeller: true)
        .listen((conversations) {
      if (!isClosed) add(_ConversationsUpdated(conversations));
    }, onError: (error) {
      if (!isClosed) add(_ConversationsError('$error'));
    });
  }

  void _onConversationsUpdated(
      _ConversationsUpdated event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is ChatSupportLoaded) {
      emit(current.copyWith(conversations: event.conversations));
    } else {
      emit(ChatSupportLoaded(
        currentUserId: _sellerId ?? '',
        conversations: event.conversations,
      ));
    }
  }

  void _onConversationsError(
      _ConversationsError event, Emitter<ChatSupportState> emit) {
    emit(ChatSupportError('Failed to load conversations: ${event.error}'));
  }

  void _onFilterChatSessions(
      FilterChatSessions event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(searchQuery: event.query));
  }

  void _onSelectChatSession(
      SelectChatSessionEvent event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded || current.currentUserId.isEmpty) return;

    _messagesSub?.cancel();

    if (event.conversationId.isEmpty) {
      emit(current.copyWith(
        selectedConversationId: null,
        messages: [],
      ));
      return;
    }

    repository.markConversationRead(event.conversationId, current.currentUserId, true);

    emit(current.copyWith(
      selectedConversationId: event.conversationId,
      messages: [],
    ));

    _messagesSub = repository
        .getMessagesStream(event.conversationId)
        .listen((messages) {
      if (!isClosed) {
        add(_MessagesUpdated(event.conversationId, messages));
      }
    }, onError: (error) {
      if (!isClosed) add(_MessagesError('$error'));
    });
  }

  void _onMessagesUpdated(
      _MessagesUpdated event, Emitter<ChatSupportState> emit) {
    final s = state;
    if (s is! ChatSupportLoaded) return;
    if (event.conversationId != s.selectedConversationId) return;
    emit(s.copyWith(messages: event.messages));
  }

  void _onMessagesError(
      _MessagesError event, Emitter<ChatSupportState> emit) {
    final s = state;
    if (s is! ChatSupportLoaded) return;
    emit(s.copyWith(
      isSendingMessage: false,
      errorMessage: 'Failed to load messages: ${event.error}',
    ));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatSupportState> emit) async {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    if (current.currentUserId.isEmpty) return;
    if (event.text.trim().isEmpty) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      await repository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: current.currentUserId,
        senderRole: 'seller',
      );
      emit(current.copyWith(isSendingMessage: false));
    } catch (e) {
      emit(current.copyWith(
        isSendingMessage: false,
        errorMessage: 'Failed to send message. Please try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    return super.close();
  }
}
