$taskName = "Apply sRGB to Gamma LUT"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask -ne $null) {
    Write-Output "Removing task"
    try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
    }
    catch {
        Write-Error "Access Denied"
        Write-Output "Failed to remove task! Please run Uninstall.bat as administrator."
        exit
    }
    Write-Output "Success!"
    exit
} else {
    Write-Output "Task does not exist, uninstall not necessary."
    exit
}