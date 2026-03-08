{
    if ($webevent.method -eq "post") {
        Send-PodeWebSocket -Name "CA" -Message @{"type"="toggleBypass";"data"=$WebEvent.Parameters['pos']}
    }else{
        $arenaStatus = Get-PodeState -Name "FMSArenaStatus" |ConvertFrom-Json
        $pos = $WebEvent.Parameters['pos']
        $payload = $arenaStatus.data.AllianceStations.$pos.Bypass
        Write-PodeTextResponse $payload
        }
}