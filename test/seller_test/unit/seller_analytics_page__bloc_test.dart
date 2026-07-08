import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart';

class MockSellerAnalyticsRepository extends Mock
    implements SellerAnalyticsRepository {}

void main() {
  group('SellerAnalyticsBloc', () {
    late SellerAnalyticsBloc bloc;
    late MockSellerAnalyticsRepository mockRepository;

    final mockData = SellerAnalyticsData(
      totalRevenue: 1000,
      percentageChange: 10,
      weeklyChartData: const [10, 20, 30, 40, 50, 60, 70],
      topProducts: [],
    );

    setUp(() {
      mockRepository = MockSellerAnalyticsRepository();
      bloc = SellerAnalyticsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AnalyticsInitial', () {
      expect(bloc.state, isA<AnalyticsInitial>());
    });

    blocTest<SellerAnalyticsBloc, SellerAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] when LoadSellerAnalytics is added successfully',
      build: () {
        when(
          () => mockRepository.fetchAnalyticsData(any()),
        ).thenAnswer((_) async => mockData);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSellerAnalytics()),
      expect: () => [
        isA<AnalyticsLoading>(),
        isA<AnalyticsLoaded>()
            .having((s) => s.data, 'data', mockData)
            .having(
              (s) => s.selectedTimeRange,
              'selectedTimeRange',
              'This Week',
            ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchAnalyticsData('This Week')).called(1);
      },
    );

    blocTest<SellerAnalyticsBloc, SellerAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsError] when LoadSellerAnalytics fails',
      build: () {
        when(
          () => mockRepository.fetchAnalyticsData(any()),
        ).thenThrow(Exception('Failed to load'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSellerAnalytics()),
      expect: () => [
        isA<AnalyticsLoading>(),
        isA<AnalyticsError>().having(
          (s) => s.message,
          'message',
          'Exception: Failed to load',
        ),
      ],
    );
  });
}
