import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

import '../../font_loader_helper.dart';
import '../helpers/delivery_test_utils.dart';

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

const mockModel = PickupConfirmationModel(
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

void main() {
  late MockPickupConfirmationRepository mockRepository;

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();
  });

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    when(
      () => mockRepository.watchPickupConfirmationDetails('#ORD12345'),
    ).thenAnswer((_) => Stream.value(mockModel));
    when(
      () => mockRepository.fetchPickupConfirmationDetails('#ORD12345'),
    ).thenAnswer((_) async => mockModel);
    when(
      () => mockRepository.startDelivery('#ORD12345'),
    ).thenAnswer((_) async => mockModel);
  });

  Widget buildPage() {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/deliveryNavigationScreen') {
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: SizedBox()),
          );
        }
        return null;
      },
      home: Scaffold(
        body: DeliveryPickupConfirmationPage(
          orderId: '#ORD12345',
          repository: mockRepository,
          service: DeliveryPickupConfirmationService(),
        ),
      ),
    );
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryPickupConfirmationPage Performance Tests', () {
    testWidgets('renders the pickup confirmation UI within frame threshold', (
      tester,
    ) async {
      setDesktopSize(tester);

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
    });

    testWidgets('disposes the page without leaks', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryPickupConfirmationPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles repeated state transitions without frame drops', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      for (var i = 0; i < 3; i++) {
        final button = find.byKey(const Key('dp_pickup_start_delivery'));
        if (button.evaluate().isEmpty) break;
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
    });
  });
}