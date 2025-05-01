$proc = Get-Process 'Teams' -ErrorAction SilentlyContinue
$cacheFolderPath = "$($env:APPDATA)\Microsoft\Teams"
$proc | Stop-Process
$cacheItems = Get-ChildItem $cacheFolderPath -Exclude 'Backgrounds'
$cacheItems | Remove-Item -Recurse -Force
$startProcessArgs = @{
  FilePath = "$($env:LOCALAPPDATA)\Microsoft\Teams\Update.exe"
  ArgumentList = '--processStart "Teams.exe"'
}
Start-Process  @startProcessArgs