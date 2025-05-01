$TenantID = (Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\OneDrive\Accounts\Business2 -Name "ConfiguredTenantId" | Select-Object -ExpandProperty ConfiguredTenantId)
if ($TenantID -eq '62a88ad2-3f81-4793-9a8f-8597480af405')
{
    Write-Output "Success - Tenant ID = $TenantID"
}
else
{
    Write-Output "FAILED - Tenant ID = $TenantID"
}