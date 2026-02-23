#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines, -1
#singleInstance force

Menu, Tray, Add, Reload, RELOAD
Menu, Tray, Default, Reload
Menu, Tray, Click, 1

;------------------ SET GLOBAL VARIABLES -------------------------------------------------

SetFormat, float, 0.14
global m1 := (2610 / 4096) / 4
global m2 := (2523 / 4096) * 128
global c1 := (3424 / 4096)
global c2 := (2413 / 4096) * 32
global c3 := (2392 / 4096) * 32

;------------------ Load Calibration ------------------------------------------------------

if (FileExist("reloadColor")) {
FileMove, config, configwithReload, 1
path = configwithReload
} else if (FileExist("noReload")) {
FileMove, configwithReload, config, 1
path = config
} else if (FileExist("configwithReload")) {
path = configwithReload
} else {
path = config
}

FileDelete reloadColor
FileDelete noReload

if (FileExist("gammaval") and FileExist("SDRValue")) {
  FileReadLine, SDRWhite, SDRValue, 1
  whiteLuminance := (SDRWhite*4)+80
  blackLuminance := 0
  FileReadLine, gamma, gammaval, 1
  CREATE_LUT_FILE(whiteLuminance,blackLuminance,gamma,SDRWhite,path)
}

FileReadLine, str, %path%, 2
word_array := StrSplit(str, A_Space, "")
SDRSliderNits := (word_array[4]*4)+80

if (FIleExist("configwithReload")) {
  admin := A_IsAdmin
} else {
  admin := ""
}

;**The line below applies the gamma fix at script startup. Delete it if you don't want this behavior.**
apply(admin, path, SDRSliderNits)

;------------------ LUT CALIBRATION CURVES HOTKEYS----------------------------------------

#F1::
#+1::
  ResetCalibrationCurve(admin)
Return

#F2::
#+2::
  apply(admin, path, SDRSliderNits)
Return

#+4::
  Reload

;------------------ LUT CALIBRATION CURVES FUNCTIONS -------------------------------------

ResetCalibrationCurve(admin) {
  if (admin) {
  RunWait, schtasks /run /tn "\Microsoft\Windows\WindowsColorSystem\Calibration Loader", , Hide
  }
  clear = -c
  RunWait, dispwin.exe %clear%, , Hide
}
Return

apply(admin, path, SDRSliderNits) {
  if (admin) {
  RunWait, schtasks /run /tn "\Microsoft\Windows\WindowsColorSystem\Calibration Loader", , Hide
 }
  RunWait, set_sdrwhite.exe 0 %SDRSliderNits%, , Hide
  RunWait, dispwin.exe %path%, , Hide
}

CREATE_LUT_FILE(whiteLuminance, blackLuminance, gamma, SDRWhite, path) {

calcurve = 
(
CAL    
SDR content brightness: %SDRWhite%
Gamma: %gamma%
DESCRIPTOR "w=%whiteLuminance% b=%blackLuminance% g=%gamma%"
ORIGINATOR "vcgt"
DEVICE_CLASS "DISPLAY"
COLOR_REP "RGB"

NUMBER_OF_FIELDS 4
BEGIN_DATA_FORMAT
RGB_I RGB_R RGB_G RGB_B
END_DATA_FORMAT

NUMBER_OF_SETS 1024
BEGIN_DATA
0.00000000000000	0.00000000000000	0.00000000000000	0.00000000000000
)


Loop, 1023
{
 b:= (A_Index / 1023)
 c:= PQ_EOTF(b)
 d:= SRGB_INV_EOTF(c,whiteLuminance,blackLuminance)
 e:= blackLuminance + (whiteLuminance-blackLuminance)*(d**gamma)
 f:= PQ_INV_EOTF(Max(0,e))
 x:= f + Min(1,(c/whiteLuminance)) * (b-f)
 
 calcurve := calcurve "`n" b "	" x "	" x "	" x
}

calcurve := calcurve "`n" "END_DATA"

FileDelete %path%
FileAppend % calcurve, %path%
FileDelete SDRValue
FileDelete gammaval

Return
}


PQ_EOTF(V) {
  x := 10000 * (Max(V ** (1 / m2) - c1, 0) / (c2 - c3 * V ** (1 / m2))) ** (1 / m1)
  return x
}



PQ_INV_EOTF(L) {
  x := ((c1 + c2 * (L / 10000) ** m1) / (1 + c3 * (L / 10000) ** m1)) ** m2
  return x
}



SRGB_INV_EOTF(L, whiteLuminance, blackLuminance) {
  X1 = 0.0404482362771082
  X2 = 0.00313066844250063
  
  x := (L - blackLuminance) / (whiteLuminance - blackLuminance)
  
  If (x > 1) {
    x := 1
  } Else If (x < 0) {
    x := 0
  } Else If (x <= X2) {
    x := x * 12.92
  } Else {
    x := 1.055 * (x ** (1 / 2.4)) - 0.055
  }
  
  return x
}

;-----------------------------------------------------------------------------------------

RELOAD:
reload