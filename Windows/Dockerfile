# escape=`

# see https://hub.docker.com/r/microsoft/windows-servercore-iis
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

SHELL ["powershell", "-NoProfile -Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Remove-Item -Recurse C:\inetpub\wwwroot\*
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
	$items = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/go-sqlcmd/releases/latest'; `
    $downloadLink = $items.assets | Where-Object { $_.name -like '*-windows-amd64.zip' } | Select-Object -ExpandProperty browser_download_url; `
    $zipFile = Join-Path $env:TEMP 'sqlcmd-windows-amd64.zip'; `
    Invoke-WebRequest -Uri $downloadLink -OutFile (Join-Path $env:TEMP 'sqlcmd-windows-amd64.zip'); `
    New-Item -Type Directory 'C:\sqlcmd'; `
    Expand-Archive -Path $zipFile -DestinationPath 'C:\sqlcmd';

RUN setx /M PATH $($Env:PATH + ';C:\sqlcmd')

WORKDIR /
COPY Helper.ps1 .

WORKDIR /inetpub/wwwroot
COPY index.html .