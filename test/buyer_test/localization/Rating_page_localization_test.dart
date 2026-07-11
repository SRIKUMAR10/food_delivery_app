import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingPageBloc extends Mock implements RatingPageBloc {}

void main() {
  group('Rating Page Localization Tests', () {
    testWidgets('Verifies static texts are displayed correctly (Mocking Localization)', (WidgetTester tester) async {
      final mockBloc = MockRatingPageBloc();
      when(() => mockBloc.state).thenReturn(const RatingInitial(rating: 5.0));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RatingPageBloc>.value(
            value: mockBloc,
            child: const RatingPageView(
              foodId: 'food123',
              foodName: 'Spicy Pizza',
            ),
          ),
        ),
      );

      // Check English defaults (as there's no intl package setup shown in the file)
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('How was your food?'), findsOneWidget);
      expect(find.text('Please rate Spicy Pizza'), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);
    });
  });
}
