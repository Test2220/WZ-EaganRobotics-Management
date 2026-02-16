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
                    }elseif ($webevent.data.element -match "blueFoulAdd"){
                        $pointState.blueMinorFoul++
                    }elseif ($webevent.data.element -match "blueFoulMin"){
                        $pointState.blueMinorFoul--
                    }elseif ($webevent.data.element -match "redFoulAdd"){
                        $pointState.redMinorFoul++
                    }elseif ($webevent.data.element -match "redFoulMin"){
                        $pointState.redMinorFoul--
                    }elseif ($webevent.data.element -match "blueTFoulAdd"){
                        $pointState.blueMajorFoul++
                    }elseif ($webevent.data.element -match "blueTFoulMin"){
                        $pointState.blueMajorFoul--
                    }elseif ($webevent.data.element -match "redTFoulAdd"){
                        $pointState.redMajorFoul++
                    }elseif ($webevent.data.element -match "redTFoulMin"){
                        $pointState.redMajorFoul--
                    }

                    Set-PodeState -Name "points" -Value $pointState
                    Write-PodeJsonResponse $pointState
                }
                
            }else{
                Lock-PodeObject -name "points" -ScriptBlock{
                    $pointState = Get-PodeState -Name "points" 
                    $redFuel = $pointState.RedAuto + $pointState.Redtele +$pointState.redend
                    $blueFuel = $pointState.blueAuto + $pointState.bluetele +$pointState.blueend
                    $Redtotal = ($pointState.RedAuto) + ($pointState.Redtele) + ($pointState.redend) +($pointState.RedAutoL1 * 15) + ($pointState.redTeleL1 * 10) + ($pointState.redTeleL2 * 20) + ($pointState.redTeleL3 * 30) + ($pointState.blueMinorFoul *5) +($pointState.blueMajorFoul * 15)
                    $Bluetotal = ($pointState.blueAuto) + ($pointState.bluetele) + ($pointState.blueend) +($pointState.blueAutoL1 * 15) + ($pointState.blueTeleL1 * 10) + ($pointState.blueTeleL2 * 20) + ($pointState.blueTeleL3 * 30) + ($pointState.redMinorFoul *5) +($pointState.redMajorFoul * 15)
    
                    $responce = @{'redTotal'=$Redtotal;'bluetotal'=$bluetotal; 'RedFuel' = $redFuel;'blueFuel' = $blueFuel;'redAutoL1' = $pointState.redAutoL1;'redTeleL1' = $pointState.redTeleL1;'redTeleL2' = $pointState.redTeleL2;'redTeleL3' = $pointState.redTeleL3;'BlueAutoL1' = $pointState.blueAutoL1;'BlueTeleL1' = $pointState.blueTeleL1;'BlueTeleL2' = $pointState.blueTeleL2;'BlueTeleL3' = $pointState.blueTeleL3; 'redMinorFoul' = $pointState.redMinorFoul;'redMajorFoul' = $pointState.redMajorFoul; 'blueMinorFoul'=$pointState.blueMinorFoul;'blueMajorFoul' = $pointState.blueMajorFoul; }
                    Write-PodeJsonResponse -Value $responce
                }
            }

    
}