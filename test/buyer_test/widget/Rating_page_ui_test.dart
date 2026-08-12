import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockRatingPageBloc extends Mock implements RatingPageBloc {}
class FakeRatingPageEvent extends Fake implements RatingPageEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRatingPageEvent());
  });

  late MockRatingPageBloc mockBloc;

  setUp(() {
    mockBloc = MockRatingPageBloc();
    
    // Default state setup
    when(() => mockBloc.state).thenReturn(const RatingInitial(rating: 5.0));
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

  group('RatingPageView Widget Tests', () {
    testWidgets('renders initial UI elements correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingPageView(
            foodId: 'food123',
            foodName: 'Spicy Pizza',
          ),
        ),
      );

      // AppBar title
      expect(find.text('Rating'), findsOneWidget);
      // Main headers
      expect(find.text('How was your food?'), findsOneWidget);
      expect(find.text('Please rate Spicy Pizza'), findsOneWidget);
      // Review TextField
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);
    });

    testWidgets('slider changes dispatch RatingChanged event', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RatingPageView(
            foodId: 'food123',
            foodName: 'Spicy Pizza',
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      await tester.tap(slider);
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(any(that: isA<RatingChanged>()))).called(greaterThan(0));
    });

    testWidgets('Submit Review button dispatches SubmitRating event', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingPageView(
            foodId: 'food123',
            foodName: 'Spicy Pizza',
          ),
        ),
      );

      // Enter review text
      await tester.enterText(find.byType(TextField), 'Delicious!');
      await tester.pumpAndSettle();
      
      // Tap submit button
      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockBloc.add(any(that: isA<SubmitRating>())));
    });

    testWidgets('shows loading indicator when state is RatingLoading', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RatingLoading(rating: 5.0));

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingPageView(
            foodId: 'food123',
            foodName: 'Spicy Pizza',
          ),
        ),
      );

      // Should show CircularProgressIndicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Review'), findsNothing);
    });
  });
}
