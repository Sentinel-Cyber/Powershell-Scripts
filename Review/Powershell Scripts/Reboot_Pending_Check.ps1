﻿# borrowed from the internet and modified by ATS
# v1.1
# 2019/12/16

param (
	[switch]$RebootNow = $false
)

## Setting pending values to false to cut down on the number of else statements
$CompPendRen,$PendFileRename,$Pending,$SCCM = $false,$false,$false,$false

## Setting CBSRebootPend to null since not all versions of Windows has this value
$CBSRebootPend = $null

## Querying WMI for build version
$WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $env:ComputerName -ErrorAction Stop

## Making registry connection to the local/remote computer
$HKLM = [UInt32] "0x80000002"
$WMI_Reg = [WMIClass] "\\$env:ComputerName\root\default:StdRegProv"

## If Vista/2008 & Above query the CBS Reg Key
If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
}

## Query WUAU from the registry
$RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
$WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

## Query PendingFileRenameOperations from the registry
$RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations")
$RegValuePFRO = $RegSubKeySM.sValue

## Query JoinDomain key from the registry - These keys are present if pending a reboot from a domain join operation
$Netlogon = $WMI_Reg.EnumKey($HKLM,"SYSTEM\CurrentControlSet\Services\Netlogon").sNames
$PendDomJoin = ($Netlogon -contains 'JoinDomain') -or ($Netlogon -contains 'AvoidSpnSet')

## Query ComputerName and ActiveComputerName from the registry
$ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")
$CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")

If (($ActCompNm -ne $CompNm) -or $PendDomJoin) {
    $CompPendRen = $true
}

## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
If ($RegValuePFRO) {
    $PendFileRename = $true
}

## Determine SCCM 2012 Client Reboot Pending Status
## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
$CCMClientSDK = $null
$CCMSplat = @{
    NameSpace='ROOT\ccm\ClientSDK'
    Class='CCM_ClientUtilities'
    Name='DetermineIfRebootPending'
    ComputerName=$env:ComputerName
    ErrorAction='Stop'
}
## Try CCMClientSDK
Try {
    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
} Catch [System.UnauthorizedAccessException] {
    $CcmStatus = Get-Service -Name CcmExec -ComputerName $env:ComputerName -ErrorAction SilentlyContinue
    If ($CcmStatus.Status -ne 'Running') {
        Write-Warning "$env:ComputerName`: Error - CcmExec service is not running."
        $CCMClientSDK = $null
    }
} Catch {
    $CCMClientSDK = $null
}

If ($CCMClientSDK) {
    If ($CCMClientSDK.ReturnValue -ne 0) {
        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
    }
    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
        $SCCM = $true
    }
} else {
    $SCCM = $null
}

$reboot = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)

if ($true -eq $reboot) {
    Write-Host Reboot is pending. 
    if ($true -eq $RebootNow) {
        Write-Host Restarting computer now...
        Restart-Computer -Force
        return $true
    } else {
        Write-Host '(Tip: Run this script again with "-RebootNow" switch to force an immediate reboot.)'
        return $true
    }
} else {
    Write-Host Reboot is not pending.
    return $false
}

