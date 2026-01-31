{
    #Mode should be fetched from the FMS - Auto, Teleop, or Endgame
    $mode = $WebEvent.Parameters['mode']
    # $mode = Invoke-WebRequest -Uri $CheesyUrl/state/I/Made/This/Up
    if ($webevent.method -eq "post") {
        Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
            $pointState = Get-PodeState -Name "points" 
            if ($WebEvent.Parameters['team'] -match "red"){
                if ($mode -match "auto") {
                    $pointState.RedAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    $pointState.Redtele += $WebEvent.Parameters['score']
                }elseif($mode -match "end") {
                    $pointState.redend += $WebEvent.Parameters['score']
                }
            }elseif ($WebEvent.Parameters['team'] -match "blue") {
                if ($mode -match "auto") {
                    $pointState.BlueAuto += $WebEvent.Parameters['score']
                }elseif($mode -match "tele") {
                    $pointState.BlueTele += $WebEvent.Parameters['score']
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