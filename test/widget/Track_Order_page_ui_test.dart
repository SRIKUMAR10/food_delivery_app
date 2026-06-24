import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';

void main() {
  testWidgets(
    'TrackOrderPageUI renders correctly and displays Skeleton when loading',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TrackOrderPageUI(orderId: 'FG125678')),
      );

      // Initial state is loading so we expect skeleton loaders or loading indicator
      expect(find.byType(ListView), findsWidgets);
    },
  );
}
