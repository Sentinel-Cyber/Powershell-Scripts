<#
	.Description
		Script for looking at the event log of a specific computer, to find event ID's of 7001 and 7002, for a specific user.
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$UserName,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [String]$ComputerName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Days
)

function GetLogonInfo {
    #Gets the specified user logon and logoff data from the specified computer's event log, a number of days back as specified.

    $StartTime = (Get-Date).AddDays(-$Days)
    $User = get-aduser -Identity $UserName -Properties SID | Select-Object -ExpandProperty SID
    get-winevent -ComputerName $ComputerName -FilterHashtable @{ LogName='System'; ID=7001,7002; Data=$User; StartTime=$StartTime}
}

GetLogonInfo