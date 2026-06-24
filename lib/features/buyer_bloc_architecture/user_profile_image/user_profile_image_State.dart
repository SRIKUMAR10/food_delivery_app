// lib/user_profile_image/user_profile_image_State.dart
//
// Defines the states for the User Profile BLoC.

part of 'user_profile_image_Bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the BLoC is created.
class ProfileInitial extends UserProfileState {
  const ProfileInitial();
}

/// State when the profile is loading (e.g. fetching from Firestore).
class ProfileLoading extends UserProfileState {
  const ProfileLoading();
}

/// State when the profile is fully loaded and can be edited.
/// Also tracks the upload progress of the profile image.
class ProfileLoaded extends UserProfileState {
  final UserProfile profile;
  final double uploadProgress;
  final bool isSaving;

  const ProfileLoaded({
    required this.profile,
    this.uploadProgress = 0.0,
    this.isSaving = false,
  });

  ProfileLoaded copyWith({
    UserProfile? profile,
    double? uploadProgress,
    bool? isSaving,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [profile, uploadProgress, isSaving];
}

/// State to indicate a success message (e.g., profile saved, image uploaded).
class ProfileSuccessAction extends UserProfileState {
  final String message;
  final UserProfileState previousState;

  const ProfileSuccessAction(this.message, this.previousState);

  @override
  List<Object?> get props => [message, previousState];
}

/// State when an error occurs.
class ProfileError extends UserProfileState {
  final String message;
  final UserProfileState? previousState;

  const ProfileError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// State indicating the user has successfully signed out.
class SignOutSuccess extends UserProfileState {
  const SignOutSuccess();
}
