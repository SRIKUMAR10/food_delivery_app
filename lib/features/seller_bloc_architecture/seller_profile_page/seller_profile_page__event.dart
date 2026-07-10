import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class SellerProfilePageEvent extends Equatable {
  const SellerProfilePageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends SellerProfilePageEvent {}

class LogoutRequested extends SellerProfilePageEvent {}

class NotificationSettingsChanged extends SellerProfilePageEvent {
  final bool isEnabled;

  const NotificationSettingsChanged(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class SubmitVerificationForm extends SellerProfilePageEvent {
  final String storeName;
  final String address;
  final String email;
  final String phone;
  final String gstNumber;
  final String taxConfiguration;
  final String fssaiLicense;
  final String bankAccountNumber;
  final String ifscCode;

  const SubmitVerificationForm({
    required this.storeName,
    required this.address,
    required this.email,
    required this.phone,
    required this.gstNumber,
    required this.taxConfiguration,
    required this.fssaiLicense,
    required this.bankAccountNumber,
    required this.ifscCode,
  });

  @override
  List<Object?> get props => [
        storeName,
        address,
        email,
        phone,
        gstNumber,
        taxConfiguration,
        fssaiLicense,
        bankAccountNumber,
        ifscCode,
      ];
}

class UpdateProfileImage extends SellerProfilePageEvent {
  final Uint8List imageBytes;
  final String fileName;

  const UpdateProfileImage(this.imageBytes, this.fileName);

  @override
  List<Object?> get props => [imageBytes, fileName];
}
