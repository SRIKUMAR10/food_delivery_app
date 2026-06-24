import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser(this.uid);
}

void main() {
  group('Cart Page Performance Test', () {
    testWidgets('Measures scrolling performance on Cart Page', (
      WidgetTester tester,
    ) async {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser('test_uid');

      for (int i = 0; i < 20; i++) {
        await fakeFirestore
            .collection('users')
            .doc('test_uid')
            .collection('cart')
            .doc('item$i')
            .set({
              'id': 'item$i',
              'name': 'Food Item $i',
              'price': 10.0 + i,
              'quantity': 1,
              'sellerId': 'seller$i',
              'isSelected': true,
            });
      }

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) =>
                CartBloc(firestore: fakeFirestore, auth: mockAuth)
                  ..add(const LoadCartStarted()),
            child: const CartPageUI(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listFinder = find.byType(ListView);

      if (listFinder.evaluate().isNotEmpty) {
        final stopwatch = Stopwatch()..start();
        await tester.fling(listFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      }
    });
  });
}
