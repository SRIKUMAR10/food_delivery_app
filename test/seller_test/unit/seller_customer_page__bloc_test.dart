import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';
import 'package:food_delivery_app/repositories/seller_customer_repository.dart';

class MockSellerCustomerRepository extends Mock
    implements SellerCustomerRepository {}

void main() {
  group('SellerCustomerBloc Tests', () {
    late SellerCustomerRepository repository;
    late SellerCustomerBloc bloc;

    final mockStats = const CustomerStats(
      totalCustomers: 1245,
      repeatCustomers: 320,
      totalRevenue: 25000.0,
      averageOrderValue: 250.0,
    );
    final mockCustomers = [
      const CustomerItem(
        id: '1',
        name: 'Mike Ross',
        orderCount: 12,
        avatarUrl: '',
        totalSpent: 3000.0,
      ),
      const CustomerItem(
        id: '2',
        name: 'John Doe',
        orderCount: 10,
        avatarUrl: '',
        totalSpent: 2500.0,
      ),
    ];

    setUp(() {
      repository = MockSellerCustomerRepository();
      when(() => repository.watchCustomerData(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) => const Stream.empty());
      bloc = SellerCustomerBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is correct', () {
      expect(bloc.state, const SellerCustomerInitial());
    });

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'emits [Loading, Loaded] when LoadCustomerData succeeds',
      build: () {
        when(
          () => repository.getCustomerStats(sellerId: any(named: 'sellerId')),
        ).thenAnswer((_) async => mockStats);
        when(
          () => repository.getCustomers(offset: 0, limit: 10, sellerId: any(named: 'sellerId')),
        ).thenAnswer((_) async => mockCustomers);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCustomerData()),
      expect: () => [
        const SellerCustomerLoading(),
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          filteredCustomers: mockCustomers,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'emits [Loading, Error] when LoadCustomerData fails',
      build: () {
        when(
          () => repository.getCustomerStats(sellerId: any(named: 'sellerId')),
        ).thenThrow(Exception('Network Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCustomerData()),
      expect: () => [
        const SellerCustomerLoading(),
        const SellerCustomerError('Exception: Network Error'),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'emits Loaded with pagination changes when LoadMoreCustomers is called',
      seed: () => SellerCustomerLoaded(
        stats: mockStats,
        customers: mockCustomers,
        filteredCustomers: mockCustomers,
        hasReachedMax: false,
      ),
      build: () {
        when(() => repository.getCustomers(offset: 2, limit: 10, sellerId: any(named: 'sellerId'))).thenAnswer(
          (_) async => [
            const CustomerItem(
              id: '3',
              name: 'Sarah Wilson',
              orderCount: 8,
              avatarUrl: '',
              totalSpent: 1200.0,
            ),
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoreCustomers()),
      expect: () => [
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          filteredCustomers: mockCustomers,
          hasReachedMax: false,
          isPaginatedLoading: true,
        ),
        SellerCustomerLoaded(
          stats: mockStats,
          customers: [
            mockCustomers[0],
            mockCustomers[1],
            const CustomerItem(
              id: '3',
              name: 'Sarah Wilson',
              orderCount: 8,
              avatarUrl: '',
              totalSpent: 1200.0,
            ),
          ],
          filteredCustomers: [
            mockCustomers[0],
            mockCustomers[1],
            const CustomerItem(
              id: '3',
              name: 'Sarah Wilson',
              orderCount: 8,
              avatarUrl: '',
              totalSpent: 1200.0,
            ),
          ],
          hasReachedMax: true,
          isPaginatedLoading: false,
        ),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'filters customers correctly when SearchCustomers is called',
      seed: () => SellerCustomerLoaded(
        stats: mockStats,
        customers: mockCustomers,
        filteredCustomers: mockCustomers,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchCustomers('Mike')),
      expect: () => [
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          filteredCustomers: [mockCustomers[0]],
          searchQuery: 'Mike',
        ),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'sorts customers correctly when SortCustomers is called',
      seed: () => SellerCustomerLoaded(
        stats: mockStats,
        customers: mockCustomers,
        filteredCustomers: mockCustomers,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const SortCustomers(CustomerSortOption.nameAsc)),
      expect: () => [
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          filteredCustomers: [mockCustomers[1], mockCustomers[0]],
          selectedSort: CustomerSortOption.nameAsc,
        ),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'updates selected customer when SelectCustomer is called',
      seed: () => SellerCustomerLoaded(
        stats: mockStats,
        customers: mockCustomers,
        filteredCustomers: mockCustomers,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(SelectCustomer(mockCustomers[0])),
      expect: () => [
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          filteredCustomers: mockCustomers,
          selectedCustomer: mockCustomers[0],
        ),
      ],
    );
  });
}
