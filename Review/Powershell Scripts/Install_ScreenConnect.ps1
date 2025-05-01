
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#  ╔═══╗ ╔═══╗ ╔═╗ ╔╗ ╔════╗ ╔══╗ ╔═╗ ╔╗ ╔═══╗ ╔╗     #
#  ║╔═╗║ ║╔══╝ ║║╚╗║║ ║╔╗╔╗║ ╚╣╠╝ ║║╚╗║║ ║╔══╝ ║║     #
#  ║╚══╗ ║╚══╗ ║╔╗╚╝║ ╚╝║║╚╝  ║║  ║╔╗╚╝║ ║╚══╗ ║║     #
#  ╚══╗║ ║╔══╝ ║║╚╗║║   ║║    ║║  ║║╚╗║║ ║╔══╝ ║║     #
#  ║╚═╝║ ║╚══╗ ║║ ║║║  ╔╝╚╗  ╔╣╠╗ ║║ ║║║ ║╚══╗ ║╚══╗  #
#  ╚═══╝ ╚═══╝ ╚╝ ╚═╝  ╚══╝  ╚══╝ ╚╝ ╚═╝ ╚═══╝ ╚═══╝  #
#>>>>>>>>>>>>>>>>>>>> [SYSTEM::ACTIVE] <<<<<<<<<<<<<<<<<<<<<<<<#
#######################CYBER DEFENSE ###########################
#####################╔═╗╔═╗╔═╗╔ ╗╦═╗╔═╗#########################
#####################╚═╗║╣ ║  ║ ║╠╦╝║╣ #########################
#####################╚═╝╚═╝╚═╝╚═╝╩╚═╚═╝#########################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

#### Installs Sentinel ScreenConnect for access.

$orgname = {define org name variable here}

# Set error action preference to stop on any error
$ErrorActionPreference = "Stop"

# Configuration
$downloadUrl = "https://sentinelcyber.screenconnect.com/Bin/ScreenConnect.ClientSetup.exe?e=Access&y=Guest&c=$orgname&c=&c=&c=&c=&c=&c=&c="
$installerPath = "$env:TEMP\ScreenConnect.ClientSetup.exe"
$logPath = "$env:TEMP\ScreenConnect_Install.log"

# Function to write to log file
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logPath -Append
    Write-Host $Message
}

try {
    Write-Log "Starting ScreenConnect installation process"
    
    # Download the installer
    Write-Log "Downloading ScreenConnect installer..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
    
    if (!(Test-Path $installerPath)) {
        throw "Failed to download installer"
    }
    Write-Log "Download completed successfully"
    
    # Run the installer silently
    Write-Log "Starting installation..."
    $process = Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Log "Installation completed successfully"
    } else {
        throw "Installation failed with exit code: $($process.ExitCode)"
    }
    
    # Clean up installer file
    Remove-Item -Path $installerPath -Force
    Write-Log "Cleaned up temporary files"
    
} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Installation failed"
    exit 1
}

Write-Log "Script completed"
exit 0