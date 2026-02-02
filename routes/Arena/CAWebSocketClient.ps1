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
                $prevstate = get-podeState -Name 'FMSArenatimer'
                if($prevstate -notmatch $WSJSONPacket.data.MatchState){

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