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
      final preparingTime = confirmedTime.add(const Duration(minutes: 5));
      final outForDeliveryTime = confirmedTime.add(const Duration(minutes: 20));

      final timeFormat = DateFormat('hh:mm a');

      emit(TrackOrderLoaded(
        orderId: event.orderId,
        estimatedDelivery: details['estimatedDelivery'] ?? '30-40 mins',
        trackingSteps: [
          TrackingStep(title: 'Order Confirmed', time: timeFormat.format(confirmedTime), status: TrackingStatus.completed),
          TrackingStep(title: 'Preparing Your Food', time: timeFormat.format(preparingTime), status: TrackingStatus.current),
          TrackingStep(title: 'Out for Delivery', time: timeFormat.format(outForDeliveryTime), status: TrackingStatus.upcoming),
          const TrackingStep(title: 'Delivered', time: 'Upcoming', status: TrackingStatus.future),
        ],
        deliveryPartner: DeliveryPartner(
          name: details['driverName'] ?? 'John D.',
          role: 'Your Delivery Partner',
          imageUrl: details['driverImage'] ?? 'https://i.pravatar.cc/150?img=11',
          phone: details['driverPhone'] ?? '+1234567890',
        ),
        sellerInfo: SellerInfo(
          id: details['sellerId'] ?? '',
          name: details['sellerName'] ?? 'Seller',
          address: details['sellerAddress'] ?? '',
          imageUrl: details['sellerImageUrl'] ?? '',
          phone: details['sellerPhone'] ?? '',
        ),
      ));
    } catch (e) {
      emit(TrackOrderError(e.toString()));
    }
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
    emit(TrackingLoading());
    try {
      await repository.startTracking('dummy_order');
      _locationSubscription?.cancel();
      _locationSubscription = repository.locationStream.listen((location) {
        if (!isClosed) {
          add(UpdateDriverLocation(lat: location.lat, lng: location.lng));
        }
      });
    } catch (e) {
      emit(TrackOrderError(e.toString()));
    }
  }

  void _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<TrackOrderState> emit,
  ) {
    emit(LocationUpdated(lat: event.lat, lng: event.lng));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    repository.stopTracking();
    return super.close();
  }
}
