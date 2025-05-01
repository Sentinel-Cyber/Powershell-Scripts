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

#INFO#
#
# This script requires Powershell 7 as well as the PnP.Powershell Module
# It is suggested to call the script and feed parameters from that call - See the example below
#
#.\Export-SharePointFolders.ps1 `
#     -SiteURL "[SharePointURL]" `
#     -LibraryName "Shared Documents/Branding" `
#     -OutputPath "C:\Temp\FolderExport.csv" `
#     -ClientId "[M365 Entra App ID created with PnP]" `
#     -TenantId "[M365 Tenant ID]" `
#     -CertificateThumbprint "[Your .pfx file cert thumbprint (should be created with PnP)]" `
#     -PfxPath "C:\Users\Ramon\PnP Powershell.pfx" `
#     -Verbose

# Parameters
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteURL,
    
    [Parameter(Mandatory=$true)]
    [string]$LibraryName,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [Parameter(Mandatory=$true)]
    [string]$ClientId,

    [Parameter(Mandatory=$true)]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory=$false)]
    [string]$PfxPath = "C:\Users\$env:USERNAME\PnP Powershell.pfx",

    [Parameter(Mandatory=$false)]
    [string]$PfxPassword
)

# Add verbose switch for debugging
$VerbosePreference = "Continue"

# Add required assembly for URL encoding
Add-Type -AssemblyName System.Web

function Install-RequiredModule {
    [CmdletBinding()]
    param (
        [string]$ModuleName,
        [string]$MinimumVersion = "0.0"
    )
    
    Write-Host "Checking for $ModuleName module..." -ForegroundColor Yellow
    
    $module = Get-Module -Name $ModuleName -ListAvailable | 
        Sort-Object Version -Descending | 
        Select-Object -First 1
    
    $needsInstall = $false
    
    if ($module) {
        Write-Host "Found $ModuleName version $($module.Version)" -ForegroundColor Yellow
        if ($module.Version -lt [version]$MinimumVersion) {
            Write-Host "Installed version is below minimum required version $MinimumVersion" -ForegroundColor Yellow
            $needsInstall = $true
        }
    } else {
        Write-Host "$ModuleName is not installed" -ForegroundColor Yellow
        $needsInstall = $true
    }
    
    if ($needsInstall) {
        try {
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            $installScope = if ($isAdmin) { "AllUsers" } else { "CurrentUser" }
            
            Write-Host "Installing $ModuleName module (Scope: $installScope)..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Force -AllowClobber -Scope $installScope
            Write-Host "$ModuleName module installed successfully" -ForegroundColor Green
        }
        catch {
            throw "Failed to install $ModuleName module: $($_.Exception.Message)"
        }
    }
    
    Write-Host "Importing $ModuleName module..." -ForegroundColor Yellow
    Import-Module -Name $ModuleName -Force -DisableNameChecking
}

function Get-Certificate {
    [CmdletBinding()]
    param(
        [string]$PfxPath,
        [string]$Password,
        [string]$CertificateThumbprint
    )

    try {
        $cert = Get-ChildItem -Path "Cert:\CurrentUser\My\$CertificateThumbprint" -ErrorAction SilentlyContinue
        
        if (-not $cert) {
            Write-Host "Certificate not found in store, importing from PFX..." -ForegroundColor Yellow
            
            if (-not (Test-Path $PfxPath)) {
                throw "PFX file not found at path: $PfxPath"
            }

            $securePassword = if ([string]::IsNullOrEmpty($Password)) {
                ConvertTo-SecureString -String " " -AsPlainText -Force
            } else {
                ConvertTo-SecureString -String $Password -AsPlainText -Force
            }

            $cert = Import-PfxCertificate -FilePath $PfxPath -CertStoreLocation Cert:\CurrentUser\My -Password $securePassword -Exportable
            $cert = Get-ChildItem -Path "Cert:\CurrentUser\My\$CertificateThumbprint" -ErrorAction Stop
        }
        
        Write-Host "Certificate loaded successfully." -ForegroundColor Green
        
        $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx)
        $certBase64 = [System.Convert]::ToBase64String($certBytes)
        
        return $certBase64
    }
    catch {
        throw "Failed to load certificate: $($_.Exception.Message)"
    }
}

function Get-SharePointViewParameters {
    [CmdletBinding()]
    param(
        [string]$SiteURL,
        [string]$LibraryName
    )
    
    try {
        # Get the list/library
        $list = Get-PnPList -Identity $LibraryName -ErrorAction Stop
        Write-Verbose "Retrieved list: $($list.Title)"
        
        # Get all views
        $views = Get-PnPView -List $list
        Write-Verbose "Found $($views.Count) views"
        
        # Try to find the view in this order:
        # 1. Default view
        # 2. "All Items" view
        # 3. First view in the list
        $selectedView = $null
        
        # Try to get the default view
        $selectedView = $views | Where-Object { $_.DefaultView -eq $true } | Select-Object -First 1
        if ($selectedView) {
            Write-Verbose "Found default view: $($selectedView.Title)"
        }
        
        # If no default view, try "All Items"
        if (-not $selectedView) {
            $selectedView = $views | Where-Object { $_.Title -eq "All Items" } | Select-Object -First 1
            if ($selectedView) {
                Write-Verbose "Found 'All Items' view: $($selectedView.Title)"
            }
        }
        
        # If still no view, take the first one
        if (-not $selectedView -and $views.Count -gt 0) {
            $selectedView = $views | Select-Object -First 1
            Write-Verbose "Using first available view: $($selectedView.Title)"
        }
        
        if ($selectedView) {
            # Extract the GUID from the Id property
            $viewId = $selectedView.Id.ToString()
            Write-Verbose "View ID: $viewId"
            
            return @{
                viewid = $viewId
            }
        } else {
            Write-Warning "No views found for library '$LibraryName'"
            return $null
        }
    }
    catch {
        Write-Warning "Unable to retrieve view parameters: $($_.Exception.Message)"
        Write-Verbose "Error details: $($_.Exception)"
        return $null
    }
}

function Get-FormattedSharePointUrl {
    [CmdletBinding()]
    param(
        [string]$SiteURL,
        [string]$FolderServerRelativeUrl,
        [hashtable]$ViewParameters
    )
    
    try {
        # Ensure we have the correct base site URL
        $baseUrl = $SiteURL.TrimEnd('/')
        
        # Construct the full URL path
        $fullUrl = "$baseUrl/Shared Documents/Forms/AllItems.aspx"
        
        # Clean up and encode the folder path
        # Remove the site URL portion if it exists in the server relative URL
        $folderPath = $FolderServerRelativeUrl
        if ($folderPath.StartsWith($baseUrl)) {
            $folderPath = $folderPath.Substring($baseUrl.Length)
        }
        
        # Ensure the path starts with /sites/
        if (-not $folderPath.StartsWith("/sites/")) {
            $siteName = $baseUrl.Split('/')[-1]
            $folderPath = "/sites/$siteName$folderPath"
        }
        
        # Encode the folder path
        $encodedPath = [System.Web.HttpUtility]::UrlEncode($folderPath)
        
        # Build the final URL
        $finalUrl = "${fullUrl}?id=$encodedPath"
        
        # Add the view ID if available
        if ($ViewParameters -and $ViewParameters.ContainsKey('viewid')) {
            $finalUrl += "&viewid=$($ViewParameters['viewid'])"
        }
        
        Write-Verbose "Generated URL: $finalUrl"
        return $finalUrl
    }
    catch {
        Write-Warning "Error formatting SharePoint URL: $($_.Exception.Message)"
        Write-Verbose "Error details: $($_.Exception)"
        return $null
    }
}

function Get-SharePointFolders {
    [CmdletBinding()]
    param(
        [string]$LibraryName,
        [string]$SiteURL
    )
    
    try {
        Write-Host "DEBUG: Incoming LibraryName: $LibraryName" -ForegroundColor Yellow
        
        # Split the LibraryName to get base library and subfolder
        $libraryParts = $LibraryName -split '/'
        $baseLibrary = $libraryParts[0]
        $subfolderName = $libraryParts[1]
        
        Write-Host "DEBUG: Base Library: $baseLibrary" -ForegroundColor Yellow
        Write-Host "DEBUG: Subfolder Name: $subfolderName" -ForegroundColor Yellow
        
        # Get the document library
        $list = Get-PnPList -Identity $baseLibrary -ErrorAction Stop
        
        # Construct the folder path using the passed parameters
        $folderPath = "$($list.RootFolder.ServerRelativeUrl)/$subfolderName"
        Write-Host "DEBUG: Full folder path: $folderPath" -ForegroundColor Yellow
        
        # Get the folder directly
        $folder = Get-PnPFolder -Url $folderPath -Includes Files,Folders
        Write-Host "DEBUG: Got folder: $($folder.Name)" -ForegroundColor Yellow
        Write-Host "DEBUG: Folder exists: $($folder.Exists)" -ForegroundColor Yellow
        Write-Host "DEBUG: Folder item count: $($folder.ItemCount)" -ForegroundColor Yellow
        Write-Host "DEBUG: Subfolders count: $($folder.Folders.Count)" -ForegroundColor Yellow
        
        # Get subfolders using the Folders property
        $subFolders = $folder.Folders
        
        Write-Host "DEBUG: Found $($subFolders.Count) subfolders" -ForegroundColor Yellow
        foreach($sf in $subFolders) {
            Write-Host "DEBUG: Subfolder: $($sf.Name)" -ForegroundColor Yellow
        }
        
        # Get view parameters for URL formatting
        $viewParams = Get-SharePointViewParameters -SiteURL $SiteURL -LibraryName $baseLibrary
        
        # Process the subfolders
        $results = foreach ($subfolder in $subFolders) {
            Write-Host "DEBUG: Processing folder: $($subfolder.Name)" -ForegroundColor Cyan
            
            $formattedUrl = Get-FormattedSharePointUrl -SiteURL $SiteURL -FolderServerRelativeUrl $subfolder.ServerRelativeUrl -ViewParameters $viewParams
            
            [PSCustomObject]@{
                FolderName = $subfolder.Name
                FolderPath = $subfolder.ServerRelativeUrl
                FolderURL = $formattedUrl
                FolderLink = if ($formattedUrl) { '=HYPERLINK("' + $formattedUrl + '", "' + $subfolder.Name + '")' } else { $subfolder.Name }
                Created = $subfolder.TimeCreated
                Modified = $subfolder.TimeLastModified
            }
        }
        
        return $results
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "ERROR Details: $($_.Exception.StackTrace)" -ForegroundColor Red
        throw "Failed to retrieve folders: $($_.Exception.Message)"
    }
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Check PowerShellGet version and update if necessary
    $psgModule = Get-Module PowerShellGet -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($psgModule.Version -lt [version]"2.0") {
        Write-Host "Updating PowerShellGet..." -ForegroundColor Yellow
        Install-Module PowerShellGet -Force -AllowClobber -Scope CurrentUser
    }
    
    # Ensure NuGet package provider is installed
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "Installing NuGet package provider..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    }
    
    # Install and import PnP.PowerShell module
    Install-RequiredModule -ModuleName "PnP.PowerShell" -MinimumVersion "1.12.0"
    
    # Get certificate Base64 string
    $certBase64 = Get-Certificate -PfxPath $PfxPath -Password $PfxPassword -CertificateThumbprint $CertificateThumbprint
    
    # Connect to SharePoint Online using certificate
    Write-Host "Connecting to SharePoint Online using certificate authentication..." -ForegroundColor Yellow
    Connect-PnPOnline -Url $SiteURL `
                      -ClientId $ClientId `
                      -Tenant $TenantId `
                      -CertificateBase64Encoded $certBase64
    
    # Get all folders from the library with proper URLs
    Write-Host "Retrieving folders from $LibraryName..." -ForegroundColor Yellow
    $results = Get-SharePointFolders -LibraryName $LibraryName -SiteURL $SiteURL
    
    # Create output directory if it doesn't exist
    $outputDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path -Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # Export to CSV
    Write-Host "Exporting results to $OutputPath..." -ForegroundColor Yellow
    $results | Export-Csv -Path $OutputPath -NoTypeInformation
    
    Write-Host "Export completed successfully!" -ForegroundColor Green
    Write-Host "Total folders exported: $($results.Count)" -ForegroundColor Green
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
}
finally {
    # Disconnect from SharePoint
    if (Get-PnPConnection -ErrorAction SilentlyContinue) {
        Disconnect-PnPOnline
    }
}