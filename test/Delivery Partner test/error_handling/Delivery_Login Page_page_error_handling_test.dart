import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_service.dart';

class MockDeliveryLoginRepository extends Mock implements DeliveryLoginRepositoryBase {}
class MockDeliveryLoginService extends Mock implements DeliveryLoginServiceBase {}

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
        when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => false);
        return DeliveryLoginPageBloc(repository: mockRepository, service: mockService);
      },
      act: (b) => b.add(const DeliveryLoginInitEvent()),
      expect: () => [
        const DeliveryLoginPageState(status: DeliveryLoginStatus.loading),
        const DeliveryLoginPageState(
          status: DeliveryLoginStatus.error,
          errorMessage: 'Network connection unavailable',
        ),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits error status when repository throws an exception during submission',
      build: () {
        when(() => mockRepository.loginWithPhone('9876543210', 'password123'))
            .thenThrow(Exception('Server unreachable'));
        return DeliveryLoginPageBloc(repository: mockRepository, service: mockService);
      },
      seed: () => const DeliveryLoginPageState(phone: '9876543210', password: 'password123'),
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
