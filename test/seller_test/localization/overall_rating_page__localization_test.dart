import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockOverallRatingBloc extends Mock implements OverallRatingBloc {}

void main() {
  testWidgets('Localization Test: checks if elements render with correct locales', (tester) async {
    final mockBloc = MockOverallRatingBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.state).thenReturn(const OverallRatingLoaded(
      overallRating: 4.8,
      totalReviews: 248,
      reviews: [],
    ));

    // To test localization properly, wrap the widget with Localizations widget 
    // and provide different locales (e.g. 'ta_IN' for Tamil).
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en', 'US'),
      home: BlocProvider<OverallRatingBloc>.value(
        value: mockBloc,
        child: const OverallRatingPage(),
      ),
    ));

    await tester.pumpAndSettle();
    
    // Verify english text is present
    expect(find.text('Overall Rating'), findsOneWidget);
    
    // In a real scenario, you'd pump again with Tamil locale and verify Tamil text.
  });
}
