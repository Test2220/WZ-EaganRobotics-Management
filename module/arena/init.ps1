    Set-PodeState -Name 'FMSArenaStatus' -Value @{ 'values' = @(); } | Out-Null
    set-podestate -name "TestarenaState"|Out-Null

     New-PodeLockable -Name 'workstationLock'
    New-PodeLockable -Name 'FMSArenaStatusLock'
    New-PodeLockable -Name 'ConfigStateLock'
    New-PodeLockable -Name 'arenaQueueLock'
    New-PodeLockable -Name 'FMSArenamatchtime'
    New-PodeLockable -Name  "TestArenaLock"