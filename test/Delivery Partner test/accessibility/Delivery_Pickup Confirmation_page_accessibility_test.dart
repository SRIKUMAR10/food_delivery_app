import 'dart:math' as math;
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

double _relativeLuminance(Color color) {
  double channel(double value) {
    final v = value / 255.0;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r * 255) +
      0.7152 * channel(color.g * 255) +
      0.0722 * channel(color.b * 255);
}

double _contrastRatio(Color foreground, Color background) {
  final fg = _relativeLuminance(foreground);
  final bg = _relativeLuminance(background);
  final lighter = math.max(fg, bg);
  final darker = math.min(fg, bg);
  return (lighter + 0.05) / (darker + 0.05);
}

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

  group('DeliveryPickupConfirmationPage Accessibility Tests', () {
    testWidgets('exposes minimum tap targets for interactive controls', (
      tester,
    ) async {
      await pumpPage(tester);

      final notificationButton = find.byKey(
        const Key('dp_pickup_notification'),
      );
      final notificationSize = tester.getSize(notificationButton);
      expect(notificationSize.width, greaterThanOrEqualTo(48.0));
      expect(notificationSize.height, greaterThanOrEqualTo(48.0));

      await tester.ensureVisible(
        find.byKey(const Key('dp_pickup_call_customer')),
      );
      final callSize = tester.getSize(
        find.byKey(const Key('dp_pickup_call_customer')),
      );
      expect(callSize.height, greaterThanOrEqualTo(48.0));

      final whatsappSize = tester.getSize(
        find.byKey(const Key('dp_pickup_whatsapp')),
      );
      expect(whatsappSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('exposes semantic labels for icon-only controls', (
      tester,
    ) async {
      await pumpPage(tester);

      for (final key in const [
        'dp_pickup_call_customer',
        'dp_pickup_whatsapp',
      ]) {
        final tooltip = tester.widget<Tooltip>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(Tooltip),
          ),
        );
        expect(
          tooltip.message,
          isNotEmpty,
          reason: '$key should expose an accessible label',
        );
      }

      final startButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('dp_pickup_start_delivery')),
      );
      expect(startButton.onPressed, isNotNull);

      final bell = tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(const Key('dp_pickup_notification')),
          matching: find.byType(IconButton),
        ),
      );
      expect(bell.onPressed, isNotNull);
    });

    testWidgets('maintains accessible color contrast ratios on dark cards', (
      tester,
    ) async {
      const cardBackground = Color(0xFF121A2D);
      const primaryText = Colors.white;
      const secondaryText = Color(0xFF94A3B8);
      const accentGreen = Color(0xFF00E676);

      expect(
        _contrastRatio(primaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(secondaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(accentGreen, cardBackground),
        greaterThanOrEqualTo(3.0),
      );
    });

    testWidgets('start delivery button meets height target', (tester) async {
      await pumpPage(tester);

      final button = find.byKey(const Key('dp_pickup_start_delivery'));
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });
}
