; Exit app if user not choose not to use this
MsgBox, 1,, This script will hold L-Shift key for user.`nPress Caplock to toggle it ON and OFF!
IfMsgBox, Cancel
	ExitApp

; set local var
ShiftReverseOn := 0
; button to set shift to reverse

*CapsLock::
    if (ShiftReverseOn = 1) {
        ShiftReverseOn := 0
        SetCapsLockState, On
        send {- Up}
    } else {
        ShiftReverseOn := 1
        SetCapsLockState, Off
        send {- Down}
    }
    msgbox % "ShiftReverse = " ShiftReverseOn " (0 off, 1 on)" 
    return

; actual hotkey - shiftdown should disengage shift, shiftup should engage it
#if (ShiftReverseOn = 0)
    $LShift::
    ; traytip, , shiftup, 1
    SetCapsLockState, On
    Send {- Up}
return
$LShift Up::
    ; traytip, , shiftdown, 1
    SetCapsLockState, Off
    Send {- Down}
return
#If