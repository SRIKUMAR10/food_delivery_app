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

  group('DeliveryLoginPage Localization Tests', () {
    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits localized English validation messages on empty form submission',
      build: () => DeliveryLoginPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (b) => b.add(const DeliveryLoginSubmittedEvent()),
      expect: () => [
        const DeliveryLoginPageState(
          status: DeliveryLoginStatus.error,
          phoneError: 'Phone number is required',
          passwordError: 'Password is required',
          errorMessage: 'Phone number is required',
        ),
      ],
    );
  });
}
