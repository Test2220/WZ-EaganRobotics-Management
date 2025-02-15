<#
17 : {'name' : 'Red', 'state' : GPIO.HIGH},
27 : {'name' : 'Blue', 'state' : GPIO.HIGH},
22 : {'name' : 'Amber', 'state' : GPIO.HIGH},
23 : {'name' : 'White', 'state' : GPIO.HIGH},
24 : {'name' : 'Green', 'state' : GPIO.HIGH},
25 : {'name' : 'Buzzer', 'state' : GPIO.HIGH},
6 : {'name' : 'Aux1', 'state' : GPIO.HIGH},
12 : {'name' : 'Aux2', 'state' : GPIO.HIGH} 

BevrLink Table

Relay   GPIOPin Stack   SCC   
Relay1  GPIO5   Red     A1
Relay2  GPIO6   Blue    A2
Relay3  GPIO13  Amber   A3
Relay4  GPIO16  white   
Relay5  GPIO19  Green 
Relay6  GPIO20  Buzzer
Relay7  GPIO21  Aux1
Relay8  GPIO26  Aux2


#>

function updatePinState {
    param (
        [int]$Pin,
        [bool]$CoilState,
        [bool]$invert = $false,
        [string]$PLCIP,
        [PSCustomObject[]]$LightState
    )
    if($invert){
        if (($CoilState -eq $false)){
            Invoke-RestMethod -Uri "http://$PLCIP/api/$Pin/off"|Out-Null
        }elseif($CoilState -eq $true){
            Invoke-RestMethod -Uri "http://$PLCIP/api/$Pin/on"|Out-Null
        }
    }else {
        if (($CoilState -eq $false)){
            Invoke-RestMethod -Uri "http://$PLCIP/api/$Pin/on"|Out-Null
        }elseif($CoilState -eq $true){
            Invoke-RestMethod -Uri "http://$PLCIP/api/$Pin/off"|Out-Null
        }
    }

   # Write-Host "Pin is $Pin and relays are inverted is $Pininverted the state of the Pin is $pinStateCast"
}
$StackIP = "172.16.20.73"
$redSCCIP = "172.16.20.71"
$blueSCCIP = "172.16.20.72"
$StacklightRed = 5
$StackLightBlue = 6
$StackLightOrange = 13 
$StackLightGreen=19
$StackLightWhite=16
$StackLightR1=5
$StackLightR2=6
$StackLightR3=13
$StackLightB1=5
$StackLightB2=6
$StackLightB3=13


do {
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 50
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $true -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 250
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 1000
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $true -PLCIP $StackIP
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $true -PLCIP $StackIP
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $true -PLCIP $StackIP
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $true -PLCIP $StackIP
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $true -PLCIP $StackIP
    
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    updatePinState -Pin $StackLightBlue -Pininverted $true -CoilState $false -PLCIP $StackIP
    updatePinState -Pin $StacklightRed -Pininverted $true -CoilState $false -PLCIP $StackIP
    updatePinState -Pin $StackLightOrange -Pininverted $true -CoilState $false -PLCIP $StackIP
    updatePinState -Pin $StackLightGreen -Pininverted $true -CoilState $false -PLCIP $StackIP
    updatePinState -Pin $StackLightWhite -Pininverted $true -CoilState $false -PLCIP $StackIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $true -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StackLightR1 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    updatePinState -Pin $StackLightR2 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    updatePinState -Pin $StackLightR3 -Pininverted $true -CoilState $false -PLCIP $redSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $true -PLCIP $blueSCCIP
    Start-Sleep -Milliseconds 500
    updatePinState -Pin $StackLightB1 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    updatePinState -Pin $StackLightB2 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP
    updatePinState -Pin $StackLightB3 -Pininverted $true -CoilState $false -PLCIP $blueSCCIP

    Start-Sleep -Seconds 2

} while (
    $true
)