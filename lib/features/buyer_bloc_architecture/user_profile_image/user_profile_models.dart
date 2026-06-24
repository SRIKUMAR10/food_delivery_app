// lib/user_profile_image/user_profile_models.dart
//
// Data models for the User Profile.

import 'package:equatable/equatable.dart';

/// Represents the user's profile data.
class UserProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String homeAddress;
  final String workAddress;
  final String otherAddress;
  final String selectedAddressType;
  final String? imageUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.homeAddress = '',
    this.workAddress = '',
    this.otherAddress = '',
    this.selectedAddressType = 'Home',
    this.imageUrl,
  });

  /// Creates an empty profile.
  factory UserProfile.empty() {
    return const UserProfile(
      name: '',
      email: '',
      phone: '',
      address: '',
      homeAddress: '',
      workAddress: '',
      otherAddress: '',
      selectedAddressType: 'Home',
      imageUrl: null,
    );
  }

  /// Creates a copy of the profile with optionally updated fields.
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? homeAddress,
    String? workAddress,
    String? otherAddress,
    String? selectedAddressType,
    String? imageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
      otherAddress: otherAddress ?? this.otherAddress,
      selectedAddressType: selectedAddressType ?? this.selectedAddressType,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        address,
        homeAddress,
        workAddress,
        otherAddress,
        selectedAddressType,
        imageUrl,
      ];
}
