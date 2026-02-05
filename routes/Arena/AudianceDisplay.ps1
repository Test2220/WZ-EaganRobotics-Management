
{
    Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
    $responseJSON = @{"redscore" = 0;"bluescore" = 0; "team1" = 0;"team2" = 0;"team3" = 0;"team4" = 0;"team5" = 0;"team6" = 0;"timer"=0}
    $pointState = Get-PodeState -Name "points" 
    if ($pointState.redAutoL1 -ge 2) {
        $pointState.redAutoL1 = 2
    }
    if ($pointState.BluedAutoL1 -ge 2) {
        $pointState.BlueAutoL1 = 2
    }
    $arenastate = Get-PodeState -Name "FMSArenaStatus"
    $arenatime = get-podestate -name "FMSArenamatchtime"
    $responseJSON.redscore = ($pointState.RedAuto) + ($pointState.Redtele) + ($pointState.redend) +($pointState.RedAutoL1 * 15) + ($pointState.redTeleL1 * 10) + ($pointState.redTeleL2 * 20) + ($pointState.redTeleL3 * 30) + ($pointState.blueMinorFoul *5) +($pointState.blueMajorFoul * 15)
    $responseJSON.bluescore = ($pointState.blueAuto) + ($pointState.bluetele) + ($pointState.blueend) +($pointState.blueAutoL1 * 15) + ($pointState.blueTeleL1 * 10) + ($pointState.blueTeleL2 * 20) + ($pointState.blueTeleL3 * 30) + ($pointState.redMinorFoul *5) +($pointState.redMajorFoul * 15)
    $responseJSON.team1 =$arenastate.data.AllianceStations.B1.team
    $responseJSON.team2 =$arenastate.data.AllianceStations.B2.team
    $responseJSON.team3 =$arenastate.data.AllianceStations.B3.team
    $responseJSON.team4 =$arenastate.data.AllianceStations.r1.team
    $responseJSON.team5 =$arenastate.data.AllianceStations.r1.team
    $responseJSON.team6 =$arenastate.data.AllianceStations.r1.team
    $responseJSON.timer = $arenatime.data.MatchTimeSec
    Write-PodeJsonResponse $responseJSON
    }

}
