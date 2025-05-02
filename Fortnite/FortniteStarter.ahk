
#Persistent			; This keeps the script running permanently.
#SingleInstance		; Only allows one instance of the script to run.
#NoTrayIcon			; Need no icon

Gui, +Resize
Gui, Add, Text,, Pick script/s to launch from the list below.`nTo cancel, press ESCAPE or close this window.
Gui, +Delimiter`n
Gui, Add, ListBox, vMyListBox gMyListBox w640 0x100 Multi
Gui, Add, Button, Default, OK
loop, %A_ScriptDir%\Fortnite\*.ahk  ; Change this folder and wildcard pattern to suit your preferences.
{
    GuiControl,, MyListBox, %A_LoopFileFullPath%
}
Gui, Show
return

MyListBox:
if (A_GuiEvent != "DoubleClick")
    return
; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
; So fall through to the next label.
ButtonOK:
GuiControlGet, MyListBox  ; Retrieve the ListBox's current selection.
MsgBox, 4,, Would you like to run the script/s below?`n`n%MyListBox%
IfMsgBox, No
    return
Loop, Parse, MyListBox, `n
{
    Run, %A_LoopField%,, UseErrorLevel
    if (ErrorLevel = "ERROR")
        MsgBox %A_LoopField% `nfailed to launch. Please contact the creator of it.
}

return

GuiClose:
GuiEscape:
ExitApp