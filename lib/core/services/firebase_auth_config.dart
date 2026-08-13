import 'package:firebase_auth/firebase_auth.dart';

/// Centralized configuration helper for Firebase Authentication.
///
/// Configures [ActionCodeSettings] for email link authentication, password resets,
/// and email verification using authorized Firebase Hosting domains instead of
/// deprecated Firebase Dynamic Links.
class FirebaseAuthConfig {
  /// Primary authorized Firebase Hosting domain.
  static const String primaryHostingDomain = 'food-delivery-app-cd4ca.firebaseapp.com';

  /// Secondary authorized Firebase Hosting domain.
  static const String secondaryHostingDomain = 'food-delivery-app-cd4ca.web.app';

  /// Default redirect URL using the primary hosting domain.
  static const String defaultRedirectUrl = 'https://$primaryHostingDomain';

  /// Default Android package name for App Links.
  static const String androidPackageName = 'com.example.food_delivery_app';

  /// Default iOS bundle identifier for Universal Links.
  static const String iOSBundleId = 'com.example.foodDeliveryApp';

  /// Creates standardized [ActionCodeSettings] configured with Firebase Hosting domains.
  ///
  /// Deprecated [dynamicLinkDomain] is explicitly omitted in compliance with modern
  /// Firebase Authentication standards.
  static ActionCodeSettings getActionCodeSettings({
    String? url,
    bool handleCodeInApp = true,
    bool androidInstallApp = true,
    String androidMinimumVersion = '1',
    String? linkDomain,
  }) {
    final targetUrl = url ?? defaultRedirectUrl;
    final targetLinkDomain = linkDomain ?? primaryHostingDomain;

    return ActionCodeSettings(
      url: targetUrl,
      handleCodeInApp: handleCodeInApp,
      androidPackageName: androidPackageName,
      androidInstallApp: androidInstallApp,
      androidMinimumVersion: androidMinimumVersion,
      iOSBundleId: iOSBundleId,
      linkDomain: targetLinkDomain,
    );
  }

  /// Convenience getter for standard default ActionCodeSettings.
  static ActionCodeSettings get defaultActionCodeSettings => getActionCodeSettings();
}
