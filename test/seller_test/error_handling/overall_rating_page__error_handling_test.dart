import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockOverallRatingBloc extends Mock implements OverallRatingBloc {}

void main() {
  testWidgets('Error Handling: Shows specific error message and retry button', (tester) async {
    final mockBloc = MockOverallRatingBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    
    // Simulate a network error state
    when(() => mockBloc.state).thenReturn(const OverallRatingError('Connection Timeout'));

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<OverallRatingBloc>.value(
        value: mockBloc,
        child: const OverallRatingPage(),
      ),
    ));

    // Verify Error Message
    expect(find.text('Error: Connection Timeout'), findsOneWidget);
    
    // Verify Retry Button
    expect(find.text('Retry'), findsOneWidget);

    // Tap Retry Button
    await tester.tap(find.text('Retry'));
    await tester.pump();

    // Verify Bloc received LoadEvent again
    // verify(() => mockBloc.add(LoadOverallRatingEvent())).called(1);
  });
}
