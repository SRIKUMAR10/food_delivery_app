import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_Repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/help_support_page.dart';

class MockHelpSupportRepository extends Mock implements HelpSupportRepository {}

void main() {
  late MockHelpSupportRepository mockRepository;

  const mockFaqs = [
    FaqItem(
      question: 'How do I place an order?',
      answer: 'Browse restaurants, add items to cart, and checkout.',
    ),
    FaqItem(
      question: 'How can I track my order?',
      answer: 'Go to My Orders and tap Track Order.',
    ),
  ];

  setUp(() {
    mockRepository = MockHelpSupportRepository();
    when(() => mockRepository.watchFaqs())
        .thenAnswer((_) => Stream.value(mockFaqs));
  });

  testWidgets('HelpSupportPage renders all menu options immediately without blocking', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HelpSupportPage(repository: mockRepository),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Help & Support'), findsWidgets);
    expect(find.text('FAQ'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Order Issues'), findsOneWidget);
    expect(find.text('Payment Issues'), findsOneWidget);
    expect(find.text('Delivery Issues'), findsOneWidget);
    expect(find.text('App Feedback'), findsOneWidget);
  });

  testWidgets('Tapping FAQ navigates to FAQ details page with loaded FAQs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HelpSupportPage(repository: mockRepository),
      ),
    );

    await tester.pumpAndSettle();

    final faqItem = find.text('FAQ');
    expect(faqItem, findsOneWidget);
    await tester.tap(faqItem);
    await tester.pumpAndSettle();

    expect(find.text('How do I place an order?'), findsOneWidget);
    expect(find.text('How can I track my order?'), findsOneWidget);
  });
}
