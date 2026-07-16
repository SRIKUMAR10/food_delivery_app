import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart';

class MockPromotionsCouponsBloc extends Mock implements PromotionsCouponsBloc {}

void main() {
  group('PromotionsCouponsPage UI Tests', () {
    late MockPromotionsCouponsBloc mockBloc;

    setUp(() {
      mockBloc = MockPromotionsCouponsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<PromotionsCouponsBloc>.value(
          value: mockBloc,
          child: const PromotionsCouponsView(),
        ),
      );
    }

    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(PromotionsCouponsLoading());
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state correctly', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(PromotionsCouponsLoaded(coupons: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('No coupons available. Add one to boost sales!'), findsOneWidget);
    });

    testWidgets('shows Add Coupon dialog when FAB is pressed', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(PromotionsCouponsLoaded(coupons: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Create New Coupon'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
