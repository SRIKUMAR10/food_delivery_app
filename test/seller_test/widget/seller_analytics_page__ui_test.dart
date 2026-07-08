import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart';

class MockSellerAnalyticsBloc extends Mock implements SellerAnalyticsBloc {}

void main() {
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

      expect(find.text('Error: Network Error'), findsOneWidget);
    });

    testWidgets('shows analytics data when state is AnalyticsLoaded', (
      tester,
    ) async {
      final mockData = SellerAnalyticsData(
        totalRevenue: 45600,
        percentageChange: 12.5,
        weeklyChartData: [10, 20, 30, 40, 50, 60, 70], // 7 elements
        topProducts: [
          ProductData(
            name: 'Red Pizza',
            count: 120,
            imageUrl: 'https://test.com/pizza.jpg',
          ),
        ],
      );

      when(() => mockBloc.state).thenReturn(
        AnalyticsLoaded(data: mockData, selectedTimeRange: 'This Week'),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildSubject());

        expect(find.text('Analytics'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);
        expect(find.text('Red Pizza'), findsOneWidget);
        expect(find.text('120'), findsOneWidget);
      });
    });
  });
}
