import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';

class MockSellerDashboardPageBloc extends Mock
    implements SellerDashboardPageBloc {}

void main() {
  group('Performance Tests', () {
    late MockSellerDashboardPageBloc mockBloc;

    final mockData = DashboardData(
      revenueToday: 5000.0,
      revenueChangePercentage: 12.5,
      pendingOrdersCount: 7,
      newOrdersCount: 3,
      todaysOrdersCount: 15,
      lowStockCount: 4,
      activeProductsCount: 120,
      todaysOrders: [
        for (var i = 0; i < 20; i++)
          DashboardOrder(
            id: '#ORD00$i',
            customerName: 'Customer $i',
            status: i.isEven ? 'New' : 'Preparing',
            price: 250.0 + i,
            timeAgo: '${i} min ago',
          ),
      ],
      storeName: 'Picarhub',
    );

    setUp(() {
      mockBloc = MockSellerDashboardPageBloc();
      when(() => mockBloc.state).thenReturn(
        SellerDashboardLoaded(data: mockData),
      );
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Dashboard scrolling performance', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1600));

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDashboardPageUI(bloc: mockBloc),
        ),
      );
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(CustomScrollView);
      expect(scrollFinder, findsOneWidget);

      await tester.drag(scrollFinder, const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.drag(scrollFinder, const Offset(0, 800));
      await tester.pumpAndSettle();

      expect(find.text("Today's Orders"), findsWidgets);
    });
  });
}
