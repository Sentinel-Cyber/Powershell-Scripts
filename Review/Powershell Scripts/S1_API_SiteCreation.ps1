### Account ID for the JSON can be found while in the portal under the parent account > Sentinels > Account Info
### URL = the root URL of your site e.g 'https://usea1-cw01.sentinelone.net' followed by /web/api/v2.0/sites?ApiToken=$your admin account generated API Token
### UserID for JSON can be acquired via REST API or the API Docs from S1 using the List Users command and filtering by the parent company ID. The userID will be in the returned JSON.
$Uri = 'https://usea1-cw01.sentinelone.net/web/api/v2.1/sites?ApiToken=iwDbwBNlqAcA7igUK3Fd82xoZQHsUu4fouVel7mGqVEegLhsckltDLMxzafGdQraMAE3X7UmjYUR3E9d'

$sitename = "@NewSiteName@"

$JSON = '{
  "data": {
    "accountId": "1591349406353077344",
    "totalLicenses": Unlimited,
    "name": "' + $sitename + '",
    "sku": "Control",
    "suite": "Control",
    "unlimitedExpiration": null,
    "externalId": null,
    "siteType": "Trial",
    "inherits": false,
    "policy": {
      "userFullName": "string",
		"agentLoggingOn": true,
		"agentNotification": false,
		"agentUiOn": true,
		"allowRemoteShell": false,
		"antiTamperingOn": true,
		"autoDecommissionDays": 90,
		"autoDecommissionOn": true,
		"autoFileUpload": {
			"enabled": false
		},
		"autoImmuneOn": true,
		"autoMitigationAction": "mitigation.none",
		"cloudValidationOn": true,
		"createdAt": "2021-07-16T13:40:58.985809Z",
		"engines": {
			"applicationControl": "off",
			"dataFiles": "on",
			"executables": "on",
			"exploits": "on",
			"lateralMovement": "on",
			"penetration": "on",
			"preExecution": "on",
			"preExecutionSuspicious": "on",
			"pup": "on",
			"remoteShell": "on",
			"reputation": "on"
		},
		"fwForNetworkQuarantineEnabled": false,
		"inheritedFrom": null,
		"isDefault": false,
		"mitigationMode": "detect",
		"mitigationModeSuspicious": "detect",
		"monitorOnExecute": true,
		"monitorOnWrite": true,
		"networkQuarantineOn": false,
		"researchOn": true,
		"scanNewAgents": true,
		"snapshotsOn": true,
		"userId": "1606665172985024445"
	},
    "unlimitedLicenses": null
  }
}'

$response = Invoke-RestMethod -Uri $Uri -Method Post -Body $JSON -ContentType "application/json"

echo $response.data.registrationToken