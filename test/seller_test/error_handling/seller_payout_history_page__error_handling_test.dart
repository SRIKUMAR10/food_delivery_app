import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__state.dart';

class MockSellerPayoutHistoryBloc
    extends MockBloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState>
    implements SellerPayoutHistoryBloc {}

void main() {
  group('Error Handling UI Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    testWidgets('triggers LoadPayoutHistory event on clicking Retry button', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerPayoutHistoryError('Network Timed Out'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerPayoutHistoryBloc>.value(
            value: bloc,
            child: const SellerPayoutHistoryView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network Timed Out'), findsOneWidget);
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      verify(() => bloc.add(const LoadPayoutHistory())).called(1);
    });
  });
}
