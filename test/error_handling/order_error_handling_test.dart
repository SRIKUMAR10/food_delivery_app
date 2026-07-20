import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}

class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Order Error Handling Tests', () {
    late MockIOrderRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIOrderRepository();
      mockAuthService = MockIAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('user123');
    });

    blocTest<OrderBloc, OrderState>(
      'Emits OrderError when repository throws an exception',
      build: () {
        when(() => mockRepository.getBuyerOrdersStream(any())).thenAnswer(
          (_) => Stream.error(
            FirebaseException(plugin: 'firestore', code: 'permission-denied'),
          ),
        );
        return OrderBloc(
          repository: mockRepository,
          authService: mockAuthService,
        );
      },
      act: (bloc) => bloc.add(LoadOrdersRequested()),
      expect: () => [isA<OrderLoading>(), isA<OrderError>()],
    );
  });
}
