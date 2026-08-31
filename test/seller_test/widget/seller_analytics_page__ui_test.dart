import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart';
import 'package:food_delivery_app/core/models/analytics_data_model.dart';

class MockSellerAnalyticsBloc extends Mock implements SellerAnalyticsBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  late MockSellerAnalyticsBloc mockBloc;

  setUp(() {
    mockBloc = MockSellerAnalyticsBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<SellerAnalyticsBloc>.value(
        value: mockBloc,
        child: const SellerAnalyticsPageUI(),
      ),
    );
  }

  group('SellerAnalyticsPageUI Widget Tests', () {
    testWidgets('shows loading skeleton when state is AnalyticsLoading', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(AnalyticsLoading());

      await tester.pumpWidget(buildSubject());

      // We expect skeleton elements (containers with specific colors, or just check existence)
      // Since skeleton doesn't have text, we just verify it renders without error.
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows error message when state is AnalyticsError', (
      tester,
    ) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const AnalyticsError(message: 'Network Error'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Unable to Load Analytics'), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('shows analytics data when state is AnalyticsLoaded', (
      tester,
    ) async {
      final mockData = AnalyticsDataModel(
        todayRevenue: 500,
        thisWeekRevenue: 45600,
        thisMonthRevenue: 150000,
        currentPeriodCustomers: 200,
        previousPeriodCustomers: 180,
        customerGrowthPercentage: 12.5,
        top3PeakTimeSlots: const ['1 PM - 2 PM', '6 PM - 7 PM', '12 PM - 1 PM'],
        revenueChartData: const [],
        bestSellingProducts: [
          BestSellingProductModel(
            productName: 'Red Pizza',
            unitsSold: 120,
            revenueGenerated: 1200.0,
          ),
        ],
      );

      when(() => mockBloc.state).thenReturn(
        AnalyticsLoaded(data: mockData, selectedTimeRange: 'This Week'),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Analytics'), findsOneWidget);
        expect(find.text('Product Intelligence'), findsOneWidget);
        expect(find.text('Red Pizza'), findsWidgets);
      });
    });
  });
}
