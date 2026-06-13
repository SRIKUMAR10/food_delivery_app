// test/cart_page/cart_page_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Buyer Bloc Architecture/Cart Page/cart_page.dart';

Widget _buildApp() {
  return MaterialApp(
    home: BlocProvider<CartBloc>(
      create: (_) => CartBloc(),
      child: const CartPageUI(),
    ),
  );
}

void main() {
  testWidgets('Cart integration test: add, update, remove items', (tester) async {
    await tester.pumpWidget(_buildApp());

    // Wait for the initial load
    await tester.pumpAndSettle();

    // 1. Initially Empty
    expect(find.text('Your cart is empty!'), findsOneWidget);

    // 2. Add an item by finding the BLoC from context directly using a Builder
    // In a real app this would happen from another page (DetailsPage).
    final BuildContext context = tester.element(find.byType(CartPageUI));
    context.read<CartBloc>().add(
      CartItemAdded(
        CartItem(
          id: 'item1',
          name: 'Burger',
          price: 150.0,
          sellerId: 'seller1',
        ),
      ),
    );

    // Let the UI rebuild
    await tester.pumpAndSettle();

    // The empty state should be gone, and the item should be listed
    expect(find.text('Your cart is empty!'), findsNothing);
    expect(find.text('Burger'), findsWidgets);
    expect(find.text('1'), findsWidgets); // quantity
    expect(find.textContaining('150.00'), findsWidgets);

    // 3. Update quantity (increment)
    // Find the add icon (plus)
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsWidgets); // quantity updated to 2
    expect(find.textContaining('300.00'), findsWidgets); // subtotal updated

    // 4. Update quantity (decrement)
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets); // quantity updated to 1
    expect(find.textContaining('150.00'), findsWidgets); // subtotal updated

    // 5. Remove item entirely using the delete icon
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    // Should be empty again
    expect(find.text('Your cart is empty!'), findsOneWidget);
  });
}
