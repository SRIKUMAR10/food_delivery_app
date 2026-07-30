import '../../core/models/seller_model.dart';

abstract interface class ISellerRepository {
  Future<double> getGstPercentage(String sellerId);
  Future<SellerModel?> getSeller(String sellerId);
}
