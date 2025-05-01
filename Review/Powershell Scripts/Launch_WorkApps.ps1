Write-Host 'Opening Work Apps' -ForegroundColor Cyan

Start-Process -FilePath 'C:\Users\DeWitt\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams'
Sleep 3
Start-Process -FilePath 'C:\Program Files (x86)\ConnectWise\PSA.net\ConnectWiseManage.exe'
Sleep 3 
Start-Process -FilePath 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

Write-Host 'Apps Launched' -ForegroundColor Cyan