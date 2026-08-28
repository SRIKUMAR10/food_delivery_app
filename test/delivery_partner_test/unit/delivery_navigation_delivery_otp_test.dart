import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';

class MockDeliveryNavigationRepository extends Mock
    implements DeliveryNavigationRepositoryBase {}

class MockDeliveryNavigationService extends Mock
    implements DeliveryNavigationServiceBase {}

void main() {
  late MockDeliveryNavigationRepository mockRepository;
  late MockDeliveryNavigationService mockService;
  late DeliveryNavigationBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryNavigationRepository();
    mockService = MockDeliveryNavigationService();

    when(() => mockService.currentDriverId()).thenAnswer((_) async => 'driver_123');
    when(() => mockRepository.getAudioEnabled()).thenAnswer((_) async => false);
    when(() => mockRepository.getEmergencyMode()).thenAnswer((_) async => false);
    when(() => mockRepository.getHasLocationPermission()).thenAnswer((_) async => true);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(() => mockRepository.fetchActiveOrderData(orderId: any(named: 'orderId')))
        .thenAnswer((_) async => {
              'orderId': 'ORD-9999',
              'status': 'out_for_delivery',
              'deliveryOtp': '4821',
              'customerName': 'Senthilkumar',
            });
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchNearbySellers()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.updateOrderStatus(any(), any())).thenAnswer((_) async {});

    bloc = DeliveryNavigationBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Delivery Navigation OTP Verification Tests', () {
    test('DeliveryNavigationOtpInputChangedEvent updates enteredDeliveryOtp in state', () {
      bloc.add(const DeliveryNavigationOtpInputChangedEvent('4821'));

      expectLater(
        bloc.stream,
        emits(predicate<DeliveryNavigationState>((state) {
          return state.enteredDeliveryOtp == '4821' &&
              state.deliveryOtpStatus == DeliveryOtpVerificationStatus.initial;
        })),
      );
    });

    test('DeliveryNavigationVerifyDeliveryOtpEvent succeeds with valid OTP', () async {
      when(() => mockRepository.verifyDeliveryOtp(
            orderId: 'ORD-9999',
            otp: '4821',
          )).thenAnswer((_) async => true);

      bloc.add(const DeliveryNavigationVerifyDeliveryOtpEvent(
        orderId: 'ORD-9999',
        otp: '4821',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DeliveryNavigationState>((state) =>
              state.deliveryOtpStatus == DeliveryOtpVerificationStatus.verifying),
          predicate<DeliveryNavigationState>((state) =>
              state.deliveryOtpStatus == DeliveryOtpVerificationStatus.success &&
              state.isDeliveryOtpVerified == true &&
              state.navigationStage == NavigationStage.completed),
        ]),
      );

      verify(() => mockRepository.verifyDeliveryOtp(
            orderId: 'ORD-9999',
            otp: '4821',
          )).called(1);
    });

    test('DeliveryNavigationVerifyDeliveryOtpEvent fails with invalid OTP', () async {
      when(() => mockRepository.verifyDeliveryOtp(
            orderId: 'ORD-9999',
            otp: '0000',
          )).thenAnswer((_) async => false);

      bloc.add(const DeliveryNavigationVerifyDeliveryOtpEvent(
        orderId: 'ORD-9999',
        otp: '0000',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DeliveryNavigationState>((state) =>
              state.deliveryOtpStatus == DeliveryOtpVerificationStatus.verifying),
          predicate<DeliveryNavigationState>((state) =>
              state.deliveryOtpStatus == DeliveryOtpVerificationStatus.invalid &&
              state.isDeliveryOtpVerified == false),
        ]),
      );
    });
  });
}
