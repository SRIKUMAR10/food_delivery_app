import 'package:flutter_test/flutter_test.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPageService', () {
    late DetailsPageService service;

    setUp(() {
      service = DetailsPageService();
    });

    test('fetchDetails returns valid data', () async {
      final result = await service.fetchDetails('123');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], '123');
      expect(result['price'], 10.99);
    });

    test('fetchDetails throws exception when id is error', () async {
      expect(() => service.fetchDetails('error'), throwsA(isA<Exception>()));
    });
  });
}
