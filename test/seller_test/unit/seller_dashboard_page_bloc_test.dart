import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';

class MockSellerDashboardRepository extends Mock implements SellerDashboardRepository {}

void main() {
  group('SellerDashboardPageBloc', () {
    late MockSellerDashboardRepository mockRepository;
    late SellerDashboardPageBloc bloc;

    final mockData = DashboardData(
      revenueToday: 500.0,
      revenueChangePercentage: 10.0,
      pendingOrdersCount: 5,
      todaysOrdersCount: 10,
      lowStockCount: 2,
      activeProductsCount: 20,
      todaysOrders: [],
      storeName: 'Picarhub',
    );

    setUp(() {
      mockRepository = MockSellerDashboardRepository();
      bloc = SellerDashboardPageBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SellerDashboardInitial', () {
      expect(bloc.state, isA<SellerDashboardInitial>());
    });

    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoading, SellerDashboardLoaded] when LoadDashboardData is added',
      build: () {
        when(() => mockRepository.getDashboardDataStream())
            .thenAnswer((_) => Stream.value(mockData));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDashboardData()),
      expect: () => [
        isA<SellerDashboardLoading>(),
        isA<SellerDashboardLoaded>(),
      ],
    );

    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoaded] when RefreshDashboardData is added',
      build: () {
        when(() => mockRepository.getDashboardData())
            .thenAnswer((_) async => mockData);
        return bloc;
      },
      act: (bloc) => bloc.add(RefreshDashboardData()),
      expect: () => [isA<SellerDashboardLoaded>()],
    );
  });
}
