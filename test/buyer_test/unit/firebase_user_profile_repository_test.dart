import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/repositories/firebase_user_profile_repository.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  group('FirebaseUserProfileRepository wallet contract', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseUserProfileRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = FirebaseUserProfileRepository(firestore: fakeFirestore);
    });

    test('loadWalletBalance returns null when no wallet field exists', () async {
      await fakeFirestore.collection('buyer_user').doc('u1').set({'name': 'A'});
      expect(await repository.loadWalletBalance('u1'), isNull);
    });

    test('loadWalletBalance returns the stored wallet balance', () async {
      await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .set({'wallet': 250.0});
      expect(await repository.loadWalletBalance('u1'), 250.0);
    });

    test('watchWalletBalance emits the current balance and live updates',
        () async {
      await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .set({'wallet': 100.0});

      final emissions = <double?>[];
      final sub = repository.watchWalletBalance('u1').listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .update({'wallet': 175.5});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await sub.cancel();
      expect(emissions.last, 175.5);
    });

    test('addWalletTransaction credits the balance and writes a transaction',
        () async {
      await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .set({'wallet': 500.0});

      await repository.addWalletTransaction(
        userId: 'u1',
        amount: 200.0,
        title: 'Wallet Top-up',
        isCredit: true,
        paymentId: 'pay_123',
      );

      final doc = await fakeFirestore.collection('buyer_user').doc('u1').get();
      expect(doc.data()?['wallet'], 700.0);

      final txns = await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .collection('transactions')
          .get();
      expect(txns.docs, hasLength(1));
      expect(txns.docs.first.data()['title'], 'Wallet Top-up');
      expect(txns.docs.first.data()['paymentId'], 'pay_123');
    });

    test('addWalletTransaction debits the balance', () async {
      await fakeFirestore
          .collection('buyer_user')
          .doc('u1')
          .set({'wallet': 500.0});

      await repository.addWalletTransaction(
        userId: 'u1',
        amount: 300.0,
        title: 'Wallet Payment',
        isCredit: false,
      );

      final doc = await fakeFirestore.collection('buyer_user').doc('u1').get();
      expect(doc.data()?['wallet'], 200.0);
    });
  });

  group('WalletDatabase adapter delegation', () {
    late MockAuthService mockAuthService;
    late MockUserProfileRepository mockRepository;
    late WalletDatabase database;

    setUp(() {
      mockAuthService = MockAuthService();
      mockRepository = MockUserProfileRepository();
      when(() => mockAuthService.currentUserId).thenReturn('u1');
      database = WalletDatabase(
        authService: mockAuthService,
        repository: mockRepository,
      );
    });

    test('getInitialBalance delegates to loadWalletBalance', () async {
      when(() => mockRepository.loadWalletBalance('u1'))
          .thenAnswer((_) async => 42.0);
      expect(await database.getInitialBalance(), 42.0);
      verify(() => mockRepository.loadWalletBalance('u1')).called(1);
    });

    test('getWalletBalanceStream delegates to watchWalletBalance', () {
      when(() => mockRepository.watchWalletBalance('u1'))
          .thenAnswer((_) => Stream.value(10.0));
      expect(database.getWalletBalanceStream(), emits(10.0));
      verify(() => mockRepository.watchWalletBalance('u1')).called(1);
    });

    test('getTransactionsStream delegates to watchTransactions', () {
      when(() => mockRepository.watchTransactions('u1'))
          .thenAnswer((_) => Stream.value(<Map<String, dynamic>>[]));
      expect(database.getTransactionsStream(), emits(<Map<String, dynamic>>[]));
      verify(() => mockRepository.watchTransactions('u1')).called(1);
    });

    test('addTransaction delegates to addWalletTransaction', () async {
      when(() => mockRepository.addWalletTransaction(
            userId: any(named: 'userId'),
            amount: any(named: 'amount'),
            title: any(named: 'title'),
            isCredit: any(named: 'isCredit'),
            paymentId: any(named: 'paymentId'),
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          )).thenAnswer((_) async {});

      await database.addTransaction(
        amount: 100.0,
        title: 'Wallet Top-up',
        isCredit: true,
        paymentId: 'pay_1',
      );

      verify(() => mockRepository.addWalletTransaction(
            userId: 'u1',
            amount: 100.0,
            title: 'Wallet Top-up',
            isCredit: true,
            paymentId: 'pay_1',
            orderId: null,
            status: 'success',
          )).called(1);
    });

    test('returns empty/null when no user is signed in', () async {
      when(() => mockAuthService.currentUserId).thenReturn(null);
      expectLater(database.getWalletBalanceStream(), emitsDone);
      expectLater(database.getTransactionsStream(), emitsDone);
      expect(await database.getInitialBalance(), isNull);
      await database.addTransaction(
        amount: 10,
        title: 't',
        isCredit: true,
      );
      verifyNever(() => mockRepository.addWalletTransaction(
            userId: any(named: 'userId'),
            amount: any(named: 'amount'),
            title: any(named: 'title'),
            isCredit: any(named: 'isCredit'),
            paymentId: any(named: 'paymentId'),
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ));
    });
  });
}