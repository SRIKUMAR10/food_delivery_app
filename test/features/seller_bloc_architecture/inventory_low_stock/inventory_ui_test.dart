import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_repository.dart';

class MockInventoryBloc extends Mock implements InventoryBloc {}
class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late MockInventoryBloc mockBloc;
  late MockInventoryRepository mockRepo;

  setUp(() {
    mockBloc = MockInventoryBloc();
    mockRepo = MockInventoryRepository();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<InventoryBloc>.value(value: mockBloc),
        ],
        child: RepositoryProvider<InventoryRepository>.value(
          value: mockRepo,
          child: const Scaffold(body: InventoryLowStockPage()), // Wrap in scaffold isn't necessary but InventoryLowStockPage has its own Scaffold
        ),
      ),
    );
  }

  // The actual build method of InventoryLowStockPage creates its own Bloc internally!
  // Wait, I need to test the view directly to inject the mock bloc.
  Widget buildViewWidget() {
    return MaterialApp(
      home: BlocProvider<InventoryBloc>.value(
        value: mockBloc,
        // Since InventoryLowStockPage creates its own Bloc, we can't test it directly easily without overriding.
        // I will test it by creating the widget tree manually bypassing the wrapper that creates the bloc.
        // Wait, since _InventoryLowStockView is private, I can't instantiate it here.
        // So I should modify the actual InventoryLowStockPage to accept an injected bloc if provided, or I can just use integration testing.
        // Actually, if we just use a generic wrapper, we might get an error because the real `InventoryLowStockPage` calls `context.read<InventoryRepository>()`.
        child: Builder(
          builder: (context) {
            // We just need to mock the repository and let it build its own bloc!
            return RepositoryProvider<InventoryRepository>.value(
              value: mockRepo,
              child: const InventoryLowStockPage(),
            );
          }
        ),
      ),
    );
  }

  testWidgets('renders loading state when initial', (tester) async {
    // When the page builds, it creates a real bloc which emits initial state, then loads.
    // We can just verify if the repository is called.
    when(() => mockRepo.getInventoryStream('seller123')).thenAnswer((_) => const Stream.empty());
    
    await tester.pumpWidget(buildViewWidget());
    
    // Pump once to allow the Bloc to process the initial LoadInventoryStream event
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
