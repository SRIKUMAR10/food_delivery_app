import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'promotions_coupons_page_model.dart';

class PromotionsCouponsService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PromotionsCouponsService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Stream<List<CouponModel>> streamCoupons(String sellerId) {
    if (sellerId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('coupons')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return CouponModel.fromMap(doc.data(), doc.id);
      }).toList();

      // Sort by creation date or start date descending for real-time list
      list.sort((a, b) {
        final aTime = a.createdAt ?? a.startDate;
        final bTime = b.createdAt ?? b.startDate;
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  Future<List<CouponModel>> fetchCoupons(String sellerId) async {
    if (sellerId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('coupons')
          .get();

      final list = snapshot.docs.map((doc) {
        return CouponModel.fromMap(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) {
        final aTime = a.createdAt ?? a.startDate;
        final bTime = b.createdAt ?? b.startDate;
        return bTime.compareTo(aTime);
      });
      return list;
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
      throw Exception('Failed to fetch coupons: $e');
    }
  }

  Future<CouponModel> addCoupon(String sellerId, CouponModel coupon) async {
    try {
      final docRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('coupons')
          .doc();

      final data = coupon.toMap();
      data['sellerId'] = sellerId;
      data['usedCount'] = 0;
      data['customerUsage'] = {};
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);

      return coupon.copyWith(
        id: docRef.id,
        sellerId: sellerId,
        usedCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error adding coupon: $e');
      throw Exception('Failed to add coupon: $e');
    }
  }

  Future<CouponModel> updateCoupon(String sellerId, CouponModel coupon) async {
    try {
      final docRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('coupons')
          .doc(coupon.id);

      final data = coupon.toMap();
      data['sellerId'] = sellerId;
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(data);
      return coupon.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      debugPrint('Error updating coupon: $e');
      throw Exception('Failed to update coupon: $e');
    }
  }

  Future<void> deleteCoupon(String sellerId, String couponId) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('coupons')
          .doc(couponId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
      throw Exception('Failed to delete coupon: $e');
    }
  }

  Future<void> toggleCouponStatus(String sellerId, String couponId, bool isActive) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('coupons')
          .doc(couponId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error toggling coupon status: $e');
      throw Exception('Failed to toggle coupon status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSellerProducts(String sellerId) async {
    if (sellerId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Product',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'category': data['category'] as String? ?? '',
          'imageUrl': data['imageUrl'] as String? ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching seller products: $e');
      return [];
    }
  }

  Future<List<String>> fetchSellerCategories(String sellerId) async {
    try {
      final Set<String> categories = {};

      // 1. Fetch from global categories
      try {
        final globalSnap = await _firestore.collection('global_categories').get();
        for (final doc in globalSnap.docs) {
          final name = doc.data()['name'] as String?;
          if (name != null && name.isNotEmpty) {
            categories.add(name);
          }
        }
      } catch (_) {}

      // 2. Fetch from seller menu preferences
      if (sellerId.isNotEmpty) {
        try {
          final prefSnap = await _firestore
              .collection('sellers')
              .doc(sellerId)
              .collection('menu_preferences')
              .get();
          for (final doc in prefSnap.docs) {
            final name = doc.data()['name'] as String? ?? doc.id;
            if (name.isNotEmpty) {
              categories.add(name);
            }
          }
        } catch (_) {}
      }

      // Default categories fallback
      if (categories.isEmpty) {
        categories.addAll(['Fried Chicken', 'Burgers', 'Pizza', 'Sides', 'Beverages', 'Desserts', 'Special Combos', 'Kids Meals']);
      }

      return categories.toList()..sort();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return ['Fried Chicken', 'Burgers', 'Pizza', 'Sides', 'Beverages', 'Desserts', 'Special Combos', 'Kids Meals'];
    }
  }

  /// Server-Side Coupon Validation via Cloud Functions (with client-side fallback)
  Future<CouponValidationResult> validateCouponServerSide({
    required String sellerId,
    required String couponCode,
    required double orderTotal,
    List<Map<String, dynamic>>? items,
    String? customerId,
  }) async {
    try {
      final callable = _functions.httpsCallable('validateCoupon');
      final result = await callable.call(<String, dynamic>{
        'sellerId': sellerId,
        'couponCode': couponCode.toUpperCase().trim(),
        'orderTotal': orderTotal,
        'items': items ?? [],
        'customerId': customerId ?? '',
      });

      if (result.data is Map) {
        final data = Map<String, dynamic>.from(result.data as Map);
        return CouponValidationResult.fromMap(data);
      }
      return CouponValidationResult.invalid(
        reason: 'Invalid server response',
        message: 'Unable to parse server validation result.',
      );
    } catch (e) {
      debugPrint('Server-side validateCoupon failed: $e. Running local fallback check.');
      // Local fallback for offline mode or test environment
      try {
        final snapshot = await _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('coupons')
            .where('code', isEqualTo: couponCode.toUpperCase().trim())
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final coupon = CouponModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          return coupon.validateDetailed(orderTotal, customerId: customerId, items: items);
        } else {
          return CouponValidationResult.invalid(
            reason: 'Coupon not found',
            message: 'Coupon code not found.',
          );
        }
      } catch (localError) {
        return CouponValidationResult.invalid(
          reason: 'Validation error',
          message: 'Failed to validate coupon: $localError',
        );
      }
    }
  }
}

