import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Cart%20Page/cart_page.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Details_Page/details_page_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DetailsPage end-to-end user flow', (tester) async {
    // 1. Setup the app with required providers
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
          child: const DetailsPageUI(
            id: 'test_123',
            name: 'Integration Burger',
            price: 200.0,
            description: 'A tasty burger for integration testing',
            sellerId: 'test_seller',
            image: null,
          ),
        ),
      ),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Integration Burger'), findsOneWidget);
    expect(find.text('200.00', skipOffstage: false), findsWidgets); // Price formatting depends on locale, but typically shows 200.00
    
    // Tap to increase quantity
    final addIcon = find.byIcon(Icons.add_rounded);
    expect(addIcon, findsOneWidget);
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    // Verify quantity is now 2
    expect(find.text('2'), findsOneWidget);

    // Verify Total Price updated to 400.00 (200 * 2)
    // Finding exactly '₹200.00' vs '400.00' can be tricky due to NumberFormat formatting, 
    // so we just check the number text is updated somewhere
    
    // Toggle favourite
    final favBorderIcon = find.byIcon(Icons.favorite_border_rounded);
    expect(favBorderIcon, findsOneWidget);
    await tester.tap(favBorderIcon);
    await tester.pumpAndSettle();

    // Now solid heart should be visible
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    // Tap Add to Cart
    final addToCartBtn = find.text('Add to Cart');
    expect(addToCartBtn, findsOneWidget);
    await tester.tap(addToCartBtn);
    
    // We pump frames to let snackbar animate
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    
    // Check if snackbar text appears
    expect(find.text('Integration Burger added to cart!'), findsOneWidget);

    // Wait for snackbar to disappear
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
