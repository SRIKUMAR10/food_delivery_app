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
  group('Seller Customer Page Widget Tests', () {
    late SellerCustomerBloc bloc;

    setUp(() {
      bloc = MockSellerCustomerBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SellerCustomerBloc>.value(
          value: bloc,
          child: const SellerCustomerView(),
        ),
      );
    }

    testWidgets('shows loading skeleton when state is SellerCustomerLoading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const SellerCustomerLoading());

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget());
        expect(
          find.byKey(const ValueKey('loading_customer_skeleton')),
          findsOneWidget,
        );
      });
    });

    testWidgets(
      'renders statistics and customer items when state is SellerCustomerLoaded',
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
              CustomerItem(
                id: '2',
                name: 'John Doe',
                orderCount: 10,
                avatarUrl: 'https://example.com/avatar2.png',
              ),
            ],
          ),
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestWidget());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Customers'), findsOneWidget);
          expect(find.text('1245'), findsOneWidget);
          expect(find.text('320'), findsOneWidget);
          expect(find.text('Top Customers'), findsOneWidget);
          expect(find.text('Mike Ross'), findsOneWidget);
          expect(find.text('John Doe'), findsOneWidget);
        });
      },
    );

    testWidgets(
      'shows error state and triggers LoadCustomerData on retry tap',
      (tester) async {
        when(
          () => bloc.state,
        ).thenReturn(const SellerCustomerError('Something went wrong'));

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestWidget());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Something went wrong'), findsOneWidget);
          final retryButton = find.text('Retry');
          expect(retryButton, findsOneWidget);

          await tester.tap(retryButton);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          verify(() => bloc.add(const LoadCustomerData())).called(1);
        });
      },
    );
  });
}
