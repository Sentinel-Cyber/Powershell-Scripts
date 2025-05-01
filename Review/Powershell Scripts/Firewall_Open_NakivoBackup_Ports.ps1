$StartPort = 9446
$EndPort = 10000
$Protocol = "TCP"
$PortRange = "$StartPort-$EndPort"

New-NetFirewallRule -DisplayName "Nakivo Backup" -Direction Inbound -LocalPort $PortRange -Protocol $Protocol -Action Allow