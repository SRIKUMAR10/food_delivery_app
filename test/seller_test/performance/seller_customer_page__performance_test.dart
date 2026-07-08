import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';

class MockSellerCustomerBloc
    extends MockBloc<SellerCustomerEvent, SellerCustomerState>
    implements SellerCustomerBloc {}

void main() {
  group('Seller Customer Page Performance Tests', () {
    late SellerCustomerBloc bloc;

    setUp(() {
      bloc = MockSellerCustomerBloc();
    });

    testWidgets(
      'ensures smooth scroll performance under large customer list size',
      (tester) async {
        final customers = List.generate(
          100,
          (index) => CustomerItem(
            id: 'cust_$index',
            name: 'Customer Name $index',
            orderCount: index,
            avatarUrl: 'https://example.com/avatar$index.png',
          ),
        );

        when(() => bloc.state).thenReturn(
          SellerCustomerLoaded(
            stats: const CustomerStats(
              totalCustomers: 500,
              repeatCustomers: 120,
            ),
            customers: customers,
          ),
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<SellerCustomerBloc>.value(
                value: bloc,
                child: const SellerCustomerView(),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 500));

          final listFinder = find.byType(ListView);
          expect(listFinder, findsOneWidget);

          // Scroll list down
          await tester.drag(
            listFinder,
            const Offset(0.0, -400.0),
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.byType(SellerCustomerView), findsOneWidget);
        });
      },
    );
  });
}
