import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingRepository extends Mock implements IRatingRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('RatingPageBloc', () {
    late MockRatingRepository mockRepository;
    late MockAuthService mockAuthService;
    late RatingPageBloc bloc;

    setUp(() {
      mockRepository = MockRatingRepository();
      mockAuthService = MockAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.currentUserDisplayName).thenReturn('Test User');
      when(() => mockAuthService.currentUserPhotoUrl).thenReturn('https://example.com/photo.jpg');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => const Stream.empty());

      bloc = RatingPageBloc(
        ratingRepository: mockRepository,
        authService: mockAuthService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be RatingInitial', () {
      expect(bloc.state, isA<RatingInitial>());
    });

    group('RatingChanged', () {
      test('emits RatingUpdated with new rating', () {
        final expectedStates = [
          isA<RatingUpdated>().having((s) => s.rating, 'rating', 4.0),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const RatingChanged(4.0));
      });
    });

    group('SubmitPartnerRatingEvent', () {
      test('submits delivery partner rating and emits RatingSuccess', () async {
        when(() => mockRepository.submitPartnerRating(
              customerId: any(named: 'customerId'),
              customerName: any(named: 'customerName'),
              customerAvatarUrl: any(named: 'customerAvatarUrl'),
              partnerId: any(named: 'partnerId'),
              partnerName: any(named: 'partnerName'),
              orderId: any(named: 'orderId'),
              rating: any(named: 'rating'),
              reviewText: any(named: 'reviewText'),
              tags: any(named: 'tags'),
            )).thenAnswer((_) async {});

        final expectedStates = [
          isA<RatingLoading>(),
          isA<RatingSuccess>().having((s) => s.rating, 'rating', 4.8),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const SubmitPartnerRatingEvent(
          partnerId: 'partner_123',
          partnerName: 'Mani',
          orderId: 'order_456',
          rating: 4.8,
          reviewText: 'Great delivery!',
          tags: ['Fast'],
        ));
      });
    });
  });
}
