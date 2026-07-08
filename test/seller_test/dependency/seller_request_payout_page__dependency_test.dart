import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'package:food_delivery_app/repositories/seller_request_payout_repository.dart';

class MockSellerRequestPayoutRepository extends Mock
    implements SellerRequestPayoutRepository {}

void main() {
  group('Dependency Injection Tests', () {
    testWidgets(
      'resolves SellerRequestPayoutRepository and SellerRequestPayoutBloc from provider context',
      (tester) async {
        final repository = MockSellerRequestPayoutRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<SellerRequestPayoutRepository>.value(
              value: repository,
              child: BlocProvider<SellerRequestPayoutBloc>(
                create: (context) => SellerRequestPayoutBloc(
                  repository: context.read<SellerRequestPayoutRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    final resolvedRepository =
                        RepositoryProvider.of<SellerRequestPayoutRepository>(
                          context,
                        );
                    final resolvedBloc =
                        BlocProvider.of<SellerRequestPayoutBloc>(context);

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
