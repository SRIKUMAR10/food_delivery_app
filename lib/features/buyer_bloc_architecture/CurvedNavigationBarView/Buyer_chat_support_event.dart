import 'package:equatable/equatable.dart';

abstract class BuyerChatSupportEvent extends Equatable {
  const BuyerChatSupportEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends BuyerChatSupportEvent {
  const LoadChatHistory();
}

class SendMessage extends BuyerChatSupportEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends BuyerChatSupportEvent {}
