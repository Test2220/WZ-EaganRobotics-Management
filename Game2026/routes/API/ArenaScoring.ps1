{
    #Mode should be fetched from the FMS - Auto, Teleop, or Endgame
    # $mode = Invoke-WebRequest -Uri $CheesyUrl/state/I/Made/This/Up
    
    # Testing code - set mode to Query option on url (http://.../:team:/:score?mode={choose}), default to "tele"
    $mode = $WebEvent.Query['mode']
    if (-not $mode){
        $mode = "tele"
    }

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