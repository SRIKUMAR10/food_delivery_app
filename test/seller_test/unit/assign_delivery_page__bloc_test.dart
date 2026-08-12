import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__repository.dart';

class MockAssignDeliveryRepository extends Mock
    implements AssignDeliveryRepository {}

List<RiderModel> _testRiders() => [
      const RiderModel(
        id: 'r1',
        name: 'John',
        rating: 4.8,
        distance: '2.3 km',
        imageUrl: 'https://example.com/john.jpg',
      ),
      const RiderModel(
        id: 'r2',
        name: 'Jane',
        rating: 4.5,
        distance: '1.0 km',
        imageUrl: '',
      ),
    ];

void main() {
  late MockAssignDeliveryRepository repository;

  setUp(() {
    repository = MockAssignDeliveryRepository();
  });

  AssignDeliveryBloc buildBloc() {
    return AssignDeliveryBloc(repository: repository, orderId: 'order_1');
  }

  group('initial state', () {
    test('is AssignDeliveryInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<AssignDeliveryInitial>());
    });
  });

  group('LoadRidersEvent', () {
    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'emits loading then loaded with riders from stream',
      setUp: () {
        when(() => repository.watchAvailableRiders('order_1'))
            .thenAnswer((_) => Stream.value(_testRiders()));
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const LoadRidersEvent(orderId: 'order_1'));
      },
      expect: () => [
        AssignDeliveryLoading(),
        AssignDeliveryLoaded(riders: _testRiders()),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'emits loading then loaded with empty riders',
      setUp: () {
        when(() => repository.watchAvailableRiders('order_1'))
            .thenAnswer((_) => Stream<List<RiderModel>>.value([]));
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const LoadRidersEvent(orderId: 'order_1'));
      },
      expect: () => [
        AssignDeliveryLoading(),
        const AssignDeliveryLoaded(riders: []),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'cancels previous subscription and re-emits on new LoadRidersEvent',
      setUp: () {
        when(() => repository.watchAvailableRiders('order_1'))
            .thenAnswer((_) => Stream.value(_testRiders()));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const LoadRidersEvent(orderId: 'order_1'));
        await Future.delayed(Duration.zero);
        bloc.add(const LoadRidersEvent(orderId: 'order_1'));
      },
      expect: () => [
        AssignDeliveryLoading(),
        AssignDeliveryLoaded(riders: _testRiders()),
        AssignDeliveryLoading(),
        AssignDeliveryLoaded(riders: _testRiders()),
      ],
    );
  });

  group('RidersUpdatedEvent (real-time updates)', () {
    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'emits loaded from non-loaded state',
      build: buildBloc,
      act: (bloc) {
        bloc.add(RidersUpdatedEvent(riders: _testRiders()));
      },
      expect: () => [
        AssignDeliveryLoaded(riders: _testRiders()),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'updates riders while preserving selectedRiderId',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: [],
        selectedRiderId: 'r1',
      ),
      act: (bloc) {
        bloc.add(RidersUpdatedEvent(riders: _testRiders()));
      },
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'updates riders while preserving delivery instructions',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: [],
        deliveryInstructions: 'Ring the bell',
      ),
      act: (bloc) {
        bloc.add(RidersUpdatedEvent(riders: _testRiders()));
      },
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          deliveryInstructions: 'Ring the bell',
        ),
      ],
    );
  });

  group('SelectRiderEvent', () {
    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'selects a rider by id',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(riders: _testRiders()),
      act: (bloc) => bloc.add(const SelectRiderEvent(riderId: 'r2')),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r2',
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'changes selection from one rider to another',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        selectedRiderId: 'r1',
      ),
      act: (bloc) => bloc.add(const SelectRiderEvent(riderId: 'r2')),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r2',
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'does nothing when state is not loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(const SelectRiderEvent(riderId: 'r1')),
      expect: () => [],
    );
  });

  group('UpdateInstructionsEvent', () {
    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'updates delivery instructions',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(riders: _testRiders()),
      act: (bloc) =>
          bloc.add(const UpdateInstructionsEvent(instructions: 'Leave at door')),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          deliveryInstructions: 'Leave at door',
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'clears instructions with empty string',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        deliveryInstructions: 'Old note',
      ),
      act: (bloc) =>
          bloc.add(const UpdateInstructionsEvent(instructions: '')),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          deliveryInstructions: '',
        ),
      ],
    );
  });

  group('SubmitAssignDeliveryEvent', () {
    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'emits error when no rider selected',
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(riders: _testRiders()),
      act: (bloc) => bloc.add(const SubmitAssignDeliveryEvent()),
      expect: () => [
        const AssignDeliveryError(message: 'Please select a rider first.'),
        AssignDeliveryLoaded(riders: _testRiders()),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'assigns rider and emits success',
      setUp: () {
        when(() => repository.assignRider('order_1', 'r1', any()))
            .thenAnswer((_) async => true);
      },
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        selectedRiderId: 'r1',
      ),
      act: (bloc) => bloc.add(const SubmitAssignDeliveryEvent()),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          isSubmitting: true,
        ),
        AssignDeliverySuccess(),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'handles assign failure with isSubmitting reset',
      setUp: () {
        when(() => repository.assignRider('order_1', 'r1', any()))
            .thenThrow(Exception('Network error'));
      },
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        selectedRiderId: 'r1',
      ),
      act: (bloc) => bloc.add(const SubmitAssignDeliveryEvent()),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          isSubmitting: true,
        ),
        isA<AssignDeliveryError>(),
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          isSubmitting: false,
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'handles false return from assignRider',
      setUp: () {
        when(() => repository.assignRider('order_1', 'r1', any()))
            .thenAnswer((_) async => false);
      },
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        selectedRiderId: 'r1',
      ),
      act: (bloc) => bloc.add(const SubmitAssignDeliveryEvent()),
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          isSubmitting: true,
        ),
        const AssignDeliveryError(message: 'Failed to assign rider.'),
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          isSubmitting: false,
        ),
      ],
    );

    blocTest<AssignDeliveryBloc, AssignDeliveryState>(
      'passes instructions to repository',
      setUp: () {
        when(() => repository.assignRider('order_1', 'r1', 'Call first'))
            .thenAnswer((_) async => true);
      },
      build: buildBloc,
      seed: () => AssignDeliveryLoaded(
        riders: _testRiders(),
        selectedRiderId: 'r1',
        deliveryInstructions: 'Call first',
      ),
      act: (bloc) => bloc.add(const SubmitAssignDeliveryEvent()),
      verify: (_) {
        verify(() => repository.assignRider('order_1', 'r1', 'Call first'))
            .called(1);
      },
      expect: () => [
        AssignDeliveryLoaded(
          riders: _testRiders(),
          selectedRiderId: 'r1',
          deliveryInstructions: 'Call first',
          isSubmitting: true,
        ),
        AssignDeliverySuccess(),
      ],
    );
  });

  group('close', () {
    test('cancels stream subscription', () async {
      final controller = StreamController<List<RiderModel>>();
      when(() => repository.watchAvailableRiders('order_1'))
          .thenAnswer((_) => controller.stream);

      final bloc = buildBloc();
      bloc.add(const LoadRidersEvent(orderId: 'order_1'));
      await Future.delayed(Duration.zero);

      expect(controller.hasListener, isTrue);

      bloc.close();
      await Future.delayed(Duration.zero);

      expect(bloc.isClosed, isTrue);
    });
  });
}
