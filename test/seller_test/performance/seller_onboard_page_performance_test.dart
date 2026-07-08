import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SellerOnboardPage Performance Test', () {
    testWidgets('Scrolling and UI rendering performance', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SellerOnboardPageUI()));
      await tester.pumpAndSettle();

      await binding.traceAction(() async {
        // Since there is no actual scrollable list in the onboard page,
        // we test the transition/animation performance and frame rendering.
        final getStartedBtn = find.text('Get Started');
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();
      }, reportKey: 'seller_onboard_page_performance');
    });
  });
}
