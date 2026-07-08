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
    );
    final mockCustomers = [
      const CustomerItem(
        id: '1',
        name: 'Mike Ross',
        orderCount: 12,
        avatarUrl: '',
      ),
      const CustomerItem(
        id: '2',
        name: 'John Doe',
        orderCount: 10,
        avatarUrl: '',
      ),
    ];

    setUp(() {
      repository = MockSellerCustomerRepository();
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
          () => repository.getCustomerStats(),
        ).thenAnswer((_) async => mockStats);
        when(
          () => repository.getCustomers(offset: 0, limit: 10),
        ).thenAnswer((_) async => mockCustomers);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCustomerData()),
      expect: () => [
        const SellerCustomerLoading(),
        SellerCustomerLoaded(
          stats: mockStats,
          customers: mockCustomers,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<SellerCustomerBloc, SellerCustomerState>(
      'emits [Loading, Error] when LoadCustomerData fails',
      build: () {
        when(
          () => repository.getCustomerStats(),
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
        hasReachedMax: false,
      ),
      build: () {
        when(() => repository.getCustomers(offset: 2, limit: 10)).thenAnswer(
          (_) async => [
            const CustomerItem(
              id: '3',
              name: 'Sarah Wilson',
              orderCount: 8,
              avatarUrl: '',
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
            ),
          ],
          hasReachedMax: true,
          isPaginatedLoading: false,
        ),
      ],
    );
  });
}
