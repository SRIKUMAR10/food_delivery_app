import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart';

class MockPromotionsCouponsBloc extends Mock implements PromotionsCouponsBloc {}

void main() {
  group('PromotionsCouponsPage Accessibility Test', () {
    late MockPromotionsCouponsBloc mockBloc;

    setUp(() {
      mockBloc = MockPromotionsCouponsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Accessibility guidelines met', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(PromotionsCouponsLoaded(coupons: []));
      
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PromotionsCouponsBloc>.value(
            value: mockBloc,
            child: const PromotionsCouponsView(),
          ),
        ),
      );

      // Verify that all tappable targets have sufficient contrast and tap area size
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      
      handle.dispose();
    });
  });
}
