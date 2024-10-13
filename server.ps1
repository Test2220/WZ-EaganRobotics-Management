Import-Module -Name Pode -MaximumVersion 2.99.99


$MPIP = '172.16.1.111'
$musicPort = "8880"
$MusicPlayerIP= $MPIP+":"+$musicPort

$DJIP = $MPIP
$playlistIDs =Invoke-RestMethod -Uri "http://$MusicPlayerIP/api/playlists/"
$PlayerIndex = @{}
foreach ($player in $playlistIDs.playlists){

    $PlayerIndex.Add($player.title,$player.id)

}


Start-PodeServer -Threads 4 {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http
    Set-PodeViewEngine -Type Pode
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    Add-PodeRoute -Method get -Path "/" -ScriptBlock{

        Write-PodeViewResponse -Path "index"
    }
    Add-PodeRoute -Method get -Path "/Music" -ScriptBlock {
        $playlistIDs = $using:PlayerIndex
        $rallyid = $playlistIDs.CrowdRally
        $apiIPPort = $using:MusicPlayerIP
        $playlist =Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$rallyid/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"

        Write-PodeViewResponse -Path "MusicControl" -Data @{"payload" = $playlist.playlistItems.items;}
    }


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

        $WebEvent.Data |ConvertTo-Json | Out-File -FilePath "./data/currentlyplaying.json" -Force
        $action = $WebEvent.Data.Player 
        $payload = New-Object -TypeName psobject


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
                

                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/pause" -Method Post  

                Invoke-RestMethod -uri "http://$VDJIP/execute?script=automix_skip" -Method Get

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
    Add-PodeRouteGroup -Path "/home" -Routes {
            Add-PodeRoute -Method get -Path "/list" -ScriptBlock {
                $apiHomeState =  Get-Content -Path ".\data\workstations.json" | ConvertFrom-Json    
                Write-PodeViewResponse -Path "phonehome" -Data @{"payload" = $apiHomeState;}
            }
            Add-PodeRoute -Method Get -Path "/add" -ScriptBlock {
                Write-PodeViewResponse -Path "ManualHomeAdd"
            }
            Add-PodeRoute -Method Post -Path "/post" -ScriptBlock {
                $apiHomeState =  Get-Content -Path ".\data\workstations.json" | ConvertFrom-Json 
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
                    $apiHomeState.$workstation.hostname + $workstation
                    $payload= $apiHomeState.$workstation
                }


                $apiHomeState | Convertto-Json | out-file -path .\data\workstations.json -Force

                Write-PodeJsonResponse -Value $payload
            }
    }
    Add-PodeRouteGroup -Path '/api' -Routes  {
        Add-PodeRoute -Method Get -Path '/home' -ContentType 'application/json' -ScriptBlock {
            $apiHomeState =  Get-Content -Path ".\data\workstations.json" | ConvertFrom-Json 
            Write-PodeJsonResponse -Value $:apiHomeState
        }
        Add-PodeRoute -Method Post -Path '/home/update' -ContentType 'application/json' -ScriptBlock{ 
            $apiHomeState =  Get-Content -Path ".\data\workstations.json" | ConvertFrom-Json 
            $workstation = $WebEvent.data.ComputerName
            
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
            }else {
                $apiHomeState.$workstation.monitor = $WebEvent.data."NDI Studio"
                $apiHomeState.$workstation.obs = $WebEvent.data.obs
                $apiHomeState.$workstation.MusicPlayer = $WebEvent.data.MusicPlayer
                $apiHomeState.$workstation.VDJ =  $WebEvent.data.VDJ
                $apiHomeState.$workstation.notes = $WebEvent.data.notes
                $apiHomeState.$workstation.LocalIP = $WebEvent.data.LocalAddress
                $apiHomeState.$workstation.tailscale = $WebEvent.data.TailscaleAddress
                $apiHomeState.$workstation.hostname + $workstation

            }
            
            $apiHomeState | Convertto-Json | out-file -path .\data\workstations.json -Force
            Write-PodeJsonResponse -Value $apiHomeState


        }
        Add-PodeRoute -Method get -Path "/Music" -ScriptBlock {
            $payload = Get-content -Path "./data/currentlyplaying.json"
            Write-PodeJsonResponse -Value $payload
        }
    }

}