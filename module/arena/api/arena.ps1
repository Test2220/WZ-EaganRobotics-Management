{
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