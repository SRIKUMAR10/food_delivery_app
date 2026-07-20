import 'package:flutter_test/flutter_test.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPageRepository', () {
    late DetailsPageRepository repository;
    late DetailsPageService service;

    setUp(() {
      service = DetailsPageService();
      repository = DetailsPageRepository(service: service);
    });

    test('getDetails returns data on success', () async {
      final data = await repository.getDetails('1');
      expect(data['id'], '1');
      expect(data['name'], 'Delicious Burger');
    });

    test('getDetails throws exception on error', () async {
      expect(repository.getDetails('error'), throwsException);
    });
  });
}
