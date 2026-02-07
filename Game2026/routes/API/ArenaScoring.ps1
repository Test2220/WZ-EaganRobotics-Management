{
    #Mode should be fetched from the FMS - Auto, Teleop, or Endgame
    # $mode = Invoke-WebRequest -Uri $CheesyUrl/state/I/Made/This/Up
    
    # Testing code - set mode to Query option on url (http://.../:team:/:score?mode={choose}), default to "tele"
  
    $mode = $WebEvent.Query['mode']
    if (-not $mode){
        $mode = "tele"
    }

    if ($webevent.method -eq "post") {
        $gametiming = get-content -Path ./Game2026/config/gametiming.json | ConvertFrom-Json
        Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
            $shifttiming = get-podestate -Name "Shifttiming"
            $pointState = Get-PodeState -Name "points" 
            $time = Get-PodeState -name "FMSArenaMatchTime"
            if ($WebEvent.Parameters['team'] -match "red"){
                if ($mode -match "auto") {
                    $pointState.RedAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    if (($shifttiming.shift1 -match "red") -and (($gametiming.shift1 -le $time.data.MatchTimeSec )-and ($gametiming.shift1 -gt $time.data.MatchTimeSec))) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift2 -match "red") -and (($gametiming.shift2 -le $time.data.MatchTimeSec )-and ($gametiming.shift2 -gt $time.data.MatchTimeSec))) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift3 -match "red") -and (($gametiming.shift3 -le $time.data.MatchTimeSec )-and ($gametiming.shift3 -gt $time.data.MatchTimeSec))) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift4 -match "red") -and (($gametiming.shift4 -le $time.data.MatchTimeSec )-and ($gametiming.shift4 -gt $time.data.MatchTimeSec))) {
                        $pointState.Redtele += $WebEvent.Parameters['score']
                    }    
                }elseif($mode -match "end") {
                    $pointState.redend += $WebEvent.Parameters['score']
                }
            }elseif ($WebEvent.Parameters['team'] -match "blue") {
                if ($mode -match "auto") {
                    $pointState.BlueAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    if (($shifttiming.shift1 -match "red") -and (($gametiming.shift1 -le $time.data.MatchTimeSec )-and ($gametiming.shift1 -gt $time.data.MatchTimeSec))) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift2 -match "red") -and (($gametiming.shift2 -le $time.data.MatchTimeSec )-and ($gametiming.shift2 -gt $time.data.MatchTimeSec))) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift3 -match "red") -and (($gametiming.shift3 -le $time.data.MatchTimeSec )-and ($gametiming.shift3 -gt $time.data.MatchTimeSec))) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }elseif (($shifttiming.shift4 -match "red") -and (($gametiming.shift4 -le $time.data.MatchTimeSec )-and ($gametiming.shift4 -gt $time.data.MatchTimeSec))) {
                        $pointState.BlueTele += $WebEvent.Parameters['score']
                    }    
                }elseif($mode -match "end") {
                    $pointState.BlueEnd += $WebEvent.Parameters['score']
                }
            }
            Set-PodeState -Name "points" -Value $pointState
            Write-PodeJsonResponse $pointState
        }
        
    }else{
            Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
            $pointState = Get-PodeState -Name "points" 
            Write-PodeJsonResponse $pointState
        } 
    }

}