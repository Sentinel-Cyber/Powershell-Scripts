 $Token = 'INSTALLERTOKENHERE'
 $LocationID = '223'
 iex (new-object Net.WebClient).DownloadString('https://bit.ly/LTPoSh'); Install-LTService -Server 'https://overwatchgroup.hostedrmm.com' -LocationID $LocationID -InstallerToken $Token -Force