<#
References:
    - https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.clientwebsocket?view=netframework-4.5
    - https://github.com/poshbotio/PoshBot/blob/master/PoshBot/Implementations/Slack/SlackConnection.ps1
    - https://www.leeholmes.com/blog/2018/09/05/producer-consumer-parallelism-in-powershell/


    17 : {'name' : 'Red', 'state' : GPIO.HIGH},
    27 : {'name' : 'Blue', 'state' : GPIO.HIGH},
    22 : {'name' : 'Amber', 'state' : GPIO.HIGH},
    23 : {'name' : 'White', 'state' : GPIO.HIGH},
    24 : {'name' : 'Green', 'state' : GPIO.HIGH},
    25 : {'name' : 'Buzzer', 'state' : GPIO.HIGH},
    6 : {'name' : 'Aux1', 'state' : GPIO.HIGH},
    12 : {'name' : 'Aux2', 'state' : GPIO.HIGH} 
#>
$ProgressPreference = "SilentlyContinue"
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

function out-TerminalLog {
    param (
        [string]$msg  
    )

    $date = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    Write-Host $date $msg 
}

$verboselogging = $false
#$quals = $data.Content
$FMSIP = "172.16.20.5"
$FMSPort = "8080"
$FMSAddress = $FMSIP + ":" + $FMSPort
$APIIP = "127.0.0.1"
$APIPort = "8080"
$APIAddress = $APIIP + ":" + $APIPort
$companionIP = "172.16.20.20"
$companionPort = "8000"
$companionAddress = $companionIP + ":" + $companionPort
$CompanionActive = $true
$playerAuotmationFlag = Invoke-RestMethod -uri "http://$APIAddress/api/music/automation"
$greenblink = $false


$StackIP = "172.16.20.70"
$Pininverted = $false

if (!(Test-Path -Path .\qualification.csv)) {
    $data = Invoke-WebRequest -Uri "http://$FMSAddress/reports/csv/schedule/qualification" 
    $data.Content | Out-File .\qualification.csv
}

$client_id = [System.GUID]::NewGuid()

$recv_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'
$send_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'

$ws = New-Object Net.WebSockets.ClientWebSocket
$cts = New-Object Threading.CancellationTokenSource
$ct = New-Object Threading.CancellationToken($false)

out-TerminalLog -msg "Connecting..."
$connectTask = $ws.ConnectAsync("ws://$FMSAddress/match_play/websocket", $cts.Token)
do { Start-Sleep(1) }
until ($connectTask.IsCompleted)
out-TerminalLog -msg "Connected!"

$recv_job = {
    param($ws, $client_id, $recv_queue)

    $buffer = [Net.WebSockets.WebSocket]::CreateClientBuffer(1024, 1024)
    $ct = [Threading.CancellationToken]::new($false)
    $taskResult = $null

    while ($ws.State -eq [Net.WebSockets.WebSocketState]::Open) {
        $jsonResult = ""
        do {
            $taskResult = $ws.ReceiveAsync($buffer, $ct)
            while (-not $taskResult.IsCompleted -and $ws.State -eq [Net.WebSockets.WebSocketState]::Open) {
                [Threading.Thread]::Sleep(10)
            }

            $jsonResult += [Text.Encoding]::UTF8.GetString($buffer, 0, $taskResult.Result.Count)
        } until (
            $ws.State -ne [Net.WebSockets.WebSocketState]::Open -or $taskResult.Result.EndOfMessage
        )

        if (-not [string]::IsNullOrEmpty($jsonResult)) {
            #"Received message(s): $jsonResult" | Out-File -FilePath "logs.txt" -Append
            $recv_queue.Enqueue($jsonResult)
        }
    }
}

$send_job = {
    param($ws, $client_id, $send_queue)

    $ct = New-Object Threading.CancellationToken($false)
    $workitem = $null
    while ($ws.State -eq [Net.WebSockets.WebSocketState]::Open) {
        if ($send_queue.TryDequeue([ref] $workitem)) {
            #"Sending message: $workitem" | Out-File -FilePath "logs.txt" -Append

            [ArraySegment[byte]]$msg = [Text.Encoding]::UTF8.GetBytes($workitem)
            $ws.SendAsync(
                $msg,
                [System.Net.WebSockets.WebSocketMessageType]::Binary,
                $true,
                $ct
            ).GetAwaiter().GetResult() | Out-Null
        }
    }
}

out-TerminalLog -msg "Starting recv runspace"
$recv_runspace = [PowerShell]::Create()
$recv_runspace.AddScript($recv_job).
AddParameter("ws", $ws).
AddParameter("client_id", $client_id).
AddParameter("recv_queue", $recv_queue).BeginInvoke() | Out-Null

out-TerminalLog -msg "Starting send runspace"
$send_runspace = [PowerShell]::Create()
$send_runspace.AddScript($send_job).
AddParameter("ws", $ws).
AddParameter("client_id", $client_id).
AddParameter("send_queue", $send_queue).BeginInvoke() | Out-Null
$oldMatchstartdata = "init"
$oldR1Team = "init"
$oldR2Team = "init"
$oldR3Team = "init"
$oldB1Team = "init"
$oldB2Team = "init"
$oldB3Team = "init"

$oldR1Byp = "init"
$oldR2Byp = "init"
$oldR3Byp = "init"
$oldB1Byp = "init"
$oldB2Byp = "init"
$oldB3Byp = "init"
    
$oldMatchState = "init"
$arenareadyFlag = $false
$gameonFlag = $false
$PostgameFlag = $false
$LastPull = Get-Date
$greenBlinkTime = Get-Date



try {
    do {
        $msg = $null
        while ($recv_queue.TryDequeue([ref] $msg)) {
            
            $psobject = ConvertFrom-Json $msg
            if ($psobject.type -eq "arenaStatus") {
                $currenttime = Get-Date
                $timespan = New-TimeSpan -Start $LastPull -End $currenttime
                $playerstatus = Invoke-RestMethod -Uri "http://$APIAddress/api/music"
                if ($timespan.TotalSeconds -ge 5) {
                   
                    $playerAuotmationFlag = Invoke-RestMethod -uri "http://$APIAddress/api/music/automation"
                    $LastPull = Get-Date
                    if ($verboselogging) {
                        out-TerminalLog -msg "Pulling data from Server"
                    }
                        
                }
                $queue = Invoke-RestMethod -uri "http://$APIAddress/api/arena/queue/read"
                if($queue.type -notmatch "queueEmpty"){
                    $json = ConvertTo-Json $queue
                    $send_queue.Enqueue($json)
                }

                Invoke-RestMethod -Uri "http://$APIAddress/api/arena" -Method Post -Body $msg -ContentType "application/json" -ErrorAction SilentlyContinue | out-null  # reserving this invoke for passing JSON to the rest endpoint server.

    
                if ($playerstatus -ne "CrowdRally") {
                    if ($playerAuotmationFlag.automation -eq $true) {
                        if (($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and (($playerstatus.Player -ne "Startup") -or ($playerstatus.Player -ne "TeamIntro"))) {
                            if (($playerstatus.Player -eq "Startup") -or ($playerstatus.Player -eq "TeamIntro")) {
                            }
                            else {
                                $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{"Player" = "Startup" } | Out-Null
                                out-TerminalLog -msg "Match Ready Switching to Startup music"

                            }
                        }
                        if (($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($playerstatus.Player -ne "Gameon")) {
                            $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{ "Player" = "Gameon" } | Out-Null
                            out-TerminalLog -msg "Match is live switching to Game On and Setting Flag for Match is running"
                        }
                        if (($psobject.data.MatchState -eq 6) -and ($playerstatus.Player -ne "Inbetween" )) {
                            $playerstatus = Invoke-restmethod -uri "http://$APIAddress/music/change-song" -Method Post -Body @{ "Player" = "Inbetween" } | Out-Null
                            out-TerminalLog -msg "Match is completed Switching to Inbetween music"
                        }
                    }
                    else {
                        if (($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and ($ArenaReadyFlag -eq $false)) {
                            if (($playerstatus.Player -eq "Startup") -or ($playerstatus.Player -eq "TeamIntro")) {
                            }
                            else {
                                out-TerminalLog -msg "(Automation Disabled) Match is Ready"
                                $arenareadyFlag = $true

                            }
                        }
                        if (($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($gameonFlag -eq $false)) {
                            $arenareadyFlag = $false
                            $gameonFlag = $true
                            out-TerminalLog -msg "(Automation Disabled) Match is live"
                        }
                        if (($psobject.data.MatchState -eq 6) -and ($PostgameFlag -eq $false )) {
                            out-TerminalLog -msg "(Automation Disabled) Match is completed"
                            $gameonFlag = $false
                            $PostgameFlag = $True
                        }
                    }
                    <#Redo this section this will make a loop of enabling and crashing need to pull player and set for single play. 
                    if ($RallyStatusConfim -eq $True) { $RallyStatusConfim = $false }
                
                    elseif (($playerstatus -eq "CrowdRally") -and ($RallyStatusConfim -eq $false)) {
                        write-host "Rally song is playing overwriting controls to play until song is over"
                        $RallyStatusConfim = $true
                    } #>
                    
                    if ($CompanionActive) {
                        if (($psobject.data.CanStartMatch -eq $true) -and ($oldMatchstartdata -ne $psobject.data.CanStartMatch) ) {
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/MatchStartStatus/value?value=True" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting Companion Start Status to True"
                        }
                        elseif (($psobject.data.CanStartMatch -eq $false) -and ($oldMatchstartdata -ne $psobject.data.CanStartMatch) ) {
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/MatchStartStatus/value?value=False" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting Companion Start Status to False"
                        }

                        if ($oldB1Team -ne $psobject.data.AllianceStations.B1.Team.ID) {
                            $team = $psobject.data.AllianceStations.B1.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB1Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B1 to $team"
                        }
                        if ($oldB2Team -ne $psobject.data.AllianceStations.B2.Team.ID) {
                            $team = $psobject.data.AllianceStations.B2.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB2Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B2 to $team"
                        }
                        if ($oldB3Team -ne $psobject.data.AllianceStations.B3.Team.ID) {
                            $team = $psobject.data.AllianceStations.B3.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB3Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B3 to $team"
                        }

                        if ($oldR1Team -ne $psobject.data.AllianceStations.R1.Team.ID) {
                            $team = $psobject.data.AllianceStations.R1.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR1Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R1 to $team"
                        }
                        if ($oldR2Team -ne $psobject.data.AllianceStations.R2.Team.ID) {
                            $team = $psobject.data.AllianceStations.R2.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR2Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R2 to $team"
                        }
                        if ($oldR3Team -ne $psobject.data.AllianceStations.R3.Team.ID) {
                            $team = $psobject.data.AllianceStations.R3.Team.ID
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR3Team/value?value=$team" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R3 to $team"
                        }


                        if ($oldB1Byp -ne $psobject.data.AllianceStations.B1.Bypass) {
                            $Value = $psobject.data.AllianceStations.B1.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB1Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B1 Bypass Status to $Value"
                        }
                        if ($oldB2Byp -ne $psobject.data.AllianceStations.B2.Bypass) {
                            $Value = $psobject.data.AllianceStations.B2.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB2Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B3 Bypass Status to $Value"
                        }
                        if ($oldB3Byp -ne $psobject.data.AllianceStations.B3.Bypass) {
                            $Value = $psobject.data.AllianceStations.B3.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaB3Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting B3 Bypass Status to $Value"
                        }

                        if ($oldR1Byp -ne $psobject.data.AllianceStations.R1.Bypass) {
                            $Value = $psobject.data.AllianceStations.R1.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR1Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R1 Bypass Status to $Value"
                        }
                        if ($oldR2Byp -ne $psobject.data.AllianceStations.R2.Bypass) {
                            $Value = $psobject.data.AllianceStations.R2.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR2Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R3 Bypass Status to $Value"
                        }
                        if ($oldR3Byp -ne $psobject.data.AllianceStations.R3.Bypass) {
                            $Value = $psobject.data.AllianceStations.R3.Bypass
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaR3Bypass/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting R3 Bypass Status to $Value"
                        }
                        if ($oldMatchState -ne $psobject.data.MatchState) {
                            $Value = $psobject.data.MatchState
                            Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/ArenaMatchState/value?value=$Value" -Method Post | Out-Null
                            out-TerminalLog -msg "Setting MatchState to $Value"
                        }

                        $oldMatchstartdata = $psobject.data.CanStartMatch
                        $oldB1Team = $psobject.data.AllianceStations.B1.Team.ID
                        $oldB2Team = $psobject.data.AllianceStations.B2.Team.ID
                        $oldB3Team = $psobject.data.AllianceStations.B3.Team.ID

                        $oldR1Team = $psobject.data.AllianceStations.R1.Team.ID
                        $oldR2Team = $psobject.data.AllianceStations.R2.Team.ID
                        $oldR3Team = $psobject.data.AllianceStations.R3.Team.ID

                    
                        $oldB1Byp = $psobject.data.AllianceStations.B1.Bypass
                        $oldB2Byp = $psobject.data.AllianceStations.B2.Bypass
                        $oldB3Byp = $psobject.data.AllianceStations.B3.Bypass

                        $oldR1Byp = $psobject.data.AllianceStations.R1.Bypass
                        $oldR2Byp = $psobject.data.AllianceStations.R2.Bypass
                        $oldR3Byp = $psobject.data.AllianceStations.R3.Bypass
                    
                
                        $oldMatchState = $psobject.data.MatchState
    
                    }

                    ##Start of PLC Section

                    #get info from CA on Arena State
                    if ($psobject.data.AllianceStations.B1.Bypass -eq $false){ #check if B1 is not in Bypass
                        $B1Ready = ($null -ne $psobject.data.AllianceStations.B1.DsConn)
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.B1.Bypass -eq $true) {
                        $B1Ready = $True
                    }
                    if ($psobject.data.AllianceStations.B2.Bypass -eq $false){ #check if B2 is not in Bypass
                        $B2Ready = ($null -ne $psobject.data.AllianceStations.B2.DsConn) 
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.B2.Bypass -eq $true) {
                        $B2Ready = $True
                    }
                    if ($psobject.data.AllianceStations.B3.Bypass -eq $false){ #check if B3 is not in Bypass
                        $B3Ready = ($null -ne $psobject.data.AllianceStations.B3.DsConn) 
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.B3.Bypass -eq $true) {
                        $B3Ready = $True
                    }

                    if ($psobject.data.AllianceStations.R1.Bypass -eq $false){ #check if R1 is not in Bypass
                        $R1Ready = ($null -ne $psobject.data.AllianceStations.R1.DsConn)
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.R1.Bypass -eq $true) {
                        $R1Ready = $True
                    }
                    if ($psobject.data.AllianceStations.R2.Bypass -eq $false){ #check if R2 is not in Bypass
                        $R2Ready = ($null -ne $psobject.data.AllianceStations.R2.DsConn) 
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.R2.Bypass -eq $true) {
                        $R2Ready = $True
                    }
                    if ($psobject.data.AllianceStations.R3.Bypass -eq $false){ #check if R3 is not in Bypass
                        $R3Ready = ($null -ne $psobject.data.AllianceStations.R3.DsConn)
                        #if so Check if DS is not Null, and Ethernet is conencted, and Radio is linked and set the restulting checks to the ready status.

                    }elseif ($psobject.data.AllianceStations.R3.Bypass -eq $true) {
                        $R3Ready = $True
                    }




                    ##Start of PLC Logic
                    if ($R1Ready -and $R2Ready -and $R3Ready){

                        $StackLightRed = $false
                    }else {
                        $StackLightRed = $true
                    }

                    if ($B1Ready -and $B2Ready -and $B3Ready){

                        $StackLightBlue = $false
                    }else {
                        $StackLightBlue = $true
                    }
                    if ($psobject.data.CanStartMatch){
                        $greentimespan = New-TimeSpan -Start $greenBlinkTime -end $currenttime
                        if ($greentimespan.Milliseconds -ge 500) {
                            $StackLightGreen = !$StackLightGreen
                        }
                


                    }else {
                        $StackLightGreen = $false
                    }
                    if (($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5)) {
                        $StackLightGreen = $true
                    }

                    #End of PLC Logic
                    #Send to Stack

                    $stackState = Invoke-RestMethod -uri "http://$StackIP/api"

                    if($Pininverted){    
                        if ($StackLightRed -eq !$stackState.'17'.state) {
                            updatePinState -Pin 17 -Pininverted $true -CoilState $StackLightRed -PLCIP $StackIP
                            Write-Host "Red Changed State"
                        }
                        if ($StackLightBlue -eq !$stackState.'27'.state) {
                            updatePinState -Pin 27 -Pininverted $true -CoilState  $StackLightBlue -PLCIP $StackIP
                            Write-Host "blue Changed State"
                        }
                        if ($StackLightOrange -eq !$stackState.'22'.state) {
                            updatePinState -Pin 22 -Pininverted $true -CoilState  $StackLightOrange -PLCIP $StackIP
                            Write-Host "Amber Changed State"
                        }
                        if ($StackLightGreen -eq !$stackState.'24'.state) {
                            updatePinState -Pin 24 -Pininverted $true -CoilState  $StackLightGreen -PLCIP $StackIP
                            Write-Host "green Changed State"
                        }
                    }else{
                        if ($StackLightRed -eq $stackState.'17'.state) {
                            updatePinState -Pin 17 -Pininverted $false -CoilState $StackLightRed -PLCIP $StackIP
                            Write-Host "Red Changed State"
                        }
                        if ($StackLightBlue -eq $stackState.'27'.state) {
                            updatePinState -Pin 27 -Pininverted $false -CoilState  $StackLightBlue -PLCIP $StackIP
                            Write-Host "blue Changed State"
                        }
                        if ($StackLightOrange -eq $stackState.'22'.state) {
                            updatePinState -Pin 22 -Pininverted $false -CoilState  $StackLightOrange -PLCIP $StackIP
                            Write-Host "Amber Changed State"
                        }
                        if ($StackLightGreen -eq $stackState.'24'.state) {
                            updatePinState -Pin 24 -Pininverted $false -CoilState  $StackLightGreen -PLCIP $StackIP
                            Write-Host "green Changed State"
                        }
                    }






                    #End of PLC Secttion 
                }

                $oldMatchState = $psobject.data.MatchState
            }
            elseif ($psobject.type -eq "audienceDisplayMode") {
                if ($psobject.data -eq "sponsor") {
                    #insert code to toggle sponsor in mini
                }
                else {
                    #insert code to remove Sponsor in Mini
                }
                $Value =$psobject.data
                Invoke-WebRequest -uri "http://$companionAddress/api/custom-variable/audienceDisplayMode/value?value=$Value" -Method Post -ErrorAction SilentlyContinue | Out-Null
            }
            elseif ($psobject.type -eq "matchTime") {

                if ($verboselogging) {
                $timer = $psobject.data.MatchTimeSec
                out-TerminalLog -msg "$timer seconds since match started."
                }
            }
            elseif ($psobject.type -eq "eventStatus") {

                $eventcycletime = $psobject.data.CycleTime
                out-TerminalLog -msg "EventStatus Obtained: Last cycle is $EventCycleTime"
                

            }
            elseif ($psobject.type -eq "ping") { 
                if ($verboselogging) {
                    out-TerminalLog -msg "Ping Receaved"
                }
                
            }
            elseif ($psobject.type -eq "realtimeScore") {

                if ($verboselogging) {
                    out-TerminalLog -msg $msg
                }
                
            }
            elseif ($psobject.type -eq "allianceStationDisplayMode") {

                if ($verboselogging) {
                    out-TerminalLog -msg $msg
                }
                
            }
            elseif ($psobject.type -eq "matchTiming") {

                
                    out-TerminalLog -msg "match timing information received"
                
                
            }
            else {

                out-TerminalLog -msg $msg
            }
            

        }
        } until ($ws.State -ne [Net.WebSockets.WebSocketState]::Open)
    
}
        finally {
            out-TerminalLog -msg "Closing WS connection"
            $closetask = $ws.CloseAsync(
                [System.Net.WebSockets.WebSocketCloseStatus]::Empty,
                "",
                $ct
            )

            do { Start-Sleep(1) }
            until ($closetask.IsCompleted)
            $ws.Dispose()

            out-TerminalLog -msg "Stopping runspaces"
            $recv_runspace.Stop()
            $recv_runspace.Dispose()

            $send_runspace.Stop()
            $send_runspace.Dispose()
        }