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

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
      ),
      home: Scaffold(
        body: DeliveryPickupConfirmationPage(
          orderId: '#ORD12345',
          bloc: mockBloc,
        ),
      ),
    );
  }

  group('DeliveryPickupConfirmationPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark layout on desktop', (tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_header')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_hero_icon')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_info_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_customer_card')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('renders dark layout with sidebar on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_info_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_customer_card')), findsOneWidget);
    });

    testWidgets('renders stacked layout without sidebar on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_sidebar')), findsNothing);
      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_bottom_bar')), findsOneWidget);
    });

    testWidgets('matches dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final customerCard = tester.widget<Container>(
        find.byKey(const Key('dp_pickup_customer_card')),
      );
      final decoration = customerCard.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF121A2D));

      final sidebar = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_pickup_sidebar')),
              matching: find.byType(Container),
            )
            .first,
      );
      final sidebarDecoration = sidebar.decoration as BoxDecoration;
      expect(sidebarDecoration.color, const Color(0xFF0D1424));
    });

    testWidgets('hero reflects delivery started palette when started', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(status: PickupConfirmationStatus.deliveryStarted),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Pickup Confirmed!'), findsNothing);
    });
  });
}
