import 'package:equatable/equatable.dart';
import 'Delivery_Help_Support_page_state.dart';

abstract class DeliveryHelpSupportPageEvent extends Equatable {
  const DeliveryHelpSupportPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryHelpSupportInitEvent extends DeliveryHelpSupportPageEvent {
  const DeliveryHelpSupportInitEvent();
}

class DeliveryHelpSupportSearchFAQEvent extends DeliveryHelpSupportPageEvent {
  final String query;

  const DeliveryHelpSupportSearchFAQEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeliveryHelpSupportSelectCategoryEvent
    extends DeliveryHelpSupportPageEvent {
  final String? category;

  const DeliveryHelpSupportSelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeliveryHelpSupportSelectTicketFilterEvent
    extends DeliveryHelpSupportPageEvent {
  final DeliverySupportTicketFilter filter;

  const DeliveryHelpSupportSelectTicketFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryHelpSupportCreateTicketEvent
    extends DeliveryHelpSupportPageEvent {
  final String subject;
  final String category;
  final String priority;
  final String description;
  final String orderId;

  const DeliveryHelpSupportCreateTicketEvent({
    required this.subject,
    required this.category,
    this.priority = 'medium',
    required this.description,
    this.orderId = '',
  });

  @override
  List<Object?> get props => [subject, category, priority, description, orderId];
}

class DeliveryHelpSupportSubmitFeedbackEvent
    extends DeliveryHelpSupportPageEvent {
  final int rating;
  final String comment;

  const DeliveryHelpSupportSubmitFeedbackEvent({
    required this.rating,
    this.comment = '',
  });

  @override
  List<Object?> get props => [rating, comment];
}

class DeliveryHelpSupportTicketsUpdatedEvent
    extends DeliveryHelpSupportPageEvent {
  final List<SupportTicket> tickets;

  const DeliveryHelpSupportTicketsUpdatedEvent(this.tickets);

  @override
  List<Object?> get props => [tickets];
}
