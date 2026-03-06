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
        [string]$CoilState,
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
    #http://[piaddres:80]/set/[relayid]/[on/off/blink]
   # Write-Host "Pin is $Pin and relays are inverted is $Pininverted the state of the Pin is $pinStateCast"
}
$StackIP = "192.168.1.251"
$StacklightRed = 1
$StackLightBlue = 2
$StackLightOrange = 6 
$StackLightGreen=3
$StackLightWhite=4


do {
    invoke-restmethod -Uri "http://$stackIP/set/$StacklightRed/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightBlue/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightOrange/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightGreen/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$Stacklightblue/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightWhite/on"  -Method post
    sleep 1
        invoke-restmethod -Uri "http://$stackIP/set/$StacklightRed/on"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightBlue/off"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightOrange/off"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightGreen/off"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$Stacklightblue/off"  -Method post
    sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightWhite/off"  -Method post
    sleep 1


    invoke-restmethod -Uri "http://$stackIP/set/1/on"  -Method post
    invoke-restmethod -Uri "http://$stackIP/set/2/on"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/3/on"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/4/on"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/5/on"   -Method post
    Sleep 1
    invoke-restmethod -Uri "http://$stackIP/set/1/off"  -Method post
    invoke-restmethod -Uri "http://$stackIP/set/2/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/3/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/4/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/5/off"   -Method post
    sleep 3

    invoke-restmethod -Uri "http://$stackIP/set/$StackLightBlue/blink"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightOrange/blink"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightGreen/blink"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$Stacklightblue/blink"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightWhite/blink"   -Method post
    sleep 10

    invoke-restmethod -Uri "http://$stackIP/set/$StackLightBlue/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightOrange/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightGreen/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$Stacklightblue/off"   -Method post
    invoke-restmethod -Uri "http://$stackIP/set/$StackLightWhite/off"   -Method post
    sleep 3

} while (
    $true
)