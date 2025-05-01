# Inbound File Transfer and Processing Script
# Purpose: Process inbound SFTP files - copy to archive and move to destination with report name renaming
# Author: Sentinel Cyber
# Date: March 11, 2025

# Error handling preference
$ErrorActionPreference = "Stop"

# Function for standardized logging
function Write-LogEntry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$LogPath = "D:\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\inbound_file_operations.log"
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

# Function to get report name from report code
function Get-ReportName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ReportCode
    )
    
    # Report code to name mapping
    $reportMapping = @{
        "R08032" = "Super Sheet Summary Report"
        "R07369" = "Same-Day Equalization Report"
        "R07370" = "Same-Day Recap & Share Control Sheet (Cash)"
        "R07367" = "Same-Day Recap & Share Control Sheet (Shares)"
        "R07366" = "Same Day Transfer Record"
        "R07371" = "Same Day Distribution of Cash"
    }
    
    # Check if report code exists in the mapping
    if ($reportMapping.ContainsKey($ReportCode)) {
        return $reportMapping[$ReportCode]
    } else {
        Write-LogEntry "WARNING: No mapping found for report code: $ReportCode"
        return $ReportCode
    }
}

# Define paths
$inboundPath = "D:\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\M3-Inbound"
$archivePath = "D:\Accounting\COMMON\SFTP_Clients\SFTP_Wildermuth\Archive Inbound"
$destinationPath = "D:\Accounting\1. Daily Work\Wildermuth\Inbound Files"

# Main script execution
try {
    Write-LogEntry "Starting inbound file processing"
    
    # Validate paths
    Test-PathAvailable $inboundPath
    Test-PathAvailable $destinationPath
    
    # Check if archive path exists, create if not
    if (-not (Test-Path $archivePath)) {
        Write-LogEntry "Creating archive directory: $archivePath"
        New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    }
    
    # Find all files in inbound directory
    Write-LogEntry "Checking for files in inbound directory: $inboundPath"
    $inboundFiles = Get-ChildItem -Path $inboundPath | Where-Object { !$_.PSIsContainer }
    
    # Log file count
    $fileCount = $inboundFiles.Count
    Write-LogEntry "Found $fileCount file(s) in inbound directory"
    
    if ($fileCount -eq 0) {
        Write-LogEntry "No files to process, exiting"
        return
    }
    
    # Log all found files
    foreach ($file in $inboundFiles) {
        Write-LogEntry "Found file: $($file.Name), Last Modified: $($file.LastWriteTime)"
    }
    
    # Process each file
    foreach ($file in $inboundFiles) {
        $fileName = $file.Name
        Write-LogEntry "Processing file: $fileName"
        
        # Step 1: Copy to archive (unchanged)
        $archiveFilePath = Join-Path -Path $archivePath -ChildPath $fileName
        Write-LogEntry "Copying file to archive: $archiveFilePath"
        
        try {
            Copy-Item -Path $file.FullName -Destination $archiveFilePath -Force
            
            # Verify copy operation
            if (Test-Path $archiveFilePath) {
                $archiveFile = Get-Item -Path $archiveFilePath
                if ($archiveFile.Length -eq $file.Length) {
                    Write-LogEntry "File successfully copied to archive (verified size match)"
                } else {
                    throw "File copied to archive but size mismatch. Original: $($file.Length) bytes, Archive: $($archiveFile.Length) bytes"
                }
            } else {
                throw "Failed to copy file to archive"
            }
        }
        catch {
            Write-LogEntry "ERROR: Failed to copy file to archive: $_"
            throw
        }
        
        # Step 2: Move to destination with renaming
        try {
            # Extract report code from filename
            if ($fileName -match '^(R\d{5})\..*') {
                $reportCode = $matches[1]
                $reportName = Get-ReportName -ReportCode $reportCode
                
                # Create new filename with report name
                $newFileName = $fileName -replace "^$reportCode", "$reportName"
                Write-LogEntry "Renaming file from '$fileName' to '$newFileName'"
                
                $destinationFilePath = Join-Path -Path $destinationPath -ChildPath $newFileName
            } else {
                Write-LogEntry "WARNING: Filename does not match expected pattern for report code extraction: $fileName"
                $destinationFilePath = Join-Path -Path $destinationPath -ChildPath $fileName
            }
            
            Write-LogEntry "Moving file to destination with rename: $destinationFilePath"
            # Instead of Move-Item, use a combination of Copy-Item with the new name and Remove-Item for the original
            Copy-Item -Path $file.FullName -Destination $destinationFilePath -Force
            Remove-Item -Path $file.FullName -Force
            
            # Verify move operation
            if (Test-Path $destinationFilePath) {
                Write-LogEntry "File successfully moved to destination"
            } else {
                throw "Failed to move file to destination"
            }
            
            # Double check that original is gone
            if (Test-Path $file.FullName) {
                Write-LogEntry "WARNING: Original file still exists after move operation"
            }
        }
        catch {
            Write-LogEntry "ERROR: Failed to move file to destination: $_"
            throw
        }
        
        Write-LogEntry "Completed processing for file: $fileName"
    }
    
    Write-LogEntry "All files processed successfully"
}
catch {
    Write-LogEntry "ERROR: $_"
    throw
}
finally {
    Write-LogEntry "Script execution completed"
}