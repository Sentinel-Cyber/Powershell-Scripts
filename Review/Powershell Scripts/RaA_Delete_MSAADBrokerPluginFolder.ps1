$enduser = Read-Host "Please provide the profile folder name:"
Remove-Item -Path "C:\Users\$enduser\AppData\Local\Packages\Microsoft.AAD.BrokerPlugin*"