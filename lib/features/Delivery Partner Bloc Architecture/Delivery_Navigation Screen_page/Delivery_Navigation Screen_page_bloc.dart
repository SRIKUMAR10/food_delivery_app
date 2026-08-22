// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/delivery_active_order_session_repository.dart';
import 'Delivery_Navigation Screen_page_event.dart';
import 'Delivery_Navigation Screen_page_state.dart';
import 'Delivery_Navigation Screen_page_repository.dart';
import 'Delivery_Navigation Screen_page_service.dart';

class DeliveryNavigationBloc
    extends Bloc<DeliveryNavigationEvent, DeliveryNavigationState> {
  final DeliveryNavigationRepositoryBase repository;
  final DeliveryNavigationServiceBase service;
  final DeliveryActiveOrderSessionRepository? _sessionRepo;

  StreamSubscription<Map<String, dynamic>>? _locationSub;
  StreamSubscription<Map<String, dynamic>?>? _orderSub;
  StreamSubscription<Map<String, dynamic>?>? _profileSub;
  StreamSubscription<List<Map<String, dynamic>>>? _sellersSub;
  StreamSubscription<DeliverySessionState>? _sessionSub;

  String? _activeOrderId;

  DeliveryNavigationBloc({
    required this.repository,
    required this.service,
    DeliveryActiveOrderSessionRepository? sessionRepository,
  })  : _sessionRepo = sessionRepository,
        super(const DeliveryNavigationState()) {
    on<DeliveryNavigationInitEvent>(_onInit);
    on<DeliveryNavigationStartNavigationEvent>(_onStartNavigation);
    on<DeliveryNavigationExitNavigationEvent>(_onExitNavigation);
    on<DeliveryNavigationRecenterMapEvent>(_onRecenterMap);
    on<DeliveryNavigationToggleAudioEvent>(_onToggleAudio);
    on<DeliveryNavigationSOSClickedEvent>(_onSOSClicked);
    on<DeliveryNavigationRefreshEvent>(_onRefresh);
    on<DeliveryNavigationLocaleChangedEvent>(_onLocaleChanged);
    on<DeliveryNavigationLocationTickEvent>(_onLocationTick);
    on<DeliveryNavigationToggleMapEvent>(_onToggleMap);
    on<DeliveryNavigationToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<DeliveryNavigationSelectDemandZoneEvent>(_onSelectDemandZone);
    on<DeliveryNavigationLocationUpdatedEvent>(_onLocationUpdated);
    on<DeliveryNavigationStageChangedEvent>(_onStageChanged);
    on<DeliveryNavigationGpsStatusChangedEvent>(_onGpsStatusChanged);
    on<DeliveryNavigationPermissionStatusChangedEvent>(
      _onPermissionStatusChanged,
    );
    on<DeliveryNavigationOrderUpdatedEvent>(_onOrderUpdated);
    on<DeliveryNavigationArrivedAtPickupEvent>(_onArrivedAtPickup);
    on<DeliveryNavigationConfirmPickupEvent>(_onConfirmPickup);
    on<DeliveryNavigationArrivedAtCustomerEvent>(_onArrivedAtCustomer);
    on<DeliveryNavigationConfirmDeliveryEvent>(_onConfirmDelivery);
    on<DeliveryNavigationCollectCodCashEvent>(_onCollectCodCash);
    on<DeliveryNavigationProfileUpdatedEvent>(_onProfileUpdated);
    on<DeliveryNavigationSellersUpdatedEvent>(_onSellersUpdated);
  }

  @override
  Future<void> close() async {
    _stopLocationStream();
    await _orderSub?.cancel();
    _orderSub = null;
    await _profileSub?.cancel();
    _profileSub = null;
    await _sellersSub?.cancel();
    _sellersSub = null;
    await _sessionSub?.cancel();
    _sessionSub = null;
    await super.close();
  }

  NavigationStage _determineStage(String? rawStatus) {
    String compress(String? value) => (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    const stage1 = <String>{
      'accepted',
      'assigned',
      'reachingrestaurant',
      'arrivedatrestaurant',
      'preparing',
      'ready',
      'readyforpickup',
    };
    const stage2 = <String>{
      'pickedup',
      'outfordelivery',
      'reachingcustomer',
      'arrivedatcustomer',
      'ontheway',
    };
    const completed = <String>{'delivered', 'completed'};

    final normalized = compress(rawStatus);
    if (completed.contains(normalized)) return NavigationStage.completed;
    if (stage2.contains(normalized)) return NavigationStage.toCustomer;
    if (stage1.contains(normalized)) return NavigationStage.toRestaurant;
    return NavigationStage.toRestaurant;
  }

  DeliveryNavigationState _applyProfile(
    DeliveryNavigationState state,
    Map<String, dynamic>? profile,
  ) {
    if (profile == null) return state;
    return state.copyWith(
      partnerName: profile['partnerName'] as String? ?? state.partnerName,
      partnerPhotoUrl:
          profile['partnerPhotoUrl'] as String? ?? state.partnerPhotoUrl,
      partnerVehicleNumber:
          profile['partnerVehicleNumber'] as String? ??
              state.partnerVehicleNumber,
      partnerRating:
          (profile['partnerRating'] as num?)?.toDouble() ?? state.partnerRating,
      isOnline: profile['isOnline'] as bool? ?? state.isOnline,
    );
  }

  DeliveryNavigationState _withDestination(
    DeliveryNavigationState state,
    NavigationStage stage,
  ) {
    final toRestaurant = stage == NavigationStage.toRestaurant;
    final destLat = toRestaurant ? state.restaurantLat : state.customerLat;
    final destLng = toRestaurant ? state.restaurantLng : state.customerLng;

    double dist = state.distanceToDestinationKm;
    int eta = state.etaToDestinationMinutes;
    if (state.hasDriverPosition && destLat != 0.0 && destLng != 0.0) {
      dist = service.calculateDistanceKm(
        state.driverLat,
        state.driverLng,
        destLat,
        destLng,
      );
      eta = service
          .calculateEtaMinutes(
            dist,
            state.driverSpeedKmh > 0 ? state.driverSpeedKmh : 22.0,
          )
          .round();
    }

    return state.copyWith(
      navigationStage: stage,
      destinationName:
          toRestaurant ? state.restaurantName : state.customerName,
      destinationAddress:
          toRestaurant ? state.restaurantAddress : state.customerAddress,
      destinationPhone:
          toRestaurant ? state.restaurantPhone : state.customerPhone,
      destinationLat: destLat,
      destinationLng: destLng,
      distanceToDestinationKm: dist > 0 ? dist : state.distanceToDestinationKm,
      etaToDestinationMinutes: eta > 0 ? eta : state.etaToDestinationMinutes,
    );
  }

  DeliveryNavigationState _applyOrderData(
    DeliveryNavigationState state,
    Map<String, dynamic> data,
  ) {
    final stage = _determineStage(data['status'] as String?);

    double rLat = (data['sellerLat'] as num?)?.toDouble() ?? state.restaurantLat;
    double rLng = (data['sellerLng'] as num?)?.toDouble() ?? state.restaurantLng;
    double cLat = (data['customerLat'] as num?)?.toDouble() ?? state.customerLat;
    double cLng = (data['customerLng'] as num?)?.toDouble() ?? state.customerLng;

    if (rLat == 0.0 && rLng == 0.0) {
      rLat = 11.4485;
      rLng = 77.6835;
    }
    if (cLat == 0.0 && cLng == 0.0) {
      cLat = 11.4580;
      cLng = 77.6980;
    }

    final withTargets = state.copyWith(
      restaurantName: data['sellerName'] as String? ?? state.restaurantName,
      restaurantAddress:
          data['sellerAddress'] as String? ?? state.restaurantAddress,
      restaurantPhone: data['sellerPhone'] as String? ?? state.restaurantPhone,
      restaurantLat: rLat,
      restaurantLng: rLng,
      customerName: data['customerName'] as String? ?? state.customerName,
      customerAddress:
          data['customerAddress'] as String? ?? state.customerAddress,
      customerPhone: data['customerPhone'] as String? ?? state.customerPhone,
      customerNotes: data['customerNotes'] as String? ?? state.customerNotes,
      customerLat: cLat,
      customerLng: cLng,
      paymentMethod:
          data['paymentMethod'] as String? ?? state.paymentMethod,
      codAmount: (data['codAmount'] as num?)?.toDouble() ?? state.codAmount,
      isCodCollected: data['isCodCollected'] == true || state.isCodCollected,
      collectedAmount:
          (data['collectedAmount'] as num?)?.toDouble() ?? state.collectedAmount,
      activeOrderId: data['orderId'] as String? ?? state.activeOrderId,
    );
    return _withDestination(withTargets, stage);
  }

  List<DeliveryDemandZone> _parseDemandZones(List<Map<String, dynamic>>? raw) {
    if (raw == null) return const [];
    return raw
        .map((z) => DeliveryDemandZone(
              name: z['name'] as String? ?? 'Hotspot',
              latitude: (z['latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (z['longitude'] as num?)?.toDouble() ?? 0.0,
              estimatedDemand: (z['estimatedDemand'] as num?)?.toInt() ?? 0,
              tags: (z['tags'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  const [],
            ))
        .toList();
  }

  Future<List<DeliveryDemandZone>> _loadDemandZones() async {
    try {
      final raw = await service.fetchDemandZones();
      return _parseDemandZones(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _onInit(
    DeliveryNavigationInitEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryNavigationStatus.loading));
    try {
      final isOnline = await service.checkConnectivity();
      final hasPermission = await service.checkLocationPermission();
      final gpsEnabled = await service.checkGpsStatus();
      final order = await repository.fetchOrderSummary();
      final rawOrder = (event.orderId != null && event.orderId!.isNotEmpty)
          ? await repository.fetchActiveOrderData(orderId: event.orderId)
          : await repository.fetchActiveOrderData();
      final pickup = await repository.fetchPickup();
      final drop = await repository.fetchDrop();
      final profile = await repository.fetchPartnerProfile();
      final audioEnabled = await repository.getAudioEnabled();
      final emergencyMode = await repository.getEmergencyMode();
      final localeCode = await repository.getLocaleCode();
      final demandZones = await _loadDemandZones();
      final nearbySellers = await repository.fetchNearbySellers();

      _activeOrderId = rawOrder?['orderId'] as String?;
      _subscribeToOrderStream();
      _subscribeToProfileStream();
      _subscribeToSellersStream();
      _subscribeToSession();

      final gpsStatus = !hasPermission
          ? DeliveryGpsStatus.permissionDenied
          : (gpsEnabled
              ? DeliveryGpsStatus.active
              : DeliveryGpsStatus.disabled);

      var next = state.copyWith(
        isOffline: !isOnline,
        hasLocationPermission: hasPermission,
        isGpsServiceEnabled: gpsEnabled,
        gpsStatus: gpsStatus,
        audioEnabled: audioEnabled,
        emergencyMode: emergencyMode,
        localeCode: localeCode,
        demandZones: demandZones,
        nearbySellers: nearbySellers,
        errorMessage: null,
        clearError: true,
      );
      next = _applyProfile(next, profile);

      if (order.orderId.trim().isEmpty) {
        // Idle driver console: keep the map live while waiting for orders.
        if (isOnline && hasPermission && gpsEnabled) {
          _startLiveLocationStream();
        }
        emit(next.copyWith(
          status: DeliveryNavigationStatus.loaded,
          order: order,
          pickup: pickup,
          drop: drop,
        ));
        return;
      }

      if (rawOrder != null) {
        next = _applyOrderData(next, rawOrder);
      }

      emit(next.copyWith(
        status: DeliveryNavigationStatus.loaded,
        order: order,
        pickup: pickup,
        drop: drop,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _subscribeToOrderStream() {
    _orderSub?.cancel();
    _orderSub = repository.watchActiveOrder().listen(
      (data) {
        if (isClosed) return;
        add(DeliveryNavigationOrderUpdatedEvent(data));
      },
      onError: (Object _) {},
    );
  }

  void _subscribeToProfileStream() {
    _profileSub?.cancel();
    _profileSub = repository.watchPartnerProfile().listen(
      (profile) {
        if (isClosed || profile == null) return;
        add(DeliveryNavigationProfileUpdatedEvent(profile));
      },
      onError: (Object _) {},
    );
  }

  void _subscribeToSellersStream() {
    _sellersSub?.cancel();
    _sellersSub = repository.watchNearbySellers().listen(
      (sellers) {
        if (isClosed) return;
        add(DeliveryNavigationSellersUpdatedEvent(sellers));
      },
      onError: (Object _) {},
    );
  }

  void _onSellersUpdated(
    DeliveryNavigationSellersUpdatedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(
      nearbySellers: event.sellers,
    ));
  }

  /// Cross-BLoC session bridge: any order accepted elsewhere (incoming order,
  /// orders dashboard, pickup confirmation) instantly propagates here.
  void _subscribeToSession() {
    if (_sessionRepo == null) return;
    _sessionSub?.cancel();
    _sessionSub = _sessionRepo.sessionStream.listen(
      (session) async {
        if (isClosed) return;
        final orderId = session.activeOrderId;
        if (orderId == null || orderId.trim().isEmpty) {
          if (_activeOrderId != null && _activeOrderId!.isNotEmpty) {
            add(DeliveryNavigationOrderUpdatedEvent(null));
          }
          return;
        }
        if (orderId != _activeOrderId) {
          try {
            final data = await repository.fetchActiveOrderData(orderId: orderId);
            if (!isClosed) {
              add(DeliveryNavigationOrderUpdatedEvent(data));
            }
          } catch (_) {
            add(
              DeliveryNavigationInitEvent(orderId: orderId),
            );
          }
        }
      },
      onError: (Object _) {},
    );
  }

  Future<void> _onStartNavigation(
    DeliveryNavigationStartNavigationEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    if (state.status == DeliveryNavigationStatus.navigating) {
      return;
    }
    await repository.saveAudioEnabled(true);
    _startLiveLocationStream();
    emit(state.copyWith(
      status: DeliveryNavigationStatus.navigating,
      audioEnabled: true,
      emergencyMode: false,
      gpsStatus: state.hasLocationPermission
          ? DeliveryGpsStatus.searching
          : DeliveryGpsStatus.permissionDenied,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onExitNavigation(
    DeliveryNavigationExitNavigationEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    _stopLocationStream();
    emit(state.copyWith(
      status: DeliveryNavigationStatus.loaded,
      emergencyMode: false,
      gpsStatus: DeliveryGpsStatus.searching,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onRecenterMap(
    DeliveryNavigationRecenterMapEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      mapZoomLevel: 15.0,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onToggleAudio(
    DeliveryNavigationToggleAudioEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    final enabled = !state.audioEnabled;
    await repository.saveAudioEnabled(enabled);
    emit(state.copyWith(
      audioEnabled: enabled,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onToggleMap(
    DeliveryNavigationToggleMapEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      showMap: !state.showMap,
      errorMessage: null,
      clearError: true,
    ));
  }

  void _onToggleOnlineStatus(
    DeliveryNavigationToggleOnlineStatusEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    final newOnline = !state.isOnline;
    _sessionRepo?.setOnlineStatus(newOnline);
    emit(state.copyWith(
      isOnline: newOnline,
      errorMessage: null,
      clearError: true,
    ));
  }

  void _onSelectDemandZone(
    DeliveryNavigationSelectDemandZoneEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(
      selectedDemandZone: event.zone,
      mapZoomLevel: 16.0,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onSOSClicked(
    DeliveryNavigationSOSClickedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    await repository.saveEmergencyMode(true);
    emit(state.copyWith(
      emergencyMode: true,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onRefresh(
    DeliveryNavigationRefreshEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    try {
      final isOnline = await service.checkConnectivity();
      final hasPermission = await service.checkLocationPermission();
      final gpsEnabled = await service.checkGpsStatus();
      final order = await repository.fetchOrderSummary();
      final rawOrder = await repository.fetchActiveOrderData();
      final pickup = await repository.fetchPickup();
      final drop = await repository.fetchDrop();
      final audioEnabled = await repository.getAudioEnabled();
      final emergencyMode = await repository.getEmergencyMode();
      final demandZones = await _loadDemandZones();

      _activeOrderId = rawOrder?['orderId'] as String?;

      var next = state.copyWith(
        isOffline: !isOnline,
        hasLocationPermission: hasPermission,
        isGpsServiceEnabled: gpsEnabled,
        gpsStatus: !hasPermission
            ? DeliveryGpsStatus.permissionDenied
            : (gpsEnabled
                ? DeliveryGpsStatus.active
                : DeliveryGpsStatus.disabled),
        audioEnabled: audioEnabled,
        emergencyMode: emergencyMode,
        demandZones: demandZones,
        errorMessage: null,
        clearError: true,
      );

      if (order.orderId.trim().isEmpty) {
        if (isOnline && hasPermission && gpsEnabled) {
          _startLiveLocationStream();
        }
        emit(next.copyWith(
          status: DeliveryNavigationStatus.loaded,
          order: order,
          pickup: pickup,
          drop: drop,
        ));
        return;
      }

      if (rawOrder != null) {
        next = _applyOrderData(next, rawOrder);
      }

      emit(next.copyWith(
        status: DeliveryNavigationStatus.loaded,
        order: order,
        pickup: pickup,
        drop: drop,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLocaleChanged(
    DeliveryNavigationLocaleChangedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    await repository.saveLocaleCode(event.localeCode);
    emit(state.copyWith(localeCode: event.localeCode));
  }

  void _onLocationTick(
    DeliveryNavigationLocationTickEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(
      turnDistanceMeters: math.max(
        0,
        state.turnDistanceMeters - event.deltaMeters,
      ),
    ));
  }

  void _onLocationUpdated(
    DeliveryNavigationLocationUpdatedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    final destLat = state.destinationLat;
    final destLng = state.destinationLng;
    var distance = state.distanceToDestinationKm;
    var eta = state.etaToDestinationMinutes;
    var heading = event.heading;

    if (destLat != 0.0 || destLng != 0.0) {
      distance = service.calculateDistanceKm(
        event.lat,
        event.lng,
        destLat,
        destLng,
      );
      eta = service
          .calculateEtaMinutes(distance, event.speed)
          .round();
      if (heading <= 0.0) {
        heading = service.calculateBearing(
          event.lat,
          event.lng,
          destLat,
          destLng,
        );
      }
    }

    emit(state.copyWith(
      driverLat: event.lat,
      driverLng: event.lng,
      driverHeading: heading,
      driverSpeedKmh: event.speed,
      driverLastUpdated: event.timestamp,
      distanceToDestinationKm: distance,
      etaToDestinationMinutes: eta,
      distanceKm: distance,
      etaMinutes: eta,
      gpsStatus: DeliveryGpsStatus.active,
    ));

    final orderId = _activeOrderId;
    if (orderId != null && orderId.isNotEmpty && !state.isOffline) {
      unawaited(
        service.updateLiveLocation(
          orderId: orderId,
          lat: event.lat,
          lng: event.lng,
          heading: heading,
          speed: event.speed,
          stage: state.navigationStage.firestoreValue,
        ),
      );
    } else if (!state.isOffline && state.hasLocationPermission) {
      // Idle rider console: keep the partner location doc fresh on the live map.
      unawaited(
        service.updateDriverLocation(
          latitude: event.lat,
          longitude: event.lng,
        ),
      );
    }
  }

  void _onStageChanged(
    DeliveryNavigationStageChangedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(_withDestination(state, event.stage));
  }

  void _onGpsStatusChanged(
    DeliveryNavigationGpsStatusChangedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(gpsStatus: event.status));
  }

  void _onPermissionStatusChanged(
    DeliveryNavigationPermissionStatusChangedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(hasLocationPermission: event.hasPermission));
  }

  void _onProfileUpdated(
    DeliveryNavigationProfileUpdatedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(_applyProfile(state, event.profile));
  }

  void _onOrderUpdated(
    DeliveryNavigationOrderUpdatedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    final data = event.orderData;
    if (data == null) {
      // No active order: fall back to the live idle radar map. GPS streaming
      // continues so the rider still sees their position and demand hotspots.
      _activeOrderId = null;
      emit(state.copyWith(
        status: DeliveryNavigationStatus.loaded,
        activeOrderId: '',
        selectedDemandZone: null,
        errorMessage: null,
        clearError: true,
      ));
      return;
    }

    _activeOrderId = data['orderId'] as String?;
    final stage = _determineStage(data['status'] as String?);
    if (stage == NavigationStage.completed) {
      _stopLocationStream();
    }

    emit(_applyOrderData(state, data));
  }

  Future<void> _onArrivedAtPickup(
    DeliveryNavigationArrivedAtPickupEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      turnDistanceMeters: 0,
      nextTurnInstruction: 'Arrived at Restaurant',
    ));
  }

  Future<void> _onConfirmPickup(
    DeliveryNavigationConfirmPickupEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    final orderId = _activeOrderId;
    if (orderId != null && orderId.isNotEmpty) {
      await service.updateOrderStatus(orderId, 'picked_up');
    }
    emit(
      _withDestination(state, NavigationStage.toCustomer).copyWith(
        turnDistanceMeters: 0,
        nextTurnInstruction: 'Head to Customer',
      ),
    );
  }

  Future<void> _onArrivedAtCustomer(
    DeliveryNavigationArrivedAtCustomerEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      turnDistanceMeters: 0,
      nextTurnInstruction: 'Arrived at Customer',
      isArrivedAtCustomer: true,
    ));
  }

  Future<void> _onCollectCodCash(
    DeliveryNavigationCollectCodCashEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    if (state.isCodCollected) return;
    emit(state.copyWith(
      codCollectStatus: CodCollectStatus.collecting,
      clearError: true,
    ));
    try {
      final result = await repository.collectCodCash(
        orderId: event.orderId,
        amountReceived: event.amountReceived,
      );
      if (result['success'] == true) {
        emit(state.copyWith(
          codCollectStatus: CodCollectStatus.success,
          isCodCollected: true,
          collectedAmount:
              (result['collectedAmount'] as num?)?.toDouble() ??
                  state.codAmountToCollect,
          codReceivedAmount: event.amountReceived,
          codChangeAmount:
              (result['changeAmount'] as num?)?.toDouble() ?? 0.0,
          codMessage: result['message'] as String?,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          codCollectStatus: CodCollectStatus.failed,
          codMessage: result['message'] as String?,
          errorMessage: result['message'] as String?,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        codCollectStatus: CodCollectStatus.failed,
        codMessage: e.toString(),
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onConfirmDelivery(
    DeliveryNavigationConfirmDeliveryEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    final orderId = _activeOrderId;
    if (orderId != null && orderId.isNotEmpty) {
      await service.updateOrderStatus(orderId, 'delivered');
    }
    _stopLocationStream();
    emit(state.copyWith(
      navigationStage: NavigationStage.completed,
      status: DeliveryNavigationStatus.loaded,
      emergencyMode: false,
      nextTurnInstruction: 'Delivery Completed',
      turnDistanceMeters: 0,
      errorMessage: null,
      clearError: true,
    ));
  }

  void _startLiveLocationStream() {
    _locationSub?.cancel();
    _locationSub = service.streamLiveLocation(highAccuracy: true).listen(
      (loc) {
        if (isClosed) return;
        add(
          DeliveryNavigationLocationUpdatedEvent(
            lat: (loc['lat'] as num).toDouble(),
            lng: (loc['lng'] as num).toDouble(),
            heading: (loc['heading'] as num?)?.toDouble() ?? 0.0,
            speed: (loc['speedKmh'] as num?)?.toDouble() ?? 0.0,
            timestamp: (loc['timestamp'] as DateTime?) ?? DateTime.now(),
          ),
        );
      },
      onError: (Object _) {
        if (isClosed) return;
        add(
          const DeliveryNavigationGpsStatusChangedEvent(
            DeliveryGpsStatus.disabled,
          ),
        );
      },
    );
  }

  void _stopLocationStream() {
    _locationSub?.cancel();
    _locationSub = null;
  }
}

/// Standardized Feature-Architecture Alias for NavigationBloc
typedef NavigationBloc = DeliveryNavigationBloc;

