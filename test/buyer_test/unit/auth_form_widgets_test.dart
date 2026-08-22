import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/auth_form_widgets.dart';

void main() {
  group('validateRequiredName', () {
    test('returns error when name is null or empty', () {
      expect(validateRequiredName(null), 'Full name is required');
      expect(validateRequiredName(''), 'Full name is required');
      expect(validateRequiredName('   '), 'Full name is required');
    });

    test('returns error when name is shorter than 2 characters', () {
      expect(validateRequiredName('A'), 'Name must be at least 2 characters');
    });

    test('returns null for a valid name', () {
      expect(validateRequiredName('Arjun'), isNull);
      expect(validateRequiredName('  Priya  '), isNull);
    });
  });

  group('validateEmailAddress', () {
    test('returns error when email is null or empty', () {
      expect(validateEmailAddress(null), 'Email address is required');
      expect(validateEmailAddress(''), 'Email address is required');
    });

    test('returns error for malformed emails', () {
      expect(
        validateEmailAddress('not-an-email'),
        'Please enter a valid email address',
      );
      expect(
        validateEmailAddress('a@b'),
        'Please enter a valid email address',
      );
    });

    test('returns null for a valid email', () {
      expect(validateEmailAddress('user@example.com'), isNull);
      expect(validateEmailAddress('  user.name+tag@domain.co.in  '), isNull);
    });
  });

  group('validatePhoneNumber', () {
    test('returns error when phone is null or empty', () {
      expect(validatePhoneNumber(null), 'Phone number is required');
      expect(validatePhoneNumber(''), 'Phone number is required');
    });

    test('returns error when phone has fewer than 10 digits', () {
      expect(
        validatePhoneNumber('987654321'),
        'Phone number must be at least 10 digits',
      );
      expect(
        validatePhoneNumber('+91 98765'),
        'Phone number must be at least 10 digits',
      );
    });

    test('returns null for a valid phone with formatting', () {
      expect(validatePhoneNumber('9876543210'), isNull);
      expect(validatePhoneNumber('+91 98765 43210'), isNull);
    });
  });

  group('authFieldDecoration', () {
    test('uses default fill color when none provided', () {
      final decoration = authFieldDecoration(hintText: 'Enter value');
      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, const Color(0xFFEEF0F5));
      expect(decoration.hintText, 'Enter value');
    });

    test('honours a custom fill color', () {
      final decoration = authFieldDecoration(
        fillColor: Colors.white,
        enabledBorderColor: Colors.grey.withValues(alpha: 0.1),
        focusedBorderColor: Colors.red,
      );
      expect(decoration.fillColor, Colors.white);
      expect(decoration.enabledBorder, isNotNull);
      expect(decoration.focusedBorder, isNotNull);
    });

    test('applies error text and error styles when requested', () {
      final decoration = authFieldDecoration(
        errorText: 'Invalid input',
        showErrorStyles: true,
      );
      expect(decoration.errorText, 'Invalid input');
      expect(decoration.errorBorder, isNotNull);
    });
  });
}