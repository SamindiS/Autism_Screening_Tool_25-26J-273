# Start all three services in separate PowerShell windows

Write-Host "Starting Backend Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-File", "$PSScriptRoot\start_backend.ps1"

Start-Sleep -Seconds 2

Write-Host "Starting Web Application..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-File", "$PSScriptRoot\start_webapp.ps1"

Start-Sleep -Seconds 2

Write-Host "Starting Python ML Engine..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-File", "$PSScriptRoot\start_python_engine.ps1"

Write-Host "`nAll services are starting in separate windows!" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:3000" -ForegroundColor Yellow
Write-Host "Web App: http://localhost:5173" -ForegroundColor Yellow
Write-Host "Python Engine: http://localhost:8001" -ForegroundColor Yellow
Write-Host "`nPress any key to exit this window (services will keep running)..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
