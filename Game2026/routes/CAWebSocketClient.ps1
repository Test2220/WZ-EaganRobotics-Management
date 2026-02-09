{
        $gametiming = get-content -Path ./Game2026/config/gametiming.json | ConvertFrom-Json
        $WSJSONPacket = $WsEvent.Request.body| ConvertFrom-Json
        if($WSJSONPacket.type -match "arenastatus"){
            Write-Debug "ArenaStatus Obtained"
            Lock-PodeObject -Name 'FMSArenaStatusLock' -ScriptBlock{
            Set-PodeState -Name 'FMSArenaStatus' -Value $WsEvent.Request.body
            }
            Lock-PodeObject -Name "StackConfig" -ScriptBlock{
                $StackConfigData = Get-PodeState -Name "StackConfig"
                if($null -eq $StackConfigData.MiddleStack){
                    $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json
                }
                $StackState = Get-PodeState -name "StackState"
                $FieldteamStatus = @{"B1"=$false;"B2"=$false;"B3"=$false;"R1"=$false;"R2"=$false;"R3"=$false;}
                #check for blue 1 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.B1.DSConn) -and ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $true)){
                    if ($StackState.B1 -notmatch "off") {
                        $StackState.B1 = "off"
                        $FieldteamStatus.B1 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/1/"+$StackState.B1 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B1.DSConn) -or ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $false)){
                    if ($StackState.B1 -notmatch "blink") {
                        $StackState.B1 = "blink"
                        $FieldteamStatus.B1 = $false
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/1/"+$StackState.B1 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B1.DSConn) -and ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $true))){
                    if ($StackState.B1 -notmatch "on") {
                        $StackState.B1 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/1/"+$StackState.B1 -SkipHttpErrorCheck
                    }
                }
                #check for blue 2 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.B2.DSConn) -and ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $true)){
                    if ($StackState.B2 -notmatch "off") {
                        $StackState.B2 = "off"
                        $FieldteamStatus.B2 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/2/"+$StackState.B2 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B2.DSConn) -or ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $false)){
                    if ($StackState.B2 -notmatch "blink") {
                        $StackState.B2 = "blink"
                        $FieldteamStatus.B2 = $false
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/2/"+$StackState.B2 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B2.DSConn) -and ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $true))){
                    if ($StackState.B2 -notmatch "on") {
                        $StackState.B2 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/2/"+$StackState.B2 -SkipHttpErrorCheck
                    }
                }
                #check for blue 3 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.B3.DSConn) -and ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $true)){
                    if ($StackState.B3 -notmatch "off") {
                        $StackState.B3 = "off"
                        $FieldteamStatus.B3 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/3/"+$StackState.B3 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B3.DSConn) -or ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $false)){
                    if ($StackState.B3 -notmatch "blink") {
                        $StackState.B3 = "blink"
                        $FieldteamStatus.B3 = $false
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/3/"+$StackState.B3 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B3.DSConn) -and ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $true))){
                    if ($StackState.B3 -notmatch "on") {
                        $StackState.B3 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCC +"/set/3/"+$StackState.B3 -SkipHttpErrorCheck
                    }
                }


                #check for Red 1 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.R1.DSConn) -and ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $true)){
                    if ($StackState.R1 -notmatch "off") {
                        $StackState.R1 = "off"
                        $FieldteamStatus.R1 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/1/"+$StackState.R1 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R1.DSConn) -or ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $false)){
                    if ($StackState.R1 -notmatch "blink") {
                        $StackState.R1 = "blink"
                        $FieldteamStatus.R1 = $false
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/1/"+$StackState.R1 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R1.DSConn) -and ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $true))){
                    if ($StackState.R1 -notmatch "on") {
                        $StackState.R1 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/1/"+$StackState.R1 -SkipHttpErrorCheck
                    }
                }
                #check for Red 2 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.R2.DSConn) -and ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $true)){
                    if ($StackState.R2 -notmatch "off") {
                        $StackState.R2 = "off"
                        $FieldteamStatus.R2 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/2/"+$StackState.R2 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R2.DSConn) -or ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $false)){
                    if ($StackState.R2 -notmatch "blink") {
                        $StackState.R2 = "blink"
                        $FieldteamStatus.R2 = $false 
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/2/"+$StackState.R2 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R2.DSConn) -and ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $true))){
                    if ($StackState.R2 -notmatch "on") {
                        $StackState.R2 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/2/"+$StackState.R2 -SkipHttpErrorCheck
                    }
                }
                #check for red 3 ready Status
                if (($null -ne $WSJSONPacket.data.AllianceStations.R3.DSConn) -and ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $true)){
                    if ($StackState.R3 -notmatch "off") {
                        $StackState.R3 = "off"
                        $FieldteamStatus.R3 = $true
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/3/"+$StackState.R3 -SkipHttpErrorCheck
                    }
                }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R3.DSConn) -or ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $false)){
                    if ($StackState.R3 -notmatch "blink") {
                        $StackState.R3 = "blink"
                        $FieldteamStatus.R3 = $false
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/3/"+$StackState.R3 -SkipHttpErrorCheck
                    }
                }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R3.DSConn) -and ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $true))){
                    if ($StackState.R3 -notmatch "on") {
                        $StackState.R3 = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCC +"/set/3/"+$StackState.R3 -SkipHttpErrorCheck
                    }
                }
                if (($WSJSONPacket.data.CanStartMatch -eq $true)) {
                    if ($StackState.Cgreen -notmatch "blink") {
                        $StackState.Cgreen = "blink"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/1/"+$StackState.Cgreen -SkipHttpErrorCheck  #get Green Pin ID
                    }
                }elseif ($WSJSONPacket.data.CanStartMatch -eq $false) {
                    if ($StackState.Cgreen -notmatch "off") {
                        $StackState.Cgreen = "off"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/1/"+$StackState.Cgreen -SkipHttpErrorCheck  #get Green Pin ID
                    }
                }elseif (($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6)) {
                    if ($StackState.Cgreen -notmatch "on") {
                        $StackState.Cgreen = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/1/"+$StackState.Cgreen -SkipHttpErrorCheck  #get Green Pin ID
                    }
                }
                        $FieldteamStatus.R2 = $true
                if ($FieldteamStatus.R1 -and $FieldteamStatus.R2 - $FieldteamStatus.R2) {
                    if ($StackState.Cred -notmatch "on") {
                        $StackState.CRed = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/2/"+$StackState.Cred -SkipHttpErrorCheck  #get red Pin ID
                    }
                }else {
                    if ($StackState.Cred -notmatch "off") {
                        $StackState.CRed = "off"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/2/"+$StackState.Cred -SkipHttpErrorCheck  #get red Pin ID
                    }
                }

                if ($FieldteamStatus.B1 -and $FieldteamStatus.B2 - $FieldteamStatus.B2) {
                    if ($StackState.Cblue -notmatch "on") {
                        $StackState.Cblue = "on"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/3/"+$StackState.Cblue -SkipHttpErrorCheck  #get Blue Pin ID
                    }
                }else {
                    if ($StackState.Cred -notmatch "off") {
                        $StackState.CRed = "off"
                        Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/3/"+$StackState.Cblue -SkipHttpErrorCheck  #get blue Pin ID
                    }
                }
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
                    if($null -eq $StackConfigData.MiddleStack){
                        $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json
                    }
                    $shifttiming = get-podestate -Name "Shifttiming"
                    $StackState = Get-PodeState -name "StackState"
                    #from Start of match to the transtion end
                    if ((($WSJSONPacket.data.MatchTimeSec -GT 0)) -and (($WSJSONPacket.data.MatchTimeSec -lT $gametiming.transtionshiftend)+ $PauseShift)) { 
                        if($StackState.HubRed -notmatch "on"){
                            $StackState.HubRed = "on"
                            Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                            
                            #Code to enable both hubs for auto
                        }
                        if($StackState.HubBlue -notmatch "on"){
                            $StackState.HubBlue = "on"
                            Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                            #Code to enable both hubs for auto
                        }
                    }
                    #end of from Start
                    #from Transtionend to 3 second before end of first Shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.transtionshiftend+$PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift1 + $PauseShift - 3))) {
                        if ($shifttiming.shift1 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift1 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
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
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift1 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End First Shift to  three sec before end of 2nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift1 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2 + $PauseShift -3))) {
                        if ($shifttiming.shift2 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift2 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }#3 Second before End of 2nd Shift to end of 2nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2 + $PauseShift - 3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2 + $PauseShift))) {
                        if ($shifttiming.shift2 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift2 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End 2rd Shift to  three sec before end of 3nd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3 + $PauseShift -3))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }#3 Second before End 3rd Shift to end of 3rd shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3 + $PauseShift - 3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3 + $PauseShift))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "blink"){
                                $StackState.HubBlue = "blink"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "blink"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }# End 3rd Shift to  4th shift
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3 + $PauseShift)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift4 + $PauseShift))) {
                        if ($shifttiming.shift3 -match "blue"){
                            if($StackState.HubRed -notmatch "off"){
                                $StackState.HubRed = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "on"){
                                $StackState.HubBlue = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable Blue hubs for shift1
                                
                            }
                        }if ($shifttiming.shift3 -match "red"){
                            if($StackState.HubRed -notmatch "on"){
                                $StackState.Hubred = "on"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to enable red hubs for shift1
                                
                            }
                            if($StackState.HubBlue -notmatch "off"){
                                $StackState.HubBlue = "off"
                                Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                                #Code to disable Blue hubs for shift1
                                
                            }
                        }
                        
                    }
                    if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift4 + $PauseShift))) {
                        if($StackState.HubRed -notmatch "on"){
                            $StackState.HubRed = "on"
                            Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/"+$StackState.HubRed -SkipHttpErrorCheck
                            #Code to enable both hubs for auto
                        }
                        if($StackState.HubBlue -notmatch "on"){
                            $StackState.HubBlue = "on"
                            Invoke-RestMethod -uri "http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/"+$StackState.HubRed -SkipHttpErrorCheck
                            #Code to enable both hubs for auto
                        }
                        
                    }
                    Set-PodeState -Name "StackConfig" -Value $StackState

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
                    
                    Write-Debug "transtion to $newstate"
                }
                Set-PodeState -Name 'FMSArenatimer' -Value $WsEvent.Request.body
            }

            if (($WSJSONPacket.data.MatchTimeSec -eq 0)-and (($WSJSONPacket.data.MatchState -eq 3) )) {
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
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.transtionshiftend +$gametiming.Pause)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }
            if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift1 +$gametiming.Pause)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift2+$gametiming.Pause)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift3+$gametiming.Pause)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift4+$gametiming.Pause)){
                write-debug "triger Sound warning"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="warning.wav"}
            }if($WSJSONPacket.data.MatchState -eq 6){
                write-debug "triger Sound end"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="end.wav"} 
            }
            $timer = $WSJSONPacket.data.MatchTimeSec
            Write-debug  "match time is $timer"
       }
       else {
        write-host $WSJSONPacket.type
       }
       
}