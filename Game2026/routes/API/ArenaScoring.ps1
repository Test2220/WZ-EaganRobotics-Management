{
    #Mode should be fetched from the FMS - Auto, Teleop, or Endgame
    # $mode = Invoke-WebRequest -Uri $CheesyUrl/state/I/Made/This/Up
    
    # Testing code - set mode to Query option on url (http://.../:team:/:score?mode={choose}), default to "tele"

    if ($webevent.method -eq "post") {
        $gametiming = get-content -Path ./Game2026/config/gametiming.json | ConvertFrom-Json
        Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
            $shifttiming = get-podestate -Name "Shifttiming"
            $pointState = Get-PodeState -Name "points" 
            $arenaGlobalState = get-podestate -name "ArenaOverride"
           
            $time = Get-PodeState -name "FMSArenatimer" | ConvertFrom-Json 
            if ($time.data.MatchState -eq 3) {
                $mode = "auto"
            }elseif (($time.data.MatchState -eq 5) -and($time.data.MatchTimeSec -lt 130)) {
                $mode = "tele"
            }elseif (($time.data.MatchState -eq 5) -and($time.data.MatchTimeSec -ge 130)) {
                $mode = "end"
            }elseif($arenaGlobalState.TestMode){
                $mode = "test"
            }
            else{

                $mode ="nonOps"
            }
            if ($WebEvent.Parameters['team'] -match "red"){
                if ($mode -match "auto") {
                    $pointState.RedAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    if (($shifttiming.shift1 -match "red") -and ((($gametiming.transtionshiftend + $gametiming.Pause) -le $time.data.MatchTimeSec )-and (($gametiming.endshift1 + $gametiming.pause) -gt $time.data.MatchTimeSec))) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift2 -match "red") -and ((($gametiming.endshift1 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift2 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift3 -match "red") -and ((($gametiming.endshift2 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift3 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift4 -match "red") -and ((($gametiming.endshift3 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift4 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }    
                }elseif($mode -match "end") {
                    $pointState.redend += $WebEvent.Parameters['score']
                }elseif($mode -match "test"){
                        $pointState.Redtele += $WebEvent.Parameters['score']
                }
            }elseif ($WebEvent.Parameters['team'] -match "blue") {
                if ($mode -match "auto") {
                    $pointState.BlueAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    if (($shifttiming.shift1 -match "red") -and ((($gametiming.transtionshiftend + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift1 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift2 -match "red") -and ((($gametiming.endshift1 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift2 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift3 -match "red") -and ((($gametiming.endshift2 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift3 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift4 -match "red") -and ((($gametiming.endshift3 + $gametiming.Pause) -le $time.data.MatchTimeSec ))-and (($gametiming.endshift4 + $gametiming.pause) -gt $time.data.MatchTimeSec)) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }    
                }elseif($mode -match "end") {
                    $pointState.BlueEnd += $WebEvent.Parameters['score']
                }elseif($mode -match "test"){
                        $pointState.Bluetele += $WebEvent.Parameters['score']
                }
            }
            $responseTable = @{ 'RedAuto' = $pointState.RedAuto;'blueauto' = $pointState.BlueAuto;'Redtele' = $pointState.RedTele;'bluetele' = $pointState.BlueTele;'redend' = $pointState.RedEnd;'blueend' = $pointState.BlueEnd; "MatchState"= $time.data.MatchState; "MatchTimeSec"=$time.data.MatchTimeSec;"Shift1"= $shifttiming.Shift1;"Shift2"= $shifttiming.Shift2;"Shift3"= $shifttiming.Shift3;"Shift4"= $shifttiming.Shift4;"mode"=$mode}

            Set-PodeState -Name "points" -Value $pointState
            Write-PodeJsonResponse $responseTable
        
        }
    }
    else{
            Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
            $pointState = Get-PodeState -Name "points" 
            Write-PodeJsonResponse $pointState
        } 
    }

}