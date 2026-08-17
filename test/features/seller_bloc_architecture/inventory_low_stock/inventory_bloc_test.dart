import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/inventory_item_model.dart';
import 'package:food_delivery_app/core/models/inventory_history_log_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';

class MockInventoryRepository extends Mock implements IInventoryRepository {}

void main() {
  late MockInventoryRepository mockRepository;
  late InventoryBloc bloc;
  const sellerId = 'seller123';

  const itemNormal = InventoryItemModel(id: '1', name: 'Normal Item', quantity: 20, unit: 'pcs');
  const itemLow = InventoryItemModel(id: '2', name: 'Low Item', quantity: 3, unit: 'pcs', lowStockThreshold: 5);
  const itemOut = InventoryItemModel(id: '3', name: 'Out Item', quantity: 0, unit: 'pcs');

  setUp(() {
    mockRepository = MockInventoryRepository();
    bloc = InventoryBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('InventoryBloc', () {
    test('initial state is InventoryInitial', () {
      expect(bloc.state, isA<InventoryInitial>());
    });

    blocTest<InventoryBloc, InventoryState>(
      'LoadInventoryStream emits [InventoryLoading, InventoryLoaded] and calculates summary correctly',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal, itemLow, itemOut]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadInventoryStream(sellerId: sellerId)),
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryLoaded>()
            .having((s) => s.summary.totalItems, 'total', 3)
            .having((s) => s.summary.normalStock, 'normal', 1)
            .having((s) => s.summary.lowStock, 'low', 1)
            .having((s) => s.summary.outOfStock, 'out', 1),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'FilterInventory correctly filters items',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal, itemLow, itemOut]));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const FilterInventory('Low Stock'));
        bloc.add(const FilterInventory('Out of Stock'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>()
            .having((s) => s.activeFilter, 'filter', 'Low Stock')
            .having((s) => s.filteredItems.length, 'len', 1)
            .having((s) => s.filteredItems.first.id, 'id', '2'),
        isA<InventoryLoaded>()
            .having((s) => s.activeFilter, 'filter', 'Out of Stock')
            .having((s) => s.filteredItems.length, 'len', 1)
            .having((s) => s.filteredItems.first.id, 'id', '3'),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'UpdateStockEvent emits updating logic and handles success',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal]));
        when(() => mockRepository.updateStock(
          sellerId: sellerId,
          productId: '1',
          quantityChange: 10,
          reason: 'Supplier Restock',
          note: null,
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const UpdateStockEvent(productId: '1', quantityChange: 10, reason: 'Supplier Restock'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>().having((s) => s.updatingItemIds, 'updating', {'1'}),
        isA<InventoryLoaded>()
            .having((s) => s.updatingItemIds, 'updating', isEmpty)
            .having((s) => s.successMessage, 'msg', 'Stock updated successfully.'),
      ],
      verify: (_) {
        verify(() => mockRepository.updateStock(sellerId: sellerId, productId: '1', quantityChange: 10, reason: 'Supplier Restock')).called(1);
      }
    );

    blocTest<InventoryBloc, InventoryState>(
      'SetAbsoluteStockEvent emits updating and sets stock level',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal]));
        when(() => mockRepository.setAbsoluteStock(
          sellerId: sellerId,
          productId: '1',
          newQuantity: 50,
          reason: 'Manual Adjustment',
          note: null,
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SetAbsoluteStockEvent(productId: '1', newQuantity: 50, reason: 'Manual Adjustment'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>().having((s) => s.updatingItemIds, 'updating', {'1'}),
        isA<InventoryLoaded>()
            .having((s) => s.updatingItemIds, 'updating', isEmpty)
            .having((s) => s.successMessage, 'msg', 'Stock level set successfully.'),
      ],
      verify: (_) {
        verify(() => mockRepository.setAbsoluteStock(sellerId: sellerId, productId: '1', newQuantity: 50, reason: 'Manual Adjustment')).called(1);
      }
    );

    blocTest<InventoryBloc, InventoryState>(
      'UpdateLowStockThresholdEvent updates threshold successfully',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal]));
        when(() => mockRepository.updateLowStockThreshold(
          sellerId: sellerId,
          productId: '1',
          threshold: 12,
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const UpdateLowStockThresholdEvent(productId: '1', threshold: 12));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>()
            .having((s) => s.successMessage, 'msg', 'Low stock threshold updated to 12'),
      ],
      verify: (_) {
        verify(() => mockRepository.updateLowStockThreshold(sellerId: sellerId, productId: '1', threshold: 12)).called(1);
      }
    );

    blocTest<InventoryBloc, InventoryState>(
      'BulkUpdateStockEvent emits rollback logic on failure',
      build: () {
        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal, itemLow]));
        when(() => mockRepository.bulkUpdateStock(
          sellerId: sellerId,
          productIds: ['1', '2'],
          quantityChange: -50,
          reason: 'Wastage',
          note: null,
        )).thenThrow(Exception('Negative stock is not allowed for product: Normal Item'));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const BulkUpdateStockEvent(productIds: ['1', '2'], quantityChange: -50, reason: 'Wastage'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>().having((s) => s.updatingItemIds, 'updating', {'1', '2'}),
        isA<InventoryLoaded>()
            .having((s) => s.updatingItemIds, 'updating', isEmpty)
            .having((s) => s.errorMessage, 'msg', 'Negative stock is not allowed for product: Normal Item'),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'LoadInventoryHistoryEvent subscribes to history stream and updates state',
      build: () {
        final mockLog = InventoryHistoryLogModel(
          id: 'log1',
          productId: '1',
          productName: 'Normal Item',
          sellerId: sellerId,
          previousQuantity: 10,
          newQuantity: 20,
          quantityChanged: 10,
          actionType: 'Supplier Restock',
          reason: 'Weekly Delivery',
          timestamp: DateTime.now(),
          updatedBy: sellerId,
        );

        when(() => mockRepository.getInventoryStream(sellerId))
            .thenAnswer((_) => Stream.value([itemNormal]));
        when(() => mockRepository.watchInventoryHistory(sellerId, productId: '1'))
            .thenAnswer((_) => Stream.value([mockLog]));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadInventoryStream(sellerId: sellerId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const LoadInventoryHistoryEvent(productId: '1'));
      },
      skip: 2,
      expect: () => [
        isA<InventoryLoaded>()
            .having((s) => s.isLoadingHistory, 'loading', true)
            .having((s) => s.selectedHistoryProductId, 'prodId', '1'),
        isA<InventoryLoaded>()
            .having((s) => s.isLoadingHistory, 'loading', false)
            .having((s) => s.historyLogs.length, 'logs', 1)
            .having((s) => s.historyLogs.first.id, 'logId', 'log1'),
      ],
    );
  });
}
