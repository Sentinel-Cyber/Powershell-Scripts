# Define common parameters
# Rules defined and suggested by Charlton Fenandes [cfernandes@abacusnext.com] provided to Ramon @ Sentinel Cyber
# Script Written with Claude and verified by Ramon @ Sentinel Cyber
$serverIP = "10.0.1.9"
$subnet = "10.0.1.0/24"
$portRange = "49500-49510"
$ruleName = "Sentinel - Amicus Access Rule"
$description = "Allow access to $serverIP on ports $portRange for TCP and UDP for the Amicus Server Exch Service from subnet $subnet"

# Create inbound TCP rule
New-NetFirewallRule -DisplayName "$ruleName - Inbound TCP" `
    -Description $description `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort $portRange `
    -LocalAddress $serverIP `
    -RemoteAddress $subnet `
    -Action Allow `
    -Profile Domain `
    -Enabled True

# Create inbound UDP rule
New-NetFirewallRule -DisplayName "$ruleName - Inbound UDP" `
    -Description $description `
    -Direction Inbound `
    -Protocol UDP `
    -LocalPort $portRange `
    -LocalAddress $serverIP `
    -RemoteAddress $subnet `
    -Action Allow `
    -Profile Domain `
    -Enabled True

# Create outbound TCP rule
New-NetFirewallRule -DisplayName "$ruleName - Outbound TCP" `
    -Description $description `
    -Direction Outbound `
    -Protocol TCP `
    -LocalPort $portRange `
    -LocalAddress $serverIP `
    -RemoteAddress $subnet `
    -Action Allow `
    -Profile Domain `
    -Enabled True

# Create outbound UDP rule
New-NetFirewallRule -DisplayName "$ruleName - Outbound UDP" `
    -Description $description `
    -Direction Outbound `
    -Protocol UDP `
    -LocalPort $portRange `
    -LocalAddress $serverIP `
    -RemoteAddress $subnet `
    -Action Allow `
    -Profile Domain `
    -Enabled True