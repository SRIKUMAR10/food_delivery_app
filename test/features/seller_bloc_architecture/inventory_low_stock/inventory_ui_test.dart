import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_ui.dart';

class MockInventoryRepository extends Mock implements IInventoryRepository {}

void main() {
  late MockInventoryRepository mockRepo;

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

  testWidgets('renders loading indicator while loading inventory stream', (tester) async {
    when(() => mockRepo.getInventoryStream(any())).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
