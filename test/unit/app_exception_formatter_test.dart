import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';

void main() {
  group('AppExceptionFormatter', () {
    test('formats null error gracefully', () {
      final msg = AppExceptionFormatter.toUserFriendlyMessage(null);
      expect(msg, 'An unexpected error occurred. Please try again.');
    });

    test('formats raw INTERNAL string error to user-friendly message', () {
      final msg1 = AppExceptionFormatter.toUserFriendlyMessage('INTERNAL');
      expect(msg1, isNot(equals('INTERNAL')));
      expect(msg1, contains('Authentication failed'));

      final msg2 = AppExceptionFormatter.toUserFriendlyMessage(Exception('INTERNAL'));
      expect(msg2, isNot(equals('INTERNAL')));
      expect(msg2, contains('Authentication failed'));
    });

    test('formats FirebaseFunctionsException internal error to user-friendly message', () {
      final exc = FirebaseFunctionsException(
        code: 'internal',
        message: 'INTERNAL',
      );
      final msg = AppExceptionFormatter.toUserFriendlyMessage(exc);
      expect(msg, isNot(equals('INTERNAL')));
      expect(msg, contains('Authentication failed'));
    });

    test('formats unregistered user error message', () {
      final exc = Exception('No registered buyer account found for "+919842730278". Please sign up.');
      final msg = AppExceptionFormatter.toUserFriendlyMessage(exc);
      expect(msg, 'Mobile number or email is not registered. Please sign up.');
    });

    test('formats wrong password error message', () {
      final exc = FirebaseAuthException(code: 'wrong-password', message: 'Password is incorrect');
      final msg = AppExceptionFormatter.toUserFriendlyMessage(exc);
      expect(msg, 'Incorrect password. Please try again.');

      final excInvalidCred = FirebaseAuthException(code: 'invalid-credential', message: 'The email address or password is incorrect');
      expect(AppExceptionFormatter.toUserFriendlyMessage(excInvalidCred), 'Incorrect password. Please try again.');

      final excRawCred = Exception('invalid-credential');
      expect(AppExceptionFormatter.toUserFriendlyMessage(excRawCred), 'Incorrect password. Please try again.');

      final excRawWrongPass = Exception('wrong-password');
      expect(AppExceptionFormatter.toUserFriendlyMessage(excRawWrongPass), 'Incorrect password. Please try again.');

      final excRawInvalidPass = Exception('invalid password');
      expect(AppExceptionFormatter.toUserFriendlyMessage(excRawInvalidPass), 'Incorrect password. Please try again.');
    });

    test('formats network and timeout errors', () {
      final timeoutMsg = AppExceptionFormatter.toUserFriendlyMessage(TimeoutException('Timed out'));
      expect(timeoutMsg, contains('Connection timed out'));

      final socketMsg = AppExceptionFormatter.toUserFriendlyMessage(const SocketException('Failed host lookup'));
      expect(socketMsg, contains('Network connection error'));
    });
  });
}
