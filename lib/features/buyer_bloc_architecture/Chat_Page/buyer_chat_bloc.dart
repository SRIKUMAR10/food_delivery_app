// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'buyer_chat_event.dart';
import 'buyer_chat_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/repositories/i_user_profile_repository.dart';
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

class _TypingStatusUpdated extends BuyerChatEvent {
  final String conversationId;
  final Map<String, bool> typingMap;
  _TypingStatusUpdated(this.conversationId, this.typingMap);
}

class _UserProfileUpdated extends BuyerChatEvent {
  final String? name;
  final String? photoUrl;
  final String? phone;
  _UserProfileUpdated(this.name, this.photoUrl, this.phone);
}

class BuyerChatBloc extends Bloc<BuyerChatEvent, BuyerChatState> {
  final IChatRepository repository;
  final IAuthService authService;
  final IUserProfileRepository? userProfileRepository;
  final FirebaseFirestore _firestore;
  StreamSubscription<String?>? _authSub;
  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _profileSub;

  // Pending auto-open after conversations load
  String? _pendingConversationId;
  // Pending product selection after conversations load
  FoodItem? _pendingProduct;

  BuyerChatBloc({
    required this.repository,
    required this.authService,
    this.userProfileRepository,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(BuyerChatInitial()) {
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
    on<_TypingStatusUpdated>(_onTypingStatusUpdated);
    on<_UserProfileUpdated>(_onUserProfileUpdated);
    on<SetBuyerTypingStatus>(_onSetTypingStatus);
    on<DeleteBuyerMessage>(_onDeleteMessage);
    on<SelectProductForSupport>(_onSelectProduct);
    on<StartDeliveryPartnerConversation>(_onStartDeliveryConversation);
    on<MarkMessagesAsRead>(_onMarkMessagesRead);
    on<SendOrderQuickReply>(_onSendOrderQuickReply);
    on<SetBuyerChatFilter>(_onSetFilter);

    _authSub = authService.authStateChanges.listen((userId) {
      if (userId != null) {
        add(LoadBuyerConversations());
      } else {
        _conversationsSub?.cancel();
        _messagesSub?.cancel();
        _typingSub?.cancel();
        _profileSub?.cancel();
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
    String? sellerPhone,
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
        if (orderImageUrl != null || orderTitle != null || orderTotal != null || sellerPhone != null) {
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
      sellerPhone: sellerPhone,
      orderId: orderId,
      orderImageUrl: orderImageUrl,
      orderTitle: orderTitle,
      orderTotal: orderTotal,
      initialMessage: null,
    );
    _pendingConversationId = convId;
    add(LoadBuyerConversations());
  }

  /// Opens (or auto-creates) a `buyer_delivery` conversation with a rider.
  Future<void> openDeliveryConversation({
    required String deliveryPartnerId,
    required String deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerImageUrl,
    required String buyerName,
    String? orderId,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      final existing = await repository.getConversationBetween(
        user1Id: userId,
        user2Id: deliveryPartnerId,
        orderId: orderId,
        type: 'buyer_delivery',
      );
      if (existing != null) {
        _pendingConversationId = existing.id;
        add(LoadBuyerConversations());
        return;
      }
    } catch (_) {}

    final convId = await repository.createConversation(
      buyerId: userId,
      buyerName: buyerName,
      sellerId: '',
      sellerName: '',
      deliveryPartnerId: deliveryPartnerId,
      deliveryPartnerName: deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone,
      deliveryPartnerImageUrl: deliveryPartnerImageUrl,
      conversationType: 'buyer_delivery',
      orderId: orderId,
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

    _profileSub?.cancel();
    if (userProfileRepository != null) {
      _profileSub = userProfileRepository!.watchProfile(userId).listen((profile) {
        if (!isClosed && profile != null) {
          add(_UserProfileUpdated(profile.name, profile.imageUrl, profile.phone));
        }
      }, onError: (_) {});
    }

    _conversationsSub?.cancel();
    _conversationsSub = repository
        .getConversationsForUser(userId, isSeller: false)
        .listen((conversations) {
      if (!isClosed) add(_ConversationsUpdated(conversations));
    }, onError: (error) {
      if (!isClosed) add(_ConversationsError('$error'));
    });
  }

  Future<void> _onConversationsUpdated(
      _ConversationsUpdated event, Emitter<BuyerChatState> emit) async {
    if (_pendingConversationId != null) {
      final exists =
          event.conversations.any((c) => c.id == _pendingConversationId);
      if (!exists) return;
    }

    // Real-time enrichment of restaurant and order information
    final enriched = <ConversationModel>[];
    for (final conv in event.conversations) {
      var c = conv;
      if (!c.isDeliveryChat &&
          c.sellerId.isNotEmpty &&
          (c.shopName == null ||
              c.shopName!.isEmpty ||
              c.shopName == 'Restaurant' ||
              c.sellerName == 'Restaurant' ||
              c.sellerName == 'Store' ||
              c.sellerImageUrl == null ||
              c.sellerPhone == null)) {
        try {
          final sellerDoc =
              await _firestore.collection('sellers').doc(c.sellerId).get();
          if (sellerDoc.exists) {
            final data = sellerDoc.data()!;
            final sName = data['shopName'] as String? ??
                data['name'] as String? ??
                data['restaurantName'] as String?;
            final sImg = data['profileImageUrl'] as String? ??
                data['imageUrl'] as String? ??
                data['logoUrl'] as String?;
            final sPhone = data['phoneNumber'] as String? ??
                data['contactNumber'] as String? ??
                data['phone'] as String?;
            c = c.copyWith(
              shopName: (sName != null && sName.isNotEmpty) ? sName : c.shopName,
              sellerName:
                  (sName != null && sName.isNotEmpty) ? sName : c.sellerName,
              sellerImageUrl: (sImg != null && sImg.isNotEmpty)
                  ? sImg
                  : c.sellerImageUrl,
              sellerPhone: (sPhone != null && sPhone.isNotEmpty)
                  ? sPhone
                  : c.sellerPhone,
            );
          }
        } catch (_) {}
      }

      if (c.orderId != null &&
          (c.orderTitle == null ||
              c.shopName == null ||
              c.shopName == 'Restaurant')) {
        try {
          final orderDoc =
              await _firestore.collection('orders').doc(c.orderId).get();
          if (orderDoc.exists) {
            final oData = orderDoc.data()!;
            final oSellerName = oData['sellerName'] as String? ??
                oData['shopName'] as String? ??
                oData['restaurantName'] as String?;
            final oItems = oData['items'] as List?;
            String? oTitle;
            String? oImg;
            if (oItems != null && oItems.isNotEmpty) {
              final first = oItems.first;
              if (first is Map) {
                oTitle = first['name'] as String?;
                oImg =
                    first['imageUrl'] as String? ?? first['image'] as String?;
              }
            }
            c = c.copyWith(
              shopName: (oSellerName != null &&
                      oSellerName.isNotEmpty &&
                      oSellerName != 'Restaurant')
                  ? oSellerName
                  : c.shopName,
              sellerName: (oSellerName != null &&
                      oSellerName.isNotEmpty &&
                      oSellerName != 'Restaurant')
                  ? oSellerName
                  : c.sellerName,
              orderTitle: (oTitle != null && oTitle.isNotEmpty)
                  ? oTitle
                  : c.orderTitle,
              orderImageUrl:
                  (oImg != null && oImg.isNotEmpty) ? oImg : c.orderImageUrl,
            );
          }
        } catch (_) {}
      }
      enriched.add(c);
    }

    final current = state;
    if (current is BuyerChatLoaded) {
      emit(current.copyWith(conversations: enriched));
    } else {
      final userId = authService.currentUserId;
      if (userId != null) {
        emit(BuyerChatLoaded(
          currentUserId: userId,
          conversations: enriched,
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

  void _onUserProfileUpdated(
      _UserProfileUpdated event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is BuyerChatLoaded) {
      emit(current.copyWith(
        buyerProfileName: event.name,
        buyerProfileImage: event.photoUrl,
        buyerProfilePhone: event.phone,
      ));
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
    _typingSub?.cancel();

    if (event.conversationId.isEmpty) {
      emit(current.copyWith(
        clearSelectedConversationId: true,
        messages: [],
        isOtherPartyTyping: false,
      ));
      return;
    }

    emit(current.copyWith(
      selectedConversationId: event.conversationId,
      messages: [],
      isOtherPartyTyping: false,
    ));

    add(MarkMessagesAsRead(event.conversationId));

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
        .listen((typingMap) {
      if (!isClosed) {
        add(_TypingStatusUpdated(event.conversationId, typingMap));
      }
    });
  }

  void _onTypingStatusUpdated(
      _TypingStatusUpdated event, Emitter<BuyerChatState> emit) {
    final s = state;
    if (s is! BuyerChatLoaded) return;
    if (event.conversationId != s.selectedConversationId) return;
    final userId = authService.currentUserId;

    final isOtherTyping = event.typingMap.entries
        .any((entry) => entry.key != userId && entry.value == true);
    emit(s.copyWith(isOtherPartyTyping: isOtherTyping));
  }

  Future<void> _onSetTypingStatus(
      SetBuyerTypingStatus event, Emitter<BuyerChatState> emit) async {
    final userId = authService.currentUserId;
    if (userId == null) return;
    try {
      await repository.setTypingStatus(
        conversationId: event.conversationId,
        userId: userId,
        isTyping: event.isTyping,
      );
    } catch (_) {}
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

    final hasIncomingUnread = filteredMessages.any(
      (m) => m.senderId != userId && !m.isRead,
    );
    if (hasIncomingUnread) {
      add(MarkMessagesAsRead(event.conversationId));
    }
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
        sellerPhone: event.sellerPhone,
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

  Future<void> _onStartDeliveryConversation(
      StartDeliveryPartnerConversation event,
      Emitter<BuyerChatState> emit) async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final current = state;
    if (current is BuyerChatLoaded) {
      emit(current.copyWith(clearError: true));
    }

    try {
      final conversationId = await repository.createConversation(
        buyerId: userId,
        buyerName: event.buyerName,
        sellerId: '',
        sellerName: '',
        deliveryPartnerId: event.deliveryPartnerId,
        deliveryPartnerName: event.deliveryPartnerName,
        deliveryPartnerPhone: event.deliveryPartnerPhone,
        deliveryPartnerImageUrl: event.deliveryPartnerImageUrl,
        conversationType: 'buyer_delivery',
        orderId: event.orderId,
        orderTitle: event.orderTitle,
        orderTotal: event.orderTotal,
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

  Future<void> _onMarkMessagesRead(
      MarkMessagesAsRead event, Emitter<BuyerChatState> emit) async {
    final s = state;
    if (s is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;

    emit(s.copyWith(isMarkingRead: true));

    try {
      await repository.markMessagesAsRead(
        conversationId: event.conversationId,
        readerId: userId,
      );
    } catch (_) {}

    final current = state;
    if (current is BuyerChatLoaded) {
      emit(current.copyWith(isMarkingRead: false));
    }
  }

  Future<void> _onSendOrderQuickReply(
      SendOrderQuickReply event, Emitter<BuyerChatState> emit) async {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    final userId = authService.currentUserId;
    if (userId == null) return;
    if (event.text.trim().isEmpty) return;

    try {
      await repository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: userId,
        senderRole: 'buyer',
      );
    } catch (_) {}
  }

  void _onSetFilter(
      SetBuyerChatFilter event, Emitter<BuyerChatState> emit) {
    final current = state;
    if (current is! BuyerChatLoaded) return;
    emit(current.copyWith(activeFilter: event.filter));
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _profileSub?.cancel();
    return super.close();
  }
}
