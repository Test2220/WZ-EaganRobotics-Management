Import-Module -Name Pode -MaximumVersion 2.99.99
function out-TerminalLog {
    param (
        [string]$msg  
    )

    $date = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    Write-Host $date $msg 
}
$podeServer = 'localhost'

Start-PodeServer -Threads 4 {

    # attach to port 80 for http
    Add-PodeEndpoint -Address $podeServer -Port 80 -Protocol Http

    Set-PodeViewEngine -Type Pode
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    
    #init the podestate and lock table
    Restore-PodeState -Path ".\data\state.json"
    Set-PodeState -Name 'currentlyplaying' -Value @{ 'currentplayer' = "none"; } | Out-Null
    Set-PodeState -Name 'FMSArenaStatus' -Value @{ 'values' = @(); } | Out-Null
    Set-PodeState -Name 'AutomationStatus' -Value @{ 'automation' = $true } | Out-Null
    set-podestate -Name "arenaQueue" -Value @{} | Out-Null
    set-podestate -Name "PlayerConfig" |Out-Null
    set-podestate -Name "PlaylistConfig" |Out-Null
    set-podestate -Name "Nexuslink" |Out-Null

    
    New-PodeLockable -name "NexusLock"
    New-PodeLockable -name "playlistLock"
    New-PodeLockable -name "playerconfigLock"
    New-PodeLockable -Name 'workstationLock'
    New-PodeLockable -Name 'FMSArenaStatusLock'
    New-PodeLockable -Name 'currentlyplayingLock'
    New-PodeLockable -Name 'PlayerAutomationLock'
    New-PodeLockable -Name 'ConfigStateLock'
    New-PodeLockable -Name 'arenaQueueLock'
 
    Set-PodeState -Name 'points' -Value @{ 'RedAuto' = 0;'blueauto' = 0;'Redtele' = 0;'bluetele' = 0;'redend' = 0;'blueend' = 0;'redAutoL1' = 0;'redTeleL1' = 0;'redTeleL2' = 0;'redTeleL3' = 0;'BlueAutoL1' = 0;'BlueTeleL1' = 0;'BlueTeleL2' = 0;'BlueTeleL3' = 0; 'redMinorFoul' = 0;'redMajorFoul' = 0; 'blueMinorFoul'=0;'blueMajorFoul' = 0; } | Out-Null
    New-PodeLockable -name "points"
    
    if (Test-Path -Path "./data/config.json") {
        $playerconfig = Get-Content -Path "./data/config.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
        $MPIP = $playerconfig.MusicPlayerIP 
        $musicPort = $playerconfig.MusicPort
        $MusicPlayerIP= $MPIP+":"+$musicPort
        $DJIP = $playerconfig.DJIP
    }
    else {
        #assume players is in local mode
        $MPIP = "localhost" 
        $musicPort = "8880"
        $MusicPlayerIP= $MPIP+":"+$musicPort
        $DJIP = "localhost"
    }    



    
    $DJIP = $playerconfig.DJIP
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
    Write-podehost "indexed Playlist"
    #Start-Process powershell {.\WSClient.ps1}
    Add-PodeRoute -Method get -Path "/" -ScriptBlock{Write-PodeViewResponse -Path "index"}

    Add-PodeRoute -Method get -Path "/music" -FilePath ".\routes\music.ps1"
    Add-PodeRouteGroup -Path "/music" -Routes {
        Add-PodeRoute -Method Post -Path '/change-song' -FilePath ".\routes\music-changeSong.ps1"
        Add-PodeRoute -Method Post -path "/update-automation" -FilePath ".\routes\music-updateAutomation.ps1"
    }
    Add-PodeRouteGroup -Path "/arena" -Routes {
        Add-PodeRoute -Method Get -Path "/scorekeeper" -ScriptBlock {
            Write-PodeViewResponse -Path "Scorekeeper"
        }
        Add-PodeRoute -method get -Path "/points" -ScriptBlock{
            Write-PodeViewResponse -Path "ScoreDashboard"
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
        Add-PodeRoute -Method Get,Post -Path "/arena" -ContentType 'application/json' -FilePath ".\routes\API\api-arena.ps1"
        Add-PodeRouteGroup -Path "/arena" -Routes{
            Add-PodeRoute -Method get -Path "/points" -FilePath ".\routes\API\Arenapoints.ps1"
            Add-PodeRoute -Method Post -Path "/points/:mode/:team/:score" -FilePath ".\Game2026\routes\API\ArenaScoring.ps1"
            Add-PodeRoute -Method get -Path "/score" -FilePath ".\Game2026\routes\API\API-Score.ps1"
            add-poderoute -Method get,post -Path "/queue" -ContentType 'application/json' -FilePath ".\routes\API\api-arenaQueue.ps1"
            add-poderoute -Method get -Path "/queue/read" -ContentType 'application/json' -FilePath ".\routes\API\Api-arenaReadqueue.ps1"
            add-poderoute -Method get,post -Path "/state" -ContentType 'application/json' -FilePath ".\routes\API\API-ArenaStateChange.ps1"
            Add-PodeRoute -Method get,post -Path "/scorekeeper" -ContentType 'application/json' -filepath ".\Game2026\routes\API\api-scorekeeper.ps1"
        }
    }

    Add-PodeRouteGroup -path "/pode" -Routes{
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
            }
            restart-podeServer
        }
        add-poderoute -Method get -path "/reset" -ScriptBlock{
            if((Test-Path ./data/)){
                Remove-Item "./data/state.json"
            }
            restart-podeServer
        }
    }
}

