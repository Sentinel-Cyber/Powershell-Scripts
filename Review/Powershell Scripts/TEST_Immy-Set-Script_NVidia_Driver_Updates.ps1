﻿# This script is designed to install the bare essential Nvidia drivers
# This will not install Nvidia GeForce or Shadowplay
# There are options below for customizing the install
# The defaults should suffice for most users


# Installer options
param (
    [switch]$clean = $false, # Will delete old drivers and install the new ones
    [string]$folder = "$env:temp"   # Downloads and extracts the driver here
)


$scheduleTask = $false  # Creates a Scheduled Task to run to check for driver updates
$scheduleDay = "Sunday" # When should the scheduled task run (Default = Sunday)
$scheduleTime = "12pm"  # The time the scheduled task should run (Default = 12pm)


# Download and silently install 7-zip
$7zip = "https://www.7-zip.org/a/7z1900-x64.exe"
$output = "C:\Windows\Temp\7Zip.exe"
(New-Object System.Net.WebClient).DownloadFile($7zip, $output)
       
Start-Process "C:\Windows\Temp\7Zip.exe" -Wait -ArgumentList "/S"
# Delete the installer once it completes
Remove-Item "C:\Windows\Temp\7Zip.exe"

$7zpathexe = "C:\Program Files\7-Zip\7z.exe"
$archiverProgram = $7zpathexe
$7zipinstalled = $true 



# Checking currently installed driver version
Write-Host "Attempting to detect currently installed driver version..."
<#if (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm -Name 'DCHUVen' -ErrorAction Ignore) {
    Write-Host -ForegroundColor Yellow "DCH driver are not supported. Windows Update will download and install the NVIDIA DCH Display Driver."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

try {
#>
    $VideoController = Get-WmiObject -ClassName Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    $ins_version = ($VideoController.DriverVersion.Replace('.', '')[-5..-1] -join '').insert(3, '.')
<#}
catch {
    Write-Host -ForegroundColor Yellow "Unable to detect a compatible Nvidia device."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}
#>
Write-Host "Installed version `t$ins_version"


# Checking latest driver version from Nvidia website
$link = Invoke-WebRequest -Uri 'https://www.nvidia.com/Download/processFind.aspx?psid=101&pfid=816&osid=57&lid=1&whql=1&lang=en-us&ctk=0&dtcid=1' -Method GET -UseBasicParsing
$link -match '<td class="gridItem">([^<]+?)</td>' | Out-Null
$version = $matches[1]
Write-Host "Latest version `t`t$version"


# Comparing installed driver version to latest driver version from Nvidia
if (!$clean -and ($version -eq $ins_version)) {
    Write-Host "The installed version is the same as the latest version."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}


# Checking Windows version
if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {
    $windowsVersion = "win10-win11"
}
else {
    $windowsVersion = "win8-win7"
}


# Checking Windows bitness
if ([Environment]::Is64BitOperatingSystem) {
    $windowsArchitecture = "64bit"
}
else {
    $windowsArchitecture = "32bit"
}


# Create a new temp folder NVIDIA
$nvidiaTempFolder = "$folder\NVIDIA"
New-Item -Path $nvidiaTempFolder -ItemType Directory 2>&1 | Out-Null


# Generating the download link
#$url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-whql.exe"
$url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql.exe"
#$rp_url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-whql-rp.exe"
$rp_url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql-rp.exe"

# Downloading the installer
$dlFile = "$nvidiaTempFolder\$version.exe"
Write-Host "Downloading the latest version to $dlFile"
Start-BitsTransfer -Source $url -Destination $dlFile

if ($?) {
    Write-Host "Proceed..."
}
else {
    Write-Host "Download failed, trying alternative RP package now..."
    Start-BitsTransfer -Source $rp_url -Destination $dlFile
}

# Extracting setup files
$extractFolder = "$nvidiaTempFolder\$version"
$filesToExtract = "Display.Driver HDAudio NVI2 PhysX EULA.txt ListDevices.txt setup.cfg setup.exe"
Write-Host "Download finished, extracting the files now..."

if ($7zipinstalled) {
    Start-Process -FilePath $archiverProgram -NoNewWindow -ArgumentList "x -bso0 -bsp1 -bse1 -aoa $dlFile $filesToExtract -o""$extractFolder""" -wait
}
elseif ($archiverProgram -eq $winrarpath) {
    Start-Process -FilePath $archiverProgram -NoNewWindow -ArgumentList 'x $dlFile $extractFolder -IBCK $filesToExtract' -wait
}
else {
    Write-Host "Something went wrong. No archive program detected. This should not happen."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}


# Remove unneeded dependencies from setup.cfg
(Get-Content "$extractFolder\setup.cfg") | Where-Object { $_ -notmatch 'name="\${{(EulaHtmlFile|FunctionalConsentFile|PrivacyPolicyFile)}}' } | Set-Content "$extractFolder\setup.cfg" -Encoding UTF8 -Force


# Installing drivers
Write-Host "Installing Nvidia drivers now..."
$install_args = "-passive -noreboot -noeula -nofinish -s"
if ($clean) {
    $install_args = $install_args + " -clean"
}
Start-Process -FilePath "$extractFolder\setup.exe" -ArgumentList $install_args -wait


# Creating a scheduled task if the $scheduleTask varible is set to TRUE
if ($scheduleTask) {
    Write-Host "Creating A Scheduled Task..."
    New-Item C:\Task\ -type directory 2>&1 | Out-Null
    Copy-Item .\Nvidia.ps1 -Destination C:\Task\ 2>&1 | Out-Null
    $taskname = "Nvidia-Updater"
    $description = "Update Your Driver!"
    $action = New-ScheduledTaskAction -Execute "C:\Task\Nvidia.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval $scheduleTask -DaysOfWeek $scheduleDay -At $scheduleTime
    Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Description $description 2>&1 | Out-Null
}


# Cleaning up downloaded files
Write-Host "Deleting downloaded files"
Remove-Item $nvidiaTempFolder -Recurse -Force


# Driver installed, requesting a reboot
#Write-Host -ForegroundColor Green "Driver installed. You may need to reboot to finish installation."
#Write-Output "True"
<#Write-Host "Would you like to reboot now?"
$Readhost = Read-Host "(Y/N) Default is no"
Switch ($ReadHost) {
    Y { Write-host "Rebooting now..."; Start-Sleep -s 2; Restart-Computer }
    N { Write-Host "Exiting script in 5 seconds."; Start-Sleep -s 5 }
    Default { Write-Host "Exiting script in 5 seconds"; Start-Sleep -s 5 }
}
#>

# End of script
exit