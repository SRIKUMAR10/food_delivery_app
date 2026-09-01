import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}
class MockReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

class FakeSetOptions extends Fake implements SetOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
    registerFallbackValue(FakeSetOptions());
  });

  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseStorage mockStorage;
  late MockUser mockUser;
  late DeliveryOnboardingVerificationRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockStorage = MockFirebaseStorage();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('partner_uid_123');
    when(() => mockUser.displayName).thenReturn('Rahul Kumar');
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.updatePhotoURL(any())).thenAnswer((_) async {});

    repository = DeliveryOnboardingVerificationRepository(
      firestore: mockFirestore,
      auth: mockAuth,
      storage: mockStorage,
    );
  });

  group('DeliveryOnboardingVerificationRepository Unit Tests', () {
    test('currentUserId returns logged-in uid', () {
      expect(repository.currentUserId, 'partner_uid_123');
    });

    test('fetchPartnerProfile returns profile map on success', () async {
      final mockCol = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnap = MockDocumentSnapshot();

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCol);
      when(() => mockCol.doc('partner_uid_123')).thenReturn(mockDoc);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);
      when(() => mockSnap.exists).thenReturn(true);
      when(() => mockSnap.data()).thenReturn({
        'name': 'Rahul Kumar',
        'phone': '9876543210',
        'city': 'Chennai',
      });

      final result = await repository.fetchPartnerProfile('partner_uid_123');
      expect(result, isNotNull);
      expect(result!['name'], 'Rahul Kumar');
      expect(result['city'], 'Chennai');
    });

    test('submitFullKycApplication executes batch commit atomically', () async {
      final mockBatch = MockWriteBatch();
      final mockCol = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockFirestore.collection(any())).thenReturn(mockCol);
      when(() => mockCol.doc(any())).thenReturn(mockDoc);
      when(() => mockDoc.collection(any())).thenReturn(mockCol);
      when(() => mockBatch.set(
            any(),
            any(),
            any(),
          )).thenReturn(null);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      final payload = {
        'fullName': 'Rahul Kumar',
        'displayName': 'Rahul K',
        'dob': '15/08/1996',
        'gender': 'Male',
        'bloodGroup': 'O+',
        'emergencyContactName': 'Suresh',
        'emergencyContactPhone': '9876543210',
        'avatarUrl': null,
        'bio': '',
        'email': 'rahul@example.com',
        'phone': '9876543210',
        'isPhoneVerified': true,
        'city': 'Chennai',
        'operatingZone': 'Central Zone',
        'preferredShift': 'Flexible',
        'workType': 'Full-Time',
        'deliveryRadiusKm': 10.0,
        'formattedAddress': 'Chennai Central',
        'houseFlatNo': '12',
        'landmark': '',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'welcomeBonusCode': 'RIDER500',
        'vehicleType': 'Motorcycle',
        'vehicleNumber': 'TN01AB1234',
        'vehicleModel': 'Activa',
        'drivingLicenseNumber': 'TN0120201234567',
        'dlExpiryDate': '31/12/2030',
        'dlFrontUrl': null,
        'dlBackUrl': null,
        'rcBookUrl': null,
        'aadhaarNumber': '123456789012',
        'panNumber': 'ABCDE1234F',
        'aadhaarFrontUrl': null,
        'aadhaarBackUrl': null,
        'panCardUrl': null,
        'bankAccountNumber': '123456789',
        'ifscCode': 'SBIN0001234',
        'bankName': 'SBI',
        'accountHolderName': 'Rahul Kumar',
        'upiId': 'rahul@okaxis',
        'payoutFrequency': 'Daily',
      };

      await repository.submitFullKycApplication('partner_uid_123', payload);
      verify(() => mockBatch.commit()).called(1);
    });

    test('saveDraftState persists draft data to Firestore with merge', () async {
      final mockCol = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCol);
      when(() => mockCol.doc('partner_uid_123')).thenReturn(mockDoc);
      when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});

      await repository.saveDraftState('partner_uid_123', {
        'name': 'arun',
        'currentStepIndex': 1,
      });

      verify(() => mockDoc.set(any(), any())).called(1);
    });

    test('waitForCurrentUser returns currentUser if already available', () async {
      final user = await repository.waitForCurrentUser();
      expect(user, isNotNull);
      expect(user?.uid, 'partner_uid_123');
    });

    test('watchPartnerProfile emits map when snapshot changes', () async {
      final mockCol = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnap = MockDocumentSnapshot();

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCol);
      when(() => mockCol.doc('partner_uid_123')).thenReturn(mockDoc);
      when(() => mockDoc.snapshots())
          .thenAnswer((_) => Stream.value(mockSnap));
      when(() => mockSnap.exists).thenReturn(true);
      when(() => mockSnap.data()).thenReturn({
        'name': 'Rahul Kumar',
        'city': 'Chennai',
      });

      final stream = repository.watchPartnerProfile('partner_uid_123');
      final result = await stream.first;

      expect(result['name'], 'Rahul Kumar');
      expect(result['city'], 'Chennai');
    });
  });
}
