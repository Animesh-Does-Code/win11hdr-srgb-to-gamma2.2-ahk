## Installation and Usage:

1. Run SETUP.bat as administrator
2. Follow the prompts that appear and enter your preferred values.
   - Your SDR content brightness slider value can be found in Windows' settings. Further in the 
   README are links to tutorials on how to find it, in case it's needed. 
3. The script will start running and can be controlled with hotkeys.
4. You can also run the script manually from HDRGammaFix.exe, but only after the initial setup.

Tip:

- SETUP.bat needs to be run again if SDR content brightness or gamma needs to be changed.
   - Running as administrator is *not required* when only changing these two settings.

## Default Hotkeys

The default hotkeys are as follows:

1. Apply gamma transformation:

 - Win+F2
   
    _or_
   
 - Win+Shift+2

2. Revert gamma transformation (When viewing HDR content):

 - Win+F1
   
    _or_
  
 - Win+Shift+1

3. Restart script: (Used for reloading SDR nits and gamma value changes after setup)

- Win+Shift+3


## SDR content brightness slider guide:

Find your SDR content brightness slider:

- Windows 11: https://www.elevenforum.com/t/change-hdr-or-sdr-content-brightness-for-hdr-display-in-windows-11.7832/

- Windows 10: https://www.tenforums.com/tutorials/146775-how-change-hdr-sdr-brightness-balance-level-windows-10-a.html

After you've set the slider to where you want it, enter the number that pops up when hovering over the slider's button in the setup.


## Windows Color Calibration reload function info

If you've used Windows' HDR Calibration app and applied a profile, there can be certain situations where it doesn't apply its changes.

This can happen after your display goes to sleep mode and wakes up again, or after your PC enters sleep mode and resumes. Reloading Windows' 
color calibration when applying the gamma transformation will fix this issue without having to open Display settings or Color management.


## Uninstallation

- Run Uninstall.bat in the "uninstall" folder as administrator, and it should remove the task from task scheduler, if it exists.

- The script (if running) can be closed from the system tray in your taskbar by right-clicking the green "H" icon.