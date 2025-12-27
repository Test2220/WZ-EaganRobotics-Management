{
            if ($webevent.method -eq "post") {
                Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
                    $pointState = Get-PodeState -Name "points" 
                    if ($WebEvent.Parameters['team'] -match "red"){
                        $pointState.RedAuto + $WebEvent.Parameters['score']
                    }elseif ($WebEvent.Parameters['team'] -match "blue") {
                        $pointState.BlueAuto + $WebEvent.Parameters['score']
                    }
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                 Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
                    $pointState = Get-PodeState -Name "points" 
                    if ($WebEvent.Parameters['team'] -match "red"){
                        $pointState.RedAuto + $WebEvent.Parameters['score']
                    }elseif ($WebEvent.Parameters['team'] -match "blue") {
                        $pointState.BlueAuto + $WebEvent.Parameters['score']
                    }
                    
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                } 
            }

}