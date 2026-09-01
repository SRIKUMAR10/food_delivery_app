// Real-Time Firestore Stream Provider Standardized
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'Delivery_Profile_page_service.dart';
import 'Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';

abstract class DeliveryProfileRepositoryBase {
  Future<DeliveryProfileState> fetchProfile();
  Stream<DeliveryProfileState> watchProfile();
  Future<void> saveProfile(DeliveryProfileState profile);
  Future<String?> pickProfileImage();
  Future<String?> getAvatarPath();
  Future<void> saveAvatarPath(String? path);
  Future<void> updateAddress(
    String address, {
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
  });
  Future<void> updateVehicle({required String vehicleType, required String vehicleNumber});
  Future<void> updatePhone(String phone);
  Future<void> updateEmail(String email);
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<void> deactivateAccount();
  Future<void> logout();
}

class DeliveryProfileRepository implements DeliveryProfileRepositoryBase {
  static const String _profileKey = 'dp_profile_data';
  static const String _avatarKey = 'dp_profile_avatar';

  SharedPreferences? _prefs;
  final DeliveryProfileServiceBase _service;

  DeliveryProfileRepository({
    SharedPreferences? prefs,
    DeliveryProfileServiceBase? service,
  })  : _prefs = prefs,
        _service = service ?? DeliveryProfileService();

  static const List<DeliveryProfileDocument> defaultDocuments = [
    DeliveryProfileDocument(
      id: 'drivingLicense',
      label: 'Driving License',
      icon: Icons.badge_outlined,
      status: DeliveryProfileDocumentStatus.notUploaded,
    ),
    DeliveryProfileDocument(
      id: 'vehicleRc',
      label: 'Vehicle RC',
      icon: Icons.description_outlined,
      status: DeliveryProfileDocumentStatus.notUploaded,
    ),
    DeliveryProfileDocument(
      id: 'insurance',
      label: 'Insurance',
      icon: Icons.verified_user_outlined,
      status: DeliveryProfileDocumentStatus.notUploaded,
    ),
    DeliveryProfileDocument(
      id: 'panCard',
      label: 'PAN Card',
      icon: Icons.credit_card_outlined,
      status: DeliveryProfileDocumentStatus.notUploaded,
    ),
  ];

  static const Map<String, bool> defaultVerificationStatuses = {
    'phone': false,
    'email': false,
    'identity': false,
    'document': false,
  };

  static List<DeliveryProfileChecklistItem> buildDefaultChecklist({
    required DeliveryProfileState profile,
  }) {
    final personalDone =
        [profile.fullName, profile.phone, profile.email, profile.address]
            .every((f) => f.trim().isNotEmpty);
    final vehicleDone = [
      profile.vehicleType,
      profile.vehicleNumber,
      profile.licenseNumber,
    ].every((f) => f.trim().isNotEmpty);
    final byId = <String, DeliveryProfileDocument>{
      for (final d in profile.documents) d.id: d,
    };
    return [
      DeliveryProfileChecklistItem(
        id: 'personalDetails',
        label: 'Personal details completed',
        isComplete: personalDone,
      ),
      DeliveryProfileChecklistItem(
        id: 'vehicleInfo',
        label: 'Vehicle information provided',
        isComplete: vehicleDone,
      ),
      DeliveryProfileChecklistItem(
        id: 'drivingLicense',
        label: 'Driving license uploaded',
        isComplete: byId['drivingLicense']?.isUploaded ?? false,
      ),
      DeliveryProfileChecklistItem(
        id: 'vehicleRc',
        label: 'Vehicle RC uploaded',
        isComplete: byId['vehicleRc']?.isUploaded ?? false,
      ),
      DeliveryProfileChecklistItem(
        id: 'insurance',
        label: 'Insurance uploaded',
        isComplete: byId['insurance']?.isUploaded ?? false,
      ),
      DeliveryProfileChecklistItem(
        id: 'panCard',
        label: 'PAN card uploaded',
        isComplete: byId['panCard']?.isUploaded ?? false,
      ),
      DeliveryProfileChecklistItem(
        id: 'documentVerification',
        label: 'Document verification approved',
        isComplete: profile.isDocumentVerified,
      ),
    ];
  }

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return _prefs ?? await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeliveryProfileState> fetchProfile() async {
    final prefs = await _getPrefs();
    final String? avatarPath = prefs?.getString(_avatarKey);
    final defaultProfile = buildDefaultProfile(avatarPath: avatarPath);
    try {
      final data = await _service.fetchProfileData();
      final String displayName = data['displayName'] ?? '';
      if (displayName.isNotEmpty || (data['phoneNumber'] as String?)?.isNotEmpty == true) {
        final profile = _mapDataToProfile(data, defaultProfile);
        final checklist = buildDefaultChecklist(profile: profile);
        return profile.copyWith(checklist: checklist);
      }
    } catch (_) {}

    if (prefs == null) {
      return defaultProfile;
    }
    final raw = prefs.getString(_profileKey);
    if (raw == null) {
      return defaultProfile;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = defaultProfile.copyWith(
        fullName: map['fullName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        address: map['address'] as String? ?? '',
        latitude: map['latitude'] != null
            ? double.tryParse(map['latitude'].toString())
            : null,
        longitude: map['longitude'] != null
            ? double.tryParse(map['longitude'].toString())
            : null,
        googleMapsUrl: map['googleMapsUrl'] as String?,
        dob: map['dob'] as String? ?? '',
        gender: map['gender'] as String? ?? '',
        vehicleType: map['vehicleType'] as String? ?? '',
        vehicleNumber: map['vehicleNumber'] as String? ?? '',
        licenseNumber: map['licenseNumber'] as String? ?? '',
        licenseValidTill: map['licenseValidTill'] as String? ?? '',
      );
      final checklist = buildDefaultChecklist(profile: profile);
      return profile.copyWith(checklist: checklist);
    } catch (_) {
      return defaultProfile;
    }
  }

  DeliveryProfileState buildDefaultProfile({String? avatarPath}) {
    final profile = DeliveryProfileState(
      status: DeliveryProfileStatus.loaded,
      fullName: _prefs?.getString('delivery_profile_name') ?? '',
      phone: _prefs?.getString('delivery_profile_phone') ?? '',
      email: _prefs?.getString('delivery_profile_email') ?? '',
      dob: _prefs?.getString('delivery_profile_dob') ?? '',
      gender: _prefs?.getString('delivery_profile_gender') ?? '',
      address: _prefs?.getString('delivery_profile_address') ?? '',
      vehicleType: _prefs?.getString('delivery_profile_vehicle_type') ?? '',
      vehicleNumber: _prefs?.getString('delivery_profile_vehicle_number') ?? '',
      licenseNumber: _prefs?.getString('delivery_profile_license') ?? '',
      licenseValidTill:
          _prefs?.getString('delivery_profile_license_valid') ?? '',
      completionPercentage: 0,
      avatarPath: avatarPath ?? _prefs?.getString(_avatarKey),
      documents: defaultDocuments,
      verificationStatuses: defaultVerificationStatuses,
      localeCode: _prefs?.getString('delivery_locale') ?? 'en',
    );
    final checklist = buildDefaultChecklist(profile: profile);
    final completion = computeDeliveryProfileCompletion(
      fullName: profile.fullName,
      phone: profile.phone,
      email: profile.email,
      dob: profile.dob,
      address: profile.address,
      vehicleType: profile.vehicleType,
      vehicleNumber: profile.vehicleNumber,
      licenseNumber: profile.licenseNumber,
      licenseValidTill: profile.licenseValidTill,
      documents: profile.documents,
    );
    return profile.copyWith(
      checklist: checklist,
      completionPercentage: completion,
    );
  }

  @override
  Stream<DeliveryProfileState> watchProfile() async* {
    _prefs ??= await SharedPreferences.getInstance();
    yield* _service.watchProfileData().map((data) {
      final defaultProfile = buildDefaultProfile();
      final profile = _mapDataToProfile(data, defaultProfile);
      final checklist = buildDefaultChecklist(profile: profile);
      final completion = computeDeliveryProfileCompletion(
        fullName: profile.fullName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        address: profile.address,
        vehicleType: profile.vehicleType,
        vehicleNumber: profile.vehicleNumber,
        licenseNumber: profile.licenseNumber,
        licenseValidTill: profile.licenseValidTill,
        documents: profile.documents,
      );
      return profile.copyWith(
        checklist: checklist,
        completionPercentage: completion,
        status: DeliveryProfileStatus.loaded,
      );
    });
  }

  DeliveryProfileState _mapDataToProfile(
      Map<String, dynamic> data, DeliveryProfileState defaultProfile) {
    final partnerId = (data['id'] as String?)?.isNotEmpty == true
        ? data['id'] as String
        : defaultProfile.partnerId;
    final displayName = (data['displayName'] as String?)?.isNotEmpty == true
        ? data['displayName'] as String
        : defaultProfile.fullName;
    final phone = (data['phoneNumber'] as String?)?.isNotEmpty == true
        ? data['phoneNumber'] as String
        : defaultProfile.phone;
    final email = (data['email'] as String?)?.isNotEmpty == true
        ? data['email'] as String
        : defaultProfile.email;
    final address = (data['address'] as String?)?.isNotEmpty == true
        ? data['address'] as String
        : defaultProfile.address;
    final vehicleType = (data['vehicleType'] as String?)?.isNotEmpty == true
        ? data['vehicleType'] as String
        : defaultProfile.vehicleType;
    final vehicleNumber = (data['vehicleNumber'] as String?)?.isNotEmpty == true
        ? data['vehicleNumber'] as String
        : defaultProfile.vehicleNumber;
    final drivingLicense = (data['drivingLicense'] as String?)?.isNotEmpty == true
        ? data['drivingLicense'] as String
        : defaultProfile.licenseNumber;
    final licenseValidTill =
        (data['licenseValidTill'] as String?)?.isNotEmpty == true
            ? data['licenseValidTill'] as String
            : ((data['dlExpiryDate'] as String?)?.isNotEmpty == true
                ? data['dlExpiryDate'] as String
                : defaultProfile.licenseValidTill);
    final vehicleRcUrl = data['vehicleRcUrl'] ?? '';
    final insuranceUrl = data['insuranceUrl'] ?? '';
    final panNumber = data['panNumber'] ?? '';
    final status = data['status'] ?? 'pending';
    final kycStatus = data['kycStatus'] ?? 'pending';
    final isActive = data['isActive'] ?? true;
    final rating = (data['rating'] as num?)?.toDouble() ?? defaultProfile.rating;
    final totalDeliveries =
        (data['totalDeliveries'] as num?)?.toInt() ?? defaultProfile.totalDeliveries;
    final joiningDate = (data['joiningDate'] as String?)?.isNotEmpty == true
        ? data['joiningDate'] as String
        : defaultProfile.joiningDate;
    final dob = (data['dob'] as String?)?.isNotEmpty == true
        ? data['dob'] as String
        : defaultProfile.dob;
    final gender = (data['gender'] as String?)?.isNotEmpty == true
        ? data['gender'] as String
        : defaultProfile.gender;

    final dlUrl = (data['dlFrontUrl'] ?? data['drivingLicense'] ?? data['drivingLicenseNumber'] ?? '').toString();
    final rcUrl = (data['rcBookUrl'] ?? data['vehicleRcUrl'] ?? '').toString();
    final insUrl = (data['insuranceUrl'] ?? '').toString();
    final aadhaarUrl = (data['idProofUrl'] ?? data['aadhaarFrontUrl'] ?? data['aadhaarUrl'] ?? data['aadhaarNumber'] ?? '').toString();
    final panUrl = (data['panCardUrl'] ?? data['panNumber'] ?? '').toString();

    final updatedDocs = defaultDocuments.map((doc) {
      if (doc.id == 'drivingLicense' && (drivingLicense.isNotEmpty || dlUrl.isNotEmpty)) {
        return doc.copyWith(
          status: (kycStatus == 'approved' || kycStatus == 'verified')
              ? DeliveryProfileDocumentStatus.verified
              : DeliveryProfileDocumentStatus.uploaded,
          progress: 1.0,
          documentUrl: dlUrl.isNotEmpty ? dlUrl : drivingLicense,
        );
      } else if (doc.id == 'vehicleRc' && (vehicleRcUrl.isNotEmpty || rcUrl.isNotEmpty)) {
        return doc.copyWith(
          status: (kycStatus == 'approved' || kycStatus == 'verified')
              ? DeliveryProfileDocumentStatus.verified
              : DeliveryProfileDocumentStatus.uploaded,
          progress: 1.0,
          documentUrl: rcUrl.isNotEmpty ? rcUrl : vehicleRcUrl,
        );
      } else if (doc.id == 'insurance' && (insuranceUrl.isNotEmpty || insUrl.isNotEmpty || aadhaarUrl.isNotEmpty)) {
        return doc.copyWith(
          status: (kycStatus == 'approved' || kycStatus == 'verified')
              ? DeliveryProfileDocumentStatus.verified
              : DeliveryProfileDocumentStatus.uploaded,
          progress: 1.0,
          documentUrl: insUrl.isNotEmpty ? insUrl : (aadhaarUrl.isNotEmpty ? aadhaarUrl : insuranceUrl),
        );
      } else if (doc.id == 'panCard' && (panNumber.isNotEmpty || panUrl.isNotEmpty)) {
        return doc.copyWith(
          status: (kycStatus == 'approved' || kycStatus == 'verified')
              ? DeliveryProfileDocumentStatus.verified
              : DeliveryProfileDocumentStatus.uploaded,
          progress: 1.0,
          documentUrl: panUrl.isNotEmpty ? panUrl : panNumber,
        );
      }
      return doc;
    }).toList();

    final Map<String, bool> verifications = {
      'phone': phone.isNotEmpty,
      'email': email.isNotEmpty,
      'identity': kycStatus == 'approved' || status == 'approved',
      'document': updatedDocs.every((d) => d.isUploaded),
    };

    return defaultProfile.copyWith(
      partnerId: partnerId,
      fullName: displayName,
      phone: phone,
      email: email,
      address: address,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      googleMapsUrl: data['googleMapsUrl'] as String?,
      dob: data['dob'] ?? '',
      gender: data['gender'] ?? '',
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: drivingLicense,
      avatarPath: (data['photoUrl'] as String?)?.isNotEmpty == true
          ? data['photoUrl']
          : defaultProfile.avatarPath,
      joiningDate: joiningDate,
      rating: rating,
      totalDeliveries: totalDeliveries,
      isActive: isActive,
      verificationStatus: status,
      kycStatus: kycStatus,
      documents: updatedDocs,
      verificationStatuses: verifications,
    );
  }

  @override
  Future<void> saveProfile(DeliveryProfileState profile) async {
    double? lat = profile.latitude;
    double? lng = profile.longitude;
    String? gUrl = profile.googleMapsUrl;

    if ((lat == null || lng == null || (lat == 0.0 && lng == 0.0)) && profile.address.trim().isNotEmpty) {
      try {
        final details = await GooglePlacesService.instance.getPlaceDetails('', fallbackAddress: profile.address.trim());
        if (details != null && details.latitude != null && details.longitude != null) {
          lat = details.latitude;
          lng = details.longitude;
          gUrl ??= 'https://www.google.com/maps?q=${lat!.toStringAsFixed(6)},${lng!.toStringAsFixed(6)}';
        }
      } catch (_) {}
    }

    final prefs = await _getPrefs();
    if (prefs != null) {
      final map = <String, String>{
        'fullName': profile.fullName,
        'phone': profile.phone,
        'email': profile.email,
        'address': profile.address,
        if (lat != null) 'latitude': lat.toString(),
        if (lng != null) 'longitude': lng.toString(),
        if (gUrl != null) 'googleMapsUrl': gUrl,
        'dob': profile.dob,
        'gender': profile.gender,
        'vehicleType': profile.vehicleType,
        'vehicleNumber': profile.vehicleNumber,
        'licenseNumber': profile.licenseNumber,
        'licenseValidTill': profile.licenseValidTill,
      };
      await prefs.setString(_profileKey, jsonEncode(map));
      if (profile.avatarPath != null) {
        await prefs.setString(_avatarKey, profile.avatarPath!);
      } else {
        await prefs.remove(_avatarKey);
      }
    }

    try {
      await _service.updateProfile({
        'displayName': profile.fullName,
        'phoneNumber': profile.phone,
        'email': profile.email,
        'address': profile.address,
        'latitude': lat,
        'longitude': lng,
        'googleMapsUrl': gUrl,
        'vehicleType': profile.vehicleType,
        'vehicleNumber': profile.vehicleNumber,
        'drivingLicense': profile.licenseNumber,
      });
    } catch (_) {}
  }

  @override
  Future<void> updateAddress(
    String address, {
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
  }) async {
    double? lat = latitude;
    double? lng = longitude;
    String? gUrl = googleMapsUrl;

    if ((lat == null || lng == null || (lat == 0.0 && lng == 0.0)) && address.trim().isNotEmpty) {
      try {
        final details = await GooglePlacesService.instance.getPlaceDetails('', fallbackAddress: address.trim());
        if (details != null && details.latitude != null && details.longitude != null) {
          lat = details.latitude;
          lng = details.longitude;
          gUrl ??= 'https://www.google.com/maps?q=${lat!.toStringAsFixed(6)},${lng!.toStringAsFixed(6)}';
        }
      } catch (_) {}
    }

    await _service.updateProfile({
      'address': address,
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
      if (gUrl != null) 'googleMapsUrl': gUrl,
    });
  }

  @override
  Future<void> updateVehicle({
    required String vehicleType,
    required String vehicleNumber,
  }) async {
    await _service.updateProfile({
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
    });
  }

  @override
  Future<void> updatePhone(String phone) async {
    await _service.updateProfile({'phoneNumber': phone});
  }

  @override
  Future<void> updateEmail(String email) async {
    await _service.updateProfile({'email': email});
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deactivateAccount() async {
    await _service.deactivateAccount();
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }

  @override
  Future<String?> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getAvatarPath() async {
    final prefs = await _getPrefs();
    return prefs?.getString(_avatarKey);
  }

  @override
  Future<void> saveAvatarPath(String? path) async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    if (path == null) {
      await prefs.remove(_avatarKey);
    } else {
      await prefs.setString(_avatarKey, path);
    }
  }
}
