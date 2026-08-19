import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionService', () {
    test('PermissionStatus has correct string values', () {
      expect(PermissionStatus.granted.isGranted, isTrue);
      expect(PermissionStatus.denied.isDenied, isTrue);
      expect(PermissionStatus.permanentlyDenied.isPermanentlyDenied, isTrue);
      expect(PermissionStatus.restricted.isRestricted, isTrue);
      expect(PermissionStatus.limited.isLimited, isTrue);
    });

    test('Permission.camera and Permission.microphone exist', () {
      expect(Permission.camera, isA<Permission>());
      expect(Permission.microphone, isA<Permission>());
    });
  });
}
