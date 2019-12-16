; auto fire script for Logitech G502
; use fuction keys as toggles or triggers

; set click interval in ms
SetTimer, lClick, 40
SetTimer, rClick, 40
SetTimer, SendP, 6000
;SetTimer, Enter, 5


Random, rand , 1, 4
movements := ["w", "a", "s", "d"]

; hold to fire left click
*F8::lToggle := 1
*F8 UP::lToggle := 0

; hold to fire right click
*F9::rToggle := 1
*F9 UP::rToggle := 0

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
    Sleep, 1000
    Click
    move := movements[rand]
    Send {move down}
    Sleep, 1000
    Send {move up}
    return

; Send Enter
; Enter:
;     If (!eToggle)
;         return
;     Send {Enter}
; return
