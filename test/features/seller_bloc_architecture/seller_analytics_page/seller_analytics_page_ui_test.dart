import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../mock_firebase.dart';
import 'package:food_delivery_app/core/models/analytics_data_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart';

class MockSellerAnalyticsBloc extends Mock implements SellerAnalyticsBloc {}

void main() {
  late MockSellerAnalyticsBloc mockBloc;

  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockBloc = MockSellerAnalyticsBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SellerAnalyticsBloc>.value(
        value: mockBloc,
        child: const SellerAnalyticsPageUI(),
      ),
    );
  }

  testWidgets('renders skeleton loader when initial or loading', (tester) async {
    when(() => mockBloc.state).thenReturn(AnalyticsInitial());
    
    await tester.pumpWidget(buildTestWidget());
    
    expect(find.byType(DropdownButton<String>), findsNothing); // Skeleton doesn't have dropdown
  });

  testWidgets('renders empty state correctly', (tester) async {
    when(() => mockBloc.state).thenReturn(const AnalyticsEmpty(selectedTimeRange: 'Weekly'));
    
    await tester.pumpWidget(buildTestWidget());
    
    expect(find.text('No completed orders yet.'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget); // Summary cards still render
  });

  testWidgets('renders data correctly when loaded', (tester) async {
    final validData = AnalyticsDataModel(
      todayRevenue: 500,
      thisWeekRevenue: 2000,
      thisMonthRevenue: 8000,
      currentPeriodCustomers: 128,
      previousPeriodCustomers: 110,
      customerGrowthPercentage: 16.4,
      top3PeakTimeSlots: const ['12 PM - 1 PM'],
      bestSellingProducts: const [
        BestSellingProductModel(productName: 'Cheese Pizza', unitsSold: 42, revenueGenerated: 4200),
      ],
      revenueChartData: [
        ChartDataPoint(date: DateTime(2023, 1, 1), value: 500),
      ],
    );

    when(() => mockBloc.state).thenReturn(AnalyticsLoaded(data: validData, selectedTimeRange: 'Weekly'));
    
    await tester.pumpWidget(buildTestWidget());
    
    // Revenue Summaries
    expect(find.text('₹500'), findsWidgets);
    expect(find.text('₹2,000'), findsOneWidget);
    expect(find.text('₹8,000'), findsOneWidget);
    
    // Customer Growth
    expect(find.text('128'), findsOneWidget);
    expect(find.text('16.4%'), findsOneWidget);
    
    // Peak Time
    expect(find.text('12 PM - 1 PM'), findsOneWidget);

    // Best Seller
    expect(find.text('Cheese Pizza'), findsOneWidget);
    expect(find.text('42 units sold'), findsOneWidget);
  });
}
