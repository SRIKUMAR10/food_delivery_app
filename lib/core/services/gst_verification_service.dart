// lib/core/services/gst_verification_service.dart
//
// Enterprise-grade statutory GST Verification & Calculation Service.
// Zero-mock, production-ready implementation supporting Indian GST laws:
// - 15-character GSTIN structure validation
// - Indian State Code mapping (01 to 38, 97, 99)
// - PAN extraction & entity classification
// - Modulo 36 Luhn Checksum verification
// - Statutory restaurant tax calculation (5% GST: 2.5% CGST + 2.5% SGST)
// - Reverse GST calculation for tax-inclusive menu items

import 'package:equatable/equatable.dart';

/// Comprehensive verification result of a GSTIN.
class GstVerificationResult extends Equatable {
  final bool isValid;
  final String gstin;
  final String stateCode;
  final String stateName;
  final String panNumber;
  final String entityType;
  final String entityCode;
  final bool isChecksumValid;
  final String? errorMessage;

  const GstVerificationResult({
    required this.isValid,
    required this.gstin,
    this.stateCode = '',
    this.stateName = '',
    this.panNumber = '',
    this.entityType = '',
    this.entityCode = '',
    this.isChecksumValid = false,
    this.errorMessage,
  });

  /// Factory for an invalid result.
  factory GstVerificationResult.invalid(String gstin, String errorMessage) {
    return GstVerificationResult(
      isValid: false,
      gstin: gstin.trim().toUpperCase(),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isValid,
        gstin,
        stateCode,
        stateName,
        panNumber,
        entityType,
        entityCode,
        isChecksumValid,
        errorMessage,
      ];
}

/// Detailed breakdown of GST tax computation.
class GstTaxBreakdown extends Equatable {
  final double taxableAmount;
  final double gstRate;
  final double totalTax;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalPayable;

  const GstTaxBreakdown({
    required this.taxableAmount,
    required this.gstRate,
    required this.totalTax,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalPayable,
  });

  /// Whether this tax breakdown represents interstate supply (IGST).
  bool get isInterstate => igst > 0;
  bool get isInterState => igst > 0;

  @override
  List<Object?> get props => [
        taxableAmount,
        gstRate,
        totalTax,
        cgst,
        sgst,
        igst,
        totalPayable,
      ];
}

/// Stateless statutory GST verification and calculation service.
class GstVerificationService {
  const GstVerificationService._();

  static const String _gstChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Standard 15-character GSTIN regex conforming to Government of India specifications:
  /// - 2 digits: State Code
  /// - 5 letters: PAN 1-5 (alphabetic)
  /// - 4 digits: PAN 6-9 (numeric)
  /// - 1 letter: PAN 10 (alphabetic)
  /// - 1 char: Entity number of same PAN in the state (1-9, A-Z)
  /// - 1 char: 'Z' by default
  /// - 1 char: Check digit (0-9, A-Z)
  static final RegExp _gstinRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  /// Standard 10-character Indian PAN regex.
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  /// Indian State Codes mapped to their official state/UT names.
  static const Map<String, String> stateCodes = {
    '01': 'Jammu and Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra and Nagar Haveli and Daman and Diu',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh (Old)',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman and Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh (New)',
    '38': 'Ladakh',
    '97': 'Other Territory',
    '99': 'Centre Jurisdiction',
  };

  /// 4th character of PAN represents the entity status.
  static const Map<String, String> entityTypeMap = {
    'C': 'Company',
    'P': 'Individual / Proprietorship',
    'H': 'Hindu Undivided Family (HUF)',
    'F': 'Partnership Firm / LLP',
    'A': 'Association of Persons (AOP)',
    'T': 'Trust',
    'B': 'Body of Individuals (BOI)',
    'L': 'Local Authority',
    'J': 'Artificial Juridical Person',
    'G': 'Government Agency',
  };

  /// Validates a GSTIN string deeply and returns a rich [GstVerificationResult].
  ///
  /// [matchPan] optionally verifies if the embedded PAN matches the merchant's business PAN.
  static GstVerificationResult validateGst(String? gstin, {String? matchPan}) {
    if (gstin == null || gstin.trim().isEmpty) {
      return const GstVerificationResult(
        isValid: false,
        gstin: '',
        errorMessage: 'GSTIN cannot be empty',
      );
    }

    final normalized = gstin.trim().toUpperCase();

    // 1. Length check
    if (normalized.length != 15) {
      return GstVerificationResult.invalid(
        normalized,
        'GSTIN must be exactly 15 characters long (currently ${normalized.length})',
      );
    }

    // 2. Syntax Regex check
    if (!_gstinRegex.hasMatch(normalized)) {
      if (normalized[13] != 'Z') {
        return GstVerificationResult.invalid(
          normalized,
          'Invalid GSTIN format: 14th character must be Z by default.',
        );
      }
      return GstVerificationResult.invalid(
        normalized,
        'Invalid GSTIN format. Expected format: 33AAAAA0000A1Z5',
      );
    }

    // 3. State Code check
    final stateCode = normalized.substring(0, 2);
    final stateName = stateCodes[stateCode];
    if (stateName == null) {
      return GstVerificationResult.invalid(
        normalized,
        'Invalid State Code "$stateCode". Must be between 01 and 38, 97, or 99.',
      );
    }

    // 4. PAN Extraction & validation
    final pan = normalized.substring(2, 12);
    if (!_panRegex.hasMatch(pan)) {
      return GstVerificationResult.invalid(
        normalized,
        'Invalid PAN component embedded in GSTIN ($pan).',
      );
    }

    if (matchPan != null && matchPan.trim().isNotEmpty) {
      final normalizedMatchPan = matchPan.trim().toUpperCase();
      if (pan != normalizedMatchPan) {
        return GstVerificationResult.invalid(
          normalized,
          'GSTIN PAN ($pan) does not match merchant PAN ($normalizedMatchPan).',
        );
      }
    }

    final entityChar = pan[3];
    final entityType = entityTypeMap[entityChar] ?? 'Business Entity';

    // 5. Luhn Modulo 36 Checksum verification
    final isChecksumValid = verifyChecksum(normalized);

    return GstVerificationResult(
      isValid: true,
      gstin: normalized,
      stateCode: stateCode,
      stateName: stateName,
      panNumber: pan,
      entityType: entityType,
      entityCode: entityChar,
      isChecksumValid: isChecksumValid,
      errorMessage: isChecksumValid ? null : 'Checksum warning: 15th digit mismatch',
    );
  }

  /// Calculates the 15th Modulo 36 Luhn check digit for a 14-character GSTIN prefix.
  static String calculateChecksum(String gstin14) {
    if (gstin14.length < 14) return '';
    final code = gstin14.toUpperCase().substring(0, 14);

    int sum = 0;
    for (int i = 0; i < 14; i++) {
      final char = code[i];
      final charVal = _gstChars.indexOf(char);
      if (charVal == -1) return '';

      final factor = (i % 2 == 0) ? 1 : 2;
      final product = charVal * factor;
      final quotient = product ~/ 36;
      final remainder = product % 36;
      sum += quotient + remainder;
    }

    final checkCodeIndex = (36 - (sum % 36)) % 36;
    return _gstChars[checkCodeIndex];
  }

  /// Quick boolean format validator.
  static bool isValidFormat(String gstin) {
    return _gstinRegex.hasMatch(gstin.trim().toUpperCase());
  }

  /// Looks up official Indian State/UT name by 2-digit code.
  static String? getStateName(String stateCode) {
    return stateCodes[stateCode.trim()];
  }

  /// Calculates the 15th checksum character using Modulo 36 Luhn algorithm.
  static String? calculateChecksumDigit(String gstin14) {
    final res = calculateChecksum(gstin14);
    return res.isNotEmpty ? res : null;
  }

  /// Verifies whether the 15th character matches the calculated Luhn Modulo 36 check digit.
  static bool verifyChecksum(String gstin15) {
    if (gstin15.length != 15) return false;
    final expectedChar = calculateChecksum(gstin15.substring(0, 14));
    return expectedChar.isNotEmpty && gstin15[14].toUpperCase() == expectedChar;
  }

  /// Calculates forward GST breakdown for a given [taxableAmount] and [gstRate].
  ///
  /// For restaurant food services in India (under Section 9(5) CGST Act):
  /// - Standard rate is 5.0%
  /// - Intra-state: CGST = 2.5%, SGST = 2.5%
  /// - Inter-state: IGST = 5.0%
  static GstTaxBreakdown calculateTax({
    required double taxableAmount,
    double gstRate = 5.0,
    bool isInterState = false,
    bool? isInterstate,
  }) {
    final bool interState = isInterstate ?? isInterState;
    if (taxableAmount <= 0.0 || gstRate <= 0.0) {
      return GstTaxBreakdown(
        taxableAmount: taxableAmount > 0 ? taxableAmount : 0.0,
        gstRate: gstRate > 0 ? gstRate : 0.0,
        totalTax: 0.0,
        cgst: 0.0,
        sgst: 0.0,
        igst: 0.0,
        totalPayable: taxableAmount > 0 ? taxableAmount : 0.0,
      );
    }

    // Rounding to 2 decimal places to match server-side Cloud Function rounding
    final totalTax = ((taxableAmount * (gstRate / 100)) * 100).roundToDouble() / 100.0;
    final halfTax = ((totalTax / 2) * 100).roundToDouble() / 100.0;

    final cgst = interState ? 0.0 : halfTax;
    final sgst = interState ? 0.0 : (totalTax - cgst);
    final igst = interState ? totalTax : 0.0;
    final totalPayable = ((taxableAmount + totalTax) * 100).roundToDouble() / 100.0;

    return GstTaxBreakdown(
      taxableAmount: taxableAmount,
      gstRate: gstRate,
      totalTax: totalTax,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalPayable: totalPayable,
    );
  }

  /// Extracts pre-tax base price and tax amount from a GST-inclusive price.
  ///
  /// Used for menu items where prices are displayed inclusive of GST.
  static ({double basePrice, double taxAmount}) reverseTax({
    required double inclusivePrice,
    double gstRate = 5.0,
  }) {
    if (inclusivePrice <= 0.0 || gstRate <= 0.0) {
      return (basePrice: inclusivePrice > 0 ? inclusivePrice : 0.0, taxAmount: 0.0);
    }

    final basePrice = ((inclusivePrice / (1 + (gstRate / 100))) * 100).roundToDouble() / 100.0;
    final taxAmount = ((inclusivePrice - basePrice) * 100).roundToDouble() / 100.0;

    return (basePrice: basePrice, taxAmount: taxAmount);
  }

  /// Returns full [GstTaxBreakdown] from a tax-inclusive amount.
  static GstTaxBreakdown calculateReverseTax({
    required double inclusiveAmount,
    double gstRate = 5.0,
    bool isInterState = false,
    bool? isInterstate,
  }) {
    final bool interState = isInterstate ?? isInterState;
    final rev = reverseTax(inclusivePrice: inclusiveAmount, gstRate: gstRate);
    final halfTax = ((rev.taxAmount / 2) * 100).roundToDouble() / 100.0;
    return GstTaxBreakdown(
      taxableAmount: rev.basePrice,
      gstRate: gstRate,
      totalTax: rev.taxAmount,
      cgst: interState ? 0.0 : halfTax,
      sgst: interState ? 0.0 : (rev.taxAmount - halfTax),
      igst: interState ? rev.taxAmount : 0.0,
      totalPayable: inclusiveAmount,
    );
  }
}
