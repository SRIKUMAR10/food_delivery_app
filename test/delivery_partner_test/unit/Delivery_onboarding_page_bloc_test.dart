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

  group('DeliveryOnboardingPageBloc Unit Tests', () {
    test('initial state is correct', () {
      expect(bloc.state, const DeliveryOnboardingPageState());
    });

    blocTest<DeliveryOnboardingPageBloc, DeliveryOnboardingPageState>(
      'emits [loading, loaded] on DeliveryOnboardingInitEvent success',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getSelectedLanguage(),
        ).thenAnswer((_) async => 'English');
        when(() => mockRepository.getFeatures()).thenAnswer(
          (_) async => const [
            OnboardingFeatureItem(
              title: 'Fast Delivery',
              description: 'Description',
              iconKey: 'fast_delivery',
            ),
          ],
        );
        when(() => mockRepository.getPartnerStats()).thenAnswer(
          (_) async => const [
            PartnerStatItem(
              value: '10K+',
              label: 'Active Partners',
              iconKey: 'partners',
            ),
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const DeliveryOnboardingInitEvent()),
      expect: () => [
        const DeliveryOnboardingPageState(
          status: DeliveryOnboardingStatus.loading,
        ),
        isA<DeliveryOnboardingPageState>()
            .having((s) => s.status, 'status', DeliveryOnboardingStatus.loaded)
            .having((s) => s.features.length, 'features', 1)
            .having((s) => s.partnerStats.length, 'partnerStats', 1),
      ],
    );

    blocTest<DeliveryOnboardingPageBloc, DeliveryOnboardingPageState>(
      'emits language updated on DeliveryOnboardingLanguageChangedEvent',
      build: () {
        when(
          () => mockRepository.saveSelectedLanguage('Tamil'),
        ).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const DeliveryOnboardingLanguageChangedEvent('Tamil')),
      expect: () => [
        const DeliveryOnboardingPageState(selectedLanguage: 'Tamil'),
      ],
    );

    blocTest<DeliveryOnboardingPageBloc, DeliveryOnboardingPageState>(
      'emits isStarted: true on DeliveryOnboardingGetStartedClickedEvent',
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const DeliveryOnboardingGetStartedClickedEvent()),
      expect: () => [
        const DeliveryOnboardingPageState(isStarted: true),
      ],
    );

    blocTest<DeliveryOnboardingPageBloc, DeliveryOnboardingPageState>(
      'emits isNavigatingToLogin: true on DeliveryOnboardingLoginClickedEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const DeliveryOnboardingLoginClickedEvent()),
      expect: () => [
        const DeliveryOnboardingPageState(isNavigatingToLogin: true),
      ],
    );
  });
}
