### Account ID for the JSON can be found while in the portal under the parent account > Sentinels > Account Info
### URL = the root URL of your site e.g 'https://usea1-cw01.sentinelone.net' followed by /web/api/v2.0/sites?ApiToken=$your admin account generated API Token
### UserID for JSON can be acquired via REST API or the API Docs from S1 using the List Users command and filtering by the parent company ID. The userID will be in the returned JSON.
    
$ApiToken = "cUKQPjhvAnoohaZuHYTqtBiyj2ZZNMcQ2Jb5qMgYaBAXyi6sRJ1GR7ZT6bp3MF8HxYet1sxUmBzdeL1M"
$AccountID = "1591349406353077344"
$Name = "TEST4"

    
$Body = [PSCustomObject]@{
     data = [PSCustomObject]@{
        siteType = "Paid"
        name = "$Name"
        unlimitedLicenses = $true
        sku = "Control"
        inherits = $true
        suite = "Control"
        accountId = "$AccountID"
        expiration = "2029-12-31T04:49:26.257525Z"
    }
}

$json = $Body | ConvertTo-Json
Write-Host $json
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "ApiToken $($ApiToken)")
$headers.Add("Content-Type", "application/json")
$url = "https://usea1-cw01.sentinelone.net/web/api/v2.1/sites"
$req = Invoke-RestMethod -Uri $url -Method 'POST' -Headers $headers -Body $json
return $req.data | select-object -ExpandProperty registrationToken
##$SiteToken = return $req.data | select-object -ExpandProperty regsitrationToken