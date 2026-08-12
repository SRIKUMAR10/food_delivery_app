// Real-Time Firestore Stream Provider Standardized
import 'disputes_refunds_page_model.dart';
import 'disputes_refunds_page_service.dart';

class DisputesRefundsRepository {
  final DisputesRefundsService service;

  DisputesRefundsRepository({required this.service});

  Stream<List<DisputeModel>> streamDisputes(String sellerId) {
    return service.streamDisputes(sellerId);
  }

  Future<List<DisputeModel>> getDisputes(String sellerId) {
    return service.fetchDisputes(sellerId);
  }

  Future<void> resolveDispute(String sellerId, String disputeId, String status) {
    return service.updateDisputeStatus(sellerId, disputeId, status);
  }
}
