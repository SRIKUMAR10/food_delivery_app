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
  group('Error Handling UI Tests', () {
    late SellerCustomerBloc bloc;

    setUp(() {
      bloc = MockSellerCustomerBloc();
    });

    testWidgets('triggers LoadCustomerData event on clicking Retry button', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerCustomerError('Network Timed Out'));

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

        expect(find.text('Network Timed Out'), findsOneWidget);
        final retryButton = find.text('Retry');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        verify(() => bloc.add(const LoadCustomerData())).called(1);
      });
    });
  });
}
