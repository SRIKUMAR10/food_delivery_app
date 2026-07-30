import 'dart:async';
import 'Track_Order_page_service.dart';

abstract class TrackOrderRepository {
  Stream<DriverLocation> get locationStream;

  Future<Map<String, dynamic>> fetchOrderDetails(String orderId);

  Future<void> startTracking(String orderId);

  Future<void> stopTracking();

  Future<void> cancelOrder(String orderId);
}

class DriverLocation {
  final double lat;
  final double lng;

  const DriverLocation({required this.lat, required this.lng});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverLocation &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
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
  Stream<DriverLocation> get locationStream => _locationController.stream;

  @override
  Future<void> startTracking(String orderId) async {
    final details = await service.getOrderDetails(orderId);
    final riderId = details['riderId'] as String?;
    if (riderId == null || riderId.isEmpty) return;

    await _locationSub?.cancel();

    _locationSub = service.riderLocationStream(riderId).listen(
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
  Future<void> cancelOrder(String orderId) {
    return service.cancelOrder(orderId);
  }

  void dispose() {
    _locationSub?.cancel();
    _locationController.close();
  }
}

