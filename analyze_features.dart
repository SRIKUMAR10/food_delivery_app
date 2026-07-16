import 'dart:io';

void main() {
  final buyerPath = 'd:/Flutter_Project/food_delivery_app/lib/features/buyer_bloc_architecture';
  final sellerPath = 'd:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture';

  Map<String, List<String>> getFeatureDetails(String basePath) {
    final dir = Directory(basePath);
    if (!dir.existsSync()) return {};
    
    final features = <String, List<String>>{};
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        final featureName = entity.path.split(Platform.pathSeparator).last;
        final files = <String>[];
        for (final subEntity in entity.listSync(recursive: true)) {
          if (subEntity is File) {
            files.add(subEntity.path.split(Platform.pathSeparator).last);
          }
        }
        features[featureName] = files;
      }
    }
    return features;
  }

  final buyerFeatures = getFeatureDetails(buyerPath);
  final sellerFeatures = getFeatureDetails(sellerPath);

  print("=== Buyer Features ===");
  buyerFeatures.forEach((f, files) {
    print("$f: ${files.length} files");
  });
  
  print("\n=== Seller Features ===");
  sellerFeatures.forEach((f, files) {
    final blocFiles = files.where((x) => x.toLowerCase().contains('bloc') || x.toLowerCase().contains('event') || x.toLowerCase().contains('state')).toList();
    final uiFiles = files.where((x) => x.toLowerCase().contains('ui') || x.toLowerCase().contains('screen') || x.toLowerCase().contains('page')).toList();
    print("$f: ${files.length} files (BLoC: ${blocFiles.length}, UI: ${uiFiles.length})");
  });
}
