import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

import '../../font_loader_helper.dart';

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

void main() {
  late MockPickupConfirmationRepository mockRepository;
  late MockPickupConfirmationService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryPickupConfirmationPage(
          orderId: '#ORD12345',
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliveryPickupConfirmationPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when fetch fails', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchPickupConfirmationDetails(any()),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_pickup_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_pickup_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the pickup confirmation', (
      tester,
    ) async {
      setDesktopSize(tester);
      var calls = 0;
      when(
        () => mockRepository.fetchPickupConfirmationDetails(any()),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return const PickupConfirmationModel(
          orderId: '#ORD12345',
          pickupLocationName: 'Green Mart',
          pickupAddress: '24, Anna Salai, Chennai - 600002',
          pickupContactName: 'Priya Sharma',
          pickupContactPhone: '+919876543210',
          pickupInstructions: 'Show the order code at the counter.',
          customerName: 'Mike Johnson',
          customerAddress: '12, Beach Road, Chennai - 600001',
          customerPhone: '+919876543211',
          pickupTime: '12:05 PM',
          paymentType: 'Cash on Delivery',
          orderAmount: 486.50,
          walletBalance: 2450.00,
        );
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_pickup_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_pickup_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_pickup_error')), findsNothing);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);
    });

    testWidgets('shows snackbar and keeps content when start delivery fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchPickupConfirmationDetails(any()),
      ).thenAnswer(
        (_) async => const PickupConfirmationModel(
          orderId: '#ORD12345',
          pickupLocationName: 'Green Mart',
          pickupAddress: '24, Anna Salai, Chennai - 600002',
          pickupContactName: 'Priya Sharma',
          pickupContactPhone: '+919876543210',
          pickupInstructions: 'Show the order code at the counter.',
          customerName: 'Mike Johnson',
          customerAddress: '12, Beach Road, Chennai - 600001',
          customerPhone: '+919876543211',
          pickupTime: '12:05 PM',
          paymentType: 'Cash on Delivery',
          orderAmount: 486.50,
          walletBalance: 2450.00,
        ),
      );
      when(
        () => mockRepository.startDelivery(any()),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byKey(const Key('dp_pickup_start_delivery')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Network error'), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
    });
  });
}
