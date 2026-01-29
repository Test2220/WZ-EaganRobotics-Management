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
                    if ($WebEvent.data.element -match "redautoL1-0"){
                        $pointState.RedAutoL1 = 0
                    }elseif ($WebEvent.data.element -match "redautoL1-1"){
                        $pointState.RedAutoL1 = 1
                    }elseif ($WebEvent.data.element -match "redautoL1-2"){
                        $pointState.RedAutoL1 = 2
                    }elseif ($WebEvent.data.element -match "redteleL1-0") {
                        $pointState.RedTeleL1 = 0
                    }elseif ($WebEvent.data.element -match "redteleL1-1") {
                        $pointState.RedTeleL1 = 1
                    }elseif ($WebEvent.data.element -match "redteleL1-2") {
                        $pointState.RedTeleL1 = 2
                    }elseif ($WebEvent.data.element -match "redteleL1-3") {
                        $pointState.RedTeleL1 = 3
                    }elseif ($WebEvent.data.element -match "redteleL2-0") {
                        $pointState.RedTeleL2 = 0
                    }elseif ($WebEvent.data.element -match "redteleL2-1") {
                        $pointState.RedTeleL2 = 1
                        if($pointState.RedTeleL1 -ge 3){
                            $pointState.RedTeleL1 = 2
                        }
                    }elseif ($WebEvent.data.element -match "redteleL2-2") {
                        $pointState.RedTeleL2 = 2
                        if($pointState.RedTeleL1 -ge 2){
                            $pointState.RedTeleL1 = 1
                        }
                    }elseif ($WebEvent.data.element -match "redteleL2-3") {
                        $pointState.RedTeleL2 = 3
                        if($pointState.RedTeleL1 -ge 1){
                            $pointState.RedTeleL1 = 0
                        }
                    }elseif ($WebEvent.data.element -match "redteleL3-0") {
                        $pointState.RedTeleL3 = 0
                    }elseif ($WebEvent.data.element -match "redteleL3-1") {
                        $pointState.RedTeleL3 = 1
                        if($pointState.RedTeleL2 -ge 3){
                            $pointState.RedTeleL2 = 2
                        }
                    }elseif ($WebEvent.data.element -match "redteleL3-2") {
                        $pointState.RedTeleL3 = 2
                        if($pointState.RedTeleL2 -ge 2){
                            $pointState.RedTeleL2 = 1
                        }                        
                    }elseif ($WebEvent.data.element -match "redteleL3-3") {
                        $pointState.RedTeleL3 = 3
                        $pointState.RedTeleL2 = 0
                        $pointState.RedTeleL1 = 0
                    }elseif ($WebEvent.data.element -match "blueautoL1-0"){
                        $pointState.blueAutoL1 = 0
                    }elseif ($WebEvent.data.element -match "blueautoL1-1"){
                        $pointState.blueAutoL1 = 1
                    }elseif ($WebEvent.data.element -match "blueautoL1-2"){
                        $pointState.blueAutoL1 = 2
                    }elseif ($WebEvent.data.element -match "blueteleL1-0") {
                        $pointState.blueTeleL1 = 0
                    }elseif ($WebEvent.data.element -match "blueteleL1-1") {
                        $pointState.blueTeleL1 = 1
                    }elseif ($WebEvent.data.element -match "blueteleL1-2") {
                        $pointState.blueTeleL1 = 2
                    }elseif ($WebEvent.data.element -match "blueteleL1-3") {
                        $pointState.blueTeleL1 = 3
                    }elseif ($WebEvent.data.element -match "blueteleL2-0") {
                        $pointState.blueTeleL2 = 0
                    }elseif ($WebEvent.data.element -match "blueteleL2-1") {
                        $pointState.blueTeleL2 = 1
                        if($pointState.blueTeleL1 -ge 3){
                            $pointState.blueTeleL1 = 2
                        }
                    }elseif ($WebEvent.data.element -match "blueteleL2-2") {
                        $pointState.blueTeleL2 = 2
                        if($pointState.blueTeleL1 -ge 2){
                            $pointState.blueTeleL1 = 1
                        }
                    }elseif ($WebEvent.data.element -match "blueteleL2-3") {
                        $pointState.blueTeleL2 = 3
                        if($pointState.blueTeleL1 -ge 1){
                            $pointState.blueTeleL1 = 0
                        }
                    }elseif ($WebEvent.data.element -match "blueteleL3-0") {
                        $pointState.blueTeleL3 = 0
                    }elseif ($WebEvent.data.element -match "blueteleL3-1") {
                        $pointState.blueTeleL3 = 1
                        if($pointState.blueTeleL2 -ge 3){
                            $pointState.blueTeleL2 = 2
                        }
                    }elseif ($WebEvent.data.element -match "blueteleL3-2") {
                        $pointState.blueTeleL3 = 2
                        if($pointState.blueTeleL2 -ge 2){
                            $pointState.blueTeleL2 = 1
                        }                        
                    }elseif ($WebEvent.data.element -match "blueteleL3-3") {
                        $pointState.blueTeleL3 = 3
                        $pointState.blueTeleL2 = 0
                        $pointState.blueTeleL1 = 0
                    }

                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                Write-PodeTextResponse -Value "this is the api for scorekeeper"  
            }

    
}