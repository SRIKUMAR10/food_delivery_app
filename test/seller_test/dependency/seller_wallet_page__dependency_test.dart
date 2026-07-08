import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/repositories/seller_wallet_repository.dart';

class MockSellerWalletRepository extends Mock
    implements SellerWalletRepository {}

void main() {
  group('Dependency Injection Tests', () {
    testWidgets(
      'resolves SellerWalletRepository and SellerWalletBloc from provider context',
      (tester) async {
        final repository = MockSellerWalletRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<SellerWalletRepository>.value(
              value: repository,
              child: BlocProvider<SellerWalletBloc>(
                create: (context) => SellerWalletBloc(
                  repository: context.read<SellerWalletRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    // Attempt resolving
                    final resolvedRepository =
                        RepositoryProvider.of<SellerWalletRepository>(context);
                    final resolvedBloc = BlocProvider.of<SellerWalletBloc>(
                      context,
                    );

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
