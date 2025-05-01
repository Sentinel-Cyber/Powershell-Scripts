$clearCache = Read-Host "Do you want to delete the Teams Cache (Y/N)?"
$clearCache = $clearCache.ToUpper()

if ($clearCache -eq "Y"){
  Write-Host "Closing Teams" -ForegroundColor Cyan
  
  try{
    if (Get-Process -ProcessName Teams -ErrorAction SilentlyContinue) { 
        Get-Process -ProcessName Teams | Stop-Process -Force
        Start-Sleep -Seconds 3
        Write-Host "Teams sucessfully closed" -ForegroundColor Green
    }else{
        Write-Host "Teams is already closed" -ForegroundColor Green
    }
  }catch{
      echo $_
  }

  Write-Host "Clearing Teams cache" -ForegroundColor Cyan

  try{
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams" | Remove-Item -Recurse -Confirm:$false
    Write-Host "Teams cache removed" -ForegroundColor Green
  }catch{
    echo $_
  }

  Write-Host "Cleanup complete... Launching Teams" -ForegroundColor Green
  Start-Process -FilePath $env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe
}