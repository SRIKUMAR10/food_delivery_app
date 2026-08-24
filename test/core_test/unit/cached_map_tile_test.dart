import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/cached_map_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CachedMapTile Widget Tests', () {
    testWidgets('Renders properly with tileUrl', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedMapTile(
              tileUrl: 'https://tile.openstreetmap.org/15/1000/2000.png',
            ),
          ),
        ),
      );

      expect(find.byType(CachedMapTile), findsOneWidget);
    });

    testWidgets('Renders with dark mode enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedMapTile(
              tileUrl: 'https://tile.openstreetmap.org/15/1000/2000.png',
              isDarkMode: true,
              fallbackTileUrl: 'https://fallback.tile.org/15/1000/2000.png',
            ),
          ),
        ),
      );

      expect(find.byType(CachedMapTile), findsOneWidget);
    });
  });
}
