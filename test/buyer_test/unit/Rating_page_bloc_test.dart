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
  });
}
