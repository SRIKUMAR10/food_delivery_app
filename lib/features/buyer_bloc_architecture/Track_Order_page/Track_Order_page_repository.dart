// Real-Time Firestore Stream Provider Standardized
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'Track_Order_page_service.dart';

abstract class TrackOrderRepository {
  Stream<DriverLocation> get locationStream;

  Future<Map<String, dynamic>> fetchOrderDetails(String orderId);

  /// Real-time stream of the order document.
  Stream<DocumentSnapshot> watchOrder(String orderId);

  /// Real-time stream of the assigned rider / delivery partner location.
  Stream<Map<String, dynamic>> driverLocationStream(String riderId);

  Future<void> startTracking(String riderId);

  Future<void> stopTracking();

  Future<void> cancelOrder(String orderId, {String? reason});
}

class TrackOrderRepositoryImpl implements TrackOrderRepository {
  final TrackOrderService service;
  StreamSubscription<Map<String, dynamic>>? _locationSub;

  final StreamController<DriverLocation> _locationController =
      StreamController<DriverLocation>.broadcast();

  TrackOrderRepositoryImpl({required this.service});

  @override
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) {
    return service.getOrderDetails(orderId);
  }

  @override
  Stream<DocumentSnapshot> watchOrder(String orderId) {
    return service.watchOrder(orderId);
  }

  @override
  Stream<Map<String, dynamic>> driverLocationStream(String riderId) {
    return service.riderLocationStream(riderId);
  }

  @override
  Stream<DriverLocation> get locationStream => _locationController.stream;

  @override
  Future<void> startTracking(String riderId) async {
    if (riderId.isEmpty) return;

    await _locationSub?.cancel();

    _locationSub = driverLocationStream(riderId).listen(
      (data) {
        if (!_locationController.isClosed) {
          _locationController.add(DriverLocation(
            lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
            lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      },
      onError: (e) {
        if (!_locationController.isClosed) {
          _locationController.addError(e);
        }
      },
    );
  }

  @override
  Future<void> stopTracking() async {
    await _locationSub?.cancel();
    _locationSub = null;
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) {
    return service.cancelOrder(orderId, reason: reason);
  }

  void dispose() {
    _locationSub?.cancel();
    _locationController.close();
  }
}
