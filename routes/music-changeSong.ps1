{
            
            $PlayerConfig = get-content -Path ./data/config.json | ConvertFrom-Json
            $apiIPPort = $playerconfig.MusicPlayerIP + ":" + $playerconfig.MusicPort
            $VDJIP = $playerconfig.DJIP

            Lock-PodeObject -Name "playlistlock" -ScriptBlock {
                $Pindex = get-podestate -name "PlaylistConfig"
            }

            
            $pWalkin = $Pindex.'WalkIn'
            $pStartup = $Pindex.'Gamestartup'
            $pCrowdRally = $Pindex.'CrowdRally'
            $pInbetween = $Pindex.'Inbetween'
            $pWalkout = $Pindex.'Walkout'
            $pTeamIntro = $Pindex.'TeamIntro'

            Lock-PodeObject -Name "currentlyplayingLock" -ScriptBlock{
                $player = $webevent.data.Player
                Set-PodeState -Name 'currentlyplaying' -Value @{"Player" = $player;}
            }
            $action = $WebEvent.Data.Player 
            $payload = New-Object -TypeName psobject
            $payload | Add-Member -MemberType NoteProperty -Name Player -Value $action

            
            switch ($action) {
                "Walkin" { 
                    Invoke-RestMethod -uri "http://$VDJIP/execute?script=pause" -Method get
                    $url = "http://$apiIPPort/api/playlists/$pWalkin/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
                    Write-Debug $url
                    $playlist =(Invoke-RestMethod -Uri $url)
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