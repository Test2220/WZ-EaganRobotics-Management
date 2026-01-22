<#
redautoL1Add
redteleL1Add
redautoL1Sub
redteleL1Sub
redteleL2Add
redteleL2Sub
redteleL3Add
redteleL3Sub

blueautoL1Add
blueteleL1Add
blueautoL1Sub
blueteleL1Sub
blueteleL2Add
blueteleL2Sub
blueteleL3Add
blueteleL3Sub

#>
{
            if ($webevent.method -eq "post") {
                Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
                    $pointState = Get-PodeState -Name "points" 
                    if ($WebEvent.data.element -match "redautoL1Add"){
                        $pointState.RedAutoL1++
                    }elseif ($WebEvent.data.element -match "redautoL1Sub") {
                        $pointState.RedAutoL1--
                    }elseif ($WebEvent.data.element -match "redteleL1Add") {
                        $pointState.RedTeleL1++
                    }elseif ($WebEvent.data.element -match "redteleL1Sub") {
                        $pointState.RedTeleL1--
                    }elseif ($WebEvent.data.element -match "redteleL2Add") {
                        $pointState.RedTeleL2++
                    }elseif ($WebEvent.data.element -match "redteleL2Sub") {
                        $pointState.RedTeleL2--
                    }elseif ($WebEvent.data.element -match "redteleL3Add") {
                        $pointState.RedTeleL3++
                    }elseif ($WebEvent.data.element -match "redteleL3Sub") {
                        $pointState.RedTeleL3--
                    }elseif ($WebEvent.data.element -match "blueautoL1Add"){
                        $pointState.blueAutoL1++
                    }elseif ($WebEvent.data.element -match "blueautoL1Sub") {
                        $pointState.blueAutoL1--
                    }elseif ($WebEvent.data.element -match "blueteleL1Add") {
                        $pointState.blueTeleL1++
                    }elseif ($WebEvent.data.element -match "blueteleL1Sub") {
                        $pointState.blueTeleL1--
                    }elseif ($WebEvent.data.element -match "blueteleL2Add") {
                        $pointState.blueTeleL2++
                    }elseif ($WebEvent.data.element -match "blueteleL2Sub") {
                        $pointState.blueTeleL2--
                    }elseif ($WebEvent.data.element -match "blueteleL3Add") {
                        $pointState.blueTeleL3++
                    }elseif ($WebEvent.data.element -match "blueteleL3Sub") {
                        $pointState.blueTeleL3--
                    }
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                 
            }

    
}