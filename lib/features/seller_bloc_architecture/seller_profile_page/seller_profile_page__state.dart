import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

abstract class SellerProfilePageState extends Equatable {
  const SellerProfilePageState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends SellerProfilePageState {}

class ProfileLoading extends SellerProfilePageState {}

class ProfileLoaded extends SellerProfilePageState {
  final String storeName;
  final String? ownerName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String coverImageUrl;
  final bool notificationsEnabled;
  final String? address;
  final String? restaurantDescription;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final List<String> cuisines;
  final double minimumOrderValue;
  final double deliveryRadius;
  final DeliveryFeeSettings deliveryFeeSettings;
  final int estimatedPrepTimeMinutes;
  final String? openingHours;
  final String? closingTime;
  final List<String> weeklyHoliday;
  final bool isOpen;
  final bool isAcceptingOrders;
  final bool isActive;
  final String verificationStatus;
  final bool isVerified;
  final String role;
  final DateTime createdAt;
  final String? gstNumber;
  final String? fssaiLicense;
  final String? panNumber;
  final String? bankAccountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? accountHolderName;
  final String? bankBranch;
  final String? taxConfiguration;
  final String? deliveryTime;
  final String? deliveryArea;
  final String? businessDetails;
  final bool isImageUploading;
  final Uint8List? localImageBytes;
  final bool isCoverUploading;
  final Uint8List? localCoverBytes;
  final String kycStatus;
  final String? fssaiCertificateUrl;
  final String? gstCertificateUrl;
  final String? panCardUrl;
  final String? bankChequeUrl;
  final String? shopLicenseUrl;
  final String? kycRejectionReason;
  final bool isKycUploading;

  bool get isKycApproved =>
      isVerified ||
      verificationStatus == 'verified' ||
      verificationStatus == 'approved' ||
      kycStatus == 'approved';

  bool get isKycPending =>
      !isKycApproved &&
      (kycStatus == 'pending' || verificationStatus == 'pending');

  bool get isKycInReview =>
      kycStatus == 'in_review' || verificationStatus == 'in_review';

  bool get isKycRejected =>
      kycStatus == 'rejected' || verificationStatus == 'rejected';

  const ProfileLoaded({
    required this.storeName,
    this.ownerName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    this.coverImageUrl = '',
    required this.notificationsEnabled,
    required this.role,
    required this.createdAt,
    required this.isVerified,
    this.verificationStatus = 'pending',
    this.address,
    this.restaurantDescription,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.cuisines = const [],
    this.minimumOrderValue = 150.0,
    this.deliveryRadius = 10.0,
    this.deliveryFeeSettings = const DeliveryFeeSettings(),
    this.estimatedPrepTimeMinutes = 25,
    this.openingHours,
    this.closingTime,
    this.weeklyHoliday = const [],
    this.isOpen = true,
    this.isAcceptingOrders = true,
    this.isActive = true,
    this.gstNumber,
    this.fssaiLicense,
    this.panNumber,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.accountHolderName,
    this.bankBranch,
    this.taxConfiguration,
    this.deliveryTime,
    this.deliveryArea,
    this.businessDetails,
    this.isImageUploading = false,
    this.localImageBytes,
    this.isCoverUploading = false,
    this.localCoverBytes,
    this.kycStatus = 'pending',
    this.fssaiCertificateUrl,
    this.gstCertificateUrl,
    this.panCardUrl,
    this.bankChequeUrl,
    this.shopLicenseUrl,
    this.kycRejectionReason,
    this.isKycUploading = false,
  });

  ProfileLoaded copyWith({
    String? storeName,
    String? ownerName,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    bool? notificationsEnabled,
    String? address,
    String? restaurantDescription,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    List<String>? cuisines,
    double? minimumOrderValue,
    double? deliveryRadius,
    DeliveryFeeSettings? deliveryFeeSettings,
    int? estimatedPrepTimeMinutes,
    String? openingHours,
    String? closingTime,
    List<String>? weeklyHoliday,
    bool? isOpen,
    bool? isAcceptingOrders,
    bool? isActive,
    String? verificationStatus,
    bool? isVerified,
    String? role,
    DateTime? createdAt,
    String? gstNumber,
    String? fssaiLicense,
    String? panNumber,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? accountHolderName,
    String? bankBranch,
    String? taxConfiguration,
    String? deliveryTime,
    String? deliveryArea,
    String? businessDetails,
    bool? isImageUploading,
    Uint8List? localImageBytes,
    bool? isCoverUploading,
    Uint8List? localCoverBytes,
    String? kycStatus,
    String? fssaiCertificateUrl,
    String? gstCertificateUrl,
    String? panCardUrl,
    String? bankChequeUrl,
    String? shopLicenseUrl,
    String? kycRejectionReason,
    bool? isKycUploading,
  }) {
    return ProfileLoaded(
      storeName: storeName ?? this.storeName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      address: address ?? this.address,
      restaurantDescription: restaurantDescription ?? this.restaurantDescription,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      cuisines: cuisines ?? this.cuisines,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      deliveryFeeSettings: deliveryFeeSettings ?? this.deliveryFeeSettings,
      estimatedPrepTimeMinutes: estimatedPrepTimeMinutes ?? this.estimatedPrepTimeMinutes,
      openingHours: openingHours ?? this.openingHours,
      closingTime: closingTime ?? this.closingTime,
      weeklyHoliday: weeklyHoliday ?? this.weeklyHoliday,
      isOpen: isOpen ?? this.isOpen,
      isAcceptingOrders: isAcceptingOrders ?? this.isAcceptingOrders,
      isActive: isActive ?? this.isActive,
      gstNumber: gstNumber ?? this.gstNumber,
      fssaiLicense: fssaiLicense ?? this.fssaiLicense,
      panNumber: panNumber ?? this.panNumber,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankBranch: bankBranch ?? this.bankBranch,
      taxConfiguration: taxConfiguration ?? this.taxConfiguration,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      businessDetails: businessDetails ?? this.businessDetails,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      localImageBytes: localImageBytes ?? this.localImageBytes,
      isCoverUploading: isCoverUploading ?? this.isCoverUploading,
      localCoverBytes: localCoverBytes ?? this.localCoverBytes,
      kycStatus: kycStatus ?? this.kycStatus,
      fssaiCertificateUrl: fssaiCertificateUrl ?? this.fssaiCertificateUrl,
      gstCertificateUrl: gstCertificateUrl ?? this.gstCertificateUrl,
      panCardUrl: panCardUrl ?? this.panCardUrl,
      bankChequeUrl: bankChequeUrl ?? this.bankChequeUrl,
      shopLicenseUrl: shopLicenseUrl ?? this.shopLicenseUrl,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
      isKycUploading: isKycUploading ?? this.isKycUploading,
    );
  }

  @override
  List<Object?> get props => [
        storeName,
        ownerName,
        email,
        phone,
        profileImageUrl,
        coverImageUrl,
        notificationsEnabled,
        address,
        restaurantDescription,
        latitude,
        longitude,
        googleMapsUrl,
        cuisines,
        minimumOrderValue,
        deliveryRadius,
        deliveryFeeSettings,
        estimatedPrepTimeMinutes,
        openingHours,
        closingTime,
        weeklyHoliday,
        isOpen,
        isAcceptingOrders,
        isActive,
        verificationStatus,
        isVerified,
        role,
        createdAt,
        gstNumber,
        fssaiLicense,
        panNumber,
        bankAccountNumber,
        bankName,
        ifscCode,
        accountHolderName,
        bankBranch,
        taxConfiguration,
        deliveryTime,
        deliveryArea,
        businessDetails,
        isImageUploading,
        localImageBytes,
        isCoverUploading,
        localCoverBytes,
        kycStatus,
        fssaiCertificateUrl,
        gstCertificateUrl,
        panCardUrl,
        bankChequeUrl,
        shopLicenseUrl,
        kycRejectionReason,
        isKycUploading,
      ];
}

class ProfileError extends SellerProfilePageState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
