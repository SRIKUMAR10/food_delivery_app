import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingPageBloc extends Mock implements RatingPageBloc {}

void main() {
  group('Rating Page Accessibility Tests', () {
    testWidgets('Rating page meets accessibility guidelines', (WidgetTester tester) async {
      final mockBloc = MockRatingPageBloc();
      when(() => mockBloc.state).thenReturn(const RatingInitial(rating: 5.0));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      final SemanticsHandle handle = tester.ensureSemantics();

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

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      // Basic accessibility checks
      expect(find.byType(Slider), findsOneWidget); // Slider is accessible by default
      expect(find.byType(TextField), findsOneWidget);

      handle.dispose();
    });
  });
}
