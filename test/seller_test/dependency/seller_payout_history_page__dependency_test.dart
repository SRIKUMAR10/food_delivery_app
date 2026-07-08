import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/repositories/seller_payout_history_repository.dart';

class MockSellerPayoutHistoryRepository extends Mock
    implements SellerPayoutHistoryRepository {}

void main() {
  group('Dependency Injection Tests', () {
    testWidgets(
      'resolves SellerPayoutHistoryRepository and SellerPayoutHistoryBloc from provider context',
      (tester) async {
        final repository = MockSellerPayoutHistoryRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<SellerPayoutHistoryRepository>.value(
              value: repository,
              child: BlocProvider<SellerPayoutHistoryBloc>(
                create: (context) => SellerPayoutHistoryBloc(
                  repository: context.read<SellerPayoutHistoryRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    final resolvedRepository =
                        RepositoryProvider.of<SellerPayoutHistoryRepository>(
                          context,
                        );
                    final resolvedBloc =
                        BlocProvider.of<SellerPayoutHistoryBloc>(context);

                    expect(resolvedRepository, isNotNull);
                    expect(resolvedBloc, isNotNull);

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();
      },
    );
  });
}
