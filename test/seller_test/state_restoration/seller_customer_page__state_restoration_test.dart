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
  group('State Restoration Tests', () {
    late SellerCustomerBloc bloc;

    setUp(() {
      bloc = MockSellerCustomerBloc();
    });

    testWidgets(
      'retains loaded data when rebuilt during routing lifecycle events',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const SellerCustomerLoaded(
            stats: CustomerStats(totalCustomers: 1245, repeatCustomers: 320),
            customers: [
              CustomerItem(
                id: '1',
                name: 'Mike Ross',
                orderCount: 12,
                avatarUrl: 'https://example.com/avatar1.png',
              ),
            ],
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

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text('Mike Ross'), findsOneWidget);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<SellerCustomerBloc>.value(
                value: bloc,
                child: const SellerCustomerView(),
              ),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text('Mike Ross'), findsOneWidget);
        });
      },
    );
  });
}
