$AdminAcc = Read-Host "Enter Admin Account for EAC and press Enter"
$UPN = Read-Host "Enter User account to expand and press Enter"
Import-Module ExchangeOnlineManagement
Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $AdminAcc
Enable-Mailbox $UPN -AutoExpandingArchive