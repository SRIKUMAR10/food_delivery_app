/// User Fixture Data
class UserFixture {
  static Map<String, dynamic> sampleBuyer({String uid = 'buyer_001'}) => {
    'uid': uid,
    'email': 'buyer@example.com',
    'displayName': 'Test Buyer',
    'role': 'buyer',
    'phoneNumber': '+919876543210',
    'createdAt': '2026-01-01T00:00:00.000Z',
  };

  static Map<String, dynamic> sampleSeller({String uid = 'seller_001'}) => {
    'uid': uid,
    'email': 'seller@example.com',
    'displayName': 'Test Seller Kitchen',
    'role': 'seller',
    'restaurantId': 'rest_001',
    'phoneNumber': '+919876543211',
    'isOnline': true,
  };

  static Map<String, dynamic> sampleDeliveryPartner({String uid = 'dp_001'}) => {
    'uid': uid,
    'email': 'delivery@example.com',
    'displayName': 'Test Driver',
    'role': 'delivery_partner',
    'vehicleType': 'motorcycle',
    'isAvailable': true,
    'currentLocation': {'latitude': 13.0827, 'longitude': 80.2707},
  };
}
