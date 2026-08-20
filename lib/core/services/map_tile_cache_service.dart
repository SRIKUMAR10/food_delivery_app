import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Centralized In-Memory LRU Map Tile Cache for Instant 0ms Rendering and Offline Resilience.
/// Zero external dependencies, pure Flutter & Dart native memory caching.
class MapTileCacheService {
  MapTileCacheService._internal();
  static final MapTileCacheService _instance = MapTileCacheService._internal();
  static MapTileCacheService get instance => _instance;

  static const int _maxTileCount = 250; // Holds ~250 256x256 map tiles (~6MB RAM footprint)
  final LinkedHashMap<String, Uint8List> _tileCache = LinkedHashMap<String, Uint8List>();
  final Set<String> _pendingDownloads = <String>{};

  /// Current count of cached map tiles in memory
  int get cachedTileCount => _tileCache.length;

  /// Check if a tile URL is already present in cache
  bool isCached(String url) => _tileCache.containsKey(url);

  /// Synchronously retrieve cached tile bytes using LRU ordering
  Uint8List? getCachedTile(String url) {
    if (_tileCache.containsKey(url)) {
      // LRU refresh: re-insert at end to mark as most recently used
      final bytes = _tileCache.remove(url)!;
      _tileCache[url] = bytes;
      return bytes;
    }
    return null;
  }

  /// Store tile bytes into memory cache with LRU eviction
  void cacheTile(String url, Uint8List bytes) {
    if (_tileCache.containsKey(url)) {
      _tileCache.remove(url);
    } else if (_tileCache.length >= _maxTileCount) {
      // Evict oldest (least recently used) tile
      final oldestKey = _tileCache.keys.first;
      _tileCache.remove(oldestKey);
    }
    _tileCache[url] = bytes;
  }

  /// Asynchronously fetch tile from network and store in LRU cache
  Future<Uint8List?> fetchAndCacheTile(String url) async {
    final cached = getCachedTile(url);
    if (cached != null) return cached;

    if (_pendingDownloads.contains(url)) {
      return null;
    }

    _pendingDownloads.add(url);
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        cacheTile(url, bytes);
        return bytes;
      }
    } catch (e) {
      debugPrint('MapTileCacheService fetch error for $url: $e');
    } finally {
      _pendingDownloads.remove(url);
    }
    return null;
  }

  /// Background worker to prefetch upcoming route map tiles
  void prefetchTiles(List<String> urls) {
    for (final url in urls) {
      if (!isCached(url) && !_pendingDownloads.contains(url)) {
        fetchAndCacheTile(url);
      }
    }
  }

  /// Clears in-memory tile cache
  void clearCache() {
    _tileCache.clear();
    _pendingDownloads.clear();
  }
}
