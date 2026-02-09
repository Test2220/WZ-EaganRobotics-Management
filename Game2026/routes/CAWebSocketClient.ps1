{
        $gametiming = get-content -Path ./Game2026/config/gametiming.json | ConvertFrom-Json
        $WSJSONPacket = $WsEvent.Request.body| ConvertFrom-Json
        if($WSJSONPacket.type -match "arenastatus"){
            Write-Debug "ArenaStatus Obtained"
            Lock-PodeObject -Name 'FMSArenaStatusLock' -ScriptBlock{
            Set-PodeState -Name 'FMSArenaStatus' -Value $WsEvent.Request.body
            }
        }elseif ($WSJSONPacket.type -match "matchTiming") {
        Set-PodeState -Name 'FMSArenatimings' -Value $WsEvent.Request.body
       
        }elseif ($WSJSONPacket.type -match "ping") {
        Write-Debug "WSMadepingrequest"
        }elseif ($WSJSONPacket.type -match "matchTime") {
            Lock-PodeObject -Name 'FMSArenamatchtime' -ScriptBlock{
                $prevstate = get-podeState -Name 'FMSArenatimer' | ConvertFrom-Json

                if($prevstate.data.MatchState -ne $WSJSONPacket.data.MatchState){
                    if ($prevstate.data.MatchState -match "3" ) {
                        
                        $currentpoints = Get-PodeState -Name "points"
                        if (($currentpoints.RedAuto) -gt ($currentpoints.blueAuto)) {
                            write-host "red is leading setting leader to red"
                            $Fuelleader ="red"
                            $FuelRunnerup = "blue"
                        }elseif (($currentpoints.RedAuto) -lt ($currentpoints.BlueAuto)) {
                            write-host "red is leading setting leader to red"
                            $Fuelleader = "blue"
                            $FuelRunnerup = "red"
                        }else{
                            $coinflip = Get-Random -Maximum 1 -Minimum 0
                            if ($coinflip -eq 0) {
                                $Fuelleader = "red"
                                $FuelRunnerup = "blue"
                            }
                            if ($coinflip -eq 1) {
                                $Fuelleader = "blue"
                                $FuelRunnerup = "red"
                            }
                            write-host "FMS Desides $team"
                        }
                        Set-PodeState -Name "Shifttiming"-Value @{"shift1"=$FuelRunnerup;"shift2"=$Fuelleader;"shift3"=$FuelRunnerup;"shift4"=$Fuelleader;}
                        Set-PodeState -Name 'FMSArenatimer' -Value "$WsEvent.Request.body"
                    }

                    $StackConfigData = Get-PodeState -Name "StackConfig"
                    $shifttiming = get-podestate -Name "Shifttiming"
                    $StackState = Get-PodeState -name "StackState"
                    #from Start of match to the transtion end
                    if ((($WSJSONPacket.data.MatchTimeSec -GT 0)) -and (($WSJSONPacket.data.MatchTimeSec -lT $gametiming.transtionshiftend)+ $PauseShift)) { 
                        if($StackState.HubRed -notmatch "on"){
                            $StackState.HubRed = "on"
                            #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/"+$StackState.HubRed
                            #Code to enable both hubs for auto
                        }
                        if($StackState.HubBlue -notmatch "on"){
                            $StackState.HubBlue = "on"
                            #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                            #Code to enable both hubs for auto
                        }
                    }
                    #end of from Start
                    #from Transtionend to 3 second before end of first Shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.transtionshiftend+$PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift1 + $PauseShift - 3))) {
                        if ($shifttiming.shift1 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift1 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }

                    #end of block
                    #3 Second before End First Shift to end of first shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift1 + $PauseShift - 3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift1 + $PauseShift))) {
                        if ($shifttiming.shift1 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift1 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End First Shift to  three sec before end of 2nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift1 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2 + $PauseShift -3))) {
                        if ($shifttiming.shift2 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift2 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }#3 Second before End of 2nd Shift to end of 2nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2 + $PauseShift - 3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2 + $PauseShift))) {
                        if ($shifttiming.shift2 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift2 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End 2rd Shift to  three sec before end of 3nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3 + $PauseShift -3))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }#3 Second before End 3rd Shift to end of 3rd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3 + $PauseShift - 3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3 + $PauseShift))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End 3rd Shift to  4th shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift4 + $PauseShift))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/" + $StackState.HubRed
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift4 + $PauseShift))) {
                        if($StackState.HubRed -notmatch "on"){
                            $StackState.HubRed = "on"
                            #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$RedHubPin+"/"+$StackState.HubRed
                            #Code to enable both hubs for auto
                        }
                        if($StackState.HubBlue -notmatch "on"){
                            $StackState.HubBlue = "on"
                            #Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+"/set/"+$BlueHubPin+"/"+ $StackState.HubBlue
                            #Code to enable both hubs for auto
                        }
                        
                    }
                    if ($WSJSONPacket.data.MatchState -eq "0") {
                        if ($prevstate.data.MatchState -eq  "6"){
                            Set-PodeState -Name 'points' -Value @{ 'RedAuto' = 0;'blueauto' = 0;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; } | Out-Null
                        }
                        $newstate = "PreMatch"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "1") {
                        $newstate = "StartMatch"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "2") {
                        $newstate = "WarmupPeriod"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "3") {
                        $newstate = "AutoPeriod"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "4") {
                        $newstate = "PausePeriod"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "5") {
                        $newstate = "TeleopPeriod"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "6") {
                        $newstate = "PostMatch"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "7") {
                        $newstate = "TimeoutActive"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "8") {
                        $newstate = "PostTimeout"
                    }
                    
                    Write-host "transtion to $newstate"
                }
                Set-PodeState -Name 'FMSArenatimer' -Value $WsEvent.Request.body
            }

            if (($WSJSONPacket.data.MatchTimeSec -eq 0)-and ($WSJSONPacket.data.MatchState -gt 0)) {
                write-debug "triger Sound Start"
                        Send-PodeSignal -Value @{"type"="playaudio";"data"="start.wav"}
            }
            if($WSJSONPacket.data.MatchTimeSec -eq (20)){
                write-debug "triger Sound end"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="end.wav"}
            }
            if($WSJSONPacket.data.MatchTimeSec -eq (20 + $gametiming.Pause)){
                    write-debug "triger Sound resume"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="resume.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq $gametiming.endshift1){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq $gametiming.endshift2){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq $gametiming.endshift3){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq $gametiming.endshift4){
                write-debug "triger Sound warning"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="warning.wav"}
            }if($WSJSONPacket.data.MatchState -eq 6){
                write-debug "triger Sound end"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="end.wav"}
            }
            $timer = $WSJSONPacket.data.MatchTimeSec
            Write-host  "match time is $timer"
       }
       else {
        write-host $WSJSONPacket.type
       }
       
}