import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart';

class MockPromotionsCouponsBloc extends Mock implements PromotionsCouponsBloc {}

void main() {
  group('PromotionsCouponsPage UI Tests', () {
    late MockPromotionsCouponsBloc mockBloc;

    final dummyCoupon = CouponModel(
      id: 'coupon_01',
      sellerId: 'seller_100',
      code: 'SUPER50',
      description: 'Flat 50% discount on all items',
      discountAmount: 50.0,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 20)),
      isActive: true,
      offerScope: 'restaurant',
    );

    setUp(() {
      mockBloc = MockPromotionsCouponsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget buildTestWidget(PromotionsCouponsState state) {
      when(() => mockBloc.state).thenReturn(state);
      return MaterialApp(
        home: BlocProvider<PromotionsCouponsBloc>.value(
          value: mockBloc,
          child: const PromotionsCouponsView(),
        ),
      );
    }

    testWidgets('renders loading indicator when state is PromotionsCouponsLoading', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PromotionsCouponsLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no coupons exist', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PromotionsCouponsLoaded(coupons: [])));

      expect(find.text('No Promotions Found'), findsOneWidget);
      expect(find.text('Create First Coupon'), findsOneWidget);
    });

    testWidgets('renders coupon cards with code, discount and switch when loaded', (tester) async {
      await tester.pumpWidget(buildTestWidget(PromotionsCouponsLoaded(coupons: [dummyCoupon])));

      expect(find.text('SUPER50'), findsOneWidget);
      expect(find.text('50% OFF'), findsOneWidget);
      expect(find.text('Flat 50% discount on all items'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders header and search bar on screen', (tester) async {
      await tester.pumpWidget(buildTestWidget(PromotionsCouponsLoaded(coupons: [dummyCoupon])));

      expect(find.text('Coupons & Offers'), findsOneWidget);
      expect(find.text('Active Offers'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
