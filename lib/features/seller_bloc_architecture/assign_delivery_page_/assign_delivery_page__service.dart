import 'package:cloud_firestore/cloud_firestore.dart';

class AssignDeliveryService {
  final FirebaseFirestore _firestore;

  AssignDeliveryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAvailableRiders(String orderId) async {
    try {
      final snapshot = await _firestore.collection('riders').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown Rider',
          'rating': (data['rating'] as num?)?.toDouble() ?? 4.5,
          'distance': data['distance'] as String? ?? 'N/A',
          'imageUrl': data['imageUrl'] as String? ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load riders: $e');
    }
  }

  Future<bool> assignDelivery(String orderId, String riderId, String instructions) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'OutForDelivery',
        'riderId': riderId,
        'deliveryInstructions': instructions,
        'outForDeliveryAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to assign delivery: $e');
    }
  }
}
