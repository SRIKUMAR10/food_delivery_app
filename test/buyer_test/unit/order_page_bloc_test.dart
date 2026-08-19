import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_view_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_item_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockAuthService extends Mock implements IAuthService {}
class MockOrderRepository extends Mock implements IOrderRepository {}
class MockCartRepository extends Mock implements ICartRepository {}
class FakeCartItem extends Fake implements CartItem {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCartItem());
    registerFallbackValue(OrderStatus.cancelled);
  });


  group('OrderBloc Tests', () {
    late MockAuthService mockAuthService;
    late MockOrderRepository mockOrderRepository;
    late MockCartRepository mockCartRepository;
    late OrderBloc orderBloc;

    const testUid = 'test_user_id';

    setUp(() {
      mockAuthService = MockAuthService();
      mockOrderRepository = MockOrderRepository();
      mockCartRepository = MockCartRepository();

      when(() => mockAuthService.currentUserId).thenReturn(testUid);
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value(testUid));
      when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});

      orderBloc = OrderBloc(
        repository: mockOrderRepository,
        authService: mockAuthService,
        cartRepository: mockCartRepository,
      );
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state is OrderInitial', () {
      expect(orderBloc.state, isA<OrderInitial>());
    });

    blocTest<OrderBloc, OrderState>(
      'emits OrderError when user is not authenticated',
      build: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        return OrderBloc(
          repository: mockOrderRepository,
          authService: mockAuthService,
          cartRepository: mockCartRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadOrdersRequested()),
      expect: () => [
        isA<OrderError>().having((s) => s.message, 'message', 'User not authenticated'),
      ],
    );

    test(
      'LoadOrdersRequested emits OrderLoading and then OrderLoaded with data',
      () async {
        when(() => mockAuthService.currentUserId).thenReturn(testUid);
        when(() => mockOrderRepository.getBuyerOrdersStream(testUid)).thenAnswer((_) => Stream.value([
          OrderModel(
            id: 'order1',
            customerId: testUid,
            customerName: 'Customer',
            sellerId: 'seller1',
            status: OrderStatus.newOrder,
            amount: 500.0,
            timestamp: DateTime(2026, 8, 15),
            items: const [
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

        orderBloc.add(const LoadOrdersRequested());

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

    blocTest<OrderBloc, OrderState>(
      'ReorderRequested adds items to cart and updates state',
      setUp: () {
        when(() => mockCartRepository.addItem(any(), any())).thenAnswer((_) async {});
      },
      build: () => orderBloc,
      act: (bloc) => bloc.add(
        ReorderRequested(
          OrderViewModel(
            id: 'ord_123',
            status: 'Delivered',
            totalAmount: 250.0,
            date: DateTime(2026, 8, 15),
            items: const [
              CartItem(
                id: 'prod_1',
                name: 'Burger',
                price: 250.0,
                quantity: 1,
                sellerId: 'seller_1',
              ),

            ],
          ),
        ),
      ),
      expect: () => [
        isA<ReorderSuccess>().having(
          (s) => s.message,
          'message',
          contains('ORD_123'),
        ),
      ],
      verify: (_) {
        verify(() => mockCartRepository.addItem(testUid, any())).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'CancelOrderRequested calls updateOrderStatus on repository',
      setUp: () {
        when(() => mockOrderRepository.updateOrderStatus(any(), any())).thenAnswer((_) async {});
      },
      build: () => orderBloc,
      act: (bloc) => bloc.add(const CancelOrderRequested('ord_123')),
      verify: (_) {
        verify(() => mockOrderRepository.updateOrderStatus('ord_123', OrderStatus.cancelled)).called(1);
      },
    );
  });
}

