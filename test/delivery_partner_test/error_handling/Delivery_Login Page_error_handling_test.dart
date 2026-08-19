import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_service.dart';

class MockDeliveryLoginRepository extends Mock
    implements DeliveryLoginRepositoryBase {}

class MockDeliveryLoginService extends Mock
    implements DeliveryLoginServiceBase {}

void main() {
  late MockDeliveryLoginRepository mockRepository;
  late MockDeliveryLoginService mockService;

  setUp(() {
    mockRepository = MockDeliveryLoginRepository();
    mockService = MockDeliveryLoginService();
  });

  group('DeliveryLoginPage Error Handling Tests', () {
    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits error status when network connectivity is offline on init',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => false);
        return DeliveryLoginPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryLoginInitEvent()),
      expect: () => [
        const DeliveryLoginPageState(status: DeliveryLoginStatus.loading),
        const DeliveryLoginPageState(
          status: DeliveryLoginStatus.error,
          errorMessage: 'No internet connection. Please check your network.',
        ),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits error status when repository throws an exception during submission',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.loginWithPhone('+919876543210', 'password123'),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryLoginPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryLoginPageState(
        phone: '9876543210',
        password: 'password123',
      ),
      act: (b) => b.add(const DeliveryLoginSubmittedEvent()),
      expect: () => [
        const DeliveryLoginPageState(
          phone: '9876543210',
          password: 'password123',
          status: DeliveryLoginStatus.loading,
        ),
        const DeliveryLoginPageState(
          phone: '9876543210',
          password: 'password123',
          status: DeliveryLoginStatus.error,
          errorMessage: 'Server unreachable',
        ),
      ],
    );
  });
}
