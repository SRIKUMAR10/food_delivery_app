import 'dart:io';

void main() {
  final dir = Directory('d:\\Flutter_Project\\food_delivery_app');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('GoogleFonts')) {
      content = content.replaceAll(RegExp(r"import\s+'package:google_fonts/google_fonts\.dart';\r?\n"), '');
      content = content.replaceAll(RegExp(r"GoogleFonts\.[a-zA-Z0-9_]+\("), 'TextStyle(');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
}

