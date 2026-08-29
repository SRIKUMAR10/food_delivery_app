import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

abstract class SellerProfilePageEvent extends Equatable {
  const SellerProfilePageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends SellerProfilePageEvent {}

class WatchProfileStarted extends SellerProfilePageEvent {}

class ProfileUpdatedFromStream extends SellerProfilePageEvent {
  final SellerModel? seller;

  const ProfileUpdatedFromStream(this.seller);

  @override
  List<Object?> get props => [seller];
}

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
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;

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
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
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
        latitude,
        longitude,
        googleMapsUrl,
      ];
}

class UpdateProfileImage extends SellerProfilePageEvent {
  final Uint8List imageBytes;
  final String fileName;

  const UpdateProfileImage(this.imageBytes, this.fileName);

  @override
  List<Object?> get props => [imageBytes, fileName];
}

class UpdateCoverImage extends SellerProfilePageEvent {
  final Uint8List imageBytes;
  final String fileName;

  const UpdateCoverImage(this.imageBytes, this.fileName);

  @override
  List<Object?> get props => [imageBytes, fileName];
}

class UpdateRestaurantIdentity extends SellerProfilePageEvent {
  final String storeName;
  final String ownerName;
  final String description;
  final String email;
  final String phone;

  const UpdateRestaurantIdentity({
    required this.storeName,
    required this.ownerName,
    required this.description,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [storeName, ownerName, description, email, phone];
}

class UpdateLocationDetails extends SellerProfilePageEvent {
  final String address;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;

  const UpdateLocationDetails({
    required this.address,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
  });

  @override
  List<Object?> get props => [address, latitude, longitude, googleMapsUrl];
}

class UpdateLogisticsSettings extends SellerProfilePageEvent {
  final double minimumOrderValue;
  final double deliveryRadius;
  final DeliveryFeeSettings deliveryFeeSettings;
  final int estimatedPrepTimeMinutes;

  const UpdateLogisticsSettings({
    required this.minimumOrderValue,
    required this.deliveryRadius,
    required this.deliveryFeeSettings,
    required this.estimatedPrepTimeMinutes,
  });

  @override
  List<Object?> get props => [
        minimumOrderValue,
        deliveryRadius,
        deliveryFeeSettings,
        estimatedPrepTimeMinutes,
      ];
}


class UpdateBusinessHoursSchedule extends SellerProfilePageEvent {
  final String openingHours;
  final String closingTime;
  final List<String> weeklyHoliday;

  const UpdateBusinessHoursSchedule({
    required this.openingHours,
    required this.closingTime,
    required this.weeklyHoliday,
  });

  @override
  List<Object?> get props => [openingHours, closingTime, weeklyHoliday];
}

class ToggleAcceptingOrders extends SellerProfilePageEvent {
  final bool isAcceptingOrders;

  const ToggleAcceptingOrders(this.isAcceptingOrders);

  @override
  List<Object?> get props => [isAcceptingOrders];
}

class ToggleStoreOpenStatus extends SellerProfilePageEvent {
  final bool isOpen;

  const ToggleStoreOpenStatus(this.isOpen);

  @override
  List<Object?> get props => [isOpen];
}

class LoadSellerKycDocuments extends SellerProfilePageEvent {}

class KycDocumentsStreamUpdated extends SellerProfilePageEvent {
  final Map<String, dynamic> kycData;

  const KycDocumentsStreamUpdated(this.kycData);

  @override
  List<Object?> get props => [kycData];
}

class SubmitSellerKycDocuments extends SellerProfilePageEvent {
  final String fssaiNumber;
  final String? fssaiCertificateUrl;
  final String gstNumber;
  final String? gstCertificateUrl;
  final String panNumber;
  final String? panCardUrl;
  final String bankAccountNumber;
  final String ifscCode;
  final String? bankChequeUrl;
  final String? shopLicenseUrl;

  const SubmitSellerKycDocuments({
    required this.fssaiNumber,
    this.fssaiCertificateUrl,
    required this.gstNumber,
    this.gstCertificateUrl,
    required this.panNumber,
    this.panCardUrl,
    required this.bankAccountNumber,
    required this.ifscCode,
    this.bankChequeUrl,
    this.shopLicenseUrl,
  });

  @override
  List<Object?> get props => [
        fssaiNumber,
        fssaiCertificateUrl,
        gstNumber,
        gstCertificateUrl,
        panNumber,
        panCardUrl,
        bankAccountNumber,
        ifscCode,
        bankChequeUrl,
        shopLicenseUrl,
      ];
}

class UploadKycDocumentFileEvent extends SellerProfilePageEvent {
  final String docType;
  final String fileName;
  final Uint8List fileBytes;

  const UploadKycDocumentFileEvent({
    required this.docType,
    required this.fileName,
    required this.fileBytes,
  });

  @override
  List<Object?> get props => [docType, fileName, fileBytes];
}

