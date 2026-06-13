// lib/user_profile_image/user_profile_image_Event.dart
//
// Defines the events for the User Profile BLoC.

part of 'user_profile_image_Bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the profile is first loaded.
class LoadProfileStarted extends UserProfileEvent {
  const LoadProfileStarted();
}

/// Dispatched when the user picks an image to upload.
class ProfileImagePicked extends UserProfileEvent {
  const ProfileImagePicked();
}

/// Internal event used to update the upload progress in the UI.
class ProfileImageUploadProgress extends UserProfileEvent {
  final double progress;

  const ProfileImageUploadProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Dispatched when the user saves the profile form.
class ProfileSaved extends UserProfileEvent {
  final UserProfile profile;

  const ProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Dispatched when the user signs out.
class SignOutRequested extends UserProfileEvent {
  const SignOutRequested();
}
