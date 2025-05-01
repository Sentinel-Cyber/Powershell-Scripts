# Import the AD module
Import-Module activedirectory

#Define CSV Location
$csv = "C:\temp\UsersProxyAddresses.csv"

#Define OU Filter
$OU = "OU=NY Users,OU=Users and Groups,DC=swpallp,DC=local"

# Loop through each row in the CSV Sheet 
Import-csv $csv | foreach {Set-ADUser -Identity $_.samaccountname -add @{Proxyaddresses=$_.Proxyaddresses -split ","}}