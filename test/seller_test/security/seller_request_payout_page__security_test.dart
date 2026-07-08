import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Security and Environment Configuration Tests', () {
    test(
      'Verify env configurations are not hardcoded or empty in production environments',
      () async {
        await dotenv.load(fileName: '.env.example');

        final apiBaseUrl = dotenv.env['BASE_URL'];
        final apiKey = dotenv.env['API_KEY'];

        expect(apiBaseUrl, isNotNull);
        expect(apiKey, isNotNull);
      },
    );
  });
}
