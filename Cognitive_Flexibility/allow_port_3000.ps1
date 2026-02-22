# PowerShell script to allow incoming connections on port 3000
# Run this as Administrator

Write-Host "Adding Windows Firewall rule for port 3000..." -ForegroundColor Yellow

# Add firewall rule to allow incoming TCP connections on port 3000
netsh advfirewall firewall add rule name="Flutter Backend Server Port 3000" dir=in action=allow protocol=TCP localport=3000

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Firewall rule added successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend server should now be accessible from your tablet." -ForegroundColor Cyan
    Write-Host "Backend URL: http://192.168.194.180:3000" -ForegroundColor Cyan
} else {
    Write-Host "✗ Failed to add firewall rule. You may need to run as Administrator." -ForegroundColor Red
    Write-Host ""
    Write-Host "To run as Administrator:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor Yellow
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "3. Navigate to this folder and run: .\allow_port_3000.ps1" -ForegroundColor Yellow
}


