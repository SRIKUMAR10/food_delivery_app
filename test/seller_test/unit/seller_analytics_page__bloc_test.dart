import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/analytics_data_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart';

class MockSellerAnalyticsRepository extends Mock implements SellerAnalyticsRepository {}

void main() {
  late MockSellerAnalyticsRepository mockRepository;
  late SellerAnalyticsBloc bloc;
  final sellerId = 'seller123';

  final validData = AnalyticsDataModel(
    todayRevenue: 100,
    thisWeekRevenue: 500,
    thisMonthRevenue: 2000,
    currentPeriodCustomers: 10,
    previousPeriodCustomers: 5,
    customerGrowthPercentage: 100.0,
    top3PeakTimeSlots: ['12 PM - 1 PM'],
    bestSellingProducts: const [],
    revenueChartData: const [],
  );

  final emptyData = AnalyticsDataModel(
    todayRevenue: 0,
    thisWeekRevenue: 0,
    thisMonthRevenue: 0,
    currentPeriodCustomers: 0,
    previousPeriodCustomers: 0,
    customerGrowthPercentage: 0,
    top3PeakTimeSlots: const [],
    bestSellingProducts: const [],
    revenueChartData: const [],
  );

  setUp(() {
    mockRepository = MockSellerAnalyticsRepository();
    when(() => mockRepository.streamFavoritesAnalytics(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.streamRatingAnalytics(any()))
        .thenAnswer((_) => const Stream.empty());
    bloc = SellerAnalyticsBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('SellerAnalyticsBloc', () {
    test('initial state is AnalyticsInitial', () {
      expect(bloc.state, isA<AnalyticsInitial>());
    });

    blocTest<SellerAnalyticsBloc, SellerAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] when data is present',
      build: () {
        when(() => mockRepository.fetchAnalyticsData(sellerId, 'Weekly'))
            .thenAnswer((_) async => validData);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerAnalytics(sellerId: sellerId, timeRange: 'Weekly')),
      expect: () => [
        isA<AnalyticsLoading>(),
        isA<AnalyticsLoaded>()
            .having((s) => s.data.todayRevenue, 'revenue', 100)
            .having((s) => s.selectedTimeRange, 'timeRange', 'Weekly'),
      ],
    );

    blocTest<SellerAnalyticsBloc, SellerAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsEmpty] when data is empty',
      build: () {
        when(() => mockRepository.fetchAnalyticsData(sellerId, 'Monthly'))
            .thenAnswer((_) async => emptyData);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerAnalytics(sellerId: sellerId, timeRange: 'Monthly')),
      expect: () => [
        isA<AnalyticsLoading>(),
        isA<AnalyticsEmpty>()
            .having((s) => s.selectedTimeRange, 'timeRange', 'Monthly'),
      ],
    );

    blocTest<SellerAnalyticsBloc, SellerAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsError] when repository throws',
      build: () {
        when(() => mockRepository.fetchAnalyticsData(sellerId, 'Weekly'))
            .thenThrow(Exception('Failed to fetch'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerAnalytics(sellerId: sellerId, timeRange: 'Weekly')),
      expect: () => [
        isA<AnalyticsLoading>(),
        isA<AnalyticsError>().having((s) => s.message, 'message', 'Exception: Failed to fetch'),
      ],
    );
  });
}
