; Auto Fire script
; Use fuction keys as toggles or triggers

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IniRead, AutoHold, config.ini, settings, AutoKeybind, %A_Space%
IniRead, LlamasToggle, config.ini, settings, LlamasKeybind, %A_Space%
IniRead, RavagerHold, config.ini, settings, RavagerKeybind, %A_Space%
IniRead, RioHold, config.ini, settings, RioKeybind, %A_Space%
Gui, Add, Text,, Set hotkeys for 
Gui, Add, Text,, Left click - Hold (Semi-Auto to Auto)
Gui, Add, Hotkey, vAutoHold w160, %AutoHold%
Gui, Add, Text,, Left click - Toggle (Open multiple Llamas)
Gui, Add, Hotkey, vLlamasToggle w160, %LlamasToggle%
Gui, Add, Text,, Jump then heavy attack (SK Ravager)
Gui, Add, Hotkey, vRavagerHold w160, %RavagerHold%
Gui, Add, Text,, Fire 6 shots then reload (Firstshot Rio)
Gui, Add, Hotkey, vRioHold w160, %RioHold%
Gui, Add, Button, w160, OK
Gui, Show,, Fortnite Auto Fire

return

ButtonOK:
    Gui, Submit
    IniWrite, %AutoHold%, config.ini, settings, AutoKeybind
    IniWrite, %LlamasToggle%, config.ini, settings, LlamasKeybind
    IniWrite, %RavagerHold%, config.ini, settings, RavagerKeybind
    IniWrite, %RioHold%, config.ini, settings, RioKeybind

Instruction =
(
Auto Firing Mode Activated!
%AutoHold%: Hold to left click (Semi-auto to Auto)
%LlamasToggle%: Toggle to left click (Open Llamas)
%RavagerHold%: Hold to jump then right click (SK Ravager)
%RioHold%: Hold to fire 6 shots then reload (Firstshot Rio)
)
MsgBox,, Auto Fire, %Instruction%

ammo_rio := 6
ammo = %ammo_rio%
counter = %ammo%
fire_rate = 2.25
reload_s = 1.08
real_reload_s := (reload_s*1) ; first shot can be fire before reload finished
shots_delay := (1000/fire_rate)
reload_ms := (real_reload_s * 1000)
reload_ms_minus := (reload_ms-shots_delay)

; set click interval in ms
SetTimer, lClick, 25
SetTimer, rClick, 50
SetTimer, RioFire, %shots_delay%
;SetTimer, SendEnter, 5

; hold to left click
*F7::lToggle := 1
*F7 UP::lToggle := 0

; toggle to left click
F8::lToggle := !lToggle

; hold to right click
*F9::rToggle := 1
*F9 UP::rToggle := 0

; hold to use rio fire
*F10::rioToggle := 1
*F10 UP::
rioToggle := 0
Click, Up
return
; toggle to send Enter
; F11::eToggle := !eToggle

return

; Click functions
lClick:
    If (!lToggle)
        Return
    Click

rClick:
    If (!rToggle)
        Return
    Send, {Space}
    Sleep, 10
    Click, right

; RioFire (fire certain shots then reload)
RioFire:
    global counter
    If (!rioToggle){
        counter = %ammo%
        return
    }
    Click, Down
    If (counter >= ammo) {
        counter := 0
        SetTimer,, Off
        Sleep, (shots_delay*0.1)
        Click, Up
        Send {r}
        Sleep, %reload_ms_minus%
        SetTimer,, On
    }
    counter++
    return

; Send Enter
SnedEnter:
    If (!eToggle)
        return
    Send {Enter}