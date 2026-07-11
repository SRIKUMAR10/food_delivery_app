import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

void main() {
  testWidgets('Performance test for rendering a large number of reviews', (tester) async {
    // We mock a repository that returns a very large list of reviews to test list rendering performance.
    // In a real app this should be paginated, but here we test the widget rendering capability.
    
    // Build Widget
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<OverallRatingBloc>(
        create: (_) => OverallRatingBloc(
          repository: _MockPerfRepository(),
        )..add(LoadOverallRatingEvent()),
        child: const OverallRatingPage(),
      ),
    ));

    await tester.pumpAndSettle();

    // Measure scroll performance
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 5; i++) {
      await tester.fling(find.byType(ListView), const Offset(0, -1000), 5000);
      await tester.pumpAndSettle();
    }
    
    stopwatch.stop();
    // Validate it doesn't take too long (e.g. less than 2 seconds for all flings)
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
  });
}

class _MockPerfRepository implements OverallRatingRepository {
  @override
  Future<OverallRatingLoaded> getOverallRatingData() async {
    return OverallRatingLoaded(
      overallRating: 4.8,
      totalReviews: 248,
      reviews: List.generate(100, (index) => ReviewModel(
        id: index.toString(),
        authorName: 'User $index',
        authorAvatarUrl: '',
        rating: 4.0,
        content: 'Review Content',
        date: DateTime.now(),
      )),
    );
  }
}
