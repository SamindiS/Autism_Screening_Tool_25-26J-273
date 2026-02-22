# PowerShell script to create all Flutter app files

$appPath = "rrb_detection_app\lib"

Write-Host "Creating Flutter app structure..." -ForegroundColor Cyan

# Create directories
$directories = @(
    "$appPath\providers",
    "$appPath\screens",
    "$appPath\widgets",
    "$appPath\utils"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Green
    }
}

Write-Host "`nFlutter app structure created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Run: cd rrb_detection_app" -ForegroundColor White
Write-Host "2. Run: C:\flutter\bin\flutter.bat pub get" -ForegroundColor White
Write-Host "3. Check for errors: C:\flutter\bin\flutter.bat analyze" -ForegroundColor White

