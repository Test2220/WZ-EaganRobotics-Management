{
    if(!(Test-Path -Path "./data/Stacklightconfig.json")){
        '{"BlueSCC": "localhost","MiddleStack": "localhost","RedSCC": "localhost"}' | Out-File "./data/Stacklightconfig.json" -Force
    }
    if ($webevent.method -eq "post") {
        Lock-PodeObject -Name "StackConfigLock" -ScriptBlock{
            $StackConfig = @{"BlueSCC" = $webevent.data.BlueSCC;"RedSCC" = $webevent.data.RedSCC; "MiddleStack" = $webevent.data.MiddleStack;"BlueSCCPort" = $webevent.data.BlueSCCPort;"RedSCCPort" = $webevent.data.RedSCCPort; "MiddleStackPort" = $webevent.data.MiddleStackPort;}
            Set-PodeState -Name "StackConfig" -Value $StackConfig 
            ConvertTo-Json $StackConfig  | Out-File "./data/Stacklightconfig.json"
            Write-PodeJsonResponse -Value $StackConfig 
        }
    Save-PodeState -Path './data/state.json'
    }else{
        $StackConfigData = Get-PodeState -Name "StackConfig"
        if($null -eq $StackConfigData.MiddleStack){
            $StackConfigData = Get-Content "./data/Stacklightconfig.json" | Convertfrom-Json
        }
        $phonehomeip =  Get-Content ./data/StacklightList.txt
        Write-PodeViewResponse -Path "arena/StackSetup"  -Data @{"BlueSCC" = $StackConfigData.BlueSCC;"RedSCC" = $StackConfigData.RedSCC; "MiddleStack" = $StackConfigData.MiddleStack;"BlueSCCPort" = $StackConfigData.BlueSCCPort;"RedSCCPort" = $StackConfigData.RedSCCPort; "MiddleStackPort" = $StackConfigData.MiddleStackPort;"IPList"=$phonehomeip;}  
        }

   
}