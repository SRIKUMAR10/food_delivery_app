import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockOverallRatingBloc extends Mock implements OverallRatingBloc {}

void main() {
  late MockOverallRatingBloc mockBloc;

  setUp(() {
    mockBloc = MockOverallRatingBloc();
    // Provide a dummy stream for bloc state
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OverallRatingBloc>.value(
        value: mockBloc,
        child: const OverallRatingPage(),
      ),
    );
  }

  group('OverallRatingPage UI Widget Tests', () {
    testWidgets('shows loading skeleton when state is Initial', (tester) async {
      when(() => mockBloc.state).thenReturn(OverallRatingInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify that LoadEvent is dispatched
      verify(() => mockBloc.add(LoadOverallRatingEvent())).called(1);
      
      // We expect ListView to be rendered for skeleton
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows rating data when state is Loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(OverallRatingLoaded(
        overallRating: 4.8,
        totalReviews: 248,
        reviews: [
          ReviewModel(
            id: '1',
            authorName: 'Mike Ross',
            authorAvatarUrl: 'http://test.com/img.png',
            rating: 5,
            content: 'Great food and fast delivery!',
            date: DateTime(2024, 5, 1),
          )
        ],
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Overall Rating'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(248 reviews)'), findsOneWidget);
      expect(find.text('Mike Ross'), findsOneWidget);
      expect(find.text('Great food and fast delivery!'), findsOneWidget);
      expect(find.text('View All Reviews'), findsOneWidget);
    });

    testWidgets('shows error message when state is Error', (tester) async {
      when(() => mockBloc.state).thenReturn(const OverallRatingError('Network Failure'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error: Network Failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
