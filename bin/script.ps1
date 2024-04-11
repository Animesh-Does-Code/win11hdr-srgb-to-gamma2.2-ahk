function config() {
    $SDRValue = Read-Host "
-------------------------------------------------------------------------------------------------

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
$SDRValue | Out-File $PSScriptRoot\SDRValue

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
    if ($configwithReload) {
        $SDRValue = [Linq.Enumerable]::ElementAt([System.IO.File]::ReadLines("$PSScriptRoot\configwithReload"), 1)
        $gammaval = [Linq.Enumerable]::ElementAt([System.IO.File]::ReadLines("$PSScriptRoot\configwithReload"), 2)
    } else {
        $SDRValue = [Linq.Enumerable]::ElementAt([System.IO.File]::ReadLines("$PSScriptRoot\config"), 1)
        $gammaval = [Linq.Enumerable]::ElementAt([System.IO.File]::ReadLines("$PSScriptRoot\config"), 2)
    }
    $rerun = Read-Host "
-------------------------------------------------------------------------------------------------

Setup was already run before, current settings:

----------------------------
$SDRValue
$gammaval
----------------------------

Change SDR content brightness and gamma values? (Enter 'Yes' or 'No')
"
    if ($rerun -match 'Y') {
    config
    } 
} else {
    config
}

$guide = Write-Output "
------------------------------------------------------------------------------------
Use Win+F2 to apply gamma conversion and Win+F1 to revert all gamma changes.

Alternatively, Win+Shift+2 (to apply) and Win+Shift+1 (to revert) can also be used.
------------------------------------------------------------------------------------
"

$Running = Get-Process HDRGammaFix -ErrorAction SilentlyContinue
$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin -ne 'True') {
    Write-Output "
-------------------------------------------------------------------------------------------------

Warning! SETUP.bat is running without administrator rights, please run as administrator for full functionality.
    "
    $exists = Get-ScheduledTask -TaskName "Apply sRGB to Gamma LUT" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Output "Restarting existing task to apply any changes...
"
        schtasks /run /tn "\Apply sRGB to Gamma LUT"
        $guide
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
       $guide
       exit
    }
    Write-Output "Done."
    $guide
    exit
}

$ReloadCal = Read-Host "
-------------------------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------------------------

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
$trigger.Delay = 'PT7S'
$triggers += $trigger
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -Priority 4
$settings.CimInstanceProperties.Item('MultipleInstances').Value = 3

function checktask() {
    if ($null -ne $existingTask) {
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
    Write-Output "
Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    checktask
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    Write-Output "Done."
    $guide
} elseif ( $AutoStart -match 'Y' ) {
    Write-Output "
Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    $guide
    task
} elseif ( $ReloadCal -match 'Y' ) {
    Write-Output "
Running HDRGammaFix.exe..."
    $null = checktask
    $null = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    $null = schtasks /run /tn "\Apply sRGB to Gamma LUT"
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
    $guide
} else {
    Write-Output "
Running HDRGammaFix.exe..."
    $null = task
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
    $guide
}