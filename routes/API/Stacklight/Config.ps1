{
    if ($webevent.method -eq "post") {
        Lock-PodeObject -Name "StackConfigLock" -ScriptBlock{
            $StackConfig = @{"BlueSCC" = $webevent.data.BlueSCCIP;"RedSCC" = $webevent.data.RedSCCIP; "MiddleStack" = $webevent.data.MiddleStackIP;}
            Set-PodeState -Name "StackConfig" -Value $StackConfig 
            ConvertTo-Json $StackConfig  | Out-File "./data/Stacklightconfig.json"
            Write-PodeJsonResponse -Value $StackConfig 
        }
    Save-PodeState -Path './data/state.json'
    }

        Lock-PodeObject -Name "StackConfigLock"  -ScriptBlock{
            $StackConfigData = Get-PodeState -Name "StackConfig"
            Write-PodeViewResponse -Path "arena/StackSetup"  -Data @{"BlueSCC" = $StackConfigData.BlueSCC;"RedSCC" = $StackConfigData.RedSCC; "MiddleStack" = $StackConfigData.MiddleStack;}
        }

   
}