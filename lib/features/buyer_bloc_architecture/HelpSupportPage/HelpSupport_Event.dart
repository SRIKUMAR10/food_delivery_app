import 'package:equatable/equatable.dart';

sealed class HelpSupportEvent extends Equatable {
  const HelpSupportEvent();
  @override
  List<Object?> get props => [];
}

class LoadHelpContent extends HelpSupportEvent {
  const LoadHelpContent();
}

class SubmitSupportTicket extends HelpSupportEvent {
  final String type;
  final String subject;
  final String message;
  final String? orderId;

  const SubmitSupportTicket({
    required this.type,
    required this.subject,
    required this.message,
    this.orderId,
  });

  @override
  List<Object?> get props => [type, subject, message, orderId];
}

class SubmitFeedback extends HelpSupportEvent {
  final int rating;
  final String comments;

  const SubmitFeedback({required this.rating, required this.comments});

  @override
  List<Object?> get props => [rating, comments];
}
