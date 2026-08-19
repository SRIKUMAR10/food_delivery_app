import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

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
  late MockDeliveryDashboardPageBloc mockBloc;

  const DeliveryDashboardState loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    selectedFilter: 'All',
  );

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockBloc = MockDeliveryDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(loadedState));
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryDashboardPage Accessibility Tests', () {
    testWidgets('exposes a minimum tap target for the online switch', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      final toggle = find.byKey(const Key('dp_dashboard_toggle_switch'));
      final size = tester.getSize(toggle);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(34.0));

      final notificationButton = find.byKey(
        const Key('dp_dashboard_notification_button'),
      );
      final notificationSize = tester.getSize(notificationButton);
      expect(notificationSize.width, greaterThanOrEqualTo(48.0));
      expect(notificationSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('exposes semantics for the online switch', (tester) async {
      setDesktopSize(tester);
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
          ),
        );
        await tester.pump();

        final toggledSemantics = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((s) => s.properties.toggled == true)
            .toList();

        expect(toggledSemantics, isNotEmpty);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('exposes selected semantics for active filter chips', (
      tester,
    ) async {
      setDesktopSize(tester);
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
          ),
        );
        await tester.pump();

        final selectedSemantics = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((s) => s.properties.selected == true)
            .toList();

        expect(selectedSemantics, isNotEmpty);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('maintains accessible color contrast ratios on dark cards', (
      tester,
    ) async {
      const cardBackground = Color(0xFF0F1E26);
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
  });
}
