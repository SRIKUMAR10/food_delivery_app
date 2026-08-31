import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/models/inventory_item_model.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_ui.dart';

class MockInventoryRepository extends Mock implements IInventoryRepository {}

void main() {
  late MockInventoryRepository mockRepo;

  final sampleItems = [
    const InventoryItemModel(
      id: 'item-1',
      name: 'Cheese',
      quantity: 2.0,
      unit: 'kg',
      lowStockThreshold: 5,
      price: 120.0,
      category: 'Dairy',
    ),
    const InventoryItemModel(
      id: 'item-2',
      name: 'Tomato',
      quantity: 0.0,
      unit: 'kg',
      lowStockThreshold: 10,
      price: 40.0,
      category: 'Vegetables',
    ),
  ];

  setUp(() {
    mockRepo = MockInventoryRepository();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: RepositoryProvider<IInventoryRepository>.value(
        value: mockRepo,
        child: const InventoryLowStockPage(),
      ),
    );
  }

  testWidgets('InventoryLowStockPage UI Test renders loaded inventory items', (tester) async {
    when(() => mockRepo.getInventoryStream(any()))
        .thenAnswer((_) => Stream.value(sampleItems));

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Inventory Management'), findsOneWidget);
    expect(find.text('Cheese'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
  });
}
