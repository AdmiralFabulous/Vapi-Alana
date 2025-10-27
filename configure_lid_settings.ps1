# PowerShell script to configure Windows to keep running with lid closed
# Run this as Administrator

Write-Host "Configuring Windows power settings to keep running with lid closed..." -ForegroundColor Cyan

# Get the active power scheme GUID
$activeScheme = powercfg /getactivescheme
$schemeGuid = ($activeScheme -split '\s+')[3]

Write-Host "Active power scheme: $schemeGuid" -ForegroundColor Yellow

# Set lid close action to "Do Nothing" (0) for both AC and DC power
# GUID: SUB_BUTTONS (4f971e89-eebd-4455-a8de-9e59040e7347)
# GUID: LIDACTION (5ca83367-6e45-459f-a27b-476b1d01c936)

# For AC Power (plugged in)
powercfg /setacvalueindex $schemeGuid 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

# For DC Power (on battery)
powercfg /setdcvalueindex $schemeGuid 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

# Apply the changes
powercfg /setactive $schemeGuid

Write-Host ""
Write-Host "✓ Power settings updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Your laptop will now:" -ForegroundColor Cyan
Write-Host "  - Continue running when lid is closed" -ForegroundColor White
Write-Host "  - Keep audio recording active" -ForegroundColor White
Write-Host "  - Screen will turn off but system stays awake" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: For long recordings with lid closed:" -ForegroundColor Yellow
Write-Host "  • Keep laptop plugged in" -ForegroundColor White
Write-Host "  • Ensure proper ventilation" -ForegroundColor White
Write-Host "  • Place on hard, flat surface" -ForegroundColor White
Write-Host ""

# Verify the settings
Write-Host "Current lid close action settings:" -ForegroundColor Cyan
$acValue = powercfg /query $schemeGuid 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 | Select-String "Current AC Power Setting Index"
$dcValue = powercfg /query $schemeGuid 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 | Select-String "Current DC Power Setting Index"

Write-Host $acValue -ForegroundColor White
Write-Host $dcValue -ForegroundColor White
Write-Host ""
Write-Host "(0 = Do Nothing, 1 = Sleep, 2 = Hibernate, 3 = Shut down)" -ForegroundColor Gray
