$userToAddOwner = "username@yourdomain.com"
Get-UnifiedGroup -ResultSize Unlimited | ForEach-Object {
$o365group = $_
Add-UnifiedGroupLinks –Identity $o365group.Name –LinkType Members –Links $userToAddOwner
Add-UnifiedGroupLinks –Identity $o365group.Name –LinkType Owners –Links $userToAddOwner
}