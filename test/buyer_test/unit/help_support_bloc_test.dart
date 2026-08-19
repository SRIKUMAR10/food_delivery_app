import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/HelpSupportPage/HelpSupport_Repository.dart';

class MockHelpSupportRepository extends Mock implements HelpSupportRepository {}

void main() {
  group('HelpSupportBloc Unit Tests', () {
    late MockHelpSupportRepository mockRepository;
    late HelpSupportBloc bloc;

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
      bloc = HelpSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, HelpSupportStatus.initial);
      expect(bloc.state.faqItems, isEmpty);
    });

    test('LoadHelpContent streams real-time FAQ items from repository', () async {
      bloc.add(const LoadHelpContent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const HelpSupportState(status: HelpSupportStatus.loading),
          const HelpSupportState(
            status: HelpSupportStatus.loaded,
            faqItems: mockFaqs,
          ),
        ]),
      );
      verify(() => mockRepository.watchFaqs()).called(1);
    });

    test('SubmitSupportTicket emits submitting and success on completion', () async {
      when(() => mockRepository.submitSupportTicket(
            type: any(named: 'type'),
            subject: any(named: 'subject'),
            message: any(named: 'message'),
            orderId: any(named: 'orderId'),
          )).thenAnswer((_) async {});

      bloc.add(const SubmitSupportTicket(
        type: 'Payment',
        subject: 'Double charge',
        message: 'Charged twice for order 123',
        orderId: 'ORD-123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const HelpSupportState(status: HelpSupportStatus.submitting),
          isA<HelpSupportState>().having(
            (s) => s.status,
            'status',
            HelpSupportStatus.success,
          ),
        ]),
      );

      verify(() => mockRepository.submitSupportTicket(
            type: 'Payment',
            subject: 'Double charge',
            message: 'Charged twice for order 123',
            orderId: 'ORD-123',
          )).called(1);
    });

    test('SubmitFeedback emits submitting and success on completion', () async {
      when(() => mockRepository.submitFeedback(
            rating: any(named: 'rating'),
            comments: any(named: 'comments'),
          )).thenAnswer((_) async {});

      bloc.add(const SubmitFeedback(
        rating: 5,
        comments: 'Great food delivery service!',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const HelpSupportState(status: HelpSupportStatus.submitting),
          isA<HelpSupportState>().having(
            (s) => s.status,
            'status',
            HelpSupportStatus.success,
          ),
        ]),
      );

      verify(() => mockRepository.submitFeedback(
            rating: 5,
            comments: 'Great food delivery service!',
          )).called(1);
    });
  });
}
