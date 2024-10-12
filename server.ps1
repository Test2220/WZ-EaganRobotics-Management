Import-Module -Name Pode -MaximumVersion 2.99.99

$apiState = @{}
$playerStatus = ""
$MPIP = 'localhost'
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
        $apiIPPort = $using:MusicPlayerIP
        $playlist =Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/p7/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"

        Write-PodeViewResponse -Path "MusicControl" -Data @{"payload" = $playlist.playlistItems.items;}
    }
    Add-PodeRoute -Method get -Path "/api/Music" -ScriptBlock {
            $payload = Get-Item -Path "./data/currentlyplaying.json"

        Write-PodeJsonResponse -Value $payload

    }

    Add-PodeRoute -Method Post -Path '/change-song' -ScriptBlock {
        $apiIPPort = $using:MusicPlayerIP
        $VDJIP = $using:DJIP
        $Pindex = $using:PlayerIndex
        $pWalkin = $Pindex.'WalkIn'
        $pStartup = $Pindex.'Startup'
        $pCrowdRally = $Pindex.'CrowdRally'
        $pInbetween = $Pindex.'Inbetween'
        $pWalkout = $Pindex.'Walkout'
        $pTeamIntro = $Pindex.'TeamIntro'

        $WebEvent.Data |ConvertTo-Json | Out-File -FilePath "./data/currentlyplaying.json" -Force
        $action = $WebEvent.Data.player 

        switch ($action) {
            "Walkin" { 
                #Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pWalkin/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pWalkin/$index" -Method Post
    
            }
            "startup" { 
               # Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pStartup/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pStartup/$index" -Method Post

        }
            "Inbetween" {
                Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                $playlist = Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pInbetween/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
                $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pInbetween/$index" -Method Post
        }
            "TeamIntro" {
                Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                $playlist = Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pTeamIntro/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
                $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pTeamIntro/$index" -Method Post  

            }
            "Gameon" {
                

                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/pause" -Method Post  

                Invoke-RestMethod -uri "http://$VDJIP/execute?script=automix_skip" -Method Get

                $VDJStem = Invoke-RestMethod -uri "http://$VDJIP/query?script=stem%20Vocal" -Method Get
                
                if ($VDJStem -ne 0) {
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=stem%20Vocal%200"                }

                
            }
            "WalkOut" {
                Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                $playlist =(Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$pWalkOut/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2")
                $index = Get-Random -Minimum 0 -Maximum $playlist.playlistItems.totalCount
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pWalkOut/$index" -Method Post
    

            }
            "CrowdRally" {
                $index = $Webevent.Data.Crowdrallysong
                Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/play/$pCrowdRally/$index" -Method Post  

            }
            "pauseAll" {
                Invoke-RestMethod -Uri "http://$apiIPPort/api/player/pause" -Method Post
        
                Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    }
            Default {}

            
        }        
        Write-PodeJsonResponse -Value $payload
    }
        Add-PodeRoute -Method get -Path '/api/home' -ContentType 'application/json' -ScriptBlock {
            Write-PodeJsonResponse -Value $Using:apiState
    
        }
#        Add-PodeRoute -Method Post -Path '/api/home/update' -ContentType 'application/json' -ScriptBlock{}


}