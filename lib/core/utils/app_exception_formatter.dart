import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Centralized utility for converting raw exceptions, Firebase errors,
/// network timeouts, and gRPC codes into user-friendly real-time messages.
class AppExceptionFormatter {
  /// Converts any error object into a clean, human-readable user message.
  static String toUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    String rawMessage = '';
    String code = '';

    if (error is FirebaseAuthException) {
      code = error.code.toLowerCase();
      rawMessage = error.message ?? error.toString();
    } else if (error is FirebaseException) {
      code = error.code.toLowerCase();
      rawMessage = error.message ?? error.toString();
    } else if (error is FirebaseFunctionsException) {
      code = error.code.toLowerCase();
      rawMessage = error.message ?? error.toString();
    } else if (error is TimeoutException) {
      return 'Connection timed out. Please check your network and try again.';
    } else if (error is SocketException) {
      return 'Network connection error. Please check your internet connection.';
    } else {
      rawMessage = error.toString();
    }

    final lower = rawMessage.toLowerCase();
    final lowerCode = code.toLowerCase();

    // 0. Password & Credential Errors (Checked FIRST for Auth failures)
    if (lowerCode.contains('wrong-password') ||
        lowerCode.contains('invalid-credential') ||
        lowerCode.contains('invalid-password') ||
        lowerCode.contains('wrong_password') ||
        lowerCode.contains('invalid_credential') ||
        lowerCode.contains('wrong-credential') ||
        lowerCode.contains('invalid_login_credentials') ||
        lowerCode.contains('invalid-login-credentials') ||
        lowerCode.contains('invalid_credentials') ||
        lowerCode.contains('invalid-credentials') ||
        lower.contains('password is incorrect') ||
        lower.contains('wrong password') ||
        lower.contains('incorrect password') ||
        lower.contains('invalid mobile number or password') ||
        lower.contains('please check the mobile number') ||
        lower.contains('invalid-credential') ||
        lower.contains('invalid_credential') ||
        lower.contains('invalid_login_credentials') ||
        lower.contains('invalid-login-credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid-credentials') ||
        lower.contains('wrong-password') ||
        lower.contains('wrong_password') ||
        lower.contains('invalid password') ||
        lower.contains('invalid_password') ||
        lower.contains('password incorrect') ||
        lower.contains('password is wrong') ||
        lower.contains('password wrong') ||
        lower.contains('password is invalid') ||
        lower.contains('password invalid') ||
        lower.contains('incorrect the password') ||
        (lower.contains('password') &&
            (lower.contains('incorrect') ||
                lower.contains('invalid') ||
                lower.contains('wrong') ||
                lower.contains('failed')))) {
      return 'Please check the mobile number and password';
    }

    // 1. Cloud Functions / Internal Errors & Raw Exception interceptor
    if (lowerCode == 'internal' ||
        lower == 'internal' ||
        lower.contains('exception: internal') ||
        lower.contains('firebasefunctionsexception: internal') ||
        lower.contains('[firebase_functions/internal]') ||
        lower.contains('[cloud_functions/internal]') ||
        lower.contains('internal error')) {
      if (lower.contains('phone') || lower.contains('mobile')) {
        return 'Please enter a valid phone number.';
      }
      if (lower.contains('password') ||
          lower.contains('incorrect') ||
          lower.contains('credential') ||
          lower.contains('invalid_login_credentials') ||
          lower.contains('invalid-login-credentials')) {
        return 'Please check the mobile number and password';
      }
      if (lower.contains('not-found') || lower.contains('no registered')) {
        return 'Mobile number or email is not registered. Please sign up.';
      }
      return 'Please check the mobile number and password';
    }

    // 2. Connection & Timeout Errors
    if (code.contains('deadline-exceeded') ||
        lower.contains('deadline-exceeded') ||
        lower.contains('timed out') ||
        lower.contains('timeout')) {
      return 'Connection timed out. Please check your network and try again.';
    }

    // 3. Network & Server Errors
    if (code.contains('network-request-failed') ||
        code.contains('unavailable') ||
        lower.contains('socketexception') ||
        lower.contains('failed to connect') ||
        lower.contains('network error')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // 4. User Account / Search Errors
    if (code.contains('user-not-found') ||
        code.contains('not-found') ||
        lower.contains('no registered buyer account') ||
        lower.contains('no registered account') ||
        lower.contains('no account found') ||
        lower.contains('user not found')) {
      return 'Mobile number or email is not registered. Please sign up.';
    }

    // 5. Account Exists / Conflict
    if (code.contains('email-already-in-use') ||
        code.contains('account-exists-with-different-credential') ||
        lower.contains('already exists') ||
        lower.contains('account with this mobile number already exists')) {
      return 'An account with this phone or email already exists. Please log in.';
    }

    // 6. Rate Limit / Quota
    if (code.contains('too-many-requests') ||
        code.contains('quota-exceeded') ||
        lower.contains('too many attempts') ||
        lower.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // 7. OTP Verification Errors
    if (code.contains('invalid-verification-code') ||
        code.contains('otp-failed') ||
        lower.contains('invalid otp') ||
        lower.contains('verification code')) {
      return 'Invalid OTP code. Please enter the correct 6-digit code.';
    }

    // 8. Field Validation
    if (code.contains('invalid-phone-number') || lower.contains('invalid phone')) {
      return 'Please enter a valid phone number.';
    }

    if (code.contains('invalid-email') || lower.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    // 9. Disabled Account
    if (code.contains('user-disabled') || lower.contains('user disabled')) {
      return 'This account has been disabled. Please contact support.';
    }

    // Clean up residual raw Exception strings if unmatched
    String cleaned = rawMessage
        .replaceAll(RegExp(r'^\s*Exception:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*\[.*?\]\s*'), '')
        .trim();

    if (cleaned.isEmpty ||
        cleaned == 'INTERNAL' ||
        cleaned.toUpperCase() == 'INTERNAL' ||
        cleaned.contains('Exception') ||
        cleaned.contains('FirebaseAuthException') ||
        cleaned.contains('FirebaseException') ||
        cleaned.contains('FirebaseFunctionsException')) {
      return 'Please check the mobile number and password';
    }

    return cleaned;
  }
}
