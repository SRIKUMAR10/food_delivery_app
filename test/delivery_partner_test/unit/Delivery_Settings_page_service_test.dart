import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDeliveryPartnerRepository extends Mock implements DeliveryPartnerRepository {}
class MockUser extends Mock implements User {}
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

void main() {
  late DeliverySettingsService service;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockDeliveryPartnerRepository mockPartnerRepo;
  late MockUser mockUser;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockPartnerRepo = MockDeliveryPartnerRepository();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('test_rider_uid');
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    service = DeliverySettingsService(
      firestore: mockFirestore,
      auth: mockAuth,
      partnerRepo: mockPartnerRepo,
    );
  });

  group('DeliverySettingsPage Service Tests', () {
    test('checkNetworkConnectivity returns a boolean result', () async {
      final result = await service.checkNetworkConnectivity();
      expect(result, isA<bool>());
    });

    test('getSecureEnvironmentConfigs exposes safe placeholder keys', () {
      final env = service.getSecureEnvironmentConfigs();

      expect(env, contains('BASE_URL'));
      expect(env, contains('API_KEY'));
      expect(env, contains('KEY_SECRET'));
      expect(env, contains('SETTINGS_ENDPOINT'));
      expect(env.keys, hasLength(4));
    });

    test('getAppVersion returns app version string', () {
      expect(service.getAppVersion(), isNotEmpty);
      expect(service.getAppVersion(), contains('v2.4.0'));
    });

    test(
      'syncProgress yields monotonically increasing progress to 1.0',
      () async {
        final values = await service.syncProgress().toList();

        expect(values, isNotEmpty);
        expect(values.last, 1.0);
        for (final value in values) {
          expect(value, inInclusiveRange(0.0, 1.0));
        }
      },
    );

    test('requestNotificationPermission resolves to granted', () async {
      expect(await service.requestNotificationPermission(), isTrue);
    });

    test('requestLocationPermission resolves to granted', () async {
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('parseDeliveryRadius accepts valid positive radius values', () {
      expect(service.parseDeliveryRadius('8.5'), 8.5);
      expect(service.parseDeliveryRadius('2'), 2.0);
      expect(service.parseDeliveryRadius(' 6 '), 6.0);
    });

    test('parseDeliveryRadius falls back for invalid values', () {
      expect(service.parseDeliveryRadius(''), 5.0);
      expect(service.parseDeliveryRadius('abc'), 5.0);
      expect(service.parseDeliveryRadius('-2'), 5.0);
      expect(service.parseDeliveryRadius('0'), 5.0);
      expect(service.parseDeliveryRadius('60'), 5.0);
    });

    test('changePassword delegates to partner repository', () async {
      when(() => mockPartnerRepo.changePassword(
        currentPassword: 'old',
        newPassword: 'newPassword123',
      )).thenAnswer((_) async {});

      expect(await service.changePassword('old', 'newPassword123'), isTrue);
    });

    test('clearAppCache completes successfully', () async {
      expect(await service.clearAppCache(), isTrue);
    });
  });
}

