import 'package:cloud_firestore/cloud_firestore.dart';
import 'disputes_refunds_page_model.dart';

class DisputesRefundsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DisputeModel>> fetchDisputes(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('disputes')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DisputeModel(
          id: doc.id,
          orderId: data['orderId'] ?? '',
          customerName: data['customerName'] ?? 'Unknown',
          reason: data['reason'] ?? '',
          status: data['status'] ?? 'Pending',
          refundAmount: (data['refundAmount'] ?? 0).toDouble(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch disputes: $e');
    }
  }

  Future<void> updateDisputeStatus(String sellerId, String disputeId, String newStatus) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('disputes')
          .doc(disputeId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Failed to update dispute status: $e');
    }
  }
}
