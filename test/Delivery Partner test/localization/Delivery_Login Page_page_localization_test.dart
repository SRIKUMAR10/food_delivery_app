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

  group('DeliveryLoginPage Localization Tests', () {
    blocTest<DeliveryLoginPageBloc, DeliveryLoginPageState>(
      'saves and updates language to Tamil (ta) on DeliveryLoginLanguageChangedEvent',
      build: () {
        when(() => mockRepository.saveSelectedLanguage('ta')).thenAnswer((_) async {});
        return DeliveryLoginPageBloc(repository: mockRepository, service: mockService);
      },
      act: (b) => b.add(const DeliveryLoginLanguageChangedEvent('ta')),
      expect: () => [
        const DeliveryLoginPageState(selectedLanguage: 'ta'),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSelectedLanguage('ta')).called(1);
      },
    );
  });
}
