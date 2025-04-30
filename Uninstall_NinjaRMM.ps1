###############################################################
### Function to find NinjaRMM uninstall string
###############################################################
function Get-NinjaUninstallString {
    try {
        $script:MSIUninstallString = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
            Where-Object { $_.DisplayName -like "*Ninja*" } |
            Select-Object -ExpandProperty UninstallString

        if ($script:MSIUninstallString) {
            return $script:MSIUninstallString
        }
        Write-Host "No NinjaRMM uninstall string found in registry."
        $script:MSIUninstallString = $null
        return $null
    }
    catch {
        Write-Host "Error searching for NinjaRMM uninstall string: $_"
        $script:MSIUninstallString = $null
        return $null
    }
}
###############################################################
### Function to get NinjaRMM installation folder
###############################################################
function Get-NinjaInstallFolder {
    try {
        Write-Host "Checking registry path: HKLM:\SOFTWARE\WOW6432Node\NinjaRMM LLC\NinjaRMMAgent"
        $script:InstallLocation = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\NinjaRMM LLC\NinjaRMMAgent" -Name "Location").Location

        if ($script:InstallLocation) {
            Write-Host "Found installation path: $script:InstallLocation"
            return $script:InstallLocation
        }
        Write-Host "No NinjaRMM installation folder found in registry."
        $script:InstallLocation = $null
        return $null
    }
    catch {
        Write-Host "Could not find NinjaRMM installation folder in registry: $_"
        $script:InstallLocation = $null
        return $null
    }
}
###############################################################
### Main Uninstallation Script
###############################################################
try {
    Write-Host "Searching for NinjaRMM uninstall string..."
    $productCode = Get-NinjaUninstallString
    Write-Host "Installation path: $($script:InstallLocation)"
    Write-Host "Uninstall string: $($script:MSIUninstallString)"

    if ($productCode) {
        Write-Host "`nNinjaRMM has been found installed at: $($script:InstallLocation)"
        ###############################################################
        ### Uncomment the following lines to enable confirmation prompt
        ###############################################################
        # $confirmation = Read-Host "`nWould you like to proceed with uninstallation? (Y/N)"
        # if ($confirmation -ne 'Y') {
        #     Write-Host "Uninstallation cancelled by user."
        #     exit
        # }
        
        Write-Host "`nProceeding with uninstall..."
        
        # Create uninstall command
        $arguments = "/X$productCode /qn /norestart /l*v C:\Windows\Temp\ninjauninstall.log"
        
        # Execute uninstall
        Write-Host "Running uninstaller..."
        Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
        
        # Verify uninstallation
        $verifyUninstall = Get-NinjaUninstallString
        if ($verifyUninstall -eq $null) {
            Write-Host "NinjaRMM has been successfully uninstalled."
        } else {
            Write-Host "Warning: Uninstall may not have completed successfully."
        }
    } else {
        Write-Host "NinjaRMM installation not found in registry."
    }
} catch {
    Write-Host "An error occurred: $_"
}