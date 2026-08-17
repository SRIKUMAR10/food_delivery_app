import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryHelpSupportPageBloc
    extends MockBloc<DeliveryHelpSupportPageEvent, DeliveryHelpSupportPageState>
    implements DeliveryHelpSupportPageBloc {}

DeliveryHelpSupportPageState buildLoadedState() {
  final now = DateTime(2026, 8, 1);
  return DeliveryHelpSupportPageState(
    status: DeliveryHelpSupportStatus.loaded,
    tickets: [
      SupportTicket(
        id: 'ticket_abc123',
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
        id: 'ticket_xyz456',
        subject: 'GPS location drifting',
        category: 'Route / GPS',
        priority: 'medium',
        status: DeliverySupportTicketStatus.inProgress,
        createdAt: now,
      ),
      SupportTicket(
        id: 'ticket_lmn789',
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

void main() {
  late MockDeliveryHelpSupportPageBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
    registerFallbackValue(
      const DeliveryHelpSupportCreateTicketEvent(
        subject: 'fallback',
        category: 'Earnings',
        priority: 'medium',
        description: 'fallback',
      ),
    );
    registerFallbackValue(
      const DeliveryHelpSupportSearchFAQEvent(''),
    );
    registerFallbackValue(
      const DeliveryHelpSupportSubmitFeedbackEvent(rating: 1),
    );
    registerFallbackValue(const DeliveryHelpSupportInitEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryHelpSupportPageBloc();
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  void setLargeSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage({Future<void> Function(Uri uri)? launchCall}) {
    return BlocProvider<DeliveryHelpSupportPageBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: Scaffold(
          body: DeliveryHelpSupportPage(bloc: mockBloc, launchCall: launchCall),
        ),
      ),
    );
  }

  group('DeliveryHelpSupportPage Widget Tests', () {
    testWidgets('renders emergency banner, stats, tickets, FAQs and feedback', (
      tester,
    ) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_help_emergency_banner')), findsOneWidget);
      expect(find.text('Emergency Assistance'), findsOneWidget);
      expect(find.textContaining('1800 123 4567'), findsWidgets);
      expect(find.byKey(const Key('dp_help_call_button')), findsOneWidget);

      expect(find.byKey(const Key('dp_help_stats')), findsOneWidget);
      expect(find.text('Total Tickets'), findsOneWidget);
      expect(find.text('Open'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);

      expect(
        find.byKey(const Key('dp_help_create_ticket_button')),
        findsOneWidget,
      );
      expect(find.text('Create Support Ticket'), findsOneWidget);

      expect(find.byKey(const Key('dp_help_ticket_list')), findsOneWidget);
      expect(find.text('Payment not received for order'), findsOneWidget);
      expect(find.text('GPS location drifting'), findsOneWidget);
      expect(find.text('App crash during delivery'), findsOneWidget);

      expect(find.byKey(const Key('dp_help_faq_search')), findsOneWidget);
      expect(find.text('When will my earnings be credited?'), findsOneWidget);
      expect(find.text('GPS shows wrong location?'), findsOneWidget);

      expect(find.byKey(const Key('dp_help_feedback_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_help_rating_stars')), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('emergency call button launches the SOS hotline', (tester) async {
      setLargeSize(tester);
      final launchedUris = <Uri>[];
      await tester.pumpWidget(
        buildPage(
          launchCall: (uri) async {
            launchedUris.add(uri);
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_help_call_button')));
      await tester.pump();

      expect(launchedUris, hasLength(1));
      expect(launchedUris.single.toString(), 'tel:18001234567');
    });

    testWidgets('renders skeleton loaders during loading state', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.loading,
        ),
      );
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_help_skeleton')), findsOneWidget);
      expect(find.text('Emergency Assistance'), findsNothing);
    });

    testWidgets('renders error shell and retries init', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const DeliveryHelpSupportPageState(
          status: DeliveryHelpSupportStatus.error,
          errorMessage: 'Server unreachable',
        ),
      );
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'), warnIfMissed: false);
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryHelpSupportInitEvent()))
          .called(1);
    });

    testWidgets('create ticket dialog dispatches a create ticket event', (
      tester,
    ) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_help_create_ticket_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Support Ticket'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_help_ticket_category')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('dp_help_ticket_subject')),
        'Payment issue',
      );
      await tester.enterText(
        find.byKey(const Key('dp_help_ticket_description')),
        'Order delivered but not credited.',
      );
      await tester.enterText(
        find.byKey(const Key('dp_help_ticket_order_id')),
        'ORD12345',
      );

      await tester.ensureVisible(
        find.byKey(const Key('dp_help_ticket_submit')),
      );
      await tester.tap(find.byKey(const Key('dp_help_ticket_submit')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryHelpSupportCreateTicketEvent(
            subject: 'Payment issue',
            category: 'Order Issue',
            priority: 'medium',
            description: 'Order delivered but not credited.',
            orderId: 'ORD12345',
          ),
        ),
      ).called(1);
    });

    testWidgets('create ticket dialog validates empty fields', (tester) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_help_create_ticket_button')),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('dp_help_ticket_submit')),
      );
      await tester.tap(find.byKey(const Key('dp_help_ticket_submit')));
      await tester.pumpAndSettle();

      expect(find.text('Subject is required'), findsOneWidget);
      expect(find.text('Description is required'), findsOneWidget);
      verifyNever(
        () => mockBloc.add(any<DeliveryHelpSupportCreateTicketEvent>()),
      );
    });

    testWidgets('FAQ search field dispatches a search event', (tester) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_help_faq_search')),
        'gps',
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryHelpSupportSearchFAQEvent('gps')),
      ).called(1);
    });

    testWidgets('feedback card dispatches feedback event after rating', (
      tester,
    ) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('dp_help_star_4')));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_help_feedback_comment')),
        'Great support team',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_help_feedback_submit')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryHelpSupportSubmitFeedbackEvent(
            rating: 4,
            comment: 'Great support team',
          ),
        ),
      ).called(1);
    });

    testWidgets('feedback submit stays disabled without a rating', (
      tester,
    ) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final submitButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('dp_help_feedback_submit')),
      );
      expect(submitButton.onPressed, isNull);
      verifyNever(
        () => mockBloc.add(any<DeliveryHelpSupportSubmitFeedbackEvent>()),
      );
    });

    testWidgets('renders all 4 quick issue buttons and opens dialog when tapped', (
      tester,
    ) async {
      setLargeSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_help_report_order_btn')), findsOneWidget);
      expect(find.byKey(const Key('dp_help_report_payment_btn')), findsOneWidget);
      expect(find.byKey(const Key('dp_help_report_restaurant_btn')), findsOneWidget);
      expect(find.byKey(const Key('dp_help_report_customer_btn')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_help_report_order_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_help_ticket_subject')), findsOneWidget);
      expect(find.text('Order Issue'), findsWidgets);
    });
  });
}

