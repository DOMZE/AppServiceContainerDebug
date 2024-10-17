[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)]
    [string] $ServerName,
    [Parameter(Mandatory = $True)]
    [String] $Database,
    [string] $ClientId
)

$ErrorActionPreference = "Stop"

# Function to get access token based on system or user identity
function Get-AccessToken {
    param (
        [string] $ClientId
    )

    # Fetch the identity endpoint and header from the environment
    $identityEndpoint = $env:IDENTITY_ENDPOINT
    $identityHeader = $env:IDENTITY_HEADER

    $url = "$($identityEndpoint)?resource=https://database.windows.net&api-version=2019-08-01"
    # Using User Identity
    if (![String]::IsNullOrWhiteSpace($ClientId)) {
        $url += "&client_id=$ClientId"
    }

    $headers = @{
        'X-IDENTITY-HEADER' = $identityHeader
    }

    # Send HTTP GET request and extract access token
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    return $response.access_token
}

# Get access token
$accessToken = Get-AccessToken -ClientId $ClientId

# Output token (optional)
Write-Output "Access Token: $accessToken"

# Write token to file in UTF-16LE format
$tokenFile = "tokenfile"
[System.Text.Encoding]::Unicode.GetBytes($accessToken) | Out-File -FilePath $tokenFile -Encoding utf8 -Force

# Execute SQL queries using sqlcmd
$server = "$ServerName.database.windows.net"

# Query 1: Select @@servername
# see https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/connecting-with-sqlcmd?view=sql-server-ver16 for parameters
Write-Output "Getting the server name from the database"
& sqlcmd -S $server -d $Database -G -P $tokenFile -Q "SELECT @@servername"

# Query 2: Get base tables from INFORMATION_SCHEMA.TABLES
Write-Output "Listing the tables in the database"
& sqlcmd -S $server -d $Database -G -P $tokenFile -Q "SELECT TABLE_NAME FROM [$Database].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"