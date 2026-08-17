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

enum NavigationStage { toRestaurant, toCustomer, completed }

extension NavigationStageX on NavigationStage {
  String get firestoreValue => switch (this) {
        NavigationStage.toRestaurant => 'to_restaurant',
        NavigationStage.toCustomer => 'to_customer',
        NavigationStage.completed => 'completed',
      };
}

enum DeliveryGpsStatus { active, searching, disabled, permissionDenied }

enum CodCollectStatus { initial, collecting, success, failed }

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
  final String paymentMethod;
  final double codAmount;
  final bool isCodCollected;
  final double collectedAmount;

  const DeliveryNavigationOrderSummary({
    required this.orderId,
    required this.pickupLabel,
    required this.pickupAddress,
    required this.dropLabel,
    required this.dropAddress,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    this.paymentMethod = '',
    this.codAmount = 0.0,
    this.isCodCollected = false,
    this.collectedAmount = 0.0,
  });

  bool get isCOD {
    final normalized = paymentMethod.trim().toUpperCase();
    return normalized == 'COD' || normalized == 'CASH ON DELIVERY';
  }

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
        paymentMethod,
        codAmount,
        isCodCollected,
        collectedAmount,
      ];
}

class DeliveryNavigationState extends Equatable {
  final DeliveryNavigationStatus status;
  final String? errorMessage;
  final String localeCode;
  final bool isOffline;
  final bool hasLocationPermission;
  final bool isGpsServiceEnabled;
  final bool audioEnabled;
  final bool emergencyMode;
  final bool showMap;

  final NavigationStage navigationStage;
  final DeliveryGpsStatus gpsStatus;

  final DeliveryNavigationRoutePoint pickup;
  final DeliveryNavigationRoutePoint drop;
  final DeliveryNavigationOrderSummary order;

  final int etaMinutes;
  final double distanceKm;
  final String nextTurnInstruction;
  final double turnDistanceMeters;
  final DeliveryNavigationTrafficLevel trafficLevel;
  final double mapZoomLevel;

  // Live driver telemetry.
  final double driverLat;
  final double driverLng;
  final double driverHeading;
  final double driverSpeedKmh;
  final DateTime? driverLastUpdated;

  // Active destination (derived from the current navigation stage).
  final String destinationName;
  final String destinationAddress;
  final String destinationPhone;
  final double destinationLat;
  final double destinationLng;

  // Restaurant (Stage 1 target).
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantPhone;
  final double restaurantLat;
  final double restaurantLng;

  // Customer (Stage 2 target).
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String customerNotes;
  final double customerLat;
  final double customerLng;

  final double distanceToDestinationKm;
  final int etaToDestinationMinutes;

  final bool isOnline;
  final String partnerName;
  final String partnerPhotoUrl;
  final String partnerVehicleNumber;
  final double partnerRating;

  // COD cash collection.
  final String paymentMethod;
  final double codAmount;
  final bool isCodCollected;
  final double collectedAmount;
  final CodCollectStatus codCollectStatus;
  final double codReceivedAmount;
  final double codChangeAmount;
  final String? codMessage;
  final bool isArrivedAtCustomer;

  // Full Firestore id of the active order (for COD writes).
  final String activeOrderId;

  const DeliveryNavigationState({
    this.status = DeliveryNavigationStatus.initial,
    this.errorMessage,
    this.localeCode = 'en',
    this.isOffline = false,
    this.hasLocationPermission = false,
    this.isGpsServiceEnabled = false,
    this.audioEnabled = false,
    this.emergencyMode = false,
    this.showMap = true,
    this.navigationStage = NavigationStage.toRestaurant,
    this.gpsStatus = DeliveryGpsStatus.searching,
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
    this.driverLat = 0.0,
    this.driverLng = 0.0,
    this.driverHeading = 0.0,
    this.driverSpeedKmh = 0.0,
    this.driverLastUpdated,
    this.destinationName = '',
    this.destinationAddress = '',
    this.destinationPhone = '',
    this.destinationLat = 0.0,
    this.destinationLng = 0.0,
    this.restaurantName = 'Reliance Digital Store',
    this.restaurantAddress = '23, Whites Road, Royapettah, Chennai',
    this.restaurantPhone = '',
    this.restaurantLat = 0.0,
    this.restaurantLng = 0.0,
    this.customerName = 'Arun Kumar',
    this.customerAddress = '45, 3rd Cross Street, Anna Nagar West, Chennai',
    this.customerPhone = '+91 98765 43210',
    this.customerNotes = '',
    this.customerLat = 0.0,
    this.customerLng = 0.0,
    this.distanceToDestinationKm = 6.2,
    this.etaToDestinationMinutes = 18,
    this.isOnline = false,
    this.partnerName = '',
    this.partnerPhotoUrl = '',
    this.partnerVehicleNumber = '',
    this.partnerRating = 0.0,
    this.paymentMethod = '',
    this.codAmount = 0.0,
    this.isCodCollected = false,
    this.collectedAmount = 0.0,
    this.codCollectStatus = CodCollectStatus.initial,
    this.codReceivedAmount = 0.0,
    this.codChangeAmount = 0.0,
    this.codMessage,
    this.isArrivedAtCustomer = false,
    this.activeOrderId = '',
  });

  bool get isNavigating => status == DeliveryNavigationStatus.navigating;

  bool get isStageToRestaurant =>
      navigationStage == NavigationStage.toRestaurant;

  bool get isStageToCustomer => navigationStage == NavigationStage.toCustomer;

  bool get isStageCompleted => navigationStage == NavigationStage.completed;

  bool get hasActiveDestination =>
      destinationLat != 0.0 || destinationLng != 0.0;

  bool get hasDriverPosition => driverLat != 0.0 || driverLng != 0.0;

  bool get isCOD {
    final normalized = paymentMethod.trim().toUpperCase();
    return normalized == 'COD' || normalized == 'CASH ON DELIVERY';
  }

  double get codAmountToCollect => codAmount > 0 ? codAmount : 0.0;

  DeliveryNavigationState copyWith({
    DeliveryNavigationStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
    bool? isOffline,
    bool? hasLocationPermission,
    bool? isGpsServiceEnabled,
    bool? audioEnabled,
    bool? emergencyMode,
    bool? showMap,
    NavigationStage? navigationStage,
    DeliveryGpsStatus? gpsStatus,
    DeliveryNavigationRoutePoint? pickup,
    DeliveryNavigationRoutePoint? drop,
    DeliveryNavigationOrderSummary? order,
    int? etaMinutes,
    double? distanceKm,
    String? nextTurnInstruction,
    double? turnDistanceMeters,
    DeliveryNavigationTrafficLevel? trafficLevel,
    double? mapZoomLevel,
    double? driverLat,
    double? driverLng,
    double? driverHeading,
    double? driverSpeedKmh,
    DateTime? driverLastUpdated,
    String? destinationName,
    String? destinationAddress,
    String? destinationPhone,
    double? destinationLat,
    double? destinationLng,
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantPhone,
    double? restaurantLat,
    double? restaurantLng,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    String? customerNotes,
    double? customerLat,
    double? customerLng,
    double? distanceToDestinationKm,
    int? etaToDestinationMinutes,
    bool? isOnline,
    String? partnerName,
    String? partnerPhotoUrl,
    String? partnerVehicleNumber,
    double? partnerRating,
  }) {
    return DeliveryNavigationState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
      isOffline: isOffline ?? this.isOffline,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isGpsServiceEnabled: isGpsServiceEnabled ?? this.isGpsServiceEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      emergencyMode: emergencyMode ?? this.emergencyMode,
      showMap: showMap ?? this.showMap,
      navigationStage: navigationStage ?? this.navigationStage,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      order: order ?? this.order,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      nextTurnInstruction: nextTurnInstruction ?? this.nextTurnInstruction,
      turnDistanceMeters: turnDistanceMeters ?? this.turnDistanceMeters,
      trafficLevel: trafficLevel ?? this.trafficLevel,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      driverHeading: driverHeading ?? this.driverHeading,
      driverSpeedKmh: driverSpeedKmh ?? this.driverSpeedKmh,
      driverLastUpdated: driverLastUpdated ?? this.driverLastUpdated,
      destinationName: destinationName ?? this.destinationName,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationPhone: destinationPhone ?? this.destinationPhone,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      restaurantLat: restaurantLat ?? this.restaurantLat,
      restaurantLng: restaurantLng ?? this.restaurantLng,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      customerNotes: customerNotes ?? this.customerNotes,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      distanceToDestinationKm:
          distanceToDestinationKm ?? this.distanceToDestinationKm,
      etaToDestinationMinutes:
          etaToDestinationMinutes ?? this.etaToDestinationMinutes,
      isOnline: isOnline ?? this.isOnline,
      partnerName: partnerName ?? this.partnerName,
      partnerPhotoUrl: partnerPhotoUrl ?? this.partnerPhotoUrl,
      partnerVehicleNumber: partnerVehicleNumber ?? this.partnerVehicleNumber,
      partnerRating: partnerRating ?? this.partnerRating,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        localeCode,
        isOffline,
        hasLocationPermission,
        isGpsServiceEnabled,
        audioEnabled,
        emergencyMode,
        showMap,
        navigationStage,
        gpsStatus,
        pickup,
        drop,
        order,
        etaMinutes,
        distanceKm,
        nextTurnInstruction,
        turnDistanceMeters,
        trafficLevel,
        mapZoomLevel,
        driverLat,
        driverLng,
        driverHeading,
        driverSpeedKmh,
        driverLastUpdated,
        destinationName,
        destinationAddress,
        destinationPhone,
        destinationLat,
        destinationLng,
        restaurantName,
        restaurantAddress,
        restaurantPhone,
        restaurantLat,
        restaurantLng,
        customerName,
        customerAddress,
        customerPhone,
        customerNotes,
        customerLat,
        customerLng,
        distanceToDestinationKm,
        etaToDestinationMinutes,
        isOnline,
        partnerName,
        partnerPhotoUrl,
        partnerVehicleNumber,
        partnerRating,
      ];
}
