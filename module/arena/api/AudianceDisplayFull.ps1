{
    $responce = @{"matchID" = 0;"redscore" = 0;"bluescore" = 0; "b1"= 0;"b2"= 0;"b3"= 0;"r1"= 0;"r2"= 0;"r3"= 0;"matchtimer"=0;"RedAuto" = 0;"BlueAuto" = 0;"RedTele" = 0;"BlueTele" = 0;"RedEnd" = 0;"BlueEnd" = 0;"RedAutoL1" = 0;"RedTeleL1" = 0;"RedTeleL2" = 0;"RedTeleL3" = 0;"BlueAutoL1" = 0;"BlueTeleL1" = 0;"BlueTeleL2" = 0;"BlueTeleL3" = 0; "RedMinorFoul" = 0;"RedMajorFoul" = 0; "BlueMinorFoul"=0;"BlueMajorFoul" = 0; }
    $arenaStatus= (Get-PodeState -Name "FMSArenaStatus")
    if($null -eq $arenaStatus){

    }else{
        $arena = $arenaStatus | ConvertFrom-Json
    }
    $pointState = Get-PodeState -Name "points" 
    if ($null -eq $pointState){$pointState = @{ "RedAuto" = 0;"BlueAuto" = 0;"RedTele" = 0;"BlueTele" = 0;"RedEnd" = 0;"BlueEnd" = 0;"RedAutoL1" = 0;"RedTeleL1" = 0;
    "RedTeleL2" = 0;"RedTeleL3" = 0;"BlueAutoL1" = 0;"BlueTeleL1" = 0;"BlueTeleL2" = 0;"BlueTeleL3" = 0; "RedMinorFoul" = 0;"RedMajorFoul" = 0; "BlueMinorFoul"=0;"BlueMajorFoul" = 0; }}
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
    if(!($null -eq $arena.data.MatchId)){$responce.matchID = $arena.data.MatchId}
    if(!($null -eq $pointstate.RedAuto)){$responce.RedAuto = $pointstate.RedAuto}
    if(!($null -eq $pointstate.BlueAuto)){$responce.BlueAuto = $pointstate.BlueAuto}

    if(!($null -eq $pointstate.RedTele)){$responce.RedTele = $pointstate.RedTele}
    if(!($null -eq $pointstate.BlueTele)){$responce.BlueTele=$pointstate.BlueTele}

    if(!($null -eq $pointstate.RedEnd)){$responce.RedEnd = $pointstate.RedEnd}
    if(!($null -eq $pointstate.BlueEnd)){$responce.BlueEnd = $pointstate.BlueEnd}

    if(!($null -eq $pointstate.RedAutoL1)){$responce.RedAutoL1 = $pointstate.RedAutoL1}
    if(!($null -eq $pointstate.RedTeleL1)){$responce.RedTeleL1 = $pointstate.RedTeleL1}
    if(!($null -eq $pointstate.RedTeleL2)){$responce.RedTeleL2 = $pointstate.RedTeleL2}
    if(!($null -eq $pointstate.RedTeleL3)){$responce.RedTeleL3 = $pointstate.RedTeleL3}

    if(!($null -eq $pointstate.BlueAutoL1)){$responce.BlueAutoL1 = $pointstate.BlueAutoL1}
    if(!($null -eq $pointstate.BlueTeleL1)){$responce.BlueTeleL1 = $pointstate.BlueTeleL1}
    if(!($null -eq $pointstate.BlueTeleL2)){$responce.BlueTeleL2 = $pointstate.BlueTeleL2} 
    if(!($null -eq $pointstate.BlueTeleL3)){$responce.BlueTeleL3 = $pointstate.BlueTeleL3}

    
    if(!($null -eq $pointstate.RedMinorFoul)){$responce.RedMinorFoul = $pointstate.RedMinorFoul}
    if(!($null -eq $pointstate.BlueMinorFoul)){$responce.BlueMinorFoul = $pointstate.BlueMinorFoul}

    if(!($null -eq $pointstate.RedMajorFoul)){$responce.RedMajorFoul = $pointstate.RedMajorFoul} 
    if(!($null -eq $pointstate.BlueMajorFoul)){$responce.BlueMajorFoul = $pointstate.BlueMajorFoul}

    Write-PodeJsonResponse -Value $responce

}