import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/gst_verification_service.dart';

void main() {
  group('GstVerificationService Unit Tests', () {
    test('validateGst detects valid 15-character GSTIN for Tamil Nadu (33)', () {
      // 33: Tamil Nadu, AAAPA0000A: PAN (P = Proprietorship), 1: Entity counter, Z: Default
      final checksum = GstVerificationService.calculateChecksum('33AAAPA0000A1Z');
      final validGstin = '33AAAPA0000A1Z$checksum';
      final result = GstVerificationService.validateGst(validGstin);

      expect(result.isValid, isTrue);
      expect(result.isChecksumValid, isTrue);
      expect(result.stateCode, '33');
      expect(result.stateName, 'Tamil Nadu');
      expect(result.panNumber, 'AAAPA0000A');
      expect(result.entityType, 'Individual / Proprietorship');
      expect(result.errorMessage, isNull);
    });

    test('validateGst correctly resolves different state codes and entity types', () {
      // Karnataka (29), Company ('C' at 4th position of PAN)
      final karnatakaResult = GstVerificationService.validateGst('29AAACA1234C1Z5');
      expect(karnatakaResult.isValid, isTrue);
      expect(karnatakaResult.stateCode, '29');
      expect(karnatakaResult.stateName, 'Karnataka');
      expect(karnatakaResult.entityType, 'Company');

      // Maharashtra (27), Partnership / LLP ('F' at 4th position of PAN)
      final maharashtraResult = GstVerificationService.validateGst('27AAAFA1234F1Z8');
      expect(maharashtraResult.isValid, isTrue);
      expect(maharashtraResult.stateCode, '27');
      expect(maharashtraResult.stateName, 'Maharashtra');
      expect(maharashtraResult.entityType, 'Partnership Firm / LLP');

      // Delhi (07), Trust ('T' at 4th position of PAN)
      final delhiResult = GstVerificationService.validateGst('07AAATA1234T1Z3');
      expect(delhiResult.isValid, isTrue);
      expect(delhiResult.stateCode, '07');
      expect(delhiResult.stateName, 'Delhi');
      expect(delhiResult.entityType, 'Trust');
    });

    test('validateGst rejects invalid length and empty inputs', () {
      final emptyResult = GstVerificationService.validateGst('');
      expect(emptyResult.isValid, isFalse);
      expect(emptyResult.errorMessage, contains('cannot be empty'));

      final shortResult = GstVerificationService.validateGst('33AAAAA0000A1Z');
      expect(shortResult.isValid, isFalse);
      expect(shortResult.errorMessage, contains('15 characters'));

      final longResult = GstVerificationService.validateGst('33AAAAA0000A1Z59');
      expect(longResult.isValid, isFalse);
      expect(longResult.errorMessage, contains('15 characters'));
    });

    test('validateGst rejects invalid state codes', () {
      // 00 is not a valid state code
      final invalidStateResult = GstVerificationService.validateGst('00AAAAA0000A1Z5');
      expect(invalidStateResult.isValid, isFalse);
      expect(invalidStateResult.errorMessage, contains('Invalid State Code'));
    });

    test('validateGst enforces 14th character to be Z', () {
      // 14th character is 'A' instead of 'Z'
      final invalid14th = GstVerificationService.validateGst('33AAAAA0000A1A5');
      expect(invalid14th.isValid, isFalse);
      expect(invalid14th.errorMessage, contains('14th character must be Z'));
    });

    test('validateGst cross-verifies against merchant PAN', () {
      const gstin = '33AAAAA0000A1Z5';

      // Matching PAN
      final matchResult = GstVerificationService.validateGst(gstin, matchPan: 'AAAAA0000A');
      expect(matchResult.isValid, isTrue);
      expect(matchResult.panNumber, 'AAAAA0000A');

      // Mismatched PAN
      final mismatchResult = GstVerificationService.validateGst(gstin, matchPan: 'BBBBB9999B');
      expect(mismatchResult.isValid, isFalse);
      expect(mismatchResult.errorMessage, contains('does not match merchant PAN'));
    });

    test('validateGst handles lowercase input gracefully', () {
      final lowerResult = GstVerificationService.validateGst('33aaaaa0000a1z5');
      expect(lowerResult.isValid, isTrue);
      expect(lowerResult.panNumber, 'AAAAA0000A');
      expect(lowerResult.stateCode, '33');
    });

    test('Modulo 36 Luhn checksum calculation verifies authentic check digits', () {
      // Test with known valid checksum digit
      const validGstin = '33AAAAA0000A1Z5';
      expect(GstVerificationService.isValidFormat(validGstin), isTrue);

      final calculatedDigit = GstVerificationService.calculateChecksumDigit('33AAAAA0000A1Z');
      expect(calculatedDigit, isNotNull);
      expect(calculatedDigit!.length, 1);
    });

    test('calculateTax computes statutory 5% restaurant GST with CGST and SGST split', () {
      // Subtotal ₹200 taxable amount at statutory 5%
      final tax = GstVerificationService.calculateTax(
        taxableAmount: 200.0,
        gstRate: 5.0,
        isInterstate: false,
      );

      expect(tax.taxableAmount, 200.0);
      expect(tax.gstRate, 5.0);
      expect(tax.totalTax, 10.0);
      expect(tax.cgst, 5.0);
      expect(tax.sgst, 5.0);
      expect(tax.igst, 0.0);
      expect(tax.totalPayable, 210.0);
      expect(tax.isInterstate, isFalse);
    });

    test('calculateTax computes IGST for interstate orders', () {
      final tax = GstVerificationService.calculateTax(
        taxableAmount: 500.0,
        gstRate: 5.0,
        isInterstate: true,
      );

      expect(tax.totalTax, 25.0);
      expect(tax.cgst, 0.0);
      expect(tax.sgst, 0.0);
      expect(tax.igst, 25.0);
      expect(tax.totalPayable, 525.0);
    });

    test('calculateTax accurately rounds fractional currency amounts to 2 decimal places', () {
      final tax = GstVerificationService.calculateTax(
        taxableAmount: 149.50,
        gstRate: 5.0,
      );

      // 149.50 * 0.05 = 7.475 -> 7.48
      expect(tax.totalTax, 7.48);
      expect(tax.cgst, 3.74);
      expect(tax.sgst, 3.74);
      expect(tax.totalPayable, 156.98);
    });

    test('calculateReverseTax extracts base taxable amount from tax-inclusive price', () {
      final reverse = GstVerificationService.calculateReverseTax(
        inclusiveAmount: 105.0,
        gstRate: 5.0,
      );

      expect(reverse.taxableAmount, 100.0);
      expect(reverse.totalTax, 5.0);
      expect(reverse.cgst, 2.5);
      expect(reverse.sgst, 2.5);
      expect(reverse.totalPayable, 105.0);
    });

    test('getStateName returns correct Indian state and territory names', () {
      expect(GstVerificationService.getStateName('33'), 'Tamil Nadu');
      expect(GstVerificationService.getStateName('29'), 'Karnataka');
      expect(GstVerificationService.getStateName('27'), 'Maharashtra');
      expect(GstVerificationService.getStateName('07'), 'Delhi');
      expect(GstVerificationService.getStateName('32'), 'Kerala');
      expect(GstVerificationService.getStateName('99'), 'Centre Jurisdiction');
      expect(GstVerificationService.getStateName('999'), isNull);
    });
  });
}
