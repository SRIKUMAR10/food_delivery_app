// Real-Time Firestore Stream Provider Standardized
import 'Delivery_Help_Support_page_service.dart';
import 'Delivery_Help_Support_page_state.dart';

abstract class DeliveryHelpSupportPageRepositoryBase {
  Stream<List<SupportTicket>> watchSupportTickets();
  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String category,
    required String priority,
    required String description,
    String orderId,
  });
  Future<void> submitFeedback(int rating, String comment);
  Future<List<FAQItem>> getFAQs();
}

class DeliveryHelpSupportPageRepository
    implements DeliveryHelpSupportPageRepositoryBase {
  final DeliveryHelpSupportPageServiceBase _service;

  DeliveryHelpSupportPageRepository({
    DeliveryHelpSupportPageServiceBase? service,
  }) : _service = service ?? DeliveryHelpSupportPageService();

  @override
  Stream<List<SupportTicket>> watchSupportTickets() {
    return _service.watchSupportTickets().map(
          (rawList) => rawList.map(_mapTicket).toList(),
        );
  }

  @override
  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String category,
    required String priority,
    required String description,
    String orderId = '',
  }) async {
    final result = await _service.createSupportTicket({
      'subject': subject,
      'category': category,
      'priority': priority,
      'description': description,
      'orderId': orderId,
    });
    if (result['success'] != true) {
      throw Exception(
        result['error'] ?? 'Could not create support ticket. Please retry.',
      );
    }
    final now = DateTime.now();
    return SupportTicket(
      id: result['id'] ?? 'ticket_${now.millisecondsSinceEpoch}',
      subject: subject,
      category: category,
      priority: priority,
      description: description,
      orderId: orderId,
      status: DeliverySupportTicketStatus.open,
      createdAt: now,
    );
  }

  @override
  Future<void> submitFeedback(int rating, String comment) async {
    final result = await _service.submitFeedback(rating, comment);
    if (result['success'] != true) {
      throw Exception(
        result['error'] ?? 'Could not submit feedback. Please retry.',
      );
    }
  }

  @override
  Future<List<FAQItem>> getFAQs() async {
    final rawList = await _service.fetchFAQs();
    return rawList
        .map(
          (e) => FAQItem(
            id: e['id'] ?? '',
            category: e['category'] ?? 'General',
            question: e['question'] ?? '',
            answer: e['answer'] ?? '',
          ),
        )
        .toList();
  }

  SupportTicket _mapTicket(Map<String, dynamic> raw) {
    return SupportTicket(
      id: raw['id'] ?? '',
      subject: raw['subject'] ?? '',
      category: raw['category'] ?? 'Other',
      priority: raw['priority'] ?? 'medium',
      description: raw['description'] ?? '',
      orderId: raw['orderId'] ?? '',
      status: _statusFromString(raw['status'] ?? 'open'),
      createdAt: _parseDate(raw['createdAt']),
      lastResponseAt: _parseDate(raw['lastResponseAt']),
      lastResponse: raw['lastResponse'] ?? '',
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DeliverySupportTicketStatus _statusFromString(String value) {
    return switch (value.toLowerCase()) {
      'open' => DeliverySupportTicketStatus.open,
      'inprogress' || 'in_progress' => DeliverySupportTicketStatus.inProgress,
      'resolved' => DeliverySupportTicketStatus.resolved,
      'escalated' => DeliverySupportTicketStatus.escalated,
      _ => DeliverySupportTicketStatus.open,
    };
  }
}
