#!ps
#timeout=90000

# SentinelOne Agent Download and Install Script
# Set your API credentials and configuration
$apiToken = "eyJraWQiOiJ1cy1lYXN0LTEtcHJvZC0wIiwiYWxnIjoiRVMyNTYifQ.eyJzdWIiOiJyYW1vbkBzZW50aW5lbGN5YmVyLnVzIiwiaXNzIjoiYXV0aG4tdXMtZWFzdC0xLXByb2QiLCJkZXBsb3ltZW50X2lkIjoiNzE4MTgiLCJ0eXBlIjoidXNlciIsImV4cCI6MTc0OTc4MjQ3OSwiaWF0IjoxNzQ3MTkwNDc5LCJqdGkiOiJiNzE3OGFkMy0yOTIyLTQ0YzQtODgwNi1lMmFiNjk0ODcyZmUifQ.Rcx_saRAwCtY7fhOOZYZgaEJ2lVOT0yuejEo0qulycNw1avMzRxrRq1t_tley_eSCAc3htyuLrbwKjiLKNhAxg"
$consoleUrl = "https://usea1-pax8-03.sentinelone.net" # e.g., "https://usea1-partners.sentinelone.net"
$siteId = "2214273525767449859"
$siteToken = "eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1wYXg4LTAzLnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICJiZTVmMmE2NThiM2MyY2ZjZGJjMzY4MTE0YjlhMTMxYmQ1YTcyNDM1OWM0MmRlYzhiODAzODhlMDdhMGZkOGRlIn0=" # Required for installation

# Headers for API requests
$headers = @{
    "Authorization" = "ApiToken $apiToken"
    "Content-Type" = "application/json"
}

# Create temp directory for download
$tempDir = "C:\Temp\SentinelOne"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Function to write logs
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $message"
    Add-Content -Path "$tempDir\S1_Install_Log.txt" -Value "[$timestamp] $message"
}

Write-Log "Starting SentinelOne agent installation process"

try {
    # Get the latest Windows agent packages
    Write-Log "Fetching Windows agent packages"
    $apiEndpoint = "/web/api/v2.1/update/agent/packages"
    
    # Build query parameters based on the API documentation
    $queryParams = @(
        "siteIds=$siteId",
        "osTypes=windows",
        "limit=10",
        "sortBy=version",
        "sortOrder=desc"
    )
    
    $queryString = $queryParams -join "&"
    $fullUrl = "$consoleUrl$apiEndpoint`?$queryString"
    
    Write-Log "API URL: $fullUrl"
    $response = Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Get
    
    Write-Log "Found $($response.pagination.totalItems) packages"
    
    if ($response.data.Count -eq 0) {
        Write-Log "No matching agent packages found"
        return
    }
    
    # Find the latest GA package for Windows
    $package = $null
    foreach ($pkg in $response.data) {
        Write-Log "Found package: $($pkg.version), Status: $($pkg.status), OS: $($pkg.osType), Arch: $($pkg.osArch)"
        # Select the first package
        if (-not $package) {
            $package = $pkg
            Write-Log "Selected package: $($package.version) (ID: $($package.id))"
        }
    }
    
    if (-not $package) {
        Write-Log "No suitable package found"
        return
    }
    
    # Download the agent package using the correct endpoint format
    $packageId = $package.id
    $downloadEndpoint = "/web/api/v2.1/update/agent/download/$packageId"
    $downloadUrl = "$consoleUrl$downloadEndpoint"
    $installerPath = "$tempDir\SentinelOneInstaller.exe"
    
    Write-Log "Downloading agent from: $downloadUrl"
    
    # Download the file
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("Authorization", "ApiToken $apiToken")
    $webClient.DownloadFile($downloadUrl, $installerPath)
    
    # Verify download was successful
    if (-not (Test-Path $installerPath)) {
        Write-Log "Failed to download installer package"
        return
    }
    
    $fileInfo = Get-Item $installerPath
    Write-Log "Agent package downloaded successfully to: $installerPath (Size: $($fileInfo.Length) bytes)"
    
    # Parse version to determine installation method
    $versionString = $package.version
    Write-Log "Package version: $versionString"
    
    if ($versionString -match "^(\d+)\.") {
        $majorVersion = [int]$matches[1]
        Write-Log "Major version: $majorVersion"
    } else {
        $majorVersion = 0
        Write-Log "Could not determine major version, defaulting to legacy installation method"
    }
    
    # Install the agent with appropriate arguments based on version
    if ($majorVersion -ge 22) {
        # For version 22+ use new CLI syntax
        $installArgs = "-t $siteToken -q"
        Write-Log "Using version 22+ installation syntax: $installArgs"
    } else {
        # For older versions use the old syntax
        $installArgs = "/SITE_TOKEN=$siteToken /quiet"
        Write-Log "Using legacy installation syntax: $installArgs"
    }
    
    # Execute the installer
    Write-Log "Installing SentinelOne agent..."
    $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
    
    $exitCode = $process.ExitCode
    Write-Log "Installation process completed with exit code: $exitCode"
    
    if ($exitCode -eq 0) {
        Write-Log "SentinelOne agent installed successfully"
    } else {
        Write-Log "Installation may have encountered issues. Exit code: $exitCode"
    }
    
    # Clean up
    ####Remove-Item $installerPath -Force
    ####Write-Log "Temporary installer file removed"
    
} catch {
    Write-Log "ERROR: $_"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)"
}

Write-Log "SentinelOne agent installation process completed"v