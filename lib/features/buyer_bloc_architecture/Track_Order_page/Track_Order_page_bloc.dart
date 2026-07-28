import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Track_Order_page_event.dart';
import 'Track_Order_page_state.dart';
import 'Track_Order_page_repository.dart';

class TrackOrderBloc extends Bloc<TrackOrderEvent, TrackOrderState> {
  final TrackOrderRepository repository;
  StreamSubscription<DriverLocation>? _locationSubscription;

  TrackOrderBloc({required this.repository}) : super(TrackOrderInitial()) {
    on<LoadTrackOrderDetails>(_onLoadTrackOrderDetails);
    on<RefreshTrackOrder>(_onRefreshTrackOrder);
    on<StartTracking>(_onStartTracking);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
  }

  Future<void> _onLoadTrackOrderDetails(
    LoadTrackOrderDetails event,
    Emitter<TrackOrderState> emit,
  ) async {
    emit(TrackOrderLoading());
    try {
      final details = await repository.fetchOrderDetails(event.orderId);

      final confirmedTime = event.orderDate;
      final timeFormat = DateFormat('hh:mm a');
      final status = details['status'] as String? ?? 'New';

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

  List<TrackingStep> _buildTrackingSteps(
    String status,
    DateTime confirmedTime,
    DateFormat timeFormat,
    Map<String, dynamic> details,
  ) {
    DateTime? _ts(String key) => details[key] as DateTime?;

    final acceptedAt = _ts('acceptedAt');
    final preparingAt = _ts('preparingAt') ?? (acceptedAt != null ? acceptedAt.add(const Duration(minutes: 5)) : confirmedTime.add(const Duration(minutes: 5)));
    final outForDeliveryAt = _ts('outForDeliveryAt') ?? (preparingAt.add(const Duration(minutes: 15)));
    final deliveredAt = _ts('deliveredAt') ?? (outForDeliveryAt.add(const Duration(minutes: 15)));

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
        time: preparing ? timeFormat.format(preparingAt) : null,
        status: preparing ? (status == 'Preparing' ? TrackingStatus.current : TrackingStatus.completed) : TrackingStatus.upcoming,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        time: outForDelivery ? timeFormat.format(outForDeliveryAt) : null,
        status: outForDelivery ? (status == 'OutForDelivery' ? TrackingStatus.current : TrackingStatus.completed) : TrackingStatus.upcoming,
      ),
      TrackingStep(
        title: 'Delivered',
        time: delivered ? timeFormat.format(deliveredAt) : null,
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
    } catch (e) {
      // Ignore error to avoid wiping out the loaded UI
    }
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

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    repository.stopTracking();
    return super.close();
  }
}
