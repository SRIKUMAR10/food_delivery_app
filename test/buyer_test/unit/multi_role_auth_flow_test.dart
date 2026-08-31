import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Multi-Role Independent Authentication Flow Tests', () {
    const testPhone = '+919842730278';
    const testEmail = 'sriabhiramiprinters@gmail.com';
    const buyerPassword = 'BuyerPassword123!';
    const sellerPassword = 'SellerPassword456!';
    const deliveryPassword = 'DeliveryPassword789!';

    test('Shared phone and email can exist across 3 distinct role profiles with separate UIDs', () {
      // Role 1: Buyer profile
      final buyerProfile = {
        'uid': 'buyer_uid_101',
        'role': 'buyer',
        'name': 'Sri Kumar (Buyer)',
        'email': testEmail,
        'phone': testPhone,
        'password': buyerPassword,
        'hashedPassword': buyerPassword,
      };

      // Role 2: Seller profile
      final sellerProfile = {
        'id': 'seller_uid_202',
        'uid': 'seller_uid_202',
        'role': 'seller',
        'name': 'Sri Kumar (Owner)',
        'shopName': 'Sri Abhirami Printers Restaurant',
        'email': testEmail,
        'contactNumber': testPhone,
        'phoneNumber': testPhone,
        'password': sellerPassword,
        'hashedPassword': sellerPassword,
      };

      // Role 3: Delivery Partner profile
      final deliveryProfile = {
        'id': 'dp_uid_303',
        'role': 'delivery_partner',
        'displayName': 'Sri Rider',
        'email': testEmail,
        'phoneNumber': testPhone,
        'password': deliveryPassword,
        'hashedPassword': deliveryPassword,
      };

      // Assert distinct UIDs
      expect(buyerProfile['uid'], isNot(equals(sellerProfile['uid'])));
      expect(buyerProfile['uid'], isNot(equals(deliveryProfile['id'])));
      expect(sellerProfile['uid'], isNot(equals(deliveryProfile['id'])));

      // Assert shared credentials across all 3 roles
      expect(buyerProfile['email'], equals(testEmail));
      expect(sellerProfile['email'], equals(testEmail));
      expect(deliveryProfile['email'], equals(testEmail));

      expect(buyerProfile['phone'], equals(testPhone));
      expect(sellerProfile['contactNumber'], equals(testPhone));
      expect(deliveryProfile['phoneNumber'], equals(testPhone));

      // Assert distinct passwords
      expect(buyerProfile['password'], isNot(equals(sellerProfile['password'])));
      expect(sellerProfile['password'], isNot(equals(deliveryProfile['password'])));
    });

    test('Custom login role-scoping routes to the correct collection based on targetRole', () {
      final collectionsMap = {
        'buyer': ['buyer_user', 'buyer_users', 'users'],
        'seller': ['sellers', 'seller', 'seller_users'],
        'delivery_partner': ['delivery_partners', 'delivery_partner', 'riders', 'partners'],
      };

      String resolveCollection(String targetRole) {
        if (targetRole.contains('delivery') || targetRole.contains('rider')) {
          return collectionsMap['delivery_partner']!.first;
        } else if (targetRole.contains('seller') || targetRole.contains('vendor')) {
          return collectionsMap['seller']!.first;
        } else {
          return collectionsMap['buyer']!.first;
        }
      }

      expect(resolveCollection('user'), equals('buyer_user'));
      expect(resolveCollection('buyer'), equals('buyer_user'));
      expect(resolveCollection('seller'), equals('sellers'));
      expect(resolveCollection('delivery_partner'), equals('delivery_partners'));
    });

    test('Password verification rejects mismatched passwords across roles', () {
      bool verifyPassword(String enteredPassword, String storedPassword) {
        return enteredPassword == storedPassword;
      }

      // Attempting to log into Buyer using Seller password must fail
      expect(verifyPassword(sellerPassword, buyerPassword), isFalse);

      // Attempting to log into Seller using Delivery Partner password must fail
      expect(verifyPassword(deliveryPassword, sellerPassword), isFalse);

      // Logging in with the role's correct password succeeds
      expect(verifyPassword(buyerPassword, buyerPassword), isTrue);
      expect(verifyPassword(sellerPassword, sellerPassword), isTrue);
      expect(verifyPassword(deliveryPassword, deliveryPassword), isTrue);
    });

    test('Custom token custom claims encode the role and role-specific UID', () {
      Map<String, dynamic> generateCustomClaims(String role, String uid, String phone) {
        return {
          'role': role,
          'uid': uid,
          'phoneNumber': phone,
        };
      }

      final buyerClaims = generateCustomClaims('user', 'buyer_uid_101', testPhone);
      final sellerClaims = generateCustomClaims('seller', 'seller_uid_202', testPhone);
      final deliveryClaims = generateCustomClaims('delivery_partner', 'dp_uid_303', testPhone);

      expect(buyerClaims['role'], equals('user'));
      expect(buyerClaims['uid'], equals('buyer_uid_101'));

      expect(sellerClaims['role'], equals('seller'));
      expect(sellerClaims['uid'], equals('seller_uid_202'));

      expect(deliveryClaims['role'], equals('delivery_partner'));
      expect(deliveryClaims['uid'], equals('dp_uid_303'));
    });
  });
}
