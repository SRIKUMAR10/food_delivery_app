import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/delivery_city_zone_service.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';
import 'package:food_delivery_app/core/services/google_maps_loader.dart';
import 'package:food_delivery_app/core/widgets/cached_map_tile.dart';
import 'package:food_delivery_app/core/theme/delivery_app_colors.dart';

enum _CityZoneSearchTab { citiesAndZones, mapPicker }

/// Interactive Delivery City & Operating Zone Hub Search modal / dialog with
/// live Google Places / Map Geocoding and City Hubs catalog for Delivery Partners.
class DeliveryCityZoneSearchDialog extends StatefulWidget {
  final String? initialCity;
  final String? initialZone;
  final DeliveryCityZoneService? cityZoneService;
  final GooglePlacesService? placesService;
  final ValueChanged<DeliveryCityZoneSelection>? onSelectionSelected;

  const DeliveryCityZoneSearchDialog({
    super.key,
    this.initialCity,
    this.initialZone,
    this.cityZoneService,
    this.placesService,
    this.onSelectionSelected,
  });

  /// Displays the search modal responsively on Mobile, Web, or Desktop.
  static Future<DeliveryCityZoneSelection?> show({
    required BuildContext context,
    String? initialCity,
    String? initialZone,
    DeliveryCityZoneService? cityZoneService,
    GooglePlacesService? placesService,
    ValueChanged<DeliveryCityZoneSelection>? onSelectionSelected,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (isDesktop) {
      return showDialog<DeliveryCityZoneSelection>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: DeliveryAppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 800),
            child: DeliveryCityZoneSearchDialog(
              initialCity: initialCity,
              initialZone: initialZone,
              cityZoneService: cityZoneService,
              placesService: placesService,
              onSelectionSelected: onSelectionSelected,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<DeliveryCityZoneSelection>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.92,
            decoration: const BoxDecoration(
              color: DeliveryAppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: DeliveryCityZoneSearchDialog(
              initialCity: initialCity,
              initialZone: initialZone,
              cityZoneService: cityZoneService,
              placesService: placesService,
              onSelectionSelected: onSelectionSelected,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<DeliveryCityZoneSearchDialog> createState() =>
      _DeliveryCityZoneSearchDialogState();
}

class _DeliveryCityZoneSearchDialogState
    extends State<DeliveryCityZoneSearchDialog>
    with SingleTickerProviderStateMixin {
  late final DeliveryCityZoneService _cityZoneService;
  late final GooglePlacesService _placesService;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mapSearchController = TextEditingController();

  _CityZoneSearchTab _activeTab = _CityZoneSearchTab.citiesAndZones;
  Timer? _debounceTimer;

  // City & Zone search state
  List<DeliveryCityInfo> _filteredCities = [];
  String _selectedCityName = 'Chennai';
  String? _selectedZoneName;
  bool _isLocatingGps = false;
  String? _gpsStatusMessage;

  // Map state
  GoogleMapController? _mapController;
  LatLng _cameraCenter = const LatLng(13.0827, 80.2707); // Default Chennai Central
  List<GooglePlacePrediction> _mapPredictions = [];
  bool _isMapSearching = false;
  bool _isMapGeocoding = false;
  String? _mapSelectedAddress;

  @override
  void initState() {
    super.initState();
    _cityZoneService = widget.cityZoneService ?? DeliveryCityZoneService.instance;
    _placesService = widget.placesService ?? GooglePlacesService();

    if (widget.initialCity != null && widget.initialCity!.trim().isNotEmpty) {
      _selectedCityName = widget.initialCity!.trim();
    }
    _selectedZoneName = widget.initialZone;

    _filteredCities = _cityZoneService.getAllCities();

    final matchedCity = _cityZoneService.findCityByName(_selectedCityName);
    if (matchedCity != null) {
      _cameraCenter = LatLng(matchedCity.latitude, matchedCity.longitude);
      if (_selectedZoneName != null) {
        final hub = matchedCity.hubs.firstWhere(
          (h) => h.hubName.toLowerCase() == _selectedZoneName!.toLowerCase(),
          orElse: () => matchedCity.hubs.first,
        );
        _cameraCenter = LatLng(hub.latitude, hub.longitude);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _filteredCities = _cityZoneService.searchCities(query);
      });
    });
  }

  Future<void> _detectGpsCityAndHub() async {
    setState(() {
      _isLocatingGps = true;
      _gpsStatusMessage = 'Detecting current GPS coordinates...';
    });

    try {
      final details = await _placesService.getCurrentLocationAddress();
      if (details != null && details.latitude != null && details.longitude != null) {
        final lat = details.latitude!;
        final lng = details.longitude!;
        final nearestCity = _cityZoneService.findNearestCity(lat, lng);
        final nearestHub = _cityZoneService.findNearestHub(nearestCity.cityName, lat, lng);

        if (mounted) {
          setState(() {
            _selectedCityName = nearestCity.cityName;
            _selectedZoneName = nearestHub.hubName;
            _cameraCenter = LatLng(lat, lng);
            _isLocatingGps = false;
            _gpsStatusMessage =
                'Detected: ${nearestCity.cityName} • Nearest Hub: ${nearestHub.hubName}';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLocatingGps = false;
            _gpsStatusMessage = 'Could not fetch GPS. Please pick city manually.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocatingGps = false;
          _gpsStatusMessage = 'Location detection unavailable. Select city below.';
        });
      }
    }
  }

  void _onSelectCity(DeliveryCityInfo city) {
    setState(() {
      _selectedCityName = city.cityName;
      _cameraCenter = LatLng(city.latitude, city.longitude);
      final hubs = city.hubs;
      if (hubs.isNotEmpty) {
        _selectedZoneName = hubs.first.hubName;
      }
    });
  }

  void _confirmSelection(DeliveryZoneHubInfo hub) {
    final selection = DeliveryCityZoneSelection(
      city: _selectedCityName,
      operatingZone: hub.hubName,
      hubCode: hub.hubCode,
      hubDescription: hub.description,
      latitude: hub.latitude,
      longitude: hub.longitude,
    );

    widget.onSelectionSelected?.call(selection);
    Navigator.of(context).pop(selection);
  }

  void _confirmMapSelection() {
    final cityObj = _cityZoneService.findCityByName(_selectedCityName);
    final hubName = _selectedZoneName ??
        (cityObj?.hubs.isNotEmpty == true ? cityObj!.hubs.first.hubName : 'Central Zone');

    final selection = DeliveryCityZoneSelection(
      city: _selectedCityName,
      operatingZone: hubName,
      hubCode: cityObj?.hubs.first.hubCode ?? 'HUB-01',
      hubDescription: _mapSelectedAddress ?? '$hubName Operating Area',
      latitude: _cameraCenter.latitude,
      longitude: _cameraCenter.longitude,
    );

    widget.onSelectionSelected?.call(selection);
    Navigator.of(context).pop(selection);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ───────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DeliveryAppColors.background,
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _activeTab == _CityZoneSearchTab.citiesAndZones
                ? _buildCitiesAndZonesTab()
                : _buildMapPickerTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        color: DeliveryAppColors.surface,
        border: Border(
          bottom: BorderSide(color: DeliveryAppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DeliveryAppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_city,
                color: DeliveryAppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Delivery City & Operating Hub',
                  style: TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Active: $_selectedCityName ${_selectedZoneName != null ? "• $_selectedZoneName" : ""}',
                  style: const TextStyle(
                    color: DeliveryAppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: DeliveryAppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: DeliveryAppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Cities & Hubs',
              icon: Icons.hub_outlined,
              tab: _CityZoneSearchTab.citiesAndZones,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              title: 'Map Hub Visualizer',
              icon: Icons.map_outlined,
              tab: _CityZoneSearchTab.mapPicker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required _CityZoneSearchTab tab,
  }) {
    final isSelected = _activeTab == tab;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryAppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? DeliveryAppColors.primary : DeliveryAppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? DeliveryAppColors.primary
                  : DeliveryAppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: CITIES & ZONES SELECTOR
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCitiesAndZonesTab() {
    final popularCities = _cityZoneService.getPopularCities();
    final activeCity = _cityZoneService.findCityByName(_selectedCityName) ??
        _cityZoneService.getAllCities().first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DeliveryAppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: DeliveryAppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search city (e.g. Chennai, Bengaluru, Coimbatore, Madurai)...',
              hintStyle: const TextStyle(
                  color: DeliveryAppColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.search,
                  color: DeliveryAppColors.textSecondary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: DeliveryAppColors.textSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // GPS Auto-detect button
        InkWell(
          onTap: _isLocatingGps ? null : _detectGpsCityAndHub,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: DeliveryAppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DeliveryAppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                _isLocatingGps
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: DeliveryAppColors.primary),
                      )
                    : const Icon(Icons.my_location,
                        color: DeliveryAppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _gpsStatusMessage ??
                        'Auto-Detect My Operating City & Nearest Hub (GPS)',
                    style: const TextStyle(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Popular City Chips
        const Text(
          'Popular Delivery Hub Cities',
          style: TextStyle(
            color: DeliveryAppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCities.map((city) {
            final isSelected =
                city.cityName.toLowerCase() == _selectedCityName.toLowerCase();
            return ChoiceChip(
              label: Text(city.cityName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onSelectCity(city);
                }
              },
              backgroundColor: DeliveryAppColors.surface,
              selectedColor: DeliveryAppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Active City Hubs Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Operating Hubs in ${activeCity.cityName} (${activeCity.hubs.length} Hubs)',
              style: const TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: DeliveryAppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                activeCity.tier,
                style: const TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List of Hubs for the active city
        ...activeCity.hubs.map((hub) => _buildHubCard(hub)),

        const SizedBox(height: 20),

        // Other Cities Section if search query exists
        if (_filteredCities.length > 1) ...[
          const Text(
            'All Operational Cities',
            style: TextStyle(
              color: DeliveryAppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ..._filteredCities
              .where((c) => c.cityName != activeCity.cityName)
              .map((c) => _buildCityTile(c)),
        ],
      ],
    );
  }

  Widget _buildHubCard(DeliveryZoneHubInfo hub) {
    final isSelected = _selectedZoneName?.toLowerCase() == hub.hubName.toLowerCase();
    final isSurge = hub.surgeStatus.contains('Surge') || hub.surgeStatus.contains('High');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? DeliveryAppColors.primary.withValues(alpha: 0.08)
            : DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? DeliveryAppColors.primary : DeliveryAppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmSelection(hub),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DeliveryAppColors.primary
                            : DeliveryAppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.store_mall_directory_rounded,
                        size: 18,
                        color: isSelected
                            ? Colors.black
                            : DeliveryAppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hub.hubName,
                                  style: TextStyle(
                                    color: DeliveryAppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSurge
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : DeliveryAppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hub.surgeStatus,
                                  style: TextStyle(
                                    color: isSurge
                                        ? Colors.orange
                                        : DeliveryAppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hub.description,
                            style: const TextStyle(
                              color: DeliveryAppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_outlined,
                            size: 13, color: DeliveryAppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          hub.hubCode,
                          style: const TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.radar,
                            size: 13, color: DeliveryAppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '~${hub.coverageRadiusKm.toInt()} km radius',
                          style: const TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _confirmSelection(hub),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? DeliveryAppColors.primary
                            : DeliveryAppColors.surface,
                        foregroundColor: isSelected
                            ? Colors.black
                            : DeliveryAppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: DeliveryAppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isSelected ? 'Selected' : 'Select Hub',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(DeliveryCityInfo city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => _onSelectCity(city),
          leading: const Icon(Icons.location_city,
              color: DeliveryAppColors.textSecondary, size: 20),
          title: Text(
            city.cityName,
            style: const TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
          subtitle: Text(
            '${city.state} • ${city.hubs.length} Active Hubs',
            style: const TextStyle(
                color: DeliveryAppColors.textSecondary, fontSize: 11),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 12, color: DeliveryAppColors.textSecondary),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: INTERACTIVE MAP VISUALIZER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMapPickerTab() {
    final bool isNativeDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    final bool shouldUseFallback =
        isNativeDesktop || (kIsWeb && !isGoogleMapsJsReady());

    return Stack(
      children: [
        // Map Canvas
        Positioned.fill(
          child: !shouldUseFallback
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _cameraCenter,
                    zoom: 14.0,
                  ),
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                  },
                  onCameraMove: (pos) {
                    _cameraCenter = pos.target;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                )
              : _buildFallbackMap(),
        ),

        // Center Pin
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DeliveryAppColors.primary, width: 1),
                ),
                child: Text(
                  '$_selectedCityName • ${_selectedZoneName ?? "Hub"}',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.location_on,
                size: 40,
                color: DeliveryAppColors.primary,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),

        // Top Search on Map Overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: DeliveryAppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: DeliveryAppColors.border),
                ),
                child: TextField(
                  controller: _mapSearchController,
                  onChanged: (val) async {
                    if (val.trim().length >= 3) {
                      final results = await _placesService.searchPlaces(val);
                      if (mounted) {
                        setState(() {
                          _mapPredictions = results;
                        });
                      }
                    }
                  },
                  style: const TextStyle(color: DeliveryAppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search place / locality in city...',
                    hintStyle: TextStyle(
                        color: DeliveryAppColors.textSecondary, fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: DeliveryAppColors.primary, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              if (_mapPredictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: DeliveryAppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DeliveryAppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _mapPredictions.take(4).length,
                    separatorBuilder: (_, __) => const Divider(
                        color: DeliveryAppColors.border, height: 1),
                    itemBuilder: (ctx, idx) {
                      final p = _mapPredictions[idx];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.place,
                              size: 16, color: DeliveryAppColors.primary),
                          title: Text(p.mainText,
                              style: const TextStyle(
                                  color: DeliveryAppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(p.secondaryText,
                              style: const TextStyle(
                                  color: DeliveryAppColors.textSecondary,
                                  fontSize: 10)),
                          onTap: () async {
                            final details = await _placesService.getPlaceDetails(
                                p.placeId,
                                fallbackAddress: p.description);
                            if (details != null &&
                                details.latitude != null &&
                                details.longitude != null &&
                                mounted) {
                              setState(() {
                                _cameraCenter =
                                    LatLng(details.latitude!, details.longitude!);
                                _mapSelectedAddress = details.formattedAddress;
                                _mapSearchController.text = p.mainText;
                                _mapPredictions = [];
                              });
                              _mapController?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(target: _cameraCenter, zoom: 16),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Bottom Confirmation Panel
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DeliveryAppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: DeliveryAppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub,
                        color: DeliveryAppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Operating Hub: $_selectedCityName • ${_selectedZoneName ?? "Central Zone"}',
                        style: const TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _confirmMapSelection,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'Confirm Hub & Location',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DeliveryAppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackMap() {
    final lat = _cameraCenter.latitude;
    final lng = _cameraCenter.longitude;
    const zoom = 14;
    final tileX = ((lng + 180.0) / 360.0 * (1 << zoom)).floor();
    final latRad = lat * math.pi / 180.0;
    final tileY = ((1.0 -
                math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) /
                    math.pi) /
            2.0 *
            (1 << zoom))
        .floor();

    final tileUrl = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';

    return ClipRect(
      child: Container(
        color: const Color(0xFF1E293B),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedMapTile(
                tileUrl: tileUrl,
                isDarkMode: true,
              ),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
