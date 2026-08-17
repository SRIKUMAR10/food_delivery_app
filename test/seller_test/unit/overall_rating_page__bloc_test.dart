import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  late OverallRatingBloc bloc;
  late MockSellerReviewService mockService;

  setUp(() {
    mockService = MockSellerReviewService();
    bloc = OverallRatingBloc(service: mockService);
  });

  tearDown(() {
    bloc.close();
  });

  ReviewModel review({
    String id = '1',
    String name = 'John',
    double rating = 5,
    String content = 'Great',
    bool reported = false,
    String? sellerReply,
  }) {
    return ReviewModel(
      id: id,
      authorName: name,
      authorAvatarUrl: '',
      rating: rating,
      content: content,
      date: DateTime(2024, 1, 1),
      customerId: 'cust_1',
      productName: 'Paneer Tikka',
      isReported: reported,
      sellerReply: sellerReply,
    );
  }

  Map<String, dynamic> buildPayload({List<Map<String, dynamic>>? reviews}) {
    return {
      'overallRating': 4.8,
      'totalReviews': reviews?.length ?? 1,
      'reviews': reviews ??
          [
            {
              'id': '1',
              'authorName': 'John',
              'authorAvatarUrl': '',
              'rating': 5.0,
              'content': 'Great',
              'date': '2024-01-01T00:00:00.000',
              'customerId': 'cust_1',
              'productName': 'Paneer Tikka',
            },
          ],
    };
  }

  OverallRatingLoaded loadedState({List<ReviewModel>? all}) {
    final reviews = all ?? [review()];
    return OverallRatingLoaded(
      overallRating: 4.8,
      totalReviews: reviews.length,
      breakdown: RatingBreakdownModel.fromReviews(reviews),
      allReviews: reviews,
      filteredReviews: reviews,
    );
  }

  group('OverallRatingBloc', () {
    test('initial state should be OverallRatingInitial', () {
      expect(bloc.state, isA<OverallRatingInitial>());
    });

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [Loading, Loaded] when LoadOverallRatingEvent succeeds',
      build: () {
        when(() => mockService.watchRatingsAndReviews())
            .thenAnswer((_) => Stream.value(buildPayload()));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOverallRatingEvent()),
      expect: () => [
        isA<OverallRatingLoading>(),
        isA<OverallRatingLoaded>()
            .having((s) => s.overallRating, 'overallRating', 4.8)
            .having((s) => s.totalReviews, 'totalReviews', 1)
            .having((s) => s.breakdown.fiveStar, 'fiveStar', 1),
      ],
      verify: (_) {
        verify(() => mockService.watchRatingsAndReviews()).called(1);
      },
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [Loading, Error] when the stream errors',
      build: () {
        when(() => mockService.watchRatingsAndReviews())
            .thenAnswer((_) => Stream.error(Exception('Failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOverallRatingEvent()),
      expect: () => [
        isA<OverallRatingLoading>(),
        isA<OverallRatingError>(),
      ],
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'FilterReviewsByStarEvent filters the reviews list',
      build: () => bloc,
      seed: () => loadedState(all: [review(id: '1', rating: 5), review(id: '2', rating: 3)]),
      act: (bloc) => bloc.add(const FilterReviewsByStarEvent(5)),
      expect: () => [
        isA<OverallRatingLoaded>()
            .having((s) => s.selectedStarFilter, 'selectedStarFilter', 5)
            .having((s) => s.filteredReviews.length, 'filteredReviews', 1),
      ],
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'FilterReviewsByTabEvent filters to unreplied reviews',
      build: () => bloc,
      seed: () => loadedState(all: [
            review(id: '1', sellerReply: null),
            review(id: '2', sellerReply: 'Thanks!'),
          ]),
      act: (bloc) => bloc.add(const FilterReviewsByTabEvent('unreplied')),
      expect: () => [
        isA<OverallRatingLoaded>()
            .having((s) => s.activeTabFilter, 'activeTabFilter', 'unreplied')
            .having((s) => s.filteredReviews.length, 'filteredReviews', 1),
      ],
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'SubmitSellerReplyEvent dispatches reply and reports success',
      build: () {
        when(() => mockService.submitSellerReply(
              reviewId: any(named: 'reviewId'),
              replyText: any(named: 'replyText'),
              authorName: any(named: 'authorName'),
              customerId: any(named: 'customerId'),
              productName: any(named: 'productName'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => loadedState(),
      act: (bloc) => bloc.add(const SubmitSellerReplyEvent(
            reviewId: '1',
            replyText: 'Thank you!',
            customerId: 'cust_1',
          )),
      expect: () => [
        isA<OverallRatingLoaded>()
            .having((s) => s.isSubmittingReply, 'isSubmittingReply', true),
        isA<OverallRatingLoaded>()
            .having((s) => s.isSubmittingReply, 'isSubmittingReply', false)
            .having((s) => s.actionMessage, 'actionMessage', 'replySubmittedSuccess'),
      ],
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'ReportReviewEvent dispatches report and reports success',
      build: () {
        when(() => mockService.reportInappropriateReview(
              reviewId: any(named: 'reviewId'),
              reason: any(named: 'reason'),
              details: any(named: 'details'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => loadedState(),
      act: (bloc) => bloc.add(const ReportReviewEvent(
            reviewId: '1',
            reason: 'Spam',
          )),
      expect: () => [
        isA<OverallRatingLoaded>()
            .having((s) => s.isReportingReview, 'isReportingReview', true),
        isA<OverallRatingLoaded>()
            .having((s) => s.isReportingReview, 'isReportingReview', false)
            .having((s) => s.actionMessage, 'actionMessage', 'reviewReportedSuccess'),
      ],
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'ClearActionMessageEvent clears the action message',
      build: () => bloc,
      seed: () => loadedState().copyWith(actionMessage: 'replySubmittedSuccess'),
      act: (bloc) => bloc.add(ClearActionMessageEvent()),
      expect: () => [
        isA<OverallRatingLoaded>()
            .having((s) => s.actionMessage, 'actionMessage', isNull),
      ],
    );
  });
}
