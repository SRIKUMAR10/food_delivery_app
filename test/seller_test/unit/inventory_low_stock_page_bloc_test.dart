import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/inventory_item_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';

class MockInventoryRepository extends Mock implements IInventoryRepository {}

void main() {
  group('InventoryBloc', () {
    late InventoryBloc inventoryBloc;
    late MockInventoryRepository repository;

    final testItem1 = InventoryItemModel(
      id: 'p1',
      name: 'Paneer Butter Masala',
      quantity: 15.0,
      unit: 'servings',
      category: 'Curry',
      sku: 'SKU-CUR-001',
      lowStockThreshold: 5,
      price: 220.0,
      isActive: true,
      hasUnlimitedStock: false,
    );

    final testItem2 = InventoryItemModel(
      id: 'p2',
      name: 'Butter Naan',
      quantity: 2.0,
      unit: 'pieces',
      category: 'Breads',
      sku: 'SKU-BRD-002',
      lowStockThreshold: 10,
      price: 45.0,
      isActive: true,
      hasUnlimitedStock: false,
    );

    setUp(() {
      repository = MockInventoryRepository();
      inventoryBloc = InventoryBloc(repository: repository);
    });

    tearDown(() {
      inventoryBloc.close();
    });

    test('initial state is InventoryInitial', () {
      expect(inventoryBloc.state, equals(InventoryInitial()));
    });

    blocTest<InventoryBloc, InventoryState>(
      'emits [InventoryLoading, InventoryLoaded] when LoadInventoryStream receives data',
      build: () {
        when(() => repository.getInventoryStream('seller_123'))
            .thenAnswer((_) => Stream.value([testItem1, testItem2]));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadInventoryStream(sellerId: 'seller_123')),
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryLoaded>()
            .having((s) => s.allItems.length, 'allItems length', 2)
            .having((s) => s.summary.totalItems, 'totalItems', 2)
            .having((s) => s.summary.lowStock, 'lowStock', 1)
            .having((s) => s.summary.normalStock, 'normalStock', 1),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'filters items by status in FilterInventory',
      build: () {
        when(() => repository.getInventoryStream('seller_123'))
            .thenAnswer((_) => Stream.value([testItem1, testItem2]));
        return inventoryBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: 'seller_123'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const FilterInventory('Low Stock'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'Low Stock')
            .having((s) => s.filteredItems.length, 'filteredItems length', 1)
            .having((s) => s.filteredItems.first.name, 'item name', 'Butter Naan'),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'searches items by name in SearchInventory',
      build: () {
        when(() => repository.getInventoryStream('seller_123'))
            .thenAnswer((_) => Stream.value([testItem1, testItem2]));
        return inventoryBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: 'seller_123'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SearchInventory('paneer'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'paneer')
            .having((s) => s.filteredItems.length, 'filteredItems length', 1)
            .having((s) => s.filteredItems.first.name, 'item name', 'Paneer Butter Masala'),
      ],
    );
  });
}
