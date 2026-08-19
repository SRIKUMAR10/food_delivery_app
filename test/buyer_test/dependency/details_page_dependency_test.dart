import 'package:flutter_test/flutter_test.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Dependency Tests', () {
    test('Dependencies are injected correctly', () {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      // Verify that the injected instances are the ones being used
      expect(repository.service, equals(service));
      expect(bloc.repository, equals(repository));
    });
  });
}
