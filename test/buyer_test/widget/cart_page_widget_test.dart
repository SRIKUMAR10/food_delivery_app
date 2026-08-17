import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_UI.dart';

class MockCartBloc extends Mock implements CartBloc {}
class MockRazorpayApiService extends Mock implements RazorpayApiService {}

void main() {
  group('Cart Page Real-Time Widget Tests', () {
    late MockCartBloc mockCartBloc;
    late MockRazorpayApiService mockRazorpayApiService;

    setUp(() {
      mockCartBloc = MockCartBloc();
      mockRazorpayApiService = MockRazorpayApiService();

      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {});
      when(() => mockRazorpayApiService.initialize(
        onSuccess: any(named: 'onSuccess'),
        onFailure: any(named: 'onFailure'),
        onExternalWallet: any(named: 'onExternalWallet'),
      )).thenReturn(null);
      when(() => mockRazorpayApiService.dispose()).thenReturn(null);
    });

    Widget createWidgetUnderTest(CartState state, {Size? surfaceSize}) {
      when(() => mockCartBloc.state).thenReturn(state);

      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: surfaceSize ?? const Size(400, 850)),
          child: BlocProvider<CartBloc>.value(
            value: mockCartBloc,
            child: CartPageUI(
              onNavigateToOrders: () {},
              onNavigateToWallet: () {},
              razorpayApiService: mockRazorpayApiService,
            ),
          ),
        ),
      );
    }

    testWidgets('1. Renders empty cart state with icon and explore message', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty!'), findsOneWidget);
      expect(find.text('Browse items and add delicious dishes to your cart.'), findsOneWidget);
    });

    testWidgets('2. Renders Delivery Address Card with active address & Change button', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Cheese Burger',
          price: 150.0,
          sellerId: 'seller1',
          quantity: 2,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 300.0,
          totalCount: 2,
          selectedAddressType: 'Home',
          deliveryAddress: '123 Beach Road, Chennai',
          homeAddress: '123 Beach Road, Chennai',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Delivery to: Home'), findsOneWidget);
      expect(find.text('123 Beach Road, Chennai'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('3. Tapping Change on Address Card opens selection bottom sheet', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Cheese Burger',
          price: 150.0,
          sellerId: 'seller1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 150.0,
          totalCount: 1,
          selectedAddressType: 'Home',
          homeAddress: 'Home Address 123',
          workAddress: 'Tech Park, Office 4',
          otherAddress: 'Gym Street 5',
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Change button
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Delivery Address'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('4. Renders Cart Item Card with custom addon chips and Stepper', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Spicy Burger Deluxe',
          price: 250.0,
          sellerId: 'seller1',
          quantity: 2,
          isSelected: true,
          selectedAddons: const [
            'Extra Cheese (+₹30)',
            'Jalapeno (+₹20)',
          ],
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 500.0,
          totalCount: 2,
          deliveryFee: 0.0,
          taxAmount: 25.0,
          platformFee: 5.0,
          finalAmount: 530.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Spicy Burger Deluxe'), findsOneWidget);
      expect(find.text('+ Extra Cheese (+₹30)'), findsOneWidget);
      expect(find.text('+ Jalapeno (+₹20)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Quantity in stepper
    });

    testWidgets('5. Renders Manual Coupon entry section & Apply button', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Pizza',
          price: 200.0,
          sellerId: 'seller1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 200.0,
          totalCount: 1,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('Coupons & Offers'), findsOneWidget);
      expect(find.text('Enter coupon code'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('6. Renders Payment Methods: Razorpay, COD, and Wallet and handles selection', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Pizza',
          price: 200.0,
          sellerId: 'seller1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 200.0,
          totalCount: 1,
          selectedPaymentMethod: CartPaymentMethod.razorpay,
          walletBalance: 350.0,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Razorpay Online'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);
      expect(find.text('FoodGo Wallet'), findsOneWidget);
      expect(find.text('Balance: ₹350'), findsOneWidget);

      // Tap COD
      await tester.tap(find.text('Cash on Delivery (COD)'), warnIfMissed: false);
      verify(() => mockCartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.cod))).called(1);
    });

    testWidgets('7. Renders Bill Details Breakdown (Item Total, Delivery Fee, Taxes, Platform Fee, Grand Total)', (WidgetTester tester) async {
      final items = [
        CartItem(
          id: 'item1',
          name: 'Pizza',
          price: 400.0,
          sellerId: 'seller1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 400.0,
          totalCount: 1,
          deliveryFee: 35.0,
          taxAmount: 20.0,
          platformFee: 5.0,
          finalAmount: 460.0,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Bill Details'), findsOneWidget);
      expect(find.text('Item Total'), findsOneWidget);
      expect(find.text('Delivery Fee'), findsOneWidget);
      expect(find.text('GST & Restaurant Charges (5%)'), findsOneWidget);
      expect(find.text('Platform Fee'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);
    });

    testWidgets('8. Renders Responsive Desktop Layout (Side-by-Side layout on >= 1024px)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final items = [
        CartItem(
          id: 'item1',
          name: 'Burger',
          price: 100.0,
          sellerId: 'seller1',
          quantity: 1,
          isSelected: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        CartLoaded(
          items: items,
          totalAmount: 100.0,
          totalCount: 1,
          deliveryFee: 35.0,
          taxAmount: 5.0,
          platformFee: 5.0,
          finalAmount: 145.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Bill Details'), findsOneWidget);
    });
  });
}
