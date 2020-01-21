SetFormat, Integer, Hex

color = 0xFF0000

Gui, +AlwaysOnTop -Caption
Gui, Color, %color%
Gui, Show, x953 y532 w20 h20 ;x1273 y532 (2560x1080)

Process, Exist
WinGet, hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%

WinSet, Region, E 5-5 w5 h5, ahk_id %hw_gui%
return

^F1::
	if ( DllCall( "IsWindowVisible", "uint", hw_gui ) )
		Gui, Hide
	else
		Gui, Show
return
