import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_item_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockAuthService extends Mock implements IAuthService {}
class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  group('OrderBloc Tests', () {
    late MockAuthService mockAuthService;
    late MockOrderRepository mockOrderRepository;
    late OrderBloc orderBloc;

    const testUid = 'test_user_id';

    setUp(() {
      mockAuthService = MockAuthService();
      mockOrderRepository = MockOrderRepository();

      when(() => mockAuthService.currentUserId).thenReturn(testUid);
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value(testUid));

      orderBloc = OrderBloc(
        repository: mockOrderRepository,
        authService: mockAuthService,
      );
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state is OrderInitial', () {
      expect(orderBloc.state, isA<OrderInitial>());
    });

    blocTest<OrderBloc, OrderState>(
      'gracefully emits empty OrderLoaded when user is not logged in',
      build: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        return OrderBloc(
          repository: mockOrderRepository,
          authService: mockAuthService,
        );
      },
      act: (bloc) => bloc.add(LoadOrdersRequested()),
      expect: () => [
        isA<OrderLoaded>().having((s) => s.orders, 'orders', isEmpty),
      ],
    );

    test(
      'LoadOrdersRequested emits OrderLoading and then OrderLoaded with data',
      () async {
        // Setup mock data
        when(() => mockAuthService.currentUserId).thenReturn(testUid);
        when(() => mockOrderRepository.getBuyerOrdersStream(testUid)).thenAnswer((_) => Stream.value([
          OrderModel(
            id: 'order1',
            customerId: testUid,
            customerName: 'Customer',
            sellerId: 'seller1',
            status: OrderStatus.newOrder,
            amount: 500.0,
            timestamp: DateTime.now(),
            items: [
              OrderItemModel(
                productId: 'item1',
                name: 'Pizza',
                price: 500.0,
                quantity: 1,
              ),
            ],
            deliveryAddress: 'Address',
            paymentMethod: 'Cash',
          ),
        ]));

        orderBloc.add(LoadOrdersRequested());

        await expectLater(
          orderBloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderLoaded>().having(
              (s) => s.orders.length,
              'orders length',
              1,
            ),
          ]),
        );
      },
    );
  });
}
