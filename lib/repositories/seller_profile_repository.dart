import '../api_service/seller_profile_service.dart';

class SellerProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String storeName;
  final String storeDescription;
  final String avatarUrl;
  final double rating;
  final int totalOrders;
  final DateTime memberSince;
  final bool isVerified;
  final String address;
  final bool bankAccountLinked;

  SellerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.storeName,
    required this.storeDescription,
    required this.avatarUrl,
    required this.rating,
    required this.totalOrders,
    required this.memberSince,
    required this.isVerified,
    required this.address,
    required this.bankAccountLinked,
  });
}

class SellerProfileRepository {
  final SellerProfileService service;

  SellerProfileRepository({required this.service});

  Future<SellerProfile> getProfile() async {
    final raw = await service.fetchProfile();
    return SellerProfile(
      id: raw['id'] ?? '',
      name: raw['name'] ?? '',
      email: raw['email'] ?? '',
      phone: raw['phone'] ?? '',
      storeName: raw['storeName'] ?? '',
      storeDescription: raw['storeDescription'] ?? '',
      avatarUrl: raw['avatarUrl'] ?? '',
      rating: (raw['rating'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (raw['totalOrders'] as num?)?.toInt() ?? 0,
      memberSince: raw['memberSince'] != null
          ? DateTime.parse(raw['memberSince'])
          : DateTime.now(),
      isVerified: raw['isVerified'] ?? false,
      address: raw['address'] ?? '',
      bankAccountLinked: raw['bankAccountLinked'] ?? false,
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    return await service.updateProfile(updates);
  }

  Future<bool> deleteAccount() async {
    return await service.deleteAccount();
  }
}
