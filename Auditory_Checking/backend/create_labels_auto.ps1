# Automatically create labels.csv from videos in folders
# Run this: .\create_labels_auto.ps1

Write-Host "Creating labels.csv from your videos..." -ForegroundColor Green
Write-Host ""

# Navigate to backend
Set-Location "D:\new flutter-app\backend"

# Get all videos from autism folder
# Get videos (path\*.mp4 works; -Include needs -Recurse to take effect)
$autismVideos = @()
foreach ($ext in @("*.mp4","*.avi","*.mov","*.mkv","*.webm")) {
    $autismVideos += Get-ChildItem "training_data\autism\$ext" -ErrorAction SilentlyContinue
}
$typicalVideos = @()
foreach ($ext in @("*.mp4","*.avi","*.mov","*.mkv","*.webm")) {
    $typicalVideos += Get-ChildItem "training_data\typical\$ext" -ErrorAction SilentlyContinue
}

Write-Host "Found videos:" -ForegroundColor Cyan
Write-Host "  Autism: $($autismVideos.Count) videos" -ForegroundColor White
Write-Host "  Typical: $($typicalVideos.Count) videos" -ForegroundColor White
Write-Host "  Total: $($autismVideos.Count + $typicalVideos.Count) videos" -ForegroundColor Green

if ($autismVideos.Count -eq 0 -and $typicalVideos.Count -eq 0) {
    Write-Host "`n❌ No videos found!" -ForegroundColor Red
    Write-Host "Please put videos in:" -ForegroundColor Yellow
    Write-Host "  - training_data\autism\ (for autism videos)" -ForegroundColor White
    Write-Host "  - training_data\typical\ (for typical videos)" -ForegroundColor White
    exit 1
}

# Create CSV content
$csvLines = @("video_path,label,child_age,notes")

# Add autism videos
foreach ($video in $autismVideos) {
    $videoPath = "training_data/autism/$($video.Name)"
    $csvLines += "$videoPath,autism,3,Autism video"
}

# Add typical videos
foreach ($video in $typicalVideos) {
    $videoPath = "training_data/typical/$($video.Name)"
    $csvLines += "$videoPath,typical,3,Typical video"
}

# Save to file
$csvPath = "training_data\labels.csv"
$csvLines -join "`n" | Out-File -FilePath $csvPath -Encoding UTF8 -NoNewline

Write-Host "`n✅ Created labels.csv!" -ForegroundColor Green
Write-Host "   File: $csvPath" -ForegroundColor Cyan
Write-Host "   Total entries: $($csvLines.Count - 1)" -ForegroundColor Cyan

Write-Host "`nLabels.csv preview:" -ForegroundColor Yellow
Get-Content $csvPath | Select-Object -First 5 | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
$totalEntries = $csvLines.Count - 1
if ($totalEntries -gt 5) {
    $moreCount = $totalEntries - 5
    Write-Host "   ... ($moreCount more entries)" -ForegroundColor Gray
}

Write-Host "`nNote: You have $($autismVideos.Count + $typicalVideos.Count) videos total" -ForegroundColor Yellow
Write-Host "   Recommended: 20+ videos per category for better accuracy" -ForegroundColor Yellow
Write-Host "   But you can train with current videos to test the system!" -ForegroundColor Cyan

Write-Host "`nNext step: Train the model" -ForegroundColor Green
Write-Host "   Run: python train_model.py" -ForegroundColor White

