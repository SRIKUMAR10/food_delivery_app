# ============================================================
# 23-06-2026 Restoration - File Deletion Script
# Run from PowerShell (Admin not required)
# ============================================================

$base = "d:\Flutter_Project\food_delivery_app\lib"

# Step 1: Delete entire seller_bloc_architecture folder
Remove-Item -Recurse -Force "$base\features\seller_bloc_architecture"
Write-Host "[OK] Deleted: lib/features/seller_bloc_architecture/" -ForegroundColor Green

# Step 2: Delete new core/models files
Remove-Item -Force "$base\core\models\product_model.dart"
Write-Host "[OK] Deleted: core/models/product_model.dart" -ForegroundColor Green

Remove-Item -Force "$base\core\models\dashboard_overview_model.dart"
Write-Host "[OK] Deleted: core/models/dashboard_overview_model.dart" -ForegroundColor Green

# Step 3: Delete new core/repositories file
Remove-Item -Force "$base\core\repositories\product_repository.dart"
Write-Host "[OK] Deleted: core/repositories/product_repository.dart" -ForegroundColor Green

# Step 4: Delete new core/api file
Remove-Item -Force "$base\core\api\RazorpayApiService.dart"
Write-Host "[OK] Deleted: core/api/RazorpayApiService.dart" -ForegroundColor Green

# Step 5: Delete buyer-side API Service stub folder
Remove-Item -Recurse -Force "$base\features\buyer_bloc_architecture\presentation\API Service"
Write-Host "[OK] Deleted: buyer_bloc_architecture/presentation/API Service/" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Restoration COMPLETE - 23-06-2026 structure" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  flutter clean" -ForegroundColor Yellow
Write-Host "  flutter pub get" -ForegroundColor Yellow
Write-Host "  flutter run" -ForegroundColor Yellow
