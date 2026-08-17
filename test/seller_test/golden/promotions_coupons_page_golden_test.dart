import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_model.dart';

class MockPromotionsCouponsBloc extends Mock implements PromotionsCouponsBloc {}

void main() {
  group('PromotionsCouponsPage Golden Tests', () {
    late MockPromotionsCouponsBloc mockBloc;

    setUp(() async {
      mockBloc = MockPromotionsCouponsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testGoldens('Coupons page layout should match golden file', (tester) async {
      await loadAppFonts();

      when(() => mockBloc.state).thenReturn(PromotionsCouponsLoaded(
        coupons: [
          CouponModel(
            id: 'g1',
            sellerId: 'seller_1',
            code: 'GOLDEN50',
            description: 'Golden ticket discount',
            discountAmount: 50,
            isPercentage: true,
            expiryDate: DateTime(2030, 1, 1),
            isActive: true,
          )
        ],
      ));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
        ..addScenario(
          name: 'Coupons Loaded State',
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocProvider<PromotionsCouponsBloc>.value(
              value: mockBloc,
              child: const PromotionsCouponsView(),
            ),
          ),
        );

      await tester.pumpDeviceBuilder(builder);
      // Wait for network images or animations if any
      await tester.pumpAndSettle();
      
      // Note: Run 'flutter test --update-goldens' to generate the golden files.
      await screenMatchesGolden(tester, 'promotions_coupons_page_golden');
    });
  });
}
