import 'package:cloud_firestore/cloud_firestore.dart';

class AssignDeliveryService {
  final FirebaseFirestore _firestore;

  AssignDeliveryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAvailableRiders(String orderId) {
    return _firestore.collection('delivery_partners').snapshots().asyncExpand(
      (dpSnapshot) {
        if (dpSnapshot.docs.isNotEmpty) {
          return Stream.value(dpSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['displayName'] ?? data['name'],
              'rating': (data['rating'] as num?)?.toDouble(),
              'distance': data['distance'],
              'imageUrl': data['photoUrl'] ?? data['imageUrl'],
            };
          }).toList());
        }
        return _firestore.collection('riders').snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'],
              'rating': (data['rating'] as num?)?.toDouble(),
              'distance': data['distance'],
              'imageUrl': data['imageUrl'],
            };
          }).toList();
        });
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAvailableRiders(String orderId) async {
    try {
      final dpSnapshot = await _firestore.collection('delivery_partners').get();
      if (dpSnapshot.docs.isNotEmpty) {
        return dpSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['displayName'] ?? data['name'],
            'rating': (data['rating'] as num?)?.toDouble(),
            'distance': data['distance'],
            'imageUrl': data['photoUrl'] ?? data['imageUrl'],
          };
        }).toList();
      }
      final snapshot = await _firestore.collection('riders').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'rating': (data['rating'] as num?)?.toDouble(),
          'distance': data['distance'],
          'imageUrl': data['imageUrl'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load riders: $e');
    }
  }

  Future<bool> assignDelivery(
    String orderId,
    String riderId,
    String instructions,
  ) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);

      // Fetch rider metadata
      String riderName = 'Delivery Partner';
      String riderPhone = '';
      try {
        final dpDoc = await _firestore.collection('delivery_partners').doc(riderId).get();
        if (dpDoc.exists) {
          final data = dpDoc.data() ?? {};
          riderName = data['displayName'] as String? ?? data['name'] as String? ?? riderName;
          riderPhone = data['phoneNumber'] as String? ?? data['phone'] as String? ?? riderPhone;
        } else {
          final rDoc = await _firestore.collection('riders').doc(riderId).get();
          if (rDoc.exists) {
            final data = rDoc.data() ?? {};
            riderName = data['name'] as String? ?? riderName;
            riderPhone = data['phone'] as String? ?? riderPhone;
          }
        }
      } catch (_) {}

      await _firestore.runTransaction((transaction) async {
        final orderSnap = await transaction.get(orderRef);
        if (!orderSnap.exists) {
          throw Exception('Order not found');
        }
        final currentStatus = orderSnap.data()?['status'] as String?;
        final cleanStatus = (currentStatus ?? '').toLowerCase().replaceAll('_', '').replaceAll(' ', '');
        if (cleanStatus != 'ready' && cleanStatus != 'readyforpickup') {
          throw Exception(
            'Order must be in "Ready" status before assigning a delivery partner. '
            'Current status: $currentStatus',
          );
        }
        transaction.update(orderRef, {
          'status': 'ready',
          'riderId': riderId,
          'deliveryPartnerId': riderId,
          'driverId': riderId,
          'deliveryPartnerName': riderName,
          'deliveryPartnerPhone': riderPhone,
          'deliveryPartnerStatus': 'assigned',
          'pickupStatus': 'heading_to_store',
          'deliveryInstructions': instructions,
          'assignedAt': FieldValue.serverTimestamp(),
          'outForDeliveryAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      throw Exception('Failed to assign delivery: $e');
    }
  }
}
