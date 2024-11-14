Import-Module -Name Pode -MaximumVersion 2.99.99

$podeServer = 'localhost'

Start-PodeServer -Threads 4 {

    # attach to port 8080 for http
    Add-PodeEndpoint -Address $podeServer -Port 8080 -Protocol Http

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
    Add-PodeRoute -Method get -Path "/" -ScriptBlock{

        Write-PodeViewResponse -Path "index"
    }
    Add-PodeRoute -Method get -Path "/music" -ScriptBlock {
        $playlistIDs = $using:PlayerIndex
        $rallyid = $playlistIDs.CrowdRally
        $apiIPPort = $using:MusicPlayerIP
        $playlist =Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$rallyid/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"

        Write-PodeViewResponse -Path "MusicControl" -Data @{"payload" = $playlist.playlistItems.items;}
    }
    Add-PodeRouteGroup -Path "/Music" -Routes {

        Add-PodeRoute -Method Post -Path '/change-song' -ScriptBlock {
            $apiIPPort = $using:MusicPlayerIP
            $VDJIP = $using:DJIP
            $Pindex = $using:PlayerIndex
            $pWalkin = $Pindex.'WalkIn'
            $pStartup = $Pindex.'Gamestartup'
            $pCrowdRally = $Pindex.'CrowdRally'
            $pInbetween = $Pindex.'Inbetween'
            $pWalkout = $Pindex.'Walkout'
            $pTeamIntro = $Pindex.'TeamIntro'

            Lock-PodeObject -Name "currentlyplayingLock" -CheckGlobal -ScriptBlock{
                $player = $webevent.data.Player
                Set-PodeState -Name 'currentlyplaying' -Value @{"Player" = $player;}
            }
            $action = $WebEvent.Data.Player 
            $payload = New-Object -TypeName psobject
            $payload | Add-Member -MemberType NoteProperty -Name Player -Value $action


            switch ($action) {
                "Walkin" { 
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pWalkin/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                    $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pWalkin/$index" -Method Post
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pWalkin
        
                }
                "Startup" { 
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pStartup/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                    $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pStartup/$index" -Method Post
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pStartup

            }
                "Inbetween" {
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $playlist = Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pInbetween/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
                    $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pInbetween/$index" -Method Post
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pInbetween
            }
                "TeamIntro" {
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $playlist = Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pTeamIntro/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
                    $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pTeamIntro/$index" -Method Post 
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pTeamIntro 

                }
                "Gameon" {
                    $VDJState = invoke-restmethod -Uri "http://$VDJIP/query?script=automix"
                    
                    if ($VDJState -match "no") {
                        Invoke-RestMethod -uri "http://$VDJIP/execute?script=automix%20on" -method get
                    }else {Invoke-RestMethod -uri "http://$VDJIP/execute?script=automix_skip" -Method Get}

                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/pause" -Method Post  

                    

                    $VDJStem = Invoke-RestMethod -uri "http://$VDJIP/query?script=stem%20Vocal" -Method Get
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value "VDJ"
                    if ($VDJStem -ne 0) {
                        Invoke-RestMethod -uri "http://$VDJIP/execute?script=stem%20Vocal%200"                }

                    
                }
                "WalkOut" {
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pWalkOut/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                    $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pWalkOut/$index" -Method Post
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pWalkout
        

                }
                "CrowdRally" {
                    $index = $Webevent.Data.Crowdrallysong
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pCrowdRally/$index" -Method Post  
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value $pCrowdRally

                }
                "pauseAll" {
                    Invoke-RestMethod -Uri "http://$apiIPPort/api/player/pause" -Method Post
            
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $payload | Add-Member -MemberType NoteProperty -Name playlistID -Value "Paused"
                        }
                Default {}  
            }        
            Write-PodeJsonResponse -Value $payload
        }
        Add-PodeRoute -Method Post -path "/update-automation" -ScriptBlock {
            Lock-PodeObject -Name "PlayerAutomationLock" -CheckGlobal -ScriptBlock {
                $autostatus = $webevent.data.automation
                Set-PodeState -name "AutomationStatus" -Value @{"automation" = $autostatus}

            }
        }
    }
    Add-PodeRouteGroup -Path "/home" -Routes {
            Add-PodeRoute -Method get -Path "/list" -ScriptBlock {
                Lock-PodeObject -Name "workstationLock" -CheckGlobal -ScriptBlock {
                    $apiHomeState = Get-PodeState -Name "workstaitons"
                    Write-PodeViewResponse -Path "phonehome" -Data @{"payload" = $apiHomeState;}
                }
            }
            Add-PodeRoute -Method Get -Path "/add" -ScriptBlock {
                Write-PodeViewResponse -Path "ManualHomeAdd"
            }
            Add-PodeRoute -Method Post -Path "/post" -ScriptBlock {
                Lock-PodeObject -Name 'workstationLock' -CheckGlobal -ScriptBlock {
                    $apiHomeState = get-podestate -Name "Workstations"
                    $workstation = $WebEvent.data.hostname
                    if (!$apiHomeState.$workstation) {
                        $computeradd = New-Object -TypeName psobject
                        $computeradd | Add-Member -MemberType NoteProperty -Name "monitor" -Value $WebEvent.data."NDI Studio"
                        $computeradd | Add-Member -MemberType NoteProperty -Name "obs" -Value $WebEvent.data.obs
                        $computeradd | Add-Member -MemberType NoteProperty -Name "MusicPlayer" -Value $WebEvent.data.MusicPlayer
                        $computeradd | Add-Member -MemberType NoteProperty -Name "VDJ" -Value $WebEvent.data.VDJ
                        $computeradd | Add-Member -MemberType NoteProperty -Name "notes" -Value $WebEvent.data.notes
                        $computeradd | Add-Member -MemberType NoteProperty -Name "LocalIP" -Value $WebEvent.data.LocalAddress
                        $computeradd | Add-Member -MemberType NoteProperty -Name "tailscale" -Value $WebEvent.data.TailscaleAddress
                        $computeradd | Add-Member -MemberType NoteProperty -Name "hostname" -Value $workstation
                        $apiHomeState | Add-Member -MemberType NoteProperty  -Name $workstation -Value $computeradd   
                        $payload = $computeradd
                    }else {
                        $apiHomeState.$workstation.monitor = $WebEvent.data."NDI Studio"
                        $apiHomeState.$workstation.obs = $WebEvent.data.obs
                        $apiHomeState.$workstation.MusicPlayer = $WebEvent.data.MusicPlayer
                        $apiHomeState.$workstation.VDJ =  $WebEvent.data.VDJ
                        $apiHomeState.$workstation.notes = $WebEvent.data.notes
                        $apiHomeState.$workstation.LocalIP = $WebEvent.data.LocalAddress
                        $apiHomeState.$workstation.tailscale = $WebEvent.data.TailscaleAddress
                        $apiHomeState.$workstation.hostname = $workstation
                        $payload= $apiHomeState.$workstation
                    }

                    Set-PodeState -Name "workstations" -Value $apiHomeState
                    Save-PodeState -Path .\Data\state.json

                    Write-PodeJsonResponse -Value $payload
                }
            }
    }
    Add-PodeRouteGroup -Path '/api' -Routes  {
        Add-PodeRoute -Method Get -Path '/home' -ContentType 'application/json' -ScriptBlock {
            Lock-PodeObject -Name 'workstationLock' -CheckGlobal -ScriptBlock{
                $apiHomeState = get-podestate -Name "Workstations"
                Write-PodeJsonResponse -Value $apiHomeState
            }
        }
        Add-PodeRoute -Method Post -Path '/home/update' -ContentType 'application/json' -ScriptBlock{ 
                $computerinfo = @{}
                if ($null -ne $WebEvent.data.ComputerName) {
                  
                    if ($WebEvent.data."NDI Studio" -eq ($true -or "on")){$computerinfo.Add("monitor",$true)}else {$computerinfo.Add("monitor",$false)}
                    if ($WebEvent.data."obs" -eq ($true -or "on")){$computerinfo.Add("obs",$true)}else {$computerinfo.Add("obs",$false)}
                    if ($WebEvent.data."MusicPlayer" -eq ($true -or "on")){$computerinfo.Add("MusicPlayer",$true)}else {$computerinfo.Add("MusicPlayer",$false)}
                    if ($WebEvent.data."VDJ" -eq ($true -or "on")){$computerinfo.Add("VDJ",$true)}else {$computerinfo.Add("VDJ",$false)}
                    if ($null -ne $WebEvent.data."LocalIP"){$computerinfo.Add("LocalIP",$WebEvent.data."LocalIP")}else {$computerinfo.Add("LocalIP","err")}
                    if ($null -ne $WebEvent.data."tailscale"){$computerinfo.Add("tailscale",$WebEvent.data."tailscale")}else {$computerinfo.Add("tailscale","err")}
                }
                $apiHomeState =  Get-Content -Path ".\data\workstations.json" | ConvertFrom-Json 
                $workstation = $WebEvent.data.ComputerName
                
                if (!$apiHomeState.$workstation) {
                    $computeradd  = New-Object -TypeName psobject
                    $computeradd | Add-Member -MemberType NoteProperty -Name "monitor" -Value $computerinfo.monitor
                    $computeradd | Add-Member -MemberType NoteProperty -Name "obs" -Value $computerinfo.obs
                    $computeradd | Add-Member -MemberType NoteProperty -Name "MusicPlayer" -Value $computerinfo.MusicPlayer
                    $computeradd | Add-Member -MemberType NoteProperty -Name "VDJ" -Value $computerinfo.VDJ
                    $computeradd | Add-Member -MemberType NoteProperty -Name "notes" -Value $computerinfo.notes
                    $computeradd | Add-Member -MemberType NoteProperty -Name "LocalIP" -Value $computerinfo.LocalAddress
                    $computeradd | Add-Member -MemberType NoteProperty -Name "tailscale" -Value $computerinfo.TailscaleAddress
                    $computeradd | Add-Member -MemberType NoteProperty -Name "hostname" -Value $workstation
                    $apiHomeState | Add-Member -MemberType NoteProperty  -Name $workstation -Value $computeradd   
                }else {
                    $apiHomeState.$workstation.role.monitor = $WebEvent.data."NDI Studio"
                    $apiHomeState.$workstation.role.obs = $WebEvent.data.obs
                    $apiHomeState.$workstation.role.MusicPlayer = $WebEvent.data.MusicPlayer
                    $apiHomeState.$workstation.role.VDJ =  $WebEvent.data.VDJ
                    $apiHomeState.$workstation.notes = $WebEvent.data.notes
                    $apiHomeState.$workstation.LocalIP = $WebEvent.data.LocalAddress
                    $apiHomeState.$workstation.tailscale = $WebEvent.data.TailscaleAddress
                    $apiHomeState.$workstation.hostname + $workstation
    
                }
                
                $apiHomeState | Convertto-Json | out-file -path .\data\workstations.json -Force
                Write-PodeJsonResponse -Value $apiHomeState

        }
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

        Add-PodeRoute -Method Get,Post -Path "/arena" -ContentType 'application/json' -ScriptBlock {
            if ($webevent.method -eq "post") {
                Lock-PodeObject -Name "FMSArenaStatusLock" -CheckGlobal -ScriptBlock {
                    Set-PodeState -Name "FMSArenaStatus" -Value $webevent.data 
                    Write-PodeJsonResponse -Value $webevent.data
                }
                
            }else{
                Lock-PodeObject -Name "FMSArenaStatusLock" -CheckGlobal -ScriptBlock {
                    $arenaPayload = Get-PodeState -Name "FMSArenaStatus" 
                    Write-PodeJsonResponse -Value $arenaPayload
                }

            }

        }
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

