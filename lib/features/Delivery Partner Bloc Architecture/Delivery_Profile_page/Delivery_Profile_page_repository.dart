import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Profile_page_service.dart';
import 'Delivery_Profile_page_state.dart';

abstract class DeliveryProfileRepositoryBase {
  Future<DeliveryProfileState> fetchProfile();
  Future<void> saveProfile(DeliveryProfileState profile);
  Future<String?> pickProfileImage();
  Future<String?> getAvatarPath();
  Future<void> saveAvatarPath(String? path);
}

class DeliveryProfileRepository implements DeliveryProfileRepositoryBase {
  static const String _profileKey = 'dp_profile_data';
  static const String _avatarKey = 'dp_profile_avatar';

  final SharedPreferences? _prefs;
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
      status: DeliveryProfileDocumentStatus.verified,
    ),
    DeliveryProfileDocument(
      id: 'vehicleRc',
      label: 'Vehicle RC',
      icon: Icons.description_outlined,
      status: DeliveryProfileDocumentStatus.uploaded,
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
      status: DeliveryProfileDocumentStatus.uploaded,
    ),
  ];

  static const Map<String, bool> defaultVerificationStatuses = {
    'phone': true,
    'email': true,
    'identity': false,
    'document': true,
  };

  static List<DeliveryProfileChecklistItem> buildDefaultChecklist({
    required DeliveryProfileState profile,
  }) {
    final personalDone =
        [profile.fullName, profile.phone, profile.email, profile.dob]
            .every((f) => f.trim().isNotEmpty);
    final vehicleDone = [
      profile.vehicleType,
      profile.vehicleNumber,
      profile.licenseNumber,
      profile.licenseValidTill,
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
      if (displayName.isNotEmpty) {
        final profile = defaultProfile.copyWith(
          fullName: displayName,
          phone: data['phoneNumber'] ?? defaultProfile.phone,
          email: data['email'] ?? defaultProfile.email,
          vehicleType: data['vehicleType'] ?? defaultProfile.vehicleType,
          vehicleNumber: data['vehicleNumber'] ?? defaultProfile.vehicleNumber,
          licenseNumber: data['drivingLicense'] ?? defaultProfile.licenseNumber,
          avatarPath: (data['photoUrl'] as String?)?.isNotEmpty == true ? data['photoUrl'] : defaultProfile.avatarPath,
        );
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
        fullName: map['fullName'] as String? ?? 'Ravi Kumar',
        phone: map['phone'] as String? ?? '+91 98765 43210',
        email: map['email'] as String? ?? 'ravi.kumar@example.com',
        dob: map['dob'] as String? ?? '15-08-1995',
        gender: map['gender'] as String? ?? 'male',
        vehicleType: map['vehicleType'] as String? ?? 'scooter',
        vehicleNumber: map['vehicleNumber'] as String? ?? '',
        licenseNumber: map['licenseNumber'] as String? ?? 'TN07 20010012345',
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
      avatarPath: avatarPath,
      documents: defaultDocuments,
      verificationStatuses: defaultVerificationStatuses,
      localeCode: 'en',
    );
    final checklist = buildDefaultChecklist(profile: profile);
    return profile.copyWith(checklist: checklist);
  }

  @override
  Future<void> saveProfile(DeliveryProfileState profile) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final map = <String, String>{
        'fullName': profile.fullName,
        'phone': profile.phone,
        'email': profile.email,
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
        'vehicleType': profile.vehicleType,
        'vehicleNumber': profile.vehicleNumber,
        'drivingLicense': profile.licenseNumber,
      });
    } catch (_) {}
  }

  @override
  Future<String?> pickProfileImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return null;
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
