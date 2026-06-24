import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  group('CartPage Snapshot Tests', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {
        return null;
      });
    });

    testWidgets('Snapshot captures structural widget tree changes', (
      WidgetTester tester,
    ) async {
      when(() => mockCartBloc.state).thenReturn(const CartLoading());

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

      final stringRepresentation = tester
          .element(find.byType(CartPageUI))
          .toStringDeep();
      expect(stringRepresentation, isNotEmpty);
      expect(stringRepresentation, contains('CircularProgressIndicator'));
    });
  });
}
