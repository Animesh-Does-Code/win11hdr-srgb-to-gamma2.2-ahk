# Windows 11 SDR-in-HDR curve transformation from piecewise sRGB to Gamma using AutoHotkey

## This is a fork of [win11hdr-srgb-to-gamma2.2-icm](https://github.com/dylanraga/win11hdr-srgb-to-gamma2.2-icm) by dylanraga. 
**dylanraga's original repo contains a great explanation on what is causing a "washed out" look or raised black levels when viewing SDR or AutoHDR content in Windows' HDR mode, and has some alternative workarounds for the issue.**

**This fork uses an AutoHotkey script + ArgyllCMS `dispwin` workaround heavily based on [mspeedo](https://github.com/mspeedo)'s .ahk [script](https://github.com/dylanraga/win11hdr-srgb-to-gamma2.2-icm/issues/7), which was written using dylanraga's formulas. Additionally, it uses [ledoge](https://github.com/ledoge)'s `set_sdrwhite` tool included in their [set_maxtml](https://github.com/ledoge/set_maxtml) tool's GitHub release to automatically set SDR content brightness using hotkeys.**

## Installation and Usage:

1. Download either [HDRGammaFix.zip](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk/releases/latest/download/HDRGammaFix.zip) or [HDRGammaFix_AutoHDR.zip](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk/releases/latest/download/HDRGammaFix_AutoHDR.zip) from the releases page and extract it to an easily accessible location where it can reside permanently.
   - The HDRGammaFix_AutoHDR variant contains a separate hotkey to fix AutoHDR gamma.
2. Run `SETUP.bat` as administrator.
   - `SETUP.bat` can also be run _without admin permissions_, but 'run at startup' tasks cannot be created.
3. Follow the prompts that appear and enter your preferred values.
   - Your SDR content brightness slider value can be found in Windows' HDR settings. For extra info, go to the [SDR content brightness slider guide](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk?tab=readme-ov-file#sdr-content-brightness-slider-guide) below.
4. The script will start running and can be controlled with hotkeys.
   - Use `Win+F1` to disable gamma changes and `Win+F2` to apply them again. `Win+F3` applies AutoHDR specific gamma correction in the AutoHDR variant, only use this with AutoHDR content like supported games.
5. You can also run the script manually from `HDRGammaFix.exe`, but only after the initial setup.

#### Tip:

- `SETUP.bat` needs to be run again if SDR content brightness value or gamma need to be changed.
  - Running as administrator is **not required** when only changing these two settings.

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

#### 3. Apply AutoHDR gamma transformation (AutoHDR variant only):

   - `Win+F3`
     
     or
     
   - `Win+Shift+3`

#### 4. Restart script: (Used for reloading SDR nits and gamma value changes after setup)

   - `Win+Shift+4`

## Uninstallation

- Run Uninstall.bat in the "uninstall" folder as administrator, and it should remove the task from task scheduler, if it exists.

- The script (if running) can be closed from the system tray in your taskbar by right-clicking the green "H" icon.

<hr>

## Why use this?

Using AutoHotkey allows fast toggling of the gamma transformation, which is useful because the gamma correction can be detrimental to real HDR content, which do not suffer from the same issue this workaround tackles.
This method also optionally allows reloading Windows' color calibration with the hotkeys. See [Windows color calibration reload function](https://github.com/Animesh-Does-Code/win11hdr-srgb-to-gamma2.2-ahk?tab=readme-ov-file#windows-color-calibration-reload-function) below for more info.

## SDR content brightness slider guide

**Find your SDR content brightness slider:**

- Windows 11: https://www.elevenforum.com/t/change-hdr-or-sdr-content-brightness-for-hdr-display-in-windows-11.7832/

- Windows 10: https://www.tenforums.com/tutorials/146775-how-change-hdr-sdr-brightness-balance-level-windows-10-a.html

After you've set the slider to where you want it, enter the number that pops up when hovering over the slider's button in the setup.

## Windows Color Calibration reload function

If you've used Windows' HDR Calibration app (Windows 11 only) and applied a profile with it, there can be certain situations where it fails to apply.

This can happen after your display goes to sleep mode and wakes up again, or after your PC enters sleep mode and resumes. Reloading Windows' 
color calibration when applying the gamma transformation will fix this issue without having to open Display settings or Color management.

<hr>

<h1>Extra</h1>

For reference, below is a table with Windows SDR content brightness slider values and their corresponding SDR white nit values, in case you want to set it up with an SDR white of exactly 100 or 200 nits for example. Credit goes to dylanraga's original repo.

## Windows SDR content brightness table

| SDR brightness value | SDR white screen luminance |
| -------------------- | -------------------------- |
| 0                    | 80 nits                    |
| 5                    | 100 nits                   |
| 10                   | 120 nits                   |
| 30                   | 200 nits                   |
| 55                   | 300 nits                   |
| 80                   | 400 nits                   |
| 100                  | 480 nits                   |

## Notes/Troubleshooting

- The gamma ramp correction will persist when toggling HDR (including via the keyboard shortcut), making SDR appear darker. When disabling HDR, make sure to revert the gamma correction using the hotkey. Likewise, when re-enabling HDR, you have to re-apply the gamma correction again.
- On systems with multiple monitors, the gamma correction might not apply to the correct monitor. Setting the monitor you want the gamma correction to apply to as the "main" monitor in Windows settings might help, but I can't confirm since I do not currently have a multi-monitor setup.
- If you have an NVIDIA GPU, make sure the NVCP desktop color settings is set to "Accurate" or "Enhanced" mode; the correction will not apply in "Reference" mode.
- If the gamma correction doesn't apply or applies for only a moment, check if you have DisplayCal or other similar software running in the background and close them. This should allow the changes to be applied.
- Pixel values above diffuse SDR white are untouched; a soft shoulder was added toward unity to blend the curve mapping with HDR values (Not done by me, all credit goes to [dylanraga](https://github.com/dylanraga))

<hr>

<small><em> This workaround uses [ArgyllCMS'](https://www.argyllcms.com/) `dispwin` utility to apply the gamma correction and [AutoHotkey](https://www.autohotkey.com/) to run the script. Additionally, it uses `set_sdrwhite` from ledoge's [set_maxtml](https://github.com/ledoge/set_maxtml) GitHub repo to change SDR content brightness on-the-fly.</em></small>
