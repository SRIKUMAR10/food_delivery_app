import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Help_Support_page/Delivery_Help_Support_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryHelpSupportPage Service Tests', () {
    late DeliveryHelpSupportPageService service;

    setUp(() {
      service = DeliveryHelpSupportPageService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
    });

    test(
      'watchSupportTickets emits an empty list when unauthenticated',
      () async {
        final tickets = await service.watchSupportTickets().first;

        expect(tickets, isEmpty);
      },
    );

    test(
      'createSupportTicket fails gracefully when unauthenticated',
      () async {
        final result = await service.createSupportTicket({
          'subject': 'New issue',
          'category': 'Earnings',
          'priority': 'medium',
          'description': 'Details',
        });

        expect(result['success'], isFalse);
        expect(result['error'], isNotNull);
      },
    );

    test(
      'submitFeedback fails gracefully when unauthenticated',
      () async {
        final result = await service.submitFeedback(5, 'Great support');

        expect(result['success'], isFalse);
        expect(result['error'], isNotNull);
      },
    );

    test(
      'fetchFAQs falls back to the bundled catalog when Firestore is unavailable',
      () async {
        final faqs = await service.fetchFAQs();

        expect(faqs, isNotEmpty);
        expect(faqs.length, greaterThanOrEqualTo(5));
        for (final faq in faqs) {
          expect(faq['id'], isNotNull);
          expect(faq['category'], isNotNull);
          expect(faq['question'], isNotNull);
          expect(faq['answer'], isNotNull);
        }
        final questions =
            faqs.map((faq) => faq['question'] as String).toList();
        expect(
          questions,
          contains('When will my earnings be credited to my wallet?'),
        );
        expect(
          questions,
          contains('The app keeps crashing during an active delivery. What now?'),
        );
      },
    );

    test(
      'fetchFAQs returns a structured catalog covering all support categories',
      () async {
        final faqs = await service.fetchFAQs();

        final categories = faqs
            .map((faq) => faq['category'] as String)
            .toSet();
        expect(categories, contains('Earnings'));
        expect(categories, contains('Route / GPS'));
        expect(categories, contains('App Technical'));
        expect(categories, contains('Customer Issue'));
      },
    );

    test('hotline number is exposed for the emergency banner', () {
      expect(DeliveryHelpSupportPageService.hotlineNumber, '18001234567');
    });
  });
}
