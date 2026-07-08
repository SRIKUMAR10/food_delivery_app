import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';

import 'package:mocktail/mocktail.dart';

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  group('CartPage Accessibility Tests', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {
        return null;
      });
    });

    testWidgets('CartPage meets tap target and semantics guidelines', (
      WidgetTester tester,
    ) async {
      when(() => mockCartBloc.state).thenReturn(
        const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      );

      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>.value(
            value: mockCartBloc,
            child: CartPageUI(
              onNavigateToOrders: () {},
              onNavigateToWallet: () {},
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
