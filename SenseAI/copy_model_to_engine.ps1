# PowerShell script to copy trained model files to ML engine
# Run this after training your model in the notebook

Write-Host "🔗 Copying Model Files to ML Engine..." -ForegroundColor Cyan
Write-Host ""

# Check if source directory exists
$sourceDir = "ML_TRAINING\models"
if (-not (Test-Path $sourceDir)) {
    Write-Host "❌ Source directory not found: $sourceDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure you've run the training notebook and saved the model files." -ForegroundColor Yellow
    Write-Host "Expected location: $sourceDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If your models are in a different location, please update this script." -ForegroundColor Yellow
    exit 1
}

# Destination directory
$destDir = "senseai_backend\ml_engine\models"

# Create destination directory if it doesn't exist
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Write-Host "✅ Created destination directory: $destDir" -ForegroundColor Green
}

# Files to copy for Age 2-3.5 model
$filesToCopy = @(
    @{Source = "$sourceDir\model_age_2_3_5_questionnaire.pkl"; Dest = "$destDir\model_age_2_3_5_questionnaire.pkl"; Name = "Model"},
    @{Source = "$sourceDir\scaler_age_2_3_5_questionnaire.pkl"; Dest = "$destDir\scaler_age_2_3_5_questionnaire.pkl"; Name = "Scaler"},
    @{Source = "$sourceDir\features_age_2_3_5_questionnaire.json"; Dest = "$destDir\features_age_2_3_5_questionnaire.json"; Name = "Features"},
    @{Source = "$sourceDir\model_metadata_age_2_3_5.json"; Dest = "$destDir\model_metadata_age_2_3_5.json"; Name = "Metadata"}
)

Write-Host "Copying files for Age 2-3.5 Questionnaire Model:" -ForegroundColor Cyan
Write-Host ""

$copied = 0
$skipped = 0

foreach ($file in $filesToCopy) {
    if (Test-Path $file.Source) {
        try {
            Copy-Item -Path $file.Source -Destination $file.Dest -Force
            Write-Host "  ✅ $($file.Name): $($file.Dest)" -ForegroundColor Green
            $copied++
        } catch {
            Write-Host "  ❌ Error copying $($file.Name): $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⚠️  $($file.Name): Not found at $($file.Source)" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Copied: $copied files" -ForegroundColor Green
Write-Host "  Skipped: $skipped files" -ForegroundColor Yellow
Write-Host ""

if ($copied -gt 0) {
    Write-Host "✅ Model files copied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart the ML engine: .\start_python_engine.ps1" -ForegroundColor Yellow
    Write-Host "  2. Check health: http://localhost:8001/health" -ForegroundColor Yellow
    Write-Host "  3. Test prediction: http://localhost:8001/docs" -ForegroundColor Yellow
} else {
    Write-Host "❌ No files were copied. Please check:" -ForegroundColor Red
    Write-Host "  1. Have you run the training notebook?" -ForegroundColor Yellow
    Write-Host "  2. Are model files in: $sourceDir" -ForegroundColor Yellow
    Write-Host "  3. Check the notebook output for the actual save location" -ForegroundColor Yellow
}

Write-Host ""
