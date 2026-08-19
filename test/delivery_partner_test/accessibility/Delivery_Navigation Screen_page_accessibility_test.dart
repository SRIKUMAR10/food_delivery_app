import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBloc
    extends MockBloc<DeliveryNavigationEvent, DeliveryNavigationState>
    implements DeliveryNavigationBloc {}

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
  late MockDeliveryNavigationBloc mockBloc;

  const DeliveryNavigationState loadedState = DeliveryNavigationState(
    status: DeliveryNavigationStatus.loaded,
    hasLocationPermission: true,
    audioEnabled: true,
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
    mockBloc = MockDeliveryNavigationBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryNavigationScreenPage Accessibility Tests', () {
    testWidgets('meets minimum 48x48 tap target sizes for action controls', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationScreenPage(bloc: mockBloc)),
      );
      await tester.pump();

      final sosButton = find.byKey(const Key('dp_navscreen_sos_button'));
      expect(tester.getSize(sosButton).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(sosButton).width, greaterThanOrEqualTo(48.0));

      final startButton = find.byKey(const Key('dp_navscreen_start_button'));
      expect(tester.getSize(startButton).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(startButton).width, greaterThanOrEqualTo(48.0));

      final exitButton = find.byKey(const Key('dp_navscreen_exit_button'));
      expect(tester.getSize(exitButton).height, greaterThanOrEqualTo(48.0));

      final contactButton = find.byKey(
        const Key('dp_navscreen_contact_button'),
      );
      expect(tester.getSize(contactButton).height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('provides semantics labels for navigation controls', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationScreenPage(bloc: mockBloc)),
      );
      await tester.pump();

      final semanticsLabels = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .map((s) => s.properties.label)
          .whereType<String>()
          .toSet();

      expect(semanticsLabels, contains('Start Navigation'));
      expect(semanticsLabels, contains('Emergency SOS'));
      expect(semanticsLabels, contains('Exit Navigation'));
      expect(semanticsLabels, contains('Zoom in'));
      expect(semanticsLabels, contains('Zoom out'));
      expect(semanticsLabels, contains('Recenter map'));
      expect(semanticsLabels, contains('Pickup'));
      expect(semanticsLabels, contains('Drop'));
      expect(semanticsLabels, contains('Current location'));
      expect(semanticsLabels, contains('Live navigation map'));
    });

    testWidgets('maintains accessible color contrast ratios', (tester) async {
      const primaryButtonText = Color(0xFF06120B);
      const primaryButtonBg = Color(0xFF00C853);
      const sosText = Colors.white;
      const sosBg = Color(0xFFB3261E);

      final primaryRatio = _contrastRatio(primaryButtonText, primaryButtonBg);
      final sosRatio = _contrastRatio(sosText, sosBg);

      expect(primaryRatio, greaterThanOrEqualTo(4.5));
      expect(sosRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
