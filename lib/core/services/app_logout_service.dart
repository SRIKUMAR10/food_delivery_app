import 'package:flutter/material.dart';
import 'i_auth_service.dart';

/// Centralized logout flow shared across Buyer / Seller / Delivery modules.
///
/// Replaces the previously duplicated `authService.signOut()` + root-navigation
/// pairs in `UserProfileBloc`, `AppSettingsBloc` and their UI listeners.
class AppLogoutService {
  /// Signs the current user out through the provided auth service.
  static Future<void> signOut(IAuthService authService) {
    return authService.signOut();
  }

  /// Resets navigation to the app root after a successful sign-out.
  static void navigateToRoot(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/', (route) => false);
  }
}