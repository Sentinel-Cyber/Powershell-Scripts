#--- Last updated by Ramon DeWitt 2/2/2023
#--- Agent Installer URL must be generated in the portal via Settings > Account Configuration or self hosted.
$AGENT_INSTALLER_URL = "https://rebrand.ly/4r3f6ma"
#--- Modify Below This Line At Your Own Risk ------------------------------
$AGENT_INSTALLER_Name_Split = $AGENT_INSTALLER_URL -Split ("com/")
$AGENT_INSTALLER_Name_Split2 = $AGENT_INSTALLER_Name_Split[1] -Split("/")
$AGENT_INSTALLER_Name_Split3 = $AGENT_INSTALLER_Name_Split2[1] -Split("/")
$AGENT_INSTALLER_Name = $AGENT_INSTALLER_Name_Split3 -split(".msi")
$TimeStamp = $(Get-Date -UFormat %s)
$Folder = New-Item -Path "C:\windows\Temp\" -Name "$TimeStamp" -ItemType "directory"
$AGENT_INSTALLER_PATH = "C:\windows\Temp\$($TimeStamp)\$($AGENT_INSTALLER_Name[0]).msi"
Function DownloadAgentInstaller()
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}
DownloadAgentInstaller
$output = $AGENT_INSTALLER_PATH
msiexec /i $output /quiet /l*v C:\windows\Temp\msiexec$($TimeStamp).log
Start-Sleep -Seconds 60
remove-item $output -force