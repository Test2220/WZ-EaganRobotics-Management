{
    Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
        $arenaPayload = Get-PodeState -Name "points" 
        Write-PodeJsonResponse -Value $arenaPayload
    }

}