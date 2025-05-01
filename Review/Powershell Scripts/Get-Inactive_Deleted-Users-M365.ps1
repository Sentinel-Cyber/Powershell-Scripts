# Store the current execution policy
$currentExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "Current execution policy: $currentExecutionPolicy"

# Set execution policy to bypass for current user
Write-Host "Temporarily setting execution policy to Bypass..."
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

# Configure PowerShell to trust PSGallery
if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Write-Host "Setting PSGallery as trusted repository..."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

try {
    # Check if Microsoft Graph PowerShell module is installed
    $module = Get-Module -Name Microsoft.Graph -ListAvailable
    if (-not $module) {
        Write-Host "Microsoft Graph PowerShell module not found. Installing..."
        Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
    }

    # Import required Microsoft Graph modules
    Import-Module Microsoft.Graph.Users -Force
    Import-Module Microsoft.Graph.Authentication -Force

    # Connect to Microsoft Graph (this will prompt for authentication)
    Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome

    # Create C:\Temp directory if it doesn't exist
    $tempPath = "C:\Temp"
    if (-not (Test-Path -Path $tempPath)) {
        New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
        Write-Host "Created directory: $tempPath"
    }

    # Get current timestamp for the output file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputFile = Join-Path $tempPath "deleted_inactive_accounts_$timestamp.csv"

    # Initialize arrays to store results
    $deletedUsers = @()
    $inactiveUsers = @()

    # Get deleted users
    Write-Host "Retrieving deleted users..."
    $deletedUsers = Get-MgDirectoryDeletedUser | ForEach-Object {
        [PSCustomObject]@{
            DisplayName = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            FirstName = $_.GivenName
            LastName = $_.Surname
            Status = "Deleted"
            DeletedDateTime = $_.DeletedDateTime
            LastSignIn = "N/A"
        }
    }

    # Get inactive users (users with blocked sign-in)
    Write-Host "Retrieving inactive users..."
    $inactiveUsers = Get-MgUser -Filter "accountEnabled eq false" -All | ForEach-Object {
        # Get sign-in activity
        $signInActivity = $_.SignInActivity
        $lastSignIn = if ($signInActivity) { $signInActivity.LastSignInDateTime } else { "Never" }

        [PSCustomObject]@{
            DisplayName = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            FirstName = $_.GivenName
            LastName = $_.Surname
            Status = "Inactive (Sign-in Blocked)"
            DeletedDateTime = "N/A"
            LastSignIn = $lastSignIn
        }
    }

    # Combine results
    $allResults = $deletedUsers + $inactiveUsers

    # Export results to CSV
    $allResults | Export-Csv -Path $outputFile -NoTypeInformation -Force
    Write-Host "Results exported to: $outputFile"

    # Display results if less than 50 entries
    if ($allResults.Count -lt 50) {
        Write-Host "`nDetailed Results:"
        $allResults | Format-Table -AutoSize
    } else {
        Write-Host "`nFound $($allResults.Count) accounts. Results have been exported to CSV file."
    }

    # Summary statistics
    Write-Host "`nSummary:"
    Write-Host "Total Deleted Users: $($deletedUsers.Count)"
    Write-Host "Total Inactive Users: $($inactiveUsers.Count)"
    Write-Host "Total Accounts Found: $($allResults.Count)"

} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
} finally {
    # Disconnect from Microsoft Graph
    try {
        Disconnect-MgGraph | Out-Null
        Write-Host "`nMicrosoft Graph session disconnected."
    } catch {
        Write-Host "Note: Could not disconnect from Microsoft Graph session." -ForegroundColor Yellow
    }

    # Restore original execution policy
    Write-Host "Restoring original execution policy..."
    Set-ExecutionPolicy -ExecutionPolicy $currentExecutionPolicy -Scope CurrentUser -Force

    # Reset PSGallery to untrusted if it was previously untrusted
    if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -eq "Trusted") {
        Write-Host "Resetting PSGallery trust settings..."
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
    }
}

Write-Host "`nScript completed."