import 'package:cloud_firestore/cloud_firestore.dart';

class AssignDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAvailableRiders(String orderId) async {
    // Mocking a network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Returning mock data based on the provided design
    return [
      {
        'id': 'rider_1',
        'name': 'John Rider',
        'rating': 4.8,
        'distance': '2.3 km away',
        'imageUrl': 'https://i.pravatar.cc/150?u=john',
      },
      {
        'id': 'rider_2',
        'name': 'Mike Rider',
        'rating': 4.6,
        'distance': '3.1 km away',
        'imageUrl': 'https://i.pravatar.cc/150?u=mike',
      },
      {
        'id': 'rider_3',
        'name': 'Sam Rider',
        'rating': 4.7,
        'distance': '4.5 km away',
        'imageUrl': 'https://i.pravatar.cc/150?u=sam',
      },
    ];
  }

  Future<bool> assignDelivery(String orderId, String riderId, String instructions) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'Out for Delivery',
        'assignedRiderId': riderId,
        'deliveryInstructions': instructions,
      });
      return true;
    } catch (e) {
      print('Error assigning delivery: $e');
      return false;
    }
  }
}
