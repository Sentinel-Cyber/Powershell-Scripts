$clearCache = Read-Host "Do you want to delete the Teams Cache for all user profiles on this device? Be aware this will close all active sessions of Teams (Y/N)?"
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
    Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\teams | Remove-Item -Recurse -Confirm:$false
    Write-Host "Teams cache removed" -ForegroundColor Green
  }catch{
    echo $_
  }

  Write-Host "Cleanup complete... Launching Teams" -ForegroundColor Green
  Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Teams\current\Teams.exe"
}