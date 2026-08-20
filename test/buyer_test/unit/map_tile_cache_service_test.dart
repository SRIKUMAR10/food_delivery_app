import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/map_tile_cache_service.dart';

void main() {
  group('MapTileCacheService Unit Tests', () {
    late MapTileCacheService cacheService;

    setUp(() {
      cacheService = MapTileCacheService.instance;
      cacheService.clearCache();
    });

    tearDown(() {
      cacheService.clearCache();
    });

    test('Initial cache is empty', () {
      expect(cacheService.cachedTileCount, equals(0));
      expect(cacheService.isCached('https://tile.test/1/1/1.png'), isFalse);
      expect(cacheService.getCachedTile('https://tile.test/1/1/1.png'), isNull);
    });

    test('cacheTile stores and retrieves Uint8List bytes correctly', () {
      const url = 'https://tile.test/14/1234/5678.png';
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      cacheService.cacheTile(url, dummyBytes);

      expect(cacheService.isCached(url), isTrue);
      expect(cacheService.cachedTileCount, equals(1));
      expect(cacheService.getCachedTile(url), equals(dummyBytes));
    });

    test('LRU eviction works when maximum capacity is reached', () {
      // Add 250 items to fill up to max capacity
      for (int i = 0; i < 250; i++) {
        cacheService.cacheTile('https://tile.test/$i.png', Uint8List.fromList([i]));
      }
      expect(cacheService.cachedTileCount, equals(250));
      expect(cacheService.isCached('https://tile.test/0.png'), isTrue);

      // Add 1 more item - should evict index 0 (oldest)
      cacheService.cacheTile('https://tile.test/250.png', Uint8List.fromList([250]));
      expect(cacheService.cachedTileCount, equals(250));
      expect(cacheService.isCached('https://tile.test/0.png'), isFalse);
      expect(cacheService.isCached('https://tile.test/250.png'), isTrue);
    });

    test('clearCache resets cache completely', () {
      cacheService.cacheTile('https://tile.test/a.png', Uint8List.fromList([1]));
      cacheService.cacheTile('https://tile.test/b.png', Uint8List.fromList([2]));
      expect(cacheService.cachedTileCount, equals(2));

      cacheService.clearCache();
      expect(cacheService.cachedTileCount, equals(0));
    });
  });
}
