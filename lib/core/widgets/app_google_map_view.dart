import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/map_marker_service.dart';
import '../services/route_polyline_service.dart';
import '../services/google_maps_loader.dart';
import '../services/map_tile_cache_service.dart';
import 'cached_map_tile.dart';

/// Reusable, high-performance Google Maps widget for Buyer, Seller, and Delivery Partner.
/// Integrates real-time Firestore streaming, animated vehicle markers (2W & 4W),
/// smooth heading interpolation, Google Directions API & OSRM dynamic road polylines,
/// interactive Layer switching (Normal / Satellite / Hybrid), Zoom (+/-), Recenter, and Traffic Overlay.
class AppGoogleMapView extends StatefulWidget {
  final LatLng? driverLocation;
  final double driverHeading;
  final String? vehicleType;
  final LatLng? storeLocation;
  final String storeName;
  final LatLng? customerLocation;
  final String customerName;
  final bool isPickedUp;
  final bool isDarkMode;
  final bool isFullScreen;
  final bool showControls;
  final bool autoFollowDriver;
  final double initialZoom;
  final EdgeInsets padding;
  final Set<Marker>? additionalMarkers;
  final Set<Polyline>? additionalPolylines;
  final void Function(GoogleMapController controller)? onMapCreated;
  final VoidCallback? onToggleFullScreen;
  final double bottomBadgeOffset;
  final double progressRatio;
  final String? etaText;
  final double? distanceKm;
  final double? driverSpeed;
  final String? expectedDeliveryTime;
  final bool isArrivingSoon;
  final bool isRaining;
  final String? weatherAlert;
  final VoidCallback? onOpenExternalNavigation;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhotoUrl;
  final String? driverVehicleNumber;
  final double? driverRating;
  final String? storePhone;
  final String? storeAddress;
  final String? storeImageUrl;
  final String? customerAddress;
  final String? customerNotes;
  final VoidCallback? onCallDriver;
  final VoidCallback? onChatDriver;
  final VoidCallback? onCallStore;
  final VoidCallback? onStoreTap;
  final VoidCallback? onDriverTap;
  final VoidCallback? onCustomerTap;

  const AppGoogleMapView({
    super.key,
    this.driverLocation,
    this.driverHeading = 0.0,
    this.vehicleType,
    this.storeLocation,
    this.storeName = 'Restaurant',
    this.customerLocation,
    this.customerName = 'Customer',
    this.isPickedUp = false,
    this.isDarkMode = false,
    this.isFullScreen = false,
    this.showControls = true,
    this.autoFollowDriver = true,
    this.initialZoom = 15.0,
    this.padding = EdgeInsets.zero,
    this.additionalMarkers,
    this.additionalPolylines,
    this.onMapCreated,
    this.onToggleFullScreen,
    this.bottomBadgeOffset = 12.0,
    this.progressRatio = 0.0,
    this.etaText,
    this.distanceKm,
    this.driverSpeed,
    this.expectedDeliveryTime,
    this.isArrivingSoon = false,
    this.isRaining = false,
    this.weatherAlert,
    this.onOpenExternalNavigation,
    this.driverName,
    this.driverPhone,
    this.driverPhotoUrl,
    this.driverVehicleNumber,
    this.driverRating,
    this.storePhone,
    this.storeAddress,
    this.storeImageUrl,
    this.customerAddress,
    this.customerNotes,
    this.onCallDriver,
    this.onChatDriver,
    this.onCallStore,
    this.onStoreTap,
    this.onDriverTap,
    this.onCustomerTap,
  });

  @override
  State<AppGoogleMapView> createState() => _AppGoogleMapViewState();
}

class _AppGoogleMapViewState extends State<AppGoogleMapView>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  bool _showWeatherOverlay = true;

  // Fallback Interactive Navigation State
  double _canvasZoom = 1.0;
  double _tileZoom = 15.0;
  Offset _canvasPanOffset = Offset.zero;

  // Custom BitmapDescriptors
  BitmapDescriptor? _vehicleIcon;
  BitmapDescriptor? _storeIcon;
  BitmapDescriptor? _customerIcon;

  // Real Road Polylines
  Set<Polyline> _roadPolylines = {};

  // Animated Marker Position State
  late AnimationController _animController;
  late AnimationController _rainAnimController;
  LatLng? _previousDriverPos;
  LatLng? _currentDriverPos;
  double _animatedLat = 11.4485;
  double _animatedLng = 77.6835;
  double _animatedHeading = 0.0;

  // Live Device Current GPS Location
  LatLng? _deviceGpsLocation;
  bool _isFetchingGps = false;
  bool _autoFollowDriver = true;

  bool _forceFallbackCanvas = false;

  @override
  void initState() {
    super.initState();
    _currentDriverPos = widget.driverLocation ?? widget.customerLocation ?? widget.storeLocation ?? const LatLng(11.4485, 77.6835);
    _previousDriverPos = _currentDriverPos;
    _animatedLat = _currentDriverPos!.latitude;
    _animatedLng = _currentDriverPos!.longitude;
    _animatedHeading = widget.driverHeading;
    _tileZoom = widget.initialZoom;
    _autoFollowDriver = widget.autoFollowDriver;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(_onAnimationTick);

    _rainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isRaining) {
      _rainAnimController.repeat();
    }

    _loadCustomIcons();
    _fetchRoadPolylines();
    _fetchDeviceGpsLocation();

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

  void _toggleAutoFollow() {
    setState(() {
      _autoFollowDriver = !_autoFollowDriver;
    });
    if (_autoFollowDriver) {
      _recenterDriver();
    }
  }

  Future<void> _openExternalGoogleMaps() async {
    if (widget.onOpenExternalNavigation != null) {
      widget.onOpenExternalNavigation!();
      return;
    }
    final dest = widget.customerLocation ?? widget.storeLocation;
    if (dest == null) return;
    final origin = widget.driverLocation ?? widget.storeLocation;

    final uri = Uri.parse(
      origin != null
          ? 'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&travelmode=driving'
          : 'https://www.google.com/maps/search/?api=1&query=${dest.latitude},${dest.longitude}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _fetchDeviceGpsLocation({bool animate = false}) async {
    if (_isFetchingGps) return;
    _isFetchingGps = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isFetchingGps = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          _isFetchingGps = false;
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final freshLatLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _deviceGpsLocation = freshLatLng;
          if (animate || (widget.customerLocation == null && widget.driverLocation == null)) {
            _canvasPanOffset = Offset.zero;
            _tileZoom = 16.0;
          }
        });

        if (animate && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: freshLatLng, zoom: 16.0),
            ),
          );
        }
      }
    } catch (_) {
    } finally {
      _isFetchingGps = false;
    }
  }

  void _onAnimationTick() {
    if (_previousDriverPos != null && _currentDriverPos != null) {
      final double t = CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
      ).value;

      setState(() {
        _animatedLat = _previousDriverPos!.latitude +
            (_currentDriverPos!.latitude - _previousDriverPos!.latitude) * t;
        _animatedLng = _previousDriverPos!.longitude +
            (_currentDriverPos!.longitude - _previousDriverPos!.longitude) * t;
      });

      if (_autoFollowDriver && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(_animatedLat, _animatedLng), zoom: _tileZoom),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant AppGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRaining != oldWidget.isRaining) {
      if (widget.isRaining) {
        _rainAnimController.repeat();
      } else {
        _rainAnimController.stop();
      }
    }

    if (widget.vehicleType != oldWidget.vehicleType ||
        (widget.driverHeading - oldWidget.driverHeading).abs() > 15) {
      _loadCustomIcons();
    }

    if (widget.storeLocation != oldWidget.storeLocation ||
        widget.customerLocation != oldWidget.customerLocation ||
        widget.isPickedUp != oldWidget.isPickedUp ||
        (widget.driverLocation != null && oldWidget.driverLocation == null) ||
        (widget.driverLocation != null &&
            oldWidget.driverLocation != null &&
            ((widget.driverLocation!.latitude - oldWidget.driverLocation!.latitude).abs() > 0.0008 ||
                (widget.driverLocation!.longitude - oldWidget.driverLocation!.longitude).abs() > 0.0008))) {
      _fetchRoadPolylines();
    }

    if (widget.driverLocation != null &&
        widget.driverLocation != oldWidget.driverLocation) {
      _previousDriverPos = LatLng(_animatedLat, _animatedLng);
      _currentDriverPos = widget.driverLocation;
      _animatedHeading = widget.driverHeading;
      _animController.forward(from: 0.0);

      if (widget.autoFollowDriver && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(widget.driverLocation!),
        );
      }
    }
  }

  @override
  void dispose() {
    _rainAnimController.dispose();
    _animController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRoadPolylines() async {
    try {
      final polylines = await RoutePolylineService.instance.generateRealRoadJourneyPolylines(
        storeLocation: widget.storeLocation,
        driverLocation: widget.driverLocation ?? LatLng(_animatedLat, _animatedLng),
        customerLocation: widget.customerLocation,
        isPickedUp: widget.isPickedUp,
        activeColor: const Color(0xFFE52121),
      );
      if (mounted) {
        setState(() {
          _roadPolylines = polylines;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCustomIcons() async {
    try {
      final vehicle = await MapMarkerService.instance.getVehicleMarker(
        vehicleType: widget.vehicleType,
        heading: widget.driverHeading,
        primaryColor: const Color(0xFFE52121),
      );
      final store = await MapMarkerService.instance.getStoreMarker();
      final customer = await MapMarkerService.instance.getCustomerMarker();

      if (mounted) {
        setState(() {
          _vehicleIcon = vehicle;
          _storeIcon = store;
          _customerIcon = customer;
        });
      }
    } catch (_) {}
  }

  LatLng get _initialCenter {
    if (widget.driverLocation != null) return widget.driverLocation!;
    if (widget.customerLocation != null) return widget.customerLocation!;
    if (widget.storeLocation != null) return widget.storeLocation!;
    if (_deviceGpsLocation != null) return _deviceGpsLocation!;
    return const LatLng(11.4485, 77.6835);
  }

  LatLng get _effectiveCenter {
    if (widget.driverLocation != null) return widget.driverLocation!;
    if (widget.storeLocation != null && widget.customerLocation != null) {
      return LatLng(
        (widget.storeLocation!.latitude + widget.customerLocation!.latitude) / 2,
        (widget.storeLocation!.longitude + widget.customerLocation!.longitude) / 2,
      );
    }
    return widget.customerLocation ?? _deviceGpsLocation ?? widget.storeLocation ?? const LatLng(11.4485, 77.6835);
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // 1. Store Marker
    if (widget.storeLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('marker_store'),
          position: widget.storeLocation!,
          icon: _storeIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: widget.storeName,
            snippet: 'Pickup Location · Tap for details',
          ),
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.onStoreTap != null) {
              widget.onStoreTap!();
            } else {
              _showStoreInfoSheet(context);
            }
          },
        ),
      );
    }

    // 2. Customer Destination Marker
    if (widget.customerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('marker_customer'),
          position: widget.customerLocation!,
          icon: _customerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: widget.customerName,
            snippet: 'Delivery Destination · Tap for details',
          ),
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.onCustomerTap != null) {
              widget.onCustomerTap!();
            } else {
              _showCustomerInfoSheet(context);
            }
          },
        ),
      );
    }

    // 3. Live Device GPS Location Marker
    if (_deviceGpsLocation != null && widget.customerLocation == null) {
      markers.add(
        Marker(
          markerId: const MarkerId('marker_device_live_gps'),
          position: _deviceGpsLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Your Current Location',
            snippet: 'Live Device GPS',
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // 4. Animated Driver / Courier Marker
    if (widget.driverLocation != null || _previousDriverPos != null) {
      final currentPos = LatLng(_animatedLat, _animatedLng);
      markers.add(
        Marker(
          markerId: const MarkerId('marker_driver'),
          position: currentPos,
          icon: _vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: _animatedHeading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(
            title: widget.driverName ?? 'Delivery Partner',
            snippet: widget.isPickedUp ? 'On the way to you · Tap for details' : 'Heading to restaurant',
          ),
          zIndexInt: 999,
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.onDriverTap != null) {
              widget.onDriverTap!();
            } else {
              _showDriverInfoSheet(context);
            }
          },
        ),
      );
    }

    if (widget.additionalMarkers != null) {
      markers.addAll(widget.additionalMarkers!);
    }

    return markers;
  }

  void _showStoreInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFFEA580C),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.storeName.isNotEmpty ? widget.storeName : 'Restaurant',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: Color(0xFF10B981), size: 13),
                                SizedBox(width: 2),
                                Text(
                                  '4.8 (500+)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Order Pickup Zone',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.storeAddress != null && widget.storeAddress!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.storeAddress!,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.isDarkMode ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.onCallStore != null || widget.storePhone != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (widget.onCallStore != null) {
                          widget.onCallStore!();
                        } else if (widget.storePhone != null) {
                          launchUrl(Uri.parse('tel:${widget.storePhone}'));
                        }
                      },
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: const Text('Call Store', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (widget.onCallStore != null || widget.storePhone != null) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openExternalGoogleMaps();
                    },
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('Directions', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverInfoSheet(BuildContext context) {
    final isBike = MapMarkerService.isTwoWheeler(widget.vehicleType);
    final partnerName = widget.driverName ?? 'Delivery Partner';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E7FF),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (widget.driverPhotoUrl != null && widget.driverPhotoUrl!.isNotEmpty)
                      ? Image.network(
                          widget.driverPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                            color: const Color(0xFF4338CA),
                            size: 28,
                          ),
                        )
                      : Icon(
                          isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                          color: const Color(0xFF4338CA),
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              partnerName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFF10B981), size: 13),
                                const SizedBox(width: 2),
                                Text(
                                  widget.driverRating != null ? widget.driverRating!.toStringAsFixed(1) : '4.9',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.driverVehicleNumber ?? (isBike ? '2-Wheeler Partner' : '4-Wheeler Partner'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Status: ${widget.isPickedUp ? "On the way to your address" : "Arriving at store"} · ${widget.driverSpeed != null && widget.driverSpeed! > 2 ? "${widget.driverSpeed!.toStringAsFixed(0)} km/h" : "Idle"}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.onCallDriver != null) {
                        widget.onCallDriver!();
                      } else if (widget.driverPhone != null) {
                        launchUrl(Uri.parse('tel:${widget.driverPhone}'));
                      }
                    },
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Call Partner', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52121),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onChatDriver?.call();
                    },
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customerName.isNotEmpty ? widget.customerName : 'Delivery Address',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Your Destination Point',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.customerAddress != null && widget.customerAddress!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.customerAddress!,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDarkMode ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.customerNotes != null && widget.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delivery Notes: ${widget.customerNotes}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCanvasPinTap(BuildContext context, Offset tapPos, double minX, double minY, double zoom) {
    if (widget.driverLocation != null) {
      final driverPx = _Mercator.lngToPixelX(_animatedLng, zoom) - minX;
      final driverPy = _Mercator.latToPixelY(_animatedLat, zoom) - minY;
      final dist = (tapPos - Offset(driverPx, driverPy)).distance;
      if (dist < 40) {
        HapticFeedback.lightImpact();
        if (widget.onDriverTap != null) {
          widget.onDriverTap!();
        } else {
          _showDriverInfoSheet(context);
        }
        return;
      }
    }

    if (widget.storeLocation != null) {
      final storePx = _Mercator.lngToPixelX(widget.storeLocation!.longitude, zoom) - minX;
      final storePy = _Mercator.latToPixelY(widget.storeLocation!.latitude, zoom) - minY;
      final dist = (tapPos - Offset(storePx, storePy)).distance;
      if (dist < 40) {
        HapticFeedback.lightImpact();
        if (widget.onStoreTap != null) {
          widget.onStoreTap!();
        } else {
          _showStoreInfoSheet(context);
        }
        return;
      }
    }

    if (widget.customerLocation != null) {
      final custPx = _Mercator.lngToPixelX(widget.customerLocation!.longitude, zoom) - minX;
      final custPy = _Mercator.latToPixelY(widget.customerLocation!.latitude, zoom) - minY;
      final dist = (tapPos - Offset(custPx, custPy)).distance;
      if (dist < 40) {
        HapticFeedback.lightImpact();
        if (widget.onCustomerTap != null) {
          widget.onCustomerTap!();
        } else {
          _showCustomerInfoSheet(context);
        }
        return;
      }
    }
  }

  Set<Polyline> _buildPolylines() {
    final Set<Polyline> polylines = Set.from(_roadPolylines);

    if (widget.additionalPolylines != null) {
      polylines.addAll(widget.additionalPolylines!);
    }

    return polylines;
  }

  void _zoomIn() {
    setState(() {
      _tileZoom = (_tileZoom + 1.0).clamp(10.0, 19.0);
      _canvasZoom = (_canvasZoom * 1.25).clamp(0.5, 4.0);
    });
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    setState(() {
      _tileZoom = (_tileZoom - 1.0).clamp(10.0, 19.0);
      _canvasZoom = (_canvasZoom * 0.8).clamp(0.5, 4.0);
    });
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _recenterDriver() async {
    // 1. Fetch fresh live GPS location from device
    await _fetchDeviceGpsLocation(animate: true);

    // 2. Center priority: live device GPS -> driver location -> customer location -> store location
    final target = _deviceGpsLocation ?? widget.driverLocation ?? widget.customerLocation ?? widget.storeLocation;
    if (target != null && mounted) {
      setState(() {
        _canvasPanOffset = Offset.zero;
        _canvasZoom = 1.0;
        _tileZoom = 16.0;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16.0),
        ),
      );
    }
  }

  void _fitAllRouteBounds() {
    setState(() {
      _canvasZoom = 1.0;
      _canvasPanOffset = Offset.zero;
      _tileZoom = 14.0;
    });
    final points = <LatLng>[
      if (widget.storeLocation != null) widget.storeLocation!,
      if (widget.driverLocation != null) widget.driverLocation!,
      if (widget.customerLocation != null) widget.customerLocation!,
    ];
    if (points.isEmpty) return;

    final bounds = RoutePolylineService.instance.computeBounds(points);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isNativeDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.linux ||
         defaultTargetPlatform == TargetPlatform.macOS);

    if (isNativeDesktop || (kIsWeb && !isGoogleMapsJsReady()) || _forceFallbackCanvas) {
      return _buildFallbackCanvasView(context);
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialCenter,
            zoom: widget.initialZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated?.call(controller);
            if (widget.isDarkMode) {
              _applyDarkStyle(controller);
            }
          },
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          mapType: _currentMapType,
          trafficEnabled: _trafficEnabled,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          padding: widget.padding,
        ),
        if (widget.isRaining && _showWeatherOverlay)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _rainAnimController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RainParticleOverlayPainter(progress: _rainAnimController.value),
                  );
                },
              ),
            ),
          ),
        _buildLiveProgressAndEtaChip(),
        if (widget.isRaining && _showWeatherOverlay) _buildWeatherSafetyBanner(),
        if (widget.showControls) _buildMapOverlayControls(),
      ],
    );
  }

  void _applyDarkStyle(GoogleMapController controller) {
    const String darkMapStyle = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
      {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]}
    ]
    ''';
    try {
      controller.setMapStyle(darkMapStyle);
    } catch (_) {}
  }

  Widget _buildLiveProgressAndEtaChip() {
    final hasDriver = widget.driverLocation != null;
    final isBike = MapMarkerService.isTwoWheeler(widget.vehicleType);
    final etaLabel = widget.etaText ?? (hasDriver ? 'Arriving in ~10-15 mins' : 'Order Placed · Partner Assigning');
    final progress = widget.progressRatio.clamp(0.0, 1.0);
    final speed = widget.driverSpeed;

    return Positioned(
      left: 12,
      top: 12,
      right: 68,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? const Color(0xFF1E293B).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: widget.isArrivingSoon
                  ? const Color(0xFFF59E0B)
                  : (widget.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: widget.isArrivingSoon ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (widget.isArrivingSoon ? const Color(0xFFF59E0B) : const Color(0xFFE52121)).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                      size: 16,
                      color: widget.isArrivingSoon ? const Color(0xFFF59E0B) : const Color(0xFFE52121),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isArrivingSoon
                          ? '⚡ Arriving at your doorstep!'
                          : (widget.expectedDeliveryTime != null
                              ? 'Expected by ${widget.expectedDeliveryTime}'
                              : etaLabel),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (speed != null && speed > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speed_rounded, size: 11, color: Color(0xFF10B981)),
                          const SizedBox(width: 2),
                          Text(
                            '${speed.round()} km/h',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (speed != null && speed == 0 && hasDriver) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '🛑 Idle',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                  if (widget.distanceKm != null && widget.distanceKm! > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.distanceKm! < 1.0
                            ? '${(widget.distanceKm! * 1000).round()}m away'
                            : '${widget.distanceKm!.toStringAsFixed(1)}km away',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (progress > 0.0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(begin: 0.0, end: progress),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 4.5,
                        backgroundColor: widget.isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isArrivingSoon
                              ? const Color(0xFFF59E0B)
                              : (progress > 0.8 ? const Color(0xFF10B981) : const Color(0xFFE52121)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapOverlayControls() {
    final isSatellite = _currentMapType == MapType.satellite || _currentMapType == MapType.hybrid;

    return Positioned(
      right: 12,
      top: 12,
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mapIconButton(Icons.add, _zoomIn, tooltip: 'Zoom In'),
              const SizedBox(height: 5),
              _mapIconButton(Icons.remove, _zoomOut, tooltip: 'Zoom Out'),
              const SizedBox(height: 5),
              _mapIconButton(
                _autoFollowDriver ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                _toggleAutoFollow,
                tooltip: _autoFollowDriver ? 'Auto-Follow: ON' : 'Auto-Follow: OFF',
                color: _autoFollowDriver ? const Color(0xFF10B981) : Colors.black87,
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                Icons.my_location_rounded,
                _recenterDriver,
                tooltip: 'Recenter on Live GPS',
                color: const Color(0xFFE52121),
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                Icons.directions_rounded,
                _openExternalGoogleMaps,
                tooltip: 'Open in Google Maps',
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                Icons.crop_free_rounded,
                _fitAllRouteBounds,
                tooltip: 'Fit Entire Route',
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                isSatellite ? Icons.satellite_alt_rounded : Icons.layers_outlined,
                _toggleMapType,
                tooltip: isSatellite ? 'Satellite Layer Active' : 'Switch to Satellite View',
                color: isSatellite ? const Color(0xFF2563EB) : Colors.black87,
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                _trafficEnabled ? Icons.traffic_rounded : Icons.traffic_outlined,
                _toggleTraffic,
                tooltip: 'Live Traffic Flow',
                color: _trafficEnabled ? const Color(0xFFEA580C) : Colors.black87,
              ),
              if (widget.isRaining) ...[
                const SizedBox(height: 5),
                _mapIconButton(
                  _showWeatherOverlay ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                  _toggleWeatherLayer,
                  tooltip: _showWeatherOverlay ? 'Weather Alert: ON' : 'Weather Alert: OFF',
                  color: _showWeatherOverlay ? const Color(0xFF0284C7) : Colors.black87,
                ),
              ],
              if (widget.onToggleFullScreen != null) ...[
                const SizedBox(height: 5),
                _mapIconButton(
                  widget.isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  widget.onToggleFullScreen!,
                  tooltip: widget.isFullScreen ? 'Exit Full Screen' : 'Full Screen',
                  color: widget.isFullScreen ? const Color(0xFFE52121) : Colors.black87,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _toggleWeatherLayer() {
    setState(() {
      _showWeatherOverlay = !_showWeatherOverlay;
    });
  }

  Widget _buildWeatherSafetyBanner() {
    final alertText = widget.weatherAlert ?? '🌧️ Rain near Bhavani · Partner is delivering safely with care';
    return Positioned(
      left: 12,
      right: 68,
      bottom: widget.bottomBadgeOffset + 6,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.thunderstorm_rounded,
                size: 16,
                color: Color(0xFF38BDF8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  alertText,
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapIconButton(
    IconData icon,
    VoidCallback onTap, {
    String? tooltip,
    Color color = Colors.black87,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  /// High-definition interactive real-world map tile engine with OpenStreetMap / CartoDB / Esri Satellite
  Widget _buildFallbackCanvasView(BuildContext context) {
    final isSatellite = _currentMapType == MapType.satellite || _currentMapType == MapType.hybrid;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double zoom = _tileZoom;
        final int z = zoom.round().clamp(1, 19);
        final int numTiles = 1 << z;
        final center = _effectiveCenter;

        final double centerPixelX = _Mercator.lngToPixelX(center.longitude, zoom);
        final double centerPixelY = _Mercator.latToPixelY(center.latitude, zoom);

        final double minX = centerPixelX - (width / 2) - _canvasPanOffset.dx;
        final double minY = centerPixelY - (height / 2) - _canvasPanOffset.dy;

        final int startCol = (minX / 256.0).floor();
        final int endCol = ((minX + width) / 256.0).floor();
        final int startRow = (minY / 256.0).floor();
        final int endRow = ((minY + height) / 256.0).floor();

        final List<Widget> tileWidgets = [];

        for (int r = startRow; r <= endRow; r++) {
          if (r < 0 || r >= numTiles) continue;
          for (int c = startCol; c <= endCol; c++) {
            final int normCol = ((c % numTiles) + numTiles) % numTiles;
            final double tileLeft = (c * 256.0) - minX;
            final double tileTop = (r * 256.0) - minY;

            final String tileUrl;
            if (isSatellite) {
              tileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$z/$r/$normCol';
            } else if (widget.isDarkMode) {
              tileUrl = 'https://basemaps.cartocdn.com/rastertiles/dark_all/$z/$normCol/$r.png';
            } else {
              tileUrl = 'https://basemaps.cartocdn.com/rastertiles/voyager/$z/$normCol/$r.png';
            }

            tileWidgets.add(
              Positioned(
                left: tileLeft,
                top: tileTop,
                width: 256,
                height: 256,
                child: CachedMapTile(
                  tileUrl: tileUrl,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: isSatellite
                ? const Color(0xFF0F172A)
                : (widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _canvasPanOffset += details.delta;
                  });
                },
                onTapUp: (details) => _handleCanvasPinTap(context, details.localPosition, minX, minY, zoom),
                child: Stack(
                  children: [
                    ...tileWidgets,
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RealTileMapOverlayPainter(
                          minX: minX,
                          minY: minY,
                          zoom: zoom,
                          roadPolylines: _roadPolylines,
                          driverPos: widget.driverLocation != null ? LatLng(_animatedLat, _animatedLng) : null,
                          driverHeading: _animatedHeading,
                          vehicleType: widget.vehicleType,
                          storePos: widget.storeLocation,
                          storeName: widget.storeName,
                          customerPos: widget.customerLocation,
                          customerName: widget.customerName,
                          deviceGpsPos: _deviceGpsLocation,
                          trafficEnabled: _trafficEnabled,
                          isSatellite: isSatellite,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isRaining && _showWeatherOverlay)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _rainAnimController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RainParticleOverlayPainter(progress: _rainAnimController.value),
                        );
                      },
                    ),
                  ),
                ),
              _buildLiveProgressAndEtaChip(),
              if (widget.isRaining && _showWeatherOverlay) _buildWeatherSafetyBanner(),
              if (widget.showControls) _buildMapOverlayControls(),
              Positioned(
                left: 12,
                bottom: widget.bottomBadgeOffset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSatellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
                        size: 13,
                        color: isSatellite ? const Color(0xFF60A5FA) : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSatellite
                            ? 'Satellite Imagery · Real-Time Hybrid'
                            : 'Live Real-Time Map (${MapMarkerService.isTwoWheeler(widget.vehicleType) ? "2-Wheeler" : "4-Wheeler"})',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Mercator {
  static const double tileSize = 256.0;

  static double lngToPixelX(double lng, double zoom) {
    return (lng + 180.0) / 360.0 * math.pow(2.0, zoom) * tileSize;
  }

  static double latToPixelY(double lat, double zoom) {
    final double clampedLat = lat.clamp(-85.05112878, 85.05112878);
    final double latRad = clampedLat * math.pi / 180.0;
    final double mercN = math.log(math.tan((math.pi / 4.0) + (latRad / 2.0)));
    return (1.0 - (mercN / math.pi)) / 2.0 * math.pow(2.0, zoom) * tileSize;
  }
}

class _RealTileMapOverlayPainter extends CustomPainter {
  final double minX;
  final double minY;
  final double zoom;
  final Set<Polyline> roadPolylines;
  final LatLng? driverPos;
  final double driverHeading;
  final String? vehicleType;
  final LatLng? storePos;
  final String storeName;
  final LatLng? customerPos;
  final String customerName;
  final LatLng? deviceGpsPos;
  final bool trafficEnabled;
  final bool isSatellite;
  final bool isDarkMode;

  _RealTileMapOverlayPainter({
    required this.minX,
    required this.minY,
    required this.zoom,
    required this.roadPolylines,
    required this.driverPos,
    required this.driverHeading,
    required this.vehicleType,
    required this.storePos,
    required this.storeName,
    required this.customerPos,
    required this.customerName,
    this.deviceGpsPos,
    required this.trafficEnabled,
    required this.isSatellite,
    required this.isDarkMode,
  });

  Offset _latLngToScreen(LatLng point) {
    final double px = _Mercator.lngToPixelX(point.longitude, zoom) - minX;
    final double py = _Mercator.latToPixelY(point.latitude, zoom) - minY;
    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Real Road Route Polylines from OSRM / Directions backend
    if (roadPolylines.isNotEmpty) {
      for (final poly in roadPolylines) {
        if (poly.points.isEmpty) continue;
        final path = Path();
        final first = _latLngToScreen(poly.points.first);
        path.moveTo(first.dx, first.dy);
        for (int i = 1; i < poly.points.length; i++) {
          final pt = _latLngToScreen(poly.points[i]);
          path.lineTo(pt.dx, pt.dy);
        }

        // Casing Shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..strokeWidth = (poly.width.toDouble() + 4.0).clamp(6.0, 14.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, shadowPaint);

        // Active Route Line
        final routePaint = Paint()
          ..color = poly.color
          ..strokeWidth = (poly.width.toDouble()).clamp(4.0, 10.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, routePaint);

        // Core Highlight Line
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, corePaint);
      }
    } else if (storePos != null && customerPos != null) {
      // Direct Line fallback if polylines still fetching
      final start = _latLngToScreen(storePos!);
      final end = _latLngToScreen(customerPos!);
      final directPath = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);

      final directPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(directPath, directPaint);
    }

    // 2. Draw Store Location Pin (Real GPS coordinates)
    if (storePos != null) {
      final storeOffset = _latLngToScreen(storePos!);
      _drawMarkerPin(canvas, storeOffset, const Color(0xFFEA580C), Icons.storefront_rounded, storeName.isNotEmpty ? storeName : 'Restaurant');
    }

    // 3. Draw Customer Location Pin & Geofence Drop-Off Zone (Real GPS coordinates)
    if (customerPos != null) {
      final customerOffset = _latLngToScreen(customerPos!);

      // Translucent Drop-Off Geofence Halo
      canvas.drawCircle(
        customerOffset,
        34,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        customerOffset,
        34,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      _drawMarkerPin(canvas, customerOffset, const Color(0xFF10B981), Icons.home_rounded, customerName.isNotEmpty ? customerName : 'Delivery Address');
    }

    // 4. Draw Real-time Live Driver Vehicle (Real GPS coordinates + Animated Heading)
    if (driverPos != null) {
      final driverOffset = _latLngToScreen(driverPos!);
      _drawRealisticDeliveryVehicle(canvas, driverOffset, driverHeading);
    } else if (storePos != null) {
      final storeOffset = _latLngToScreen(storePos!);
      _drawDispatchPulse(canvas, storeOffset);
    }

    // 5. Draw Device Current GPS Location Marker if available
    if (deviceGpsPos != null && customerPos == null) {
      final gpsOffset = _latLngToScreen(deviceGpsPos!);
      _drawDeviceGpsPulse(canvas, gpsOffset);
    }
  }

  void _drawDeviceGpsPulse(Canvas canvas, Offset pos) {
    // Outer Ripple
    canvas.drawCircle(
      pos,
      22,
      Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    // Outer Ring
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Inner Solid Circle
    canvas.drawCircle(pos, 8, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 5, Paint()..color = const Color(0xFF0284C7));
  }

  void _drawRealisticDeliveryVehicle(Canvas canvas, Offset pos, double heading) {
    // Radar Pulse Halo
    final pulsePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 24, pulsePaint);

    final pulseRing = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pos, 18, pulseRing);

    final isBike = MapMarkerService.isTwoWheeler(vehicleType);
    if (isBike) {
      _drawRealisticBike(canvas, pos, heading * (math.pi / 180));
    } else {
      _drawRealisticCar(canvas, pos, heading * (math.pi / 180));
    }
  }

  void _drawRealisticCar(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Car Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -14, 16, 28), const Radius.circular(5)),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Car Body (Yellow Cab / Uber Gold)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-7, -13, 14, 26), const Radius.circular(4)),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Windshield (Dark Blue-Grey)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -6, 10, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Roof Center
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -1, 8, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFF59E0B),
    );

    // Headlights
    canvas.drawCircle(const Offset(-4, -12), 1.5, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(const Offset(4, -12), 1.5, Paint()..color = const Color(0xFFFEF08A));

    canvas.restore();
  }

  void _drawRealisticBike(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Shadow
    canvas.drawOval(
      const Rect.fromLTWH(-6, -11, 12, 22),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Bike Body (Yellow / Red Delivery Bike)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -9, 8, 18), const Radius.circular(3)),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Rider Helmet (Dark Grey & Red Accent)
    canvas.drawCircle(const Offset(0, -1), 4.0, Paint()..color = const Color(0xFF1F2937));
    canvas.drawCircle(const Offset(0, -1), 2.5, Paint()..color = const Color(0xFFE52121));

    // Handlebar
    canvas.drawLine(
      const Offset(-5, -6),
      const Offset(5, -6),
      Paint()
        ..color = const Color(0xFF111827)
        ..strokeWidth = 2,
    );

    // Rear Delivery Bag (Red Swiggy/Zomato style thermal box)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4.5, 4, 9, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE52121),
    );

    canvas.restore();
  }

  void _drawDispatchPulse(Canvas canvas, Offset pos) {
    canvas.drawCircle(
      pos,
      20,
      Paint()
        ..color = const Color(0xFFEA580C).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawMarkerPin(Canvas canvas, Offset pos, Color color, IconData icon, String label) {
    // Pin Shadow
    canvas.drawCircle(Offset(pos.dx, pos.dy + 3), 13, Paint()..color = Colors.black.withValues(alpha: 0.25));

    // Outer Pin Circle
    canvas.drawCircle(pos, 14, Paint()..color = color);
    canvas.drawCircle(pos, 11, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 7, Paint()..color = color);

    // Label Badge
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeOffset = Offset(pos.dx - (textPainter.width / 2), pos.dy + 18);
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeOffset.dx - 6, badgeOffset.dy - 2, textPainter.width + 12, textPainter.height + 4),
      const Radius.circular(6),
    );

    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
    textPainter.paint(canvas, badgeOffset);
  }

  @override
  bool shouldRepaint(covariant _RealTileMapOverlayPainter oldDelegate) {
    return oldDelegate.minX != minX ||
        oldDelegate.minY != minY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.roadPolylines != roadPolylines ||
        oldDelegate.driverPos != driverPos ||
        oldDelegate.driverHeading != driverHeading ||
        oldDelegate.vehicleType != vehicleType ||
        oldDelegate.storePos != storePos ||
        oldDelegate.customerPos != customerPos ||
        oldDelegate.trafficEnabled != trafficEnabled ||
        oldDelegate.isSatellite != isSatellite ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

class _RainParticleOverlayPainter extends CustomPainter {
  final double progress;
  static final math.Random _random = math.Random(42);

  _RainParticleOverlayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.38)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    const dropCount = 45;
    for (int i = 0; i < dropCount; i++) {
      final xOffset = (_random.nextDouble() * size.width);
      final speedFactor = 0.85 + (_random.nextDouble() * 0.3);
      final yPos = ((progress * speedFactor + (i / dropCount)) % 1.0) * (size.height + 40) - 20;

      // Draw subtle slanted rain streak
      canvas.drawLine(
        Offset(xOffset, yPos),
        Offset(xOffset - 4, yPos + 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainParticleOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
