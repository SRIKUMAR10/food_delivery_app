import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_date_formatter.dart';

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
  final bool isAvailable;
  final bool isBusy;
  final String? currentOrderId;
  final DateTime? lastActiveAt;
  final Map<String, dynamic>? lastLocation;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? drivingLicense;
  final String? aadhaarNumber;
  final String kycStatus;
  final double totalEarnings;
  final int totalDeliveries;
  final double cashCollected;
  final double cashInHand;
  final double cashSubmitted;
  final String reconciliationStatus;
  final double rating;
  final String? deviceToken;
  final String? appVersion;
  final bool isEmailVerified;
  final bool onboardingCompleted;
  final int profileCompletion;
  final String? address;
  final String? idProofUrl;
  final String? vehicleRcUrl;
  final String? insuranceUrl;
  final String? panNumber;
  final String? password;
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
    this.address,
    this.idProofUrl,
    this.vehicleRcUrl,
    this.insuranceUrl,
    this.panNumber,
    this.password,
    this.role = 'delivery_partner',
    this.status = 'pending',
    this.isActive = false,
    this.isVerified = false,
    this.isPhoneVerified = true,
    this.isEmailVerified = false,
    this.onboardingCompleted = false,
    this.profileCompletion = 0,
    this.isOnline = false,
    this.isAvailable = false,
    this.isBusy = false,
    this.currentOrderId,
    this.lastActiveAt,
    this.lastLocation,
    this.vehicleType,
    this.vehicleNumber,
    this.drivingLicense,
    this.aadhaarNumber,
    this.kycStatus = 'pending',
    this.totalEarnings = 0.0,
    this.totalDeliveries = 0,
    this.cashCollected = 0.0,
    this.cashInHand = 0.0,
    this.cashSubmitted = 0.0,
    this.reconciliationStatus = 'balanced',
    this.rating = 0.0,
    this.deviceToken,
    this.appVersion,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.lastLogout,
  });

  /// Partner identification code formatted for UI (e.g. DP-1A2B3C)
  String get partnerCode {
    if (id.isEmpty) return 'DP-000000';
    final cleanId = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final code = cleanId.length >= 6 ? cleanId.substring(0, 6) : cleanId.padRight(6, '0');
    return 'DP-${code.toUpperCase()}';
  }

  /// Formatted joining date for UI (e.g. 15 Aug, 2024)
  String get formattedJoiningDate {
    return AppDateFormatter.formatDisplayDate(createdAt);
  }

  bool get isApproved => status == 'approved' || kycStatus == 'approved';
  bool get isKycPending => kycStatus == 'pending';
  bool get isKycInReview => kycStatus == 'in_review';
  bool get isKycApproved => kycStatus == 'approved';
  bool get isKycRejected => kycStatus == 'rejected';

  bool get hasPendingCashSubmission => cashInHand > 0;
  bool get isReconciliationBalanced => reconciliationStatus == 'balanced';
  bool get isReconciliationOverdue => reconciliationStatus == 'overdue';

  /// Safely parses Firestore `Timestamp`, ISO-8601 `String`, or `int`
  /// (milliseconds since epoch) values into [DateTime] without runtime casts.
  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      final milliseconds = value.toInt();
      if (milliseconds > 0) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    }
    return null;
  }

  factory DeliveryPartnerModel.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    final isOnlineVal = data?['isOnline'] ?? false;
    final isAvailableVal = data?['isAvailable'] ?? isOnlineVal;
    final isBusyVal = data?['isBusy'] ?? false;

    return DeliveryPartnerModel(
      id: snapshot.id,
      phoneNumber: data?['phoneNumber'] ?? '',
      countryCode: data?['countryCode'] ?? '+91',
      displayName: data?['displayName'] ?? '',
      email: data?['email'],
      photoUrl: data?['photoUrl'],
      address: data?['address'],
      idProofUrl: data?['idProofUrl'] ?? data?['aadhaarUrl'],
      vehicleRcUrl: data?['vehicleRcUrl'],
      insuranceUrl: data?['insuranceUrl'],
      panNumber: data?['panNumber'],
      password: null, // Zero plain text password storage in Firestore
      role: data?['role'] ?? 'delivery_partner',
      status: data?['status'] ?? (isOnlineVal ? (isBusyVal ? 'busy' : 'available') : 'offline'),
      isActive: data?['isActive'] ?? false,
      isVerified: data?['isVerified'] ?? false,
      isPhoneVerified: data?['isPhoneVerified'] ?? true,
      isEmailVerified: data?['isEmailVerified'] ?? false,
      onboardingCompleted: data?['onboardingCompleted'] ??
          (data?['kycStatus'] == 'under_review' ||
              data?['kycStatus'] == 'verified' ||
              (data?['profileCompletion'] as num?)?.toInt() == 100),
      profileCompletion: (data?['profileCompletion'] as num?)?.toInt() ?? 0,
      isOnline: isOnlineVal,
      isAvailable: isAvailableVal,
      isBusy: isBusyVal,
      currentOrderId: data?['currentOrderId'],
      lastActiveAt: _parseDateTime(data?['lastActiveAt']),
      lastLocation: data?['lastLocation'] is Map<String, dynamic>
          ? data!['lastLocation'] as Map<String, dynamic>
          : null,
      vehicleType: data?['vehicleType'],
      vehicleNumber: data?['vehicleNumber'],
      drivingLicense: data?['drivingLicense'],
      aadhaarNumber: data?['aadhaarNumber'],
      kycStatus: data?['kycStatus'] ?? 'pending',
      totalEarnings: (data?['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: (data?['totalDeliveries'] as num?)?.toInt() ?? 0,
      cashCollected: (data?['cashCollected'] as num?)?.toDouble() ?? 0.0,
      cashInHand: (data?['cashInHand'] as num?)?.toDouble() ?? 0.0,
      cashSubmitted: (data?['cashSubmitted'] as num?)?.toDouble() ?? 0.0,
      reconciliationStatus: data?['reconciliationStatus'] ?? 'balanced',
      rating: (data?['rating'] as num?)?.toDouble() ?? 0.0,
      deviceToken: data?['deviceToken'],
      appVersion: data?['appVersion'],
      createdAt: _parseDateTime(data?['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data?['updatedAt']) ?? DateTime.now(),
      lastLogin: _parseDateTime(data?['lastLogin']),
      lastLogout: _parseDateTime(data?['lastLogout']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'address': address,
      'idProofUrl': idProofUrl,
      'vehicleRcUrl': vehicleRcUrl,
      'insuranceUrl': insuranceUrl,
      'panNumber': panNumber,
      // Note: password is never serialized in toMap() for security model invariants
      'role': role,
      'status': status,
      'isActive': isActive,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'onboardingCompleted': onboardingCompleted,
      'profileCompletion': profileCompletion,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'isBusy': isBusy,
      if (currentOrderId != null) 'currentOrderId': currentOrderId,
      if (lastActiveAt != null) 'lastActiveAt': Timestamp.fromDate(lastActiveAt!),
      if (lastLocation != null) 'lastLocation': lastLocation,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'drivingLicense': drivingLicense,
      'aadhaarNumber': aadhaarNumber,
      'kycStatus': kycStatus,
      'totalEarnings': totalEarnings,
      'totalDeliveries': totalDeliveries,
      'cashCollected': cashCollected,
      'cashInHand': cashInHand,
      'cashSubmitted': cashSubmitted,
      'reconciliationStatus': reconciliationStatus,
      'rating': rating,
      'deviceToken': deviceToken,
      'appVersion': appVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastLogin != null) 'lastLogin': Timestamp.fromDate(lastLogin!),
      if (lastLogout != null) 'lastLogout': Timestamp.fromDate(lastLogout!),
    };
  }

  DeliveryPartnerModel copyWith({
    String? id,
    String? phoneNumber,
    String? countryCode,
    String? displayName,
    String? email,
    String? photoUrl,
    String? address,
    String? idProofUrl,
    String? vehicleRcUrl,
    String? insuranceUrl,
    String? panNumber,
    String? password,
    String? role,
    String? status,
    bool? isActive,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? onboardingCompleted,
    int? profileCompletion,
    bool? isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
    DateTime? lastActiveAt,
    Map<String, dynamic>? lastLocation,
    String? vehicleType,
    String? vehicleNumber,
    String? drivingLicense,
    String? aadhaarNumber,
    String? kycStatus,
    double? totalEarnings,
    int? totalDeliveries,
    double? cashCollected,
    double? cashInHand,
    double? cashSubmitted,
    String? reconciliationStatus,
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
      address: address ?? this.address,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      vehicleRcUrl: vehicleRcUrl ?? this.vehicleRcUrl,
      insuranceUrl: insuranceUrl ?? this.insuranceUrl,
      panNumber: panNumber ?? this.panNumber,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      isBusy: isBusy ?? this.isBusy,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      lastLocation: lastLocation ?? this.lastLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      kycStatus: kycStatus ?? this.kycStatus,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      cashCollected: cashCollected ?? this.cashCollected,
      cashInHand: cashInHand ?? this.cashInHand,
      cashSubmitted: cashSubmitted ?? this.cashSubmitted,
      reconciliationStatus: reconciliationStatus ?? this.reconciliationStatus,
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
