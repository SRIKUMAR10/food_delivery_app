import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/map_tile_cache_service.dart';

/// Ultra-Fast, Zero-Jitter Cached Map Tile Widget with Multi-Provider Fallbacks.
class CachedMapTile extends StatefulWidget {
  final String tileUrl;
  final bool isDarkMode;
  final String? fallbackTileUrl;

  const CachedMapTile({
    super.key,
    required this.tileUrl,
    this.isDarkMode = false,
    this.fallbackTileUrl,
  });

  @override
  State<CachedMapTile> createState() => _CachedMapTileState();
}

class _CachedMapTileState extends State<CachedMapTile> {
  Uint8List? _cachedBytes;
  bool _useFallback = false;

  static const List<double> _darkMapMatrix = <double>[
    -0.80,  0.0,   0.0,   0.0, 215.0,
     0.0,  -0.80,  0.0,   0.0, 222.0,
     0.0,   0.0,  -0.75,  0.0, 235.0,
     0.0,   0.0,   0.0,   1.0,   0.0,
  ];

  @override
  void initState() {
    super.initState();
    _loadTile();
  }

  @override
  void didUpdateWidget(covariant CachedMapTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tileUrl != oldWidget.tileUrl) {
      _useFallback = false;
      _cachedBytes = null;
      _loadTile();
    }
  }

  void _loadTile() {
    if (!kIsWeb) {
      _cachedBytes = MapTileCacheService.instance.getCachedTile(widget.tileUrl);
      if (_cachedBytes == null) {
        MapTileCacheService.instance
            .fetchAndCacheTile(widget.tileUrl)
            .then((bytes) {
          if (bytes != null && mounted) {
            setState(() {
              _cachedBytes = bytes;
            });
          }
        });
      }
    }
  }

  Widget _wrapTile(Widget child, String activeUrl) {
    final bool isSatellite = activeUrl.contains('lyrs=y') || activeUrl.contains('World_Imagery');
    final bool isNativeDark = activeUrl.contains('dark_all');
    if (widget.isDarkMode && !isSatellite && !isNativeDark) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(_darkMapMatrix),
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = (_useFallback && widget.fallbackTileUrl != null)
        ? widget.fallbackTileUrl!
        : widget.tileUrl;

    if (_cachedBytes != null) {
      return _wrapTile(
        Image.memory(
          _cachedBytes!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _buildTileImage(activeUrl),
        ),
        activeUrl,
      );
    }

    return _wrapTile(_buildTileImage(activeUrl), activeUrl);
  }

  Widget _buildTileImage(String activeUrl) {
    return Image.network(
      activeUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        if (!_useFallback && widget.fallbackTileUrl != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_useFallback) {
              setState(() {
                _useFallback = true;
              });
            }
          });
          return Image.network(
            widget.fallbackTileUrl!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Container(
              color: widget.isDarkMode
                  ? const Color(0xFF131E29)
                  : const Color(0xFFE2E8F0),
            ),
          );
        }
        return Container(
          color: widget.isDarkMode
              ? const Color(0xFF131E29)
              : const Color(0xFFE2E8F0),
        );
      },
    );
  }
}

