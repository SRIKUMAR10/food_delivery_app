import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/map_tile_cache_service.dart';

/// Ultra-Fast, Zero-Jitter Cached Map Tile Widget with In-Memory LRU Cache Fallback.
class CachedMapTile extends StatefulWidget {
  final String tileUrl;
  final bool isDarkMode;

  const CachedMapTile({
    super.key,
    required this.tileUrl,
    this.isDarkMode = false,
  });

  @override
  State<CachedMapTile> createState() => _CachedMapTileState();
}

class _CachedMapTileState extends State<CachedMapTile> {
  Uint8List? _cachedBytes;

  @override
  void initState() {
    super.initState();
    _loadTile();
  }

  @override
  void didUpdateWidget(covariant CachedMapTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tileUrl != oldWidget.tileUrl) {
      _loadTile();
    }
  }

  void _loadTile() {
    _cachedBytes = MapTileCacheService.instance.getCachedTile(widget.tileUrl);
    if (_cachedBytes == null) {
      MapTileCacheService.instance.fetchAndCacheTile(widget.tileUrl).then((bytes) {
        if (bytes != null && mounted) {
          setState(() {
            _cachedBytes = bytes;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedBytes != null) {
      return Image.memory(
        _cachedBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Container(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        ),
      );
    }

    return Image.network(
      widget.tileUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Container(
        color: widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      ),
    );
  }
}
