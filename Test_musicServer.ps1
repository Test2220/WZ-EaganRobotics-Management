Import-Module -Name Pode -MaximumVersion 2.99.99
$podeServer = "localhost"
Start-PodeServer -Threads 4 {

    Add-PodeEndpoint -Address $podeServer -Port 8880 -Protocol Http #endpoint for foobar
    Add-PodeEndpoint -Address $podeServer -Port 8080 -Protocol http #endpoint for VDJ

    Add-PodeRoute -Method Get,post -path "/api/player/:PlayerAction/:PlistID/:Pindex" -ScriptBlock{

        Write-PodeTextResponse "this is /api/playlists/:rallyid/items"
    }


    Add-poderoute -Method Get -Path "/" -ScriptBlock {
        Write-PodeTextResponse "This Is Root"
    }


}