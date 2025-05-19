# SentinelOne Installation Script
# Set your site token here
$sitetoken = "YOUR_SITE_TOKEN_HERE"

# Path to the SentinelOne installer
$installerPath = "C:\temp\sentinelone\sentineloneinstaller.exe"

# Check if the installer exists
if (Test-Path $installerPath) {
    # Run the installer with specified parameters
    Start-Process -FilePath $installerPath -ArgumentList "-c -t $sitetoken" -Wait
    Write-Host "SentinelOne installation completed."
} else {
    Write-Error "SentinelOne installer not found at: $installerPath"
} 