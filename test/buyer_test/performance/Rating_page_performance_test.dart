import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingPageBloc extends Mock implements RatingPageBloc {}

void main() {
  group('Rating Page Performance Tests', () {
    testWidgets('Rating page builds efficiently without frame drops', (WidgetTester tester) async {
      final mockBloc = MockRatingPageBloc();
      when(() => mockBloc.state).thenReturn(const RatingInitial(rating: 5.0));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // Start timing
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RatingPageBloc>.value(
            value: mockBloc,
            child: const RatingPageView(
              foodId: 'food123',
              foodName: 'Test Food',
            ),
          ),
        ),
      );

      // Verify the widget built under threshold
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(200), reason: 'Build time exceeds performance limits.');
    });
  });
}
