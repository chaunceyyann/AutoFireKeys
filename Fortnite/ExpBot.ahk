
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Read keybind config
IniRead, ToggleKey, config.ini, settings, ExpKeybind, %A_Space%

; Show GUI
Instruction = 
(
Please choose a toggle key below. (Automatically save to config.ini)
Select game mode (E.g. Team Ramble) before toggle this script on.
)
Gui, Add, Text,, %Instruction%
Gui, Add, Hotkey, vToggleKey w160, %ToggleKey%
Gui, Add, Button, w80 x+5, OK
Gui, Show,, Fortnite EXP Farming (1080P)

; set click interval in ms
SetTimer, SendP, 2500
movements := ["w", "a", "s", "d"] ; movement keys
return

ButtonOK:
    GuiControlGet, ToggleKey ; Retrieve the ListBox's current selection.
    IniWrite, %ToggleKey%, config.ini, settings, ExpKeybind
    Hotkey, %ToggleKey%, ExpSub
    Gui, Destroy
    return

ExpSub:
    pToggle := !pToggle
    return

; send P to ready up for fortnite BR
SendP:
    If (!pToggle)
        return
    Send {p}
    
    CoordMode, Mouse, Screen
    ; battle pass gif claim click
    Click, 1065, 939
    Sleep, 10
    ; there are times random error popup stopping the game, just need to hit continue
    Click, 960, 700
    Sleep, 10
    Click, 960, 630
    Sleep, 10
    ; ready up after match
    Click, 1875, 1060
    Sleep, 10
    Click, 1800, 800
    Sleep, 10

    ; random movements
    Random, rand , 1, 4
    movement := movements[rand]
    ;MsgBox, Value Is: %movement%
    Send {%movement% down}
    if (rand == 1){
        Sleep, 1000
        Send {esc}
        Sleep, 400
        Send {esc}
    }
    Sleep, 1000
    ;Send {esc}
    Send {space}
    Send {%movement% up}
    return