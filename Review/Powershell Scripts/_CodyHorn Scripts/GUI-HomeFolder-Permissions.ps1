Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Function validateTextBox(){
if ($InputBox1.Text -match "^\\(?:\\[^<>:`"/\\|?*]+)+$") {
$RunButton.Enabled = $true
}else{
$RunButton.Enabled = $false
}
}### END FUNCTION ###

Function RunCheck {
$homeDrivesDir = $InputBox1.Text
#Set Report ON or OFF
if ($Mode1.Checked -eq $true) {$reportMode = $true}
if ($Mode2.Checked -eq $true) {$reportMode = $false}
$verbose = $true
$domainName = (Get-ADDomain -Current LocalComputer).NetBiosName
$UserPermissions = $permChoice.SelectedItem

if (Test-Path $homeDrivesDir) {
#################################################################################
# Save the current working directory before we change it (purely for convenience)
pushd .
# Change to the location of the home drives
Set-Location $homeDrivesDir

# Warn the user if we will be fixing or just reporting on problems
write-host ""
if ($reportMode) {
 Write-Host "Report mode is on. Not fixing problems"
} else {
 Write-Host "Report mode is off. Will fix problems"
}
write-host ""

# Initialise a few counter variables. Only useful for multiple executions from the same session
$goodPermissions = $unfixablePermissions = $fixedPermissions = $badPermissions = 0
$failedFolders = @()

# For every folder in the $homeDrivesDir folder
foreach($homeFolder in (Get-ChildItem $homeDrivesDir | Where {$_.psIsContainer -eq $true})) {
    # dump the current ACL in a variable
    $Acl = Get-Acl $homeFolder

    # create a permission mask in the form of DOMAIN\Username where Username=foldername
    #    (adjust as necessary if your home folders are not exactly your usernames)
    $compareString = "*" + $domainName + "\" + $homeFolder.Name + " Allow  $UserPermissions*"

    # if the permission mask is in the ACL
    if ($Acl.AccessToString -like $compareString) {
    
    # everything's good, increment the counter and move on.
    if ($verbose) {Write-Host "Permissions are valid for" $homeFolder.Name -backgroundcolor green -foregroundcolor black}
        $goodPermissions += 1
    } else {
        # Permissions are invalid, either fix or report
        # increment the number of permissions needing repair
        $badPermissions += 1
        # if we're in report mode
        if ($reportMode -eq $true) {
            # reportmode is on, don't do anything
            Write-Host "Permissions not valid for" $homeFolder.Name OR $homeFolder.Name does not exist! -backgroundcolor red -foregroundcolor white
        } else {
            # reportmode is off, fix the permissions
            Write-Host "Setting permissions for" $homeFolder.Name -foregroundcolor white -backgroundcolor red

            # Add the user in format DOMAIN\Username
            $username = $domainName + "\" + $homeFolder.Name
        
            # Grant the user Modify
            $accessLevel = "$UserPermissions"
        
            # Should permissions be inherited from above?
            $inheritanceFlags = "ContainerInherit, ObjectInherit"
        
            # Should permissions propagate to below?
            $propagationFlags = "None"
        
            # Is this an Allow/Deny entry?
            $accessControlType = "Allow"
        
            try {
                # Create the Access Rule
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                # Attempt to apply the access rule to the ACL
                $Acl.SetAccessRule($accessRule)
                Set-Acl $homeFolder.Name $Acl
                # if it hasn't errored out by now, increment the counter
                $fixedPermissions += 1
            } catch {
                # It failed!
                # Increment the fail count
                $unfixablePermissions += 1
                # and add the folder to the list of failed folders
                $failedFolders += $homeFolder
            }
        } #/if
    } #/if
} #/foreach
# Print out a summary
Write-Host ""
Write-Host $goodPermissions "valid permissions"
Write-Host $badPermissions "permissions needing repair"
if ($reportMode -eq $false) {Write-Host $fixedPermissions "permissions fixed"}
if ($unfixablePermissions -gt 0) {
 Write-Host $unfixablePermissions "Folders that could not be repaired."
 foreach ($folder in $failedFolders) {Write-Host " -" $folder}
}
# Cleanup
popd
}else{
    $InputBox1.BackColor = "red"
    $InputBox1.ForeColor = "white"
    $InputBox1.Text = "Path not Valid"
}
}#####  END Function  ########################################################

#Build Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Repair HomeDirectory Permissions"
$Form.Size = New-Object System.Drawing.Size(250,300)
$Form.AutoSize = $false
$Form.FormBorderStyle = 'FixedDialog'
$Form.StartPosition = "CenterScreen"


#Input Box
$InputBox1 = New-Object System.Windows.Forms.TextBox
$InputBox1.Location = New-Object System.Drawing.Size(20,60)
$InputBox1.Size = New-Object System.Drawing.Size(200,20)
$InputBox1.Add_TextChanged({validateTextBox})
$Form.Controls.Add($InputBox1)
#Input Box Label
$inputBxLbl = New-Object System.Windows.Forms.Label
$inputBxLbl.Location = New-Object System.Drawing.Size(16,42)
$inputBxLbl.Size = New-Object System.Drawing.Size(100,20)
$inputBxLbl.Text = 'Share Path "\\SERVER\SHARE"'
$inputBxLbl.AutoSize = $true
$Form.Controls.Add($inputBxLbl)

#Domain Name
$DomainLbl = New-Object System.Windows.Forms.Label
$DomainLbl.Location = New-Object System.Drawing.Size(120,10)
$DomainLbl.Size = New-Object System.Drawing.Size(100,20)
$DomainLbl.Text = (Get-ADDomain -Current LocalComputer).NetBiosName
$DomainLbl.BackColor = "Transparent"
$DomainLbl.AutoSize = $true
$Form.Controls.Add($DomainLbl)
#Domain Label
$DomainLbl = New-Object System.Windows.Forms.Label
$DomainLbl.Location = New-Object System.Drawing.Size(20,10)
$DomainLbl.Size = New-Object System.Drawing.Size(100,20)
$DomainLbl.Text = "Current Domain is:"
$DomainLbl.BackColor = "Transparent"
$DomainLbl.AutoSize = $true
$Form.Controls.Add($DomainLbl)

#Report Mode Box
$Mode = New-Object System.Windows.Forms.GroupBox
$Mode.Location = New-Object System.Drawing.Size(20,90)
$Mode.Size = New-Object System.Drawing.Size(200,70)
$Mode.Text = "Select Run Mode"
$Form.Controls.Add($Mode)
#Mode Option1
$Mode1 = New-Object System.Windows.Forms.RadioButton
$Mode1.Location = New-Object System.Drawing.Size(10,20)
$Mode1.Size = New-Object System.Drawing.Size(150,20)
$Mode1.Text = "Report Only"
$Mode1.Checked = $true
$Mode.Controls.Add($Mode1)
#Mode Option2
$Mode2 = New-Object System.Windows.Forms.RadioButton
$Mode2.Location = New-Object System.Drawing.Size(10,40)
$Mode2.Size = New-Object System.Drawing.Size(150,20)
$Mode2.Text = "Repair Permissions"
$Mode.Controls.Add($Mode2)

#Permissions Box
$permChoice = New-Object System.Windows.Forms.ComboBox
$permChoice.Location = New-Object System.Drawing.Size(20,190)
$permChoice.Size = New-Object System.Drawing.Size(180,20)
$permChoice.Width = 200
$permChoice.Text = "Modify"
$Choices = @("Modify","FullControl","ReadAndExecute")
    Foreach ($Choice in $Choices){$permChoice.Items.Add($Choice)}
$permChoice.SelectedIndex = 0
$Form.Controls.Add($permChoice)
#Permission Label
$PermLbl = New-Object System.Windows.Forms.Label
$PermLbl.Location = New-Object System.Drawing.Size(20,170)
$PermLbl.Size = New-Object System.Drawing.Size(10,20)
$PermLbl.Text = "Select Permissions for Users:"
$PermLbl.BackColor = "Transparent"
$PermLbl.AutoSize = $true
$Form.Controls.Add($PermLbl)

#Run Button
$RunButton = New-Object System.Windows.Forms.Button
$RunButton.Location = New-Object System.Drawing.Size(20,220)
$RunButton.Size = New-Object System.Drawing.Size(120,40)
$RunButton.Text = "Run NOW"
$RunButton.Enabled = $false
$RunButton.Add_Click({RunCheck})
$Form.Controls.Add($RunButton)

$Form.ShowDialog()
