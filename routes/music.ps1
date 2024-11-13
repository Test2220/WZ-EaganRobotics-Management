


$playlistIDs = $using:PlayerIndex
$rallyid = $playlistIDs.CrowdRally
$apiIPPort = $using:MusicPlayerIP
$playlist =Invoke-RestMethod -Uri "http://$apiIPPort/api/playlists/$rallyid/items/0%3A100?columns=%25title%25,%25artist%25,%25album%2"
Write-PodeViewResponse -Path "MusicControl" -Data @{"payload" = $playlist.playlistItems.items;}