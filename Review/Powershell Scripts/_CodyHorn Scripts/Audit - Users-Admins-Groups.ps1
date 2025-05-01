Write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||"
Write-Host "--------------------------------------------------"
Write-Host "Sun State Technology Group"
Write-Host "Active Directory Audit"
Write-Host "Last Updated: 6/8/2020" 
Write-Host "Cody Horn - Chorn@sunstatetech.com"
Write-Host "--------------------------------------------------"
Write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||"
Write-Host ""
Write-Host ""
Write-Host ""

#Sets client acronym for file labeling
$client = Read-Host -Prompt 'Enter Client Acronym'
New-Item -ItemType Directory -Force -Path C:\PS | Out-Null

#Gets all AD Users and outputs to CSV File
Get-ADUser -Filter 'Enabled -eq $true' -Property Name,CanonicalName,CN,DisplayName,DistinguishedName,HomeDirectory,HomeDrive,SamAccountName,UserPrincipalName,
LastLogonDate, scriptPath  | `export-csv -path C:\PS\$client-Audit-AD-Users.csv -NoTypeInformation

#Gets all AD Users who are members of the Administrators group and outputs to CSV File
Get-ADGroupMember -Identity "Administrators" | Select-Object -Property Name, SamAccountName |  Export-Csv -Append -Force -Path C:\PS\$client-Audit-Administrators.csv -NoTypeInformation
#Gets all AD Users who are members of the Domain Admins group and outputs to CSV File
Get-ADGroupMember -Identity "Domain Admins" | Select-Object -Property Name, SamAccountName | Export-Csv -Append -Force -Path C:\PS\$client-Audit-Domain-Admins.csv -NoTypeInformation
Write-Host ""
#Gets all security groups under given OU DN and exports to CSV
$groupOU = Read-Host 'OU DN that contains the Security Groups'
$groups = Get-ADGroup -SearchBase $groupOU -Filter * | Select-Object -ExpandProperty name | Set-Content -Path C:\PS\grouplist.txt
Start-Sleep -s 5
$groupsList = Get-Content C:\PS\grouplist.txt
add-content -Path C:\PS\$client-Group-Audit.csv -Value "Group,User"
foreach($Group in $groupsList)
{
    $users=Get-ADGroupMember -Id $Group
    foreach($user in $users)
    {
        add-content -Path C:\PS\$client-Group-Audit.csv -Value "$group,$($user.samaccountname)"
    }
}

#Opens file path
Invoke-Item "C:\PS\"
