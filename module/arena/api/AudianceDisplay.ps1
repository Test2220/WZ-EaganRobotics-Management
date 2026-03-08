{
    $responce = @{"redscore" = 0;"bluescore" = 0; "b1"= 0;"b2"= 0;"b3"= 0;"r1"= 0;"r2"= 0;"r3"= 0;"matchtimer"=0}
    $arenaStatus= (Get-PodeState -Name "FMSArenaStatus")
    if($null -eq $arenaStatus){
    }else{
        $arena = $arenaStatus | ConvertFrom-Json
    }
    $pointState = Get-PodeState -Name "points" 
    if ($null -eq $pointState){$pointState = @{ 'RedAuto' = 0;'blueauto' = 0;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; }}
    if ($pointState.redAutoL1 -ge 2) {
        $pointState.redAutoL1 = 2
    }
    if ($pointState.BluedAutoL1 -ge 2) {
        $pointState.BlueAutoL1 = 2
    }
    $responce.redscore = ($pointState.RedAuto) + ($pointState.Redtele) + ($pointState.redend) +($pointState.RedAutoL1 * 15) + ($pointState.redTeleL1 * 10) + ($pointState.redTeleL2 * 20) + ($pointState.redTeleL3 * 30) + ($pointState.blueMinorFoul *5) +($pointState.blueMajorFoul * 15)
    $responce.bluescore = ($pointState.blueAuto) + ($pointState.bluetele) + ($pointState.blueend) +($pointState.blueAutoL1 * 15) + ($pointState.blueTeleL1 * 10) + ($pointState.blueTeleL2 * 20) + ($pointState.blueTeleL3 * 30) + ($pointState.redMinorFoul *5) +($pointState.redMajorFoul * 15)
    if($null -ne $arena.data.AllianceStations.B1.Team.Id){
        $responce.b1 = $arena.data.AllianceStations.B1.Team.Id
    }else {
        $responce.b1 = "0000"
    }if($null -ne $arena.data.AllianceStations.B2.Team.Id){
        $responce.b2 = $arena.data.AllianceStations.B2.Team.Id
    }else {
        $responce.b2 = "0000"
    }if($null -ne $arena.data.AllianceStations.B3.Team.Id){
        $responce.b3 = $arena.data.AllianceStations.B3.Team.Id
    }else {
        $responce.b3 = "0000"
    }
    if($null -ne $arena.data.AllianceStations.R1.Team.Id){
        $responce.r1 = $arena.data.AllianceStations.R1.Team.Id
    }else {
        $responce.r1 = "0000"
    }if($null -ne $arena.data.AllianceStations.R2.Team.Id){
        $responce.r2 = $arena.data.AllianceStations.r2.Team.Id
    }else {
        $responce.r2 = "0000"
    }if($null -ne $arena.data.AllianceStations.R3.Team.Id){
        $responce.r3 = $arena.data.AllianceStations.R3.Team.Id
    }else {
        $responce.r3 = "0000"
    }
    $timeing = ConvertFrom-Json (get-podestate -name "FMSArenatimer")
    if($timeing.data.MatchState -eq 6){
        $responce.matchtimer = 160
    }else{
        if($timeing.data.MatchTimeSec -ge 23){
            $responce.matchtimer = $timeing.data.MatchTimeSec -3
        }elseif (($timeing.data.MatchTimeSec -lt 23) -and ($timeing.data.MatchTimeSec -gt 20)){
            $responce.matchtimer = 20
        }else{
        $responce.matchtimer = $timeing.data.MatchTimeSec
    }
    }
    Write-PodeJsonResponse -Value $responce

}