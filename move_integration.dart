import 'dart:io';

void main() {
  final sourceDir = Directory('test/integration');
  final targetDir = Directory('integration_test');

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  for (final entity in sourceDir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final fileName = entity.uri.pathSegments.last;
      entity.copySync('${targetDir.path}/$fileName');
      entity.deleteSync();
    }
  }
  print('Moved successfully');
}
