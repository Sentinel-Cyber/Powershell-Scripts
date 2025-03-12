# Inputs
$AccountKey = "099812957840e906c4965ed591a9eceb"
$DirectoryPath = "C:\Temp\Huntress"
$OrganizationKey = "{Org Here}"
if (-not (Test-Path -Path $directoryPath -PathType Container)) {
    New-Item -Path $directoryPath -ItemType Directory
    Write-Host "Directory '$directoryPath' created."
} else {
    Write-Host "Directory '$directoryPath' already exists."
}
cd C:\Temp\Huntress
Invoke-WebRequest -Uri https://github.com/Sentinel-Cyber/Huntress-Deployment/blob/main/Powershell/InstallHuntress.powershellv2.ps1 -Outfile .\HuntressDeploymentv2.ps1
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\HuntressDeploymentv2.ps1 -acctkey $AccountKey -orgkey $OrganizationKey
Start-Sleep -Seconds 15
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
