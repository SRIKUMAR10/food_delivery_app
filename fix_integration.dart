import 'dart:io';

void main() {
  final testDir = Directory('test');
  final files = testDir.listSync(recursive: true).whereType<File>();
  
  for (final file in files) {
    if (file.path.endsWith('_integration_test.dart') || file.path.endsWith('_Integration_test.dart') || file.path.endsWith('integration_test.dart')) {
      var content = file.readAsStringSync();
      var changed = false;

      // Check for import
      if (!content.contains('package:integration_test/integration_test.dart')) {
        content = "import 'package:integration_test/integration_test.dart';\n" + content;
        changed = true;
      }

      // Check for binding
      if (!content.contains('IntegrationTestWidgetsFlutterBinding.ensureInitialized()')) {
        content = content.replaceFirst(
          RegExp(r'void main\(\)\s*\{'),
          'void main() {\n  IntegrationTestWidgetsFlutterBinding.ensureInitialized();'
        );
        changed = true;
      }

      if (changed) {
        file.writeAsStringSync(content);
        print('Updated \${file.path}');
      }
    }
  }
}
