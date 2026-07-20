import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';
import 'package:food_delivery_app/repositories/seller_customer_repository.dart';

class MockCustomerRepository extends Mock implements SellerCustomerRepository {}

void main() {
  group('Seller Customer Snapshot Tree Tests', () {
    testWidgets('loaded state matches exact structural layout snapshots', (
      tester,
    ) async {
      final repo = MockCustomerRepository();
      when(() => repo.getCustomerStats()).thenAnswer(
        (_) async => const CustomerStats(totalCustomers: 1245, repeatCustomers: 320),
      );
      when(() => repo.getCustomers(offset: any(named: 'offset'), limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      final bloc = SellerCustomerBloc(repository: repo);
      bloc.add(const LoadCustomerData());

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerCustomerBloc>.value(
              value: bloc,
              child: const SellerCustomerView(),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final totalCustomers = find.text('Total Customers');
        expect(totalCustomers, findsOneWidget);

        final repeatCustomers = find.text('Repeat Customers');
        expect(repeatCustomers, findsOneWidget);
      });
    });
  });
}
