import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_hours_validator.dart';

class SellerAvailability {
  final bool isOnline;
  final bool isOpen;
  bool get isAvailable => isOnline && isOpen;
  final String? message;

  const SellerAvailability({
    required this.isOnline,
    required this.isOpen,
    this.message,
  });
}

class SellerStatusService {
  final FirebaseFirestore _firestore;
  final BusinessHoursValidator _hoursValidator;

  SellerStatusService({
    FirebaseFirestore? firestore,
    BusinessHoursValidator? hoursValidator,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _hoursValidator = hoursValidator ?? BusinessHoursValidator();

  Stream<SellerAvailability> watchSellerStatus(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) {
        return const SellerAvailability(isOnline: false, isOpen: false);
      }
      final isOnline = snapshot.data()?['isOnline'] as bool? ?? false;
      final hoursResult = await _hoursValidator.validateSeller(sellerId);
      return SellerAvailability(
        isOnline: isOnline,
        isOpen: hoursResult.isOpen,
        message: hoursResult.isOpen
            ? null
            : hoursResult.message,
      );
    });
  }

  Future<SellerAvailability> checkAvailability(String sellerId) async {
    try {
      final doc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();
      if (!doc.exists) {
        return const SellerAvailability(isOnline: false, isOpen: false);
      }
      final isOnline = doc.data()?['isOnline'] as bool? ?? false;
      final hoursResult = await _hoursValidator.validateSeller(sellerId);
      return SellerAvailability(
        isOnline: isOnline,
        isOpen: hoursResult.isOpen,
        message: hoursResult.isOpen ? null : hoursResult.message,
      );
    } catch (_) {
      return const SellerAvailability(isOnline: false, isOpen: true);
    }
  }

  Future<void> setOnline(String sellerId, bool isOnline) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .update({'isOnline': isOnline});
  }
}
