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
                    }elseif (($WebEvent.data.element -match "redautoL1Sub") -and ($pointState.RedAutoL1 -gt 0)) {
                        $pointState.RedAutoL1--
                    }elseif ($WebEvent.data.element -match "redteleL1Add") {
                        $pointState.RedTeleL1++
                    }elseif (($WebEvent.data.element -match "redteleL1Sub")-and ($pointState.RedTeleL1 -gt 0)) {
                        $pointState.RedTeleL1--
                    }elseif ($WebEvent.data.element -match "redteleL2Add") {
                        $pointState.RedTeleL2++
                    }elseif (($WebEvent.data.element -match "redteleL2Sub") -and ($pointState.RedTeleL2 -gt 0)) {
                        $pointState.RedTeleL2--
                    }elseif ($WebEvent.data.element -match "redteleL3Add") {
                        $pointState.RedTeleL3++
                    }elseif (($WebEvent.data.element -match "redteleL3Sub") -and ($pointState.RedTeleL3 -gt 0)) {
                        $pointState.RedTeleL3--
                    }elseif ($WebEvent.data.element -match "blueautoL1Add"){
                        $pointState.blueAutoL1++
                    }elseif (($WebEvent.data.element -match "blueautoL1Sub") -and ($pointState.BlueAutoL1 -gt 0)) {
                        $pointState.blueAutoL1--
                    }elseif ($WebEvent.data.element -match "blueteleL1Add") {
                        $pointState.blueTeleL1++
                    }elseif (($WebEvent.data.element -match "blueteleL1Sub") -and ($pointState.BlueTeleL1 -gt 0)) {
                        $pointState.blueTeleL1--
                    }elseif ($WebEvent.data.element -match "blueteleL2Add") {
                        $pointState.blueTeleL2++
                    }elseif (($WebEvent.data.element -match "blueteleL2Sub")-and ($pointState.BlueTeleL2 -gt 0)) {
                        $pointState.blueTeleL2--
                    }elseif ($WebEvent.data.element -match "blueteleL3Add") {
                        $pointState.blueTeleL3++
                    }elseif (($WebEvent.data.element -match "blueteleL3Sub") -and ($pointState.BlueTeleL3 -gt 0)) {
                        $pointState.blueTeleL3--
                    }
                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                Write-PodeTextResponse -Value "this is the api for scorekeeper"  
            }

    
}