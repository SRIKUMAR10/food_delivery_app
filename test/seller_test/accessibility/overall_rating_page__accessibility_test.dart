import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../lib/features/Seller Bloc Architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/Seller Bloc Architecture/overall_rating_page/overall_rating_page__state.dart';
import '../../../../lib/features/Seller Bloc Architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockOverallRatingBloc extends Mock implements OverallRatingBloc {}

void main() {
  testWidgets('Accessibility Test for Overall Rating Page', (tester) async {
    final mockBloc = MockOverallRatingBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.state).thenReturn(OverallRatingLoaded(
      overallRating: 4.8,
      totalReviews: 248,
      reviews: [],
    ));

    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<OverallRatingBloc>.value(
        value: mockBloc,
        child: const OverallRatingPage(),
      ),
    ));

    // Checks that text meets contrast and tap targets are sized properly
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
