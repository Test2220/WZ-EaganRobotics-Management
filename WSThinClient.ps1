<#
References:
    - https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.clientwebsocket?view=netframework-4.5
    - https://github.com/poshbotio/PoshBot/blob/master/PoshBot/Implementations/Slack/SlackConnection.ps1
    - https://www.leeholmes.com/blog/2018/09/05/producer-consumer-parallelism-in-powershell/
This script is to only grab the WS JSON table from Cheesy/Freezy Arena and Pass it to Pode for State Coniguration

#>
$ProgressPreference = "SilentlyContinue"

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



try {
    do {
        $msg = $null
        while ($recv_queue.TryDequeue([ref] $msg)) {
            
            $psobject = ConvertFrom-Json $msg
            if ($psobject.type -eq "arenaStatus") {

                $queue = Invoke-RestMethod -uri "http://$APIAddress/api/arena/queue/read"
                if($queue.type -notmatch "queueEmpty"){
                    $json = ConvertTo-Json $queue
                    $send_queue.Enqueue($json)
                }

                Invoke-RestMethod -Uri "http://$APIAddress/api/arena" -Method Post -Body $msg -ContentType "application/json" -ErrorAction SilentlyContinue | out-null  # reserving this invoke for passing JSON to the rest endpoint server.


                }

            }
            elseif ($psobject.type -eq "audienceDisplayMode") {
                if ($psobject.data -eq "sponsor") {
                    #insert code to toggle sponsor in mini
                }
                else {
                    #insert code to remove Sponsor in Mini
                }

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