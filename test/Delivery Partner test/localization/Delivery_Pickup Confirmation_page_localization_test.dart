import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
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

const enState = DeliveryPickupConfirmationPageState(
  status: PickupConfirmationStatus.success,
  model: mockModel,
);

const taState = DeliveryPickupConfirmationPageState(
  status: PickupConfirmationStatus.success,
  model: mockModel,
  localeCode: 'ta',
);

void main() {
  late MockPickupConfirmationBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockPickupConfirmationBloc();
    when(() => mockBloc.state).thenReturn(enState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpPage(WidgetTester tester) async {
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
  }

  group('DeliveryPickupConfirmationPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      await pumpPage(tester);

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('Start Delivery'), findsWidgets);
      expect(find.text('Pickup Information'), findsOneWidget);
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Safe Delivery'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      when(() => mockBloc.state).thenReturn(taState);
      await pumpPage(tester);

      expect(find.text('டெலிவரி பார்ட்னர்'), findsOneWidget);
      expect(find.text('எடுப்பு உறுதி செய்யப்பட்டது!'), findsOneWidget);
      expect(find.text('டெலிவரியைத் தொடங்கு'), findsWidgets);
      expect(find.text('எடுப்பு தகவல்'), findsOneWidget);
      expect(find.text('வாடிக்கையாளர் விவரங்கள்'), findsOneWidget);
      expect(find.text('பாதுகாப்பான டெலிவரி'), findsOneWidget);
    });

    testWidgets('keeps data values from the model regardless of locale', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(taState);
      await pumpPage(tester);

      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
      expect(find.text('#ORD12345'), findsWidgets);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(
        DeliveryPickupConfirmationStrings.of('pickupConfirmed', 'fr'),
        'Pickup Confirmed!',
      );
      expect(
        DeliveryPickupConfirmationStrings.of('safeDelivery', 'hi'),
        'Safe Delivery',
      );
    });
  });
}
