import 'package:flutter_bloc/flutter_bloc.dart';
import 'Buyer_chat_support_event.dart';
import 'Buyer_chat_support_state.dart';

class BuyerChatSupportBloc
    extends Bloc<BuyerChatSupportEvent, BuyerChatSupportState> {
  BuyerChatSupportBloc() : super(const BuyerChatSupportState()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
  }

  void _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<BuyerChatSupportState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulate network call
    emit(
      state.copyWith(
        status: ChatStatus.success,
        messages: [
          {'sender': 'support', 'text': 'Hello! How can I help you today?'},
        ],
      ),
    );
  }

  void _onSendMessage(
    SendMessage event,
    Emitter<BuyerChatSupportState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    final newMessage = {'sender': 'user', 'text': event.message};
    final updatedMessages = List<Map<String, String>>.from(state.messages)
      ..add(newMessage);

    emit(state.copyWith(messages: updatedMessages, isTyping: true));

    // Simulate support agent reply
    await Future.delayed(const Duration(seconds: 2));
    final supportReply = {
      'sender': 'support',
      'text': 'Thank you for your message. We are looking into it.',
    };
    final finalMessages = List<Map<String, String>>.from(state.messages)
      ..add(supportReply);
    emit(state.copyWith(messages: finalMessages, isTyping: false));
  }
}
