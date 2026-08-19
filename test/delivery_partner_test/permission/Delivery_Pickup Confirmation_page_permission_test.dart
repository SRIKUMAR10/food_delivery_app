import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

import '../../font_loader_helper.dart';

class MockPickupConfirmationBloc
    extends
        MockBloc<
          DeliveryPickupConfirmationPageEvent,
          DeliveryPickupConfirmationPageState
        >
    implements DeliveryPickupConfirmationPageBloc {}

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

const loadedState = DeliveryPickupConfirmationPageState(
  status: PickupConfirmationStatus.success,
  model: mockModel,
);

void main() {
  late MockPickupConfirmationBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockPickupConfirmationBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryPickupConfirmationPage Permission Tests', () {
    test('service requests phone and location permissions safely', () async {
      final service = DeliveryPickupConfirmationService();

      expect(await service.requestPhonePermission(), isTrue);
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('service validates phone numbers before launching actions', () {
      final service = DeliveryPickupConfirmationService();

      expect(service.isValidPhoneNumber('+919876543210'), isTrue);
      expect(service.isValidPhoneNumber('invalid'), isFalse);
    });

    testWidgets('renders contact quick actions when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryPickupConfirmationPage(
              orderId: '#ORD12345',
              bloc: mockBloc,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('dp_pickup_call_customer')),
      );
      expect(find.byKey(const Key('dp_pickup_call_customer')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_whatsapp')), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });

    testWidgets('call customer button dispatches CallCustomerEvent', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryPickupConfirmationPage(
              orderId: '#ORD12345',
              bloc: mockBloc,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('dp_pickup_call_customer')),
      );
      await tester.tap(find.byKey(const Key('dp_pickup_call_customer')));
      await tester.pump();

      verify(
        () => mockBloc.add(const CallCustomerEvent('+919876543211')),
      ).called(1);
    });

    testWidgets('whatsapp button dispatches OpenWhatsAppEvent', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryPickupConfirmationPage(
              orderId: '#ORD12345',
              bloc: mockBloc,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('dp_pickup_whatsapp')));
      await tester.tap(find.byKey(const Key('dp_pickup_whatsapp')));
      await tester.pump();

      verify(
        () => mockBloc.add(const OpenWhatsAppEvent('+919876543211')),
      ).called(1);
    });
  });
}
