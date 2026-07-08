import 'package:cloud_firestore/cloud_firestore.dart';

class SellerModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? shopName;
  final String? businessDetails;
  final String authProvider;
  final bool isVerified;
  final DateTime createdAt;

  SellerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.shopName,
    this.businessDetails,
    this.authProvider = 'password',
    this.isVerified = false,
    required this.createdAt,
  });

  factory SellerModel.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return SellerModel(
      id: snapshot.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      role: data?['role'] ?? 'seller',
      phoneNumber: data?['phoneNumber'],
      shopName: data?['shopName'],
      businessDetails: data?['businessDetails'],
      authProvider: data?['authProvider'] ?? 'password',
      isVerified: data?['isVerified'] ?? false,
      createdAt: data?['createdAt'] != null
          ? (data!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'shopName': shopName,
      'businessDetails': businessDetails,
      'authProvider': authProvider,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
