#Microsoft Teams cache behaviour is a lot to be desired if I am honest. 
#One thing for sure is that if you are deploying Teams you’ll quickly find that your admin controlled policy settings take a random amount of time to come into effect on the target machines.

#Unlike Skype for Business Online where in-band policy changes took longest 30 minutes, with Teams we can be waiting days, and I mean that literally.

#Upon talking with support the standard response is that it can take anything from 30 minutes to 3 days for policies to become effective. 
#To me, this is unacceptable and Microsoft have acknowledged that at least. Hopefully we will see some improvements soon.

#The problem though really centers around the client cache. So clearing the cache is the first step to troubleshooting. 
#The trouble is, the cache for Teams isn’t in one place or even a single directory. It’s split in multiple directories and even Internet Explorer and Chrome cache locations. 
#So when support as you to clear the cache, there are something like 13 different places you need to go in order to clean the machine.

#These locations are:

#%AppData%\Microsoft\teams\application cache\cache
#%AppData%\Microsoft\teams\blob_storage
#%AppData%\Microsoft\teams\databases
#%AppData%\Microsoft\teams\cache
#%AppData%\Microsoft\teams\gpucache
#%AppData%\Microsoft\teams\Indexeddb
#%AppData%\Microsoft\teams\Local Storage
#%AppData%\Microsoft\teams\tmp
#%LocalAppData%\Google\Chrome\User Data\Default\Cache
#%LocalAppData%\Google\Chrome\User Data\Default\Cookies
#%LocalAppData%\Google\Chrome\User Data\Default\Web Data
#Internet Explorer Temporary Internet Files
#Internet Explorer Cookies

$challenge = Read-Host "Are you sure you want to delete Teams Cache (Y/N)?"
$challenge = $challenge.ToUpper()
if ($challenge -eq "N"){
Stop-Process -Id $PID
}elseif ($challenge -eq "Y"){
Write-Host "Stopping Teams Process" -ForegroundColor Yellow
try{
Get-Process -ProcessName Teams | Stop-Process -Force
Start-Sleep -Seconds 3
Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Clearing Teams Disk Cache" -ForegroundColor Yellow
try{
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\application cache\cache" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blob_storage" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" | Remove-Item -Confirm:$false
Write-Host "Teams Disk Cache Cleaned" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Stopping Chrome Process" -ForegroundColor Yellow
try{
Get-Process -ProcessName Chrome| Stop-Process -Force
Start-Sleep -Seconds 3
Write-Host "Chrome Process Sucessfully Stopped" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Clearing Chrome Cache" -ForegroundColor Yellow
try{
Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Cache" | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Cookies" -File | Remove-Item -Confirm:$false
Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Web Data" -File | Remove-Item -Confirm:$false
Write-Host "Chrome Cleaned" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Stopping IE Process" -ForegroundColor Yellow
try{
Get-Process -ProcessName MicrosoftEdge | Stop-Process -Force
Get-Process -ProcessName IExplore | Stop-Process -Force
Write-Host "Internet Explorer and Edge Processes Sucessfully Stopped" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Clearing IE Cache" -ForegroundColor Yellow
try{
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 2
Write-Host "IE and Edge Cleaned" -ForegroundColor Green
}catch{
echo $_
}
Write-Host "Cleanup Complete... Launching Teams" -ForegroundColor Green
Start-Process -FilePath $env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe
Stop-Process -Id $PID
}else{
Stop-Process -Id $PID
}