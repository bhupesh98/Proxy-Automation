# Define variables
$taskName = 'Toggle Proxy Based on Network'
$taskDescription = 'This is a task that runs an executable that toggles the system proxy settings based on the network connection.'

# If ps2exe is not installed, Install-Module
if (-not (Get-Module -Name ps2exe)) {
    Install-Module ps2exe
}
# Convert the .ps1 file to an executable
Invoke-PS2EXE .\ToggleProxy.ps1 .\toggle-proxy.exe
$exePath = "$PWD\toggle-proxy.exe"

# Create the action for the task (running the executable)
$action = New-ScheduledTaskAction -Execute $exePath

# Set up trigger on an event (network change)
$trigger = New-CimInstance -CimClass (Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger) -ClientOnly
$trigger.Subscription = @"
<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[Provider[@Name='Microsoft-Windows-NetworkProfile']and EventID=10000]]</Select></Query></QueryList>
"@

$trigger.Repetition = 'MSFT_TaskRepetitionPattern'
$trigger.Enabled = $True

# Define the principal (which user account the task will run under)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Create the task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable

# Create and register the task
Register-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description $taskDescription -TaskName $taskName
