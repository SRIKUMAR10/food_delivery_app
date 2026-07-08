import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class MockSellerPayoutHistoryBloc
    extends MockBloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState>
    implements SellerPayoutHistoryBloc {}

void main() {
  group('SellerPayoutHistoryView Widget Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<SellerPayoutHistoryBloc>.value(
          value: bloc,
          child: const SellerPayoutHistoryView(),
        ),
      );
    }

    testWidgets('renders skeleton loader when state is loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const SellerPayoutHistoryLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const ValueKey('loading_skeleton')), findsOneWidget);
    });

    testWidgets('renders empty state when list is empty', (tester) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerPayoutHistoryLoaded(payouts: []));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('empty_state')), findsOneWidget);
      expect(find.text('No Payout History'), findsOneWidget);
    });

    testWidgets('renders list of payouts when state is loaded', (tester) async {
      final payouts = [
        PayoutItem(
          id: 'payout_1',
          title: 'Payout #0001',
          amount: 2000.0,
          status: 'Paid',
          date: DateTime(2024, 5, 1),
        ),
        PayoutItem(
          id: 'payout_2',
          title: 'Payout #0002',
          amount: 4000.0,
          status: 'Paid',
          date: DateTime(2024, 5, 2),
        ),
      ];

      when(
        () => bloc.state,
      ).thenReturn(SellerPayoutHistoryLoaded(payouts: payouts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Start animations

      expect(find.text('Payout #0001'), findsOneWidget);
      expect(find.text('Payout #0002'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);
      expect(find.text('₹4,000'), findsOneWidget);
    });

    testWidgets('renders error screen with retry button on error', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerPayoutHistoryError('Network error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('error_state')), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
