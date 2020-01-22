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
IniRead, LeaveBR, config.ini, settings, LeaveBrKeybind, %A_Space%
IniRead, LeaveSTW, config.ini, settings, LeaveStwKeybind, %A_Space%
Gui, Add, Text, , Set hotkeys for below macros, press <space> to remove keybind
Gui, Add, Text, , Left click - Hold (Semi-Auto to Auto)
Gui, Add, Hotkey, vAutoHold w160, %AutoHold%
Gui, Add, Text, , Left click - Toggle (Open multiple Llamas)
Gui, Add, Hotkey, vLlamasToggle w160, %LlamasToggle%
Gui, Add, Text, , Jump then heavy attack (SK Ravager)
Gui, Add, Hotkey, vRavagerHold w160, %RavagerHold%
Gui, Add, Text, , Fire 6 shots then reload (Firstshot Rio)
Gui, Add, Hotkey, vRioHold w160, %RioHold%
Gui, Add, Text, , Quick leave BR game
Gui, Add, Hotkey, vLeaveBR w160, %LeaveBR%
Gui, Add, Text, , Quick leave STW game stay with party
Gui, Add, Hotkey, vLeaveSTW w160, %LeaveSTW%
Gui, Add, Button, w160, OK
Gui, Show, , Fortnite Auto Fire

return

ButtonOK:
    Gui, Submit
    IniWrite, %AutoHold%, config.ini, settings, AutoKeybind
    IniWrite, %LlamasToggle%, config.ini, settings, LlamasKeybind
    IniWrite, %RavagerHold%, config.ini, settings, RavagerKeybind
    IniWrite, %RioHold%, config.ini, settings, RioKeybind
    IniWrite, %LeaveBR%, config.ini, settings, LeaveBrKeybind
    IniWrite, %LeaveSTW%, config.ini, settings, LeaveStwKeybind
    
    Instruction =
    (
    Auto Firing Mode Activated!
    User <Space> to remove unwanted hotkeys.
    %AutoHold%: Hold to left click (Semi-auto to Auto)
    %LlamasToggle%: Toggle to left click (Open Llamas)
    %RavagerHold%: Hold to jump then right click (SK Ravager)
    %RioHold%: Hold to fire 6 shots then reload (Firstshot Rio)
    %LeaveBR%: Quick leave BR game
    %LeaveSTW%: Quick leave STW game stay with party
    )
    MsgBox, , Auto Fire, %Instruction%
    
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
    Hotkey, %AutoHold%, LeftClick
    Hotkey, %AutoHold% UP, LeftClickUp
    
    ; toggle to left click
    Hotkey, %LlamasToggle%, LeftToggle
    
    ; hold to right click
    Hotkey, %RavagerHold%, RavagerClick
    Hotkey, %RavagerHold% UP, RavagerClickUp
    
    ; hold to use rio fire
    Hotkey, %RioHold%, RioClick
    Hotkey, %RioHold% UP, RioClickUp
    
    ; quick leave
    Hotkey, %LeaveBR%, QuickLeaveBR
    Hotkey, %LeaveSTW%, STWLeaveButStayParty
    
return

; Left Clicks
LeftClick:
    lToggle := 1
return

LeftClickUp:
    lToggle := 0
return

LeftToggle:
    lToggle := !lToggle
return

lClick:
    if (!lToggle)
    Return
Click
return

; Right Clicks
RavagerClick:
    rToggle := 1
return

RavagerClickUp:
    rToggle := 0
return

rClick:
    if (!rToggle)
    Return
Send, {Space}
Sleep, 10
Click, right
return

; RioFire (fire certain shots then reload)
RioClick:
    rioToggle := 1
return

RioClickUp:
    rioToggle := 0
    Click, Up
return

RioFire:
    global counter
    if (!rioToggle) {
        counter = %ammo%
    return
    }
Click, Down
if (counter >= ammo) {
    counter := 0
    SetTimer, , Off
    Sleep, (shots_delay*0.1)
    Click, Up
    Send {r}
    Sleep, %reload_ms_minus%
    SetTimer, , On
}
counter++
return

QuickLeaveBR:
    Send {Esc}
    Sleep, 200
    Click, 1500, 500
    Sleep, 200
    Click, 1150, 780
return

STWLeaveButStayParty:
    Send {Esc}
    Sleep, 50
    Click, 1410, 444
    Sleep, 100
    Click, 600, 580
    Sleep, 100
    Click, 1150, 780
return
