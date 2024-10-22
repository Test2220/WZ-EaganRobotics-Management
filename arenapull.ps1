<#
References:
    - https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.clientwebsocket?view=netframework-4.5
    - https://github.com/poshbotio/PoshBot/blob/master/PoshBot/Implementations/Slack/SlackConnection.ps1
    - https://www.leeholmes.com/blog/2018/09/05/producer-consumer-parallelism-in-powershell/    
    
    $PLCState.data.Inputs[7] #Red1Connect
    $PLCState.data.Inputs[8] #Red2Connect
    $PLCState.data.Inputs[9] #Red3Connect

    $PLCState.data.Inputs[10] #Blue1Connect
    $PLCState.data.Inputs[11] #Blue2Connect
    $PLCState.data.Inputs[12] #Blue3Connect

    $PLCState.data.Coils[1] #matchReset
    
    $PLCState.data.Coils[2] #stackLightGreen
    $PLCState.data.Coils[3] #stackLightOrange
    $PLCState.data.Coils[4] #stackLightRed
    $PLCState.data.Coils[5] #stackLightBlue
    $PLCState.data.Coils[6] #stackLightBuzzer
    $PLCState.data.Coils[7] #fieldResetLight

#>



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
            "Sending message: $workitem" | Out-File -FilePath "logs.txt" -Append

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

try {
    do {
        $msg = $null
        while ($recv_queue.TryDequeue([ref] $msg)) {
            
            $psobject = ConvertFrom-Json $msg
            
            
            if ($psobject.type -eq "arenaStatus") {
                # Invoke-RestMethod -Uri "http://172.16.45.58:80/api/arena" -Method Post -Body $msg -ContentType "application/json" -ErrorAction SilentlyContinue |out-null  # reserving this invoke for passing JSON to the rest endpoint server.
                if (($psobject.data.MatchState -eq 3)-or ($psobject.data.MatchState -eq 5)) {

                    $currenttime = Get-Date
                    if ($null -eq $LastPull){
                        $LastPull  = (Get-Date).AddMinutes(-1)

                    } 
                    $timespan = New-TimeSpan -Start $LastPull -End $currenttime
        
                    if ($timespan.TotalSeconds -ge 5) {
                        $test_payload= ConvertFrom-Json '{"type":"updateRealtimeScore","data":{"blueAuto":0,"redAuto":20,"blueTeleop":0,"redTeleop":0,"blueEndgame":0,"redEndgame":0}}'
                        if ($psobject.data.MatchState -eq 3) {
                            $test_payload.data.blueAuto  = Get-Random -Minimum 0 -Maximum 30
                            $test_payload.data.redAuto  = Get-Random -Minimum 0 -Maximum 30
                        }
                        if ($psobject.data.MatchState -eq 5) {
                            $test_payload.data.blueTeleop  = Get-Random -Minimum 0 -Maximum 60
                            $test_payload.data.redTeleop  = Get-Random -Minimum 0 -Maximum 60
                            $test_payload.data.blueEndgame  = Get-Random -Minimum 0 -Maximum 30
                            $test_payload.data.redEndgame  = Get-Random -Minimum 0 -Maximum 30
                        }


                        $json = ConvertTo-Json $test_payload
                        $send_queue.Enqueue($json)

                        $LastPull  = Get-Date
                    }

                }



            }
            if($psobject.type -eq "ping"){
                Write-Host "Ping Receaved"
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
