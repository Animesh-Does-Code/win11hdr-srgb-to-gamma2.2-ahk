function config() {
    $SDRValue = Read-Host "
Please enter your Windows' SDR content brightness slider value (Should be a number from 0 to 100)
(See README for more info)
"
While (!$SDRValue) {
    Write-Output "
No value entered, please try again"
    $SDRValue = Read-Host "
Please enter your Windows' SDR content brightness slider value (Should be a number from 0 to 100)
(See README for more info)
"
} 
([int]$SDRValue*4)+80 | Out-File $PSScriptRoot\SDRWhite

$gamma = Read-Host "
Please enter your preferred Gamma (Commonly 2.2 or 2.4)
"
While (!$gamma) {
    Write-Output "
No value was entered, please try again"
    $gamma = Read-Host "
Please enter your preferred Gamma (Commonly 2.2 or 2.4)
"
}
$gamma | Out-File -FilePath $PSScriptRoot\gammaval
}

$config = Get-Item $PSScriptRoot\config -ErrorAction SilentlyContinue
$configwithReload = Get-Item $PSScriptRoot\configwithReload -ErrorAction SilentlyContinue
if ($config -or $configwithReload) {
    $rerun = Read-Host "
Setup was already run before, change SDR brightness and gamma values? (Answer 'Yes' or 'No')
"
    if ($rerun -match 'Y') {
    config
    } 
} else {
    config
}

$Running = Get-Process HDRGammaFix -ErrorAction SilentlyContinue
$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin -ne 'True') {
    Write-Output "
Warning! SETUP.bat is running without administrator rights, please run as administrator for full functionality.
    "
    $exists = Get-ScheduledTask -TaskName "Apply sRGB to Gamma LUT" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Output "Restarting existing task to apply any changes...
"
        schtasks /run /tn "\Apply sRGB to Gamma LUT"
    }
    elseif (!$Running) {
       Write-Output "Running HDRGammaFix.exe..."
       & $PSScriptRoot\HDRGammaFix.exe
    } else {
       Write-Output "Trying to restart HDRGammaFix.exe to apply any changes..."
       try {
       $Running | Stop-Process -Force -ErrorAction Stop
    } catch {
        Write-Output "
Failed! Couldn't restart HDRGammaFix.exe since it was running as administrator! 
Use hotkey Win+Shift+3 to restart script manually for any changes to take effect.
"
       exit
    }  
       & $PSScriptRoot\HDRGammaFix.exe
       Write-Output "Done."
       exit
    }
    Write-Output "Done."
    exit
}

$ReloadCal = Read-Host "
Reload Windows color calibration when applying gamma transformation? (Enter 'Yes' or 'No')
(Recommended when using a Windows HDR Calibration app profile in Windows 11)
"
While (!$ReloadCal) {
    Write-Output "
No value was entered, please try again"
    $ReloadCal = Read-Host "
Reload Windows color calibration when applying gamma transformation? (Enter 'Yes' or 'No')
(Recommended when using a Windows HDR Calibration app profile in Windows 11)
"
}
if ($ReloadCal -match 'Y') {
    Out-File $PSScriptRoot\reloadColor
    Write-Output "
Reloading Windows color calibration requires running the .exe script as administrator when running it manually.
If the hotkey script is enabled on startup, it will run as administrator by default, without triggering UAC."
    Write-Host -NoNewLine '
Press any key to continue setup...
'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} else {
    Out-File $PSScriptRoot\noReload
    Write-Output "
Continuing regular setup...
"
}

$AutoStart = Read-Host "
Enable hotkey script on Windows startup? (Enter 'Yes' or 'No')
"
    While (!$AutoStart) {
    Write-Output "
No value was entered, please try again"
    $AutoStart = Read-Host "
Enable hotkey script on Windows startup? (Enter 'Yes' or 'No')
"
}
$taskName = "Apply sRGB to Gamma LUT"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$exeFile = "HDRGammaFix.exe"
$action = New-ScheduledTaskAction -Execute $exeFile -WorkingDirectory $PSScriptRoot
$triggers = @()
$triggers += New-ScheduledTaskTrigger -AtLogOn
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger.Subscription = 
@"
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and EventID=566]]</Select></Query></QueryList>
"@
$trigger.Enabled = $true
$trigger.Delay = 'PT5S'
$triggers += $trigger
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -Priority 4
$settings.CimInstanceProperties.Item('MultipleInstances').Value = 3

function checktask() {
    if ($existingTask -ne $null) {
    Write-Host "Removing previous task"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
}

function task() {
    checktask
    if (!$Running) {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    } else {
    $Running | Stop-Process -Force -ErrorAction Stop
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    Write-Output "Done."
   }
}
if ( ($AutoStart -match 'Y') -and ($ReloadCal -match 'Y') ) {
    Write-Output "Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    checktask
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    Write-Output "Done."
} elseif ( $AutoStart -match 'Y' ) {
    Write-Output "Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    task
} elseif ( $ReloadCal -match 'Y' ) {
    Write-Output "Running HDRGammaFix.exe..."
    $null = checktask
    $null = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    $null = schtasks /run /tn "\Apply sRGB to Gamma LUT"
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
} else {
    Write-Output "Running HDRGammaFix.exe..."
    $null = task
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
}