import 'disputes_refunds_page_model.dart';
import 'disputes_refunds_page_service.dart';

class DisputesRefundsRepository {
  final DisputesRefundsService service;

  DisputesRefundsRepository({required this.service});

  Future<List<DisputeModel>> getDisputes(String sellerId) {
    return service.fetchDisputes(sellerId);
  }

  Future<void> resolveDispute(String sellerId, String disputeId, String status) {
    return service.updateDisputeStatus(sellerId, disputeId, status);
  }
}
