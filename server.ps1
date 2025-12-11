Import-Module -Name Pode -MaximumVersion 2.99.99

$podeServer = '0.0.0.0'

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

        Write-Podehost "Error with playlist capture navigate to http://$podeserver`:8081/setup to setup player"
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

        Add-PodeRoute -Method Get,Post -Path "/arena" -ContentType 'application/json' -FilePath ".\routes\api-arena.ps1"


        add-poderoute -Method get,post -Path "/arena/queue" -ContentType 'application/json' -ScriptBlock{
            if ($webevent.method -eq "post") {
                    try{
                        $queue = Get-Content -Path "./data/queue.json" -erroraction Stop| ConvertFrom-Json
                    }Catch{$queue = New-Object -TypeName PSObject}
                    if($null -eq $queue.1 ){
                        $queue = New-Object -TypeName PSObject
                    }
                
                    $queueindex = $queue.psobject.Properties.name.count + 1
                    $queue |Add-Member -MemberType NoteProperty -Name $queueindex -Value $webevent.data 
                    

                    $output = $queue | convertto-json 
                    $output |Out-File -FilePath './data/queue.json'
                    write-PodeJsonResponse -Value $Output
                
                
            }else{
                Write-PodeJsonResponse -Path "./data/queue.json"
                
            }
        }

        add-poderoute -Method get -Path "/arena/queue/read" -ContentType 'application/json' -ScriptBlock{
            
            $queue = Get-Content -Path "./data/queue.json" -ErrorAction Stop| ConvertFrom-Json

            if($null -eq $queue.1 ){
                $payload = '{"type":"queueEmpty"}'
            }else{
                $payload = $queue.1 | ConvertTo-Json
                    $tempqueue = $queue | Select-Object -Property * -ExcludeProperty 1
                    $newqueue = New-Object -TypeName PSObject
        
                    foreach ($data in $tempqueue.PSObject.Properties.Value){
                        $newequeueIndex = $newqueue.psobject.Properties.Name.count + 1
                        $newqueue | Add-Member -MemberType NoteProperty -Name $newequeueIndex -Value $data
                    }
                    $newqueuecount = $newqueue.psobject.Properties.Name.count

                    if ($newqueuecount -eq 0){
                        "{}" |Out-File -FilePath './data/queue.json'
                    }else{

                        $output = $newqueue | convertto-json

                        $output |Out-File -FilePath './data/queue.json'
                    }
            }
            Write-PodeJsonResponse -Value $payload
            
}
        }

        Add-PodeRoute -Method Get -Path "/save" -ScriptBlock {
            if(!(Test-Path ./data/)){
                mkdir ./data
            }
            Lock-PodeObject -ScriptBlock {
                Save-PodeState -Path './data/state.json'
            }

        }
    }

