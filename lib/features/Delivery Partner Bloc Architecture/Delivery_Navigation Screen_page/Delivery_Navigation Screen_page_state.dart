import 'package:equatable/equatable.dart';

enum DeliveryNavigationStatus {
  initial,
  loading,
  loaded,
  navigating,
  empty,
  error,
}

enum DeliveryNavigationTrafficLevel { clear, moderate, heavy }

class DeliveryNavigationRoutePoint extends Equatable {
  final String label;
  final String address;
  final String iconKey;

  const DeliveryNavigationRoutePoint({
    required this.label,
    required this.address,
    required this.iconKey,
  });

  @override
  List<Object?> get props => [label, address, iconKey];
}

class DeliveryNavigationOrderSummary extends Equatable {
  final String orderId;
  final String pickupLabel;
  final String pickupAddress;
  final String dropLabel;
  final String dropAddress;
  final String customerName;
  final String customerPhone;
  final String status;

  const DeliveryNavigationOrderSummary({
    required this.orderId,
    required this.pickupLabel,
    required this.pickupAddress,
    required this.dropLabel,
    required this.dropAddress,
    required this.customerName,
    required this.customerPhone,
    required this.status,
  });

  @override
  List<Object?> get props => [
        orderId,
        pickupLabel,
        pickupAddress,
        dropLabel,
        dropAddress,
        customerName,
        customerPhone,
        status,
      ];
}

class DeliveryNavigationState extends Equatable {
  final DeliveryNavigationStatus status;
  final String? errorMessage;
  final String localeCode;
  final bool isOffline;
  final bool hasLocationPermission;
  final bool audioEnabled;
  final bool emergencyMode;
  final bool showMap;

  final DeliveryNavigationRoutePoint pickup;
  final DeliveryNavigationRoutePoint drop;
  final DeliveryNavigationOrderSummary order;

  final int etaMinutes;
  final double distanceKm;
  final String nextTurnInstruction;
  final double turnDistanceMeters;
  final DeliveryNavigationTrafficLevel trafficLevel;
  final double mapZoomLevel;

  const DeliveryNavigationState({
    this.status = DeliveryNavigationStatus.initial,
    this.errorMessage,
    this.localeCode = 'en',
    this.isOffline = false,
    this.hasLocationPermission = false,
    this.audioEnabled = false,
    this.emergencyMode = false,
    this.showMap = true,
    this.pickup = const DeliveryNavigationRoutePoint(
      label: 'Pickup',
      address: 'Reliance Digital Store, 23, Whites Road, Royapettah, Chennai',
      iconKey: 'pickup',
    ),
    this.drop = const DeliveryNavigationRoutePoint(
      label: 'Drop',
      address: '45, 3rd Cross Street, Anna Nagar West, Chennai',
      iconKey: 'drop',
    ),
    this.order = const DeliveryNavigationOrderSummary(
      orderId: '#ORD-789456',
      pickupLabel: 'Reliance Digital Store',
      pickupAddress: '23, Whites Road, Royapettah, Chennai',
      dropLabel: 'Arun Kumar',
      dropAddress: '45, 3rd Cross Street, Anna Nagar West, Chennai',
      customerName: 'Arun Kumar',
      customerPhone: '+91 98765 43210',
      status: 'On the Way',
    ),
    this.etaMinutes = 18,
    this.distanceKm = 6.2,
    this.nextTurnInstruction = 'Turn Left onto 2nd Avenue',
    this.turnDistanceMeters = 250.0,
    this.trafficLevel = DeliveryNavigationTrafficLevel.moderate,
    this.mapZoomLevel = 15.0,
  });

  bool get isNavigating => status == DeliveryNavigationStatus.navigating;

  DeliveryNavigationState copyWith({
    DeliveryNavigationStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
    bool? isOffline,
    bool? hasLocationPermission,
    bool? audioEnabled,
    bool? emergencyMode,
    bool? showMap,
    DeliveryNavigationRoutePoint? pickup,
    DeliveryNavigationRoutePoint? drop,
    DeliveryNavigationOrderSummary? order,
    int? etaMinutes,
    double? distanceKm,
    String? nextTurnInstruction,
    double? turnDistanceMeters,
    DeliveryNavigationTrafficLevel? trafficLevel,
    double? mapZoomLevel,
  }) {
    return DeliveryNavigationState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
      isOffline: isOffline ?? this.isOffline,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      emergencyMode: emergencyMode ?? this.emergencyMode,
      showMap: showMap ?? this.showMap,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      order: order ?? this.order,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      nextTurnInstruction: nextTurnInstruction ?? this.nextTurnInstruction,
      turnDistanceMeters: turnDistanceMeters ?? this.turnDistanceMeters,
      trafficLevel: trafficLevel ?? this.trafficLevel,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        localeCode,
        isOffline,
        hasLocationPermission,
        audioEnabled,
        emergencyMode,
        showMap,
        pickup,
        drop,
        order,
        etaMinutes,
        distanceKm,
        nextTurnInstruction,
        turnDistanceMeters,
        trafficLevel,
        mapZoomLevel,
      ];
}
