{
if ($webevent.method -eq "post") {
                    try{
                        $queue = Get-Content -Path "./data/queue.json" -erroraction Stop| ConvertFrom-Json
                    }Catch{$queue = New-Object -TypeName PSObject}
                    if($null -eq $queue.1 ){
                        $queue = New-Object -TypeName PSObject
                    }
                
                    $queueindex = $queue.psobject.Properties.name.count + 1
                    $queue |Add-Member -MemberType NoteProperty -Name $queueindex -Value $webevent.data 
                    

                    $output = $queue | convertto-json 
                    $output |Out-File -FilePath './data/queue.json'
                    write-PodeJsonResponse -Value $Output
                
                
            }else{
                Write-PodeJsonResponse -Path "./data/queue.json"
                
            }
        }