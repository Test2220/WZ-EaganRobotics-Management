Import-Module -Name Pode -MaximumVersion 2.99.99
function out-TerminalLog {
    param (
        [string]$msg  
    )

    $date = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    Write-Host $date $msg 
}
$DebugPreference = 'Continue'
if(Test-Path -Path "./data/server.json"){
    Write-Debug "Getting Server Config"
    $serverSettings = Get-Content -Path "./data/server.json"  |ConvertFrom-Json
}else {
    Write-Debug "Writing Server.JSON"
    Write-Host "server config file created update config to new settings"
    '{"server":"localhost","FMS":"localhost","FMSConnect":true,"Music":false,"stacklight":false}'| Out-File -FilePath "./data/server.json" -Force
    exit 99 
}
    Write-Debug "Getting loading Server Config"
$podeServer = $serverSettings.server
$FMSAddress = $serverSettings.FMS #address to pull websocket for CA
 Write-Host "starting PODE Server"
Start-PodeServer -Threads 4 -EnablePool WebSockets -FilePath ".\WZ-Server-Core.ps1"

