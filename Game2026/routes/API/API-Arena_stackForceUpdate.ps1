{
    Lock-PodeObject -Name "StackState" -ScriptBlock {
        $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json
        $StackStateMiddleIP = $StackConfigData.MiddleStack
        $StackStateMiddle =Invoke-RestMethod -Uri "http://$StackStateMiddleIP/state"
        $shifttiming = get-podestate -Name "Shifttiming"
        $time = Set-PodeState -name "timerData" | convertfrom-json 


        $shifttiming = get-podestate -Name "Shifttiming"
        if (!(($time.MatchState -ge 3) -and ($time.MatchState -le 5))) {
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
        if (($time.MatchTimeSec -GT 0) -and ($time.MatchTimeSec -lT ($gametiming.transtionshiftend))) { 
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
        if (($time.MatchTimeSec -ge ($gametiming.transtionshiftend)) -and ($time.MatchTimeSec -lT ($gametiming.endshift1Warn))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift1Warn)) -and ($time.MatchTimeSec -lT ($gametiming.endshift1))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift1)) -and ($time.MatchTimeSec -lT ($gametiming.endshift2warn ))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift2warn)) -and ($time.MatchTimeSec -lT ($gametiming.endshift2))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift2)) -and ($time.MatchTimeSec -lT ($gametiming.endshift3warn))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift3warn)) -and ($time.MatchTimeSec -lT ($gametiming.endshift3))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift3)) -and ($time.MatchTimeSec -lT ($gametiming.endshift4))) {
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
        if (($time.MatchTimeSec -ge ($gametiming.endshift4))) {
            if($StackStateMiddle.mappings.hub_red  -notmatch "on"){
                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/7/on" ) -Method Post
                #Code to enable both hubs for auto
            }
            if($StackStateMiddle.mappings.hub_blue -notmatch "on"){
                Invoke-RestMethod -uri ("http://"+$StackConfigData.MiddleStack+":"+$StackConfigData.MiddleStackPort +"/set/8/on") -Method Post
                #Code to enable both hubs for auto
            }
            
        }
                
            

    }
    Write-PodeHost "forced update completed"
}