<# 
.Synopsis 
    Checks the local system for Log4Shell Vulnerability [CVE-2021-44228]
.DESCRIPTION 
    Gets a list of all volumes on the server, loops through searching each disk for Log4j stuff
    Using base search from https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b#find-vulnerable-software-windows

    Version History
        1.0 - Initial release
        1.1 - Changed ErrorAction to "Continue" instead of stopping the script
        1.2 - Went back to SilentlyContinue, so much noise
        1.3 - Borrowed some improvements from @cedric2bx (https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b#gistcomment-3995092)
                Replace attribute -Include by -Filter (prevent unauthorized access exception stopping scan)
                Remove duplicate path with Get-Unique cmdlet
        1.4 - Added .war support thanks to @djblazkowicz (https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b#gistcomment-3998189)
.EXAMPLE 
    .\check_CVE-2021-44228.ps1
.NOTES 
    Created by Eric Schewe 2021-12-13
    Modified by Cedric BARBOTIN 2021-12-14
#> 

# Get Windows Version string
$windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption

# Server 2008 (R2)
if ($windowsVersion -like "*2008*") {

    $disks = [System.IO.DriveInfo]::getdrives() | Where-Object {$_.DriveType -eq "Fixed"}

}
# Everything else
else {

    $disks = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}

}

# I have no idea why I had to write it this way and why .Count didn't just work
$diskCount = $disks | Measure-Object | Select-Object Count -ExpandProperty Count

Write-Host -ForegroundColor Green "$(Get-Date -Format "yyyy-MM-dd H:mm:ss") - Starting the search of $($diskCount) disks"

foreach ($disk in $disks) {

    # One liner from https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b#find-vulnerable-software-windows
    # gci 'C:\' -rec -force -include *.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path

    # Server 2008 (R2)
    if ($windowsVersion -like "*2008*") {

        Write-Host -ForegroundColor Yellow "  $(Get-Date -Format "yyyy-MM-dd H:mm:ss") - Checking $($disk.Name): - $($disk.VolumeLabel)"
        Get-ChildItem "$($disk.Name)" -Recurse -Force -Include @("*.jar","*.war") -ErrorAction SilentlyContinue | ForEach-Object { Select-String "JndiLookup.class" $_ } | Select-Object -ExpandProperty Path | Get-Unique

    }
    # Everything else
    else {

        Write-Host -ForegroundColor Yellow "  $(Get-Date -Format "yyyy-MM-dd H:mm:ss") - Checking $($disk.DriveLetter): - $($disk.VolumeLabel)"
        Get-ChildItem "$($disk.DriveLetter):\" -Recurse -Force -Include @("*.jar","*.war") -ErrorAction SilentlyContinue | ForEach-Object { Select-String "JndiLookup.class" $_ } | Select-Object -ExpandProperty Path | Get-Unique

    }

}

Write-Host -ForegroundColor Green "$(Get-Date -Format "yyyy-MM-dd H:mm:ss") - Done checking all drives"