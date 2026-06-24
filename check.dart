import 'dart:io';

void main() async {
  var dir = Directory(r'C:\Users\DELL\AppData\Local\Pub\Cache\hosted\pub.dev');
  if (await dir.exists()) {
    var packages = await dir.list().toList();
    for (var p in packages) {
      if (p.path.contains('image_cropper-')) {
        print(p.path);
        var f = File('${p.path}/lib/src/models/crop_aspect_ratio.dart');
        if (await f.exists()) {
          print(await f.readAsString());
        } else {
          print('no crop_aspect_ratio.dart');
        }
      }
    }
  } else {
    print('dir not found');
  }
}
