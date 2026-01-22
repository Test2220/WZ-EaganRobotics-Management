{
            if ($webevent.method -eq "post") {
                Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
                    $pointState = Get-PodeState -Name "points" 
                    if ($WebEvent.Parameters['team'] -match "red"){
                        if ($WebEvent.Parameters['mode']-match "auto") {
                            $pointState.RedAuto + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "tele") {
                            $pointState.Redtele + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "end") {
                            $pointState.redend + $WebEvent.Parameters['score']
                        }
                    }elseif ($WebEvent.Parameters['team'] -match "blue") {
                        if ($WebEvent.Parameters['mode']-match "auto") {
                            $pointState.BlueAuto + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "tele") {
                            $pointState.BlueTele + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "end") {
                            $pointState.BlueEnd + $WebEvent.Parameters['score']
                        }
                    }
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                 Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
                    $pointState = Get-PodeState -Name "points" 
                                        if ($WebEvent.Parameters['team'] -match "red"){
                        if ($WebEvent.Parameters['mode']-match "auto") {
                            $pointState.RedAuto + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "tele") {
                            $pointState.Redtele + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "end") {
                            $pointState.redend + $WebEvent.Parameters['score']
                        }
                    }elseif ($WebEvent.Parameters['team'] -match "blue") {
                        if ($WebEvent.Parameters['mode']-match "auto") {
                            $pointState.BlueAuto + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "tele") {
                            $pointState.BlueTele + $WebEvent.Parameters['score']
                        }elseif($WebEvent.Parameters['mode']-match "end") {
                            $pointState.BlueEnd + $WebEvent.Parameters['score']
                        }
                    }
                    
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                } 
            }

}