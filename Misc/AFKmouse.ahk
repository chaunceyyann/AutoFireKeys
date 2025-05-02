Pause
loop
	MoveMouseInCircle(400, 20)
return

F2::Pause
Esc::ExitApp

MoveMouseInCircle(r := 200, degInc := 5, start := "top", speed := 0)
{
	static radPerDeg := 3.14159265359 / 180

	MouseGetPos, cx, cy
	Switch start
	{
		Case "top":
			angle := 0
			cy += r
		Case "right":
			angle := 90 * radPerDeg
			cx -= r
		Case "bottom":
			angle := 180 * radPerDeg
			cy -= r
		Case "left":
			angle := 270 * radPerDeg
			cx += r
	}
	loop, % 360 / degInc
	{
		angle += degInc * radPerDeg
		MouseMove, cx + r * Sin(angle), cy - r * Cos(angle)
		Sleep, speed
	}
}