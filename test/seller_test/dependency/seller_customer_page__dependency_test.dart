import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/repositories/seller_customer_repository.dart';

class MockSellerCustomerRepository extends Mock
    implements SellerCustomerRepository {}

void main() {
  group('Dependency Injection Tests', () {
    testWidgets(
      'resolves SellerCustomerRepository and SellerCustomerBloc from provider context',
      (tester) async {
        final repository = MockSellerCustomerRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: RepositoryProvider<SellerCustomerRepository>.value(
              value: repository,
              child: BlocProvider<SellerCustomerBloc>(
                create: (context) => SellerCustomerBloc(
                  repository: context.read<SellerCustomerRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    final resolvedRepository =
                        RepositoryProvider.of<SellerCustomerRepository>(
                          context,
                        );
                    final resolvedBloc = BlocProvider.of<SellerCustomerBloc>(
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
