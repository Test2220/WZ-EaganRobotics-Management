{
    # attach to port 80 for http
    Add-PodeEndpoint -Address $podeServer -Port 80 -Protocol Http
    Add-PodeEndpoint -Address $podeServer -Port 80 -Protocol Ws

    Set-PodeViewEngine -Type Pode
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    Write-Debug "init Pode State and Lock Tables"
    #init the podestate and lock table
    Restore-PodeState -Path "./data/state.json"


    set-podestate -Name "Nexuslink" |Out-Null
    

    New-PodeLockable -name "NexusLock"
   
    . "./module/music/init.ps1" #music state and lock table init code
    . "./module/arena/init.ps1" #arena state init
    . "./module/Game2026/init-Gamecode.ps1" #Game2026 State and Lock table
    
    $WSURL = "ws://" + $FMSAddress +":8080/match_play/websocket"
    if($serverSettings.FMSConnect){
        Write-Debug "Starting WebSocket"
        try {Connect-PodeWebSocket -Url $WSURL -Name "CA" -FilePath "./module/Game2026/routes/CAWebSocketClient.ps1"}
        catch {Write-Host "Websocket to FMS Software failed check connection and reset server if FMS is up"}
    }else{write-debug "Setting for Websocket is disabled skipping WS connection"}
    
    if($serverSettings.Music){
        if (Test-Path -Path "./data/config.json") {
            $playerconfig = Get-Content -Path "./data/config.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
            $MPIP = $playerconfig.MusicPlayerIP 
            $musicPort = $playerconfig.MusicPort
            $MusicPlayerIP= $MPIP+":"+$musicPort
        }
        else {
            #assume players is in local mode
            $MPIP = "localhost" 
            $musicPort = "8880"
            $MusicPlayerIP= $MPIP+":"+$musicPort
        }    
        try {
            $playlistIDs =Invoke-RestMethod -Uri "http://$MusicPlayerIP/api/playlists/"
            Write-podehost "got Playlist"
        }
        catch {
            Write-Podehost "Error with playlist capture navigate to http://$podeserver/setup to setup player"
            Add-PodeRoute -Method Post,get -Path '/setup' -ScriptBlock {
                if ($webevent.method -eq "post") {
                    Lock-PodeObject -Name "PlayerConfigLock" -CheckGlobal -ScriptBlock{
                        $playerconfig = @{"MusicPlayerIP" = $webevent.data.MusicPlayerIP;"MusicPort" = $webevent.data.MusicPort; "DJIP" = $webevent.data.DJIP;}
                        Set-PodeState -Name "PlayerConfig" -Value $playerconfig
                        ConvertTo-Json $playerconfig | Out-File "./data/config.json"
                    }
                    Save-PodeState -Path './data/state.json'
                    }
                Write-PodeViewResponse -Path "setup"
                }
            }
        $PlayerIndex = @{}
        foreach ($player in $playlistIDs.playlists){
            $PlayerIndex.Add($player.title,$player.id)
        }
        Lock-PodeObject -Name "playlistlock" -ScriptBlock {
            Set-PodeState -Name "PlaylistConfig" -Value $PlayerIndex
        }
        
        Write-podehost "indexed Playlist"
        Add-PodeRoute -Method get -Path "/music" -FilePath "./module/music/front/music.ps1" 
        Add-PodeRouteGroup -Path "/music" -Routes {
            Add-PodeRoute -Method Post -Path '/change-song' -FilePath "./module/music/api/music-changeSong.ps1" 
            Add-PodeRoute -Method Post -path "/update-automation" -FilePath "./module/music/api/music-updateAutomation.ps1"
        }    
    }
    Add-PodeRoute -Method get -Path "/" -ScriptBlock{Write-PodeViewResponse -Path "index"}

    Add-PodeRouteGroup -Path "/arena" -Routes {
        Add-PodeRoute -Method Get -Path "/scorekeeper" -ScriptBlock {Write-PodeViewResponse -Path "Scorekeeper" -Folder "./module/arena/view"}
        Add-PodeRoute -Method Get -Path "/Announcer" -ScriptBlock {Write-PodeViewResponse -Path "AnnouncerDisplay" -Folder "./module/arena/view"}
        Add-PodeRoute -method get -Path "/points" -ScriptBlock{Write-PodeViewResponse -Path "ScoreDashboard" -Folder "./module/arena/view"}
        add-poderoute -Method Get -Path "/Test" -ScriptBlock {Write-PodeViewResponse -Path "testArena" -Folder "./module/arena/view"}
        Add-PodeRouteGroup -Path "/Audiance" -Routes {
            Add-PodeRoute -Path "/game" -Method Get -ScriptBlock {Write-PodeViewResponse -Path "AudianceGameBug" -Folder "./module/arena/view"}
            Add-PodeRoute -Path "/AudioPlayback" -Method Get -ScriptBlock {Write-PodeViewResponse -Path "soundplayer" -Folder "./module/arena/view"}
        }
        Add-PodeRoute -Method get -Path "/stack" -ScriptBlock {Write-PodeViewResponse -Path "arena/stacklightTest" -Folder "./module/arena/view"}

        Add-PodeRoute -Method get -Path "/log" -scriptblock {Write-PodeDirectoryResponse -Path "./log"} 
        add-podeRoute -method get -Path "/log/:filename" -ScriptBlock{#need to debug on why this errors out
            $filepath = "./log/"+$WebEvent.Parameters['filename']
            $filelocation = get-content -Path $filepath
            Write-PodetextResponse $filelocation
        }
    }
    Add-PodeRouteGroup -Path '/api' -Routes  {
        Add-PodeRoute -Method get -Path "/Music" -ScriptBlock {
            Lock-PodeObject -Name "currentlyplayingLock" -CheckGlobal -ScriptBlock{
                $payload = Get-PodeState -Name "currentlyplaying" 
                Write-PodeJsonResponse -Value $payload
            }
        }
        Add-PodeRoute -Method get -Path "/Music/automation" -ScriptBlock {
            Lock-PodeObject -Name "PlayerAutomationLock" -CheckGlobal -ScriptBlock{
                $payload = Get-PodeState -Name "AutomationStatus" 
                Write-PodeJsonResponse -Value $payload
            }
        }
        Add-PodeRoute -Method Get,Post -Path "/arena" -ContentType 'application/json' -FilePath "./module/arena/api/arena.ps1"
        Add-PodeRouteGroup -Path "/arena" -Routes{
            Add-PodeRoute -Method get,Post -path "/test" -FilePath "./module/arena/api/Test-Arena.ps1"
            Add-PodeRouteGroup -Path "/test" -Routes{
                Add-PodeRoute -Method Post -Path "/playSound" -ScriptBlock {
                    $fileselection = $webevent.data.sound
                    Send-PodeSignal -Value @{"type"="playaudio";"data"=$fileselection}
                }
            }
            Add-PodeRoute -Method get -Path "/points" -FilePath "./module/arena/api/Arenapoints.ps1"
            Add-PodeRoute -Method get,Post -Path "/points/:team/:score" -FilePath "./module/Game2026/routes/API/ArenaScoring.ps1"
            Add-PodeRoute -Method get -Path "/score" -FilePath "./module/Game2026/routes/API/score.ps1"
            add-poderoute -Method get,post -Path "/state" -ContentType 'application/json' -FilePath "./module/arena/api/ArenaStateChange.ps1"
            Add-PodeRoute -Method get,post -Path "/scorekeeper" -ContentType 'application/json' -filepath "./module/Game2026/routes/API/scorekeeper.ps1"
            Add-PodeRoute -Method get,post -Path "/bypass/:pos" -FilePath "./module/arena/api/FMS-Bypass.ps1"
            add-poderoute -Method Get -Path "/team/:pos" -FilePath "./module/arena/api/FMS-TeamList.ps1"
            Add-PodeRoute -Method Get -Path "/matchstart" -ScriptBlock {Send-PodeWebSocket -name "CA" -Message @{"type"="startMatch";"data"=@{"muteMatchSounds"=$false}}}
            Add-PodeRoute -Method Get -Path "/abortmatch" -ScriptBlock {Send-PodeWebSocket -name "CA" -Message @{"type"="abortMatch"}}
            Add-PodeRoute -Method Get -Path "/AudianceDisplay" -FilePath "./module/arena/api/AudianceDisplay.ps1"
             Add-PodeRoute -Method Get -Path "/Shifttiming" -scriptblock{
                $shifts = get-podestate -Name "Shifttiming"
                $time = get-PodeState -name "timerData" | convertfrom-json 
                if (($time.MatchTimeSec -ge ($gametiming.transtionshiftend)) -and ($time.MatchTimeSec -lT ($gametiming.endshift1))) {
                    $currentShift = "shift1"
                }
                if (($time.MatchTimeSec -ge ($gametiming.endshift1)) -and ($time.MatchTimeSec -lT ($gametiming.endshift2))) {
                    $currentShift = "shift2"
                }
                if (($time.MatchTimeSec -ge ($gametiming.endshift2)) -and ($time.MatchTimeSec -lT ($gametiming.endshift3))) {
                    $currentShift = "shift3"
                }
                if (($time.MatchTimeSec -ge ($gametiming.endshift3)) -and ($time.MatchTimeSec -lT ($gametiming.endshift4))) {
                    $currentShift = "shift4"
                }
                if (($time.MatchTimeSec -ge ($gametiming.endshift4))) {
                    $currentShift = "endgame"
                }

                Write-PodeJsonResponse -Value @{"currentshift"=$currentShift;"shift1"=$shifts.shift1;"shift2"=$shifts.shift2;"shift3"=$shifts.shift3;"shift4"=$shifts.shift4;}


            }
            Add-PodeRouteGroup -Path "/Stack"-Routes{
                Add-PodeRoute -Path "/state" -Method Get -ScriptBlock{
                    Lock-PodeObject -Name "ConfigStateLock" -ScriptBlock {Write-PodeJsonResponse (Get-PodeState -Name "StackState")}

                } 
                add-poderoute -Path "/update" -Method post -FilePath "./module/Game2026/routes/API/Arena_stackForceUpdate.ps1"

               Add-PodeRoute -Path "/config" -Method Get,post -FilePath "./module/Stacklight/api/Config.ps1" 
    
            }
            add-Poderoute -method get -path "/reset" -scriptblock {    Set-PodeState -Name 'points' -Value @{ 'RedAuto' = 0;'blueauto' = 0;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; } | Out-Null}
        }
        
    }
    Add-PodeRouteGroup -path "/pode" -Routes{
                Add-PodeRoute -Method Get -Path "/update" -ScriptBlock {
            $response = (git pull)
            Write-PodeTextResponse $response
        }
        Add-PodeRoute -Method Get -Path "/save" -ScriptBlock {
            if(!(Test-Path ./data/)){
                mkdir ./data
            }
            Lock-PodeObject -ScriptBlock {
                Save-PodeState -Path './data/state.json'
            }
        }
        add-poderoute -Method get -path "/reload" -ScriptBlock{
            if(!(Test-Path ./data/)){
                mkdir ./data
            }
            Lock-PodeObject -ScriptBlock {
                Save-PodeState -Path './data/state.json'
            } Disconnect-PodeWebSocket -name "CA"
            restart-podeServer
        }
        add-poderoute -Method get -path "/reset" -ScriptBlock{
            if((Test-Path ./data/)){
                Remove-Item "./data/state.json"
            }
            Disconnect-PodeWebSocket -name "CA"
            restart-podeServer
        }
    }
}