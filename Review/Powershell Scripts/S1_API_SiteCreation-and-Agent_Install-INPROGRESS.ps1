##################################
# SentinelOne Site Management and Installation Script
# Configuration Variables
##################################
$ApiToken = "eyJraWQiOiJ1cy1lYXN0LTEtcHJvZC0wIiwiYWxnIjoiRVMyNTYifQ.eyJzdWIiOiJyYW1vbkBzZW50aW5lbGN5YmVyLnVzIiwiaXNzIjoiYXV0aG4tdXMtZWFzdC0xLXByb2QiLCJkZXBsb3ltZW50X2lkIjoiNzE4MTgiLCJ0eXBlIjoidXNlciIsImV4cCI6MTczNDgxMTU3MCwiaWF0IjoxNzMyMjE5NTcwLCJqdGkiOiI1NDIyNTM2OS0zYjU2LTQwODAtYmIyMC1hNzI5MGJlYTY3YTEifQ.NtEC2-Ah1741U3VIliFofEFyfWBpXjl2WdPOAoyfUl2r4MeUlGsundHAvdUUN-dGoO0SO8zb5n0JTc4dpNbuMA"
$AccountID = "2088674662638456853"
$BaseUrl = "https://usea1-pax8-03.sentinelone.net/"
$Client = "Sentinel Dev4"  # This will be passed as a parameter in production

# ##################################
# # Check if S1 is already installed
# ##################################

# $InstalledSoftware = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like "*Sentinel*" }
# if ($InstalledSoftware) {
#     Write-Host "LOG: S1 is already installed, exiting script."
#     exit 0
# }

##################################
# Setup Headers for API calls
##################################

$headers = @{
    "Authorization" = "ApiToken $ApiToken"
    "Content-Type" = "application/json"
}

# ##################################
# # Check for existing site
# ##################################

# Write-Host "Checking for existing site for $Client..."
# try {
#     $siteResponse = Invoke-RestMethod -Uri "$BaseUrl/web/api/v2.1/sites" -Method 'GET' -Headers $headers
#     $existingSite = $siteResponse.data.sites | Where-Object { $_.name -eq $Client }
# } catch {
#     Write-Host "Error checking existing sites: $_"
#     exit 1
# }

# ##################################
# # Variable to Store the Site Token
# ##################################
# $siteToken = $null

# ##################################
# # Check for Existing Sites
# ##################################

# if ($null -ne $existingSite) {
#     Write-Host "Found existing site with state: $($existingSite.state)"
    
#     if ($existingSite.state -eq "deleted" -or $existingSite.state -eq "expired") {
#         Write-Host "Site exists but is in $($existingSite.state) state. Attempting to reactivate..."
        
#         # Prepare reactivation body
#         $reactivateBody = @{
#             data = @{
#                 expiration = "2029-12-31T04:49:26.257525Z"
#                 unlimited = $true
#             }
#         } | ConvertTo-Json

#         try {
#             # Call reactivate endpoint with PUT method
#             $reactivateResponse = Invoke-RestMethod `
#                 -Uri "$BaseUrl/web/api/v2.1/sites/$($existingSite.id)/reactivate" `
#                 -Method 'PUT' `
#                 -Headers $headers `
#                 -Body $reactivateBody

#             if ($reactivateResponse.data.success) {
#                 Write-Host "Site successfully reactivated."
                
#                 # Get updated site information
#                 $updatedSiteResponse = Invoke-RestMethod `
#                     -Uri "$BaseUrl/web/api/v2.1/sites" `
#                     -Method 'GET' `
#                     -Headers $headers
#                 $existingSite = $updatedSiteResponse.data.sites | Where-Object { $_.id -eq $existingSite.id }
#                 $siteToken = $existingSite.registrationToken
#             } else {
#                 Write-Host "Failed to reactivate site."
#                 exit 1
#             }
#         } catch {
#             Write-Host "Error reactivating site: $_"
#             exit 1
#         }
#     } else {
#         Write-Host "Using existing active site..."
#         $siteToken = $existingSite.registrationToken
#     }
# } else {
#     Write-Host "No existing site found. Creating new site..."
    
#     # Prepare modules array for site creation
#     $moduleArray = $Modules | ForEach-Object {
#         @{
#             name = $_
#         }
#     }
    
#     # Prepare the JSON body for site creation
#     $siteBody = @{
#         data = @{
#             siteType = "Paid"
#             name = $Client
#             expiration = $null
#             unlimitedExpiration = $true
#             unlimitedLicenses = $true
#             inherits = $true
#             accountId = $AccountID
#             licenses = @{
#                 bundles = @(
#                     @{
#                         name = "control"
#                         majorVersion = 1
#                         minorVersion = 8
#                         surfaces = @(
#                             @{
#                                 name = "Total Agents"
#                                 count = -1
#                             }
#                         )
#                     }
#                 )
#                 modules = @(
#                     @{
#                         name = "vigilance"
#                         majorVersion = 1
#                     }
#                 )
#             }
#         }
#     }
#     $siteBody = $siteBody | ConvertTo-Json -Depth 10

#     try {
#         $newSite = Invoke-RestMethod -Uri "$BaseUrl/web/api/v2.1/sites" -Method 'POST' -Headers $headers -Body $siteBody
#         $siteToken = $newSite.data.registrationToken
#         Write-Host "New site created successfully."
#     } catch {
#         Write-Host "Error creating new site: $_"
#         exit 1
#     }
# }

##################################
# Get Latest Windows x64 Package Information
##################################

Write-Host "Getting latest package information..."
try {
    $packagesResponse = Invoke-RestMethod -Uri "$BaseUrl/web/api/v2.1/update/agent/packages?limit=1&osArches=64 bit&osTypes=windows&sortBy=version&sortOrder=desc&status=ga" -Method 'GET' -Headers $headers

    if ($null -eq $latestPackage) {
        Write-Host "No suitable package found."
        exit 1
    }
} catch {
    Write-Host "Error getting package information: $_"
    exit 1
}

# ##################################
# # Create Temp Directory if it Doesn't Exist
# ##################################

# if (-not (Test-Path -Path "C:\Temp")) {
#     New-Item -ItemType Directory -Path "C:\Temp"
# }

# ##################################
# # Download and Install the Package
# ##################################

# Write-Host "Downloading and installing S1 agent..."
# try {
#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
#     # Download URL using the package ID
#     $downloadUrl = "$BaseUrl/web/api/v2.1/update/agent/download/$($latestPackage.id)"
    
#     # Download the installer
#     Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile "C:\Temp\SentinelInstaller_x64.exe"
    
#     # Install S1
#     Write-Host "Starting installation..."
#     Start-Process -FilePath "C:\Temp\SentinelInstaller_x64.exe" `
#                  -ArgumentList "--dont_fail_on_config_preserving_failures -t $siteToken -a='/NORESTART /QN'" `
#                  -Wait
    
#     Write-Host "Installation completed successfully."
# } catch {
#     Write-Host "Error during download/installation: $_"
#     exit 1
# }