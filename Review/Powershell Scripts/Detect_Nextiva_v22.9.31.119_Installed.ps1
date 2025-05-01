$current = Get-WmiObject -Class win32_Product | where {$_.vendor -eq "Nextiva, Inc"}

if(!$current.version){
    return $false
}else{
    $minVersion = [Version]"22.9.31.119"

    if([Version]$current.version -ge $minVersion){
    return $true
    }
}