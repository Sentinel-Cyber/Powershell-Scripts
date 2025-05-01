# Create Variables
$date = Get-Date -Format 'yyyy-MM-dd'
$source = "C:\Program Files (x86)\ScreenConnect"
$dest = "C:\CW Control Backups\SCBackup_$date"

# Warn Tech
Read-Host "This will temporarily disable access to Connectwise Control, please ensure users are out and do not need Control while this backup script runs. Press Enter to accept or close the script to exit."

# Make New Backup Directory
if (-not (Test-Path -LiteralPath $dest)) {
    try {
        New-Item -Path 'C:\CW Control Backups' -Name SCBackup_$date -ItemType 'directory' -ErrorAction Stop | Out-Null #-Force
    }
    Catch {
        Write-Error -Message "Unable to create directory 'SCBackup_$date'. Error was: $_" -Error
    }
    "Successfully created directory 'SCBackup_$date'."

}
else {
    Write-Host "Directory already existed"
}

# Stop CW Control Services
Write-Host "Stopping CW Control Services"

Stop-Service -Name "ScreenConnect Relay" -Force
    $SCRStatus = (Get-Service 'ScreenConnect Relay' | Select-Object Status)
    Write-Host "SC Rrelay Status is $SCRStatus"

Stop-Service -Name "ScreenConnect Security Manager" -Force
    $SCSMStatus = (Get-Service 'ScreenConnect Security Manager' | Select-Object Status)
    Write-Host "SC Security Manger Status is $SCSMStatus"

Stop-Service -Name "ScreenConnect Session Manager" -Force
    $SCSManStatus = (Get-Service 'ScreenConnect Session Manager' | Select-Object Status)
    Write-Host "SC Session Manager Status is $SCSManStatus"

Stop-Service -Name "ScreenConnect Web Server" -Force
    $SCWSStatus = (Get-Service 'ScreenConnect Web Server' | Select-Object Status)
    Write-Host "SC Web Server Status is $SCWSStatus"

# Copy Current Files to New Directory
Write-Host "Attempting to create Control backup"
try {
    Copy-Item -Path $source -Destination $dest -Recurse
} Catch {Write-Host "An error has occurred while copying files for the backup from $source to $dest"}
Write-Host "File Copy for backup finished without errors."

# Starting Services
Write-Host "Starting CW Control Services"

Start-Service -Name "ScreenConnect Relay" -Force
    $SCRStatus = (Get-Service 'ScreenConnect Relay' | Select-Object Status)
    Write-Host "SC Rrelay Status is $SCRStatus"

Start-Service -Name "ScreenConnect Security Manager" -Force
    $SCSMStatus = (Get-Service 'ScreenConnect Security Manager' | Select-Object Status)
    Write-Host "SC Security Manger Status is $SCSMStatus"

Start-Service -Name "ScreenConnect Session Manager" -Force
    $SCSManStatus = (Get-Service 'ScreenConnect Session Manager' | Select-Object Status)
    Write-Host "SC Session Manager Status is $SCSManStatus"

Start-Service -Name "ScreenConnect Web Server" -Force
    $SCWSStatus = (Get-Service 'ScreenConnect Web Server' | Select-Object Status)
    Write-Host "SC Web Server Status is $SCWSStatus"

# Script Closing
Write-Host "Script Finished"