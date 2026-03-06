{
            Lock-PodeObject -Name "PlayerAutomationLock" -CheckGlobal -ScriptBlock {
                $autostatus = $webevent.data.automation
                Set-PodeState -name "AutomationStatus" -Value @{"automation" = $autostatus}

            }
}