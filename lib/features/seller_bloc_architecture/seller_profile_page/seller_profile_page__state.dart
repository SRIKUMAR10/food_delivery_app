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

  const ProfileLoaded({
    required this.storeName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.notificationsEnabled,
    this.address,
    this.gstNumber,
    this.fssaiLicense,
    this.bankAccountNumber,
    this.ifscCode,
    this.taxConfiguration,
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
      ];
}

class ProfileError extends SellerProfilePageState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
