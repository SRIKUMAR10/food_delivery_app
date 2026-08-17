import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page.dart';
import 'package:mocktail/mocktail.dart';

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartPage Localization Tests', () {
    late MockCartBloc mockCartBloc;

    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('razorpay_flutter'),
        (MethodCall methodCall) async => null,
      );
    });

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {
        return null;
      });
      when(() => mockCartBloc.state).thenReturn(
        const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      );
    });

    testWidgets('Renders localized text properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: BlocProvider<CartBloc>.value(
            value: mockCartBloc,
            child: CartPageUI(
              onNavigateToOrders: () {},
              onNavigateToWallet: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CartPageUI), findsOneWidget);
      // Replace with actual localized string expectations later
    });
  });
}
