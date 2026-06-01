# Ensure TLS 1.2 (required for PowerShell Gallery)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install module if missing
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
}

# Import module
Import-Module ExchangeOnlineManagement

# Verify module is working
Get-Command Connect-ExchangeOnline
