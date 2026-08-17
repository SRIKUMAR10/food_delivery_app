import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock_firebase.dart';

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    registerFallbackValue(const LoadCartStarted());
    registerFallbackValue(const CartLoading());
  });

  Widget createWidgetUnderTest(CartBloc bloc) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: BlocProvider<CartBloc>.value(
        value: bloc,
        child: CartPageUI(onNavigateToOrders: () {}, onNavigateToWallet: () {}),
      ),
    );
  }

  group('CartPageUI Widget Tests', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {
        return null;
      });
    });

    testWidgets('shows loading indicator when state is CartLoading', (
      WidgetTester tester,
    ) async {
      when(() => mockCartBloc.state).thenReturn(const CartLoading());

      await tester.pumpWidget(createWidgetUnderTest(mockCartBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows empty cart message when state is CartLoaded with no items',
      (WidgetTester tester) async {
        when(() => mockCartBloc.state).thenReturn(
          const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
        );

        await tester.pumpWidget(createWidgetUnderTest(mockCartBloc));

        expect(find.textContaining('Your cart is empty!'), findsWidgets);
      },
    );

    testWidgets('shows checkout button, payment options, and total when items are present', (
      WidgetTester tester,
    ) async {
      final mockItems = [
        CartItem(
          id: '1',
          name: 'Burger',
          price: 150.0,
          quantity: 2,
          sellerId: '1',
          isSelected: true,
        ),
      ];
      when(() => mockCartBloc.state).thenReturn(
        CartLoaded(
          items: mockItems,
          totalAmount: 300.0,
          totalCount: 2,
          finalAmount: 350.0,
          selectedPaymentMethod: CartPaymentMethod.razorpay,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockCartBloc));

      expect(find.textContaining('300'), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.textContaining('Razorpay'), findsWidgets);
      expect(find.textContaining('Cash on Delivery'), findsWidgets);
      expect(find.textContaining('FoodGo Wallet'), findsWidgets);
    });
  });
}
