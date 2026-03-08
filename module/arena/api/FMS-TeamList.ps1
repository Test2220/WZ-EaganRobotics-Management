{
Lock-PodeObject -Name "FMSArenaStatusLock" -ScriptBlock {
    $arenaStatus = Get-PodeState -Name "FMSArenaStatus" |ConvertFrom-Json
    $pos = $WebEvent.Parameters['pos']
    try {
        $payload = $arenaStatus.data.AllianceStations.$pos.Team.Id
    }
    catch {
        $payload = "ERR"
    }
    Write-PodeTextResponse $payload

}
}