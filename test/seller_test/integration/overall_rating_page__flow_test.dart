import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockOverallRatingRepository extends Mock implements OverallRatingRepository {}

void main() {
  late MockOverallRatingRepository mockRepository;
  late OverallRatingBloc bloc;

  setUp(() {
    mockRepository = MockOverallRatingRepository();
    bloc = OverallRatingBloc(repository: mockRepository);
  });

  Widget buildApp() {
    return MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: const OverallRatingPage(),
      ),
    );
  }

  testWidgets('Full flow integration: Loading to Success to Refresh', (tester) async {
    // 1. Initial State -> should trigger LoadEvent
    when(() => mockRepository.getOverallRatingData()).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100)); // simulate network delay
      return OverallRatingLoaded(
        overallRating: 4.5,
        totalReviews: 100,
        reviews: [],
      );
    });

    await tester.pumpWidget(buildApp());
    expect(find.byType(ListView), findsOneWidget); // Loading skeleton

    // 2. Wait for network call to finish and UI to update
    await tester.pumpAndSettle();
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(100 reviews)'), findsOneWidget);

    // 3. Trigger pull to refresh
    // Mocking new data for refresh
    when(() => mockRepository.getOverallRatingData()).thenAnswer((_) async {
      return OverallRatingLoaded(
        overallRating: 4.9,
        totalReviews: 105,
        reviews: [],
      );
    });

    await tester.fling(find.byType(ListView), const Offset(0.0, 300.0), 1000.0);
    await tester.pumpAndSettle();

    // Verify UI updated with new data
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('(105 reviews)'), findsOneWidget);
  });
}
