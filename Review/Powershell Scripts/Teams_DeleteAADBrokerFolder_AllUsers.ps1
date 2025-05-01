## Stop Teams and Delete the AADBroker Folder to try and repair Sign-In
try{
    if (Get-Process -ProcessName Teams -ErrorAction SilentlyContinue) {
        Get-Process -ProcessName Teams | Stop-Process -Force
        Start-Sleep -Seconds 3
    }else{
        continue
    }
}catch{
    echo $_
}

try{
    Get-ChildItem C:\Users\*\AppData\Local\Packages -Include Microsoft.AAD* -Recurse | Remove-Item -Recurse -Force
    }catch{
        echo $_
    }