import 'dart:io';

void main() {
  final basePath = 'test/seller_test';
  final dir = Directory(basePath);
  int fixedCount = 0;

  if (dir.existsSync()) {
    final List<FileSystemEntity> entities = dir.listSync(recursive: true);
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('_test.dart')) {
        String content = entity.readAsStringSync();
        // Check if the file contains the literal undeclared variables from the previous buggy script
        if (content.contains('\$title') || content.contains('\$category')) {
          
          // Extract the title and category based on the filename to fix it properly
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final parts = fileName.replaceAll('.dart', '').split('_');
          
          // Try to guess the category from the directory name
          final parentDirName = entity.parent.path.split(Platform.pathSeparator).last;
          
          // Replace literal $title and $category with something valid
          final titleStr = parts.map((w) => w.isNotEmpty ? '\${w[0].toUpperCase()}\${w.substring(1)}' : '').join(' ');
          
          content = content.replaceAll('\$title', titleStr);
          content = content.replaceAll('\$category', parentDirName);
          
          entity.writeAsStringSync(content);
          fixedCount++;
        }
      }
    }
  }

  print('Successfully fixed \$fixedCount test files containing syntax errors!');
}
