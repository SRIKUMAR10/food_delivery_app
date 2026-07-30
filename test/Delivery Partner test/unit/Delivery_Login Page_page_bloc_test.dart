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
  late DeliveryLoginPageBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryLoginRepository();
    mockService = MockDeliveryLoginService();
    bloc = DeliveryLoginPageBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryLoginPageBloc Unit Tests', () {
    test('initial state is correct', () {
      expect(bloc.state, const DeliveryLoginPageState());
    });

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits correct states on DeliveryLoginInitEvent success',
      build: () {
        when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => true);
        when(() => mockRepository.getSelectedLanguage()).thenAnswer((_) async => 'en');
        when(() => mockRepository.getSavedPhone()).thenAnswer((_) async => '9876543210');
        return bloc;
      },
      act: (b) => b.add(const DeliveryLoginInitEvent()),
      expect: () => [
        const DeliveryLoginPageState(status: DeliveryLoginStatus.loading),
        const DeliveryLoginPageState(
          status: DeliveryLoginStatus.initial,
          selectedLanguage: 'en',
          phone: '9876543210',
          isRememberMeChecked: true,
        ),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits updated phone on DeliveryLoginPhoneChangedEvent',
      build: () => bloc,
      act: (b) => b.add(const DeliveryLoginPhoneChangedEvent('9876543210')),
      expect: () => [
        const DeliveryLoginPageState(phone: '9876543210'),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits updated password on DeliveryLoginPasswordChangedEvent',
      build: () => bloc,
      act: (b) => b.add(const DeliveryLoginPasswordChangedEvent('secret123')),
      expect: () => [
        const DeliveryLoginPageState(password: 'secret123'),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'toggles password visibility on DeliveryLoginTogglePasswordVisibilityEvent',
      build: () => bloc,
      act: (b) => b.add(const DeliveryLoginTogglePasswordVisibilityEvent()),
      expect: () => [
        const DeliveryLoginPageState(isPasswordVisible: true),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits error state on invalid form submission',
      build: () => bloc,
      act: (b) => b.add(const DeliveryLoginSubmittedEvent()),
      expect: () => [
        const DeliveryLoginPageState(
          status: DeliveryLoginStatus.error,
          errorMessage: 'Please enter a valid 10-digit phone number and at least 6-character password',
        ),
      ],
    );

    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'emits success state on valid credentials submission',
      build: () {
        when(() => mockRepository.loginWithPhone('9876543210', 'password123')).thenAnswer((_) async => true);
        when(() => mockRepository.saveSavedPhone('9876543210')).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const DeliveryLoginPageState(
        phone: '9876543210',
        password: 'password123',
        isRememberMeChecked: true,
      ),
      act: (b) => b.add(const DeliveryLoginSubmittedEvent()),
      expect: () => [
        const DeliveryLoginPageState(
          phone: '9876543210',
          password: 'password123',
          isRememberMeChecked: true,
          status: DeliveryLoginStatus.loading,
        ),
        const DeliveryLoginPageState(
          phone: '9876543210',
          password: 'password123',
          isRememberMeChecked: true,
          status: DeliveryLoginStatus.success,
          isLoggedIn: true,
        ),
      ],
    );
  });
}
