// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Track_Order_page_event.dart';
import 'Track_Order_page_state.dart';
import 'Track_Order_page_repository.dart';
import 'Track_Order_page_service.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/models/order_status.dart';

class TrackOrderBloc extends Bloc<TrackOrderEvent, TrackOrderState> {
  final TrackOrderRepository repository;
  final IOrderRepository orderRepository;
  final TrackOrderService trackService;
  StreamSubscription<DriverLocation>? _locationSubscription;
  StreamSubscription? _orderStatusSubscription;
  String? _trackedRiderId;

  TrackOrderBloc({
    required this.repository,
    required this.orderRepository,
    required this.trackService,
  }) : super(TrackOrderInitial()) {
    on<LoadTrackOrderDetails>(_onLoadTrackOrderDetails);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<RefreshTrackOrder>(_onRefreshTrackOrder);
    on<StartTracking>(_onStartTracking);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<CancelOrderEvent>(_onCancelOrder);
    on<ToggleMapFullScreen>(_onToggleMapFullScreen);
  }

  Future<void> _onLoadTrackOrderDetails(
    LoadTrackOrderDetails event,
    Emitter<TrackOrderState> emit,
  ) async {
    emit(TrackOrderLoading());
    try {
      final details = await trackService.getOrderDetails(event.orderId);
      details['orderId'] = event.orderId;
      final confirmedTime = event.orderDate;

      _listenToOrderStatus(event.orderId, confirmedTime);

      emit(_buildLoaded(details, confirmedTime));

      _syncLocationTracking(details);
    } catch (e) {
      emit(TrackOrderError(e.toString()));
    }
  }

  void _listenToOrderStatus(String orderId, DateTime orderDate) {
    _orderStatusSubscription?.cancel();
    _orderStatusSubscription = trackService.watchOrder(orderId).listen((snapshot) {
      if (!snapshot.exists || isClosed) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      add(OrderStatusUpdated(orderId: orderId, orderDate: orderDate, orderData: data));
    }, onError: (_) {});
  }

  Future<void> _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<TrackOrderState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! TrackOrderLoaded) return;

      final Map<String, dynamic> details;
      if (event.orderData != null && event.orderData!.isNotEmpty) {
        details = _enrichWithExisting(event.orderData!, currentState);
        details['orderId'] = event.orderId;
      } else {
        details = await trackService.getOrderDetails(event.orderId);
      }

      emit(_buildLoaded(details, event.orderDate));
      _syncLocationTracking(details);
    } catch (_) {}
  }

  /// Merges a raw order document snapshot with already-fetched partner/seller
  /// enrichments so live updates keep contact & profile details intact.
  Map<String, dynamic> _enrichWithExisting(
    Map<String, dynamic> data,
    TrackOrderLoaded current,
  ) {
    final map = Map<String, dynamic>.from(data);
    map.putIfAbsent('riderId', () => map['riderId']);
    map['driverName'] = map['driverName'] ?? current.deliveryPartner.name;
    map['driverImage'] = map['driverImage'] ?? current.deliveryPartner.imageUrl;
    map['driverPhone'] = map['driverPhone'] ?? current.deliveryPartner.phone;
    map['driverVehicleType'] = map['driverVehicleType'] ?? current.deliveryPartner.vehicleType;
    map['driverVehicleNumber'] = map['driverVehicleNumber'] ?? current.deliveryPartner.vehicleNumber;
    map['driverRating'] = map['driverRating'] ?? current.deliveryPartner.rating;
    map['driverTotalDeliveries'] = map['driverTotalDeliveries'] ?? current.deliveryPartner.totalDeliveries;
    map['driverIsAssigned'] = map['driverIsAssigned'] ?? current.deliveryPartner.isAssigned;
    map['driverLat'] = map['driverLat'] ?? current.driverLat;
    map['driverLng'] = map['driverLng'] ?? current.driverLng;
    map['sellerId'] = map['sellerId'] ?? current.sellerInfo?.id;
    map['sellerName'] = map['sellerName'] ?? current.sellerInfo?.name;
    map['sellerAddress'] = map['sellerAddress'] ?? current.sellerInfo?.address;
    map['sellerImageUrl'] = map['sellerImageUrl'] ?? current.sellerInfo?.imageUrl;
    map['sellerPhone'] = map['sellerPhone'] ?? current.sellerInfo?.phone;
    map['sellerLat'] = map['sellerLat'] ?? current.sellerLat;
    map['sellerLng'] = map['sellerLng'] ?? current.sellerLng;
    map['sellerIsVerified'] = map['sellerIsVerified'] ?? current.sellerInfo?.isVerified;
    map['sellerOpenStatus'] = map['sellerOpenStatus'] ?? current.sellerInfo?.openStatus;
    map['sellerOpeningHours'] = map['sellerOpeningHours'] ?? current.sellerInfo?.openingHours;
    map['estimatedDelivery'] = map['estimatedDelivery'] ?? current.estimatedDelivery;
    map['etaMinutes'] = map['etaMinutes'] ?? current.etaMinutes;
    return map;
  }

  /// Starts live driver-location tracking as soon as a rider is assigned and
  /// stops it once the order reaches a terminal state (delivered/cancelled).
  void _syncLocationTracking(Map<String, dynamic> details) {
    final raw = details['status'] as String? ?? 'New';
    final status = OrderStatus.fromString(raw);
    final riderId = details['riderId'] as String?;
    final isTerminal = status == OrderStatus.delivered ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.rejected;
    final hasRider = riderId != null && riderId.isNotEmpty;

    if (isTerminal || !hasRider) {
      _stopLocationTracking();
      return;
    }

    if (_trackedRiderId != riderId) {
      _trackedRiderId = riderId;
      add(StartTracking(riderId: riderId));
    }
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _trackedRiderId = null;
    repository.stopTracking();
  }

  TrackOrderLoaded _buildLoaded(
    Map<String, dynamic> details,
    DateTime confirmedTime,
  ) {
    final timeFormat = DateFormat('hh:mm a');
    final rawStatus = details['status'] as String? ?? 'New';
    final status = OrderStatus.fromString(rawStatus);
    final steps = _buildTrackingSteps(status, confirmedTime, timeFormat, details);

    final itemsRaw = details['items'];
    final orderItems = <OrderTrackItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is! Map) continue;
        orderItems.add(OrderTrackItem(
          id: (raw['id'] ?? raw['productId'] ?? '').toString(),
          name: (raw['name'] ?? 'Item').toString(),
          quantity: (raw['quantity'] is num ? raw['quantity'] as num : 1).toInt(),
          price: (raw['price'] is num ? raw['price'] as num : 0).toDouble(),
          imageUrl: raw['imageUrl']?.toString() ?? raw['image']?.toString(),
        ));
      }
    }

    final partnerData = details['driverIsAssigned'] == true;
    final deliveryPartner = DeliveryPartner(
      name: _str(details['driverName']),
      role: 'Your Delivery Partner',
      imageUrl: _str(details['driverImage']),
      phone: _str(details['driverPhone']),
      vehicleType: _str(details['driverVehicleType']),
      vehicleNumber: _str(details['driverVehicleNumber']),
      rating: _dbl(details['driverRating']),
      totalDeliveries: _int(details['driverTotalDeliveries']),
      isAssigned: partnerData,
      lat: _dbl(details['driverLat']),
      lng: _dbl(details['driverLng']),
    );

    final sellerId = _str(details['sellerId']);
    final sellerInfo = SellerInfo(
      id: sellerId,
      name: _str(details['sellerName']),
      address: _str(details['sellerAddress']),
      imageUrl: _str(details['sellerImageUrl']),
      phone: _str(details['sellerPhone']),
      lat: _dbl(details['sellerLat']),
      lng: _dbl(details['sellerLng']),
      isVerified: details['sellerIsVerified'] == true,
      openStatus: details['sellerOpenStatus']?.toString(),
      openingHours: details['sellerOpeningHours']?.toString(),
    );

    final customerInfo = CustomerInfo(
      name: _str(details['customerName']),
      phone: _str(details['customerPhone']),
      deliveryAddress: _str(details['deliveryAddress']),
      deliveryNotes: _str(details['deliveryNotes']),
      lat: _dbl(details['customerLat']),
      lng: _dbl(details['customerLng']),
    );

    return TrackOrderLoaded(
      orderId: _str(details['orderId']),
      status: status,
      orderStatusLabel: _statusLabel(status),
      orderDate: confirmedTime,
      estimatedDelivery: _str(details['estimatedDelivery'], fallback: '30-40 mins'),
      etaMinutes: _int(details['etaMinutes']),
      trackingSteps: steps,
      deliveryPartner: deliveryPartner,
      sellerInfo: sellerInfo,
      customerInfo: customerInfo,
      driverLat: _dbl(details['driverLat']),
      driverLng: _dbl(details['driverLng']),
      sellerLat: _dbl(details['sellerLat']),
      sellerLng: _dbl(details['sellerLng']),
      customerLat: _dbl(details['customerLat']),
      customerLng: _dbl(details['customerLng']),
      orderItems: orderItems,
      subtotal: _dbl(details['subtotal']),
      deliveryFee: _dbl(details['deliveryFee']),
      taxAmount: _dbl(details['taxAmount']),
      discountAmount: _dbl(details['discountAmount']),
      platformFee: _dbl(details['platformFee']),
      totalAmount: _dbl(details['totalAmount']) ?? 0.0,
      paymentMethod: _str(details['paymentMethod']),
      paymentStatus: _str(details['paymentStatus']),
      cancellationReason: details['cancellationReason']?.toString(),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.outForDelivery:
        return 'Out For Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  List<TrackingStep> _buildTrackingSteps(
    OrderStatus status,
    DateTime confirmedTime,
    DateFormat timeFormat,
    Map<String, dynamic> details,
  ) {
    DateTime? _ts(String key) {
      final val = details[key];
      if (val is DateTime) return val;
      return null;
    }

    final placedAt = _ts('timestamp') ?? confirmedTime;
    final acceptedAt = _ts('acceptedAt');
    final preparingAt = _ts('preparingAt');
    final outForDeliveryAt = _ts('pickedUpAt') ?? _ts('outForDeliveryAt');
    final deliveredAt = _ts('deliveredAt');
    final cancelledAt = _ts('cancelledAt') ?? _ts('rejectedAt') ?? confirmedTime;

    if (status == OrderStatus.cancelled || status == OrderStatus.rejected) {
      return [
        TrackingStep(
          title: 'Order Placed',
          time: timeFormat.format(placedAt),
          status: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Order Cancelled',
          time: timeFormat.format(cancelledAt),
          status: TrackingStatus.cancelled,
        ),
      ];
    }

    final completedUpTo = switch (status) {
      OrderStatus.newOrder => 0,
      OrderStatus.accepted => 1,
      OrderStatus.preparing => 2,
      OrderStatus.ready => 3,
      OrderStatus.pickedUp => 3,
      OrderStatus.outForDelivery => 3,
      OrderStatus.delivered => 5,
      OrderStatus.rejected => 0,
      OrderStatus.cancelled => 0,
    };

    final currentIdx = switch (status) {
      OrderStatus.newOrder => 0,
      OrderStatus.accepted => 1,
      OrderStatus.preparing => 2,
      OrderStatus.pickedUp => 3,
      OrderStatus.outForDelivery => 3,
      _ => -1,
    };

    TrackingStatus statusFor(int idx) {
      if (idx < completedUpTo) return TrackingStatus.completed;
      if (idx == currentIdx) return TrackingStatus.current;
      return TrackingStatus.upcoming;
    }

    return [
      TrackingStep(
        title: 'Order Placed',
        time: timeFormat.format(placedAt),
        status: statusFor(0),
      ),
      TrackingStep(
        title: 'Accepted',
        time: acceptedAt != null ? timeFormat.format(acceptedAt) : null,
        status: statusFor(1),
      ),
      TrackingStep(
        title: 'Preparing Your Food',
        time: preparingAt != null ? timeFormat.format(preparingAt) : null,
        status: statusFor(2),
      ),
      TrackingStep(
        title: 'Out for Delivery',
        time: outForDeliveryAt != null ? timeFormat.format(outForDeliveryAt) : null,
        status: statusFor(3),
      ),
      TrackingStep(
        title: 'Delivered',
        time: deliveredAt != null ? timeFormat.format(deliveredAt) : null,
        status: statusFor(4),
      ),
    ];
  }

  Future<void> _onRefreshTrackOrder(
    RefreshTrackOrder event,
    Emitter<TrackOrderState> emit,
  ) async {
    add(LoadTrackOrderDetails(orderId: event.orderId, orderDate: event.orderDate));
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<TrackOrderState> emit,
  ) async {
    try {
      _trackedRiderId = event.riderId;
      await repository.startTracking(event.riderId);
      _locationSubscription?.cancel();
      _locationSubscription = repository.locationStream.listen((location) {
        if (!isClosed) {
          add(UpdateDriverLocation(lat: location.lat, lng: location.lng));
        }
      });
    } catch (_) {
      _trackedRiderId = null;
    }
  }

  void _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<TrackOrderState> emit,
  ) {
    final currentState = state;
    if (currentState is TrackOrderLoaded) {
      emit(currentState.copyWith(driverLat: event.lat, driverLng: event.lng));
    }
  }

  void _onToggleMapFullScreen(
    ToggleMapFullScreen event,
    Emitter<TrackOrderState> emit,
  ) {
    final currentState = state;
    if (currentState is TrackOrderLoaded) {
      emit(currentState.copyWith(isMapExpanded: !currentState.isMapExpanded));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<TrackOrderState> emit,
  ) async {
    try {
      await repository.cancelOrder(event.orderId, reason: event.reason);
    } catch (_) {}
  }

  String _str(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    final s = v.toString();
    return s.isEmpty ? fallback : s;
  }

  double? _dbl(dynamic v) => v is num ? v.toDouble() : null;

  int? _int(dynamic v) => v is num ? v.toInt() : null;

  @override
  Future<void> close() {
    _orderStatusSubscription?.cancel();
    _locationSubscription?.cancel();
    _trackedRiderId = null;
    repository.stopTracking();
    return super.close();
  }
}
