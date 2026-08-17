import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/availability_cubit.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';

class MockDeliveryPartnerRepository extends Mock implements DeliveryPartnerRepository {}
class MockDeliveryActiveOrderSessionRepository extends Mock
    implements DeliveryActiveOrderSessionRepository {}

void main() {
  late MockDeliveryPartnerRepository mockRepo;
  late MockDeliveryActiveOrderSessionRepository mockSessionRepo;

  setUp(() {
    mockRepo = MockDeliveryPartnerRepository();
    mockSessionRepo = MockDeliveryActiveOrderSessionRepository();
    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockSessionRepo.sessionStream)
        .thenAnswer((_) => const Stream.empty());
  });

  group('AvailabilityCubit Tests', () {
    test('initial state has default online and available values', () {
      final cubit = AvailabilityCubit(
        repository: mockRepo,
        sessionRepo: mockSessionRepo,
      );
      expect(cubit.state.isOnline, true);
      expect(cubit.state.isAvailable, true);
      expect(cubit.state.isBusy, false);
      expect(cubit.state.partnerStatus, 'online');
      cubit.close();
    });

    blocTest<AvailabilityCubit, AvailabilityState>(
      'goOffline updates state to offline and unavailable',
      build: () {
        when(() => mockSessionRepo.setOnlineStatus(false)).thenReturn(null);
        return AvailabilityCubit(
          repository: mockRepo,
          sessionRepo: mockSessionRepo,
        );
      },
      act: (cubit) => cubit.goOffline(),
      expect: () => [
        isA<AvailabilityState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<AvailabilityState>()
            .having((s) => s.isOnline, 'isOnline', false)
            .having((s) => s.isAvailable, 'isAvailable', false)
            .having((s) => s.partnerStatus, 'partnerStatus', 'offline')
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<AvailabilityCubit, AvailabilityState>(
      'goOnline updates state to online and available',
      seed: () => const AvailabilityState(
        isOnline: false,
        isAvailable: false,
        partnerStatus: 'offline',
      ),
      build: () {
        when(() => mockSessionRepo.setOnlineStatus(true)).thenReturn(null);
        return AvailabilityCubit(
          repository: mockRepo,
          sessionRepo: mockSessionRepo,
        );
      },
      act: (cubit) => cubit.goOnline(),
      expect: () => [
        isA<AvailabilityState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<AvailabilityState>()
            .having((s) => s.isOnline, 'isOnline', true)
            .having((s) => s.isAvailable, 'isAvailable', true)
            .having((s) => s.partnerStatus, 'partnerStatus', 'online')
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<AvailabilityCubit, AvailabilityState>(
      'setBusy updates busy state with currentOrderId',
      build: () => AvailabilityCubit(
        repository: mockRepo,
        sessionRepo: mockSessionRepo,
      ),
      act: (cubit) => cubit.setBusy(orderId: 'ORD_999'),
      expect: () => [
        isA<AvailabilityState>()
            .having((s) => s.isBusy, 'isBusy', true)
            .having((s) => s.isAvailable, 'isAvailable', false)
            .having((s) => s.partnerStatus, 'partnerStatus', 'busy')
            .having((s) => s.currentOrderId, 'currentOrderId', 'ORD_999'),
      ],
    );

    blocTest<AvailabilityCubit, AvailabilityState>(
      'setAvailable resets busy flag and clears orderId',
      seed: () => const AvailabilityState(
        isBusy: true,
        isAvailable: false,
        partnerStatus: 'busy',
        currentOrderId: 'ORD_999',
      ),
      build: () => AvailabilityCubit(
        repository: mockRepo,
        sessionRepo: mockSessionRepo,
      ),
      act: (cubit) => cubit.setAvailable(),
      expect: () => [
        isA<AvailabilityState>()
            .having((s) => s.isBusy, 'isBusy', false)
            .having((s) => s.isAvailable, 'isAvailable', true)
            .having((s) => s.partnerStatus, 'partnerStatus', 'online')
            .having((s) => s.currentOrderId, 'currentOrderId', isNull),
      ],
    );
  });
}
