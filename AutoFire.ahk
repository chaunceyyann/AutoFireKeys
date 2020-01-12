; auto fire script for Logitech G502
; use fuction keys as toggles or triggers

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; set click interval in ms
SetTimer, lClick, 25
SetTimer, rClick, 50
SetTimer, AltFire, 500
SetTimer, SendP, 2500
;SetTimer, Enter, 5

movements := ["w", "a", "s", "d"]

ammo_rio := 6
ammo_2 := 1
ammo = %ammo_2%
counter = %ammo%

; hold to use alt fire
*F7::aToggle := 1
*F7 UP::aToggle := 0

; hold to fire left click
*F8::lToggle := 1
*F8 UP::lToggle := 0

; hold to fire right click
*F9::aToggle := 1
*F9 UP::aToggle := 0

; toggle to fire
F6::lToggle := !lToggle

; F10::eToggle := !eToggle

; send P for ready, for fortnite BR
^k::pToggle := !pToggle


F5::
    Send {Escape}
    CoordMode, Mouse, Screen
    Click, 2400, 460

; click funct
rClick:
    If (!rToggle)
        Return
    Click, right

lClick:
    If (!lToggle)
        Return
    Click

; Send P
SendP:
    If (!pToggle)
        return
    Send {p}
    ;Sleep, 1000
    
    CoordMode, Mouse, Screen
    ; battle pass gif claim click
    Click, 1065, 939
    ; there are times random error popup stopping the game, just need to hit continue
    Click, 960, 700
    Click, 960, 630
    ; ready up after match
    Click, 1875, 1060
    Click, 1800, 840

    ; random movements
    Random, rand , 1, 4
    movement := movements[rand]
    ;MsgBox, Value Is: %movement%
    Send {%movement% down}
    if (rand == 1){
        Sleep, 1000
        Send {esc}
        Sleep, 500
        Send {esc}
    }
    Sleep, 1000
    ;Send {esc}
    Send {space}
    Send {%movement% up}
    return

; altFire mode
AltFire:
    global counter
    If (!aToggle){
        counter = %ammo%
        return
    }
    Click
    If (counter >= ammo) {
        counter := 0
        Send {r}
    }
    ;send {%counter%}
    ;MsgBox, Value Is: %ammo%
    counter++
    return
   
; Send Enter
; Enter:
;     If (!eToggle)
;         return
;     Send {Enter}
; return
