import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  StreamSubscription? _messagesSub;

  DeliveryChatBloc({
    required this.chatRepository,
    required this.deliveryChatRepository,
    required this.deliveryChatService,
  }) : super(const DeliveryChatInitial()) {
    on<InitDeliveryChatEvent>(_onInitChat);
    on<SendDeliveryMessageEvent>(_onSendMessage);
    on<SendDeliveryQuickReplyEvent>(_onSendQuickReply);
    on<PickDeliveryAttachmentEvent>(_onPickAttachment);
    on<_MessagesUpdatedEvent>(_onMessagesUpdated);
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

      final conversationId =
          await deliveryChatRepository.createOrGetConversation(
        orderId: event.orderId,
        customerId: event.customerId,
        customerName: event.customerName,
        riderId: riderId,
        riderName: riderName,
        orderTitle: event.orderTitle,
        orderTotal: event.orderTotal,
      );

      await deliveryChatService.markMessagesRead(conversationId, riderId);

      await _subscribeToMessages(conversationId);

      emit(DeliveryChatLoaded(
        conversationId: conversationId,
        orderId: event.orderId,
        customerId: event.customerId,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
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
        senderRole: 'seller',
      );
    } catch (e) {
      emit(current.copyWith(
        isSendingMessage: false,
        errorMessage: 'Failed to send message',
      ));
      return;
    }

    if (state is DeliveryChatLoaded) {
      final s = state as DeliveryChatLoaded;
      emit(s.copyWith(isSendingMessage: false));
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

    emit(current.copyWith(
      infoMessage: 'Attachment upload coming soon',
    ));
    await Future.delayed(const Duration(seconds: 2));
    if (state is DeliveryChatLoaded) {
      emit((state as DeliveryChatLoaded).copyWith(clearInfo: true));
    }
  }

  Future<void> _subscribeToMessages(String conversationId) async {
    await _messagesSub?.cancel();

    _messagesSub = chatRepository
        .getMessagesStream(conversationId)
        .listen((messages) {
      add(_MessagesUpdatedEvent(messages));
    }, onError: (error) {
      add(_ChatErrorEvent('Message stream error: $error'));
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
    return super.close();
  }
}
