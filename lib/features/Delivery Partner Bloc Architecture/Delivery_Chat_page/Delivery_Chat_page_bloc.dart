import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/chat_message_model.dart';
import 'Delivery_Chat_page_event.dart';
import 'Delivery_Chat_page_state.dart';
import 'Delivery_Chat_page_repository.dart';
import 'Delivery_Chat_page_service.dart';

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

  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;

  DeliveryChatBloc({
    required this.chatRepository,
    required this.deliveryChatRepository,
    required this.deliveryChatService,
  }) : super(const DeliveryChatInitial()) {
    on<InitDeliveryChatEvent>(_onInitChat);
    on<SendDeliveryMessageEvent>(_onSendMessage);
    on<SendDeliveryMediaMessageEvent>(_onSendMediaMessage);
    on<SendDeliveryQuickReplyEvent>(_onSendQuickReply);
    on<PickDeliveryAttachmentEvent>(_onPickAttachment);
    on<SendAudioVoiceNoteEvent>(_onSendAudioVoiceNote);
    on<SetDeliveryTypingStatusEvent>(_onSetTypingStatus);
    on<MarkDeliveryChatReadEvent>(_onMarkRead);
    on<_MessagesUpdatedEvent>(_onMessagesUpdated);
    on<_TypingStatusUpdatedEvent>(_onTypingStatusUpdated);
    on<_ChatErrorEvent>(_onChatError);
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

      emit(DeliveryChatLoaded(
        conversationId: conversationId,
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
    _messagesSub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}

/// Standardized Feature-Architecture Alias for ChatBloc
typedef ChatBloc = DeliveryChatBloc;

