Import-Module -Name Pode -MaximumVersion 2.99.99
$podeServer = "localhost"
Start-PodeServer -Threads 4 {
New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    Add-PodeEndpoint -Address $podeServer -Port 8880 -Protocol Http #endpoint for foobar
    Add-PodeEndpoint -Address $podeServer -Port 8080 -Protocol http #endpoint for VDJ
    Add-PodeRouteGroup -Path "/api" -Routes{
        Add-PodeRouteGroup -Path "/player" -Routes{
            Add-PodeRoute -Method Get,post -path "/:PlayerAction/:PlistID/:Pindex" -ScriptBlock{

                Write-PodeTextResponse "this is /api/player/"
            }
        }
        Add-PodeRoute -Method Get -Path "/playlists/" -ScriptBlock {
            $string = '{"playlists":[{"id":"p1","index":0,"isCurrent":false,"itemCount":0,"title":"WalkIn","totalTime":0.0},{"id":"p2","index":1,"isCurrent":false,"itemCount":0,"title":"Gamestartup","totalTime":0.0},{"id":"p3","index":2,"isCurrent":false,"itemCount":0,"title":"CrowdRally","totalTime":0.0},{"id":"p4","index":3,"isCurrent":false,"itemCount":0,"title":"Inbetween","totalTime":0.0},{"id":"p5","index":4,"isCurrent":false,"itemCount":0,"title":"Walkout","totalTime":0.0},{"id":"p6","index":5,"isCurrent":true,"itemCount":0,"title":"TeamIntro","totalTime":0.0}]}'
            Write-PodeJsonResponse $string
        }
    }
    Add-PodeRoute -Method get -Path "/query" -ScriptBlock {
        $stringout =  $WebEvent.Query['script']
        if($stringout -match "automix"){
            Write-PodeTextResponse 'yes'    
        }elseif ($stringout -match "stem%20Vocal") {
            Write-PodeTextResponse '1' 
        }
        Write-PodeTextResponse 'true'

    }
    Add-PodeRoute -Method get -Path "/execute" -ScriptBlock {
            Write-PodeTextResponse "true"
    }

    Add-poderoute -Method Get -Path "/" -ScriptBlock {
        Write-PodeTextResponse "This Is Root"
    }


}