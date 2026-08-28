import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_google_map_bloc/app_google_map_bloc.dart';
import 'app_google_map_bloc/app_google_map_event.dart';
import 'app_google_map_bloc/app_google_map_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/map_marker_service.dart';
import '../services/route_polyline_service.dart';
import '../services/realtime_vehicle_route_navigator.dart';
import '../services/google_maps_loader.dart';
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
  final bool showProgressCard;
  final bool autoFitEntireRoute;

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
    this.autoFitEntireRoute = true,
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
    this.showProgressCard = true,
  });

  @override
  State<AppGoogleMapView> createState() => _AppGoogleMapViewState();
}

class _AppGoogleMapViewState extends State<AppGoogleMapView>
    with TickerProviderStateMixin {
  late AppGoogleMapBloc _mapBloc;
  GoogleMapController? _mapController;

  // Fallback Interactive Navigation State
  double _canvasZoom = 1.0;
  double _tileZoom = 15.0;
  Offset _canvasPanOffset = Offset.zero;

  // Custom BitmapDescriptors
  bool _isDraggingMap = false;
  BitmapDescriptor? _vehicleIcon;
  BitmapDescriptor? _storeIcon;
  BitmapDescriptor? _customerIcon;

  // Real Road Polylines

  // Animated Marker Position State
  late AnimationController _animController;
  late AnimationController _rainAnimController;
  LatLng? _previousDriverPos;
  LatLng? _currentDriverPos;
  double _animatedLat = 11.4299713;
  double _animatedLng = 77.6759418;
  double _animatedHeading = 0.0;

  // Realtime Road Navigation Telemetry State
  StreamSubscription<VehicleTelemetry>? _roadNavSubscription;
  double _liveSpeed = 0.0;
  double? _liveDistanceKm;
  String? _liveEtaText;
  double _liveProgressRatio = 0.0;
  bool _isArrivedAtDestination = false;
  String? _liveStatusMessage;

  @override
  void initState() {
    super.initState();

    _mapBloc = AppGoogleMapBloc()
      ..add(MapInitializeEvent(
        driverLocation: widget.driverLocation,
        storeLocation: widget.storeLocation,
        customerLocation: widget.customerLocation,
        driverHeading: widget.driverHeading,
        initialZoom: widget.initialZoom,
        autoFollowDriver: widget.autoFollowDriver,
      ));

    _currentDriverPos = widget.driverLocation ?? widget.storeLocation ?? widget.customerLocation;
    _previousDriverPos = _currentDriverPos;
    if (_currentDriverPos != null) {
      _animatedLat = _currentDriverPos!.latitude;
      _animatedLng = _currentDriverPos!.longitude;
    }
    _animatedHeading = widget.driverHeading;
    _tileZoom = widget.initialZoom;

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
    _startRealtimeRoadNavigation();

    if (kIsWeb) {
      registerGoogleMapsAuthFailureListener(() {
        if (mounted) {
          _mapBloc.add(WebFallbackTriggeredEvent());
        }
      });

      ensureGoogleMapsJsLoaded().then((ready) {
        if (ready && mounted && !_mapBloc.state.forceFallbackCanvas) {

        }
      });
    }

    if (widget.autoFitEntireRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fitAllRouteBounds();
        }
      });
    }
  }

  Future<void> _loadCustomIcons() async {
    try {
      final vehicleIcon = await MapMarkerService.instance.getVehicleMarker(
        vehicleType: widget.vehicleType,
        heading: 0.0,
        size: 130.0,
      );
      final storeIcon = await MapMarkerService.instance.getStoreMarker(
        storeName: widget.storeName.isNotEmpty ? widget.storeName : 'Restaurant',
        size: 120.0,
      );
      final customerIcon = await MapMarkerService.instance.getCustomerMarker(
        customerName: widget.customerName.isNotEmpty ? widget.customerName : 'Customer',
        size: 120.0,
      );

      if (mounted) {
        setState(() {
          _vehicleIcon = vehicleIcon;
          _storeIcon = storeIcon;
          _customerIcon = customerIcon;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom map markers: $e');
    }
  }

  void _toggleAutoFollow() {
    _mapBloc.add(ToggleAutoFollowEvent());
  }

  Future<void> _openExternalGoogleMaps() async {
    if (widget.onOpenExternalNavigation != null) {
      widget.onOpenExternalNavigation!();
      return;
    }
    final dest = widget.customerLocation ?? const LatLng(11.4555052, 77.6873137);
    LatLng origin = widget.storeLocation ?? const LatLng(11.4299713, 77.6759418);
    if (widget.driverLocation != null &&
        ((widget.driverLocation!.latitude - dest.latitude).abs() > 0.0001 ||
            (widget.driverLocation!.longitude - dest.longitude).abs() > 0.0001)) {
      origin = widget.driverLocation!;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&travelmode=driving',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
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

      if (_mapBloc.state.autoFollowDriver && _mapController != null) {
        final is3D = _mapBloc.state.is3DTiltMode;
        final targetZoom = is3D ? math.max(_tileZoom, 17.0) : _tileZoom;
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_animatedLat, _animatedLng),
              zoom: targetZoom,
              tilt: is3D ? 55.0 : 0.0,
              bearing: is3D ? _animatedHeading : 0.0,
            ),
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
      _mapBloc.add(MapDataUpdatedEvent(
        driverLocation: widget.driverLocation,
        storeLocation: widget.storeLocation,
        customerLocation: widget.customerLocation,
        driverHeading: widget.driverHeading,
        isPickedUp: widget.isPickedUp,
        forceRouteRefetch: true,
      ));
      _startRealtimeRoadNavigation();
      if (widget.autoFitEntireRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fitAllRouteBounds();
          }
        });
      }
    }

    if (widget.driverLocation != null &&
        widget.driverLocation != oldWidget.driverLocation) {
      final targetDriverPos = widget.driverLocation!;
      final targetHeading = widget.driverHeading;

      _previousDriverPos = LatLng(_animatedLat, _animatedLng);
      _currentDriverPos = targetDriverPos;
      _animatedHeading = targetHeading;
      _animController.forward(from: 0.0);

      if (widget.autoFollowDriver && _mapController != null) {
        final is3D = _mapBloc.state.is3DTiltMode;
        final targetZoom = is3D ? math.max(_tileZoom, 17.0) : _tileZoom;
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: targetDriverPos,
              zoom: targetZoom,
              tilt: is3D ? 55.0 : 0.0,
              bearing: is3D ? targetHeading : 0.0,
            ),
          ),
        );
      }
    }
  }

  void _startRealtimeRoadNavigation() {
    const defaultZoloLocation = LatLng(11.4299713, 77.6759418);
    const defaultPartnerStartLocation = LatLng(11.4555052, 77.6873137);

    final LatLng destPos = widget.isPickedUp
        ? (widget.customerLocation ?? defaultPartnerStartLocation)
        : (widget.storeLocation ?? defaultZoloLocation);

    LatLng startPos;
    if (widget.isPickedUp) {
      startPos = widget.storeLocation ?? defaultZoloLocation;
    } else {
      startPos = widget.driverLocation ?? _currentDriverPos ?? defaultPartnerStartLocation;
    }

    final double distToDest = RoutePolylineService.instance.haversineDistanceMeters(startPos, destPos);
    if (distToDest < 100.0) {
      if (widget.isPickedUp) {
        startPos = defaultZoloLocation;
      } else {
        startPos = defaultPartnerStartLocation;
      }
    }

    final destName = widget.isPickedUp
        ? (widget.customerName.isNotEmpty ? widget.customerName : 'Customer')
        : (widget.storeName.isNotEmpty ? widget.storeName : "Zolo Family Restaurant - Fried Chicken's / Burgers / Pizza's");

    _roadNavSubscription?.cancel();
    _roadNavSubscription = RealtimeVehicleRouteNavigator.instance.startNavigation(
      start: startPos,
      destination: destPos,
      destinationName: destName,
      cruisingSpeedKmh: 80.0,
      simulationSpeedMultiplier: 2.5,
      tickInterval: const Duration(milliseconds: 40),
    ).listen((telemetry) {
      if (!mounted) return;

      setState(() {
        _animatedLat = telemetry.currentPosition.latitude;
        _animatedLng = telemetry.currentPosition.longitude;
        _animatedHeading = telemetry.heading;
        _liveSpeed = telemetry.speedKmh;
        _liveDistanceKm = telemetry.remainingDistanceKm;
        _liveEtaText = telemetry.etaMinutes > 0 ? '~${telemetry.etaMinutes} mins' : 'Arriving now';
        _liveProgressRatio = telemetry.progressRatio;
        _isArrivedAtDestination = telemetry.isArrived;
        _liveStatusMessage = telemetry.statusMessage;
        _currentDriverPos = telemetry.currentPosition;
      });

      if (!_isDraggingMap && _mapBloc.state.autoFollowDriver && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: telemetry.currentPosition,
              zoom: _tileZoom,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _roadNavSubscription?.cancel();
    _roadNavSubscription = null;
    if (kIsWeb) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _rainAnimController.dispose();
    _animController.dispose();
    _mapController?.dispose();
    _mapBloc.close();
    super.dispose();
  }

  bool _isValidCoord(LatLng? pos) {
    if (pos == null) return false;
    return pos.latitude.abs() > 0.001 || pos.longitude.abs() > 0.001;
  }

  LatLng get _initialCenter {
    if (_isValidCoord(widget.driverLocation)) return widget.driverLocation!;
    if (_isValidCoord(widget.customerLocation)) return widget.customerLocation!;
    if (_isValidCoord(widget.storeLocation)) return widget.storeLocation!;
    if (_isValidCoord(_mapBloc.state.deviceGpsLocation)) return _mapBloc.state.deviceGpsLocation!;
    return const LatLng(11.4427872, 77.6760544); // Exact Center from Google Maps Link
  }

  LatLng get _effectiveCenter {
    if (_isValidCoord(widget.storeLocation) && _isValidCoord(widget.driverLocation)) {
      return LatLng(
        (widget.storeLocation!.latitude + widget.driverLocation!.latitude) / 2,
        (widget.storeLocation!.longitude + widget.driverLocation!.longitude) / 2,
      );
    }
    if (_isValidCoord(widget.driverLocation)) return widget.driverLocation!;
    if (_isValidCoord(widget.storeLocation) && _isValidCoord(widget.customerLocation)) {
      return LatLng(
        (widget.storeLocation!.latitude + widget.customerLocation!.latitude) / 2,
        (widget.storeLocation!.longitude + widget.customerLocation!.longitude) / 2,
      );
    }
    if (_isValidCoord(widget.customerLocation)) return widget.customerLocation!;
    if (_isValidCoord(widget.storeLocation)) return widget.storeLocation!;
    if (_isValidCoord(_mapBloc.state.deviceGpsLocation)) return _mapBloc.state.deviceGpsLocation!;
    return const LatLng(11.4427872, 77.6760544); // Exact Center from Google Maps Link
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

    // 4. Animated Driver / Courier Marker
    if (widget.driverLocation != null || _previousDriverPos != null || _currentDriverPos != null) {
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
    final Set<Polyline> polylines = Set.from(_mapBloc.state.roadPolylines);

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
    _mapBloc.add(MapInitializeEvent(driverLocation: widget.driverLocation, storeLocation: widget.storeLocation, customerLocation: widget.customerLocation));

    // 2. Center priority: live device GPS -> driver location -> customer location -> store location
    final target = _mapBloc.state.deviceGpsLocation ?? widget.driverLocation ?? widget.customerLocation ?? widget.storeLocation;
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
    final points = <LatLng>[
      if (widget.storeLocation != null && _isValidCoord(widget.storeLocation)) widget.storeLocation!,
      if (widget.driverLocation != null && _isValidCoord(widget.driverLocation)) widget.driverLocation!,
      if (widget.customerLocation != null && _isValidCoord(widget.customerLocation)) widget.customerLocation!,
      if (_mapBloc.state.deviceGpsLocation != null && _isValidCoord(_mapBloc.state.deviceGpsLocation)) _mapBloc.state.deviceGpsLocation!,
      if (widget.additionalMarkers != null)
        for (final m in widget.additionalMarkers!)
          if (_isValidCoord(m.position)) m.position,
    ];
    if (points.isEmpty) return;

    final bounds = RoutePolylineService.instance.computeBounds(points);
    final double latSpan = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
    final double lngSpan = (bounds.northeast.longitude - bounds.southwest.longitude).abs();
    final double maxSpan = math.max(latSpan, lngSpan);

    double optimalZoom = 15.0;
    if (maxSpan > 0.5) {
      optimalZoom = 9.5;
    } else if (maxSpan > 0.2) {
      optimalZoom = 11.0;
    } else if (maxSpan > 0.1) {
      optimalZoom = 12.5;
    } else if (maxSpan > 0.05) {
      optimalZoom = 13.5;
    } else if (maxSpan > 0.02) {
      optimalZoom = 14.5;
    } else if (maxSpan > 0.008) {
      optimalZoom = 15.0;
    } else {
      optimalZoom = 15.8;
    }

    setState(() {
      _canvasZoom = 1.0;
      _canvasPanOffset = Offset.zero;
      _tileZoom = optimalZoom;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _toggleMapType() {
    _mapBloc.add(ToggleMapTypeEvent());
  }

  void _toggleTraffic() {
    _mapBloc.add(ToggleTrafficEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapBloc,
      child: BlocBuilder<AppGoogleMapBloc, AppGoogleMapState>(
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppGoogleMapState state) {
    final bool isNativeDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.linux ||
         defaultTargetPlatform == TargetPlatform.macOS);

    final bool shouldUseFallback = isNativeDesktop ||
        (kIsWeb && !isGoogleMapsJsReady()) ||
        _mapBloc.state.forceFallbackCanvas;

    if (shouldUseFallback) {
      return _buildFallbackCanvasView(context);
    }

    return Stack(
      children: [
        Focus(
          canRequestFocus: false,
          descendantsAreFocusable: false,
          child: GoogleMap(
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
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            onCameraMoveStarted: () {
              _isDraggingMap = true;
            },
            onCameraIdle: () {
              _isDraggingMap = false;
            },
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
            mapType: _mapBloc.state.mapType,
            trafficEnabled: _mapBloc.state.trafficEnabled,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            padding: widget.padding,
          ),
        ),
        if (widget.isRaining && _mapBloc.state.showWeatherOverlay)
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
        if (state.currentManeuverStep != null)
          _buildTurnByTurnManeuverHud(state)
        else
          _buildLiveProgressAndEtaChip(),
        if (state.isRouteLoading) _buildRouteLoadingBadge(),
        if (widget.isRaining && _mapBloc.state.showWeatherOverlay) _buildWeatherSafetyBanner(),
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

  IconData _getManeuverIcon(RouteManeuver maneuver) {
    switch (maneuver) {
      case RouteManeuver.turnLeft:
        return Icons.turn_left_rounded;
      case RouteManeuver.turnRight:
        return Icons.turn_right_rounded;
      case RouteManeuver.turnSlightLeft:
        return Icons.turn_slight_left_rounded;
      case RouteManeuver.turnSlightRight:
        return Icons.turn_slight_right_rounded;
      case RouteManeuver.turnSharpLeft:
        return Icons.turn_sharp_left_rounded;
      case RouteManeuver.turnSharpRight:
        return Icons.turn_sharp_right_rounded;
      case RouteManeuver.uturn:
        return Icons.u_turn_left_rounded;
      case RouteManeuver.roundabout:
        return Icons.roundabout_left_rounded;
      case RouteManeuver.arrive:
        return Icons.place_rounded;
      case RouteManeuver.depart:
        return Icons.navigation_rounded;
      case RouteManeuver.straight:
      default:
        return Icons.straight_rounded;
    }
  }

  Widget _buildTurnByTurnManeuverHud(AppGoogleMapState state) {
    final step = state.currentManeuverStep;
    if (step == null) return const SizedBox.shrink();

    final distStr = state.distanceToNextTurnMeters > 0
        ? (state.distanceToNextTurnMeters >= 1000
            ? '${(state.distanceToNextTurnMeters / 1000).toStringAsFixed(1)} km'
            : '${state.distanceToNextTurnMeters.round()} m')
        : step.distanceText;

    return Positioned(
      top: 12,
      left: 12,
      right: 70,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getManeuverIcon(step.maneuver),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (distStr.isNotEmpty)
                      Text(
                        distStr,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    Text(
                      step.instruction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  state.isVoiceGuidanceEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: state.isVoiceGuidanceEnabled
                      ? const Color(0xFF38BDF8)
                      : Colors.white54,
                  size: 22,
                ),
                onPressed: () {
                  _mapBloc.add(ToggleVoiceGuidanceEvent());
                },
                tooltip: state.isVoiceGuidanceEnabled
                    ? 'Mute Voice'
                    : 'Unmute Voice',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteLoadingBadge() {
    return Positioned(
      top: 75,
      left: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Fetching live real road...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveProgressAndEtaChip() {
    if (!widget.showProgressCard) {
      return const SizedBox.shrink();
    }
    final isBike = MapMarkerService.isTwoWheeler(widget.vehicleType);
    final effectiveDist = _liveDistanceKm ?? widget.distanceKm;
    final speed = _liveSpeed > 0 ? _liveSpeed : (widget.driverSpeed ?? 0.0);
    final progress = (_liveProgressRatio > 0 ? _liveProgressRatio : widget.progressRatio).clamp(0.0, 1.0);
    final isArrived = _isArrivedAtDestination || widget.isArrivingSoon || (effectiveDist != null && effectiveDist <= 0.02);

    final String distStr;
    if (effectiveDist != null) {
      distStr = effectiveDist < 0.03
          ? '0m'
          : (effectiveDist < 1.0
              ? '${(effectiveDist * 1000).round()}m'
              : '${effectiveDist.toStringAsFixed(1)}km');
    } else {
      distStr = '';
    }

    final String titleText;
    final String subtitleText;
    if (isArrived) {
      titleText = '⚡ Arrived at ${widget.storeName.isNotEmpty ? widget.storeName : "Destination"}!';
      subtitleText = 'Vehicle stopped at destination • 0.0 km';
    } else {
      final destLabel = widget.storeName.isNotEmpty ? widget.storeName : 'Zolo Family Restaurant';
      titleText = '🛵 Heading to $destLabel';
      final etaStr = _liveEtaText ?? widget.etaText ?? (effectiveDist != null ? '~${((effectiveDist / 35.0) * 60).clamp(1, 45).round()} mins' : 'En route');
      subtitleText = distStr.isNotEmpty ? '$distStr away • $etaStr' : etaStr;
    }

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
              color: isArrived
                  ? const Color(0xFF10B981)
                  : (widget.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: isArrived ? 1.5 : 1.0,
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
                      color: (isArrived ? const Color(0xFF10B981) : const Color(0xFFE52121)).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                      size: 16,
                      color: isArrived ? const Color(0xFF10B981) : const Color(0xFFE52121),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titleText,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isArrived || speed <= 2 ? const Color(0xFFEA580C) : const Color(0xFF10B981)).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isArrived || speed <= 2 ? const Color(0xFFEA580C) : const Color(0xFF10B981)).withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (speed > 2 && !isArrived) const Icon(Icons.speed_rounded, size: 11, color: Color(0xFF10B981)),
                          if (speed > 2 && !isArrived) const SizedBox(width: 2),
                          Text(
                            isArrived ? '🛑 Arrived' : (speed <= 2 ? '🛑 Idle' : '${speed.round()} km/h'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isArrived || speed <= 2 ? const Color(0xFFEA580C) : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (distStr.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      flex: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          distStr,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitleText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0.0, end: progress),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 4.5,
                      backgroundColor: widget.isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isArrived
                            ? const Color(0xFF10B981)
                            : (progress > 0.8 ? const Color(0xFF10B981) : const Color(0xFFE52121)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapOverlayControls() {
    final isSatellite = _mapBloc.state.mapType == MapType.satellite || _mapBloc.state.mapType == MapType.hybrid;

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
                Icons.crop_free_rounded,
                _fitAllRouteBounds,
                tooltip: 'Fit Route to Screen (4-Corner View)',
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                _mapBloc.state.autoFollowDriver ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                _toggleAutoFollow,
                tooltip: _mapBloc.state.autoFollowDriver ? 'Auto-Follow: ON' : 'Auto-Follow: OFF',
                color: _mapBloc.state.autoFollowDriver ? const Color(0xFF10B981) : Colors.black87,
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
                isSatellite ? Icons.satellite_alt_rounded : Icons.layers_outlined,
                _toggleMapType,
                tooltip: isSatellite ? 'Satellite Layer Active' : 'Switch to Satellite View',
                color: isSatellite ? const Color(0xFF2563EB) : (widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                _mapBloc.state.trafficEnabled ? Icons.traffic_rounded : Icons.traffic_outlined,
                _toggleTraffic,
                tooltip: 'Live Traffic Flow',
                color: _mapBloc.state.trafficEnabled ? const Color(0xFFEA580C) : (widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
              if (widget.onToggleFullScreen != null) ...[
                const SizedBox(height: 5),
                _mapIconButton(
                  widget.isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  widget.onToggleFullScreen!,
                  tooltip: widget.isFullScreen ? 'Exit Full Screen (Half Screen View)' : 'Expand to Full Screen View',
                  color: widget.isFullScreen ? const Color(0xFFE11D48) : const Color(0xFF0284C7),
                ),
              ],
              if (widget.isRaining) ...[
                const SizedBox(height: 5),
                _mapIconButton(
                  _mapBloc.state.showWeatherOverlay ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                  _toggleWeatherLayer,
                  tooltip: _mapBloc.state.showWeatherOverlay ? 'Weather Alert: ON' : 'Weather Alert: OFF',
                  color: _mapBloc.state.showWeatherOverlay ? const Color(0xFF0284C7) : (widget.isDarkMode ? Colors.white70 : Colors.black87),
                ),
              ],
              const SizedBox(height: 5),
              _mapIconButton(
                _mapBloc.state.isVoiceGuidanceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                _toggleVoiceGuidance,
                tooltip: _mapBloc.state.isVoiceGuidanceEnabled ? 'Voice Guidance: ON' : 'Voice Guidance: OFF',
                color: _mapBloc.state.isVoiceGuidanceEnabled ? const Color(0xFF0284C7) : (widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 5),
              _mapIconButton(
                _mapBloc.state.is3DTiltMode ? Icons.view_in_ar_rounded : Icons.view_in_ar_outlined,
                _toggle3DTiltMode,
                tooltip: _mapBloc.state.is3DTiltMode ? '3D Navigation View: ON' : '3D Navigation View: OFF',
                color: _mapBloc.state.is3DTiltMode ? const Color(0xFF8B5CF6) : (widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleVoiceGuidance() {
    _mapBloc.add(ToggleVoiceGuidanceEvent());
  }

  void _toggle3DTiltMode() {
    _mapBloc.add(Toggle3DTiltModeEvent());
    final is3D = !_mapBloc.state.is3DTiltMode;
    final currentPos = _currentDriverPos ?? _initialCenter;
    final targetZoom = is3D ? math.max(_tileZoom, 17.0) : _tileZoom;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPos,
          zoom: targetZoom,
          tilt: is3D ? 55.0 : 0.0,
          bearing: is3D ? _animatedHeading : 0.0,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleWeatherLayer() {
    _mapBloc.add(ToggleWeatherEvent());
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
    final bool isDark = widget.isDarkMode;
    return Tooltip(
      message: tooltip ?? '',
      waitDuration: const Duration(milliseconds: 250),
      child: Material(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 19, color: color),
          ),
        ),
      ),
    );
  }

  /// High-definition interactive real-world map tile engine with OpenStreetMap / CartoDB / Esri Satellite
  Widget _buildFallbackCanvasView(BuildContext context) {
    final isSatellite = _mapBloc.state.mapType == MapType.satellite || _mapBloc.state.mapType == MapType.hybrid;

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

            final subdomains = ['a', 'b', 'c', 'd'];
            final sub = subdomains[(c + r).abs() % subdomains.length];

            final String tileUrl;
            final String fallbackUrl;
            if (isSatellite) {
              tileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$z/$r/$normCol';
              fallbackUrl = 'https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/$z/$r/$normCol';
            } else if (widget.isDarkMode) {
              tileUrl = 'https://$sub.basemaps.cartocdn.com/dark_all/$z/$normCol/$r.png';
              fallbackUrl = 'https://tile.openstreetmap.org/$z/$normCol/$r.png';
            } else {
              tileUrl = 'https://$sub.basemaps.cartocdn.com/rastertiles/voyager/$z/$normCol/$r.png';
              fallbackUrl = 'https://tile.openstreetmap.org/$z/$normCol/$r.png';
            }

            tileWidgets.add(
              Positioned(
                key: ValueKey('tile_pos_${tileUrl}_${normCol}_$r'),
                left: tileLeft,
                top: tileTop,
                width: 256,
                height: 256,
                child: CachedMapTile(
                  key: ValueKey('tile_$tileUrl'),
                  tileUrl: tileUrl,
                  fallbackTileUrl: fallbackUrl,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            );
          }
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF131E29) : const Color(0xFFE2E8F0),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    setState(() {
                      _isDraggingMap = true;
                    });
                  },
                  onPointerMove: (event) {
                    if (event.delta != Offset.zero) {
                      setState(() {
                        _canvasPanOffset += event.delta;
                      });
                    }
                  },
                  onPointerUp: (event) {
                    setState(() {
                      _isDraggingMap = false;
                    });
                  },
                  onPointerCancel: (event) {
                    setState(() {
                      _isDraggingMap = false;
                    });
                  },
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      if (pointerSignal.scrollDelta.dy < 0) {
                        _zoomIn();
                      } else if (pointerSignal.scrollDelta.dy > 0) {
                        _zoomOut();
                      }
                    }
                  },
                  child: MouseRegion(
                    cursor: _isDraggingMap ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onScaleStart: (details) {
                        setState(() {
                          _isDraggingMap = true;
                        });
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          if (details.scale != 1.0) {
                            _tileZoom = (_tileZoom + (details.scale - 1.0) * 0.4).clamp(3.0, 19.0);
                          }
                          if (details.focalPointDelta != Offset.zero) {
                            _canvasPanOffset += details.focalPointDelta;
                          }
                        });
                      },
                      onScaleEnd: (details) {
                        setState(() {
                          _isDraggingMap = false;
                        });
                      },
                      onTapUp: (details) => _handleCanvasPinTap(context, details.localPosition, minX, minY, zoom),
                      onSecondaryTapUp: (details) => _handleCanvasPinTap(context, details.localPosition, minX, minY, zoom),
                      child: Transform(
                        transform: _mapBloc.state.is3DTiltMode
                            ? (Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateX(-0.48))
                            : Matrix4.identity(),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                            Container(
                              width: width,
                              height: height,
                              color: widget.isDarkMode ? const Color(0xFF131E29) : const Color(0xFFE2E8F0),
                            ),
                            ...tileWidgets,
                            Positioned.fill(
                              child: CustomPaint(
                                size: Size(width, height),
                                painter: _RealTileMapOverlayPainter(
                                  minX: minX,
                                  minY: minY,
                                  zoom: zoom,
                                  roadPolylines: _mapBloc.state.roadPolylines,
                                  driverPos: (widget.driverLocation != null || _currentDriverPos != null)
                                      ? LatLng(_animatedLat, _animatedLng)
                                      : null,
                                  driverHeading: _animatedHeading,
                                  vehicleType: widget.vehicleType,
                                  storePos: widget.storeLocation,
                                  storeName: widget.storeName,
                                  customerPos: widget.customerLocation,
                                  customerName: widget.customerName,
                                  additionalMarkers: widget.additionalMarkers,
                                  trafficEnabled: _mapBloc.state.trafficEnabled,
                                  isSatellite: isSatellite,
                                  isDarkMode: widget.isDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isRaining && _mapBloc.state.showWeatherOverlay)
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
              if (widget.isRaining && _mapBloc.state.showWeatherOverlay) _buildWeatherSafetyBanner(),
              if (widget.showControls) _buildMapOverlayControls(),
              Positioned(
                left: 12,
                right: 72,
                bottom: widget.bottomBadgeOffset,
                child: Align(
                  alignment: Alignment.bottomLeft,
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
                        Flexible(
                          child: Text(
                            isSatellite
                                ? 'Satellite Imagery · Real-Time Hybrid'
                                : 'Live Real-Time Map (${MapMarkerService.isTwoWheeler(widget.vehicleType) ? "2-Wheeler" : "4-Wheeler"})',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
  final Set<Marker>? additionalMarkers;
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
    this.additionalMarkers,
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
    // 1. Draw Real Road Route Polylines from OSRM / Directions backend if present
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
          ..color = Colors.black.withValues(alpha: 0.35)
          ..strokeWidth = (poly.width.toDouble() + 5.0).clamp(7.0, 16.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, shadowPaint);

        // Active Route Line
        final routePaint = Paint()
          ..color = poly.color
          ..strokeWidth = (poly.width.toDouble() + 1.0).clamp(5.0, 12.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, routePaint);

        // Core Highlight Line
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, corePaint);
      }
    }

    // 2. Draw Demand Zones / Hotspots
    if (additionalMarkers != null && additionalMarkers!.isNotEmpty) {
      for (final marker in additionalMarkers!) {
        final pos = _latLngToScreen(marker.position);
        _drawDemandZonePin(
          canvas,
          pos,
          marker.infoWindow.title ?? 'Hotspot',
          marker.infoWindow.snippet ?? '',
        );
      }
    }

    // 3. Draw Store Location Pin (Real GPS coordinates)
    if (storePos != null) {
      final storeOffset = _latLngToScreen(storePos!);
      _drawMarkerPin(canvas, storeOffset, const Color(0xFFEA580C), Icons.storefront_rounded, storeName.isNotEmpty ? storeName : 'Restaurant', isAbove: true);
    }

    // 4. Draw Customer Location Pin (Real GPS coordinates)
    if (customerPos != null) {
      final customerOffset = _latLngToScreen(customerPos!);
      _drawMarkerPin(canvas, customerOffset, const Color(0xFF10B981), Icons.home_rounded, customerName.isNotEmpty ? customerName : 'Delivery Address');
    }

    // 5. Draw Real-time Live Driver Vehicle (Real GPS coordinates + Animated Heading)
    if (driverPos != null) {
      final driverOffset = _latLngToScreen(driverPos!);
      _drawRealisticDeliveryVehicle(canvas, driverOffset, driverHeading);
    } else if (storePos != null) {
      final storeOffset = _latLngToScreen(storePos!);
      _drawDispatchPulse(canvas, storeOffset);
    }
  }

  void _drawDemandZonePin(Canvas canvas, Offset pos, String title, String snippet) {
    // Pulsing aura
    canvas.drawCircle(
      pos,
      28,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pos,
      18,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner Pin
    canvas.drawCircle(pos, 12, Paint()..color = const Color(0xFFEA580C));
    canvas.drawCircle(pos, 9, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 6, Paint()..color = const Color(0xFFEA580C));

    final label = snippet.isNotEmpty ? '$title ($snippet)' : title;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeOffset = Offset(pos.dx - (textPainter.width / 2), pos.dy + 15);
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeOffset.dx - 5, badgeOffset.dy - 2, textPainter.width + 10, textPainter.height + 4),
      const Radius.circular(5),
    );

    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.90));
    textPainter.paint(canvas, badgeOffset);
  }



  void _drawRealisticDeliveryVehicle(Canvas canvas, Offset pos, double heading) {
    final isBike = MapMarkerService.isTwoWheeler(vehicleType);
    if (isBike) {
      _drawRealistic3DBike(canvas, pos, heading * (math.pi / 180));
    } else {
      _drawRealistic3DCar(canvas, pos, heading * (math.pi / 180));
    }

    // 3D Glassmorphic Live Partner Tag
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🛵 Partner (Live 3D)',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeOffset = Offset(pos.dx - (textPainter.width / 2), pos.dy + 20);
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeOffset.dx - 6, badgeOffset.dy - 3, textPainter.width + 12, textPainter.height + 6),
      const Radius.circular(6),
    );

    // 3D Tag Shadow & Glass Surface
    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 3));
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.94));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(60, 0),
          [const Color(0xFF38BDF8), const Color(0xFFE52121)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    textPainter.paint(canvas, badgeOffset);
  }

  void _drawRealistic3DCar(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // 1. Volumetric Dual Headlight Beam
    final Path carBeamPath = Path()
      ..moveTo(-7, -16)
      ..lineTo(-20, -52)
      ..lineTo(20, -52)
      ..lineTo(7, -16)
      ..close();

    final Paint beamPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -16),
        const Offset(0, -52),
        [
          const Color(0xFFFEF08A).withValues(alpha: 0.45),
          const Color(0xFF38BDF8).withValues(alpha: 0.1),
          Colors.transparent,
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawPath(carBeamPath, beamPaint);

    // 2. 3D Car Ground Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -17, 20, 34), const Radius.circular(7)),
      shadowPaint,
    );

    // 3. 3D Car Body (Metallic Uber/Zomato Crimson or Gold)
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-9, -16),
        const Offset(9, 16),
        [
          const Color(0xFFFBBF24),
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -16, 18, 32), const Radius.circular(6)),
      bodyPaint,
    );

    // 4. 3D Windshield & Windows (Tinted Glass)
    final Paint glassPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-7, -8),
        const Offset(7, 8),
        [
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
      );
    // Front Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-7, -8, 14, 7), const Radius.circular(2.5)),
      glassPaint,
    );
    // Rear Window
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6.5, 6, 13, 5), const Radius.circular(2)),
      glassPaint,
    );

    // 5. 3D Roof with Bevel
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -1, 12, 7), const Radius.circular(3)),
      Paint()..color = const Color(0xFFF59E0B),
    );

    // 6. Dual Xenon Headlights
    canvas.drawCircle(const Offset(-6, -15), 2.2, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(const Offset(6, -15), 2.2, Paint()..color = const Color(0xFFFFFFFF));

    // 7. Dual LED Taillights
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, 15, 4, 1.8), const Radius.circular(1)),
      Paint()..color = const Color(0xFFFF2222),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(4, 15, 4, 1.8), const Radius.circular(1)),
      Paint()..color = const Color(0xFFFF2222),
    );

    canvas.restore();
  }

  void _drawRealistic3DBike(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // 1. Dynamic 3D Volumetric Headlight Light Cone (Front Projection)
    final Path lightBeamPath = Path()
      ..moveTo(0, -12)
      ..lineTo(-18, -48)
      ..lineTo(18, -48)
      ..close();

    final Paint headlightBeamPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -12),
        const Offset(0, -48),
        [
          const Color(0xFFFEF08A).withValues(alpha: 0.45),
          const Color(0xFF38BDF8).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(lightBeamPath, headlightBeamPaint);

    // 2. Realistic 3D Ground Drop Shadow with Perspective Offset
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-7, -12, 14, 28), const Radius.circular(7)),
      shadowPaint,
    );

    // 3. 3D Bike Main Frame & Footboard
    final Paint chassisPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-6, 0),
        const Offset(6, 0),
        [
          const Color(0xFF1E293B),
          const Color(0xFF334155),
          const Color(0xFF0F172A),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-5.5, -10, 11, 22), const Radius.circular(5.5)),
      chassisPaint,
    );

    // 4. Sporty Aerodynamic Front Fairing / Fender (3D Red Gloss Shading)
    final Path frontFairingPath = Path()
      ..moveTo(0, -15)
      ..cubicTo(-6, -13, -6.5, -8, -5, -4)
      ..lineTo(5, -4)
      ..cubicTo(6.5, -8, 6, -13, 0, -15)
      ..close();

    final Paint fairingPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-6, -15),
        const Offset(6, -4),
        [
          const Color(0xFFFF5252),
          const Color(0xFFE52121),
          const Color(0xFF991B1B),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(frontFairingPath, fairingPaint);

    // Bevel highlight on fairing
    canvas.drawPath(
      frontFairingPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 5. Dual Xenon LED Headlights with Crystal Corona
    final Paint headlightGlow = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.solid, 2.0);
    canvas.drawCircle(const Offset(-2.5, -13), 2.2, headlightGlow);
    canvas.drawCircle(const Offset(2.5, -13), 2.2, headlightGlow);
    canvas.drawCircle(const Offset(-2.5, -13), 1.2, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(const Offset(2.5, -13), 1.2, Paint()..color = const Color(0xFF38BDF8));

    // 6. Handlebars & Ergonomic Chrome Mirrors
    final Paint handlebarPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-8, -7), const Offset(8, -7), handlebarPaint);

    // Grip Caps
    canvas.drawCircle(const Offset(-8, -7), 1.5, Paint()..color = const Color(0xFFE52121));
    canvas.drawCircle(const Offset(8, -7), 1.5, Paint()..color = const Color(0xFFE52121));

    // Chrome Mirrors with Reflection
    canvas.drawLine(
      const Offset(-5, -8),
      const Offset(-8.5, -11),
      Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2,
    );
    canvas.drawLine(
      const Offset(5, -8),
      const Offset(8.5, -11),
      Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-10.5, -13, 4, 3),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.9),
    );
    canvas.drawOval(
      const Rect.fromLTWH(6.5, -13, 4, 3),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.9),
    );

    // 7. 3D Rider Torso & Shoulders
    final Paint riderVestPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-7, -4),
        const Offset(7, 4),
        [
          const Color(0xFFDC2626),
          const Color(0xFFB91C1C),
          const Color(0xFF7F1D1D),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -5, 12, 10), const Radius.circular(4)),
      riderVestPaint,
    );

    // Silver Reflective Safety Straps on Rider's Back
    canvas.drawLine(
      const Offset(-4.5, -4),
      const Offset(-4.5, 4),
      Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.0,
    );
    canvas.drawLine(
      const Offset(4.5, -4),
      const Offset(4.5, 4),
      Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.0,
    );

    // 8. 3D Rider Helmet with Metallic Finish & Gradient Cyan Visor
    final Paint helmetPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(-1.5, -2),
        6.0,
        [
          const Color(0xFF475569),
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(const Offset(0, -1), 5.0, helmetPaint);

    // Glossy Highlight Ring on Helmet Top
    canvas.drawArc(
      const Rect.fromLTWH(-4, -5, 8, 8),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Aerodynamic Cyan Reflective Visor
    final Path visorPath = Path()
      ..moveTo(-3.5, -4)
      ..quadraticBezierTo(0, -5.5, 3.5, -4)
      ..lineTo(3.0, -3)
      ..quadraticBezierTo(0, -4.5, -3.0, -3)
      ..close();

    final Paint visorPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-3.5, -5),
        const Offset(3.5, -3),
        [
          const Color(0xFF0284C7),
          const Color(0xFF38BDF8),
          const Color(0xFFE0F2FE),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(visorPath, visorPaint);

    // 9. 3D Thermal Delivery Box (Isometric Perspective with Depth)
    final Paint boxShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6.5, 5, 13, 10), const Radius.circular(2.5)),
      boxShadow,
    );

    // Box Main Face (Vibrant Delivery Red)
    final Paint boxBodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-6, 5),
        const Offset(6, 15),
        [
          const Color(0xFFEF4444),
          const Color(0xFFDC2626),
          const Color(0xFF991B1B),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, 5, 12, 9.5), const Radius.circular(2.5)),
      boxBodyPaint,
    );

    // Box Top Lid Bevel Highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-5.5, 5.2, 11, 3.2), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFFCA5A5).withValues(alpha: 0.65),
    );

    // High-visibility Silver Reflective Center Band
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-6, 9.5, 12, 2.2), const Radius.circular(0.5)),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Delivery Icon on Box
    canvas.drawCircle(const Offset(0, 10.6), 1.2, Paint()..color = const Color(0xFFE52121));

    // 10. Glowing Ruby LED Taillight
    final Paint taillightGlow = Paint()
      ..color = const Color(0xFFFF2222)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.solid, 2.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-3.5, 14.5, 7, 2), const Radius.circular(1)),
      taillightGlow,
    );

    // Exhaust Pipe on Right Side with Chrome Tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(5.5, 6, 2.2, 7), const Radius.circular(1)),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawCircle(const Offset(6.6, 13), 1.0, Paint()..color = const Color(0xFFCBD5E1));

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

  void _drawMarkerPin(Canvas canvas, Offset pos, Color color, IconData icon, String label, {bool isAbove = false, bool isStore = false}) {
    if (label.isEmpty) return;

    final isStoreType = isStore || icon == Icons.storefront_rounded;
    final prefix = isStoreType ? '🏪 ' : '📍 ';
    final cleanLabel = label.length > 22 ? '${label.substring(0, 20)}..' : label;

    // 1. Ground Radiant Aura Halo
    final Paint auraPaint = Paint()
      ..color = (isStoreType ? const Color(0xFFEA580C) : const Color(0xFF10B981)).withValues(alpha: 0.22)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 5);
    canvas.drawCircle(pos, 22, auraPaint);

    // 2. 3D Beveled Teardrop Pin
    final Path pinPath = Path()
      ..addArc(Rect.fromCircle(center: Offset(pos.dx, pos.dy - 16), radius: 14), math.pi * 0.78, math.pi * 1.44)
      ..lineTo(pos.dx, pos.dy)
      ..close();

    final Paint pinPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(pos.dx - 14, pos.dy - 30),
        Offset(pos.dx + 14, pos.dy),
        isStoreType
            ? [const Color(0xFFFF6B00), const Color(0xFFEA580C), const Color(0xFFB91C1C)]
            : [const Color(0xFF34D399), const Color(0xFF10B981), const Color(0xFF047857)],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(pinPath, pinPaint);

    // Bevel Edge Rim
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Inner White Pearl Circle
    canvas.drawCircle(Offset(pos.dx, pos.dy - 16), 9.5, Paint()..color = Colors.white);

    // Inner Glyph Icon
    final TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 13,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(pos.dx - (iconPainter.width / 2), pos.dy - 16 - (iconPainter.height / 2)),
    );

    // Rating star for store
    if (isStoreType) {
      final starCenter = Offset(pos.dx + 10, pos.dy - 26);
      canvas.drawCircle(starCenter, 6, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawCircle(starCenter, 6, Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 0.8);
      final TextPainter starPainter = TextPainter(
        text: const TextSpan(
          text: '★',
          style: TextStyle(color: Color(0xFFD97706), fontSize: 7.5, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      starPainter.paint(canvas, Offset(starCenter.dx - (starPainter.width / 2), starCenter.dy - (starPainter.height / 2)));
    }

    // 3. Floating 3D Frosted Glassmorphic Name Card
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$prefix$cleanLabel',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double badgeY = isAbove ? (pos.dy - 44) : (pos.dy + 8);
    final badgeOffset = Offset(pos.dx - (textPainter.width / 2), badgeY);
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeOffset.dx - 8, badgeOffset.dy - 3, textPainter.width + 16, textPainter.height + 6),
      const Radius.circular(8),
    );

    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 3));
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.94));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(badgeOffset.dx, badgeOffset.dy),
          Offset(badgeOffset.dx + textPainter.width, badgeOffset.dy),
          isStoreType
              ? [const Color(0xFFF59E0B), const Color(0xFFEA580C)]
              : [const Color(0xFF34D399), const Color(0xFF10B981)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
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
