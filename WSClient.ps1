<#
References:
    - https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.clientwebsocket?view=netframework-4.5
    - https://github.com/poshbotio/PoshBot/blob/master/PoshBot/Implementations/Slack/SlackConnection.ps1
    - https://www.leeholmes.com/blog/2018/09/05/producer-consumer-parallelism-in-powershell/
#>

if(!(Test-Path -Path .\qualification.csv)){
$data = Invoke-WebRequest -Uri "http://172.16.20.5:8080/reports/csv/schedule/qualification" 
$data.Content | Out-File .\qualification.csv
}

#$quals = $data.Content

$APIIP = "localhost"

$client_id = [System.GUID]::NewGuid()

$recv_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'
$send_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'

$ws = New-Object Net.WebSockets.ClientWebSocket
$cts = New-Object Threading.CancellationTokenSource
$ct = New-Object Threading.CancellationToken($false)

Write-Output "Connecting..."
$connectTask = $ws.ConnectAsync("ws://172.16.20.5:8080/match_play/websocket", $cts.Token)
do { Start-Sleep(1) }
until ($connectTask.IsCompleted)
Write-Output "Connected!"

$recv_job = {
    param($ws, $client_id, $recv_queue)

    $buffer = [Net.WebSockets.WebSocket]::CreateClientBuffer(1024,1024)
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
    while ($ws.State -eq [Net.WebSockets.WebSocketState]::Open){
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

Write-Output "Starting recv runspace"
$recv_runspace = [PowerShell]::Create()
$recv_runspace.AddScript($recv_job).
    AddParameter("ws", $ws).
    AddParameter("client_id", $client_id).
    AddParameter("recv_queue", $recv_queue).BeginInvoke() | Out-Null

Write-Output "Starting send runspace"
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

try {
    do {
        $msg = $null
        while ($recv_queue.TryDequeue([ref] $msg)) {
            
            $psobject = ConvertFrom-Json $msg
          if($psobject.type -eq "arenaStatus"){
            $currenttime = Get-Date
            $timespan = New-TimeSpan -Start $LastPull -End $currenttime

            if ($timespan.TotalSeconds -ge 5) {
                $playerstatus = Invoke-RestMethod -Uri "http://$APIIP/api/music/"
                $playerAuotmationFlag = Invoke-RestMethod -uri "http://$APIIP/api/music/automation"
                $LastPull  = Get-Date
            }
            Invoke-RestMethod -Uri "http://172.16.45.58:80/api/arena" -Method Post -Body $msg -ContentType "application/json" |out-null

    
                if($playerstatus -ne "CrowdRally"){
                    if($playerAuotmationFlag.automation -eq $true){
                        if(($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and (($playerstatus.CurrentPlayer -ne "Startup") -or ($playerstatus.CurrentPlayer -ne "TeamIntro"))){
                            if(($playerstatus.CurrentPlayer -eq "Startup") -or ($playerstatus.CurrentPlayer -eq "TeamIntro")){
                            }else{
                                Invoke-WebRequest -uri "http://$APIIP/change-song" -Method Post -Body '{ "Player": "Startup"}'|Out-Null
                                Write-Output "Match Ready Switching to Startup music"

                            }
                        }
                        if(($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($playerstatus.CurrentPlayer -ne "Gameon")){
                            Invoke-WebRequest -uri "http://$APIIP/change-song" -Method Post -Body '{ "Player": "Gameon"}'|Out-Null
                            Write-Output "Match is live switching to Game On and Setting Flag for Match is running"
                        }
                        if(($psobject.data.MatchState -eq 6) -and ($playerstatus.CurrentPlayer -ne "Inbetween" )){
                            Invoke-WebRequest -uri "http://$APIIP/change-song" -Method Post -Body '{ "Player": "Inbetween"}'|Out-Null
                            Write-Output "Match is completed Switching to Inbetween music"
                        }
                    }else {
                        if(($psobject.data.MatchState -eq 0) -and ($psobject.data.CanStartMatch -eq $true) -and (($playerstatus.CurrentPlayer -ne "Startup") -or ($playerstatus.CurrentPlayer -ne "TeamIntro"))){
                            if(($playerstatus.CurrentPlayer -eq "Startup") -or ($playerstatus.CurrentPlayer -eq "TeamIntro")){
                            }else{
                                Invoke-WebRequest -uri "http://$APIIP/change-song" -Method Post -Body '{ "Player": "Startup"}'|Out-Null
                                Write-Output "(Automation Disabled) Match is Ready"

                            }
                        }
                        if(($psobject.data.MatchState -ge 1) -and ($psobject.data.MatchState -le 5) -and ($playerstatus.CurrentPlayer -ne "Gameon")){
                            Invoke-WebRequest -uri "http://$APIIP/change-song" -Method Post -Body '{ "Player": "Gameon"}'|Out-Null
                            Write-Output "(Automation Disabled) Match is live"
                        }
                        if(($psobject.data.MatchState -eq 6) -and ($playerstatus.CurrentPlayer -ne "Inbetween" )){
                            Write-Output "(Automation Disabled) Match is completed"
                        }
                    }
                    if($RallyStatusConfim -eq $True) {$RallyStatusConfim = $false}
                }elseif (($playerstatus -eq "CrowdRally")-and ($RallyStatusConfim -eq $false)) {
                    write-host "Rally song is playing overwriting controls to play until song is over"
                    $RallyStatusConfim = $true
                }
                if(($psobject.data.CanStartMatch -eq $true) -and ($oldMatchstartdata -ne $psobject.data.CanStartMatch) ){
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/MatchStartStatus/value?value=True" -Method Post|Out-Null
                    Write-host "Setting Companion Start Status to True"
                }elseif (($psobject.data.CanStartMatch -eq $false) -and ($oldMatchstartdata -ne $psobject.data.CanStartMatch) ) {
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/MatchStartStatus/value?value=False" -Method Post|Out-Null
                    Write-host "Setting Companion Start Status to False"
                }

                if($oldB1Team -ne $psobject.data.AllianceStations.B1.Team.ID){
                    $team = $psobject.data.AllianceStations.B1.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB1Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting B1 to $team"
                }
                if($oldB2Team -ne $psobject.data.AllianceStations.B2.Team.ID){
                    $team = $psobject.data.AllianceStations.B2.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB2Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting B2 to $team"
                }
                if($oldB3Team -ne $psobject.data.AllianceStations.B3.Team.ID){
                    $team = $psobject.data.AllianceStations.B3.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB3Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting B3 to $team"
                }

                if($oldR1Team -ne $psobject.data.AllianceStations.R1.Team.ID){
                    $team = $psobject.data.AllianceStations.R1.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR1Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting R1 to $team"
                }
                if($oldR2Team -ne $psobject.data.AllianceStations.R2.Team.ID){
                    $team = $psobject.data.AllianceStations.R2.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR2Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting R2 to $team"
                }
                if($oldR3Team -ne $psobject.data.AllianceStations.R3.Team.ID){
                    $team = $psobject.data.AllianceStations.R3.Team.ID
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR3Team/value?value=$team" -Method Post|Out-Null
                    Write-host "Setting R3 to $team"
                }


                if($oldB1Byp -ne $psobject.data.AllianceStations.B1.Bypass){
                    $Value= $psobject.data.AllianceStations.B1.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB1Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting B1 Bypass Status to $Value"
                }
                if($oldB2Byp -ne $psobject.data.AllianceStations.B2.Bypass){
                    $Value= $psobject.data.AllianceStations.B2.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB2Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting B3 Bypass Status to $Value"
                }
                if($oldB3Byp -ne $psobject.data.AllianceStations.B3.Bypass){
                    $Value= $psobject.data.AllianceStations.B3.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaB3Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting B3 Bypass Status to $Value"
                }

                if($oldR1Byp -ne $psobject.data.AllianceStations.R1.Bypass){
                    $Value= $psobject.data.AllianceStations.R1.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR1Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting R1 Bypass Status to $Value"
                }
                if($oldR2Byp -ne $psobject.data.AllianceStations.R2.Bypass){
                    $Value= $psobject.data.AllianceStations.R2.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR2Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting R3 Bypass Status to $Value"
                }
                if($oldR3Byp -ne $psobject.data.AllianceStations.R3.Bypass){
                    $Value= $psobject.data.AllianceStations.R3.Bypass
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaR3Bypass/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting R3 Bypass Status to $Value"
                }
                if($oldMatchState -ne $psobject.data.MatchState){
                    $Value= $psobject.data.MatchState
                    Invoke-WebRequest -uri "http://192.168.30.12:8000/api/custom-variable/ArenaMatchState/value?value=$Value" -Method Post|Out-Null
                    Write-host "Setting MatchState to $Value"
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
        if($psobject.type -eq "audienceDisplayMode"){
            if($psobject.data -eq "sponsor"){
                #insert code to toggle sponsor in mini
            }else{
                #insert code to remove Sponsor in Mini
            }
        }
        if($psobject.type -eq "matchTime"){
        Write-Output $msg
        }


        }
    } until ($ws.State -ne [Net.WebSockets.WebSocketState]::Open)
}
finally {
    Write-Output "Closing WS connection"
    $closetask = $ws.CloseAsync(
        [System.Net.WebSockets.WebSocketCloseStatus]::Empty,
        "",
        $ct
    )

    do { Start-Sleep(1) }
    until ($closetask.IsCompleted)
    $ws.Dispose()

    Write-Output "Stopping runspaces"
    $recv_runspace.Stop()
    $recv_runspace.Dispose()

    $send_runspace.Stop()
    $send_runspace.Dispose()
}