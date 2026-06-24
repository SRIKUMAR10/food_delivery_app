import 'dart:async';
import 'Track_Order_page_service.dart';

abstract class TrackOrderRepository {
  /// Stream of driver location updates
  Stream<DriverLocation> get locationStream;

  /// Fetch initial order tracking details
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId);
  
  /// Start tracking the order
  Future<void> startTracking(String orderId);
  
  /// Stop tracking the order
  Future<void> stopTracking();
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
  
  TrackOrderRepositoryImpl({required this.service});

  @override
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) {
    return service.getOrderDetails(orderId);
  }

  @override
  Stream<DriverLocation> get locationStream {
    return service.connectDriverLocationSocket('dummy').map(
      (data) => DriverLocation(lat: data['lat'] ?? 0.0, lng: data['lng'] ?? 0.0),
    );
  }

  @override
  Future<void> startTracking(String orderId) async {
    // In a real app, initialize sockets or background services here
  }

  @override
  Future<void> stopTracking() async {
    // Clean up
  }
}

