// Real-Time BLoC Stream Binding Standardized
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

class _TypingStatusUpdated extends ChatSupportEvent {
  final Map<String, bool> typingUsers;
  const _TypingStatusUpdated(this.typingUsers);
}

class ChatSupportBloc extends Bloc<ChatSupportEvent, ChatSupportState> {
  final IChatRepository repository;
  String? _sellerId;
  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;
  Timer? _typingResetTimer;
  String? _activeTypingConversationId;

  // Initial open context (used for deep-linking from Orders List / tracking).
  String? _initialConversationId;
  String? _initialOrderId;
  String? _targetRole;
  String? _partnerId;
  String? _partnerName;
  String? _partnerPhone;
  String? _partnerImageUrl;
  String? _orderTitle;
  double? _orderTotal;
  bool _autoOpenHandled = false;

  ChatSupportBloc({required this.repository}) : super(ChatSupportInitial()) {
    on<LoadChatSessionsEvent>(_onLoadChatSessions);
    on<SelectChatSessionEvent>(_onSelectChatSession);
    on<SendMessageEvent>(_onSendMessage);
    on<FilterChatSessions>(_onFilterChatSessions);
    on<_ConversationsUpdated>(_onConversationsUpdated);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<_ConversationsError>(_onConversationsError);
    on<_MessagesError>(_onMessagesError);
    on<DeleteSupportMessageEvent>(_onDeleteMessage);
    on<SendSupportMediaMessage>(_onSendMediaMessage);
    on<ToggleSupportEmojiPicker>(_onToggleEmojiPicker);
    on<StartSupportAudioRecording>(_onStartAudioRecording);
    on<StopSupportAudioRecording>(_onStopAudioRecording);
    on<CancelSupportAudioRecording>(_onCancelAudioRecording);
    on<SetTypingStatusEvent>(_onSetTypingStatus);
    on<_TypingStatusUpdated>(_onTypingStatusUpdated);
    on<SetChatFilterTabEvent>(_onSetChatFilterTab);
    on<StartOrderDeliveryPartnerChatEvent>(_onStartOrderDeliveryPartnerChat);
    on<AutoOpenOrderConversationEvent>(_onAutoOpenOrderConversation);
  }

  void _onLoadChatSessions(
      LoadChatSessionsEvent event, Emitter<ChatSupportState> emit) {
    _sellerId = event.sellerId;
    _initialConversationId = event.initialConversationId;
    _initialOrderId = event.initialOrderId;
    _targetRole = event.targetRole;
    _partnerId = event.partnerId;
    _partnerName = event.partnerName;
    _partnerPhone = event.partnerPhone;
    _partnerImageUrl = event.partnerImageUrl;
    _orderTitle = event.orderTitle;
    _orderTotal = event.orderTotal;
    _autoOpenHandled = false;

    _messagesSub?.cancel();
    _typingSub?.cancel();
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
    final loadedState = current is ChatSupportLoaded
        ? current.copyWith(conversations: event.conversations)
        : ChatSupportLoaded(
            currentUserId: _sellerId ?? '',
            conversations: event.conversations,
            initialOrderId: _initialOrderId,
          );
    emit(loadedState);

    if (!_autoOpenHandled) {
      _autoOpenHandled = true;
      _runAutoOpen(event.conversations);
    }
  }

  void _runAutoOpen(List<ConversationModel> conversations) {
    final initialConversationId = _initialConversationId;
    if (initialConversationId != null &&
        initialConversationId.isNotEmpty &&
        conversations.any((c) => c.id == initialConversationId)) {
      add(SelectChatSessionEvent(initialConversationId));
      return;
    }

    final orderId = _initialOrderId;
    if (orderId == null || orderId.isEmpty) return;

    if (_targetRole == 'delivery_partner' &&
        _partnerId != null &&
        _partnerId!.isNotEmpty) {
      add(StartOrderDeliveryPartnerChatEvent(
        orderId: orderId,
        riderId: _partnerId!,
        riderName: _partnerName ?? 'Delivery Partner',
        riderPhone: _partnerPhone,
        riderImageUrl: _partnerImageUrl,
        orderTitle: _orderTitle,
        orderTotal: _orderTotal,
      ));
      return;
    }

    add(AutoOpenOrderConversationEvent(
      orderId: orderId,
      targetRole: _targetRole,
    ));
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

  void _onSetChatFilterTab(
      SetChatFilterTabEvent event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(activeFilterTab: event.tab));
  }

  void _onSelectChatSession(
      SelectChatSessionEvent event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded || current.currentUserId.isEmpty) return;

    _messagesSub?.cancel();
    _typingSub?.cancel();
    _activeTypingConversationId = null;
    _typingResetTimer?.cancel();

    if (event.conversationId.isEmpty) {
      emit(ChatSupportLoaded(
        currentUserId: current.currentUserId,
        conversations: current.conversations,
        activeFilterTab: current.activeFilterTab,
        initialOrderId: current.initialOrderId,
        searchQuery: current.searchQuery,
        showEmojiPicker: current.showEmojiPicker,
        isRecording: current.isRecording,
        recordingDuration: current.recordingDuration,
      ));
      return;
    }

    repository.markConversationRead(
        event.conversationId, current.currentUserId, true);

    emit(current.copyWith(
      selectedConversationId: event.conversationId,
      messages: const [],
      typingUsers: const {},
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

    _typingSub = repository
        .getTypingStatusStream(event.conversationId)
        .listen((typingUsers) {
      if (!isClosed) add(_TypingStatusUpdated(typingUsers));
    }, onError: (_) {});
  }

  void _onTypingStatusUpdated(
      _TypingStatusUpdated event, Emitter<ChatSupportState> emit) {
    final s = state;
    if (s is! ChatSupportLoaded) return;
    emit(s.copyWith(typingUsers: event.typingUsers));
  }

  void _onSetTypingStatus(
      SetTypingStatusEvent event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded || current.currentUserId.isEmpty) return;

    final conversationId = event.conversationId ??
        current.selectedConversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    _typingResetTimer?.cancel();

    if (event.isTyping) {
      _activeTypingConversationId = conversationId;
      unawaited(repository.setTypingStatus(
        conversationId: conversationId,
        userId: current.currentUserId,
        isTyping: true,
      ));
      // Auto-reset: if the seller stops typing for 3 seconds, mark as not typing.
      _typingResetTimer = Timer(const Duration(seconds: 3), () {
        final c = _activeTypingConversationId;
        if (c != null && !isClosed) {
          unawaited(repository.setTypingStatus(
            conversationId: c,
            userId: _sellerId ?? current.currentUserId,
            isTyping: false,
          ));
        }
        _activeTypingConversationId = null;
      });
    } else {
      _activeTypingConversationId = null;
      unawaited(repository.setTypingStatus(
        conversationId: conversationId,
        userId: current.currentUserId,
        isTyping: false,
      ));
    }
  }

  void _onMessagesUpdated(
      _MessagesUpdated event, Emitter<ChatSupportState> emit) {
    final s = state;
    if (s is! ChatSupportLoaded) return;
    if (event.conversationId != s.selectedConversationId) return;
    final userId = s.currentUserId;
    if (userId.isEmpty) return;
    final filteredMessages = event.messages
        .where((m) => !m.deletedBy.contains(userId))
        .toList();
    emit(s.copyWith(messages: filteredMessages));
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
      if (isClosed) return;
      final s = state;
      if (s is ChatSupportLoaded) {
        emit(s.copyWith(isSendingMessage: false));
      }
    } catch (e) {
      if (isClosed) return;
      final s = state;
      if (s is ChatSupportLoaded) {
        emit(s.copyWith(
          isSendingMessage: false,
          errorMessage: 'Failed to send message. Please try again.',
        ));
      }
    }
  }

  Future<void> _onSendMediaMessage(
      SendSupportMediaMessage event, Emitter<ChatSupportState> emit) async {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    if (current.currentUserId.isEmpty) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      final mediaUrl = await repository.uploadChatAttachment(
        event.file,
        event.conversationId,
        event.fileName,
      );

      await repository.sendMessage(
        conversationId: event.conversationId,
        text: event.fileName.isNotEmpty ? event.fileName : event.messageType,
        senderId: current.currentUserId,
        senderRole: 'seller',
        messageType: event.messageType,
        mediaUrl: mediaUrl,
        fileName: event.fileName,
        duration: event.duration,
      );
      if (isClosed) return;
      final s = state;
      if (s is ChatSupportLoaded) {
        emit(s.copyWith(isSendingMessage: false));
      }
    } catch (e) {
      if (isClosed) return;
      final s = state;
      if (s is ChatSupportLoaded) {
        emit(s.copyWith(
          isSendingMessage: false,
          errorMessage: 'Failed to send media. Please try again.',
        ));
      }
    }
  }

  void _onToggleEmojiPicker(
      ToggleSupportEmojiPicker event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(showEmojiPicker: event.show));
  }

  void _onStartAudioRecording(
      StartSupportAudioRecording event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(isRecording: true, recordingDuration: Duration.zero));
  }

  void _onStopAudioRecording(
      StopSupportAudioRecording event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(isRecording: false));
  }

  void _onCancelAudioRecording(
      CancelSupportAudioRecording event, Emitter<ChatSupportState> emit) {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    emit(current.copyWith(isRecording: false, recordingDuration: Duration.zero));
  }

  Future<void> _onStartOrderDeliveryPartnerChat(
      StartOrderDeliveryPartnerChatEvent event,
      Emitter<ChatSupportState> emit) async {
    final current = state;
    if (current is! ChatSupportLoaded || current.currentUserId.isEmpty) return;

    try {
      final existing = await repository.getConversationBetween(
        user1Id: current.currentUserId,
        user2Id: event.riderId,
        orderId: event.orderId,
        type: 'seller_delivery',
      );

      String conversationId;
      if (existing != null) {
        conversationId = existing.id;
      } else {
        conversationId = await repository.createConversation(
          buyerId: '',
          buyerName: '',
          sellerId: current.currentUserId,
          sellerName: '',
          orderId: event.orderId,
          orderTitle: event.orderTitle,
          orderTotal: event.orderTotal,
          deliveryPartnerId: event.riderId,
          deliveryPartnerName: event.riderName,
          deliveryPartnerPhone: event.riderPhone,
          deliveryPartnerImageUrl: event.riderImageUrl,
          conversationType: 'seller_delivery',
          participants: [current.currentUserId, event.riderId],
          participantRoles: {
            current.currentUserId: 'seller',
            event.riderId: 'delivery_partner',
          },
        );
      }

      if (!isClosed) add(SelectChatSessionEvent(conversationId));
    } catch (e) {
      if (isClosed) return;
      emit(current.copyWith(
        errorMessage: 'Failed to open delivery partner chat. Please try again.',
      ));
    }
  }

  Future<void> _onAutoOpenOrderConversation(
      AutoOpenOrderConversationEvent event,
      Emitter<ChatSupportState> emit) async {
    final current = state;
    if (current is! ChatSupportLoaded) return;

    // Prefer a delivery conversation when explicitly requested, otherwise the
    // classic buyer_seller conversation for the order.
    final targetType = event.targetRole == 'delivery_partner'
        ? 'seller_delivery'
        : 'buyer_seller';

    ConversationModel? match;
    for (final c in current.conversations) {
      if (c.orderId != event.orderId) continue;
      if (c.conversationType == targetType) {
        match = c;
        break;
      }
      match ??= c;
    }

    if (match == null) {
      try {
        match = await repository.getConversationByOrderId(
          event.orderId,
          userId: current.currentUserId,
          isSeller: true,
        );
      } catch (_) {}
    }

    if (match != null && !isClosed) {
      add(SelectChatSessionEvent(match.id));
    }
  }

  Future<void> _onDeleteMessage(
      DeleteSupportMessageEvent event, Emitter<ChatSupportState> emit) async {
    final current = state;
    if (current is! ChatSupportLoaded) return;
    final userId = current.currentUserId;
    if (userId.isEmpty) return;

    try {
      await repository.deleteMessage(
        conversationId: event.message.conversationId,
        messageId: event.message.id,
        messageType: event.message.messageType,
        forEveryone: event.forEveryone,
        userId: userId,
      );
    } catch (e) {
      if (isClosed) return;
      emit(current.copyWith(
        errorMessage: 'Failed to delete message. Please try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _typingResetTimer?.cancel();
    return super.close();
  }
}
