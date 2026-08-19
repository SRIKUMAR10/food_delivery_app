import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_state.dart';

class MockDeliveryHelpSupportPageService extends Mock
    implements DeliveryHelpSupportPageServiceBase {}

Map<String, dynamic> rawTicket({
  String id = 'ticket_abc123',
  String status = 'open',
  String category = 'Earnings',
  String createdAt = '2026-08-01T10:00:00.000',
}) {
  return {
    'id': id,
    'subject': 'Payment not received for order',
    'category': category,
    'priority': 'high',
    'description': 'Order delivered but earnings missing.',
    'orderId': 'ORD12345',
    'status': status,
    'createdAt': createdAt,
    'lastResponseAt': '2026-08-01T12:00:00.000',
    'lastResponse': 'We are reviewing your payout.',
  };
}

void main() {
  late MockDeliveryHelpSupportPageService mockService;

  setUp(() {
    mockService = MockDeliveryHelpSupportPageService();
  });

  group('DeliveryHelpSupportPage Repository Tests', () {
    test('watchSupportTickets maps raw service data into ticket models', () async {
      when(
        () => mockService.watchSupportTickets(),
      ).thenAnswer(
        (_) => Stream.value([
          rawTicket(),
          rawTicket(id: 'ticket_xyz456', status: 'in_progress'),
          rawTicket(id: 'ticket_lmn789', status: 'resolved'),
          rawTicket(id: 'ticket_esc111', status: 'escalated'),
        ]),
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      final tickets = await repository.watchSupportTickets().first;

      expect(tickets, hasLength(4));
      final first = tickets.first;
      expect(first.id, 'ticket_abc123');
      expect(first.subject, 'Payment not received for order');
      expect(first.category, 'Earnings');
      expect(first.priority, 'high');
      expect(first.description, 'Order delivered but earnings missing.');
      expect(first.orderId, 'ORD12345');
      expect(first.status, DeliverySupportTicketStatus.open);
      expect(first.createdAt, DateTime(2026, 8, 1, 10));
      expect(first.lastResponseAt, DateTime(2026, 8, 1, 12));
      expect(first.lastResponse, 'We are reviewing your payout.');
    });

    test('watchSupportTickets maps status strings to the correct enums', () async {
      when(
        () => mockService.watchSupportTickets(),
      ).thenAnswer(
        (_) => Stream.value([
          rawTicket(id: 't1', status: 'open'),
          rawTicket(id: 't2', status: 'in_progress'),
          rawTicket(id: 't3', status: 'inprogress'),
          rawTicket(id: 't4', status: 'resolved'),
          rawTicket(id: 't5', status: 'escalated'),
          rawTicket(id: 't6', status: 'unknown_value'),
        ]),
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      final tickets = await repository.watchSupportTickets().first;

      expect(
        tickets.where(
          (t) => t.status == DeliverySupportTicketStatus.open,
        ),
        hasLength(2),
      );
      expect(
        tickets.where(
          (t) => t.status == DeliverySupportTicketStatus.inProgress,
        ),
        hasLength(2),
      );
      expect(
        tickets.where(
          (t) => t.status == DeliverySupportTicketStatus.resolved,
        ),
        hasLength(1),
      );
      expect(
        tickets.where(
          (t) => t.status == DeliverySupportTicketStatus.escalated,
        ),
        hasLength(1),
      );
    });

    test('watchSupportTickets tolerates missing dates', () async {
      when(
        () => mockService.watchSupportTickets(),
      ).thenAnswer(
        (_) => Stream.value([
          {
            'id': 't1',
            'subject': 'No dates',
            'category': 'Other',
            'status': 'open',
          },
        ]),
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      final tickets = await repository.watchSupportTickets().first;

      expect(tickets.single.createdAt, isNull);
      expect(tickets.single.lastResponseAt, isNull);
      expect(tickets.single.subject, 'No dates');
    });

    test('createSupportTicket returns mapped ticket on success', () async {
      when(
        () => mockService.createSupportTicket(any()),
      ).thenAnswer((_) async => {'success': true, 'id': 'ticket_new_1'});

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      final ticket = await repository.createSupportTicket(
        subject: 'New issue',
        category: 'Earnings',
        priority: 'high',
        description: 'Details',
        orderId: 'ORD999',
      );

      expect(ticket.id, 'ticket_new_1');
      expect(ticket.subject, 'New issue');
      expect(ticket.category, 'Earnings');
      expect(ticket.priority, 'high');
      expect(ticket.description, 'Details');
      expect(ticket.orderId, 'ORD999');
      expect(ticket.status, DeliverySupportTicketStatus.open);
      expect(ticket.createdAt, isNotNull);

      verify(
        () => mockService.createSupportTicket({
          'subject': 'New issue',
          'category': 'Earnings',
          'priority': 'high',
          'description': 'Details',
          'orderId': 'ORD999',
        }),
      ).called(1);
    });

    test('createSupportTicket throws when the service reports failure', () async {
      when(
        () => mockService.createSupportTicket(any()),
      ).thenAnswer(
        (_) async => {'success': false, 'error': 'offline'},
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );

      expect(
        () => repository.createSupportTicket(
          subject: 'New issue',
          category: 'Earnings',
          priority: 'medium',
          description: 'Details',
        ),
        throwsException,
      );
    });

    test('submitFeedback delegates to the service on success', () async {
      when(
        () => mockService.submitFeedback(5, 'Great support'),
      ).thenAnswer((_) async => {'success': true});

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      await repository.submitFeedback(5, 'Great support');

      verify(() => mockService.submitFeedback(5, 'Great support')).called(1);
    });

    test('submitFeedback throws when the service reports failure', () async {
      when(
        () => mockService.submitFeedback(any(), any()),
      ).thenAnswer(
        (_) async => {'success': false, 'error': 'offline'},
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );

      expect(
        () => repository.submitFeedback(4, 'ok'),
        throwsException,
      );
    });

    test('getFAQs maps raw service data into FAQ item models', () async {
      when(
        () => mockService.fetchFAQs(),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'faq_1',
            'category': 'Earnings',
            'question': 'When will my earnings be credited?',
            'answer': 'Within 24 hours.',
          },
          {
            'id': 'faq_2',
            'category': 'Route / GPS',
            'question': 'GPS wrong?',
            'answer': 'Restart the app.',
          },
        ],
      );

      final repository = DeliveryHelpSupportPageRepository(
        service: mockService,
      );
      final faqs = await repository.getFAQs();

      expect(faqs, hasLength(2));
      expect(faqs.first.id, 'faq_1');
      expect(faqs.first.category, 'Earnings');
      expect(faqs.first.question, 'When will my earnings be credited?');
      expect(faqs.first.answer, 'Within 24 hours.');
      expect(faqs.last.category, 'Route / GPS');
    });
  });
}
