servername="$1"
database="$2"
client_id="$3"
if [ -z "$client_id" ]; then
    # using System Identity
    accessToken=$(curl --silent --location --request GET ''"$IDENTITY_ENDPOINT"'?resource=https://database.windows.net&api-version=2019-08-01' --header 'X-IDENTITY-HEADER: '"$IDENTITY_HEADER"'' | jq --raw-output '.access_token' )
else
    # using User Identity
    accessToken=$(curl --silent --location --request GET ''"$IDENTITY_ENDPOINT"'?resource=https://database.windows.net&api-version=2019-08-01&client_id='"$client_id"'' --header 'X-IDENTITY-HEADER: '"$IDENTITY_HEADER"'' | grep -Po '"access_token":"\K[^"]*' )
fi

echo $accessToken
echo $accessToken | tr -d '\n' | iconv -f ascii -t UTF-16LE > tokenfile
sqlcmd -S "$servername.database.windows.net" -d "$database" -G -P tokenfile -Q "SELECT @@servername"
sqlcmd -S "$servername.database.windows.net" -d "$database" -G -P tokenfile -Q "SELECT TABLE_NAME FROM [$database].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"