@echo off
setlocal enabledelayedexpansion

echo Checking main drive type (C:)...
echo.

:: Method 1: Using WMIC to check for physical media
echo Method 1: Checking drive media type...
wmic diskdrive get Model, MediaType | findstr /C:"Fixed hard disk media" /C:"SSD"

:: Method 2: Query for disk hardware info
echo.
echo Method 2: Detailed disk information...
powershell -Command "Get-PhysicalDisk | Where-Object DeviceID -eq (Get-Partition -DriveLetter C | Select-Object -ExpandProperty DiskNumber) | Format-Table FriendlyName, MediaType, BusType, Size"

:: Method 3: SSD specific attribute check using smartctl if available
echo.
echo Method 3: Checking drive seek time (SSD should have 0)...
wmic diskdrive get Caption, Size, Model, Status, PNPDeviceID | findstr /C:"PHYSICALDRIVE0"
echo.

:: Method 4: Check if TRIM is supported (usually only on SSDs)
echo Method 4: Checking TRIM support (SSD-only feature)...
fsutil behavior query DisableDeleteNotify
echo Note: DisableDeleteNotify = 0 indicates TRIM is enabled (likely SSD)
echo       DisableDeleteNotify = 1 indicates TRIM is disabled (could be HDD)

:: Summary based on MediaType
echo.
echo Summary:
powershell -Command "$disk = Get-PhysicalDisk | Where-Object DeviceID -eq (Get-Partition -DriveLetter C | Select-Object -ExpandProperty DiskNumber); if ($disk.MediaType -eq 'SSD') { Write-Host 'C: drive is an SSD' -ForegroundColor Green } else { Write-Host 'C: drive is an HDD' -ForegroundColor Yellow }"

echo.
echo Note: On some systems, especially older ones, detection may not be 100%% accurate.
echo Please cross-reference the different method results for the most accurate determination.

pause