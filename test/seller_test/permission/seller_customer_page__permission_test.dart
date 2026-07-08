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
  group('Security Permission Verification Tests', () {
    late SellerCustomerBloc bloc;

    setUp(() {
      bloc = MockSellerCustomerBloc();
    });

    testWidgets(
      'shows unauthorized warning when state is restricted or forbidden error occurs',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const SellerCustomerError('403 Forbidden: Seller access revoked'),
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

          expect(
            find.text('403 Forbidden: Seller access revoked'),
            findsOneWidget,
          );
        });
      },
    );
  });
}
