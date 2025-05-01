# PowerShell cmdlet to start a named service
Clear-Host
$srvName = "Adobe Acrobat Update Service"
$servicePrior = Get-Service $srvName
"$srvName is now " + $servicePrior.status
Start-Service $srvName
$serviceAfter = Get-Service $srvName
"$srvName is now " + $serviceAfter.status