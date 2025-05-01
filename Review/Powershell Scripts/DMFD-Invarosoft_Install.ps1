### Inputs
$Activation_Code = "VTEHXLOVJB"
### Script
Set-ExecutionPolicy Bypass -scope CurrentUser
mkdir c:\temp
Set-Location -path c:\temp
wget https://goto.invarosoft.com/?id=latest-win-msi -outfile c:\temp\itsp.installer.msi
msiexec.exe /i c:\temp\itsp.installer.msi /q ACTIVATION=$Activation_Code