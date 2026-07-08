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

import '../../font_loader_helper.dart';

class MockSellerPayoutHistoryBloc
    extends MockBloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState>
    implements SellerPayoutHistoryBloc {}

void main() {
  setUpAll(() {
    overrideFontAssetLoading();
  });

  group('Seller Payout History Flow Integration Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SellerPayoutHistoryBloc>.value(
          value: bloc,
          child: const SellerPayoutHistoryView(),
        ),
      );
    }

    testWidgets('Scroll to bottom fires LoadMorePayoutHistory event', (
      tester,
    ) async {
      final payouts = List.generate(
        15,
        (index) => PayoutItem(
          id: 'payout_$index',
          title: 'Payout #00$index',
          amount: 1000.0 * index,
          status: 'Paid',
          date: DateTime(2024, 5, 1),
        ),
      );

      when(() => bloc.state).thenReturn(
        SellerPayoutHistoryLoaded(
          payouts: payouts,
          hasReachedMax: false,
          isPaginatedLoading: false,
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to bottom
      final scrollableFinder = find.byType(Scrollable);
      expect(scrollableFinder, findsOneWidget);

      final scrollableState = tester.state<ScrollableState>(scrollableFinder);
      scrollableState.position.jumpTo(scrollableState.position.maxScrollExtent);
      await tester.pumpAndSettle();

      verify(() => bloc.add(const LoadMorePayoutHistory())).called(1);
    });

    testWidgets('Pull to refresh fires RefreshPayoutHistory event', (
      tester,
    ) async {
      final payouts = [
        PayoutItem(
          id: 'payout_1',
          title: 'Payout #0001',
          amount: 2000.0,
          status: 'Paid',
          date: DateTime(2024, 5, 1),
        ),
      ];

      when(
        () => bloc.state,
      ).thenReturn(SellerPayoutHistoryLoaded(payouts: payouts));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Drag list down to trigger refresh
      final firstItem = find.text('Payout #0001');
      await tester.drag(firstItem, const Offset(0.0, 300.0));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const RefreshPayoutHistory())).called(1);
    });
  });
}
