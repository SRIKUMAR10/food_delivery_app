import 'dart:io';
import 'dart:convert';

void main() async {
  var file = File('error_verbose_utf8.txt');
  if (!await file.exists()) {
    file = File('test_errors.txt');
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
  var outFile = File('scratch/failing_tests_summary.txt');
  // create directory if not exists
  await Directory('scratch').create(recursive: true);
  var sink = outFile.openWrite();

  bool inErrorBlock = false;
  for (var line in lines) {
    if (line.contains('[E]')) {
      inErrorBlock = true;
      sink.writeln('\n-----------------');
      sink.writeln(line.trim());
    } else if (inErrorBlock) {
      if (line.trim().isEmpty) {
        // empty line might not end it, but let's just print a few lines
      }
      if (line.startsWith('00:')) {
        if (!line.contains('[E]')) {
          inErrorBlock = false;
        }
      }
      if (inErrorBlock) {
        if (!line.contains(RegExp(r'package:flutter|dart:async|package:test_api|package:test_core'))) {
           sink.writeln(line.trim());
        }
      }
    }
  }
  
  await sink.close();
  print('Done');
}
