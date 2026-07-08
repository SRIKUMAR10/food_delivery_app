import 'dart:io';

void main() {
  final dir = Directory('lib/features/buyer_bloc_architecture');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  final outFile = File('analyze_out.txt');
  final out = outFile.openWrite();
  
  for (var file in files) {
    out.writeln('FILE: ${file.path}');
    final content = file.readAsStringSync();
    
    // Find class definitions
    final classMatches = RegExp(r'class\s+([A-Za-z0-9_]+)\s+extends\s+(StatelessWidget|StatefulWidget)').allMatches(content);
    for (var m in classMatches) {
      out.writeln('  CLASS: ${m.group(1)}');
    }
    
    // Find Navigator usages
    final navMatches = RegExp(r'Navigator\.(push[A-Za-z0-9_]*|pop|pushAndRemoveUntil)\s*\(').allMatches(content);
    for (var m in navMatches) {
      out.writeln('  NAV: ${m.group(0)}');
    }
    
    // Attempt to extract the target page
    final builderMatches = RegExp(r'builder:\s*\(\s*(?:context|ctx|_)\s*\)\s*=>\s*([A-Za-z0-9_]+)\s*\(').allMatches(content);
    for (var m in builderMatches) {
      out.writeln('  TARGET: ${m.group(1)}');
    }
    
    // Also look for MaterialPageRoute(builder: (context) => TargetPage())
    final materialRouteMatches = RegExp(r'MaterialPageRoute\(\s*builder:\s*\(\s*(?:context|ctx|_)\s*\)\s*=>\s*([A-Za-z0-9_]+)\s*\(').allMatches(content);
    for (var m in materialRouteMatches) {
      out.writeln('  ROUTE_TARGET: ${m.group(1)}');
    }
  }
  
  out.close();
}
