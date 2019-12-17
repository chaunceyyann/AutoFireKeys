; auto fire script for Logitech G502
; use fuction keys as toggles or triggers

; set click interval in ms
SetTimer, lClick, 50
SetTimer, rClick, 50
SetTimer, AltFire, 50
SetTimer, SendP, 2000
;SetTimer, Enter, 5

movements := ["w", "a", "s", "d"]
ammo_rio := 6
ammo_2 := 2
ammo := %ammo_rio%
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
; F10::lToggle := !lToggle

; F10::eToggle := !eToggle

; send P for ready, for fortnite BR
F10::pToggle := !pToggle

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
    Click
    Random, rand , 1, 4
    movement := movements[rand]

    ;MsgBox, Value Is: %movement%
    Send {%movement% down}
    if (rand == 1)
        Send {space}
        Sleep, 1000
    Sleep, 1000
    Send {%movement% up}
    return

AltFire:
    If (!aToggle)
        counter = %ammo%
        return
    If (counter == %ammo%)
        counter = 0
        Send {r}
    Click
    counter++
    return
        

    
; Send Enter
; Enter:
;     If (!eToggle)
;         return
;     Send {Enter}
; return
