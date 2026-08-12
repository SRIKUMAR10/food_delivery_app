import 'package:equatable/equatable.dart';

enum DeliveryHelpSupportStatus { initial, loading, loaded, submitting, error }

enum DeliverySupportTicketStatus { open, inProgress, resolved, escalated }

enum DeliverySupportTicketFilter { all, open, inProgress, resolved, escalated }

const List<String> kDeliverySupportCategories = [
  'Earnings',
  'Route / GPS',
  'App Technical',
  'Customer Issue',
  'Other',
];

const List<String> kDeliverySupportPriorities = ['low', 'medium', 'high', 'urgent'];

class SupportTicket extends Equatable {
  final String id;
  final String subject;
  final String category;
  final String priority;
  final String description;
  final String orderId;
  final DeliverySupportTicketStatus status;
  final DateTime? createdAt;
  final DateTime? lastResponseAt;
  final String lastResponse;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    this.priority = 'medium',
    this.description = '',
    this.orderId = '',
    this.status = DeliverySupportTicketStatus.open,
    this.createdAt,
    this.lastResponseAt,
    this.lastResponse = '',
  });

  SupportTicket copyWith({
    String? id,
    String? subject,
    String? category,
    String? priority,
    String? description,
    String? orderId,
    DeliverySupportTicketStatus? status,
    DateTime? createdAt,
    DateTime? lastResponseAt,
    String? lastResponse,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastResponseAt: lastResponseAt ?? this.lastResponseAt,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        category,
        priority,
        description,
        orderId,
        status,
        createdAt,
        lastResponseAt,
        lastResponse,
      ];
}

class FAQItem extends Equatable {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, category, question, answer];
}

class DeliveryHelpSupportPageState extends Equatable {
  final DeliveryHelpSupportStatus status;
  final List<SupportTicket> tickets;
  final List<FAQItem> faqs;
  final List<FAQItem> filteredFaqs;
  final String searchQuery;
  final String? selectedCategory;
  final DeliverySupportTicketFilter ticketFilter;
  final bool isSubmitting;
  final bool feedbackSuccess;
  final String? errorMessage;
  final String? successMessage;
  final String localeCode;

  const DeliveryHelpSupportPageState({
    this.status = DeliveryHelpSupportStatus.initial,
    this.tickets = const [],
    this.faqs = const [],
    this.filteredFaqs = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.ticketFilter = DeliverySupportTicketFilter.all,
    this.isSubmitting = false,
    this.feedbackSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.localeCode = 'en',
  });

  int get totalTickets => tickets.length;

  int get openTickets =>
      tickets.where((t) => t.status == DeliverySupportTicketStatus.open).length;

  int get resolvedTickets =>
      tickets
          .where((t) => t.status == DeliverySupportTicketStatus.resolved)
          .length;

  List<SupportTicket> get filteredTickets {
    return switch (ticketFilter) {
      DeliverySupportTicketFilter.all => tickets,
      DeliverySupportTicketFilter.open => tickets
          .where((t) => t.status == DeliverySupportTicketStatus.open)
          .toList(),
      DeliverySupportTicketFilter.inProgress => tickets
          .where((t) => t.status == DeliverySupportTicketStatus.inProgress)
          .toList(),
      DeliverySupportTicketFilter.resolved => tickets
          .where((t) => t.status == DeliverySupportTicketStatus.resolved)
          .toList(),
      DeliverySupportTicketFilter.escalated => tickets
          .where((t) => t.status == DeliverySupportTicketStatus.escalated)
          .toList(),
    };
  }

  DeliveryHelpSupportPageState copyWith({
    DeliveryHelpSupportStatus? status,
    List<SupportTicket>? tickets,
    List<FAQItem>? faqs,
    List<FAQItem>? filteredFaqs,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    DeliverySupportTicketFilter? ticketFilter,
    bool? isSubmitting,
    bool? feedbackSuccess,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    String? localeCode,
  }) {
    return DeliveryHelpSupportPageState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      faqs: faqs ?? this.faqs,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      ticketFilter: ticketFilter ?? this.ticketFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tickets,
        faqs,
        filteredFaqs,
        searchQuery,
        selectedCategory,
        ticketFilter,
        isSubmitting,
        feedbackSuccess,
        errorMessage,
        successMessage,
        localeCode,
      ];
}
