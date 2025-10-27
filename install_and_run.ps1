# Quick Install and Run Script for Audio Recorder
# Run this as Administrator in PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Audio Recorder Quick Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Step 1: Check Python
Write-Host "[1/5] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Python not found!" -ForegroundColor Red
    Write-Host "  Please install Python from https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "  Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    pause
    exit
}

# Step 2: Install dependencies
Write-Host ""
Write-Host "[2/5] Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to install dependencies" -ForegroundColor Red
    pause
    exit
}

# Step 3: Configure lid settings
Write-Host ""
Write-Host "[3/5] Configuring power settings (lid stays awake)..." -ForegroundColor Yellow
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 | Out-Null
powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 | Out-Null
powercfg /setactive SCHEME_CURRENT | Out-Null
Write-Host "  ✓ Laptop will stay awake with lid closed" -ForegroundColor Green

# Step 4: Create output directory
Write-Host ""
Write-Host "[4/5] Creating output directory..." -ForegroundColor Yellow
if (-not (Test-Path "C:\Programming")) {
    New-Item -ItemType Directory -Path "C:\Programming" -Force | Out-Null
    Write-Host "  ✓ Created C:\Programming" -ForegroundColor Green
} else {
    Write-Host "  ✓ C:\Programming already exists" -ForegroundColor Green
}

# Step 5: Launch application
Write-Host ""
Write-Host "[5/5] Launching Audio Recorder..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Application is starting!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Look for the 'AU' icon in your system tray" -ForegroundColor White
Write-Host "  • Black = Not recording" -ForegroundColor White
Write-Host "  • White = Recording active" -ForegroundColor White
Write-Host ""
Write-Host "Controls:" -ForegroundColor Cyan
Write-Host "  • Right-click AU icon to start/stop recording" -ForegroundColor White
Write-Host "  • Press Shift + Windows + Q to show interface" -ForegroundColor White
Write-Host "  • Recordings save to: C:\Programming" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C in this window to stop the application" -ForegroundColor Yellow
Write-Host ""

# Run the application
python audio_recorder.py
