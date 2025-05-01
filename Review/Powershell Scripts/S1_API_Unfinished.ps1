$Uri = 'https://usea1-pax8.sentinelone.net/web/api/v2.0/sites?ApiToken=FQqnPN3V3NN1z0580ctUwYfMfqjAuAYnUsVcSi3LGCNPdLFxpvMEAeD1zqCs3HOFjrU1u3vAtdg71WD5'

$sitename = "TestSite"

$JSON = '{
  "data": {
    "accountId": "1031148474820287216",
    "totalLicenses": 1,
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
		"userId": "1245914305612617108"
	},
    "unlimitedLicenses": null
  }
}'