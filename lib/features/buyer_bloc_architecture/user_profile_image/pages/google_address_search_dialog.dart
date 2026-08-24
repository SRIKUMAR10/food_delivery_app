import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';
import 'package:food_delivery_app/core/services/google_maps_loader.dart';
import 'package:food_delivery_app/core/widgets/cached_map_tile.dart';

enum _AddressPickerTab { search, map }

/// Interactive Google Places & Address Search modal / dialog with
/// Draggable Map Pin Picker (Ola / Rapido / Swiggy style).
class GoogleAddressSearchDialog extends StatefulWidget {
  final String addressType;
  final String currentAddress;
  final GooglePlacesService? placesService;
  final ValueChanged<String> onAddressSelected;

  const GoogleAddressSearchDialog({
    super.key,
    required this.addressType,
    required this.currentAddress,
    required this.onAddressSelected,
    this.placesService,
  });

  /// Displays the search modal responsively on Mobile, Web, or Desktop.
  static Future<String?> show({
    required BuildContext context,
    required String addressType,
    required String currentAddress,
    required ValueChanged<String> onAddressSelected,
    GooglePlacesService? placesService,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (isDesktop) {
      return showDialog<String>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: GoogleAddressSearchDialog(
              addressType: addressType,
              currentAddress: currentAddress,
              onAddressSelected: onAddressSelected,
              placesService: placesService,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: GoogleAddressSearchDialog(
              addressType: addressType,
              currentAddress: currentAddress,
              onAddressSelected: onAddressSelected,
              placesService: placesService,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<GoogleAddressSearchDialog> createState() => _GoogleAddressSearchDialogState();
}

class _GoogleAddressSearchDialogState extends State<GoogleAddressSearchDialog>
    with SingleTickerProviderStateMixin {
  late final GooglePlacesService _placesService;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _flatDoorController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  _AddressPickerTab _activeTab = _AddressPickerTab.search;
  Timer? _debounceTimer;
  Timer? _mapIdleTimer;
  List<GooglePlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _isLocatingGps = false;
  bool _isMapGeocoding = false;
  bool _isMapDragging = false;
  String? _selectedGoogleAddress;
  String? _errorMessage;

  // Map state
  GoogleMapController? _mapController;
  LatLng _cameraCenter = const LatLng(13.0827, 80.2707); // Chennai center default
  late AnimationController _pinAnimController;
  double _fallbackZoom = 16.0;
  bool _forceFallbackCanvas = false;

  static const Color _primaryRed = BuyerAppColors.primary;

  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  int _latToTileY(double lat, int zoom) {
    final latRad = (lat.clamp(-85.0, 85.0)) * math.pi / 180.0;
    final n = math.log(math.tan(latRad) + 1.0 / math.cos(latRad));
    return ((1.0 - (n / math.pi)) / 2.0 * (1 << zoom)).floor();
  }

  double _lonToTileXFrac(double lon, int zoom) {
    return (lon + 180.0) / 360.0 * (1 << zoom);
  }

  double _latToTileYFrac(double lat, int zoom) {
    final latRad = (lat.clamp(-85.0, 85.0)) * math.pi / 180.0;
    final n = math.log(math.tan(latRad) + 1.0 / math.cos(latRad));
    return (1.0 - (n / math.pi)) / 2.0 * (1 << zoom);
  }

  @override
  void initState() {
    super.initState();
    _placesService = widget.placesService ?? GooglePlacesService.instance;

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    if (widget.currentAddress.isNotEmpty && widget.currentAddress != 'Tap edit to add address') {
      _selectedGoogleAddress = widget.currentAddress;
    }

    if (kIsWeb) {
      registerGoogleMapsAuthFailureListener(() {
        if (mounted) {
          setState(() {
            _forceFallbackCanvas = true;
          });
        }
      });

      ensureGoogleMapsJsLoaded().then((ready) {
        if (ready && mounted && !_forceFallbackCanvas) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapIdleTimer?.cancel();
    _pinAnimController.dispose();
    _searchController.dispose();
    _flatDoorController.dispose();
    _landmarkController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await _placesService.searchPlaces(query);
        if (mounted) {
          setState(() {
            _predictions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _errorMessage = 'Failed to search places. Please check network.';
          });
        }
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocatingGps = true;
      _errorMessage = null;
    });

    try {
      final details = await _placesService.getCurrentLocationAddress();
      if (details != null && mounted) {
        final lat = details.latitude ?? 13.0827;
        final lng = details.longitude ?? 80.2707;
        setState(() {
          _cameraCenter = LatLng(lat, lng);
          _selectedGoogleAddress = details.formattedAddress;
          _searchController.text = details.mainText;
          _predictions = [];
          _isLocatingGps = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _cameraCenter, zoom: 17.0),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isLocatingGps = false;
          _errorMessage = 'Could not retrieve GPS location. Please check location permissions.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocatingGps = false;
          _errorMessage = 'Location error: $e';
        });
      }
    }
  }

  void _onSelectPrediction(GooglePlacePrediction prediction) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final details = await _placesService.getPlaceDetails(
        prediction.placeId,
        fallbackAddress: prediction.description,
      );

      if (mounted) {
        final lat = details?.latitude ?? 13.0827;
        final lng = details?.longitude ?? 80.2707;
        setState(() {
          _cameraCenter = LatLng(lat, lng);
          _selectedGoogleAddress = details?.formattedAddress ?? prediction.description;
          _searchController.text = prediction.mainText;
          _predictions = [];
          _isSearching = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _cameraCenter, zoom: 17.0),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedGoogleAddress = prediction.description;
          _predictions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onCameraMoveStarted() {
    _mapIdleTimer?.cancel();
    if (!_isMapDragging) {
      setState(() {
        _isMapDragging = true;
      });
      _pinAnimController.forward();
    }
  }

  void _onCameraMove(CameraPosition position) {
    _cameraCenter = position.target;
  }

  void _onCameraIdle() {
    if (_isMapDragging) {
      setState(() {
        _isMapDragging = false;
      });
      _pinAnimController.reverse();
    }

    _mapIdleTimer?.cancel();
    _mapIdleTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() {
        _isMapGeocoding = true;
      });

      try {
        final details = await _placesService.reverseGeocode(
          _cameraCenter.latitude,
          _cameraCenter.longitude,
        );

        if (mounted && details != null) {
          setState(() {
            _selectedGoogleAddress = details.formattedAddress;
            _searchController.text = details.mainText;
            _isMapGeocoding = false;
          });
        } else if (mounted) {
          setState(() {
            _isMapGeocoding = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isMapGeocoding = false;
          });
        }
      }
    });
  }

  String _getFinalFormattedAddress() {
    final door = _flatDoorController.text.trim();
    final landmark = _landmarkController.text.trim();
    final base = _selectedGoogleAddress ?? _searchController.text.trim();

    final List<String> parts = [];
    if (door.isNotEmpty) parts.add(door);
    if (base.isNotEmpty) parts.add(base);
    if (landmark.isNotEmpty) parts.add('Landmark: $landmark');

    return parts.join(', ');
  }

  void _onConfirmAndSave() {
    final finalAddress = _getFinalFormattedAddress();
    if (finalAddress.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter or search for an address.';
      });
      return;
    }

    widget.onAddressSelected(finalAddress);
    Navigator.of(context).pop(finalAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          const Divider(height: 1, color: Color(0xFFF1F3F5)),
          Expanded(
            child: _activeTab == _AddressPickerTab.search
                ? _buildSearchModeView()
                : _buildMapPickerModeView(),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.addressType,
              style: const TextStyle(
                color: _primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Set ${widget.addressType} Address',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('closeAddressSearchButton'),
            icon: const Icon(Icons.close_rounded, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = _AddressPickerTab.search;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeTab == _AddressPickerTab.search ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _activeTab == _AddressPickerTab.search
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: _activeTab == _AddressPickerTab.search ? _primaryRed : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Search Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _activeTab == _AddressPickerTab.search ? _primaryRed : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = _AddressPickerTab.map;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeTab == _AddressPickerTab.map ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _activeTab == _AddressPickerTab.map
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        size: 16,
                        color: _activeTab == _AddressPickerTab.map ? _primaryRed : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pick on Map',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _activeTab == _AddressPickerTab.map ? _primaryRed : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchModeView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSearchInput(),
        const SizedBox(height: 14),
        _buildCurrentLocationTile(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(),
        ],
        const SizedBox(height: 16),
        if (_predictions.isNotEmpty) ...[
          _buildSectionTitle('Google Search Suggestions'),
          const SizedBox(height: 8),
          _buildPredictionsList(),
        ] else if (_selectedGoogleAddress != null && _selectedGoogleAddress!.isNotEmpty) ...[
          _buildSelectedAddressCard(),
          const SizedBox(height: 16),
          _buildRefinementSection(),
        ] else ...[
          _buildPopularLocationsSection(),
        ],
      ],
    );
  }

  Widget _buildInteractiveFallbackMap() {
    final int zoom = _fallbackZoom.round().clamp(10, 19);
    final int centerTileX = _lonToTileX(_cameraCenter.longitude, zoom);
    final int centerTileY = _latToTileY(_cameraCenter.latitude, zoom);
    final double fracX = _lonToTileXFrac(_cameraCenter.longitude, zoom) - centerTileX;
    final double fracY = _latToTileYFrac(_cameraCenter.latitude, zoom) - centerTileY;

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => _onCameraMoveStarted(),
          onPanUpdate: (details) {
            final double worldSize = 256.0 * (1 << zoom);
            final double dLng = (details.delta.dx / worldSize) * 360.0;
            final double dLat = (details.delta.dy / worldSize) * 360.0 * math.cos(_cameraCenter.latitude * math.pi / 180.0);
            final newLat = (_cameraCenter.latitude + dLat).clamp(-85.0, 85.0);
            final newLng = (_cameraCenter.longitude - dLng).clamp(-180.0, 180.0);

            _onCameraMove(CameraPosition(target: LatLng(newLat, newLng), zoom: _fallbackZoom));
            setState(() {});
          },
          onPanEnd: (_) => _onCameraIdle(),
          child: ClipRect(
            child: Container(
              color: const Color(0xFFF1F5F9),
              child: Stack(
                children: [
                  for (int dx = -2; dx <= 2; dx++)
                    for (int dy = -2; dy <= 2; dy++)
                      Positioned(
                        left: centerX + (dx * 256.0) - (fracX * 256.0),
                        top: centerY + (dy * 256.0) - (fracY * 256.0),
                        width: 256,
                        height: 256,
                        child: CachedMapTile(
                          tileUrl: 'https://basemaps.cartocdn.com/rastertiles/voyager/$zoom/${centerTileX + dx}/${centerTileY + dy}.png',
                          isDarkMode: false,
                        ),
                      ),
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 14, color: Colors.amberAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Interactive Pin: ${_cameraCenter.latitude.toStringAsFixed(4)}, ${_cameraCenter.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapPickerModeView() {
    final bool isNativeDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.linux ||
         defaultTargetPlatform == TargetPlatform.macOS);

    final bool shouldUseFallback = isNativeDesktop || (kIsWeb && !isGoogleMapsJsReady()) || _forceFallbackCanvas;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (shouldUseFallback)
                _buildInteractiveFallbackMap()
              else
                Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _cameraCenter,
                      zoom: 16.5,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onCameraMoveStarted: _onCameraMoveStarted,
                    onCameraMove: _onCameraMove,
                    onCameraIdle: _onCameraIdle,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                  ),
                ),

              // Central Floating Bouncing Pin
              AnimatedBuilder(
                animation: _pinAnimController,
                builder: (context, child) {
                  final double offset = -14.0 * _pinAnimController.value;
                  return Transform.translate(
                    offset: Offset(0, offset - 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6),
                            ],
                          ),
                          child: Text(
                            _isMapDragging
                                ? 'Pinning Location...'
                                : (_isMapGeocoding ? 'Finding Address...' : 'Order will be delivered here'),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.location_pin,
                          color: _primaryRed,
                          size: 44,
                        ),
                        Container(
                          width: 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Floating Controls
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'locateMeMapBtn',
                      backgroundColor: Colors.white,
                      foregroundColor: _primaryRed,
                      elevation: 3,
                      onPressed: _useCurrentLocation,
                      child: _isLocatingGps
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _primaryRed),
                            )
                          : const Icon(Icons.my_location_rounded, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomInMapBtn',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 3,
                      onPressed: () {
                        if (shouldUseFallback) {
                          setState(() {
                            _fallbackZoom = (_fallbackZoom + 1).clamp(10.0, 19.0);
                          });
                          _onCameraIdle();
                        } else {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        }
                      },
                      child: const Icon(Icons.add, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomOutMapBtn',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 3,
                      onPressed: () {
                        if (shouldUseFallback) {
                          setState(() {
                            _fallbackZoom = (_fallbackZoom - 1).clamp(10.0, 19.0);
                          });
                          _onCameraIdle();
                        } else {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        }
                      },
                      child: const Icon(Icons.remove, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live Selected Location Preview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.place_rounded, color: _primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedGoogleAddress ?? 'Move map to select delivery location',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('mapDoorFlatInputField'),
                controller: _flatDoorController,
                decoration: InputDecoration(
                  labelText: 'Flat / House No. (Optional)',
                  hintText: 'e.g. Flat 301',
                  isDense: true,
                  prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF64748B), size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        key: const ValueKey('addressSearchInputField'),
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search Google area, street, building...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryRed,
            size: 22,
          ),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primaryRed,
                    ),
                  ),
                )
              : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    return InkWell(
      key: const ValueKey('useCurrentLocationButton'),
      onTap: _isLocatingGps ? null : _useCurrentLocation,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _primaryRed.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: _isLocatingGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryRed,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: _primaryRed,
                      size: 18,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocatingGps ? 'Locating via GPS...' : 'Use Current Location',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Fetch current address using device GPS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: _primaryRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildPredictionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _predictions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final item = _predictions[index];
          return ListTile(
            key: ValueKey('predictionItem_$index'),
            onTap: () => _onSelectPrediction(item),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: _primaryRed,
                size: 20,
              ),
            ),
            title: Text(
              item.mainText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              item.secondaryText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Google Location',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF10B981),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoogleAddress = null;
                    _searchController.clear();
                  });
                },
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: _primaryRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedGoogleAddress!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Door / Flat / Landmark Details (Optional)'),
        const SizedBox(height: 10),
        TextField(
          key: const ValueKey('doorFlatInputField'),
          controller: _flatDoorController,
          decoration: InputDecoration(
            labelText: 'Flat / House / Floor / Building No.',
            hintText: 'e.g. Flat 402, Lotus Towers',
            prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('landmarkInputField'),
          controller: _landmarkController,
          decoration: InputDecoration(
            labelText: 'Landmark / Instructions (Optional)',
            hintText: 'e.g. Near HDFC Bank, 2nd Cross Road',
            prefixIcon: const Icon(Icons.pin_drop_outlined, color: Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularLocationsSection() {
    final popular = [
      {'title': 'Anna Nagar', 'sub': 'Chennai, Tamil Nadu, India'},
      {'title': 'T. Nagar (Thyagaraya Nagar)', 'sub': 'Chennai, Tamil Nadu, India'},
      {'title': 'Velachery Main Road', 'sub': 'Chennai, Tamil Nadu, India'},
      {'title': 'Connaught Place', 'sub': 'New Delhi, Delhi, India'},
      {'title': 'Indiranagar 100 Feet Road', 'sub': 'Bengaluru, Karnataka, India'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Popular & Recommended Areas'),
        const SizedBox(height: 10),
        ...popular.asMap().entries.map((entry) {
          final p = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              key: ValueKey('popularLocationItem_${entry.key}'),
              onTap: () {
                setState(() {
                  _selectedGoogleAddress = '${p['title']}, ${p['sub']}';
                  _searchController.text = p['title']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            p['sub']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _primaryRed,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const ValueKey('confirmAddressSelectionButton'),
            onPressed: _onConfirmAndSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Save This Address',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
