import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser(this.uid);
}

void main() {
  group('Order Page Performance Test', () {
    testWidgets('Measures scrolling performance on Order Page', (
      WidgetTester tester,
    ) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser('test_uid');

      for (int i = 0; i < 20; i++) {
        await fakeFirestore
            .collection('users')
            .doc('test_uid')
            .collection('orders')
            .doc('order$i')
            .set({
              'status': 'Pending',
              'totalAmount': 500.0,
              'date': DateTime.now(),
              'items': [],
            });
      }

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      final mockRepo = OrderRepository(
        firestore: fakeFirestore,
        auth: mockAuth,
      );

      await tester.pumpWidget(
        MaterialApp(home: OrderPageUI(orderRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      final listFinder = find.byType(ListView);

      if (listFinder.evaluate().isNotEmpty) {
        // Record performance trace
        final stopwatch = Stopwatch()..start();
        // Scroll down the list
        await tester.fling(listFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      }
    });
  });
}
