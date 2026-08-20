import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

Future<void> waitFor(bool Function() condition,
    {Duration timeout = const Duration(seconds: 3)}) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late SellerSettingRepositoryImpl repository;

  const String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(sellerId);
    repository = SellerSettingRepositoryImpl(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  group('SellerSettingRepositoryImpl (Firestore)', () {
    test('saveSettings writes to sellers and seller_notification_settings', () async {
      const state = SellerSettingState(
        restaurantName: 'New Palace',
        pushNotifications: false,
        newOrderSound: true,
        soundLoopUntilAccepted: false,
        orderAlertRingtone: 'Digital Siren',
        soundVolume: 0.9,
        promoAndOffers: true,
        lowStockAlerts: true,
        orderUpdates: true,
      );

      await repository.saveSettings(state);

      final sellerSnap = await fakeFirestore.collection('sellers').doc(sellerId).get();
      expect(sellerSnap.exists, isTrue);
      expect(sellerSnap.data()!['shopName'], 'New Palace');

      final notifSnap = await fakeFirestore
          .collection('seller_notification_settings')
          .doc(sellerId)
          .get();
      expect(notifSnap.exists, isTrue);
      expect(notifSnap.data()!['orderAlertRingtone'], 'Digital Siren');
      expect(notifSnap.data()!['soundVolume'], 0.9);
      expect(notifSnap.data()!['promoAndOffers'], isTrue);
    });

    test('loadSettings merges seller profile and notification settings', () async {
      await fakeFirestore.collection('sellers').doc(sellerId).set({
        'shopName': 'Royal Kitchen',
        'ownerName': 'Chef Rao',
        'pushNotifications': true,
        'orderAlertRingtone': 'Bell Chime',
      });
      await fakeFirestore
          .collection('seller_notification_settings')
          .doc(sellerId)
          .set({
        'pushNotifications': false,
        'orderAlertRingtone': 'Classic Phone Ring',
        'soundVolume': 0.5,
        'newOrderSound': false,
      });

      final state = await repository.loadSettings();

      expect(state.restaurantName, 'Royal Kitchen');
      expect(state.ownerName, 'Chef Rao');
      expect(state.pushNotifications, isFalse);
      expect(state.orderAlertRingtone, 'Classic Phone Ring');
      expect(state.soundVolume, 0.5);
      expect(state.newOrderSound, isFalse);
    });

    test('loadSettings falls back to defaults when no documents exist', () async {
      final state = await repository.loadSettings();
      expect(state.restaurantName, '');
      expect(state.orderAlertRingtone, 'Bell Chime');
      expect(state.soundVolume, 0.8);
    });

    test('watchSettings streams combined real-time updates from both docs', () async {
      await fakeFirestore.collection('sellers').doc(sellerId).set({
        'shopName': 'Live Kitchen',
        'pushNotifications': true,
      });
      await fakeFirestore
          .collection('seller_notification_settings')
          .doc(sellerId)
          .set({
        'orderAlertRingtone': 'Bell Chime',
        'soundVolume': 0.8,
      });

      final states = <SellerSettingState>[];
      final subscription = repository.watchSettings().listen(states.add);

      await waitFor(() => states.isNotEmpty);
      await fakeFirestore
          .collection('seller_notification_settings')
          .doc(sellerId)
          .set({
        'orderAlertRingtone': 'Kitchen Buzzer',
        'soundVolume': 0.5,
      }, SetOptions(merge: true));

      await waitFor(() => states.any((s) => s.orderAlertRingtone == 'Kitchen Buzzer'));
      await subscription.cancel();

      expect(states.first.restaurantName, 'Live Kitchen');
      expect(states.first.pushNotifications, isTrue);
      expect(states.any((s) => s.soundVolume == 0.5), isTrue);
    });

    test('saveSettings throws when the seller is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.saveSettings(const SellerSettingState(restaurantName: 'Ghost')),
        throwsException,
      );
    });

    test('loadSettings returns default state when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final state = await repository.loadSettings();
      expect(state, const SellerSettingState());
    });

    test('watchSettings emits default state when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final state = await repository.watchSettings().first;
      expect(state, const SellerSettingState());
    });
  });
}