## To run agent tasks, the agent needs to be able to access 'https://raw.githubusercontent.com/LabtechConsulting/LabTech-Powershell-Module/master/LabTech.psm1'
### Setting up Variables
$cwaserv = 'overwatchgroup.hostedrmm.com'
$cwauser = 'Automation'
$cwapass = ConvertTo-SecureString 'Mushroom@Implosion8@Roast' -AsPlainText -Force
$cwacredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cwauser, $cwapass
$cwaid = 'baa2368e-3110-4e96-a314-4a8e3205e3cd'
##$cwamfa = 'HAYWEOJTGYYTMLJXGU2TKLJUHFSTMLJZMJSTGLLDGZTDAZLDMVTGGMZQMI'
$cwcadd = 'https://overwatchgroup.hostedrmm.com:8040'
$cwcuser = 'AutomateFunctions'
$cwcpass = ConvertTo-SecureString '55@25LyBTjrqu!vy3Vyy!@&&F!kiNwL5Y%dfV#XTp^PbVXbeJj' -AsPlainText -Force
$cwccredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cwcuser, $cwcpass
## Enable Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
## Start Module setup and fix
Install-Module AutomateAPI
Import-Module AutomateAPI
Connect-AutomateAPI -Credential $cwacredential -ClientID $cwaid -Server $cwaserv
Connect-ControlAPI -Credential $cwccredential -Server $cwcadd
##Sleep 10
##Get-AutomateComputer -Online $false | Compare-AutomateControlStatus | Repair-AutomateAgent -Action Restart -Confirm:$false