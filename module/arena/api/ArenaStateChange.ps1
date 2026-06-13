{
    
    if ($webevent.method -eq "post") {
            <# Action to perform if the condition is true #>
        
        Lock-PodeObject -Name "FMSArenaStatusLock" -CheckGlobal -ScriptBlock {
            $Arenastatus = Get-PodeState -Name "FMSArenaStatus" -Value $webevent.data 
        }
        Lock-PodeObject -Name "currentlyplayingLock" -CheckGlobal -ScriptBlock{
            $playerstatus = Get-PodeState -Name "currentlyplaying" 
        }

        if ($playerstatus -ne "CrowdRally") {
            if ($playerAuotmationFlag.automation -eq $true) {
                if (($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and (($playerstatus.Player -ne "Startup") -or ($playerstatus.Player -ne "TeamIntro"))) {
                    if (($playerstatus.Player -eq "Startup") -or ($playerstatus.Player -eq "TeamIntro")) {
                    }
                    else {
                        $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{"Player" = "Startup" } | Out-Null
                        out-TerminalLog -msg "Match Ready Switching to Startup music"

                    }
                }
                if (($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($playerstatus.Player -ne "Gameon")) {
                    $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{ "Player" = "Gameon" } | Out-Null
                    out-TerminalLog -msg "Match is live switching to Game On and Setting Flag for Match is running"
                }
                if (($psobject.data.MatchState -eq 6) -and ($playerstatus.Player -ne "Inbetween" )) {
                    $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{ "Player" = "Inbetween" } | Out-Null
                    out-TerminalLog -msg "Match is completed Switching to Inbetween music"
                }
            }
        else {
            if (($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and ($ArenaReadyFlag -eq $false)) {
                if (($playerstatus.Player -eq "Startup") -or ($playerstatus.Player -eq "TeamIntro")) {
                }
                else {
                    out-TerminalLog -msg "(Automation Disabled) Match is Ready"
                    $arenareadyFlag = $true

                }
            }
            if (($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($gameonFlag -eq $false)) {
                $arenareadyFlag = $false
                $gameonFlag = $true
                out-TerminalLog -msg "(Automation Disabled) Match is live"
            }
            if (($psobject.data.MatchState -eq 6) -and ($PostgameFlag -eq $false )) {
                out-TerminalLog -msg "(Automation Disabled) Match is completed"
                $gameonFlag = $false
                $PostgameFlag = $True
            }
        }

    }

    }
}