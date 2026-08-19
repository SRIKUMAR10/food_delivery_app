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

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

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
  late MockPickupConfirmationService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();
  });

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();

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

  group('Delivery Pickup Confirmation Integration Flow', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/deliveryNavigationScreen') {
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: SizedBox()),
              );
            }
            return null;
          },
          home: DeliveryPickupConfirmationPage(
            orderId: '#ORD12345',
            repository: mockRepository,
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('loads pickup confirmation details end-to-end', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('#ORD12345'), findsWidgets);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
      expect(find.text('12:05 PM'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('progresses from confirmed state to delivery started', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      final startButton = find.byKey(const Key('dp_pickup_start_delivery'));
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pump();

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);
      expect(find.byKey(const Key('dp_pickup_start_delivery')), findsNothing);

      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispatches customer quick actions without crashing', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('dp_pickup_call_customer')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('dp_pickup_whatsapp')));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}