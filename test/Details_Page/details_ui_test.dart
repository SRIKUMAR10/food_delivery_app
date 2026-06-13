import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Cart%20Page/cart_page.dart';

import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Details_Page/details_page_UI.dart';

// Fake CartBloc to satisfy context.read<CartBloc>()
class FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  FakeCartBloc() : super(const CartLoaded());
}

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CartBloc>(
        create: (_) => FakeCartBloc(),
        child: const DetailsPageUI(
          id: '1',
          name: 'Burger',
          price: 150.0,
          description: 'Delicious chicken burger',
          sellerId: 'seller123',
          image: null,
        ),
      ),
    );
  }

  group('DetailsPageUI Widget Tests', () {
    testWidgets('renders all initial details correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Check text rendering
      expect(
        find.text('Burger'),
        findsWidgets,
      ); // Can be multiple if both layouts build but layout builder selects one.
      expect(find.text('Price'), findsWidgets);
      expect(find.text('1'), findsWidgets); // Initial quantity
      expect(find.text('Delicious chicken burger'), findsWidgets);
    });

    testWidgets('increments quantity when add button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial quantity
      expect(find.text('1'), findsWidgets);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();

      // Check quantity increased to 2
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('decrements quantity when remove button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap + button to increase to 2 first
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsWidgets);

      // Tap - button
      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();

      // Check quantity decreased to 1
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('toggles favourite icon when tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initially not favourite
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      // Tap favourite button
      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pumpAndSettle();

      // Now it should be favourite
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('shows snackbar when adding to cart', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap add to cart
      await tester.tap(find.text('Add to Cart').first);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Let snackbar show

      // Verify snackbar is visible
      expect(find.text('Burger added to cart!'), findsOneWidget);
    });
  });
}
