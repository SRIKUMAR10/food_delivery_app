$baseDir = "d:\Flutter_Project\food_delivery_app\test\seller_test"

$foldersAndFiles = @{
    "unit" = @("assign_delivery_page__repository_test.dart", "assign_delivery_page__service_test.dart")
    "widget" = @("assign_delivery_page__ui_test.dart")
    "integration" = @("assign_delivery_page__flow_test.dart", "end_to_end_user_flow_test.dart")
    "golden" = @("assign_delivery_page__golden_test.dart")
    "performance" = @("assign_delivery_page__performance_test.dart")
    "accessibility" = @("assign_delivery_page__accessibility_test.dart")
    "security" = @("assign_delivery_page__security_test.dart")
    "localization" = @("assign_delivery_page__localization_test.dart")
    "snapshot" = @("assign_delivery_page__snapshot_test.dart")
    "dependency" = @("assign_delivery_page__dependency_test.dart")
    "state_restoration" = @("assign_delivery_page__state_restoration_test.dart")
    "error_handling" = @("assign_delivery_page__error_handling_test.dart")
    "permission" = @("assign_delivery_page__permission_test.dart")
}

foreach ($folder in $foldersAndFiles.Keys) {
    $dirPath = Join-Path $baseDir $folder
    if (-Not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath | Out-Null
    }
    
    foreach ($file in $foldersAndFiles[$folder]) {
        $filePath = Join-Path $dirPath $file
        $content = "import 'package:flutter_test/flutter_test.dart';`n`nvoid main() {`n  test('Scaffolded test for $file', () {`n    expect(true, true);`n  });`n}"
        Set-Content -Path $filePath -Value $content
    }
}
