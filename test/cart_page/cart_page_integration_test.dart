// test/cart_page/cart_page_integration_test.dart

import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  FakeCartBloc()
    : super(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0)) {
    on<LoadCartStarted>((event, emit) {
      emit(state);
    });
    on<CartItemAdded>((event, emit) {
      if (state is CartLoaded) {
        final current = state as CartLoaded;
        final items = List<CartItem>.from(current.items);
        final index = items.indexWhere((i) => i.id == event.item.id);
        if (index >= 0) {
          items[index] = items[index].copyWith(
            quantity: items[index].quantity + event.item.quantity,
          );
        } else {
          items.add(event.item);
        }

        double totalAmount = items.fold(
          0,
          (sum, i) => sum + (i.price * i.quantity),
        );
        int totalCount = items.fold(0, (sum, i) => sum + i.quantity);
        emit(
          CartLoaded(
            items: items,
            totalAmount: totalAmount,
            totalCount: totalCount,
          ),
        );
      }
    });
    on<CartItemQuantityUpdated>((event, emit) {
      if (state is CartLoaded) {
        final current = state as CartLoaded;
        final items = List<CartItem>.from(current.items);
        final index = items.indexWhere((i) => i.id == event.id);
        if (index >= 0) {
          final newQty = items[index].quantity + event.delta;
          if (newQty <= 0) {
            items.removeAt(index);
          } else {
            items[index] = items[index].copyWith(quantity: newQty);
          }
          double totalAmount = items.fold(
            0,
            (sum, i) => sum + (i.price * i.quantity),
          );
          int totalCount = items.fold(0, (sum, i) => sum + i.quantity);
          emit(
            CartLoaded(
              items: items,
              totalAmount: totalAmount,
              totalCount: totalCount,
            ),
          );
        }
      }
    });
    on<CartItemRemoved>((event, emit) {
      if (state is CartLoaded) {
        final current = state as CartLoaded;
        final items = List<CartItem>.from(current.items);
        items.removeWhere((i) => i.id == event.id);
        double totalAmount = items.fold(
          0,
          (sum, i) => sum + (i.price * i.quantity),
        );
        int totalCount = items.fold(0, (sum, i) => sum + i.quantity);
        emit(
          CartLoaded(
            items: items,
            totalAmount: totalAmount,
            totalCount: totalCount,
          ),
        );
      }
    });
    on<CartCleared>((event, emit) {
      emit(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0));
    });
  }
}

Widget _buildApp() {
  return MaterialApp(
    home: BlocProvider<CartBloc>(
      create: (_) => FakeCartBloc()..add(const LoadCartStarted()),
      child: const CartPageUI(),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Cart integration test: add, update, remove items', (
    tester,
  ) async {
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
    final addIcon = find.byIcon(Icons.add_rounded);
    await tester.ensureVisible(addIcon);
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    expect(find.text('2'), findsWidgets); // quantity updated to 2
    expect(find.textContaining('300.00'), findsWidgets); // subtotal updated

    // 4. Update quantity (decrement)
    final removeIcon = find.byIcon(Icons.remove_rounded);
    await tester.ensureVisible(removeIcon);
    await tester.tap(removeIcon);
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
