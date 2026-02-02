{
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
                    if ($WSJSONPacket.data.MatchState -eq "0") {
                        if ($prevstate.data.MatchState -eq  "3"){
                            Set-PodeState -Name 'points' -Value @{ 'RedAuto' = $randomred;'blueauto' = $randomblue;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; } | Out-Null
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
            $timer = $WSJSONPacket.data.MatchTimeSec
            Write-host  "match time is $timer"
       }
       else {
        write-host $WSJSONPacket.type
       }
       
}