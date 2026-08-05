import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_repository.dart';

class MockDeliveryPartnerRepository extends Mock
    implements DeliveryPartnerRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockDeliveryPartnerRepository mockPartnerRepo;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockSnapshot;
  late DeliveryForgotPasswordRepository repository;

  setUp(() {
    mockPartnerRepo = MockDeliveryPartnerRepository();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockSnapshot = MockQuerySnapshot();

    repository = DeliveryForgotPasswordRepository(
      partnerRepo: mockPartnerRepo,
      auth: mockAuth,
      firestore: mockFirestore,
    );

    registerFallbackValue(FirebaseAuthException(code: 'dummy'));
  });

  group('DeliveryForgotPasswordRepository sendOtp Tests', () {
    const phone = '9876543210';
    const fullPhone = '+919876543210';

    test('proceeds to sendOtp if partner exists via getDeliveryPartnerByPhone',
        () async {
      final mockPartner = DeliveryPartnerModel(
        id: 'uid123',
        phoneNumber: fullPhone,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .thenAnswer((_) async => mockPartner);

      when(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((_) async {});

      bool codeSentCalled = false;
      await repository.sendOtp(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
          codeSentCalled = true;
        },
        onVerificationFailed: (e) {},
      );

      verify(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .called(1);
      verify(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: fullPhone,
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).called(1);
      expect(codeSentCalled, false); // triggers only on callback from partnerRepo
    });

    test('proceeds to sendOtp if partner exists via firestore check fallback',
        () async {
      final mockPartner = DeliveryPartnerModel(
        id: 'uid123',
        phoneNumber: fullPhone,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      // first call returns null
      when(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .thenAnswer((invocation) async {
        return null;
      });

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('phoneNumber', isEqualTo: fullPhone))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([MockQueryDocumentSnapshot()]);

      // mock the second call
      when(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .thenAnswer((_) async => mockPartner);

      when(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((_) async {});

      await repository.sendOtp(
        phoneNumber: phone,
        onCodeSent: (v, r) {},
        onVerificationFailed: (e) {},
      );

      verify(() => mockFirestore.collection('delivery_partners')).called(1);
      verify(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: fullPhone,
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).called(1);
    });

    test('fails with user-not-found if partner is not registered anywhere',
        () async {
      when(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .thenAnswer((_) async => null);

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('phoneNumber', isEqualTo: fullPhone))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      bool verificationFailedCalled = false;
      FirebaseAuthException? failureException;

      await repository.sendOtp(
        phoneNumber: phone,
        onCodeSent: (v, r) {},
        onVerificationFailed: (e) {
          verificationFailedCalled = true;
          failureException = e;
        },
      );

      expect(verificationFailedCalled, true);
      expect(failureException?.code, 'user-not-found');
      verifyNever(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      );
    });

    test(
        'proceeds to sendOtp if query fails with permission-denied (anonymous bypass)',
        () async {
      when(() => mockPartnerRepo.getDeliveryPartnerByPhone(fullPhone))
          .thenAnswer((_) async => null);

      when(() => mockFirestore.collection('delivery_partners'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('phoneNumber', isEqualTo: fullPhone))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );

      when(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((_) async {});

      bool verificationFailedCalled = false;

      await repository.sendOtp(
        phoneNumber: phone,
        onCodeSent: (v, r) {},
        onVerificationFailed: (e) {
          verificationFailedCalled = true;
        },
      );

      expect(verificationFailedCalled, false);
      verify(
        () => mockPartnerRepo.sendPhoneOtp(
          phoneNumber: fullPhone,
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).called(1);
    });
  });
}
