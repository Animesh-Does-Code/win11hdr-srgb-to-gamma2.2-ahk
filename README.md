# Windows 11 SDR-in-HDR curve transformation from piecewise sRGB to Gamma using AutoHotkey

## This is a fork of [win11hdr-srgb-to-gamma2.2-icm](https://github.com/dylanraga/win11hdr-srgb-to-gamma2.2-icm) by dylanraga. 
#### dylanraga's original repo contains a great explanation on what is causing a "washed out" look or raised black levels when viewing SDR or AutoHDR content in Windows' HDR mode, and has some alternative workarounds for the issue.

#### This fork uses an AutoHotkey script + ArgyllCMS `dispwin` workaround heavily based on [mspeedo](https://github.com/mspeedo)'s .ahk [script](https://github.com/dylanraga/win11hdr-srgb-to-gamma2.2-icm/issues/7), which is based on dylanraga's workarounds.

Using AutoHotkey allows fast toggling of the gamma transformation, which is useful because the gamma correction can be detrimental to real HDR content, which do not suffer from the same issue this workaround tackles.
This method also optionally allows reloading Windows' color calibration with the hotkeys. See [Windows color calibration reload function](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk?tab=readme-ov-file#windows-color-calibration-reload-function) below for more info.

## Installation and Usage:

1. Download [HDRGammaFix.zip](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk/releases/latest/download/HDRGammaFix.zip) from the releases page and extract it to an easily accessible location where it can reside permanently.
2. Run `SETUP.bat` as administrator.
   - `SETUP.bat` can also be run without admin permissions, but without the ability to create startup tasks.
3. Follow the prompts that appear and enter your preferred values.
   - Your SDR content brightness slider value can be found in Windows' settings. For info, go to the [SDR content brightness slider guide](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk?tab=readme-ov-file#sdr-content-brightness-slider-guide) below.
4. The script will start running and can be controlled with hotkeys.
   - Use `Win+F1` to disable gamma changes and `Win+F2` to apply them again.
5. You can also run the script manually from `HDRGammaFix.exe`, but only after the initial setup.

`SETUP.bat` needs to be run again if SDR content brightness value or gamma need to be changed.

### Default Hotkeys

The default hotkeys are as follows:

#### 1. Apply gamma transformation:

   - `Win+F2`
     
     or
     
   - `Win+Shift+2`

#### 2. Disable gamma transformation (When viewing HDR content):

   - `Win+F1`
     
     or
     
   - `Win+Shift+1`

#### 3. Restart script: (Used for reloading SDR nits and gamma value changes after setup)

   - `Win+Shift+3`

## Uninstallation

- Run Uninstall.bat in the "uninstall" folder as administrator, and it should remove the task from task scheduler, if it exists.

- The script (if running) can be closed from the system tray in your taskbar by right-clicking the green "H" icon.

<hr>

## SDR content brightness slider guide

#### Find your SDR content brightness slider:

- Windows 11: https://www.elevenforum.com/t/change-hdr-or-sdr-content-brightness-for-hdr-display-in-windows-11.7832/

- Windows 10: https://www.tenforums.com/tutorials/146775-how-change-hdr-sdr-brightness-balance-level-windows-10-a.html

After you've set the slider to where you want it, enter the number that pops up when hovering over the slider's button in the setup.

## Windows Color Calibration reload function

If you've used Windows' HDR Calibration app (Windows 11 only) and applied a profile with it, there can be certain situations where it fails to apply.

This can happen after your display goes to sleep mode and wakes up again, or after your PC enters sleep mode and resumes. Reloading Windows' 
color calibration when applying the gamma transformation will fix this issue without having to open Display settings or Color management.

<hr>

## Notes/Troubleshooting

- The gamma ramp correction will persist when toggling HDR (including via the keyboard shortcut), making SDR appear darker. When disabling HDR, make sure to revert the gamma correction using the hotkey. Likewise, when re-enabling HDR, you have to re-apply the gamma correction again.
- If you have an NVIDIA GPU, make sure the NVCP desktop color settings is set to "Accurate" or "Enhanced" mode; the correction will not apply in "Reference" mode.
- Pixel values above diffuse SDR white are untouched; a soft shoulder was added toward unity to blend the curve mapping with HDR values (Not done by me, all credit goes to [dylanraga](https://github.com/dylanraga))

<hr>

<small><em> This workaround uses [ArgyllCMS'](https://www.argyllcms.com/) `dispwin` utility to apply the gamma correction and [AutoHotkey](https://www.autohotkey.com/) to run the script.</em></small>
