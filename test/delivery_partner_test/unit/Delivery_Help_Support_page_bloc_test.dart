import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_service.dart';

class MockDeliveryHelpSupportPageRepository extends Mock
    implements DeliveryHelpSupportPageRepositoryBase {}

class MockDeliveryHelpSupportPageService extends Mock
    implements DeliveryHelpSupportPageServiceBase {}

DeliveryHelpSupportPageState buildLoadedState() {
  final now = DateTime(2026, 8, 1);
  return DeliveryHelpSupportPageState(
    status: DeliveryHelpSupportStatus.loaded,
    tickets: [
      SupportTicket(
        id: 'ticket_1',
        subject: 'Payment not received for order',
        category: 'Earnings',
        priority: 'high',
        description: 'Order delivered but earnings missing.',
        orderId: 'ORD12345',
        status: DeliverySupportTicketStatus.open,
        createdAt: now,
        lastResponseAt: now,
        lastResponse: 'We are reviewing your payout.',
      ),
      SupportTicket(
        id: 'ticket_2',
        subject: 'GPS location drifting',
        category: 'Route / GPS',
        priority: 'medium',
        status: DeliverySupportTicketStatus.inProgress,
        createdAt: now,
      ),
      SupportTicket(
        id: 'ticket_3',
        subject: 'App crash during delivery',
        category: 'App Technical',
        priority: 'urgent',
        status: DeliverySupportTicketStatus.resolved,
        createdAt: now,
      ),
    ],
    faqs: const [
      FAQItem(
        id: 'faq_1',
        category: 'Earnings',
        question: 'When will my earnings be credited?',
        answer: 'Earnings are credited within 24 hours.',
      ),
      FAQItem(
        id: 'faq_2',
        category: 'Route / GPS',
        question: 'GPS shows wrong location?',
        answer: 'Enable high accuracy location and restart the app.',
      ),
      FAQItem(
        id: 'faq_3',
        category: 'App Technical',
        question: 'How do I update the app?',
        answer: 'Check the store for the latest version.',
      ),
    ],
    filteredFaqs: const [
      FAQItem(
        id: 'faq_1',
        category: 'Earnings',
        question: 'When will my earnings be credited?',
        answer: 'Earnings are credited within 24 hours.',
      ),
      FAQItem(
        id: 'faq_2',
        category: 'Route / GPS',
        question: 'GPS shows wrong location?',
        answer: 'Enable high accuracy location and restart the app.',
      ),
      FAQItem(
        id: 'faq_3',
        category: 'App Technical',
        question: 'How do I update the app?',
        answer: 'Check the store for the latest version.',
      ),
    ],
  );
}

Future<void> pumpMicrotasks([int times = 3]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MockDeliveryHelpSupportPageRepository mockRepository;
  late MockDeliveryHelpSupportPageService mockService;

  setUp(() {
    mockRepository = MockDeliveryHelpSupportPageRepository();
    mockService = MockDeliveryHelpSupportPageService();
  });

  group('DeliveryHelpSupportPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state.status, DeliveryHelpSupportStatus.initial);
      expect(bloc.state.tickets, isEmpty);
      expect(bloc.state.faqs, isEmpty);
      expect(bloc.state.filteredFaqs, isEmpty);
      expect(bloc.state.searchQuery, '');
      expect(bloc.state.selectedCategory, isNull);
      expect(
        bloc.state.ticketFilter,
        DeliverySupportTicketFilter.all,
      );
      expect(bloc.state.isSubmitting, isFalse);
      expect(bloc.state.feedbackSuccess, isFalse);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    test('filteredTickets respects the selected ticket filter', () {
      final openOnly = buildLoadedState().copyWith(
        ticketFilter: DeliverySupportTicketFilter.open,
      );
      expect(openOnly.filteredTickets, hasLength(1));
      expect(
        openOnly.filteredTickets.first.status,
        DeliverySupportTicketStatus.open,
      );

      final all = buildLoadedState().copyWith(
        ticketFilter: DeliverySupportTicketFilter.all,
      );
      expect(all.filteredTickets, hasLength(3));
    });

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'emits [loading, loaded, tickets updated] on init success with real-time stream',
      build: () {
        when(
          () => mockRepository.getFAQs(),
        ).thenAnswer((_) async => buildLoadedState().faqs);
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) async {
        final controller = StreamController<List<SupportTicket>>.broadcast();
        when(
          () => mockRepository.watchSupportTickets(),
        ).thenAnswer((_) => controller.stream);
        bloc.add(const DeliveryHelpSupportInitEvent());
        await pumpMicrotasks();
        controller.add([
          const SupportTicket(
            id: 'ticket_1',
            subject: 'Payment not received for order',
            category: 'Earnings',
            status: DeliverySupportTicketStatus.resolved,
          ),
        ]);
        await pumpMicrotasks();
        await controller.close();
      },
      expect: () => [
        const DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.loading,
        ),
        DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.loaded,
          faqs: buildLoadedState().faqs,
          filteredFaqs: buildLoadedState().faqs,
        ),
        DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.loaded,
          tickets: [
            const SupportTicket(
              id: 'ticket_1',
              subject: 'Payment not received for order',
              category: 'Earnings',
              status: DeliverySupportTicketStatus.resolved,
            ),
          ],
          faqs: buildLoadedState().faqs,
          filteredFaqs: buildLoadedState().faqs,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getFAQs()).called(1);
        verify(() => mockRepository.watchSupportTickets()).called(1);
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'emits [loading, error] on init failure',
      build: () {
        when(
          () => mockRepository.getFAQs(),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryHelpSupportInitEvent()),
      expect: () => [
        const DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.loading,
        ),
        const DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.error,
          errorMessage: 'Exception: Server unreachable',
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'search query filters FAQ items by text',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSearchFAQEvent('gps'),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          searchQuery: 'gps',
          filteredFaqs: const [
            FAQItem(
              id: 'faq_2',
              category: 'Route / GPS',
              question: 'GPS shows wrong location?',
              answer: 'Enable high accuracy location and restart the app.',
            ),
          ],
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'selecting a category filters FAQ items by category',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSelectCategoryEvent('Earnings'),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          selectedCategory: 'Earnings',
          filteredFaqs: const [
            FAQItem(
              id: 'faq_1',
              category: 'Earnings',
              question: 'When will my earnings be credited?',
              answer: 'Earnings are credited within 24 hours.',
            ),
          ],
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'selecting "all" clears the FAQ category filter',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState().copyWith(
        selectedCategory: 'Earnings',
        filteredFaqs: const [
          FAQItem(
            id: 'faq_1',
            category: 'Earnings',
            question: 'When will my earnings be credited?',
            answer: 'Earnings are credited within 24 hours.',
          ),
        ],
      ),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSelectCategoryEvent('all'),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          selectedCategory: null,
          clearCategory: true,
          filteredFaqs: buildLoadedState().faqs,
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'ticket filter event updates the ticket filter',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSelectTicketFilterEvent(
          DeliverySupportTicketFilter.open,
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          ticketFilter: DeliverySupportTicketFilter.open,
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'create ticket emits submitting then success with message',
      build: () {
        when(
          () => mockRepository.createSupportTicket(
            subject: any(named: 'subject'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            description: any(named: 'description'),
            orderId: any(named: 'orderId'),
          ),
        ).thenAnswer(
          (_) async => const SupportTicket(
            id: 'ticket_new',
            subject: 'New issue',
            category: 'Earnings',
            priority: 'high',
            description: 'Details',
            status: DeliverySupportTicketStatus.open,
          ),
        );
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportCreateTicketEvent(
          subject: 'New issue',
          category: 'Earnings',
          priority: 'high',
          description: 'Details',
          orderId: 'ORD999',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          status: DeliveryHelpSupportStatus.submitting,
          isSubmitting: true,
          clearError: true,
          clearSuccess: true,
        ),
        buildLoadedState().copyWith(
          isSubmitting: false,
          successMessage: 'Your support ticket has been submitted.',
          clearError: true,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.createSupportTicket(
            subject: any(named: 'subject'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            description: any(named: 'description'),
            orderId: any(named: 'orderId'),
          ),
        ).called(1);
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'create ticket rejects empty subject without calling repository',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportCreateTicketEvent(
          subject: '   ',
          category: 'Earnings',
          priority: 'medium',
          description: 'Some description',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Please enter a subject for your support ticket.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockRepository.createSupportTicket(
            subject: any(named: 'subject'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            description: any(named: 'description'),
            orderId: any(named: 'orderId'),
          ),
        );
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'create ticket rejects empty description without calling repository',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportCreateTicketEvent(
          subject: 'Subject here',
          category: 'Earnings',
          priority: 'medium',
          description: '   ',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Please describe the issue you are facing.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockRepository.createSupportTicket(
            subject: any(named: 'subject'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            description: any(named: 'description'),
            orderId: any(named: 'orderId'),
          ),
        );
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'create ticket failure emits friendly error and resets submitting',
      build: () {
        when(
          () => mockRepository.createSupportTicket(
            subject: any(named: 'subject'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            description: any(named: 'description'),
            orderId: any(named: 'orderId'),
          ),
        ).thenThrow(Exception('offline'));
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportCreateTicketEvent(
          subject: 'New issue',
          category: 'Earnings',
          priority: 'medium',
          description: 'Details',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          status: DeliveryHelpSupportStatus.submitting,
          isSubmitting: true,
          clearError: true,
          clearSuccess: true,
        ),
        buildLoadedState().copyWith(
          isSubmitting: false,
          errorMessage: 'Could not submit ticket. Please try again.',
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'submit feedback emits success flag and message on success',
      build: () {
        when(
          () => mockRepository.submitFeedback(4, 'Great support'),
        ).thenAnswer((_) async {});
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSubmitFeedbackEvent(
          rating: 4,
          comment: 'Great support',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          isSubmitting: true,
          clearError: true,
          clearSuccess: true,
        ),
        buildLoadedState().copyWith(
          isSubmitting: false,
          feedbackSuccess: true,
          successMessage: 'Thank you for your feedback!',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.submitFeedback(4, 'Great support'))
            .called(1);
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'submit feedback rejects invalid rating without calling repository',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSubmitFeedbackEvent(rating: 0),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Please select a rating between 1 and 5 stars.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.submitFeedback(any(), any()));
      },
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'submit feedback failure emits friendly error and resets submitting',
      build: () {
        when(
          () => mockRepository.submitFeedback(any(), any()),
        ).thenThrow(Exception('offline'));
        return DeliveryHelpSupportPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportSubmitFeedbackEvent(
          rating: 5,
          comment: 'Great',
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          isSubmitting: true,
          clearError: true,
          clearSuccess: true,
        ),
        buildLoadedState().copyWith(
          isSubmitting: false,
          errorMessage: 'Could not submit feedback. Please try again.',
        ),
      ],
    );

    blocTest<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      'tickets updated event replaces the ticket list and clears errors',
      build: () => DeliveryHelpSupportPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryHelpSupportTicketsUpdatedEvent([
          SupportTicket(
            id: 'ticket_x',
            subject: 'Resolved issue',
            category: 'Customer Issue',
            status: DeliverySupportTicketStatus.resolved,
          ),
        ]),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          tickets: [
            const SupportTicket(
              id: 'ticket_x',
              subject: 'Resolved issue',
              category: 'Customer Issue',
              status: DeliverySupportTicketStatus.resolved,
            ),
          ],
          clearError: true,
        ),
      ],
    );
  });
}
