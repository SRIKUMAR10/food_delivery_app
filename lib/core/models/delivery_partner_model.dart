import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryPartnerModel {
  final String id;
  final String phoneNumber;
  final String countryCode;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final String role;
  final String status;
  final bool isActive;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isOnline;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? drivingLicense;
  final String? aadhaarNumber;
  final String kycStatus;
  final double totalEarnings;
  final int totalDeliveries;
  final double rating;
  final String? deviceToken;
  final String? appVersion;
  final bool isEmailVerified;
  final int profileCompletion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final DateTime? lastLogout;

  const DeliveryPartnerModel({
    required this.id,
    required this.phoneNumber,
    this.countryCode = '+91',
    this.displayName = '',
    this.email,
    this.photoUrl,
    this.role = 'delivery_partner',
    this.status = 'pending',
    this.isActive = false,
    this.isVerified = false,
    this.isPhoneVerified = true,
    this.isEmailVerified = false,
    this.profileCompletion = 0,
    this.isOnline = false,
    this.vehicleType,
    this.vehicleNumber,
    this.drivingLicense,
    this.aadhaarNumber,
    this.kycStatus = 'pending',
    this.totalEarnings = 0.0,
    this.totalDeliveries = 0,
    this.rating = 0.0,
    this.deviceToken,
    this.appVersion,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.lastLogout,
  });

  factory DeliveryPartnerModel.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return DeliveryPartnerModel(
      id: snapshot.id,
      phoneNumber: data?['phoneNumber'] ?? '',
      countryCode: data?['countryCode'] ?? '+91',
      displayName: data?['displayName'] ?? '',
      email: data?['email'],
      photoUrl: data?['photoUrl'],
      role: data?['role'] ?? 'delivery_partner',
      status: data?['status'] ?? 'pending',
      isActive: data?['isActive'] ?? false,
      isVerified: data?['isVerified'] ?? false,
      isPhoneVerified: data?['isPhoneVerified'] ?? true,
      isEmailVerified: data?['isEmailVerified'] ?? false,
      profileCompletion: data?['profileCompletion'] ?? 0,
      isOnline: data?['isOnline'] ?? false,
      vehicleType: data?['vehicleType'],
      vehicleNumber: data?['vehicleNumber'],
      drivingLicense: data?['drivingLicense'],
      aadhaarNumber: data?['aadhaarNumber'],
      kycStatus: data?['kycStatus'] ?? 'pending',
      totalEarnings: (data?['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: data?['totalDeliveries'] ?? 0,
      rating: (data?['rating'] as num?)?.toDouble() ?? 0.0,
      deviceToken: data?['deviceToken'],
      appVersion: data?['appVersion'],
      createdAt: data?['createdAt'] != null
          ? (data!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data?['updatedAt'] != null
          ? (data!['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data?['lastLogin'] != null
          ? (data!['lastLogin'] as Timestamp).toDate()
          : null,
      lastLogout: data?['lastLogout'] != null
          ? (data!['lastLogout'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'status': status,
      'isActive': isActive,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'profileCompletion': profileCompletion,
      'isOnline': isOnline,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'drivingLicense': drivingLicense,
      'aadhaarNumber': aadhaarNumber,
      'kycStatus': kycStatus,
      'totalEarnings': totalEarnings,
      'totalDeliveries': totalDeliveries,
      'rating': rating,
      'deviceToken': deviceToken,
      'appVersion': appVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'lastLogout': lastLogout != null ? Timestamp.fromDate(lastLogout!) : null,
    };
  }

  DeliveryPartnerModel copyWith({
    String? id,
    String? phoneNumber,
    String? countryCode,
    String? displayName,
    String? email,
    String? photoUrl,
    String? role,
    String? status,
    bool? isActive,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    int? profileCompletion,
    bool? isOnline,
    String? vehicleType,
    String? vehicleNumber,
    String? drivingLicense,
    String? aadhaarNumber,
    String? kycStatus,
    double? totalEarnings,
    int? totalDeliveries,
    double? rating,
    String? deviceToken,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    DateTime? lastLogout,
  }) {
    return DeliveryPartnerModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isOnline: isOnline ?? this.isOnline,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      kycStatus: kycStatus ?? this.kycStatus,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      rating: rating ?? this.rating,
      deviceToken: deviceToken ?? this.deviceToken,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastLogout: lastLogout ?? this.lastLogout,
    );
  }
}
