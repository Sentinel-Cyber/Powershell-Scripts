# Checking currently installed driver version
#Write-Host "Attempting to detect currently installed driver version..."
<#if (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm -Name 'DCHUVen' -ErrorAction Ignore) {
    Write-Host -ForegroundColor Yellow "DCH driver are not supported. Windows Update will download and install the NVIDIA DCH Display Driver."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}
#>
try {
    $VideoController = Get-WmiObject -ClassName Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    $ins_version = ($VideoController.DriverVersion.Replace('.', '')[-5..-1] -join '').insert(3, '.')
}
catch {
    Write-Host -ForegroundColor Yellow "Unable to detect a compatible Nvidia device."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}
Write-Host "Installed version `t$ins_version"


# Checking latest driver version from Nvidia website
$link = Invoke-WebRequest -Uri 'https://www.nvidia.com/Download/processFind.aspx?psid=101&pfid=816&osid=57&lid=1&whql=1&lang=en-us&ctk=0&dtcid=1' -Method GET -UseBasicParsing
$link -match '<td class="gridItem">([^<]+?)</td>' | Out-Null
$version = $matches[1]
Write-Host "Latest version `t`t$version"


# Comparing installed driver version to latest driver version from Nvidia
if (!$clean -and ($version -eq $ins_version)) {
    Write-Host "Up to date: True"
    Write-Output "True"
    #Write-Host "Press any key to exit..."
    #$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    #exit
}


    else {
        Write-Host "Up to date: `$False"
        }