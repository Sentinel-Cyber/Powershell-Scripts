## Get Site Token
$SiteToken = 'eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1wYXg4LnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICIwZmM4MTViYmNlZTI2MTBkIn0='

## Determine Status of S1 Install
$InstalledSoftware = Get-Package
if ( $InstalledSoftware.Name -contains 'Sentinel Agent' )
    {
        $S1 = 'true'
    }else{
        $S1 = 'false'
    }

##Test for LTSVC\Packages path and create if not present.
$LTSVC = "C:\Windows\LTSvc\Packages"
if (Test-Path $LTSVC)
    {
        Write-Host "Folder Exists"
    }
    else
    {
        New-Item $LTSVC -ItemType Directory -Force
        Write-Host "Folder Created"
    }

## If S1 is installed, Exit. If S1 is not installed, download and install.
if ($S1 -eq 'true')
    {
        Write-Host LOG: S1 is Installed
        Exit
    }else{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri "https://rebrand.ly/6wnvi7g" -OutFile "C:\Windows\LTSvc\packages\SentinelInstaller_x64.exe"
        Sleep 15
## Whatever follows -t in this line, must be your site or group token key in S1
        c:\windows\ltsvc\packages\SentinelInstaller_x64.exe --dont_fail_on_config_preserving_failures -t $SiteToken -a="/NORESTART"
        Sleep 60
        Shutdown /r /t 0
    }