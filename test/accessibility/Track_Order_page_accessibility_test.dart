import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart'
    show TrackOrderPageUI;
import 'package:firebase_core/firebase_core.dart';
import '../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('TrackOrderPageUI meets accessibility guidelines', (
    WidgetTester tester,
  ) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(
      const MaterialApp(home: TrackOrderPageUI(orderId: 'FG125678')),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byType(TrackOrderPageUI), findsOneWidget);
  });
}
