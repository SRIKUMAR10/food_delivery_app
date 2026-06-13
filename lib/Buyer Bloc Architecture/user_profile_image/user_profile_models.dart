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
  final String? imageUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.imageUrl,
  });

  /// Creates an empty profile.
  factory UserProfile.empty() {
    return const UserProfile(
      name: '',
      email: '',
      phone: '',
      address: '',
      imageUrl: null,
    );
  }

  /// Creates a copy of the profile with optionally updated fields.
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? imageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [name, email, phone, address, imageUrl];
}
