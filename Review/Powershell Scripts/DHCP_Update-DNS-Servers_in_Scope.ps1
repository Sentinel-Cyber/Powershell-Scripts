# Written by Ramon DeWitt 2024/10/29 with Claude.ai
# Last updated 2024/10/29
# Requires -RunAsAdministrator
# Script to update DNS servers for all DHCP scopes and validate the changes

# Import the DHCP Server module
Import-Module DHCPServer

try {
    # Get all DHCP scopes from the local server
    $scopes = Get-DhcpServerv4Scope
    
    # Define the new DNS servers
    $dnsServers = "10.1.1.13", "192.168.34.12"
    
    # Counter for successful updates
    $successCount = 0
    
    Write-Host "Starting DNS server update for all DHCP scopes..."
    
    foreach ($scope in $scopes) {
        try {
            # Get current scope options
            $scopeID = $scope.ScopeId
            Write-Host "Processing Scope: $($scope.Name) ($scopeID)"
            
            # Update DNS servers (Option ID 6)
            Set-DhcpServerv4OptionValue -ScopeId $scopeID -OptionId 6 -Value $dnsServers
            
            Write-Host "Successfully updated DNS servers for scope: $($scope.Name)" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "Failed to update scope $($scope.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Final summary
    Write-Host "`nUpdate complete!"
    Write-Host "Successfully updated $successCount out of $($scopes.Count) scopes"
    
    # Validation section
    Write-Host "`n=== Starting DNS Server Validation ===" -ForegroundColor Cyan
    Write-Host "Expected DNS Servers: $($dnsServers -join ', ')`n"
    
    $validationErrors = @()
    
    foreach ($scope in $scopes) {
        Write-Host "Validating Scope: $($scope.Name) ($($scope.ScopeId))" -NoNewline
        
        try {
            $currentDnsServers = (Get-DhcpServerv4OptionValue -ScopeId $scope.ScopeId -OptionId 6).Value
            
            # Compare arrays
            $match = @(Compare-Object $dnsServers $currentDnsServers -SyncWindow 0).Length -eq 0
            
            if ($match) {
                Write-Host " - PASS" -ForegroundColor Green
            } else {
                Write-Host " - FAIL" -ForegroundColor Red
                $validationErrors += [PSCustomObject]@{
                    ScopeName = $scope.Name
                    ScopeId = $scope.ScopeId
                    CurrentDNS = $currentDnsServers -join ', '
                    ExpectedDNS = $dnsServers -join ', '
                }
            }
        }
        catch {
            Write-Host " - ERROR" -ForegroundColor Red
            $validationErrors += [PSCustomObject]@{
                ScopeName = $scope.Name
                ScopeId = $scope.ScopeId
                CurrentDNS = "Error reading DNS servers"
                ExpectedDNS = $dnsServers -join ', '
            }
        }
    }
    
    # Display validation summary
    if ($validationErrors.Count -gt 0) {
        Write-Host "`nValidation Errors Found:" -ForegroundColor Red
        Write-Host "======================="
        foreach ($error in $validationErrors) {
            Write-Host "`nScope: $($error.ScopeName) ($($error.ScopeId))"
            Write-Host "Expected DNS Servers: $($error.ExpectedDNS)"
            Write-Host "Current DNS Servers:  $($error.CurrentDNS)"
        }
        
        # Export errors to CSV if any found
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $csvPath = ".\DHCP_DNS_Validation_Errors_$timestamp.csv"
        $validationErrors | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "`nValidation errors have been exported to: $csvPath"
    } else {
        Write-Host "`nValidation Complete - All scopes have correct DNS servers" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have administrative privileges and the DHCP Server module is installed."
}