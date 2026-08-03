import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliveryForgotPasswordRepositoryBase {
  Future<void> sendPasswordResetEmail(String email);
}

class DeliveryForgotPasswordRepository
    implements DeliveryForgotPasswordRepositoryBase {
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryForgotPasswordRepository({DeliveryPartnerRepository? partnerRepo})
      : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _partnerRepo.sendPasswordResetEmail(email);
  }
}
