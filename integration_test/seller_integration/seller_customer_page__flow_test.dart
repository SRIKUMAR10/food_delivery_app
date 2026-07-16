import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';

import '../../test/font_loader_helper.dart';

class MockSellerCustomerBloc
    extends MockBloc<SellerCustomerEvent, SellerCustomerState>
    implements SellerCustomerBloc {}

void main() {
  setUpAll(() {
    overrideFontAssetLoading();

    // Mock path_provider channel to avoid MissingPluginException from CachedNetworkImage cache store
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  group('Seller Customer Flow Integration Tests', () {
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

    testWidgets(
      'Scroll to bottom triggers pagination LoadMoreCustomers event',
      (tester) async {
        final mockCustomers = List.generate(
          20,
          (index) => CustomerItem(
            id: 'cust_$index',
            name: 'Customer $index',
            orderCount: index,
            avatarUrl: '',
          ),
        );

        when(() => bloc.state).thenReturn(
          SellerCustomerLoaded(
            stats: const CustomerStats(
              totalCustomers: 1245,
              repeatCustomers: 320,
            ),
            customers: mockCustomers,
            hasReachedMax: false,
          ),
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestWidget());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Find the scrollable descendant of the SingleChildScrollView
          final scrollableFinder = find
              .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(Scrollable),
              )
              .first;
          expect(scrollableFinder, findsOneWidget);

          final scrollableState = tester.state<ScrollableState>(
            scrollableFinder,
          );

          scrollableState.position.jumpTo(
            scrollableState.position.maxScrollExtent,
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          verify(() => bloc.add(const LoadMoreCustomers())).called(1);
        });
      },
    );

    testWidgets('Pull to refresh triggers RefreshCustomerData event', (
      tester,
    ) async {
      final mockCustomers = [
        const CustomerItem(
          id: 'cust_0',
          name: 'Customer 0',
          orderCount: 5,
          avatarUrl: '',
        ),
      ];

      when(() => bloc.state).thenReturn(
        SellerCustomerLoaded(
          stats: const CustomerStats(totalCustomers: 10, repeatCustomers: 2),
          customers: mockCustomers,
        ),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Drag first item down to trigger refresh
        final firstItem = find.text('Customer 0');
        await tester.drag(firstItem, const Offset(0.0, 300.0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        verify(() => bloc.add(const RefreshCustomerData())).called(1);
      });
    });
  });
}
