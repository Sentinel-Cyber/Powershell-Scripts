# File Copy and SFTP Upload Script
# Purpose: Locate most recent file, copy to destination, upload via SFTP, then archive
# Author: System Administrator
# Date: December 30, 2024

# Error handling preference
$ErrorActionPreference = "Stop"

# Function for standardized logging
function Write-LogEntry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$LogPath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\file_operations.log"
    )
    
    try {
        $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $LogEntry = "$TimeStamp - $Message"
        Add-Content -Path $LogPath -Value $LogEntry
        Write-Host $LogEntry
    }
    catch {
        Write-Error "Failed to write to log file: $_"
        throw
    }
}

# Function to validate path existence
function Test-PathAvailable {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        Write-LogEntry "ERROR: Path not accessible: $Path"
        throw "Path not accessible: $Path"
    }
}

# Define paths
$sourcePath = "\\12-S-FS01\Accounting\Wildermuth\SS&C - Pricing File"
$outboundPath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\M3-Outbound"
$archivePath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\Archive Outbound"

# Main script execution
try {
    Write-LogEntry "Starting file operation process"
    
    # Validate paths
    Test-PathAvailable $sourcePath
    Test-PathAvailable $outboundPath
    
    # Find latest file
    Write-LogEntry "Searching for latest file in source directory"
    $latestFile = Get-ChildItem -Path $sourcePath | 
                  Where-Object { !$_.PSIsContainer } | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    if ($null -eq $latestFile) {
        throw "No files found in source directory"
    }
    
    Write-LogEntry "Latest file found: $($latestFile.Name)"
    
    # Copy file to outbound directory first
    $outboundFilePath = Join-Path -Path $outboundPath -ChildPath $latestFile.Name
    Write-LogEntry "Copying file to outbound directory: $outboundFilePath"
    Copy-Item -Path $latestFile.FullName -Destination $outboundFilePath -Force
    
    # Verify copy operation
    if (-not (Test-Path $outboundFilePath)) {
        throw "File copy to outbound directory failed"
    }
    Write-LogEntry "File successfully copied to outbound directory"
    
    # Format password for SFTP
    $escapedPassword = "Hn3%24Ys6%2BQx"
    
    # Create the put command with properly quoted path
    $putCommand = """put """"$outboundFilePath"""" /"""
    Write-LogEntry "Starting SFTP transfer"
    
    # Execute WinSCP command
    & "C:\Program Files (x86)\WinSCP\WinSCP.com" `
        /log="\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\WinSCP.log" `
        /ini=nul `
        /command `
        "option batch continue" `
        "option confirm off" `
        "open sftp://wildermuth:$escapedPassword@sfg-prod.ssnc.cloud:50022/ -hostkey=*" `
        $putCommand `
        "exit"
    
    # Move file to archive after SFTP upload
    Write-LogEntry "Moving file from outbound to archive"
    if (-not (Test-Path $archivePath)) {
        Write-LogEntry "Creating archive directory"
        New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    }
    
    $archiveFilePath = Join-Path -Path $archivePath -ChildPath $latestFile.Name
    Move-Item -Path $outboundFilePath -Destination $archiveFilePath -Force
    Write-LogEntry "File successfully moved to archive"
}
catch {
    Write-LogEntry "ERROR: $_"
    throw
}
finally {
    Write-LogEntry "Script execution completed"
}# File Copy and SFTP Upload Script
# Purpose: Locate most recent file, copy to destination, upload via SFTP, then archive
# Author: System Administrator
# Date: December 30, 2024

# Error handling preference
$ErrorActionPreference = "Stop"

# Function for standardized logging
function Write-LogEntry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$LogPath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\file_operations.log"
    )
    
    try {
        $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $LogEntry = "$TimeStamp - $Message"
        Add-Content -Path $LogPath -Value $LogEntry
        Write-Host $LogEntry
    }
    catch {
        Write-Error "Failed to write to log file: $_"
        throw
    }
}

# Function to validate path existence
function Test-PathAvailable {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        Write-LogEntry "ERROR: Path not accessible: $Path"
        throw "Path not accessible: $Path"
    }
}

# Define paths
$sourcePath = "\\12-S-FS01\Accounting\Wildermuth\SS&C - Pricing File"
$outboundPath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\M3-Outbound"
$archivePath = "\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\Archive Outbound"

# Main script execution
try {
    Write-LogEntry "Starting file operation process"
    
    # Validate paths
    Test-PathAvailable $sourcePath
    Test-PathAvailable $outboundPath
    
    # Find latest file
    Write-LogEntry "Searching for latest file in source directory"
    $latestFile = Get-ChildItem -Path $sourcePath | 
                  Where-Object { !$_.PSIsContainer } | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    if ($null -eq $latestFile) {
        throw "No files found in source directory"
    }
    
    Write-LogEntry "Latest file found: $($latestFile.Name)"
    
    # Copy file to outbound directory first
    $outboundFilePath = Join-Path -Path $outboundPath -ChildPath $latestFile.Name
    Write-LogEntry "Copying file to outbound directory: $outboundFilePath"
    Copy-Item -Path $latestFile.FullName -Destination $outboundFilePath -Force
    
    # Verify copy operation
    if (-not (Test-Path $outboundFilePath)) {
        throw "File copy to outbound directory failed"
    }
    Write-LogEntry "File successfully copied to outbound directory"
    
    # Format password for SFTP
    $escapedPassword = "Hn3%24Ys6%2BQx"
    
    # Create the put command with properly quoted path
    $putCommand = """put """"$outboundFilePath"""" /"""
    Write-LogEntry "Starting SFTP transfer"
    
    # Execute WinSCP command
    & "C:\Program Files (x86)\WinSCP\WinSCP.com" `
        /log="\\12-S-FS01\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\WinSCP.log" `
        /ini=nul `
        /command `
        "option batch continue" `
        "option confirm off" `
        "open sftp://wildermuth:$escapedPassword@sfg-prod.ssnc.cloud:50022/ -hostkey=*" `
        $putCommand `
        "exit"
    
    # Move file to archive after SFTP upload
    Write-LogEntry "Moving file from outbound to archive"
    if (-not (Test-Path $archivePath)) {
        Write-LogEntry "Creating archive directory"
        New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    }
    
    $archiveFilePath = Join-Path -Path $archivePath -ChildPath $latestFile.Name
    Move-Item -Path $outboundFilePath -Destination $archiveFilePath -Force
    Write-LogEntry "File successfully moved to archive"
}
catch {
    Write-LogEntry "ERROR: $_"
    throw
}
finally {
    Write-LogEntry "Script execution completed"
}