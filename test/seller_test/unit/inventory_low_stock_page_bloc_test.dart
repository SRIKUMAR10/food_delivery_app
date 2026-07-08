import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_state.dart';

void main() {
  group('InventoryLowStockPageBloc', () {
    late InventoryLowStockPageBloc inventoryBloc;

    setUp(() {
      inventoryBloc = InventoryLowStockPageBloc();
    });

    tearDown(() {
      inventoryBloc.close();
    });

    test('initial state is InventoryInitial', () {
      expect(inventoryBloc.state, equals(InventoryInitial()));
    });

    blocTest<InventoryLowStockPageBloc, InventoryLowStockPageState>(
      'emits [InventoryLoading, InventoryLoaded] when LoadInventoryData is added',
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(LoadInventoryData()),
      wait: const Duration(seconds: 3), // Wait for Future.delayed in bloc
      expect: () => [isA<InventoryLoading>(), isA<InventoryLoaded>()],
      verify: (bloc) {
        final state = bloc.state as InventoryLoaded;
        expect(state.summary.totalItems, 120);
        expect(state.items.length, 4);
      },
    );

    blocTest<InventoryLowStockPageBloc, InventoryLowStockPageState>(
      'emits [InventoryLoading, InventoryLoaded] when RefreshInventoryData is added',
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(RefreshInventoryData()),
      wait: const Duration(seconds: 3),
      expect: () => [isA<InventoryLoading>(), isA<InventoryLoaded>()],
    );
  });
}
