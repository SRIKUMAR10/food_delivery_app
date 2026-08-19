import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingPageBloc extends Mock implements RatingPageBloc {}

void main() {
  late MockRatingPageBloc mockBloc;

  setUp(() {
    mockBloc = MockRatingPageBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<RatingPageBloc>.value(
        value: mockBloc,
        child: child,
      ),
    );
  }

  group('Rating Page Golden Tests', () {
    testWidgets('Rating Page matches golden file for initial state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RatingInitial(rating: 5.0));

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingPageView(
            foodId: 'food123',
            foodName: 'Spicy Pizza',
          ),
        ),
      );

      await expectLater(
        find.byType(RatingPageView),
        matchesGoldenFile('goldens/rating_page_initial.png'),
      );
    });
  });
}
