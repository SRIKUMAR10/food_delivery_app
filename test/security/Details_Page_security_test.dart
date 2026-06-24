import 'package:flutter_test/flutter_test.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Security Tests', () {
    test('State does not contain raw sensitive data', () async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      bloc.add(LoadDetailsEvent('1'));

      // Wait for state to update
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DetailsLoading>(),
          isA<DetailsLoaded>().having((state) {
            // Verify that sensitive fields like tokens or passwords are not present in UI state
            return state.data.containsKey('password') || state.data.containsKey('token');
          }, 'hasSensitiveData', false),
        ]),
      );
    });
  });
}
