<#
Name: get-log4jrcevulnerability.ps1
Version: 0.1.6.1 (13th December 2021)
Author: Prejay Shah (Doherty Associates)
Purpose: Detection of jar files vulnerable to log4j RCE vulnerability (CVE-2021-44228)
Utilizing JNDILookup detection method posted to https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b with some slight modifications to make it more RMM friendly

0.1 Initial Release
0.1.1 Adeed Dedupe to Vulnerable .JAR Listings
0.1.2 Public Release
0.1.3 Found that use of -force isn't working for all scans. Have added a non forced mode to see what outputs can be obtained
0.1.4 Experimenting with Unicode/Robocopy to bypass 260 character file path limit / access denied errors
0.1.5 added support for pseverything module
0.1.5.1 changed detection to be module based rather than command based
0.1.5.2 Cleaned up Output
0.1.6 Have revamped order to PSEverything, Robocopy, GCI
0.1.6.1 Fixed Typo, Modification for N-Central AMP Output of file names when robocopy is utilized
#>

$Version = "0.1.6.1" # 13th December 2021
Write-Host "get-log4jrcevulnerability $version" -foregroundcolor Green
$robocopycsv = $null

if (get-module -listavailable | where-object {$_.name -like 'PSEverything'}) {
    Write-Host "The almighty PSEverything module's Search-Everything command was found.`nDoing a new scan because we can..." -ForegroundColor Yellow
    $log4jfiles = $null
    $log4jfilescan = $null
    $Timetaken = (measure-command {$log4jfilescan = search-everything -global -extension jar}).totalseconds
    Write-host "See? That only took $timetaken seconds to scan the entire C: Drive for .jar files!" -foregroundcolor Green
    $log4jfilenames = $log4jfilescan 
}
else {
    try {
        Write-Host "Attempting to use Robocopy to scan for JAR files.." -ForegroundColor Yellow
        $robocopyexitcode = (start-process robocopy  -argumentlist "c:\ c:\DOESNOTEXIST *.jar /S /XJ /L /FP /NS /NC /NDL /NJH /NJS /r:0 /w:0 /LOG:$env:temp\log4jfilescan.csv" -wait).exitcode
        if ($? -eq $True) {
            $robocopycsv = $true
            $log4jfilescan = import-csv "$env:temp\log4jfilescan.csv" -header FilePath        
            $log4jfilenames = $log4jfilescan
        }
    }
    catch {
        Write-Host "WARNING: Robocopy Scan failed. Falling back to GCI.." -ForegroundColor Yellow
        $log4jfilescan = get-childitem 'C:\' -rec -force -include *.jar -ea 0
        if ($? -eq $true) {
            $log4jfilenames = ($log4jfilescan).fullname 
        }
        else {
            $log4jfiles = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Unable to scan files"
            $log4jvulnerable = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Unable to scan files"
            $log4jvulnerablefilecount = '-1'
            Write-Host $log4jfiles -ForegroundColor Red
            Exit 1
        }
    }
}
if ($log4jfilescan -eq $null) {
    $log4jfiles = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') OK - No JAR Files were found on this device"
    $log4jvulnerable = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') OK - No JAR Files were found on this device"
    $log4jvulnerablefilecount = '0'
    Write-Host "$log4jvulnerable" -ForegroundColor Green
}
else {
    Write-Host "Determining whether any of the $(($log4jfilenames).count) found .jar files are vulnerable to CVE-2021-44228 due to being capable of JNDI lookups..." -ForegroundColor Yellow
    if ($robocopycsv -eq $true) {
        $log4jvulnerablefiles = $log4jfilescan | foreach-object {select-string "JndiLookup.class" $_.FilePath} | select-object -exp Path | sort-object -unique
    }
    else {
        $log4jvulnerablefiles = $log4jfilescan | foreach-object {select-string "JndiLookup.class" $_} | select-object -exp Path | sort-object -unique
    }
    $log4jvulnerablefilecount = ($log4jvulnerablefiles).count
    if ($log4jvulnerablefiles -eq $null) {
        $log4jvulnerable = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') OK - 0 Vulnerable JAR files were found"
        write-host "Log4J CVE-2021-44228 Vulnerable Files:`n$log4jvulnerable" -ForegroundColor Green
    }
    else {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') WARNING - $log4jvulnerablefilecount Vulnerable JAR file(s) were found" -foregroundcolor Red
        write-host "Log4J CVE-2021-44228 Vulnerable Files:`n$log4jvulnerablefiles" -ForegroundColor Red
        $log4jvulnerable = $log4jvulnerablefiles -join '<br>'
    }
    # Write-Host "Log4j Files found:`n$log4jfiles"

}

if ($robocopycsv -eq $true) {
    $log4jfiles = get-content "$env:temp\log4jfilescan.csv" -readcount 0 | ForEach-Object{$_  -join '<br>'}
    start-sleep 5
    remove-item "$env:temp\log4jfilescan.csv" -force
}
else {
    $log4jfiles = $log4jfilenames -join '<br>'
}