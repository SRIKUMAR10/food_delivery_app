import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/repositories/seller_wallet_repository.dart';

class MockSellerWalletRepository extends Mock implements SellerWalletRepository {}

void main() {
  group('Dependency Injection Tests', () {
    testWidgets(
      'resolves SellerWalletRepository and SellerPayoutHistoryBloc from provider context',
      (tester) async {
        final repository = MockSellerWalletRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<SellerWalletRepository>.value(
              value: repository,
              child: BlocProvider<SellerPayoutHistoryBloc>(
                create: (context) => SellerPayoutHistoryBloc(
                  repository: context.read<SellerWalletRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    final resolvedRepository =
                        RepositoryProvider.of<SellerWalletRepository>(
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