#Requires AutoHotkey v2.0

; simple script to hold w and shift key and press space every second
; add a trigger key F2 for space smash and F3 for sprint cycle

#SingleInstance Force

isActive := false
isCycleActive := false
isShiftPressed := false
isCircleActive := false
circleDirection := 1  ; 1 for right, -1 for left
spaceTimer := 0
sprintTimer := 0
circleTimer := 0
cycleStartTime := 0
circleStartTime := 0

; Function to show key status
ShowKeyStatus(action, key) {
    ToolTip action " " key, 0, 0
    SetTimer RemoveToolTip, -1000
}

; Function to tap Shift key
TapShift() {
    global isShiftPressed
    ShowKeyStatus("Pressing", "Shift")
    SendInput "{Shift down}"
    Sleep 100
    SendInput "{Shift up}"
    ShowKeyStatus("Released", "Shift")
    isShiftPressed := true
}

; Function to use potion
UsePotion() {
    Sleep 200  ; Wait before starting potion use
    ShowKeyStatus("Pressing", "Potion")
    SendInput "5"
    Sleep 200  ; Wait between potion presses
    SendInput "5"
    Sleep 200  ; Wait after potion use
    ShowKeyStatus("Released", "Potion")
}

; Function to tap 5 key
TapFive() {
    ShowKeyStatus("Pressing", "5")
    SendInput "{5 down}"
    Sleep 50
    SendInput "{5 up}"
    ShowKeyStatus("Released", "5")
}

; Function to make character turn
RunInCircle() {
    global isCircleActive, circleDirection, circleStartTime
    if (!isCircleActive)
        return
        
    ; Start of cycle - tap shift after 0.5s
    if (circleStartTime = 0) {
        circleStartTime := A_TickCount
        SendInput "{w down}"
        SetTimer(TapShift, -500)  ; Tap shift after 0.5s
    }
    
    ; Get current mouse position
    MouseGetPos &x, &y
    
    ; Move mouse horizontally
    MouseMove x + (circleDirection * 20), y, 0  ; Move 20 pixels per update
    
    ; Continue the movement
    if (isCircleActive)
        circleTimer := SetTimer(RunInCircle, -10)  ; Update every 10ms for smoother turning
}

; Function to smash space for 3 seconds
SmashSpace() {
    global isActive, spaceTimer
    if (!isActive)
        return
    
    ; Smash space for 3 seconds
    startTime := A_TickCount
    lastFiveTime := A_TickCount
    while (A_TickCount - startTime < 3000 && isActive) {
        if (!isActive)
            return
            
        ; Check if it's time to tap 5 (every 500ms)
        if (A_TickCount - lastFiveTime >= 500) {
            TapFive()
            lastFiveTime := A_TickCount
        }
            
        ShowKeyStatus("Pressing", "Space")
        SendInput "{Space down}"
        Sleep 50
        SendInput "{Space up}"
        ShowKeyStatus("Released", "Space")
        Sleep 50  ; Small delay between space presses
    }
    
    ; Start next cycle
    if (isActive)
        spaceTimer := SetTimer(SmashSpace, -1)
}

; Function to handle sprint cycle
SprintCycle() {
    global isCycleActive, isShiftPressed, cycleStartTime
    if (!isCycleActive)
        return
        
    ; Start of cycle
    if (cycleStartTime = 0) {
        cycleStartTime := A_TickCount
        SendInput "{w down}"
        SetTimer(TapShift, -500)  ; Tap shift after 0.5s
    }
    
    ; Check if we've reached 28 seconds
    if (A_TickCount - cycleStartTime >= 28000) {
        SendInput "{w up}"
        if (isShiftPressed) {
            TapShift()
            isShiftPressed := false
        }
        cycleStartTime := 0
        ; Wait 10 seconds before next cycle
        if (isCycleActive)
            sprintTimer := SetTimer(SprintCycle, -10000)
        return
    }
    
    ; Continue the cycle check every second
    if (isCycleActive)
        sprintTimer := SetTimer(SprintCycle, -1000)
}

; Hotkey to toggle the behavior
F2:: {
    global isActive, spaceTimer
    isActive := !isActive
    
    if (isActive) {
        ToolTip "Auto Space Smash: ON", 0, 0
        SetTimer RemoveToolTip, -2000
        spaceTimer := SetTimer(SmashSpace, -1)
    } else {
        ToolTip "Auto Space Smash: OFF", 0, 0
        SetTimer RemoveToolTip, -2000
        if (spaceTimer) {
            SetTimer spaceTimer, 0
            spaceTimer := 0
        }
    }
}

; Hotkey to toggle the cycle behavior
F3:: {
    global isCycleActive, isShiftPressed, sprintTimer, cycleStartTime
    isCycleActive := !isCycleActive
    
    if (isCycleActive) {
        ToolTip "Auto Sprint: ON", 0, 0
        SetTimer RemoveToolTip, -2000
        cycleStartTime := 0
        sprintTimer := SetTimer(SprintCycle, -1)
    } else {
        ToolTip "Auto Sprint: OFF", 0, 0
        SetTimer RemoveToolTip, -2000
        if (sprintTimer) {
            SetTimer sprintTimer, 0
            sprintTimer := 0
        }
        SendInput "{w up}"
        if (isShiftPressed) {
            TapShift()
            isShiftPressed := false
        }
        cycleStartTime := 0
    }
}

; Hotkey to toggle turning
F4:: {
    global isCircleActive, circleTimer, circleDirection, circleStartTime, isShiftPressed
    isCircleActive := !isCircleActive
    
    if (isCircleActive) {
        ToolTip "Auto Turn: ON (" (circleDirection = 1 ? "Right" : "Left") ")", 0, 0
        SetTimer RemoveToolTip, -2000
        circleStartTime := 0
        circleTimer := SetTimer(RunInCircle, -1)
    } else {
        ToolTip "Auto Turn: OFF", 0, 0
        SetTimer RemoveToolTip, -2000
        if (circleTimer) {
            SetTimer circleTimer, 0
            circleTimer := 0
        }
        SendInput "{w up}"
        if (isShiftPressed) {
            TapShift()
            isShiftPressed := false
        }
        circleStartTime := 0
    }
}

; Hotkey to change turn direction
F5:: {
    global circleDirection, isCircleActive
    circleDirection := -circleDirection  ; Toggle between 1 and -1
    if (isCircleActive) {
        ToolTip "Turn Direction: " (circleDirection = 1 ? "Right" : "Left"), 0, 0
        SetTimer RemoveToolTip, -2000
    }
}

; Function to remove tooltip
RemoveToolTip() {
    ToolTip
}

; Clean up when script exits
OnExit(*) {
    global isShiftPressed, spaceTimer, sprintTimer, circleTimer
    SendInput "{w up}"
    if (isShiftPressed) {
        TapShift()
        isShiftPressed := false
    }
    if (spaceTimer) {
        SetTimer spaceTimer, 0
        spaceTimer := 0
    }
    if (sprintTimer) {
        SetTimer sprintTimer, 0
        sprintTimer := 0
    }
    if (circleTimer) {
        SetTimer circleTimer, 0
        circleTimer := 0
    }
}