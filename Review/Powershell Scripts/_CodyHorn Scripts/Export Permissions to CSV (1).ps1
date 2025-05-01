###############################################################
#Export folder permissions in directory
###############################################################
New-Item -ItemType Directory -Force -Path C:\PS | Out-Null
$FolderPath = dir -Directory -Path "D:\Data\Share" -Recurse -Force
$Report = @()
Foreach ($Folder in $FolderPath) {
    $Acl = Get-Acl -Path $Folder.FullName
    foreach ($Access in $acl.Access)
        {
            $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD
Group or
User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
            $Report += New-Object -TypeName PSObject -Property $Properties
        }
}
$Report | Export-Csv -path "C:\PS\FolderPermissions.csv"
Invoke-Item "C:\PS\"