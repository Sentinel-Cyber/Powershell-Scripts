##WebURI Link is generated at rebrandly with Ramon's GMail account - Update via that account to edit short url
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri "https://calicoit.screenconnect.com/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest&c=Coastal%20Medical%20Group&c=Main&c=&c=SBC&c=&c=&c=&c=" -OutFile "C:\Windows\Temp\ScreenConnect.msi"
msiexec.exe /i "C:\Windows\Temp\ScreenConnect.msi" ALLUSERS=1 /qn /norestart /log output.log