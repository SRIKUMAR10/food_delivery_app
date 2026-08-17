import 'package:cloud_firestore/cloud_firestore.dart';

class BackfillOrdersService {
  final FirebaseFirestore _firestore;

  BackfillOrdersService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static bool _isPlaceholderName(String? name) {
    if (name == null) return true;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return true;
    final lower = trimmed.toLowerCase();
    return lower == 'customer' ||
        lower == 'buyer' ||
        lower == 'unknown customer' ||
        lower == 'unknown' ||
        lower == '?' ||
        lower == 'null';
  }

  static bool _isPlaceholderPhone(String? phone) {
    if (phone == null) return true;
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return true;
    final lower = trimmed.toLowerCase();
    return lower == 'n/a' || lower == 'none' || lower == 'null' || lower == 'phone not provided';
  }

  static bool _isPlaceholderAddress(String? address) {
    if (address == null) return true;
    final trimmed = address.trim();
    if (trimmed.isEmpty) return true;
    final lower = trimmed.toLowerCase();
    return lower == 'primary address' ||
        lower == 'default address' ||
        lower == 'n/a' ||
        lower == 'null' ||
        lower == 'no address' ||
        lower == 'none' ||
        lower == 'select address' ||
        lower == 'not set' ||
        lower == 'address not specified';
  }

  /// One-time backfill migration strategy to update existing order snapshots.
  Future<int> runBackfillMigration(String sellerId) async {
    if (sellerId.isEmpty) return 0;
    int updatedCount = 0;
    try {
      final ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .limit(100)
          .get();
      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final currentName = data['customerName'] as String?;
        final currentPhone = data['customerPhone'] as String?;
        final currentAddress = data['deliveryAddress'] as String?;
        final customerId = (data['customerId'] ?? data['buyerId'] ?? data['userId'] ?? data['customer_id'] ?? data['uid']) as String?;

        final needsName = _isPlaceholderName(currentName);
        final needsPhone = _isPlaceholderPhone(currentPhone);
        final needsAddress = _isPlaceholderAddress(currentAddress);

        if ((needsName || needsPhone || needsAddress) && customerId != null && customerId.trim().isNotEmpty) {
          try {
            final userDoc = await _firestore.collection('buyer_user').doc(customerId.trim()).get();
            if (userDoc.exists && userDoc.data() != null) {
              final uData = userDoc.data()!;
              final updates = <String, dynamic>{};

              if (needsName) {
                final uName = uData['name'] ?? uData['displayName'] ?? uData['fullName'] ?? uData['userName'];
                if (uName is String && !_isPlaceholderName(uName)) {
                  updates['customerName'] = uName.trim();
                }
              }

              if (needsPhone) {
                final uPhone = uData['phone'] ?? uData['phoneNumber'] ?? uData['mobile'] ?? uData['userPhone'] ?? uData['contactNumber'];
                if (uPhone is String && !_isPlaceholderPhone(uPhone)) {
                  updates['customerPhone'] = uPhone.trim();
                }
              }

              if (needsAddress) {
                String uAddr = '';
                final selType = (uData['selectedAddressType'] as String? ?? '').toLowerCase().trim();
                if (selType == 'home' && uData['homeAddress'] != null) {
                  uAddr = uData['homeAddress'].toString().trim();
                } else if (selType == 'work' && uData['workAddress'] != null) {
                  uAddr = uData['workAddress'].toString().trim();
                } else if (selType == 'other' && uData['otherAddress'] != null) {
                  uAddr = uData['otherAddress'].toString().trim();
                } else if (uData['address'] != null) {
                  uAddr = uData['address'].toString().trim();
                }

                if (uAddr.isEmpty) {
                  for (final k in ['deliveryAddress', 'primaryAddress', 'homeAddress', 'workAddress', 'userAddress']) {
                    final val = uData[k];
                    if (val is String && !_isPlaceholderAddress(val)) {
                      uAddr = val.trim();
                      break;
                    }
                  }
                }

                if (uAddr.isNotEmpty && !_isPlaceholderAddress(uAddr)) {
                  updates['deliveryAddress'] = uAddr;
                  updates['deliveryAddressSnapshot'] = uAddr;
                }
              }

              if (updates.isNotEmpty) {
                updates['backfilledAt'] = FieldValue.serverTimestamp();
                await _firestore.collection('orders').doc(doc.id).update(updates);
                updatedCount++;
              }
            }
          } catch (e) {
            // Silently skip if security rules restrict client-side reading of other users' profile documents
          }
        }
      }
    } catch (e) {
      // Silently catch query exceptions
    }
    return updatedCount;
  }
}
