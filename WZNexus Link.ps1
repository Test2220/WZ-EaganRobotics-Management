

try {
    $Nexusconfig = Get-Content -Path "./data/Nexus.json" -ErrorAction Stop| ConvertFrom-Json
}
catch {
    $Nexusconfig = New-Object -TypeName psobject
    Write-host "error no config for Nexus API please go to https://frc.nexus/en/api and insert api key"
    $Nexuseventid = Read-Host "event ID here"
    $NexusAPIKEY = Read-Host "Paste Nexus API Key here"

    $Nexusconfig | Add-Member -MemberType NoteProperty -Name "eventid" -Value $Nexuseventid
    $Nexusconfig | Add-Member -MemberType NoteProperty -Name "API" -Value $NexusAPIKEY

    ConvertTo-Json $Nexusconfig | Out-File -FilePath ".\data\Nexus.json" 
}
finally {
$eventid = $Nexusconfig.eventid
$APIKey = $Nexusconfig.API
}
$NexusObject = New-Object -TypeName PSObject
$NexusTeamData = New-Object -TypeName PSObject
$NexusObject |Add-Member -MemberType NoteProperty -Name type -Value "substituteTeam"
$NexusTeamData |Add-Member -MemberType NoteProperty -Name team -Value "9999"
$NexusTeamData |Add-Member -MemberType NoteProperty -Name position -Value "NO"
$NexusObject |Add-Member -MemberType NoteProperty -Name Data -Value $NexusTeamData
do {
    

    try {
        $NexusData = Invoke-RestMethod -uri "https://frc.nexus/api/v1/event/$eventid" -Method Get -Headers @{"Nexus-Api-Key" = $APIKey} -ErrorAction Stop
    }
    catch {
        Remove-Item ".\data\Nexus.json"
        Read-host "error Rejecting script API key is invalid please generate new keys "
        break
            
        }

    
    finally {
        
        $ArenaData = Invoke-RestMethod -uri http://localhost:8080/api/arena



        $matchindex = $ArenaData.data.MatchID -1

        
        if ($ArenaData.data.MatchState -eq 0) {
 
            if ($arenadata.data.AllianceStations.B1.team.Id -ne [int]$NexusData.matches[$matchindex].blueTeams[0]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].blueTeams[0]
                $NexusObject.Data.position = "B1"    

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post | Out-Null
                Write-Host $payload
            }
            if ($arenadata.data.AllianceStations.B2.team.Id -ne [int]$NexusData.matches[$matchindex].blueTeams[1]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].blueTeams[1]
                $NexusObject.Data.position = "B2"    

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post| Out-Null
                Write-Host $payload}
            if ($arenadata.data.AllianceStations.B3.team.Id -ne [int]$NexusData.matches[$matchindex].blueTeams[2]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].blueTeams[2]
                $NexusObject.Data.position = "B3"    

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post| Out-Null
                Write-Host $payload
            }
            if ($arenadata.data.AllianceStations.r1.team.Id -ne [int]$NexusData.matches[$matchindex].redTeams[0]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].redTeams[0]
                $NexusObject.Data.position = "R1"    

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post | Out-Null
                Write-Host $payload
            }
            if ($arenadata.data.AllianceStations.r2.team.Id -ne [int]$NexusData.matches[$matchindex].redTeams[1]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].redTeams[1]
                $NexusObject.Data.position = "R2"   

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post| Out-Null
            Write-Host $payload
            }
            if ($arenadata.data.AllianceStations.r3.team.Id -ne [int]$NexusData.matches[$matchindex].redTeams[2]){
                $NexusObject.Data.team = [int]$NexusData.matches[$matchindex].redTeams[2]
                $NexusObject.Data.position = "R3"    

                $payload = ConvertTo-Json $NexusObject
                Invoke-RestMethod -uri 'http://localhost:8080/api/arena/queue' -Body $payload -Method Post| Out-Null
                Write-Host $payload
            }

        }
    }
     
    Start-Sleep -Seconds 5
}while ($true)