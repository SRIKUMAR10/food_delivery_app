import 'dart:io';

void main() {
  final List<String> sourceDirs = [
    'test/buyer_test/integration',
    'test/seller_test/integration',
  ];
  
  final targetBase = 'integration_test';
  int movedCount = 0;

  for (final sourceDir in sourceDirs) {
    final dir = Directory(sourceDir);
    if (!dir.existsSync()) continue;

    final targetDirName = sourceDir.contains('buyer') ? 'buyer_integration' : 'seller_integration';
    final targetDir = Directory('$targetBase/$targetDirName');
    
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.uri.pathSegments.last;
        final newFile = File('${targetDir.path}/$fileName');
        
        entity.copySync(newFile.path);
        entity.deleteSync();
        movedCount++;
      }
    }
    
    // Clean up empty directories
    if (dir.listSync().isEmpty) {
      dir.deleteSync();
    }
  }

  print('Successfully moved $movedCount integration test files to the integration_test/ directory.');
  print('This resolves the hanging cursor issue when running flutter test!');
}
