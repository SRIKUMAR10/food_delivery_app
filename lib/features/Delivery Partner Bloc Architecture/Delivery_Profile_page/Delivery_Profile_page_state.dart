import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum DeliveryProfileStatus { initial, loading, loaded, error, empty }

enum DeliveryProfileSaveStatus { idle, saving, saved, failed }

enum DeliveryProfileDocumentStatus { notUploaded, uploading, uploaded, verified }

class DeliveryProfileDocument extends Equatable {
  final String id;
  final String label;
  final IconData icon;
  final DeliveryProfileDocumentStatus status;
  final double progress;
  final String? documentUrl;

  const DeliveryProfileDocument({
    required this.id,
    required this.label,
    required this.icon,
    this.status = DeliveryProfileDocumentStatus.notUploaded,
    this.progress = 0.0,
    this.documentUrl,
  });

  bool get isUploaded =>
      status == DeliveryProfileDocumentStatus.uploaded ||
      status == DeliveryProfileDocumentStatus.verified;

  bool get isVerified => status == DeliveryProfileDocumentStatus.verified;

  bool get isUploading => status == DeliveryProfileDocumentStatus.uploading;

  DeliveryProfileDocument copyWith({
    DeliveryProfileDocumentStatus? status,
    double? progress,
    String? documentUrl,
  }) {
    return DeliveryProfileDocument(
      id: id,
      label: label,
      icon: icon,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }

  @override
  List<Object?> get props => [id, label, icon, status, progress, documentUrl];
}

class DeliveryProfileChecklistItem extends Equatable {
  final String id;
  final String label;
  final bool isComplete;

  const DeliveryProfileChecklistItem({
    required this.id,
    required this.label,
    required this.isComplete,
  });

  DeliveryProfileChecklistItem copyWith({bool? isComplete}) {
    return DeliveryProfileChecklistItem(
      id: id,
      label: label,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [id, label, isComplete];
}

int computeDeliveryProfileCompletion({
  required String fullName,
  required String phone,
  required String email,
  required String dob,
  required String address,
  required String vehicleType,
  required String vehicleNumber,
  required String licenseNumber,
  required String licenseValidTill,
  required List<DeliveryProfileDocument> documents,
}) {
  final personalFields = [
    fullName,
    phone,
    email,
    dob,
    address,
    vehicleType,
    vehicleNumber,
    licenseNumber,
    licenseValidTill,
  ];
  final filled = personalFields.where((f) => f.trim().isNotEmpty).length;
  final uploaded = documents.where((d) => d.isUploaded).length;
  final total = personalFields.length + documents.length;
  if (total == 0) return 0;
  return ((filled + uploaded) * 100 / total).round().clamp(0, 100);
}

class DeliveryProfileState extends Equatable {
  final DeliveryProfileStatus status;
  final DeliveryProfileSaveStatus saveStatus;
  final String? errorMessage;
  final String? actionMessage;

  final String partnerId;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String dob;
  final String gender;
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final String licenseValidTill;
  final String? avatarPath;
  final String joiningDate;
  final double rating;
  final int totalDeliveries;
  final bool isActive;
  final String verificationStatus;
  final String kycStatus;

  final double uploadProgress;
  final Map<String, bool> verificationStatuses;
  final int completionPercentage;
  final List<DeliveryProfileChecklistItem> checklist;
  final List<DeliveryProfileDocument> documents;
  final String localeCode;

  final bool isChangingPassword;
  final bool isDeactivating;
  final bool isLoggingOut;

  const DeliveryProfileState({
    this.status = DeliveryProfileStatus.initial,
    this.saveStatus = DeliveryProfileSaveStatus.idle,
    this.errorMessage,
    this.actionMessage,
    this.partnerId = '',
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.dob = '',
    this.gender = '',
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.licenseNumber = '',
    this.licenseValidTill = '',
    this.avatarPath,
    this.joiningDate = '',
    this.rating = 5.0,
    this.totalDeliveries = 0,
    this.isActive = true,
    this.verificationStatus = 'pending',
    this.kycStatus = 'pending',
    this.uploadProgress = 0.0,
    this.verificationStatuses = const {
      'phone': false,
      'email': false,
      'identity': false,
      'document': false,
    },
    this.completionPercentage = 0,
    this.checklist = const [],
    this.documents = const [],
    this.localeCode = 'en',
    this.isChangingPassword = false,
    this.isDeactivating = false,
    this.isLoggingOut = false,
  });

  String get partnerCode {
    if (partnerId.isEmpty) return 'DP-000000';
    final clean = partnerId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final code = clean.length >= 6 ? clean.substring(0, 6) : clean.padRight(6, '0');
    return 'DP-${code.toUpperCase()}';
  }

  bool get isPhoneVerified => verificationStatuses['phone'] ?? false;
  bool get isEmailVerified => verificationStatuses['email'] ?? false;
  bool get isIdentityVerified => verificationStatuses['identity'] ?? false;
  bool get isDocumentVerified => verificationStatuses['document'] ?? false;

  bool get isKycApproved => kycStatus == 'approved' || verificationStatus == 'approved';
  bool get isKycPending => kycStatus == 'pending' && verificationStatus != 'approved';
  bool get isKycInReview => kycStatus == 'in_review';
  bool get isKycRejected => kycStatus == 'rejected';

  DeliveryProfileState copyWith({
    DeliveryProfileStatus? status,
    DeliveryProfileSaveStatus? saveStatus,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? partnerId,
    String? fullName,
    String? phone,
    String? email,
    String? address,
    String? dob,
    String? gender,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
    String? licenseValidTill,
    String? avatarPath,
    bool clearAvatar = false,
    String? joiningDate,
    double? rating,
    int? totalDeliveries,
    bool? isActive,
    String? verificationStatus,
    String? kycStatus,
    double? uploadProgress,
    Map<String, bool>? verificationStatuses,
    int? completionPercentage,
    List<DeliveryProfileChecklistItem>? checklist,
    List<DeliveryProfileDocument>? documents,
    String? localeCode,
    bool? isChangingPassword,
    bool? isDeactivating,
    bool? isLoggingOut,
  }) {
    return DeliveryProfileState(
      status: status ?? this.status,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      partnerId: partnerId ?? this.partnerId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseValidTill: licenseValidTill ?? this.licenseValidTill,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      joiningDate: joiningDate ?? this.joiningDate,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      isActive: isActive ?? this.isActive,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      kycStatus: kycStatus ?? this.kycStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      verificationStatuses:
          verificationStatuses ?? this.verificationStatuses,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      checklist: checklist ?? this.checklist,
      documents: documents ?? this.documents,
      localeCode: localeCode ?? this.localeCode,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isDeactivating: isDeactivating ?? this.isDeactivating,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  @override
  List<Object?> get props => [
        status,
        saveStatus,
        errorMessage,
        actionMessage,
        partnerId,
        fullName,
        phone,
        email,
        address,
        dob,
        gender,
        vehicleType,
        vehicleNumber,
        licenseNumber,
        licenseValidTill,
        avatarPath,
        joiningDate,
        rating,
        totalDeliveries,
        isActive,
        verificationStatus,
        kycStatus,
        uploadProgress,
        verificationStatuses,
        completionPercentage,
        checklist,
        documents,
        localeCode,
        isChangingPassword,
        isDeactivating,
        isLoggingOut,
      ];
}
