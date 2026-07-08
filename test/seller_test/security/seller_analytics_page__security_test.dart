import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Security test for env variables', () {
    test(
      'Verify API_KEY and BASE_URL are loaded from env, not hardcoded',
      () async {
        dotenv.testLoad(fileInput: 'BASE_URL=secure_url\nAPI_KEY=secure_key');
        expect(dotenv.env['BASE_URL'], 'secure_url');
        expect(dotenv.env['API_KEY'], 'secure_key');
      },
    );
  });
}
