$SDRWhite = Read-Host "
Please enter your SDR white luminance in nits 
(*Must* correspond to your 'SDR content brightness' slider value in Windows, see README for more info)
"
While (!$SDRWhite) {
    Write-Output "
No value entered, please try again"
    $SDRWhite = Read-Host "
Please enter your SDR white luminance in nits 
(*Must* correspond to your 'SDR content brightness' slider value in Windows)
"
} 
$SDRWhite | Out-File -FilePath $PSScriptRoot\SDRWhite

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

$Running = Get-Process HDRGammaFix -ErrorAction SilentlyContinue
$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin -ne 'True') {
    Write-Output "
Warning! SETUP.bat is running without administrator rights, please run as administrator for full functionality.
    "
    if (!$Running) {
       Write-Output "Running HDRGammaFix.exe..."
       & $PSScriptRoot\HDRGammaFix.exe
    } else {
       Write-Output "Trying to restart HDRGammaFix.exe..."
       try {
       $Running | Stop-Process -Force -ErrorAction Stop
    } catch {
        Write-Output "
Failed! Couldn't restart HDRGammaFix.exe since it was running as administrator! 
Use hotkey Win+Shift+3 to restart script manually for changes to take effect.
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
    Set-Content -Path $PSScriptRoot\apply.vbs -Value 'Set shell = CreateObject("Wscript.Shell")
shell.run "schtasks /run /tn ""\Microsoft\Windows\WindowsColorSystem\Calibration Loader""", 0, True
shell.run "dispwin.exe templut", 0, True
'
    Set-Content -Path $PSScriptRoot\restore.vbs -Value 'Set shell = CreateObject("Wscript.Shell")
shell.run "schtasks /run /tn ""\Microsoft\Windows\WindowsColorSystem\Calibration Loader""", 0, True
'
    Write-Output "
Reloading Windows color calibration requires running the .exe script as administrator when running it manually. 
The Windows startup task (If created) runs as administrator by default on startup, without triggering UAC."
    Write-Host -NoNewLine '
Press any key to continue setup...
'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} else {
    Set-Content -Path $PSScriptRoot\apply.vbs -Value 'Set shell = CreateObject("Wscript.Shell")
shell.run "dispwin.exe templut", 0, True'
    Set-Content -Path $PSScriptRoot\restore.vbs -Value ''
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
Enable hotkey script on startup? (Enter 'Yes' or 'No')
"
}
$taskName = "Apply sRGB to Gamma LUT"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$exeFile = "HDRGammaFix.exe"
$action = New-ScheduledTaskAction -Execute $exeFile -WorkingDirectory $PSScriptRoot
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

function checktask() {
    if ($existingTask -ne $null) {
    Write-Host "Removing previous task"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
}

function task() {
    checktask
    if (!$Running) {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    } else {
    $Running | Stop-Process -Force -ErrorAction Stop
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    Write-Output "Done."
   }
}
if ( ($AutoStart -match 'Y') -and ($ReloadCal -match 'Y') ) {
    Write-Output "Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    checktask
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
    schtasks /run /tn "\Apply sRGB to Gamma LUT"
    Write-Output "Done."
} elseif ( $AutoStart -match 'Y' ) {
    Write-Output "Adding 'Apply sRGB to Gamma LUT' task to task scheduler..."
    task
} elseif ( $ReloadCal -match 'Y' ) {
    Write-Output "Running HDRGammaFix.exe..."
    $null = checktask
    $null = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
    $null = schtasks /run /tn "\Apply sRGB to Gamma LUT"
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
} else {
    Write-Output "Running HDRGammaFix.exe..."
    $null = task
    $null = & Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Done."
}