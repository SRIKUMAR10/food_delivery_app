import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/low_stock_alert_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/low_stock_alert_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/low_stock_alert_page__state.dart';

void main() {
  group('LowStockAlertBloc', () {
    late LowStockAlertBloc lowStockAlertBloc;

    setUp(() {
      lowStockAlertBloc = LowStockAlertBloc();
    });

    tearDown(() {
      lowStockAlertBloc.close();
    });

    test('initial state is LowStockAlertInitial', () {
      expect(lowStockAlertBloc.state, equals(LowStockAlertInitial()));
    });

    blocTest<LowStockAlertBloc, LowStockAlertState>(
      'emits [LowStockAlertLoading, LowStockAlertLoaded] when LoadLowStockData is added',
      build: () => lowStockAlertBloc,
      act: (bloc) => bloc.add(LoadLowStockData()),
      expect: () => [
        isA<LowStockAlertLoading>(),
        isA<LowStockAlertLoaded>().having(
          (state) => state.items.length,
          'items length',
          0,
        ),
      ],
    );

    blocTest<LowStockAlertBloc, LowStockAlertState>(
      'emits Loading and then Loaded when RefreshLowStockData is added',
      build: () => lowStockAlertBloc,
      act: (bloc) => bloc.add(RefreshLowStockData()),
      expect: () => [isA<LowStockAlertLoading>(), isA<LowStockAlertLoaded>()],
    );
  });
}
