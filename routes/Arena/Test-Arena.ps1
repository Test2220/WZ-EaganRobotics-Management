{
    if ($webevent.method -eq "post") {
        Lock-PodeObject -Name "TestArenaLock" -ScriptBlock{
            $testState = Get-PodeState -Name "ArenaOverride"
            $currentPoints = Get-PodeState -Name "points"
            if($null -eq $testState){
                $testState=@{"TestMode" = $false}
            }

            if($webevent.data.value -match "True"){
                $testState.TestMode = $true
                $currentpoints.Mode = "test"
            }
            if($webevent.data.value -match "False"){
                $time = Get-PodeState -name "FMSArenatimer" | ConvertFrom-Json 
            if ($time.data.MatchState -eq 3) {
                $currentpoints.Mode  = "auto"
            }elseif (($time.data.MatchState -eq 5) -and($time.data.MatchTimeSec -lt 130)) {
                $currentpoints.Mode  = "tele"
            }elseif (($time.data.MatchState -eq 5) -and($time.data.MatchTimeSec -ge 130)) {
                $currentpoints.Mode  = "end"
            }
            else{
                $currentpoints.Mode  ="nonOps"
            }

                $testState.TestMode = $False
            }
        
            Write-PodeJsonResponse $testState
            Set-PodeState -Name "ArenaOverride" -Value $testState
            set-podestate -name "points" -value $currentpoints
        }

    }else{
        Lock-PodeObject -Name "TestArenaLock" -ScriptBlock{
            $testState = Get-PodeState -Name "ArenaOverride"
            if($null -eq $testState){
                $testState=@{"TestMode" = $false}
            }
            Write-PodeJsonResponse $testState

        }
    
        }
}