# Define the Get-Folder function to display a folder selection dialog
function Get-Folder($Title) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.Description = $Title
    $FolderBrowser.ShowNewFolderButton = $false
    $DialogResult = $FolderBrowser.ShowDialog()
    if ($DialogResult -eq "OK") {
        $SelectedPath = $FolderBrowser.SelectedPath
        return $SelectedPath
    }
}

# Select the source and target folders
$source = Get-Folder -Title "Select Source Folder"
$target = Get-Folder -Title "Select Target Folder"

# Create a VSS snapshot of the source folder
$vss = Get-WmiObject -Class Win32_ShadowCopy -Namespace "root\cimv2" |
    Where-Object { $_.DeviceObject -match [regex]::Escape($source) } |
    Select-Object -First 1

# Select the files or folders to restore from the VSS snapshot
$selected = Get-ChildItem -Path $vss.DeviceObject + "\" -Recurse | Out-GridView -PassThru -Title "Select Items to Restore"

# Restore the selected files or folders
foreach ($item in $selected) {
    $relativePath = $item.FullName.Substring($vss.DeviceObject.Length)
    $targetPath = Join-Path -Path $target -ChildPath $relativePath

    if ($item.PSIsContainer) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    } else {
        $directory = Split-Path -Path $targetPath -Parent
        if (!(Test-Path -Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        Copy-Item -Path $item.FullName -Destination $targetPath -Force
    }
}
