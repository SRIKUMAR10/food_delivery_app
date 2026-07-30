import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Track_Order_page_event.dart';
import 'Track_Order_page_state.dart';
import 'Track_Order_page_repository.dart';
import 'Track_Order_page_service.dart';
import '../../../core/repositories/i_order_repository.dart';

class TrackOrderBloc extends Bloc<TrackOrderEvent, TrackOrderState> {
  final TrackOrderRepository repository;
  final IOrderRepository orderRepository;
  final TrackOrderService trackService;
  StreamSubscription<DriverLocation>? _locationSubscription;
  StreamSubscription? _orderStatusSubscription;

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
  }

  Future<void> _onLoadTrackOrderDetails(
    LoadTrackOrderDetails event,
    Emitter<TrackOrderState> emit,
  ) async {
    emit(TrackOrderLoading());
    try {
      final details = await trackService.getOrderDetails(event.orderId);

      final confirmedTime = event.orderDate;
      final timeFormat = DateFormat('hh:mm a');
      final status = details['status'] as String? ?? 'New';

      _listenToOrderStatus(event.orderId, confirmedTime);

      final steps = _buildTrackingSteps(status, confirmedTime, timeFormat, details);

      final driverLat = details['driverLat'] as double?;
      final driverLng = details['driverLng'] as double?;

      emit(TrackOrderLoaded(
        orderId: event.orderId,
        estimatedDelivery: details['estimatedDelivery'] ?? '30-40 mins',
        trackingSteps: steps,
        deliveryPartner: DeliveryPartner(
          name: details['driverName'] as String? ?? '',
          role: 'Your Delivery Partner',
          imageUrl: details['driverImage'] as String? ?? '',
          phone: details['driverPhone'] as String? ?? '',
        ),
        sellerInfo: SellerInfo(
          id: details['sellerId'] ?? '',
          name: details['sellerName'] ?? 'Seller',
          address: details['sellerAddress'] ?? '',
          imageUrl: details['sellerImageUrl'] ?? '',
          phone: details['sellerPhone'] ?? '',
        ),
        driverLat: driverLat,
        driverLng: driverLng,
      ));

      if (status == 'OutForDelivery' || status == 'outForDelivery') {
        add(StartTracking(orderId: event.orderId));
      }
    } catch (e) {
      emit(TrackOrderError(e.toString()));
    }
  }

  void _listenToOrderStatus(String orderId, DateTime orderDate) {
    _orderStatusSubscription?.cancel();
    _orderStatusSubscription = trackService.watchOrder(orderId).listen((snapshot) {
      if (!snapshot.exists || isClosed) return;
      add(OrderStatusUpdated(orderId: orderId, orderDate: orderDate));
    }, onError: (_) {});
  }

  Future<void> _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<TrackOrderState> emit,
  ) async {
    try {
      final details = await trackService.getOrderDetails(event.orderId);
      final currentState = state;
      if (currentState is! TrackOrderLoaded) return;

      final status = details['status'] as String? ?? 'New';
      final confirmedTime = event.orderDate;
      final timeFormat = DateFormat('hh:mm a');
      final steps = _buildTrackingSteps(status, confirmedTime, timeFormat, details);

      final driverLat = details['driverLat'] as double? ?? currentState.driverLat;
      final driverLng = details['driverLng'] as double? ?? currentState.driverLng;

      emit(TrackOrderLoaded(
        orderId: currentState.orderId,
        estimatedDelivery: details['estimatedDelivery'] ?? currentState.estimatedDelivery,
        trackingSteps: steps,
        deliveryPartner: DeliveryPartner(
          name: details['driverName'] as String? ?? currentState.deliveryPartner.name,
          role: 'Your Delivery Partner',
          imageUrl: details['driverImage'] as String? ?? currentState.deliveryPartner.imageUrl,
          phone: details['driverPhone'] as String? ?? currentState.deliveryPartner.phone,
        ),
        sellerInfo: SellerInfo(
          id: details['sellerId'] ?? currentState.sellerInfo?.id ?? '',
          name: details['sellerName'] ?? currentState.sellerInfo?.name ?? 'Seller',
          address: details['sellerAddress'] ?? currentState.sellerInfo?.address ?? '',
          imageUrl: details['sellerImageUrl'] ?? currentState.sellerInfo?.imageUrl ?? '',
          phone: details['sellerPhone'] ?? currentState.sellerInfo?.phone ?? '',
        ),
        driverLat: driverLat,
        driverLng: driverLng,
      ));

      if ((status == 'OutForDelivery' || status == 'outForDelivery') && _locationSubscription == null) {
        add(StartTracking(orderId: event.orderId));
      }
    } catch (_) {}
  }

  List<TrackingStep> _buildTrackingSteps(
    String status,
    DateTime confirmedTime,
    DateFormat timeFormat,
    Map<String, dynamic> details,
  ) {
    DateTime? _ts(String key) {
      final val = details[key];
      if (val is DateTime) return val;
      return null;
    }

    final preparingAt = _ts('preparingAt');
    final outForDeliveryAt = _ts('outForDeliveryAt');
    final deliveredAt = _ts('deliveredAt');
    final rejectedAt = _ts('rejectedAt');
    final cancelledAt = _ts('cancelledAt');

    final isCancelledOrRejected = status.toLowerCase() == 'rejected' || status.toLowerCase() == 'cancelled';

    if (isCancelledOrRejected) {
      final cancelTime = cancelledAt ?? rejectedAt ?? confirmedTime;
      return [
        TrackingStep(
          title: 'Order Confirmed',
          time: timeFormat.format(confirmedTime),
          status: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Order Cancelled',
          time: timeFormat.format(cancelTime),
          status: TrackingStatus.cancelled,
        ),
      ];
    }

    final orderConfirmed = status == 'Delivered' || status == 'OutForDelivery' || status == 'Ready' || status == 'Preparing' || status == 'Accepted' || status == 'New';
    final preparing = status == 'Delivered' || status == 'OutForDelivery' || status == 'Ready' || status == 'Preparing';
    final outForDelivery = status == 'Delivered' || status == 'OutForDelivery';
    final delivered = status == 'Delivered';

    return [
      TrackingStep(
        title: 'Order Confirmed',
        time: timeFormat.format(confirmedTime),
        status: orderConfirmed ? TrackingStatus.completed : TrackingStatus.current,
      ),
      TrackingStep(
        title: 'Preparing Your Food',
        time: preparingAt != null ? timeFormat.format(preparingAt) : null,
        status: preparing ? (status == 'Preparing' ? TrackingStatus.current : TrackingStatus.completed) : TrackingStatus.upcoming,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        time: outForDeliveryAt != null ? timeFormat.format(outForDeliveryAt) : null,
        status: outForDelivery ? (status == 'OutForDelivery' ? TrackingStatus.current : TrackingStatus.completed) : TrackingStatus.upcoming,
      ),
      TrackingStep(
        title: 'Delivered',
        time: deliveredAt != null ? timeFormat.format(deliveredAt) : null,
        status: delivered ? TrackingStatus.completed : TrackingStatus.future,
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
      await repository.startTracking(event.orderId);
      _locationSubscription?.cancel();
      _locationSubscription = repository.locationStream.listen((location) {
        if (!isClosed) {
          add(UpdateDriverLocation(lat: location.lat, lng: location.lng));
        }
      });
    } catch (_) {}
  }

  void _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<TrackOrderState> emit,
  ) {
    if (state is TrackOrderLoaded) {
      final currentState = state as TrackOrderLoaded;
      emit(TrackOrderLoaded(
        orderId: currentState.orderId,
        estimatedDelivery: currentState.estimatedDelivery,
        trackingSteps: currentState.trackingSteps,
        deliveryPartner: currentState.deliveryPartner,
        sellerInfo: currentState.sellerInfo,
        driverLat: event.lat,
        driverLng: event.lng,
      ));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<TrackOrderState> emit,
  ) async {
    try {
      await repository.cancelOrder(event.orderId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _orderStatusSubscription?.cancel();
    _locationSubscription?.cancel();
    repository.stopTracking();
    return super.close();
  }
}
