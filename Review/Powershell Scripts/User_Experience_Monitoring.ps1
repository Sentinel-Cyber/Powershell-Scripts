$FailingThreshold = 6.5

# Check to make sure there is a vald WinSat assessment available.
# "1" indicates a valid assesment is available, any other value shows issues with WinSAT on the system.
$WinSatStatus= (Get-CimInstance Win32_WinSAT).WinSATAssessmentState
if ($WinSatStatus -ne "1") {
Write-Output "WinSAT has not run or contains invalid data. No score is available for this device."
exit 1
}

$WinSatResults = Get-CimInstance Win32_WinSAT | Select-Object CPUScore, DiskScore, GraphicsScore, MemoryScore, WinSPRLevel

$WinSatHealth = foreach ($Result in $WinSatResults) {
    if ($Result.CPUScore -lt $FailingThreshold) { "CPU Score is $($result.CPUScore). This is less than $FailingThreshold" }
    if ($Result.DiskScore -lt $FailingThreshold) { "Disk Score is $($result.Diskscore). This is less than $FailingThreshold" }
    if ($Result.GraphicsScore -lt $FailingThreshold) { "Graphics Score is $($result.GraphicsScore). This is less than $FailingThreshold" }
    if ($Result.MemoryScore -lt $FailingThreshold) { "RAM Score is $($result.MemoryScore). This is less than $FailingThreshold" }
    if ($Result.WinSPRLevel -lt $FailingThreshold) { "Average WinSPR Score is $($result.winsprlevel). This is less than $FailingThreshold" }
}
if (!$WinSatHealth) {
$AllResults = ($Winsatresults | out-string)
$WinSatHealth = "Healthy. $AllResults"
}
$AllResults