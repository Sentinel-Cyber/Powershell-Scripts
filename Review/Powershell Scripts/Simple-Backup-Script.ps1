# Backup script with logging functionality

# Configuration variables
$SourcePath = "C:\Backup1"              # Source directory to backup
$DestinationPath = "C:\Backup2"      # Destination for backups
$LogPath = "C:\Logs\Backup"          # Location for log files

# Function to write log entries
function Write-LogEntry {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    # Create logs directory if it doesn't exist
    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    
    $Date = Get-Date -Format "yyyy-MM-dd"
    $Time = Get-Date -Format "HH:mm:ss"
    $LogFile = Join-Path $LogPath "backup_$Date.log"
    
    $LogMessage = "[$Date $Time] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

# Main backup function
function Start-BackupProcess {
    $Date = Get-Date -Format "yyyy-MM-dd"
    
    try {
        Write-LogEntry "Starting backup process"
        Write-LogEntry "Source: $SourcePath"
        Write-LogEntry "Destination: $DestinationPath"
        
        # Verify paths exist
        if (-not (Test-Path $SourcePath)) {
            throw "Source path does not exist"
        }
        
        if (-not (Test-Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
            Write-LogEntry "Created destination directory"
        }
        
        # Get source item name and create dated destination path
        $ItemName = Split-Path $SourcePath -Leaf
        $DatedDestination = Join-Path $DestinationPath "$ItemName`_$Date"
        
        # Copy items
        Copy-Item -Path $SourcePath -Destination $DatedDestination -Recurse -Force
        Write-LogEntry "Successfully copied $ItemName to $DatedDestination"
        
    } catch {
        Write-LogEntry $_.Exception.Message -Level "ERROR"
        throw $_
    }
}

# Execute backup
try {
    Start-BackupProcess
    Write-LogEntry "Backup completed successfully"
} catch {
    Write-LogEntry "Backup failed" -Level "ERROR"
    exit 1
}