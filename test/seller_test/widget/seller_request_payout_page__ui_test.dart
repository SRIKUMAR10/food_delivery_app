import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__state.dart';

class MockSellerRequestPayoutBloc
    extends MockBloc<SellerRequestPayoutEvent, SellerRequestPayoutState>
    implements SellerRequestPayoutBloc {}

void main() {
  group('SellerRequestPayoutPage Widget Tests', () {
    late SellerRequestPayoutBloc bloc;

    setUp(() {
      bloc = MockSellerRequestPayoutBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SellerRequestPayoutBloc>.value(
          value: bloc,
          child: const SellerRequestPayoutView(),
        ),
      );
    }

    testWidgets('renders skeleton loader when state is loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const SellerRequestPayoutLoading());

      await tester.pumpWidget(createTestWidget());

      expect(
        find.byKey(const ValueKey('loading_payout_skeleton')),
        findsOneWidget,
      );
    });

    testWidgets('renders error message and retry button when state is error', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerRequestPayoutError('API connection lost'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Failed to load details'), findsOneWidget);
      expect(find.text('API connection lost'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders balance card and payout inputs when state is loaded', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const SellerRequestPayoutLoaded(
          balance: 12680.00,
          bankAccounts: ['HDFC Bank • 1234', 'ICICI Bank • 5678'],
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('₹12,680.00'), findsOneWidget);
      expect(find.text('Enter Amount'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('UPI ID'), findsOneWidget);
      expect(find.text('Request Payout'), findsOneWidget);
    });
  });
}
