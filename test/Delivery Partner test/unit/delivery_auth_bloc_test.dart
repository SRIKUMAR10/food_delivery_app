import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/delivery_auth_bloc.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

class MockDeliveryPartnerRepository extends Mock implements DeliveryPartnerRepository {}

void main() {
  late MockDeliveryPartnerRepository mockRepo;

  setUp(() {
    mockRepo = MockDeliveryPartnerRepository();
    when(() => mockRepo.currentUser).thenReturn(null);
  });

  group('DeliveryAuthBloc Tests', () {
    test('initial state is unauthenticated / initial', () {
      final bloc = DeliveryAuthBloc(repository: mockRepo);
      expect(bloc.state.status, DeliveryAuthStatus.initial);
      expect(bloc.state.partner, isNull);
      bloc.close();
    });

    blocTest<DeliveryAuthBloc, DeliveryAuthState>(
      'DeliveryAuthCheckSessionRequested emits unauthenticated when no user is logged in',
      build: () => DeliveryAuthBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const DeliveryAuthCheckSessionRequested()),
      expect: () => [
        isA<DeliveryAuthState>()
            .having((s) => s.status, 'status', DeliveryAuthStatus.authenticating),
        isA<DeliveryAuthState>()
            .having((s) => s.status, 'status', DeliveryAuthStatus.unauthenticated),
      ],
    );

    blocTest<DeliveryAuthBloc, DeliveryAuthState>(
      'DeliveryAuthSignOutRequested signs out and emits unauthenticated',
      build: () {
        when(() => mockRepo.signOut()).thenAnswer((_) async {});
        return DeliveryAuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const DeliveryAuthSignOutRequested()),
      expect: () => [
        isA<DeliveryAuthState>()
            .having((s) => s.status, 'status', DeliveryAuthStatus.authenticating),
        isA<DeliveryAuthState>()
            .having((s) => s.status, 'status', DeliveryAuthStatus.unauthenticated)
            .having((s) => s.partner, 'partner', isNull),
      ],
    );
  });
}
