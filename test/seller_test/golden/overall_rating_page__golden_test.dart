import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';
import 'package:mocktail/mocktail.dart';


class MockOverallRatingBloc extends Mock implements OverallRatingBloc {}

void main() {
  late MockOverallRatingBloc mockBloc;

  setUp(() {
    mockBloc = MockOverallRatingBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Golden Test for Overall Rating Page Loaded State', (tester) async {
    final reviews = [
      ReviewModel(
        id: '1',
        authorName: 'Jane Smith',
        authorAvatarUrl: 'http://test.com/img',
        rating: 4.5,
        content: 'Great food!',
        date: DateTime(2024, 1, 1),
      )
    ];
    when(() => mockBloc.state).thenReturn(OverallRatingLoaded(
      overallRating: 4.8,
      totalReviews: 248,
      breakdown: RatingBreakdownModel.fromReviews(reviews),
      allReviews: reviews,
      filteredReviews: reviews,
    ));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlocProvider<OverallRatingBloc>.value(
          value: mockBloc,
          child: const RepaintBoundary(
            child: OverallRatingPage(),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Verify UI matches the golden master image
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/overall_rating_page_loaded.png'),
    );
  });
}
