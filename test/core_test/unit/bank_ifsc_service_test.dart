import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/bank_ifsc_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  late BankIfscService ifscService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    ifscService = BankIfscService();
    mockHttpClient = MockHttpClient();
  });

  group('BankIfscService & BankBranchInfo Unit Tests', () {
    test('isValidIfscFormat validates strictly according to RBI regex', () {
      expect(BankIfscService.isValidIfscFormat('SBIN0001234'), isTrue);
      expect(BankIfscService.isValidIfscFormat('HDFC0000001'), isTrue);
      expect(BankIfscService.isValidIfscFormat('ICIC0000009'), isTrue);
      expect(BankIfscService.isValidIfscFormat('UTIB0000148'), isTrue);
      expect(BankIfscService.isValidIfscFormat('sbin0001234'), isTrue); // Case-insensitive clean

      // Invalid formats
      expect(BankIfscService.isValidIfscFormat(''), isFalse);
      expect(BankIfscService.isValidIfscFormat('SBIN01234'), isFalse); // < 11 chars
      expect(BankIfscService.isValidIfscFormat('SBIN1001234'), isFalse); // 5th char not 0
      expect(BankIfscService.isValidIfscFormat('SBI00001234'), isFalse); // < 4 letter prefix
      expect(BankIfscService.isValidIfscFormat('SBIN000123456'), isFalse); // > 11 chars
    });

    test('searchBanks returns matched offline branches across multiple keywords', () {
      final sbiResults = ifscService.searchBanks('State Bank Anna Nagar');
      expect(sbiResults.isNotEmpty, isTrue);
      expect(sbiResults.first.bankName, 'State Bank of India');
      expect(sbiResults.first.branch, 'Anna Nagar');
      expect(sbiResults.first.ifsc, 'SBIN0001234');

      final hdfcResults = ifscService.searchBanks('HDFC0000001');
      expect(hdfcResults.isNotEmpty, isTrue);
      expect(hdfcResults.first.bankName, 'HDFC Bank');
      expect(hdfcResults.first.ifsc, 'HDFC0000001');

      final cityResults = ifscService.searchBanks('Coimbatore');
      expect(cityResults.isNotEmpty, isTrue);
      expect(cityResults.any((b) => b.city == 'Coimbatore'), isTrue);
    });

    test('getSupportedBanks and getPopularBanks return expected metadata', () {
      final allBanks = ifscService.getSupportedBanks();
      expect(allBanks.length, greaterThanOrEqualTo(15));
      expect(allBanks.any((b) => b.name == 'State Bank of India'), isTrue);
      expect(allBanks.any((b) => b.name == 'HDFC Bank'), isTrue);

      final popular = ifscService.getPopularBanks();
      expect(popular.isNotEmpty, isTrue);
      expect(popular.every((b) => b.isPopular), isTrue);
    });

    test('hierarchical branch discovery works seamlessly (Bank -> State -> City -> Branch)', () {
      const bankName = 'State Bank of India';
      final states = ifscService.getStatesForBank(bankName);
      expect(states.contains('Tamil Nadu'), isTrue);

      final cities = ifscService.getCitiesForBankAndState(bankName, 'Tamil Nadu');
      expect(cities.contains('Chennai'), isTrue);

      final branches = ifscService.getBranches(bankName, 'Tamil Nadu', 'Chennai');
      expect(branches.isNotEmpty, isTrue);
      expect(branches.any((b) => b.branch == 'Anna Nagar'), isTrue);
      expect(branches.any((b) => b.branch == 'T Nagar'), isTrue);
    });

    test('lookupIfsc returns cached/offline bank details instantly', () async {
      final info = await ifscService.lookupIfsc('SBIN0001234');
      expect(info, isNotNull);
      expect(info!.bankName, 'State Bank of India');
      expect(info.branch, 'Anna Nagar');
      expect(info.city, 'Chennai');
      expect(info.ifsc, 'SBIN0001234');
      expect(info.isVerified, isTrue);
    });

    test('lookupIfsc falls back to online API when not in offline cache', () async {
      const customIfsc = 'KKBK0000999';
      final apiJson = json.encode({
        'IFSC': customIfsc,
        'BANK': 'Kotak Mahindra Bank',
        'BRANCH': 'Koramangala Bangalore',
        'ADDRESS': '80 Feet Road, Koramangala 4th Block',
        'CITY': 'Bengaluru',
        'DISTRICT': 'Bengaluru Urban',
        'STATE': 'Karnataka',
        'UPI': true,
        'NEFT': true,
        'RTGS': true,
        'IMPS': true,
        'BANKCODE': 'KKBK',
      });

      when(() => mockHttpClient.get(Uri.parse('https://ifsc.razorpay.com/$customIfsc')))
          .thenAnswer((_) async => http.Response(apiJson, 200));

      final result = await ifscService.lookupIfsc(customIfsc, client: mockHttpClient);
      expect(result, isNotNull);
      expect(result!.bankName, 'Kotak Mahindra Bank');
      expect(result.branch, 'Koramangala Bangalore');
      expect(result.city, 'Bengaluru');
      expect(result.state, 'Karnataka');
    });

    test('BankBranchInfo serialization and Equatable props', () {
      const item = BankBranchInfo(
        ifsc: 'HDFC0000001',
        bankName: 'HDFC Bank',
        branch: 'Fort Mumbai',
        city: 'Mumbai',
        state: 'Maharashtra',
        upi: true,
      );

      final jsonMap = item.toJson();
      expect(jsonMap['ifsc'], 'HDFC0000001');
      expect(jsonMap['bankName'], 'HDFC Bank');
      expect(jsonMap['city'], 'Mumbai');

      final copied = item.copyWith(branch: 'Nariman Point');
      expect(copied.branch, 'Nariman Point');
      expect(copied.ifsc, 'HDFC0000001');
      expect(copied.props.contains('HDFC0000001'), isTrue);
    });
  });
}
