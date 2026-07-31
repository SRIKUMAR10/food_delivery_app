import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryCompletedBloc
    extends MockBloc<DeliveryCompletedEvent, DeliveryCompletedPageState>
    implements DeliveryCompletedBloc {}

const mockModel = DeliveryCompletedModel(
  orderId: '#ORD12345',
  walletBalance: 2450.00,
  partnerName: 'Ravi Kumar',
  partnerVehicleNo: 'TN 01 AB 1234',
  customerName: 'Arun Kumar',
  deliveryAddress: '12, Beach Road, Chennai - 600001',
  timeTaken: '32 min',
  distanceCovered: 5.6,
  paymentStatus: 'Paid Successfully',
  paymentMethod: 'UPI • Google Pay',
  customerRating: 5.0,
  deliveryEarnings: 120.00,
  completedAt: 'Today, 4:15 PM',
);

const loadedState = DeliveryCompletedPageState(
  status: DeliveryCompletedStatus.success,
  model: mockModel,
);

void main() {
  late MockDeliveryCompletedBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliveryCompletedBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
      ),
      home: Scaffold(
        body: DeliveryCompletedPage(orderId: '#ORD12345', bloc: mockBloc),
      ),
    );
  }

  group('DeliveryCompletedPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark layout on desktop', (tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_completed_header')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_hero_icon')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_rating_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_completed_summary_card')),
        findsOneWidget,
      );
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
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

      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_completed_summary_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_completed_actions_card')),
        findsOneWidget,
      );
    });

    testWidgets('renders stacked layout without sidebar on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_sidebar')), findsNothing);
      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_bottom_bar')), findsOneWidget);
    });

    testWidgets('matches dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final summaryCard = tester.widget<Container>(
        find.byKey(const Key('dp_completed_summary_card')),
      );
      final decoration = summaryCard.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF121A2D));

      final sidebar = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_completed_sidebar')),
              matching: find.byType(Container),
            )
            .first,
      );
      final sidebarDecoration = sidebar.decoration as BoxDecoration;
      expect(sidebarDecoration.color, const Color(0xFF0D1424));
    });

    testWidgets('hero reflects completed palette when order is completed', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(status: DeliveryCompletedStatus.completed),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Order Completed'), findsWidgets);
      expect(
        find.byKey(const Key('dp_completed_complete_button')),
        findsNothing,
      );
    });
  });
}
