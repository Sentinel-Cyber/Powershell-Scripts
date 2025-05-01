$Path = Read-Host "Enter Parent Folder Path for Redirected or Profile Folders Here"
##11/18/22 added a space after | in the $Homefolders line
$HomeFolders = Get-ChildItem $Path | where{$_.PSIsContainer -eq 'True'}
foreach ($HomeFolder in $HomeFolders) {
    $Path = $HomeFolder.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $HomeFolder.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.AddAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}