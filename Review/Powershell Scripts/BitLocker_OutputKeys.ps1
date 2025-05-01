$ret = ""
(Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume) | Sort-Object DriveLetter | ForEach-Object {
	if ($_.protectionstatus -eq 1) {
		$protector = (Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -Filter ("DriveLetter = '" + $_.DriveLetter + "'")).GetKeyProtectors(3)
		$password  = (Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -Filter ("DriveLetter = '" + $_.DriveLetter + "'")).GetKeyProtectorNumericalPassword($protector.VolumeKeyProtectorId)
		$ret += ($_.DriveLetter + " identifier " + $protector.VolumeKeyProtectorId + ", recovery " + $password.NumericalPassword + "; ")
	} else {
		$ret += ($_.DriveLetter + " BitLocker not enabled;")
	}
}
$ret