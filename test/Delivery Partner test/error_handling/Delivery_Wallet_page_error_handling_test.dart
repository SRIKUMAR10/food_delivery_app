import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

class FailingWalletService extends Mock
    implements DeliveryWalletPageServiceBase {}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows an error shell when wallet loading fails', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final service = FailingWalletService();
    when(() => service.fetchWalletData()).thenThrow(Exception('timeout'));
    final repository = DeliveryWalletPageRepository(service: service);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DeliveryWalletPage(repository: repository)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('dp_wallet_error')), findsOneWidget);
    expect(find.byKey(const Key('dp_wallet_retry')), findsOneWidget);
  });

  test(
    'repository returns null for malformed cache instead of throwing',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dp_wallet_cache_v1', '{bad json');
      final state = await DeliveryWalletPageRepository(
        prefs: prefs,
      ).loadCachedWallet();
      expect(state, isNull);
    },
  );
}
