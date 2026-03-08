set-PodeState -Name 'currentlyplaying' -Value @{ 'currentplayer' = "none"; } | Out-Null
set-podestate -Name "PlayerConfig" |Out-Null
set-podestate -Name "PlaylistConfig" |Out-Null

New-PodeLockable -name "playlistLock"
New-PodeLockable -name "playerconfigLock"
New-PodeLockable -Name 'currentlyplayingLock'
New-PodeLockable -Name 'PlayerAutomationLock'