import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_UI.dart';
import 'package:mocktail/mocktail.dart';

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  group('CartPageUI Golden Tests', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {
        return null;
      });
    });

    testWidgets('Golden test for CartLoaded state with items', (
      WidgetTester tester,
    ) async {
      final mockItems = [
        CartItem(
          id: '1',
          name: 'Pizza',
          price: 200.0,
          sellerId: '1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      when(() => mockCartBloc.state).thenReturn(
        CartLoaded(items: mockItems, totalAmount: 200.0, totalCount: 1),
      );

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

      await expectLater(
        find.byType(CartPageUI),
        matchesGoldenFile('goldens/cart_page_loaded.png'),
      );
    });
  });
}
