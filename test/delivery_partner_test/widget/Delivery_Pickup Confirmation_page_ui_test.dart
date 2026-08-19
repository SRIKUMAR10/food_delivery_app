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

  group('DeliveryPickupConfirmationPageUi Widget Tests', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      Size? size,
      String orderId = '#ORD12345',
    }) async {
      if (size != null) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
      }
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
            orderId: orderId,
            repository: mockRepository,
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('renders header, hero, pickup info and customer cards', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_pickup_header')), findsOneWidget);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('#ORD12345'), findsWidgets);

      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);

      expect(find.byKey(const Key('dp_pickup_info_card')), findsOneWidget);
      expect(find.text('Pickup Information'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);

      expect(find.byKey(const Key('dp_pickup_customer_card')), findsOneWidget);
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
      expect(find.text('12, Beach Road, Chennai - 600001'), findsOneWidget);
    });

    testWidgets('renders sidebar navigation and promo banner on desktop', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_pickup_sidebar')), findsOneWidget);
      for (final label in [
        'Dashboard',
        'Orders',
        'Earnings',
        'Incentives',
        'History',
        'Wallet',
        'Profile',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('Deliver More Earn More'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_promo_banner')), findsOneWidget);
    });

    testWidgets('hides sidebar on mobile viewport', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(390, 844));

      expect(find.byKey(const Key('dp_pickup_sidebar')), findsNothing);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_bottom_bar')), findsOneWidget);
    });

    testWidgets('starts delivery and shows delivery started state', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      final startButton = find.byKey(const Key('dp_pickup_start_delivery'));
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pump();

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);

      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders skeleton while initial data is loading', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryPickupConfirmationPage(orderId: '#ORD12345'),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_skeleton')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}