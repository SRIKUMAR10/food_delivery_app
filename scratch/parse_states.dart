import 'dart:io';
import 'dart:convert';

void main() {
  var dir = Directory('lib/features/seller_bloc_architecture');
  if (!dir.existsSync()) return;
  
  Map<String, dynamic> schema = {};
  
  var files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('_state.dart')).toList();
  
  final classRegex = RegExp(r'class\s+([A-Za-z0-9_]+)\s+(extends|implements|with|{)');
  final fieldRegex = RegExp(r'final\s+([A-Za-z0-9_<>?]+)\s+([A-Za-z0-9_]+);');
  
  for (var file in files) {
    try {
      var content = file.readAsStringSync();
      var classNameMatch = classRegex.firstMatch(content);
      if (classNameMatch != null) {
        var className = classNameMatch.group(1)!;
        List<Map<String, String>> fields = [];
        
        for (var match in fieldRegex.allMatches(content)) {
          fields.add({
            'type': match.group(1)!,
            'name': match.group(2)!,
          });
        }
        
        schema[className] = fields;
      }
    } catch (e) {
      print('Error parsing ${file.path}: $e');
    }
  }
  
  File('scratch/state_fields.json').writeAsStringSync(JsonEncoder.withIndent('  ').convert(schema));
  print('Done parsing states.');
}
