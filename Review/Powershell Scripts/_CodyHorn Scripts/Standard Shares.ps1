#Sun State Technology
#Author: Cody Horn - chorn@sunstatetech.com
#Modified: 8/19/20



Add-WindowsFeature RSAT-AD-PowerShell
import-module ActiveDirectory

#Collects Enviroment Variables
$Domain = (Get-ADDomain).DNSRoot
$ServerName = [Environment]::MachineName

#Disables UAC
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates Root Data Folder
$dir = 'D:\Data\'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates Home Folder
$dir = 'D:\Data\Home\'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL

#Creates Network Share
New-SmbShare -Name "Home$" -Path $dir -FullAccess "$($Domain)\Domain Users"
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates Archive Folder
$dir = 'D:\Data\Archive\'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL
#Creates Network Share
New-SmbShare -Name "Archive$" -Path $dir -FullAccess "$($Domain)\Domain Users"
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates IT Folder
$dir = 'D:\Data\IT\'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Domain Users Permissions
$identity = "$($Domain)\Domain Users"
$ACL = Get-Acl $dir
$rights = 'ReadAndExecute'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL
#Creates Network Share
New-SmbShare -Name "IT" -Path $dir -FullAccess "$($Domain)\Domain Users"
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates IT-Admin Folder
$dir = 'D:\Data\IT\IT-Admin'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL


#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
#Creates Share Folder
$dir = 'D:\Data\Share\'
New-Item $dir -ItemType Directory

#Sets Domain Admins Permissions
$identity = "$($Domain)\Domain Admins"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets Local Administrator Permissions
$identity = "$($ServerName)\Administrator"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Sets SYSTEM Permissions
$identity = "SYSTEM"
$ACL = Get-Acl $dir
$rights = 'FullControl'
$inheritance = 'ContainerInherit,ObjectInherit'
$propogation = 'None'
$type = 'Allow'
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation,$type)
$ACL.AddAccessRule($ACE)
Set-Acl $dir -AclObject $ACL

#Removes Inherited Permissions
$ACL = Get-ACL -Path $dir
$ACL. SetAccessRuleProtection($True, $False)
Set-Acl -Path $dir -AclObject $ACL

#Creates Network Share
New-SmbShare -Name "Share" -Path $dir -FullAccess "$($Domain)\Domain Users"






Restart-Computer