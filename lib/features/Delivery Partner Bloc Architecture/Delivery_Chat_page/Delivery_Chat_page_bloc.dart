import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/conversation_model.dart';
import 'Delivery_Chat_page_event.dart';
import 'Delivery_Chat_page_state.dart';
import 'Delivery_Chat_page_repository.dart';
import 'Delivery_Chat_page_service.dart';

class _ConversationsUpdatedEvent extends DeliveryChatEvent {
  final List<ConversationModel> conversations;
  const _ConversationsUpdatedEvent(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class _MessagesUpdatedEvent extends DeliveryChatEvent {
  final List<ChatMessageModel> messages;
  const _MessagesUpdatedEvent(this.messages);
  @override
  List<Object?> get props => [messages];
}

class _TypingStatusUpdatedEvent extends DeliveryChatEvent {
  final Map<String, bool> typingUsers;
  const _TypingStatusUpdatedEvent(this.typingUsers);
  @override
  List<Object?> get props => [typingUsers];
}

class _ChatErrorEvent extends DeliveryChatEvent {
  final String error;
  const _ChatErrorEvent(this.error);
  @override
  List<Object?> get props => [error];
}

class DeliveryChatBloc extends Bloc<DeliveryChatEvent, DeliveryChatState> {
  final IChatRepository chatRepository;
  final DeliveryChatRepositoryBase deliveryChatRepository;
  final DeliveryChatServiceBase deliveryChatService;
  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;

  DeliveryChatBloc({
    required this.chatRepository,
    required this.deliveryChatRepository,
    required this.deliveryChatService,
  }) : super(const DeliveryChatInitial()) {
    on<LoadDeliveryConversations>(_onLoadConversations);
    on<SelectDeliveryConversation>(_onSelectConversation);
    on<ClearSelectedDeliveryConversation>(_onClearSelectedConversation);
    on<SetDeliveryChatFilter>(_onSetFilter);
    on<SearchDeliveryConversations>(_onSearchConversations);
    on<InitDeliveryChatEvent>(_onInitChat);
    on<SendDeliveryMessageEvent>(_onSendMessage);
    on<SendDeliveryMediaMessageEvent>(_onSendMediaMessage);
    on<SendDeliveryQuickReplyEvent>(_onSendQuickReply);
    on<PickDeliveryAttachmentEvent>(_onPickAttachment);
    on<SendAudioVoiceNoteEvent>(_onSendAudioVoiceNote);
    on<SetDeliveryTypingStatusEvent>(_onSetTypingStatus);
    on<MarkDeliveryChatReadEvent>(_onMarkRead);
    on<ToggleDeliveryEmojiPicker>(_onToggleEmojiPicker);
    on<StartDeliveryAudioRecording>(_onStartAudioRecording);
    on<StopDeliveryAudioRecording>(_onStopAudioRecording);
    on<CancelDeliveryAudioRecording>(_onCancelAudioRecording);
    on<UpdateDeliveryAudioRecordingDuration>(_onUpdateRecordingDuration);
    on<DeleteDeliveryMessage>(_onDeleteMessage);
    on<_ConversationsUpdatedEvent>(_onConversationsUpdated);
    on<_MessagesUpdatedEvent>(_onMessagesUpdated);
    on<_TypingStatusUpdatedEvent>(_onTypingStatusUpdated);
    on<_ChatErrorEvent>(_onChatError);
  }

  Future<void> _onLoadConversations(
    LoadDeliveryConversations event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final riderId = deliveryChatService.currentUserId;
    final effectiveRiderId = riderId.isNotEmpty ? riderId : 'delivery_partner_session';

    if (state is! DeliveryChatLoaded) {
      emit(DeliveryChatLoaded(currentUserId: effectiveRiderId));
    }

    await _conversationsSub?.cancel();
    _conversationsSub = deliveryChatRepository
        .getDeliveryConversations(effectiveRiderId)
        .listen(
      (convs) {
        add(_ConversationsUpdatedEvent(convs));
      },
      onError: (err) {
        add(_ChatErrorEvent('Failed to stream conversations: $err'));
      },
    );
  }

  void _onConversationsUpdated(
    _ConversationsUpdatedEvent event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    final riderId = deliveryChatService.currentUserId;
    if (current is DeliveryChatLoaded) {
      final map = <String, ConversationModel>{};

      if (current.conversationId.isNotEmpty) {
        final active = current.selectedConversation ??
            ConversationModel(
              id: current.conversationId,
              orderId: current.orderId,
              buyerId: current.customerId,
              buyerName: current.customerName.isNotEmpty ? current.customerName : 'Customer',
              sellerId: current.sellerId ?? '',
              sellerName: current.sellerName ?? '',
              sellerPhone: current.sellerPhone,
              conversationType: current.isSellerChat ? 'seller_delivery' : 'buyer_delivery',
              participants: [riderId, current.recipientId].where((p) => p.isNotEmpty).toList(),
              shopName: current.orderTitle ?? current.sellerName,
              orderTitle: current.orderTitle,
              orderTotal: current.orderTotal,
              orderImageUrl: current.orderImageUrl,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
        map[active.id] = active;
      }

      for (final c in event.conversations) {
        map[c.id] = c;
      }

      final mergedList = map.values.toList();
      mergedList.sort((a, b) {
        final aTime = a.lastMessageTimestamp ?? a.createdAt;
        final bTime = b.lastMessageTimestamp ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      emit(current.copyWith(
        conversations: mergedList,
        selectedConversationId: current.selectedConversationId ?? current.conversationId,
      ));
    } else {
      emit(DeliveryChatLoaded(
        currentUserId: riderId,
        conversations: event.conversations,
      ));
    }
  }

  Future<void> _onSelectConversation(
    SelectDeliveryConversation event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    final riderId = deliveryChatService.currentUserId;
    if (riderId.isEmpty) {
      emit(const DeliveryChatError('Not authenticated'));
      return;
    }

    ConversationModel? target;
    if (current is DeliveryChatLoaded) {
      try {
        target = current.conversations.firstWhere((c) => c.id == event.conversationId);
      } catch (_) {}
    }

    final isSeller = target?.conversationType == 'seller_delivery' ||
        target?.conversationType == 'seller_support' ||
        target?.conversationType == 'seller';

    final recipientId = target != null
        ? (isSeller
            ? target.sellerId
            : (target.buyerId.isNotEmpty ? target.buyerId : target.sellerId))
        : '';
    final recipientName = target != null
        ? (isSeller
            ? (target.shopName?.isNotEmpty == true ? target.shopName! : target.sellerName)
            : (target.buyerName.isNotEmpty && target.buyerName.toLowerCase() != 'customer'
                ? target.buyerName
                : (target.buyerName.isNotEmpty ? target.buyerName : 'Anu')))
        : 'Anu';
    final recipientPhone = target != null
        ? (isSeller ? target.sellerPhone : null)
        : null;

    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(
        selectedConversationId: event.conversationId,
        conversationId: event.conversationId,
        orderId: target?.orderId ?? current.orderId,
        recipientRole: isSeller ? 'seller' : 'customer',
        recipientId: recipientId,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        sellerId: isSeller ? recipientId : current.sellerId,
        sellerName: isSeller ? recipientName : current.sellerName,
        sellerPhone: isSeller ? recipientPhone : current.sellerPhone,
        customerId: !isSeller ? recipientId : current.customerId,
        customerName: !isSeller ? recipientName : current.customerName,
        customerPhone: !isSeller ? recipientPhone : current.customerPhone,
        orderTitle: target?.orderTitle ?? current.orderTitle,
        orderTotal: target?.orderTotal ?? current.orderTotal,
        orderImageUrl: target?.orderImageUrl ?? current.orderImageUrl,
      ));
    } else {
      emit(DeliveryChatLoaded(
        currentUserId: riderId,
        selectedConversationId: event.conversationId,
        conversationId: event.conversationId,
        orderId: target?.orderId ?? '',
        recipientRole: isSeller ? 'seller' : 'customer',
        recipientId: recipientId,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        orderTitle: target?.orderTitle,
        orderTotal: target?.orderTotal,
        orderImageUrl: target?.orderImageUrl,
      ));
    }

    await deliveryChatService.markMessagesRead(event.conversationId, riderId);
    await _subscribeToStreams(event.conversationId);
  }

  void _onClearSelectedConversation(
    ClearSelectedDeliveryConversation event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      _messagesSub?.cancel();
      _typingSub?.cancel();
      emit(current.copyWith(
        clearSelectedConversationId: true,
        conversationId: '',
        messages: const [],
      ));
    }
  }

  void _onSetFilter(
    SetDeliveryChatFilter event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(activeFilter: event.activeFilter));
    }
  }

  void _onSearchConversations(
    SearchDeliveryConversations event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onToggleEmojiPicker(
    ToggleDeliveryEmojiPicker event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(showEmojiPicker: !current.showEmojiPicker));
    }
  }

  void _onStartAudioRecording(
    StartDeliveryAudioRecording event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(isRecordingAudio: true, recordingDuration: Duration.zero));
    }
  }

  void _onStopAudioRecording(
    StopDeliveryAudioRecording event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(isRecordingAudio: false));
    }
  }

  void _onCancelAudioRecording(
    CancelDeliveryAudioRecording event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(isRecordingAudio: false, recordingDuration: Duration.zero));
    }
  }

  void _onUpdateRecordingDuration(
    UpdateDeliveryAudioRecordingDuration event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(recordingDuration: event.duration));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteDeliveryMessage event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.currentUserId.isEmpty) return;
    try {
      final int index = current.messages.indexWhere(
        (m) => m.id == event.messageId,
      );
      final message = index != -1 ? current.messages[index] : null;
      if (message == null) return;
      await chatRepository.deleteMessage(
        conversationId: current.conversationId,
        messageId: message.id,
        messageType: message.messageType,
        forEveryone: message.senderId != current.currentUserId,
        userId: current.currentUserId,
      );
    } catch (e) {
      emit(current.copyWith(errorMessage: 'Failed to delete message: $e'));
    }
  }

  Future<void> _onInitChat(
    InitDeliveryChatEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    emit(const DeliveryChatLoading());

    try {
      final riderId = deliveryChatService.currentUserId;
      final riderName = deliveryChatService.currentUserName;

      if (riderId.isEmpty) {
        emit(const DeliveryChatError('Not authenticated'));
        return;
      }

      // Start conversations stream in background
      await _conversationsSub?.cancel();
      _conversationsSub = deliveryChatRepository
          .getDeliveryConversations(riderId)
          .listen(
        (convs) {
          add(_ConversationsUpdatedEvent(convs));
        },
        onError: (err) {
          add(_ChatErrorEvent('Failed to stream conversations: $err'));
        },
      );

      final isSeller = event.isSellerChat;
      final recipientId = event.effectiveRecipientId;
      final recipientName = event.effectiveRecipientName;
      final recipientPhone = event.effectiveRecipientPhone;

      final String conversationId;
      if (isSeller) {
        conversationId =
            await deliveryChatRepository.createOrGetSellerDeliveryConversation(
          orderId: event.orderId,
          sellerId: recipientId,
          sellerName: recipientName,
          riderId: riderId,
          riderName: riderName,
          orderTitle: event.orderTitle,
          orderTotal: event.orderTotal,
        );
      } else {
        conversationId =
            await deliveryChatRepository.createOrGetConversation(
          orderId: event.orderId,
          customerId: recipientId,
          customerName: recipientName,
          riderId: riderId,
          riderName: riderName,
          orderTitle: event.orderTitle,
          orderTotal: event.orderTotal,
        );
      }

      await deliveryChatService.markMessagesRead(conversationId, riderId);
      await _subscribeToStreams(conversationId);

      final activeConv = ConversationModel(
        id: conversationId,
        orderId: event.orderId,
        buyerId: isSeller ? '' : recipientId,
        buyerName: isSeller ? '' : (recipientName.isNotEmpty ? recipientName : 'Customer'),
        sellerId: isSeller ? recipientId : (event.sellerId ?? ''),
        sellerName: isSeller ? recipientName : (event.sellerName ?? ''),
        sellerPhone: isSeller ? recipientPhone : event.sellerPhone,
        conversationType: isSeller ? 'seller_delivery' : 'buyer_delivery',
        participants: [riderId, recipientId].where((p) => p.isNotEmpty).toList(),
        shopName: isSeller ? (event.sellerName ?? recipientName) : (event.orderTitle),
        orderTitle: event.orderTitle,
        orderTotal: event.orderTotal,
        orderImageUrl: event.orderImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastMessage: '',
      );

      final currentLoaded = state is DeliveryChatLoaded ? (state as DeliveryChatLoaded) : null;
      final existingConvs = currentLoaded?.conversations ?? <ConversationModel>[];
      final mergedList = [
        activeConv,
        ...existingConvs.where((c) => c.id != conversationId),
      ];

      emit(DeliveryChatLoaded(
        conversationId: conversationId,
        selectedConversationId: conversationId,
        conversations: mergedList,
        orderId: event.orderId,
        customerId: isSeller ? '' : recipientId,
        customerName: isSeller ? '' : recipientName,
        customerPhone: isSeller ? null : recipientPhone,
        sellerId: isSeller ? recipientId : event.sellerId,
        sellerName: isSeller ? recipientName : event.sellerName,
        sellerPhone: isSeller ? recipientPhone : event.sellerPhone,
        recipientRole: event.recipientRole,
        recipientId: recipientId,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        orderTitle: event.orderTitle,
        orderTotal: event.orderTotal,
        orderImageUrl: event.orderImageUrl,
        currentUserId: riderId,
      ));
    } catch (e) {
      emit(DeliveryChatError('Failed to start conversation: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendDeliveryMessageEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (event.text.trim().isEmpty) return;
    if (current.conversationId.isEmpty) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      await chatRepository.sendMessage(
        conversationId: current.conversationId,
        text: event.text.trim(),
        senderId: current.currentUserId,
        senderRole: 'delivery_partner',
        receiverId: current.recipientId,
        messageType: 'text',
      );
    } catch (e) {
      emit(current.copyWith(
        isSendingMessage: false,
        errorMessage: 'Failed to send message: $e',
      ));
      return;
    }

    if (state is DeliveryChatLoaded) {
      final s = state as DeliveryChatLoaded;
      emit(s.copyWith(isSendingMessage: false));
    }
  }

  Future<void> _onSendMediaMessage(
    SendDeliveryMediaMessageEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.conversationId.isEmpty) return;

    emit(current.copyWith(isSendingMessage: true, clearError: true));

    try {
      await chatRepository.sendMessage(
        conversationId: current.conversationId,
        text: event.text ?? (event.messageType == 'image' ? 'Photo attachment' : 'Voice message'),
        senderId: current.currentUserId,
        senderRole: 'delivery_partner',
        receiverId: current.recipientId,
        messageType: event.messageType,
        mediaUrl: event.mediaUrl,
        fileName: event.fileName,
        fileSize: event.fileSize,
        duration: event.duration,
      );
    } catch (e) {
      emit(current.copyWith(
        isSendingMessage: false,
        errorMessage: 'Failed to send media: $e',
      ));
      return;
    }

    if (state is DeliveryChatLoaded) {
      emit((state as DeliveryChatLoaded).copyWith(isSendingMessage: false));
    }
  }

  Future<void> _onSendQuickReply(
    SendDeliveryQuickReplyEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    add(SendDeliveryMessageEvent(event.text));
  }

  Future<void> _onPickAttachment(
    PickDeliveryAttachmentEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.conversationId.isEmpty) return;

    try {
      final source = event.fromCamera ? ImageSource.camera : ImageSource.gallery;
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (file == null) return;

      emit(current.copyWith(isUploadingAttachment: true, clearError: true));

      final downloadUrl = await deliveryChatRepository.uploadAttachment(
        file,
        current.conversationId,
        file.name.isNotEmpty ? file.name : 'delivery_photo.jpg',
      );

      add(SendDeliveryMediaMessageEvent(
        messageType: 'image',
        mediaUrl: downloadUrl,
        fileName: file.name,
      ));

      if (state is DeliveryChatLoaded) {
        emit((state as DeliveryChatLoaded).copyWith(isUploadingAttachment: false));
      }
    } catch (e) {
      if (state is DeliveryChatLoaded) {
        emit((state as DeliveryChatLoaded).copyWith(
          isUploadingAttachment: false,
          errorMessage: 'Failed to upload photo: $e',
        ));
      }
    }
  }

  Future<void> _onSendAudioVoiceNote(
    SendAudioVoiceNoteEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.conversationId.isEmpty) return;

    emit(current.copyWith(isUploadingAttachment: true, clearError: true));

    try {
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final downloadUrl = await deliveryChatRepository.uploadAttachment(
        event.audioFile,
        current.conversationId,
        fileName,
      );

      add(SendDeliveryMediaMessageEvent(
        messageType: 'audio',
        mediaUrl: downloadUrl,
        duration: event.durationSeconds,
        fileName: fileName,
      ));

      if (state is DeliveryChatLoaded) {
        emit((state as DeliveryChatLoaded).copyWith(isUploadingAttachment: false));
      }
    } catch (e) {
      if (state is DeliveryChatLoaded) {
        emit((state as DeliveryChatLoaded).copyWith(
          isUploadingAttachment: false,
          errorMessage: 'Failed to send voice note: $e',
        ));
      }
    }
  }

  Future<void> _onSetTypingStatus(
    SetDeliveryTypingStatusEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.conversationId.isEmpty) return;

    try {
      await deliveryChatRepository.setTypingStatus(
        conversationId: current.conversationId,
        userId: current.currentUserId,
        isTyping: event.isTyping,
      );
    } catch (_) {}
  }

  Future<void> _onMarkRead(
    MarkDeliveryChatReadEvent event,
    Emitter<DeliveryChatState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryChatLoaded) return;
    if (current.conversationId.isEmpty) return;

    try {
      await deliveryChatService.markMessagesRead(
        current.conversationId,
        current.currentUserId,
      );
    } catch (_) {}
  }

  Future<void> _subscribeToStreams(String conversationId) async {
    await _messagesSub?.cancel();
    await _typingSub?.cancel();

    _messagesSub = chatRepository
        .getMessagesStream(conversationId)
        .listen((messages) {
      add(_MessagesUpdatedEvent(messages));
    }, onError: (error) {
      add(_ChatErrorEvent('Message stream error: $error'));
    });

    _typingSub = deliveryChatRepository
        .getTypingStatusStream(conversationId)
        .listen((typingMap) {
      add(_TypingStatusUpdatedEvent(typingMap));
    });
  }

  void _onMessagesUpdated(
    _MessagesUpdatedEvent event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(messages: event.messages));
    }
  }

  void _onTypingStatusUpdated(
    _TypingStatusUpdatedEvent event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(typingUsers: event.typingUsers));
    }
  }

  void _onChatError(
    _ChatErrorEvent event,
    Emitter<DeliveryChatState> emit,
  ) {
    final current = state;
    if (current is DeliveryChatLoaded) {
      emit(current.copyWith(errorMessage: event.error));
    } else {
      emit(DeliveryChatError(event.error));
    }
  }

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}

/// Standardized Feature-Architecture Alias for ChatBloc
typedef ChatBloc = DeliveryChatBloc;
