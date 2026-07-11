import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class SellerProfilePageState extends Equatable {
  const SellerProfilePageState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends SellerProfilePageState {}

class ProfileLoading extends SellerProfilePageState {}

class ProfileLoaded extends SellerProfilePageState {
  final String storeName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final bool notificationsEnabled;
  final String? address;
  final String? gstNumber;
  final String? fssaiLicense;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? taxConfiguration;
  final bool isImageUploading;
  final Uint8List? localImageBytes;
  
  // Newly added fields to support dynamic profile
  final String role;
  final DateTime createdAt;
  final bool isVerified;
  final String? bankName;
  final String? accountHolderName;
  final String? bankBranch;
  final String? panNumber;
  final String? openingHours;
  final String? deliveryTime;
  final String? deliveryArea;
  final String? businessDetails;

  const ProfileLoaded({
    required this.storeName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.notificationsEnabled,
    required this.role,
    required this.createdAt,
    required this.isVerified,
    this.address,
    this.gstNumber,
    this.fssaiLicense,
    this.bankAccountNumber,
    this.ifscCode,
    this.taxConfiguration,
    this.isImageUploading = false,
    this.localImageBytes,
    this.bankName,
    this.accountHolderName,
    this.bankBranch,
    this.panNumber,
    this.openingHours,
    this.deliveryTime,
    this.deliveryArea,
    this.businessDetails,
  });

  @override
  List<Object?> get props => [
        storeName,
        email,
        phone,
        profileImageUrl,
        notificationsEnabled,
        address,
        gstNumber,
        fssaiLicense,
        bankAccountNumber,
        ifscCode,
        taxConfiguration,
        isImageUploading,
        localImageBytes,
        role,
        createdAt,
        isVerified,
        bankName,
        accountHolderName,
        bankBranch,
        panNumber,
        openingHours,
        deliveryTime,
        deliveryArea,
        businessDetails,
      ];
}

class ProfileError extends SellerProfilePageState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
