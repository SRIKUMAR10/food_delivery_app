import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI shows loading and then content', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerProfilePageUI(),
      ),
    );

    // Verify initial loading state (Skeleton loader is present).
    expect(find.byType(ProfileSkeletonLoader), findsOneWidget);

    // Wait for the mock network request in the Bloc to finish
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify loading indicator is gone and data is shown.
    expect(find.byType(ProfileSkeletonLoader), findsNothing);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Picarhub Restaurant'), findsOneWidget);
    expect(find.text('seller@picarhub.com'), findsOneWidget);
    expect(find.text('Business Details'), findsOneWidget);
  });
}
