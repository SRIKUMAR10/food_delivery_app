import 'dart:io';

void main() async {
  final dir = Directory('test/seller_test/widget');
  if (!await dir.exists()) return;

  final files = await dir.list().where((e) => e.path.endsWith('_test.dart')).toList();

  for (var file in files) {
    if (file is File) {
      String content = await file.readAsString();

      bool needsFirebase = false;
      
      // If it doesn't have setUpAll with setupFirebaseAuthMocks, let's add it.
      if (!content.contains('setupFirebaseAuthMocks()')) {
        // Add imports if needed
        if (!content.contains('mock_firebase.dart')) {
          content = "import '../../../mock_firebase.dart';\n" + content;
        }
        if (!content.contains('firebase_core.dart')) {
          content = "import 'package:firebase_core/firebase_core.dart';\n" + content;
        }

        // Check if setUpAll exists
        if (content.contains('setUpAll(()')) {
           // It's tricky to insert reliably. Let's just prepend to main()
           // wait, safer to just replace `void main() {` with `void main() { setUpAll(() async { setupFirebaseAuthMocks(); await Firebase.initializeApp(); });`
           content = content.replaceFirst('void main() {', 'void main() {\n  setUpAll(() async {\n    setupFirebaseAuthMocks();\n    await Firebase.initializeApp();\n  });\n');
        } else {
           content = content.replaceFirst('void main() {', 'void main() {\n  setUpAll(() async {\n    setupFirebaseAuthMocks();\n    await Firebase.initializeApp();\n  });\n');
        }
        
        await file.writeAsString(content);
        print('Updated ${file.path}');
      }
    }
  }
}
