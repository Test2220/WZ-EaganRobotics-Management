{
        $gametiming = get-content -Path ./Game2026/config/gametiming.json | ConvertFrom-Json
        $WSJSONPacket = $WsEvent.Request.body| ConvertFrom-Json
        if($WSJSONPacket.type -match "arenastatus"){
            Write-Debug "ArenaStatus Obtained"
            Lock-PodeObject -Name 'FMSArenaStatusLock' -ScriptBlock{
            Set-PodeState -Name 'FMSArenaStatus' -Value $WsEvent.Request.body
            }
#            $serverstate = Get-Content -path "./data/server.json"  | ConvertFrom-Json
            if ($true) {            
                Lock-PodeObject -Name "StackConfig" -ScriptBlock{
                    
                    $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json
                    $StackStateRedIP = $StackConfigData.RedSCC
                    $StackStateBlueIP = $StackConfigData.BlueSCC
                    $StackStateMiddleIP = $StackConfigData.MiddleStack
                    $StackStateRed =Invoke-RestMethod -Uri "http://$StackStateRedIP/state"
                    $StackStateBlue =Invoke-RestMethod -Uri "http://$StackStateBlueIP/state"
                    $StackStateMiddle =Invoke-RestMethod -Uri "http://$StackStateMiddleIP/state"

                    

                    $FieldteamStatus = @{"B1"=$false;"B2"=$false;"B3"=$false;"R1"=$false;"R2"=$false;"R3"=$false;}
                    #check for blue 1 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.B1.DSConn) -and ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $true)){
                        if ($StackStateBlue.mappings.ds_1 -notmatch "off") {
                            $FieldteamStatus.B1 = $true
                            $url = "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/1/off"
                            Invoke-RestMethod -uri $url -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B1.DSConn) -or ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $false)){
                        if ($StackStateBlue.mappings.ds_1 -notmatch "blink") {
                            $FieldteamStatus.B1 = $false
                            $url = "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/1/blink"
                            Invoke-RestMethod -uri $url -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B1.DSConn) -and ($WSJSONPacket.data.AllianceStations.B1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B1.Bypass -eq $true))){
                        if ($StackStateBlue.mappings.ds_1 -notmatch "on") {
                            $url = "http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/1/on"
                            Invoke-RestMethod -uri $url -Method Post
                        }
                    }
                    #check for blue 2 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.B2.DSConn) -and ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $true)){
                        if ($StackStateBlue.mappings.ds_2 -notmatch "off") {
                            $FieldteamStatus.B2 = $true
                            Invoke-RestMethod -uri (("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/2/off")) -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B2.DSConn) -or ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $false)){
                        if ($StackStateBlue.mappings.ds_2 -notmatch "blink") {
                            $FieldteamStatus.B2 = $false
                            Invoke-RestMethod -uri (("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/2/blink")) -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B2.DSConn) -and ($WSJSONPacket.data.AllianceStations.B2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B2.Bypass -eq $true))){
                        if ($StackStateBlue.mappings.ds_2 -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/2/on") -Method Post
                        }
                    }
                    #check for blue 3 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.B3.DSConn) -and ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $true)){
                        if ($StackStateBlue.mappings.ds_3 -notmatch "off") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/3/off") -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.B3.DSConn) -or ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $false)){
                        if ($StackStateBlue.mappings.ds_3 -notmatch "blink") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/3/blink") -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.B3.DSConn) -and ($WSJSONPacket.data.AllianceStations.B3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.B3.Bypass -eq $true))){
                        if ($StackStateBlue.mappings.ds_3 -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.BlueSCC+":"+$StackConfigData.BlueSCCPort +"/set/3/on") -Method Post
                        }
                    }


                    #check for Red 1 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.R1.DSConn) -and ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $true)){
                        if ($StackStateRed.mappings.ds_1 -notmatch "off") {
                            $FieldteamStatus.R1 = $true
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/1/off") -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R1.DSConn) -or ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $false)){
                        if ($StackStateRed.mappings.ds_1 -notmatch "blink") {
                            $FieldteamStatus.R1 = $false
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/1/blink") -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R1.DSConn) -and ($WSJSONPacket.data.AllianceStations.R1.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R1.Bypass -eq $true))){
                        if ($StackStateRed.mappings.ds_1 -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/1/on") -Method Post
                        }
                    }
                    #check for Red 2 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.R2.DSConn) -and ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $true)){
                        if ($StackStateRed.mappings.ds_2 -notmatch "off") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/2/off") -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R2.DSConn) -or ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $false)){
                        if ($StackStateRed.mappings.ds_2 -notmatch "blink") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/2/blink") -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R2.DSConn) -and ($WSJSONPacket.data.AllianceStations.R2.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R2.Bypass -eq $true))){
                        if ($StackStateRed.mappings.ds_2 -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/2/on") -Method Post
                        }
                    }
                    #check for red 3 ready Status
                    if (($null -ne $WSJSONPacket.data.AllianceStations.R3.DSConn) -and ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $true)){
                        if ($StackStateRed.mappings.ds_3 -notmatch "off") {
                            $FieldteamStatus.R3 = $true
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/3/off") -Method Post
                        }
                    }elseif (($null -eq $WSJSONPacket.data.AllianceStations.R3.DSConn) -or ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $false) -or ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $false) -or ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $false) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $false)){
                        if ($StackStateRed.mappings.ds_3 -notmatch "blink") {
                            $FieldteamStatus.R3 = $false
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/3/blink") -Method Post
                        }
                    }elseif ((($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6))-and (($null -ne $WSJSONPacket.data.AllianceStations.R3.DSConn) -and ($WSJSONPacket.data.AllianceStations.R3.Ethernet -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Astop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Estop -eq $true) -and ($WSJSONPacket.data.AllianceStations.R3.Bypass -eq $true))){
                        if ($StackStateRed.mappings.ds_3 -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.RedSCC+":"+$StackConfigData.RedSCCPort +"/set/3/on") -Method Post
                        }
                    }
                    if (($WSJSONPacket.data.CanStartMatch -eq $true)) {
                        if ($StackStateMiddle.mappings.stack_green -notmatch "blink") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/5/blink") -Method Post  #get Green Pin ID
                        }
                    }elseif ($WSJSONPacket.data.CanStartMatch -eq $false) {
                        if ($StackStateMiddle.mappings.stack_green -notmatch "off") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/5/off") -Method Post  #get Green Pin ID
                        }
                    }elseif (($WSJSONPacket.data.MatchState -gt 0)-and ($WSJSONPacket.data.MatchState -lt 6)) {
                        if ($StackStateMiddle.mappings.stack_green -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/5/on") -Method Post #get Green Pin ID
                        }
                    }
                            $FieldteamStatus.R2 = $true
                    if ($FieldteamStatus.R1 -and $FieldteamStatus.R2 - $FieldteamStatus.R2) {
                        if ($StackStateMiddle.mappings.stack_red -notmatch "on") {
                            $StackStateMiddle.mappings.stack_Red = "on"
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/2/on") -Method Post #get red Pin ID
                        }
                    }else {
                        if ($StackStateMiddle.mappings.stack_red -notmatch "off") {
                            $url = ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/2/off") 

                            Invoke-RestMethod -uri $url -Method Post  #get red Pin ID
                        }
                    }

                    if ($FieldteamStatus.B1 -and $FieldteamStatus.B2 - $FieldteamStatus.B2) {
                        if ($StackStateMiddle.mappings.stack_blue -notmatch "on") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/1/on") -Method Post  #get Blue Pin ID
                        }
                    }else {
                        if ($StackStateMiddle.mappings.stack_red -notmatch "off") {
                            Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/1/off")  -Method Post #get blue Pin ID
                        }
                    }
                }
            }
        }elseif ($WSJSONPacket.type -match "matchTiming") {
        Set-PodeState -Name 'FMSArenatimings' -Value $WsEvent.Request.body
       
        }elseif ($WSJSONPacket.type -match "ping") {
        Write-Debug "WSMadepingrequest"
        }elseif ($WSJSONPacket.type -match "matchTime") {
            if ($true) {

                Lock-PodeObject -name "StackState" -ScriptBlock {
                    $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json

                    #$StackStateRedIP = $StackConfigData.RedSCC
                    #$StackStateBlueIP = $StackConfigData.BlueSCC
                    $StackStateMiddleIP = $StackConfigData.MiddleStack
                    #$StackStateRed =Invoke-RestMethod -Uri "http://$StackStateRedIP/state"
                    #$StackStateBlue =Invoke-RestMethod -Uri "http://$StackStateBlueIP/state"
                    $StackStateMiddle =Invoke-RestMethod -Uri "http://$StackStateMiddleIP/state"
                        $shifttiming = get-podestate -Name "Shifttiming"
                        $StackState = Get-PodeState -name "StackState"
                        if (!(($WSJSONPacket.data.MatchState -ge 3) -and ($WSJSONPacket.data.MatchState -le 5))) {
                            if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off") -Method Post
                                Write-host "Red hubs off"
                                #Code to enable both hubs for non ops
                            }
                            if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                #Code to enable both hubs for no ops
                                Write-host "Blue hubs off"
                            }                    }
                        #from Start of match to the transtion end
                        if (($WSJSONPacket.data.MatchTimeSec -GT 0) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.transtionshiftend))) { 
                            if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on") -Method Post
                                Write-host "Red hubs On"
                                #Code to enable both hubs for auto
                            }
                            if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                #Code to enable both hubs for auto
                                Write-host "Blue hubs On"
                            }
                            
                        }
                        #end of from Start
                        #from Transtionend to 3 second before end of first Shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.transtionshiftend)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift1Warn))) {
                            if ($shifttiming.shift1 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    Write-host "Red hub active for Shift 1"
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    write-host "Blue hub active for Shift 1"
                                    
                                }
                            }if ($shifttiming.shift1 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    Write-host " Red hubs active" 
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    write-host " Blue hubs active"
                                    
                                }
                            }
                            
                        }

                        #end of block
                        #3 Second before End First Shift to end of first shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift1Warn)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift1))) {
                            if ($shifttiming.shift1 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/blink") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift1 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/blink" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }# End First Shift to  three sec before end of 2nd shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift1)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2warn ))) {
                            if ($shifttiming.shift2 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift2 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }#3 Second before End of 2nd Shift to end of 2nd shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2warn)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift2))) {
                            if ($shifttiming.shift2 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/blink") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift2 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/blink" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }# End 2rd Shift to  three sec before end of 3nd shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift2)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3warn))) {
                            if ($shifttiming.shift3 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift3 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }#3 Second before End 3rd Shift to end of 3rd shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3warn)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift3))) {
                            if ($shifttiming.shift3 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/blink") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift3 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "blink"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/blink" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }# End 3rd Shift to  4th shift
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift3)) -and ($WSJSONPacket.data.MatchTimeSec -lT ($gametiming.endshift4))) {
                            if ($shifttiming.shift3 -match "blue"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/off" ) -Method Post
                                    #Code to disable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                    #Code to enable Blue hubs for shift1
                                    
                                }
                            }if ($shifttiming.shift3 -match "red"){
                                if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                                    #Code to enable red hubs for shift1
                                    
                                }
                                if($StackStateMiddle.mappings.hub_blue -notmatch "off"){
                                    Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/off") -Method Post
                                    #Code to disable Blue hubs for shift1
                                    
                                }
                            }
                            
                        }
                        if (($WSJSONPacket.data.MatchTimeSec -ge ($gametiming.endshift4))) {
                            if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                                #Code to enable both hubs for auto
                            }
                            if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                                #Code to enable both hubs for auto
                            }
                            
                        }
                        Set-PodeState -Name "StackConfig" -Value $StackState

                }
            }
            Lock-PodeObject -Name 'FMSArenamatchtime' -ScriptBlock{
                $prevstate = get-podeState -Name 'FMSArenatimer' | ConvertFrom-Json

                if($prevstate.data.MatchState -notmatch $WSJSONPacket.data.MatchState){
                    if ($prevstate.data.MatchState -match "3" ) {
                        
                        $currentpoints = Get-PodeState -Name "points"
                        if (($currentpoints.RedAuto) -gt ($currentpoints.blueAuto)) {
                            write-host "red is leading setting leader to red"
                            $Fuelleader ="red"
                            $FuelRunnerup = "blue"
                        }elseif (($currentpoints.RedAuto) -lt ($currentpoints.BlueAuto)) {
                            write-host "Blue is leading setting leader to Blue"
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
                            write-host "FMS Desides $Fuelleader Leads"
                        }
                        Set-PodeState -Name "Shifttiming"-Value @{"shift1"=$FuelRunnerup;"shift2"=$Fuelleader;"shift3"=$FuelRunnerup;"shift4"=$Fuelleader;}
                        Set-PodeState -Name 'FMSArenatimer' -Value "$WsEvent.Request.body"
                    }

                    
                    if ($WSJSONPacket.data.MatchState -eq "0") {
                        if ($prevstate.data.MatchState -eq  "6"){
                            $arena = get-podeState -name "FMSArenaStatus" | ConvertFrom-Json
                            $matchid = ($arena.data.MatchId)
                            Get-PodeState -name "points"| convertto-JSON | Out-File -FilePath ./log/$matchid.json -Force
                            Set-PodeState -Name 'points' -Value @{ 'RedAuto' = 0;'blueauto' = 0;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; "mode"="nonops"} | Out-Null
                        }
                        $newstate = "PreMatch"
                    }elseif ($WSJSONPacket.data.MatchState -eq  "1") {
                        Invoke-RestMethod -uri "http://172.16.20.6/music/change-song" -Method Post -Body @{"player"="GameOn"}
 
                        
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
                        Invoke-RestMethod -uri "http://172.16.20.6/music/change-song" -Method Post -Body @{"player"="Inbetween"}
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
            if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.Autoend)){
                write-debug "triger Sound end"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="end.wav"}
            }
            if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.Autoend + $gametiming.pause)){
                    write-debug "triger Sound resume"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="resume.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.transtionshiftend )){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }
            if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift1)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift2)){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift3 )){
                write-debug "triger Sound powerup-force"
                    Send-PodeSignal -Value @{"type"="playaudio";"data"="powerup-force.wav"}
            }if($WSJSONPacket.data.MatchTimeSec -eq ($gametiming.endshift4 )){
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