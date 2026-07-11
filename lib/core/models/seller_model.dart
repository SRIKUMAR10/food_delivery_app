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
  final String? profileImageUrl;
  final String? openingHours;
  final String? deliveryTime;
  final String? deliveryArea;
  final String? gstNumber;
  final String? fssaiNumber;
  final String? panNumber;
  final bool isOnline;
  final double gstPercentage;
  final double minimumOrderValue;
  final double packagingCharges;
  final String? bankAccountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? accountHolderName;
  final String? bankBranch;
  final bool notificationsEnabled;
  final String? taxConfiguration;

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
    this.profileImageUrl,
    this.openingHours,
    this.deliveryTime,
    this.deliveryArea,
    this.gstNumber,
    this.fssaiNumber,
    this.panNumber,
    this.isOnline = false,
    this.gstPercentage = 18.0,
    this.minimumOrderValue = 150.0,
    this.packagingCharges = 25.0,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.accountHolderName,
    this.bankBranch,
    this.notificationsEnabled = true,
    this.taxConfiguration,
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
      profileImageUrl: data?['profileImageUrl'],
      openingHours: data?['openingHours'],
      deliveryTime: data?['deliveryTime'],
      deliveryArea: data?['deliveryArea'],
      gstNumber: data?['gstNumber'],
      fssaiNumber: data?['fssaiNumber'],
      panNumber: data?['panNumber'],
      isOnline: data?['isOnline'] ?? false,
      gstPercentage: (data?['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      minimumOrderValue: (data?['minimumOrderValue'] as num?)?.toDouble() ?? 150.0,
      packagingCharges: (data?['packagingCharges'] as num?)?.toDouble() ?? 25.0,
      bankAccountNumber: data?['bankAccountNumber'],
      bankName: data?['bankName'],
      ifscCode: data?['ifscCode'],
      accountHolderName: data?['accountHolderName'],
      bankBranch: data?['bankBranch'],
      notificationsEnabled: data?['notificationsEnabled'] ?? true,
      taxConfiguration: data?['taxConfiguration'],
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
      'profileImageUrl': profileImageUrl,
      'openingHours': openingHours,
      'deliveryTime': deliveryTime,
      'deliveryArea': deliveryArea,
      'gstNumber': gstNumber,
      'fssaiNumber': fssaiNumber,
      'panNumber': panNumber,
      'isOnline': isOnline,
      'gstPercentage': gstPercentage,
      'minimumOrderValue': minimumOrderValue,
      'packagingCharges': packagingCharges,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'bankBranch': bankBranch,
      'notificationsEnabled': notificationsEnabled,
      'taxConfiguration': taxConfiguration,
    };
  }
}
