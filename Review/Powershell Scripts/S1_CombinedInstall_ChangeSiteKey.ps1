#!ps
## Set Site Token
## Enter your Site Token or Group token between the quotes for the site token variable.
$SiteToken = 'eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0zMDAtbmZyLnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICI2MWRjMWMyNmE0ZTAzYTk5In0='

## Create C:\Temp directory if it doesn't exist
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp"
}

## Determine Status of S1 Install
$InstalledSoftware = Get-Package
if ($InstalledSoftware.Name -contains 'Sentinel Agent') {
    $S1 = 'true'
} else {
    $S1 = 'false'
}

## If S1 is installed, Exit. If S1 is not installed, download and install.
if ($S1 -eq 'true') {
    Write-Host "LOG: S1 is Installed, Exiting Script."
    Exit
} else {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri "https://sdcalicoiti-my.sharepoint.com/:u:/g/personal/ramon_calicoit_com/ER7B6vcoV4tAqIAjNewnrVoBv5LL3eOadO0zMZ3IUr1TdQ?e=wL6sv5&download=1" -OutFile "C:\Temp\SentinelInstaller_x64.exe"
    Start-Sleep -Seconds 15
    ## Whatever follows -t in this line, must be your site or group token key in S1
    C:\Temp\SentinelInstaller_x64.exe --dont_fail_on_config_preserving_failures -t $SiteToken -a="/NORESTART /QN"
}