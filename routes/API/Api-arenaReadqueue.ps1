{
            $queue = Get-Content -Path "./data/queue.json" -ErrorAction Stop| ConvertFrom-Json

            if($null -eq $queue.1 ){
                $payload = '{"type":"queueEmpty"}'
            }else{
                $payload = $queue.1 | ConvertTo-Json
                    $tempqueue = $queue | Select-Object -Property * -ExcludeProperty 1
                    $newqueue = New-Object -TypeName PSObject
        
                    foreach ($data in $tempqueue.PSObject.Properties.Value){
                        $newequeueIndex = $newqueue.psobject.Properties.Name.count + 1
                        $newqueue | Add-Member -MemberType NoteProperty -Name $newequeueIndex -Value $data
                    }
                    $newqueuecount = $newqueue.psobject.Properties.Name.count

                    if ($newqueuecount -eq 0){
                        "{}" |Out-File -FilePath './data/queue.json'
                    }else{

                        $output = $newqueue | convertto-json

                        $output |Out-File -FilePath './data/queue.json'
                    }
            }
            Write-PodeJsonResponse -Value $payload
        }