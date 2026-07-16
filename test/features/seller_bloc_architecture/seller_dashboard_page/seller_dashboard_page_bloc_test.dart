import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';

class MockSellerDashboardRepository extends Mock
    implements SellerDashboardRepository {}

void main() {
  late MockSellerDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerDashboardRepository();
  });

  final tDashboardData = const DashboardData(
    revenueToday: 1000.0,
    revenueChangePercentage: 10.0,
    pendingOrdersCount: 5,
    todaysOrdersCount: 15,
    lowStockCount: 2,
    activeProductsCount: 10,
    todaysOrders: [],
    storeName: 'Picarhub',
  );

  group('SellerDashboardPageBloc', () {
    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoading, SellerDashboardLoaded] when LoadDashboardData is added and stream emits data',
      build: () {
        when(() => mockRepository.getDashboardDataStream())
            .thenAnswer((_) => Stream.value(tDashboardData));
        return SellerDashboardPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadDashboardData()),
      expect: () => [
        isA<SellerDashboardLoading>(),
        SellerDashboardLoaded(data: tDashboardData),
      ],
    );

    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoading, SellerDashboardError] when repository throws error',
      build: () {
        when(() => mockRepository.getDashboardDataStream())
            .thenAnswer((_) => Stream.error('Error fetching data'));
        return SellerDashboardPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadDashboardData()),
      expect: () => [
        isA<SellerDashboardLoading>(),
        const SellerDashboardError(message: 'Failed to load dashboard data.'),
      ],
    );
  });
}
