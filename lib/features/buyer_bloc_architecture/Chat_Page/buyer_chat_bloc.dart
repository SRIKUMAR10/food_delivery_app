// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'buyer_chat_event.dart';
import 'buyer_chat_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../home_Page/home_page_models.dart';

class _ConversationsUpdated extends BuyerChatEvent {
  final List<ConversationModel> conversations;
  _ConversationsUpdated(this.conversations);
}

class _MessagesUpdated extends BuyerChatEvent {
  final String conversationId;
  final List<ChatMessageModel> messages;
  _MessagesUpdated(this.conversationId, this.messages);
}

class _ConversationsError extends BuyerChatEvent {
  final String error;
  _ConversationsError(this.error);
}

class _MessagesError extends BuyerChatEvent {
  final String error;
  _MessagesError(this.error);
}

class _AutoOpenConversation extends BuyerChatEvent {
  final String conversationId;
  _AutoOpenConversation(this.conversationId);
}

class BuyerChatBloc extends Bloc<BuyerChatEvent, BuyerChatState> {
  final IChatRepository repository;
  final IAuthService authService;
  StreamSubscription<String?>? _authSub;
  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;

  // Pending auto-open after conversations load
  String? _pendingConversationId;
  // Pending product selection after conversations load
  FoodItem? _pendingProduct;

  BuyerChatBloc({required this.repository, required this.authService})
      : super(BuyerChatInitial()) {
    on<LoadBuyerConversations>(_onLoadConversations);
    on<SelectBuyerConversation>(_onSelectConversation);
    on<SendBuyerMessage>(_onSendMessage);
    on<StartBuyerConversation>(_onStartConversation);
    on<FilterBuyerConversations>(_onFilterConversations);
    on<SendBuyerMediaMessage>(_onSendMediaMessage);
    on<ToggleEmojiPicker>(_onToggleEmojiPicker);
    on<StartAudioRecording>(_onStartAudioRecording);
    on<StopAudioRecording>(_onStopAudioRecording);
    on<CancelAudioRecording>(_onCancelAudioRecording);
    on<_ConversationsUpdated>(_onConversationsUpdated);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<_ConversationsError>(_onConversationsError);
    on<_MessagesError>(_onMessagesError);
    on<_AutoOpenConversation>(_onAutoOpenConversation);
    on<DeleteBuyerMessage>(_onDeleteMessage);
    on<SelectProductForSupport>(_onSelectProduct);

    _authSub = authService.authStateChanges.listen((userId) {
      if (userId != null) {
        add(LoadBuyerConversations());
      } else {
        _conversationsSub?.cancel();
        _messagesSub?.cancel();
      }
    });
  }

  /// Called externally to open (or auto-create) a conversation for an order.
  Future<void> openOrderConversation({
    required String orderId,
    required String sellerId,
    required String sellerName,
    String? shopName,
    String? sellerImageUrl,
    required String buyerName,
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      final existing = await repository.getConversationByOrderId(
        orderId, 
        userId: userId, 
        isSeller: false,
      );
      if (existing != null) {
        if (orderImageUrl != null || orderTitle != null || orderTotal != null) {
          try {
            await repository.updateConversationOrderDetails(
              existing.id,
              orderImageUrl: orderImageUrl,
              orderTitle: orderTitle,
              orderTotal: orderTotal,
            );
          } catch (_) {}
        }
        _pendingConversationId = existing.id;
        add(LoadBuyerConversations());
        return;
      }
    } catch (_) {}

    final convId = await repository.createConversation(
      buyerId: userId,
      buyerName: buyerName,
      sellerId: sellerId,
      sellerName: sellerName,
      shopName: shopName,
      sellerImageUrl: sellerImageUrl,
      orderId: orderId,
      orderImageUrl: orderImageUrl,
      orderTitle: orderTitle,
      orderTotal: orderTotal,
      initialMessage: null,
    );
    _pendingConversationId = convId;
    add(LoadBuyerConversations());
  }

  void _onLoadConversations(
      LoadBuyerConversations event, Emitter<BuyerChatState> emit) {
    final userId = authService.currentUserId;
    if (userId == null) {
      emit(BuyerChatError('User not logged in'));
      return;
    }

    _messagesSub?.cancel();
    emit(BuyerChatLoading());

    _conversationsSub?.cancel();
    _conversationsSub = repository
        .getConversationsForUser(userId, isSeller: false)
        .listen((conversations) {
      if (!isClosed) add(_ConversationsUpdated(conversations));
    }, onError: (error) {
      if (!isClosed) add(_ConversationsError('$error'));
    });
  }

  void _onConversationsUpdated(
      _ConversationsUpdated event, Emitter<BuyerChatState> emit) {
    if (_pendingConversationId != null) {
      final exists =
          event.conversations.any((c) => c.id == _pendingConversationId);
      if (!exists) return;
    }

    final current = state;
    if (current is BuyerChatLoaded) {
      emit(current.copyWith(conversations: event.conversations));
    } else {
      final userId = authService.currentUserId;
      if (userId != null) {
        emit(BuyerChatLoaded(
          currentUserId: userId,
          conversations: event.conversations,
          selectedProduct: _pendingProduct,
        ));
      }
      _pendingProduct = null;
    }

    if (_pendingConversationId != null && state is BuyerChatLoaded) {
      add(_AutoOpenConversation(_pendingConversationId!));
      _pendingConversationId = null;
    }
  }

  void _onAutoOpenConversation(
      _AutoOpenConversation event, Emitter<BuyerChatState> emit) {
    add(SelectBuyerConversation(event.conversationId));
  }

  void _onConversationsError(
      _ConversationsError event, Emitter<BuyerChatState> emit) {
    emit(BuyerChatError('Failed to load conversations: ${event.error}'));
  }

  void _onFilterConversations(
      FilterBuyerConversations event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(searchQuery: event.query));
  }

  void _onSelectConversation(
      SelectBuyerConversation event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;

    _messagesSub?.cancel();

    if (event.conversationId.isEmpty) {
      emit(current.copyWith(
        clearSelectedConversationId: true,
        messages: [],
      ));
      return;
    }

    repository.markConversationRead(event.conversationId, userId, false);

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
      _MessagesUpdated event, Emitter<BuyerChatState> emit) {
    final s = state;
    if (s is! BuyerChatLoaded) return;
    if (event.conversationId != s.selectedConversationId) return;
    final userId = authService.currentUserId;
    if (userId == null) return;
    final filteredMessages = event.messages
        .where((m) => !m.deletedBy.contains(userId))
        .toList();
    emit(s.copyWith(messages: filteredMessages));
  }

  void _onMessagesError(
      _MessagesError event, Emitter<BuyerChatState> emit) {
    final s = state;
    if (s is! BuyerChatLoaded) return;
    emit(s.copyWith(
      isSendingMessage: false,
      errorMessage: 'Failed to load messages: ${event.error}',
    ));
  }

  Future<void> _onSendMessage(
      SendBuyerMessage event, Emitter<BuyerChatState> emit) async {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;
    if (event.text.trim().isEmpty) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      await repository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: userId,
        senderRole: 'buyer',
      );
      final s = state;
      if (s is BuyerChatLoaded) {
        emit(s.copyWith(isSendingMessage: false));
      }
    } catch (e) {
      final s = state;
      if (s is BuyerChatLoaded) {
        emit(s.copyWith(
          isSendingMessage: false,
          errorMessage: 'Failed to send message. Please try again.',
        ));
      }
    }
  }

  Future<void> _onDeleteMessage(
      DeleteBuyerMessage event, Emitter<BuyerChatState> emit) async {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      await repository.deleteMessage(
        conversationId: event.message.conversationId,
        messageId: event.message.id,
        messageType: event.message.messageType,
        forEveryone: event.forEveryone,
        userId: userId,
      );
    } catch (e) {
      emit(current.copyWith(
        errorMessage: 'Failed to delete message. Please try again.',
      ));
    }
  }

  Future<void> _onSendMediaMessage(
      SendBuyerMediaMessage event, Emitter<BuyerChatState> emit) async {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      final mediaUrl = await repository.uploadChatAttachment(
        event.file,
        event.conversationId,
        event.fileName,
      );

      await repository.sendMessage(
        conversationId: event.conversationId,
        text: '', // Empty text for media
        senderId: userId,
        senderRole: 'buyer',
        messageType: event.messageType,
        mediaUrl: mediaUrl,
        fileName: event.fileName,
        duration: event.duration,
      );
      final s = state;
      if (s is BuyerChatLoaded) {
        emit(s.copyWith(isSendingMessage: false));
      }
    } catch (e) {
      final s = state;
      if (s is BuyerChatLoaded) {
        emit(s.copyWith(
          isSendingMessage: false,
          errorMessage: 'Failed to send media. Please try again.',
        ));
      }
    }
  }

  void _onToggleEmojiPicker(
      ToggleEmojiPicker event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(showEmojiPicker: event.show));
  }

  void _onStartAudioRecording(
      StartAudioRecording event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(isRecording: true, recordingDuration: Duration.zero));
  }

  void _onStopAudioRecording(
      StopAudioRecording event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(isRecording: false));
  }

  void _onCancelAudioRecording(
      CancelAudioRecording event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(isRecording: false, recordingDuration: Duration.zero));
  }

  Future<void> _onStartConversation(
      StartBuyerConversation event, Emitter<BuyerChatState> emit) async {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;

    emit(current.copyWith(clearError: true));

    try {
      final conversationId = await repository.createConversation(
        buyerId: userId,
        buyerName: event.buyerName,
        sellerId: event.sellerId,
        sellerName: event.sellerName,
        shopName: event.shopName,
        sellerImageUrl: event.sellerImageUrl,
        orderId: event.orderId,
        initialMessage: event.initialMessage,
      );
      add(SelectBuyerConversation(conversationId));
    } catch (e) {
      final s = state;
      if (s is BuyerChatLoaded) {
        emit(s.copyWith(
          errorMessage: 'Failed to start conversation. Please try again.',
        ));
      }
    }
  }

  void _onSelectProduct(
      SelectProductForSupport event, Emitter<BuyerChatState> emit) {
    final s = state;
    if (s is BuyerChatLoaded) {
      emit(s.copyWith(selectedProduct: event.product));
    } else {
      _pendingProduct = event.product;
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    return super.close();
  }
}
