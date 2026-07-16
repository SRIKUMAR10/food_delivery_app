import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, success, error }

class BuyerChatSupportState extends Equatable {
  final ChatStatus status;
  final List<Map<String, String>> messages;
  final String? errorMessage;
  final bool isTyping;

  const BuyerChatSupportState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isTyping = false,
  });

  BuyerChatSupportState copyWith({
    ChatStatus? status,
    List<Map<String, String>>? messages,
    String? errorMessage,
    bool? isTyping,
  }) {
    return BuyerChatSupportState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, isTyping];
}
