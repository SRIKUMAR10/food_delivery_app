import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';

class MockDeliveryOnboardingRepository extends Mock
    implements DeliveryOnboardingRepositoryBase {}

class MockDeliveryOnboardingService extends Mock
    implements DeliveryOnboardingServiceBase {}

void main() {
  late MockDeliveryOnboardingRepository mockRepository;
  late MockDeliveryOnboardingService mockService;
  late DeliveryOnboardingPageBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryOnboardingRepository();
    mockService = MockDeliveryOnboardingService();
    bloc = DeliveryOnboardingPageBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryOnboardingPage Error Handling Tests', () {
    blocTest<DeliveryOnboardingPageBloc, DeliveryOnboardingPageState>(
      'emits error state when network connectivity check fails',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => false);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeliveryOnboardingInitEvent()),
      expect: () => [
        const DeliveryOnboardingPageState(
          status: DeliveryOnboardingStatus.loading,
        ),
        const DeliveryOnboardingPageState(
          status: DeliveryOnboardingStatus.error,
          errorMessage: 'Network connection unavailable',
        ),
      ],
    );
  });
}
