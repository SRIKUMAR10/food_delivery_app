import 'dart:async';
import 'package:http/http.dart' as http;

class TrackOrderService {
  final http.Client httpClient;

  TrackOrderService({required this.httpClient});

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));

    // Returning dummy data instead of failing so the UI can render
    return {
      'estimatedDelivery': '30-40 mins',
      'driverName': 'Jane Doe',
      'driverImage': 'https://i.pravatar.cc/150?img=11',
      'driverPhone': '+1234567890',
    };
  }

  // Simulating a WebSocket Stream for location
  Stream<Map<String, dynamic>> connectDriverLocationSocket(String orderId) {
    // In a real app, this would use web_socket_channel
    final controller = StreamController<Map<String, dynamic>>();
    // We don't implement the real socket here for brevity, but the interface exists.
    return controller.stream;
  }
}
