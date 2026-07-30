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

  group('DeliveryLoginPage State Restoration & Persistence Tests', () {
    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'restores saved phone number on init when remember me was checked previously',
      build: () {
        when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => true);
        when(() => mockRepository.getSelectedLanguage()).thenAnswer((_) async => 'en');
        when(() => mockRepository.getSavedPhone()).thenAnswer((_) async => '9876543210');
        return DeliveryLoginPageBloc(repository: mockRepository, service: mockService);
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
  });
}
