import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveLayout & Helper Tests', () {
    testWidgets('renders mobileBody on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobileBody: (context) => const Text('Mobile Screen'),
            desktopBody: (context) => const Text('Desktop Screen'),
          ),
        ),
      );

      expect(find.text('Mobile Screen'), findsOneWidget);
      expect(find.text('Desktop Screen'), findsNothing);
    });

    testWidgets('renders desktopBody on wide desktop viewport', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobileBody: (context) => const Text('Mobile Screen'),
            desktopBody: (context) => const Text('Desktop Screen'),
          ),
        ),
      );

      expect(find.text('Desktop Screen'), findsOneWidget);
      expect(find.text('Mobile Screen'), findsNothing);
    });

    testWidgets('ResponsiveValue resolves correct values', (tester) async {
      const respVal = ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3);

      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late int resolvedVal;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolvedVal = respVal.resolve(context);
              return Text('Value: $resolvedVal');
            },
          ),
        ),
      );

      expect(resolvedVal, 3);
    });
  });
}
