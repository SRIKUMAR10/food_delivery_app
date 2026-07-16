import 'dart:io';
import 'dart:convert';

void main() async {
  var file = File('error_verbose_utf8.txt');
  if (!await file.exists()) {
    file = File('test_errors.txt'); // Fallback
  }
  if (!await file.exists()) return;

  var bytes = await file.readAsBytes();
  var content = '';
  try {
    content = utf8.decode(bytes);
  } catch (e) {
    var runes = <int>[];
    for (var i = 0; i < bytes.length - 1; i += 2) {
      runes.add(bytes[i] | (bytes[i + 1] << 8));
    }
    content = String.fromCharCodes(runes);
  }

  var lines = content.split('\n');
  var outFile = File('extracted_errors.txt');
  var sink = outFile.openWrite();

  for (var line in lines) {
    if (line.contains('Exception:') || line.contains('FAILED:') || line.contains('Expected:') || line.contains('Some tests failed')) {
      sink.writeln(line.trim());
    }
  }
  
  await sink.close();
  print('Done extracting errors');
}
