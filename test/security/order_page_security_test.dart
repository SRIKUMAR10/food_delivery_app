import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_State.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}

class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Order Security Tests', () {
    late MockIOrderRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIOrderRepository();
      mockAuthService = MockIAuthService();

      when(() => mockAuthService.currentUserId).thenReturn(null);
    });

    blocTest<OrderBloc, OrderState>(
      'Denies access / Returns error if user is not authenticated',
      build: () {
        return OrderBloc(
          repository: mockRepository,
          authService: mockAuthService,
        );
      },
      act: (bloc) => bloc.add(LoadOrdersRequested()),
      expect: () => [
        isA<OrderError>(),
      ],
      verify: (_) {
        // Verify that repository was never queried when unauthenticated.
        verifyNever(() => mockRepository.getBuyerOrdersStream(any()));
      },
    );
  });
}
