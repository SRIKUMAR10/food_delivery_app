import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

class MockOrderBloc extends Mock implements OrderBloc {}

class FakeOrderEvent extends Fake implements OrderEvent {}

class FakeOrderState extends Fake implements OrderState {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    registerFallbackValue(FakeOrderEvent());
    registerFallbackValue(FakeOrderState());
  });

  Widget createWidgetUnderTest(OrderBloc bloc) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: OrderPageUI(orderBloc: bloc),
    );
  }

  group('OrderPageUI Widget Tests', () {
    late MockOrderBloc mockOrderBloc;

    setUp(() {
      mockOrderBloc = MockOrderBloc();
      // Stub the stream and state
      when(() => mockOrderBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockOrderBloc.close()).thenAnswer((_) async {
        return null;
      });
    });

    testWidgets('shows loading indicator when state is OrderLoading', (
      WidgetTester tester,
    ) async {
      when(() => mockOrderBloc.state).thenReturn(OrderLoading());

      await tester.pumpWidget(createWidgetUnderTest(mockOrderBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows empty message when state is OrderLoaded with no orders',
      (WidgetTester tester) async {
        when(() => mockOrderBloc.state).thenReturn(const OrderLoaded([]));

        await tester.pumpWidget(createWidgetUnderTest(mockOrderBloc));

        // The UI shows "Your order list is empty"
        expect(find.textContaining('order list is empty'), findsWidgets);
      },
    );

    testWidgets('shows error message when state is OrderError', (
      WidgetTester tester,
    ) async {
      when(
        () => mockOrderBloc.state,
      ).thenReturn(const OrderError('Network Failure'));

      await tester.pumpWidget(createWidgetUnderTest(mockOrderBloc));

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Network Failure'), findsOneWidget);
    });
  });
}
