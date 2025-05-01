# PowerShell cmdlet to stop a named service
$srvName = "Adobe Acrobat Update Service"
$servicePrior = Get-Service $srvName
"$srvName is now " + $servicePrior.Status
Stop-Service $srvName
$serviceAfter = Get-Service $srvName
"$srvName is now " + $serviceAfter.Status