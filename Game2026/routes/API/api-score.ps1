<#
'RedAuto'   'blueauto'
'Redtele'   'bluetele'
'redend'    'blueend'
'redAutoL1' 'BlueAutoL1' Upper limit of 2
'redTeleL1' 'BlueTeleL1'
'redTeleL2' 'BlueTeleL2'
'redTeleL3''BlueTeleL3'
'redMinorFoul''blueMinorFoul'
'redMajorFoul''blueMajorFoul'


#>

{

Lock-PodeObject -Name "points" -CheckGlobal -ScriptBlock {
    $responseJSON = @{"redscore" = 0;"bluescore" = 0}
    $pointState = Get-PodeState -Name "points" 
    if ($pointState.redAutoL1 -ge 2) {
        $pointState.redAutoL1 = 2
    }
    if ($pointState.BluedAutoL1 -ge 2) {
        $pointState.BlueAutoL1 = 2
    }
    $responseJSON.redscore = ($pointState.RedAuto) + ($pointState.Redtele) + ($pointState.redend) +($pointState.RedAutoL1 * 15) + ($pointState.redTeleL1 * 10) + ($pointState.redTeleL2 * 20) + ($pointState.redTeleL3 * 30) + ($pointState.blueMinorFoul *5) +($pointState.blueMajorFoul * 15)
    $responseJSON.bluescore = ($pointState.blueAuto) + ($pointState.bluetele) + ($pointState.blueend) +($pointState.blueAutoL1 * 15) + ($pointState.blueTeleL1 * 10) + ($pointState.blueTeleL2 * 20) + ($pointState.blueTeleL3 * 30) + ($pointState.redMinorFoul *5) +($pointState.redMajorFoul * 15)
    
    
    Write-PodeJsonResponse $responseJSON
    }

}