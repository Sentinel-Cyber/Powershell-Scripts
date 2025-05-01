$warnfile = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\PST" -Name WarnLargeFileSize
$maxfile = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\PST" -Name MaxLargeFileSize
if (Compare-Object $warnfile, $maxfile   72500, 75000 -SyncWindow 0) {
    $false
    } else {
    $true
}